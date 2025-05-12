import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../common_widgets/buttons/primary_button.dart';
import '../../../common_widgets/layouts/screen_container.dart';
import '../blocs/settings_bloc.dart';
import '../widgets/settings_form.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenContainer(
      appBar: AppBar(title: const Text('Settings')),
      child: Consumer<SettingsBloc>(
        builder: (context, bloc, child) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section: Database Management
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Database Management',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),

                // เพิ่มปุ่มนี้ในส่วนเนื้อหาของหน้า Settings
                Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Database Connection',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Test connection to MySQL database',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        PrimaryButton(
                          text: 'Test MySQL Connection',
                          icon: Icons.storage,
                          onPressed: () {
                            Navigator.pushNamed(context, '/databaseTest');
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 24),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Delete all assets
                        const Text(
                          'Delete All Assets',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'This action will permanently delete all assets from the database.',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        PrimaryButton(
                          text: 'Delete All Assets',
                          color: Colors.red,
                          icon: Icons.delete_forever,
                          isLoading:
                              bloc.status == SettingsActionStatus.loading,
                          onPressed: () {
                            _showDeleteConfirmationDialog(
                              context,
                              'Delete All Assets',
                              'Are you sure you want to delete all assets? This action cannot be undone.',
                              () => bloc.deleteAllAssets(context),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Section: Delete specific asset
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Delete Specific Asset',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),

                SettingsForm(
                  onSubmit: () {
                    bloc.updateAssetStatus(
                      context,
                      bloc.uidController.text,
                      'Checked In',
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showDeleteConfirmationDialog(
    BuildContext context,
    String title,
    String message,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  onConfirm();
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }
}
