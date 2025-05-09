import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../common_widgets/layouts/app_bottom_navigation.dart';
import '../../../common_widgets/layouts/screen_container.dart';
import '../blocs/asset_bloc.dart';
import '../widgets/asset_table_row.dart';

class ViewAssetsScreen extends StatefulWidget {
  const ViewAssetsScreen({Key? key}) : super(key: key);

  @override
  _ViewAssetsScreenState createState() => _ViewAssetsScreenState();
}

class _ViewAssetsScreenState extends State<ViewAssetsScreen> {
  int _selectedIndex = 3; // Index for the View tab
  final GlobalKey _statusColumnKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AssetBloc>().loadAssets();
    });
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    Navigator.pushReplacementNamed(
      context,
      ['/', '/searchAssets', '/scanRfid', '/viewAssets', '/export'][index],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenContainer(
      appBar: AppBar(title: const Text('View Assets')),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      child: Consumer<AssetBloc>(
        builder: (context, bloc, child) {
          if (bloc.status == AssetStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          } else if (bloc.status == AssetStatus.error) {
            return Center(child: Text('Error: ${bloc.errorMessage}'));
          } else if (bloc.assets.isEmpty) {
            return const Center(
              child: Text(
                'No assets available',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            );
          } else {
            // สร้างรายการสถานะที่มีในข้อมูล
            final statuses = bloc.getAllStatuses();

            return Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      Table(
                        columnWidths: const {
                          0: FlexColumnWidth(1.2), // ID
                          1: FlexColumnWidth(1), // Category
                          2: FlexColumnWidth(1.2), // Status
                        },
                        border: TableBorder.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                        children: [
                          TableRow(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                            ),
                            children: [
                              const TableCell(
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Center(child: Text('ID')),
                                ),
                              ),
                              const TableCell(
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Center(child: Text('Category')),
                                ),
                              ),
                              TableCell(
                                child: InkWell(
                                  key: _statusColumnKey,
                                  onTap: () {
                                    // แสดง dropdown สำหรับกรองตามสถานะ
                                    _showStatusFilterMenu(statuses, bloc);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Text('Status'),
                                        const SizedBox(width: 4),
                                        Icon(
                                          Icons.arrow_drop_down,
                                          size: 16,
                                          color:
                                              bloc.selectedStatus != null
                                                  ? Theme.of(
                                                    context,
                                                  ).primaryColor
                                                  : Colors.grey,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          ...List.generate(
                            bloc.assets.length,
                            (index) =>
                                AssetTableRow(
                                  asset: bloc.assets[index],
                                  index: index,
                                ).getTableRow(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  void _showStatusFilterMenu(List<String> statuses, AssetBloc bloc) {
    // ดึงตำแหน่งของคอลัมน์ Status
    final RenderBox? statusColumn =
        _statusColumnKey.currentContext?.findRenderObject() as RenderBox?;
    final RenderBox? overlay =
        Navigator.of(context).overlay?.context.findRenderObject() as RenderBox?;

    if (statusColumn != null && overlay != null) {
      // คำนวณตำแหน่งให้แสดง dropdown ใต้คอลัมน์ Status
      final statusColumnPos = statusColumn.localToGlobal(
        Offset.zero,
        ancestor: overlay,
      );
      final statusColumnSize = statusColumn.size;

      final RelativeRect position = RelativeRect.fromLTRB(
        statusColumnPos.dx,
        statusColumnPos.dy + statusColumnSize.height,
        statusColumnPos.dx + statusColumnSize.width,
        statusColumnPos.dy + statusColumnSize.height,
      );

      showMenu(
        context: context,
        position: position,
        items: [
          PopupMenuItem(
            value: null,
            child: Row(
              children: [
                Icon(
                  Icons.clear,
                  color:
                      bloc.selectedStatus == null
                          ? Theme.of(context).primaryColor
                          : Colors.grey,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text('All Statuses'),
              ],
            ),
          ),
          ...statuses.map(
            (status) => PopupMenuItem(
              value: status,
              child: Row(
                children: [
                  Icon(
                    Icons.check,
                    color:
                        bloc.selectedStatus == status
                            ? Theme.of(context).primaryColor
                            : Colors.transparent,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(status),
                ],
              ),
            ),
          ),
        ],
      ).then((value) {
        if (value != null || value == null) {
          bloc.setStatusFilter(value);
        }
      });
    }
  }
}
