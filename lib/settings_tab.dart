import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_providers.dart';
import 'icon_box.dart';
import 'login_page.dart';

class SettingsTab extends ConsumerWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appControllerProvider);
    final controller = ref.read(appControllerProvider.notifier);

    return CupertinoPageScaffold(
      child: ListView(
        children: [
          CupertinoListSection.insetGrouped(
            children: [
              CupertinoListTile(
                leading: const IconBox(
                  icon: Icons.fingerprint,
                  color: CupertinoColors.systemOrange,
                ),
                title: const Text("Biometrics"),
                trailing: CupertinoSwitch(
                  value: appState.biometricsEnabled,
                  onChanged: (value) {
                    controller.toggleBiometrics(value);
                  },
                ),
              ),
              CupertinoListTile(
                leading: const IconBox(
                  icon: CupertinoIcons.moon_fill,
                  color: CupertinoColors.systemBlue,
                ),
                title: const Text("Dark Mode"),
                trailing: CupertinoSwitch(
                  value: appState.darkMode,
                  onChanged: (value) {
                    controller.toggleDarkMode(value);
                  },
                ),
              ),
              CupertinoListTile(
                leading: const IconBox(
                  icon: CupertinoIcons.thermometer,
                  color: CupertinoColors.systemPurple,
                ),
                title: const Text("Metric"),
                trailing: CupertinoSwitch(
                  value: appState.isMetric,
                  onChanged: (value) {
                    controller.toggleMetric(value);
                  },
                ),
              ),
              GestureDetector(
                onTap: () => _showLocationDialog(context, ref),
                child: CupertinoListTile(
                  leading: const IconBox(
                    icon: CupertinoIcons.location_fill,
                    color: CupertinoColors.systemGreen,
                  ),
                  title: const Text("Location"),
                  trailing: const Icon(CupertinoIcons.chevron_forward),
                  additionalInfo: Text(appState.city),
                ),
              ),
              GestureDetector(
                onTap: () => _showThemeDialog(context, ref),
                child: CupertinoListTile(
                  leading: IconBox(
                    icon: CupertinoIcons.paintbrush_fill,
                    color: appState.primaryColor,
                  ),
                  title: const Text("Theme Color"),
                  trailing: const Icon(CupertinoIcons.chevron_forward),
                  additionalInfo: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        CupertinoIcons.circle_fill,
                        color: appState.primaryColor,
                      ),
                      const SizedBox(width: 6),
                      Text(appState.themeColorName),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _showAboutDialog(context),
                child: const CupertinoListTile(
                  leading: IconBox(
                    icon: CupertinoIcons.group,
                    color: CupertinoColors.systemGrey,
                  ),
                  title: Text("About"),
                  trailing: Icon(CupertinoIcons.chevron_forward),
                ),
              ),
              GestureDetector(
                onTap: () => _showLogoutDialog(context),
                child: const CupertinoListTile(
                  leading: IconBox(
                    icon: Icons.logout,
                    color: CupertinoColors.systemYellow,
                  ),
                  title: Text("Logout"),
                  trailing: Icon(CupertinoIcons.chevron_forward),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text("Theme Color"),
        content: Wrap(
          spacing: 12,
          children: [
            _colorDot(ref, context, "Red", CupertinoColors.destructiveRed),
            _colorDot(ref, context, "Orange", CupertinoColors.systemOrange),
            _colorDot(ref, context, "Yellow", CupertinoColors.systemYellow),
            _colorDot(ref, context, "Green", CupertinoColors.systemGreen),
            _colorDot(ref, context, "Blue", CupertinoColors.activeBlue),
            _colorDot(ref, context, "Indigo", CupertinoColors.systemIndigo),
            _colorDot(ref, context, "Purple", CupertinoColors.systemPurple),
          ],
        ),
        actions: [
          CupertinoButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _colorDot(
      WidgetRef ref,
      BuildContext context,
      String name,
      Color color,
      ) {
    return GestureDetector(
      onTap: () async {
        await ref
            .read(appControllerProvider.notifier)
            .setThemeColor(name, color);

        if (context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Icon(
        CupertinoIcons.circle_fill,
        color: color,
        size: 30,
      ),
    );
  }

  void _showLocationDialog(BuildContext context, WidgetRef ref) {
    final currentCity = ref.read(appControllerProvider).city;
    final textController = TextEditingController(text: currentCity);

    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text("City"),
        content: CupertinoTextField(controller: textController),
        actions: [
          CupertinoButton(
            child: const Text("Save"),
            onPressed: () async {
              final success = await ref
                  .read(appControllerProvider.notifier)
                  .saveCity(textController.text);

              if (!context.mounted) return;

              Navigator.pop(context);

              if (!success) {
                showCupertinoDialog(
                  context: context,
                  builder: (_) => CupertinoAlertDialog(
                    title: const Text("Error"),
                    content: const Text(
                      "Invalid city or something went wrong. Try again.",
                    ),
                    actions: [
                      CupertinoButton(
                        child: const Text("OK"),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
          CupertinoButton(
            child: const Text(
              "Cancel",
              style: TextStyle(
                color: CupertinoColors.destructiveRed,
              ),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text("Members"),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Delos Santos, Jhanelle N."),
            Text("Enriquez, Tijano Tj P."),
            Text("Maniago, Jairus Legor C."),
          ],
        ),
        actions: [
          CupertinoButton(
            child: const Text("OK"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text("Logout"),
        content: const Text("Return to login page?"),
        actions: [
          CupertinoButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.of(context).pop(),
          ),
          CupertinoButton(
            child: const Text(
              "Logout",
              style: TextStyle(
                color: CupertinoColors.destructiveRed,
              ),
            ),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                CupertinoPageRoute(
                  builder: (_) => const LoginPage(),
                ),
                    (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}