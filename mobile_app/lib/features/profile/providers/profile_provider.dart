import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/logger.dart';
import '../../../core/network/api_client.dart';
import '../../auth/models/user_model.dart';
import '../models/profile_model.dart';

class ProfileProvider extends ChangeNotifier {
  final SharedPreferences _prefs;
  UserModel? _user;
  
  ProfileModel? _activeProfile;
  List<ProfileModel> _profiles = [];
  bool _isLoading = false;

  ProfileProvider({
    required SharedPreferences sharedPreferences,
  }) : _prefs = sharedPreferences {
    _restoreActiveProfile();
  }

  bool get isLoading => _isLoading;
  ProfileModel? get activeProfile => _activeProfile;
  List<ProfileModel> get profiles => _profiles;

  void updateAuth(String? token, UserModel? user) {
    _user = user;
    if (user != null) {
      _profiles = user.profiles;
    }
    // Wire tokens to ApiClient singleton
    ApiClient.instance.updateToken(token);
    if (_activeProfile != null) {
      ApiClient.instance.updateActiveProfile(_activeProfile?.id);
    }
    notifyListeners();
  }

  void _restoreActiveProfile() {
    final activeId = _prefs.getString(AppConstants.keyActiveProfileId);
    if (activeId != null && _profiles.isNotEmpty) {
      try {
        _activeProfile = _profiles.firstWhere((p) => p.id == activeId);
        ApiClient.instance.updateActiveProfile(_activeProfile?.id);
        AppLogger.info('Active Profile restored: ${_activeProfile?.name}');
      } catch (_) {
        _activeProfile = null;
      }
    }
  }

  Future<bool> selectProfile(ProfileModel profile, {String? pinInput}) async {
    if (profile.pin != null && profile.pin != pinInput) {
      AppLogger.warning('Profile select blocked: Incorrect PIN');
      return false;
    }

    _activeProfile = profile;
    await _prefs.setString(AppConstants.keyActiveProfileId, profile.id);
    ApiClient.instance.updateActiveProfile(profile.id);
    AppLogger.info('Active Profile set to: ${profile.name}');
    notifyListeners();
    return true;
  }

  Future<bool> createProfile(String name, {bool isKids = false, String? pin}) async {
    if (_user == null) return false;
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Try sending request to backend
      final response = await ApiClient.instance.post('/profiles', body: {
        'name': name,
        'isKids': isKids,
        'pin': pin,
      });

      final decoded = jsonDecode(response.body);
      if (decoded['success'] == true) {
        final newProfile = ProfileModel.fromJson(decoded['data']);
        _profiles.add(newProfile);
        
        // Save user profiles locally
        await _saveUpdatedProfilesLocally();
        
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      AppLogger.warning('Create profile API failed: $e. Using local mock fallback...');
    }

    // Local fallback/mocking
    try {
      final newProfileId = 'prof_new_${DateTime.now().millisecondsSinceEpoch}';
      final newProfile = ProfileModel(
        id: newProfileId,
        name: name,
        avatarUrl: 'https://api.dicebear.com/7.x/bottts/png?seed=$name',
        isKids: isKids,
        pin: pin,
        languagePreference: 'en',
      );

      _profiles.add(newProfile);
      await _saveUpdatedProfilesLocally();
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      AppLogger.error('Failed to create profile locally: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProfile(String profileId, {String? name, bool? isKids, String? pin, String? languagePreference}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiClient.instance.post('/profiles/$profileId', body: {
        if (name != null) 'name': name,
        if (isKids != null) 'isKids': isKids,
        if (pin != null) 'pin': pin,
        if (languagePreference != null) 'languagePreference': languagePreference,
      });

      final decoded = jsonDecode(response.body);
      if (decoded['success'] == true) {
        final updated = ProfileModel.fromJson(decoded['data']);
        final idx = _profiles.indexWhere((p) => p.id == profileId);
        if (idx != -1) {
          _profiles[idx] = updated;
          if (_activeProfile?.id == profileId) {
            _activeProfile = updated;
          }
          await _saveUpdatedProfilesLocally();
        }
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      AppLogger.warning('Update profile API failed: $e. Updating locally...');
      // Local fallback update
      final idx = _profiles.indexWhere((p) => p.id == profileId);
      if (idx != -1) {
        final current = _profiles[idx];
        final updated = ProfileModel(
          id: current.id,
          name: name ?? current.name,
          avatarUrl: current.avatarUrl,
          isKids: isKids ?? current.isKids,
          pin: pin ?? current.pin,
          languagePreference: languagePreference ?? current.languagePreference,
        );
        _profiles[idx] = updated;
        if (_activeProfile?.id == profileId) {
          _activeProfile = updated;
        }
        await _saveUpdatedProfilesLocally();
      }
    }

    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<bool> deleteProfile(String profileId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiClient.instance.delete('/profiles/$profileId');
      final decoded = jsonDecode(response.body);
      if (decoded['success'] == true) {
        _profiles.removeWhere((p) => p.id == profileId);
        if (_activeProfile?.id == profileId) {
          _activeProfile = null;
          _prefs.remove(AppConstants.keyActiveProfileId);
          ApiClient.instance.updateActiveProfile(null);
        }
        await _saveUpdatedProfilesLocally();
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      AppLogger.warning('Delete profile API failed: $e. Removing locally...');
    }

    // Local delete fallback
    _profiles.removeWhere((p) => p.id == profileId);
    if (_activeProfile?.id == profileId) {
      _activeProfile = null;
      _prefs.remove(AppConstants.keyActiveProfileId);
      ApiClient.instance.updateActiveProfile(null);
    }
    await _saveUpdatedProfilesLocally();
    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<void> _saveUpdatedProfilesLocally() async {
    if (_user != null) {
      final updatedUser = UserModel(
        id: _user!.id,
        email: _user!.email,
        role: _user!.role,
        subscriptionPlan: _user!.subscriptionPlan,
        profiles: _profiles,
      );
      await _prefs.setString(AppConstants.keyUser, jsonEncode(updatedUser.toJson()));
    }
  }
}
