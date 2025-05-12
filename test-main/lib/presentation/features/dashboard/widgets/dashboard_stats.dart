import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../blocs/dashboard_bloc.dart';

class AssetCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const AssetCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class DashboardStats extends StatelessWidget {
  const DashboardStats({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<DashboardBloc>(context);

    return Column(
      children: [
        AssetCard(
          icon: Icons.inventory_2,
          title: 'Assets Total',
          value: '${bloc.totalAssets} Units',
        ),
        AssetCard(
          icon: Icons.check_circle,
          title: 'Checked In',
          value: '${bloc.checkedInAssets} Units',
        ),
        AssetCard(
          icon: Icons.assignment_turned_in,
          title: 'Available',
          value: '${bloc.availableAssets} Units',
        ),
        AssetCard(
          icon: Icons.qr_code_scanner,
          title: 'RFID Scan Today',
          value: '${bloc.rfidScansToday} Times',
        ),
      ],
    );
  }
}
