// คลาสสำหรับเก็บข้อมูลการใช้งานแอปเพื่อวิเคราะห์พฤติกรรมผู้ใช้
class AnalyticsService {
  // บันทึกเหตุการณ์ทั่วไปพร้อมข้อมูลเพิ่มเติม (ถ้ามี)
  // เช่น การกดปุ่ม การเปิดเมนู หรือการทำงานสำคัญในแอป
  void logEvent(String eventName, {Map<String, dynamic>? parameters}) {
    // ส่วนนี้จะเชื่อมต่อกับบริการวิเคราะห์ เช่น Firebase Analytics ในอนาคต
    // ตอนนี้แค่แสดงข้อความในคอนโซลเพื่อการทดสอบ
    print('Analytics event: $eventName, params: $parameters');
  }

  // บันทึกเมื่อผู้ใช้เปิดหน้าจอใดๆ ในแอป
  // ช่วยให้รู้ว่าผู้ใช้ใช้เวลาอยู่กับหน้าไหนมากที่สุด
  void logScreenView(String screenName) {
    logEvent('screen_view', parameters: {'screen_name': screenName});
  }

  // บันทึกเมื่อผู้ใช้สแกนสินทรัพย์ด้วย RFID
  // ช่วยติดตามว่าสินทรัพย์ไหนถูกสแกนบ่อย
  void logAssetScanned(String assetId) {
    logEvent('asset_scanned', parameters: {'asset_id': assetId});
  }

  // บันทึกคำค้นหาที่ผู้ใช้ใช้ในแอป
  // ช่วยให้เข้าใจว่าผู้ใช้กำลังมองหาอะไร
  void logSearch(String query) {
    logEvent('search', parameters: {'query': query});
  }
}
