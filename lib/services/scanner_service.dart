import 'dart:io';
import 'package:photo_manager/photo_manager.dart';
import '../models/screenshot_model.dart';
import 'database_service.dart';

class ScannerService {
  static final ScannerService _instance = ScannerService._internal();
  factory ScannerService() => _instance;
  ScannerService._internal();

  final DatabaseService _db = DatabaseService();

  /// Request photo permissions
  Future<bool> requestPermission() async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    return ps.isAuth || ps.hasAccess;
  }

  /// Scan device for screenshots and return new (unscanned) ones.
  ///
  /// [limit]           – max screenshots to return (null = unlimited).
  /// [analyzeExisting] – if false, only returns screenshots captured AFTER
  ///                     [existingCutoff] (defaults to app install time / now).
  ///                     if true (default), scans the entire gallery.
  Future<List<ScreenshotModel>> scanForScreenshots({
    int? limit,
    bool analyzeExisting = true,
    DateTime? existingCutoff,
  }) async {
    final hasPermission = await requestPermission();
    if (!hasPermission) {
      throw Exception('Storage permission required. Please open your Android app settings and allow Photos & Videos access to scan screenshots.');
    }

    // If not analyzing existing, only look at files newer than cutoff
    final cutoff = (!analyzeExisting)
        ? (existingCutoff ?? DateTime.now().subtract(const Duration(minutes: 5)))
        : null;

    // Get all albums
    final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      filterOption: FilterOptionGroup(
        imageOption: const FilterOption(
          sizeConstraint: SizeConstraint(
            minWidth: 100,
            minHeight: 100,
          ),
        ),
        orders: [
          const OrderOption(
            type: OrderOptionType.createDate,
            asc: false,
          ),
        ],
      ),
    );

    final List<ScreenshotModel> newScreenshots = [];

    // Find the main unified gallery album or explicit screenshot albums
    for (final album in albums) {
      final albumName = album.name.toLowerCase();

      // Get the unified gallery (Recent/All) where photo_manager dumps everything chronologically,
      // OR specific screenshot folders. This prevents duplicating scans from multiple nested sub-albums.
      final isValidAlbum = album.isAll ||
          albumName == 'recent' ||
          albumName == 'recents' ||
          albumName == 'all' ||
          albumName.contains('screenshot') ||
          albumName.contains('screen shot') ||
          albumName.contains('screencap') ||
          albumName.contains('captures') ||
          albumName.contains('screen') ||
          albumName.contains('capture');

      if (!isValidAlbum) continue;

      // Get all assets in this relevant album
      final int assetCount = await album.assetCountAsync;
      if (assetCount == 0) continue;

      final int fetchCount = limit != null
          ? (limit - newScreenshots.length).clamp(1, assetCount)
          : assetCount;

      final List<AssetEntity> assets =
          await album.getAssetListRange(start: 0, end: fetchCount);

      for (final asset in assets) {
        // Skip if older than cutoff (when analyzeExisting is false)
        if (cutoff != null && asset.createDateTime.isBefore(cutoff)) {
          continue;
        }

        File? file;
        try {
          file = await asset.file;
        } catch (e) {
          continue;
        }
        if (file == null) continue;

        final imagePath = file.path;

        // Check if already in database
        final exists = await _db.screenshotExists(imagePath);
        if (exists) continue;

        // Create new screenshot entry
        final screenshot = ScreenshotModel(
          imagePath: imagePath,
          dateAdded: DateTime.now(),
          dateTaken: asset.createDateTime,
          isScanned: false,
        );

        newScreenshots.add(screenshot);

        // Break out early if we reached the limit
        if (limit != null && newScreenshots.length >= limit) {
          return newScreenshots;
        }
      }
    }

    // Also check standard screenshot directories directly (expanded list)
    final standardDirs = [
      '/storage/emulated/0/Pictures/Screenshots',
      '/storage/emulated/0/DCIM/Screenshots',
      '/storage/emulated/0/Screenshots',
      '/storage/emulated/0/Pictures/Captures',
      '/storage/emulated/0/DCIM/Captures',
      '/storage/emulated/1/Pictures/Screenshots', // Secondary storage
    ];

    for (final dirPath in standardDirs) {
      try {
        final dir = Directory(dirPath);
        if (!await dir.exists()) continue;

        await for (final entity in dir.list(followLinks: false)) {
          if (entity is File) {
            // Skip if older than cutoff
            if (cutoff != null) {
              try {
                final stat = await entity.stat();
                if (stat.modified.isBefore(cutoff)) continue;
              } catch (_) {
                continue;
              }
            }

            final ext = entity.path.toLowerCase();
            if (ext.endsWith('.png') ||
                ext.endsWith('.jpg') ||
                ext.endsWith('.jpeg') ||
                ext.endsWith('.webp')) {
              final exists = await _db.screenshotExists(entity.path);
              if (exists) continue;

              final stat = await entity.stat();
              final screenshot = ScreenshotModel(
                imagePath: entity.path,
                dateAdded: DateTime.now(),
                dateTaken: stat.modified,
                isScanned: false,
              );

              newScreenshots.add(screenshot);

              if (limit != null && newScreenshots.length >= limit) {
                return newScreenshots;
              }
            }
          }
        }
      } catch (e) {
        // Silently ignore permission errors for restricted directories
        continue;
      }
    }

    return newScreenshots;
  }

  /// Insert newly found screenshots into the database
  Future<int> registerNewScreenshots(List<ScreenshotModel> screenshots) async {
    if (screenshots.isEmpty) return 0;
    await _db.insertScreenshots(screenshots);
    return screenshots.length;
  }

  /// Get count of screenshots pending scan
  Future<int> getPendingScanCount() async {
    final unscanned = await _db.getUnscannedScreenshots();
    return unscanned.length;
  }
}
