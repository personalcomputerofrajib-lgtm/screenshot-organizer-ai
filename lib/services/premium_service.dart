import 'package:shared_preferences/shared_preferences.dart';
import '../config/constants.dart';

class PremiumService {
  static final PremiumService _instance = PremiumService._internal();
  factory PremiumService() => _instance;
  PremiumService._internal();

  SharedPreferences? _prefs;

  Future<SharedPreferences> get prefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Check if user is premium
  Future<bool> isPremium() async {
    final p = await prefs;
    return p.getBool(AppConstants.prefIsPremium) ?? false;
  }

  /// Set premium status
  Future<void> setPremium(bool value) async {
    final p = await prefs;
    await p.setBool(AppConstants.prefIsPremium, value);
  }

  /// Get current scan count
  Future<int> getScanCount() async {
    final p = await prefs;
    return p.getInt(AppConstants.prefScanCount) ?? 0;
  }

  /// Increment scan count
  Future<int> incrementScanCount({int by = 1}) async {
    final p = await prefs;
    final current = p.getInt(AppConstants.prefScanCount) ?? 0;
    final newCount = current + by;
    await p.setInt(AppConstants.prefScanCount, newCount);
    return newCount;
  }

  /// Check if user can scan (free tier limit)
  Future<bool> canScan() async {
    if (await isPremium()) return true;
    final count = await getScanCount();
    return count < AppConstants.freeMaxScans;
  }

  /// Get remaining free scans
  Future<int> getRemainingScans() async {
    if (await isPremium()) return -1; // Unlimited
    final count = await getScanCount();
    return (AppConstants.freeMaxScans - count).clamp(0, AppConstants.freeMaxScans);
  }

  /// Check if this is the first launch
  Future<bool> isFirstLaunch() async {
    final p = await prefs;
    return p.getBool(AppConstants.prefFirstLaunch) ?? true;
  }

  /// Mark first launch as done
  Future<void> setFirstLaunchDone() async {
    final p = await prefs;
    await p.setBool(AppConstants.prefFirstLaunch, false);
  }
}
