import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_2/core/services/hive_service.dart';

class SettingsState {
  final bool notificationsEnabled;
  final bool darkModeEnabled;

  const SettingsState({
    required this.notificationsEnabled,
    required this.darkModeEnabled,
  });

  SettingsState copyWith({
    bool? notificationsEnabled,
    bool? darkModeEnabled,
  }) {
    return SettingsState(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier()
      : super(const SettingsState(
          notificationsEnabled: true,
          darkModeEnabled: false,
        )) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final box = HiveService.getSettingsBox();
    final notificationsEnabled =
        box.get(HiveService.notificationsEnabledKey, defaultValue: true) as bool;
    final darkModeEnabled =
        box.get(HiveService.darkModeEnabledKey, defaultValue: false) as bool;

    state = state.copyWith(
      notificationsEnabled: notificationsEnabled,
      darkModeEnabled: darkModeEnabled,
    );
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    state = state.copyWith(notificationsEnabled: enabled);
    await HiveService.getSettingsBox()
        .put(HiveService.notificationsEnabledKey, enabled);
  }

  Future<void> setDarkModeEnabled(bool enabled) async {
    state = state.copyWith(darkModeEnabled: enabled);
    await HiveService.getSettingsBox().put(HiveService.darkModeEnabledKey, enabled);
  }
}

final settingsControllerProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) => SettingsNotifier(),
);
