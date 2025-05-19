import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../common_widgets/layouts/screen_container.dart';
import '../blocs/settings_bloc.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenContainer(
      appBar: AppBar(title: const Text('Settings')),
      child: Consumer<SettingsBloc>(
        builder: (context, bloc, child) {
          return const Center(
            child: Text('Settings Screen', style: TextStyle(fontSize: 20)),
          );
        },
      ),
    );
  }
}
