import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config.dart';
import '../utils/storage_service.dart';
import '../utils/audio_service.dart';
import '../models/user_data.dart';
import '../widgets/animated_scale_button.dart';

/// Settings screen — Music, Sound, Vibration, Dark Theme, Reset Progress, Privacy Policy, About.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _musicEnabled;
  late bool _soundEnabled;
  late bool _vibrationEnabled;
  late bool _darkTheme;

  @override
  void initState() {
    super.initState();
    final storage = Provider.of<StorageService>(context, listen: false);
    final settings = storage.userData.settings;
    _musicEnabled = settings.musicEnabled;
    _soundEnabled = settings.soundEnabled;
    _vibrationEnabled = settings.vibrationEnabled;
    _darkTheme = settings.darkTheme;
  }

  void _saveSettings() {
    final storage = Provider.of<StorageService>(context, listen: false);
    storage.updateSettings(
      UserSettings(
        musicEnabled: _musicEnabled,
        soundEnabled: _soundEnabled,
        vibrationEnabled: _vibrationEnabled,
        darkTheme: _darkTheme,
      ),
    );
    // Apply audio settings at runtime
    AudioService.instance.setMusicEnabled(_musicEnabled);
    AudioService.instance.setSoundEnabled(_soundEnabled);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameConfig.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.all(GameConfig.spacingMd),
              child: Row(
                children: [
                  AnimatedScaleButton(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: GameConfig.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: GameConfig.surfaceLight,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 20,
                        color: GameConfig.textColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: GameConfig.spacingMd),
                  Text(
                    'SETTINGS',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(GameConfig.spacingMd),
                children: [
                  // Audio section
                  _buildSection('Audio', [
                    _buildToggle(
                      'Music',
                      Icons.music_note_rounded,
                      _musicEnabled,
                      (v) {
                        setState(() => _musicEnabled = v);
                        _saveSettings();
                      },
                    ),
                    _buildToggle(
                      'Sound',
                      Icons.volume_up_rounded,
                      _soundEnabled,
                      (v) {
                        setState(() => _soundEnabled = v);
                        _saveSettings();
                      },
                    ),
                    _buildToggle(
                      'Vibration',
                      Icons.vibration,
                      _vibrationEnabled,
                      (v) {
                        setState(() => _vibrationEnabled = v);
                        _saveSettings();
                      },
                    ),
                  ]),
                  const SizedBox(height: GameConfig.spacingLg),

                  // Display section
                  _buildSection('Display', [
                    _buildToggle(
                      'Dark Theme',
                      Icons.dark_mode_rounded,
                      _darkTheme,
                      (v) {
                        setState(() => _darkTheme = v);
                        _saveSettings();
                      },
                    ),
                  ]),
                  const SizedBox(height: GameConfig.spacingLg),

                  // Data section
                  _buildSection('Account', [
                    _buildAction(
                      'Restore Purchases',
                      Icons.restore_rounded,
                      GameConfig.primary,
                      () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('No purchases to restore'),
                            backgroundColor: GameConfig.surface,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                GameConfig.radiusSm,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    _buildAction(
                      'Privacy Policy',
                      Icons.privacy_tip_rounded,
                      GameConfig.accent,
                      () async {
                        final uri = Uri.parse(GameConfig.privacyPolicyUrl);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(
                            uri,
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      },
                    ),
                    _buildAction(
                      'Reset Progress',
                      Icons.delete_outline_rounded,
                      GameConfig.error,
                      () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: GameConfig.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            title: const Text('Reset Progress?'),
                            content: const Text(
                              'This will erase all your level progress, coins, and hints. This cannot be undone.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  final storage = Provider.of<StorageService>(
                                    context,
                                    listen: false,
                                  );
                                  storage.resetProgress();
                                  Navigator.pop(ctx);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Progress reset'),
                                      backgroundColor: GameConfig.surface,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          GameConfig.radiusSm,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Reset',
                                  style: TextStyle(color: GameConfig.error),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: GameConfig.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ),
        const SizedBox(height: GameConfig.spacingSm),
        DecoratedBox(
          decoration: BoxDecoration(
            color: GameConfig.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: GameConfig.surfaceLight, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildToggle(
    String label,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      leading: Icon(icon, color: GameConfig.textMuted, size: 24),
      title: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: GameConfig.primary,
        activeTrackColor: GameConfig.primary.withValues(alpha: 0.3),
      ),
    );
  }

  Widget _buildAction(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: color, size: 24),
      title: Text(
        label,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: color.withValues(alpha: 0.5),
        size: 24,
      ),
      onTap: onTap,
    );
  }
}
