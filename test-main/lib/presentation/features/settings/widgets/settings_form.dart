import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../common_widgets/buttons/primary_button.dart';
import '../blocs/settings_bloc.dart';

class SettingsForm extends StatelessWidget {
  final VoidCallback onSubmit;

  const SettingsForm({Key? key, required this.onSubmit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<SettingsBloc>(context);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Settings",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              text: 'Delete All Assets',
              icon: Icons.delete_forever,
              color: Colors.red,
              isLoading: bloc.status == SettingsActionStatus.loading,
              onPressed: onSubmit,
            ),
          ],
        ),
      ),
    );
  }
}
