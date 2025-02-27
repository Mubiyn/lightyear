import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'settings_controller.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  static const routeName = '/settings';

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsController>(
      builder: (__, value, _) => Padding(
        padding: const EdgeInsets.all(16),
        child: DropdownButton<ThemeMode>(
          value: value.themeMode,
          onChanged: (val) async {
            await value.updateThemeMode(val);
          },
          underline: const SizedBox.shrink(),
          icon: Icon(
              value.themeMode == ThemeMode.dark
                  ? Icons.dark_mode
                  : Icons.light_mode,
              color: Theme.of(context).dividerColor),
          dropdownColor: Theme.of(context).cardColor,
          items: [
            DropdownMenuItem(
              value: ThemeMode.system,
              child: Text('System Theme',
                  style: TextStyle(color: Theme.of(context).dividerColor)),
            ),
            DropdownMenuItem(
              value: ThemeMode.light,
              child: Text('Light Theme',
                  style: TextStyle(color: Theme.of(context).dividerColor)),
            ),
            DropdownMenuItem(
              value: ThemeMode.dark,
              child: Text('Dark Theme',
                  style: TextStyle(color: Theme.of(context).dividerColor)),
            )
          ],
        ),
      ),
    );
  }
}
