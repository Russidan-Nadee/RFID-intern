import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../common_widgets/inputs/text_input.dart';
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
            TextInput(
              controller: bloc.idController,
              label: 'ID',
              prefixIcon: Icons.tag,
            ),
            const SizedBox(height: 12),

            TextInput(
              controller: bloc.categoryController,
              label: 'Category',
              prefixIcon: Icons.category,
            ),
            const SizedBox(height: 12),

            TextInput(
              controller: bloc.brandController,
              label: 'Brand',
              prefixIcon: Icons.business,
            ),
            const SizedBox(height: 12),

            // Department dropdown
            DropdownButtonFormField<String>(
              value: bloc.selectedDepartment,
              decoration: InputDecoration(
                labelText: 'Department',
                prefixIcon: const Icon(Icons.apartment),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              items:
                  <String>[
                    'it',
                    'hr',
                    'admin',
                    'finance',
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  bloc.setDepartment(newValue);
                }
              },
            ),
            const SizedBox(height: 12),

            TextInput(
              controller: bloc.uidController,
              label: 'UID',
              prefixIcon: Icons.qr_code,
            ),
            const SizedBox(height: 20),

            PrimaryButton(
              text: 'Update Asset',
              icon: Icons.save,
              color: Colors.green,
              isLoading: bloc.status == SettingsActionStatus.loading,
              onPressed: onSubmit,
            ),
          ],
        ),
      ),
    );
  }
}
