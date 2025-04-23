import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class Dashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Dashboard',
            style: TextStyle(
              fontSize: 40.0, // ขยายขนาดตัวอักษรของหัวข้อให้ใหญ่ขึ้นอีก
              fontWeight: FontWeight.bold, // เพิ่มความหนาให้ตัวอักษร
            ),
          ),
        ),
        backgroundColor: Colors.white, // สีขาวสำหรับ AppBar
        foregroundColor: Colors.blue, // สีฟ้าสำหรับข้อความใน AppBar
      ),
      body: Center(
        child: Container(
          color: Colors.white, // สีขาวสำหรับพื้นหลัง
          child: Column(
            mainAxisSize: MainAxisSize.min, // ขนาดของ Column จะปรับตามเนื้อหา
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 24.0,
                  horizontal: 16.0,
                ), // ลดระยะห่างแนวตั้งและแนวนอน
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      vertical: 16.0,
                    ), // ลดขนาดปุ่มในแนวตั้ง
                    textStyle: TextStyle(fontSize: 20.0), // ลดขนาดตัวอักษร
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ScanRFIDPage()),
                    );
                  },
                  child: Text('Connect RFID Reader'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 24.0,
                  horizontal: 16.0,
                ), // ลดระยะห่างแนวตั้งและแนวนอน
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      vertical: 16.0,
                    ), // ลดขนาดปุ่มในแนวตั้ง
                    textStyle: TextStyle(fontSize: 20.0), // ลดขนาดตัวอักษร
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AssetsPage()),
                    );
                  },
                  child: Text('View Assets'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 24.0,
                  horizontal: 16.0,
                ), // ลดระยะห่างแนวตั้งและแนวนอน
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      vertical: 16.0,
                    ), // ลดขนาดปุ่มในแนวตั้ง
                    textStyle: TextStyle(fontSize: 20.0), // ลดขนาดตัวอักษร
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SearchAndDetailPage(),
                      ),
                    );
                  },
                  child: Text('Search Asset'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 24.0,
                  horizontal: 16.0,
                ), // ลดระยะห่างแนวตั้งและแนวนอน
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      vertical: 16.0,
                    ), // ลดขนาดปุ่มในแนวตั้ง
                    textStyle: TextStyle(fontSize: 20.0), // ลดขนาดตัวอักษร
                  ),
                  onPressed: () {
                    // Add functionality to export audit data
                  },
                  child: Text('Export Audit Data'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AssetsPage extends StatelessWidget {
  Future<List<List<String>>> _loadCsvData() async {
    final csvData = await rootBundle.loadString('assets/company_assets.csv');
    final lines = LineSplitter.split(csvData).toList();
    final data = lines.map((line) => line.split(',')).toList();

    // Remove the header row if it exists
    if (data.isNotEmpty && data[0][0].toLowerCase() == 'asset id') {
      data.removeAt(0);
    }

    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Assets',
          style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center, // จัดข้อความให้อยู่ตรงกลาง
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue,
      ),
      body: FutureBuilder<List<List<String>>>(
        future: _loadCsvData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading CSV data'));
          } else {
            final data = snapshot.data ?? [];
            if (data.isEmpty) {
              return Center(child: Text('No data available'));
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Asset ID',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Asset Name',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Status',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Divider(),
                  Expanded(
                    child: ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final row = data[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(row[0]), // Asset ID
                              ),
                              Expanded(
                                child: Text(row[1]), // Asset Name
                              ),
                              Expanded(
                                child: Text(row[2]), // Status
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

class ScanRFIDPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Scan RFID',
          style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'RFID Reader 1',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              '04A7086C38E67',
              style: TextStyle(fontSize: 20.0, color: Colors.grey[700]),
            ),
            SizedBox(height: 16.0),
            Text(
              'Laptop A',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              'Location: IT Department',
              style: TextStyle(fontSize: 18.0, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchAndDetailPage extends StatefulWidget {
  @override
  _SearchAndDetailPageState createState() => _SearchAndDetailPageState();
}

class _SearchAndDetailPageState extends State<SearchAndDetailPage> {
  TextEditingController _searchController = TextEditingController();
  List<List<String>> _allAssets = [];
  List<List<String>> _filteredAssets = [];
  List<String>? _selectedAsset;

  @override
  void initState() {
    super.initState();
    _loadAssets();
  }

  Future<void> _loadAssets() async {
    final csvData = await rootBundle.loadString('assets/company_assets.csv');
    final lines = LineSplitter.split(csvData).toList();
    final data = lines.map((line) => line.split(',')).toList();

    // Remove the header row if it exists
    if (data.isNotEmpty && data[0][0].toLowerCase() == 'asset id') {
      data.removeAt(0);
    }

    setState(() {
      _allAssets = data;
      _filteredAssets = data;
    });
  }

  void _filterAssets(String query) {
    final filtered =
        _allAssets
            .where(
              (asset) =>
                  asset[0].contains(query) ||
                  asset[1].toLowerCase().contains(query.toLowerCase()),
            )
            .toList();

    setState(() {
      _filteredAssets = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Search Assets',
          style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by ID or Name',
                border: OutlineInputBorder(),
              ),
              onChanged: _filterAssets,
            ),
            SizedBox(height: 16.0),
            Expanded(
              child:
                  _selectedAsset == null
                      ? ListView.builder(
                        itemCount: _filteredAssets.length,
                        itemBuilder: (context, index) {
                          final asset = _filteredAssets[index];
                          return ListTile(
                            title: Text(asset[1]), // Asset Name
                            subtitle: Text(
                              'ID: ${asset[0]} | Status: ${asset[2]}',
                            ),
                            onTap: () {
                              setState(() {
                                _selectedAsset = asset;
                              });
                            },
                          );
                        },
                      )
                      : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Asset ID: ${_selectedAsset![0]}',
                            style: TextStyle(fontSize: 18.0),
                          ),
                          Text(
                            'Asset Name: ${_selectedAsset![1]}',
                            style: TextStyle(fontSize: 18.0),
                          ),
                          Text(
                            'Status: ${_selectedAsset![2]}',
                            style: TextStyle(fontSize: 18.0),
                          ),
                          Text(
                            'RFID UID: ${_selectedAsset![3]}',
                            style: TextStyle(fontSize: 18.0),
                          ),
                          Text(
                            'Last Audit: ${_selectedAsset![4]}',
                            style: TextStyle(fontSize: 18.0),
                          ),
                          SizedBox(height: 16.0),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedAsset = null;
                              });
                            },
                            child: Text('Back to Search'),
                          ),
                        ],
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: Dashboard(), debugShowCheckedModeBanner: false));
}
