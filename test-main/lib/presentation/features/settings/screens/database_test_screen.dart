import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../domain/repositories/asset_repository.dart';
import '../../../common_widgets/layouts/screen_container.dart';
import '../../../common_widgets/buttons/primary_button.dart';

class DatabaseTestScreen extends StatefulWidget {
  const DatabaseTestScreen({Key? key}) : super(key: key);

  @override
  _DatabaseTestScreenState createState() => _DatabaseTestScreenState();
}

class _DatabaseTestScreenState extends State<DatabaseTestScreen> {
  bool _isLoading = false;
  String _resultMessage = '';
  bool _isSuccess = false;
  List<dynamic> _assets = [];

  @override
  Widget build(BuildContext context) {
    return ScreenContainer(
      appBar: AppBar(title: const Text('Database Connection Test')),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PrimaryButton(
              text: 'Test MySQL Connection',
              icon: Icons.database,
              isLoading: _isLoading,
              onPressed: _testMySqlConnection,
            ),

            const SizedBox(height: 20),

            if (_resultMessage.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _isSuccess ? Colors.green.shade50 : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        _isSuccess
                            ? Colors.green.shade300
                            : Colors.red.shade300,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isSuccess ? Icons.check_circle : Icons.error,
                      color: _isSuccess ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _resultMessage,
                        style: TextStyle(
                          color:
                              _isSuccess
                                  ? Colors.green.shade800
                                  : Colors.red.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            if (_assets.isNotEmpty) ...[
              const Text(
                'Assets from MySQL Database:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: _assets.length,
                  itemBuilder: (context, index) {
                    final asset = _assets[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(asset.id),
                        subtitle: Text('${asset.category} - ${asset.status}'),
                        trailing: Text(asset.uid),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _testMySqlConnection() async {
    final repository = Provider.of<AssetRepository>(context, listen: false);

    setState(() {
      _isLoading = true;
      _resultMessage = '';
      _isSuccess = false;
      _assets = [];
    });

    try {
      final assets = await repository.getAssets();

      setState(() {
        _isLoading = false;
        _isSuccess = true;
        _resultMessage =
            'Successfully connected to MySQL! Found ${assets.length} assets.';
        _assets = assets;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isSuccess = false;
        _resultMessage = 'Error connecting to MySQL: ${e.toString()}';
      });
    }
  }
}
