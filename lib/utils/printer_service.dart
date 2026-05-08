import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrinterService {
  static const _prefKey = 'printer_mac';

  /// Pesan error terakhir untuk keperluan diagnostik
  static String lastError = '';

  // ── Bluetooth device management ──────────────────────────────────────────

  static Future<String?> getSavedAddress() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefKey);
  }

  static Future<void> saveAddress(String mac) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, mac);
  }

  static Future<List<BluetoothInfo>> getPairedDevices() async {
    return PrintBluetoothThermal.pairedBluetooths;
  }

  static Future<bool> isBluetoothEnabled() async {
    return PrintBluetoothThermal.bluetoothEnabled;
  }

  static Future<bool> connect(String mac) async {
    lastError = '';
    try {
      return await PrintBluetoothThermal.connect(
        macPrinterAddress: mac,
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          lastError = 'Timeout: printer tidak merespons dalam 15 detik';
          return false;
        },
      );
    } catch (e) {
      lastError = e.toString();
      return false;
    }
  }

  static Future<bool> get isConnected async {
    return PrintBluetoothThermal.connectionStatus;
  }

  static Future<void> disconnect() async {
    try {
      await PrintBluetoothThermal.disconnect;
    } catch (_) {}
  }

  // ── Diagnostik ────────────────────────────────────────────────────────────

  /// Cek semua kondisi dan kembalikan pesan status.
  /// Tidak mengecek koneksi aktif — auto-connect ditangani saat cetak.
  static Future<String> diagnose() async {
    final btOn = await PrintBluetoothThermal.bluetoothEnabled;
    if (!btOn) {
      return 'Bluetooth tidak aktif. Aktifkan Bluetooth terlebih dahulu.';
    }

    final mac = await getSavedAddress();
    if (mac == null || mac.isEmpty) {
      return 'Belum ada printer yang dipilih. Pilih printer dari daftar di halaman Printer.';
    }

    final devices = await PrintBluetoothThermal.pairedBluetooths.timeout(
      const Duration(seconds: 10),
      onTimeout: () => [],
    );
    if (devices.isEmpty) {
      return 'Daftar perangkat paired kosong. Pastikan izin Bluetooth (Nearby Devices) sudah diberikan dan Bluetooth aktif.';
    }

    final found = devices.any((d) => d.macAdress == mac);
    if (!found) {
      return 'Printer ($mac) tidak ditemukan di daftar paired. Pastikan sudah di-pair di Pengaturan Bluetooth HP.';
    }

    return 'OK';
  }

  // ── Print receipt ─────────────────────────────────────────────────────────

  /// Cetak struk langsung via Bluetooth ke printer thermal 80mm.
  static Future<({bool ok, String error})> printReceiptWithDiag({
    required String storeName,
    required String cashierName,
    required String transactionId,
    required DateTime dateTime,
    required List<Map<String, dynamic>> items,
    required double subtotal,
    required double tax,
    required double total,
    required double paid,
    required double change,
    String? note,
  }) async {
    try {
      final btOn = await PrintBluetoothThermal.bluetoothEnabled;
      if (!btOn) {
        return (ok: false, error: 'Bluetooth tidak aktif');
      }

      final mac = await getSavedAddress();
      if (mac == null || mac.isEmpty) {
        return (ok: false, error: 'Belum ada printer dipilih');
      }

      final alreadyConnected = await PrintBluetoothThermal.connectionStatus;
      if (!alreadyConnected) {
        final ok = await connect(mac); // pakai method dengan timeout 15s
        if (!ok) {
          return (
            ok: false,
            error: lastError.isNotEmpty
                ? lastError
                : 'Gagal konek ke printer ($mac). Pastikan printer menyala dan dalam jangkauan.',
          );
        }
        // Tunggu printer siap menerima data setelah koneksi
        await Future<void>.delayed(const Duration(milliseconds: 800));
      }

      List<int> bytes;
      try {
        bytes = await _buildReceiptBytes(
          storeName: storeName,
          cashierName: cashierName,
          transactionId: transactionId,
          dateTime: dateTime,
          items: items,
          subtotal: subtotal,
          tax: tax,
          total: total,
          paid: paid,
          change: change,
          note: note,
        );
      } catch (e) {
        return (
          ok: false,
          error: 'Gagal menyiapkan data cetak: ${e.toString()}',
        );
      }

      if (bytes.isEmpty) {
        return (ok: false, error: 'Data cetak kosong. Coba lagi.');
      }

      // Coba kirim sekaligus dulu (plugin butuh List<int>, bukan Uint8List)
      bool written = await PrintBluetoothThermal.writeBytes(
        bytes,
      ).timeout(const Duration(seconds: 20), onTimeout: () => false);

      // Jika gagal, coba kirim per-chunk 512 bytes
      if (!written) {
        written = true;
        const chunkSize = 512;
        for (int i = 0; i < bytes.length; i += chunkSize) {
          final end = (i + chunkSize < bytes.length)
              ? i + chunkSize
              : bytes.length;
          final chunk = bytes.sublist(i, end);
          final ok = await PrintBluetoothThermal.writeBytes(
            chunk,
          ).timeout(const Duration(seconds: 10), onTimeout: () => false);
          if (!ok) {
            written = false;
            break;
          }
          await Future<void>.delayed(const Duration(milliseconds: 50));
        }
      }

      if (!written) {
        return (
          ok: false,
          error:
              'Printer terhubung tapi gagal mengirim data. Coba:\n1. Matikan/nyalakan printer\n2. Pastikan kertas terpasang\n3. Putuskan & hubungkan ulang',
        );
      }
      return (ok: true, error: '');
    } catch (e) {
      lastError = e.toString();
      return (ok: false, error: e.toString());
    }
  }

  /// Versi lama untuk kompatibilitas
  static Future<bool> printReceipt({
    required String storeName,
    required String cashierName,
    required String transactionId,
    required DateTime dateTime,
    required List<Map<String, dynamic>> items,
    required double subtotal,
    required double tax,
    required double total,
    required double paid,
    required double change,
    String? note,
  }) async {
    final result = await printReceiptWithDiag(
      storeName: storeName,
      cashierName: cashierName,
      transactionId: transactionId,
      dateTime: dateTime,
      items: items,
      subtotal: subtotal,
      tax: tax,
      total: total,
      paid: paid,
      change: change,
      note: note,
    );
    if (!result.ok) lastError = result.error;
    return result.ok;
  }

  // ── ESC/POS byte builder ──────────────────────────────────────────────────

  static Future<List<int>> _buildReceiptBytes({
    required String storeName,
    required String cashierName,
    required String transactionId,
    required DateTime dateTime,
    required List<Map<String, dynamic>> items,
    required double subtotal,
    required double tax,
    required double total,
    required double paid,
    required double change,
    String? note,
  }) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);
    List<int> bytes = [];

    bytes += generator.setGlobalCodeTable('CP1252');

    // Header toko
    bytes += generator.text(
      storeName,
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );
    bytes += generator.text(
      'Struk Pembayaran',
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.hr();

    // Info transaksi
    final tgl =
        '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}'
        ' ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    bytes += generator.row([
      PosColumn(text: 'No', width: 4),
      PosColumn(text: ': $transactionId', width: 8),
    ]);
    bytes += generator.row([
      PosColumn(text: 'Kasir', width: 4),
      PosColumn(text: ': $cashierName', width: 8),
    ]);
    bytes += generator.row([
      PosColumn(text: 'Tgl', width: 4),
      PosColumn(text: ': $tgl', width: 8),
    ]);
    bytes += generator.hr();

    // Daftar item
    for (final item in items) {
      final name = (item['name'] as String).length > 20
          ? (item['name'] as String).substring(0, 20)
          : item['name'] as String;
      final qty = item['qty'] as int;
      final itemSubtotal = item['subtotal'] as double;
      bytes += generator.text(name);
      bytes += generator.row([
        PosColumn(
          text: '  ${qty}x ${_formatRp(item['price'] as double)}',
          width: 8,
        ),
        PosColumn(
          text: _formatRp(itemSubtotal),
          width: 4,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }
    bytes += generator.hr();

    // Total section
    if (tax > 0) {
      bytes += generator.row([
        PosColumn(text: 'Subtotal', width: 6),
        PosColumn(
          text: _formatRp(subtotal),
          width: 6,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
      bytes += generator.row([
        PosColumn(text: 'Pajak', width: 6),
        PosColumn(
          text: _formatRp(tax),
          width: 6,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }
    bytes += generator.hr(ch: '=');
    bytes += generator.row([
      PosColumn(text: 'TOTAL', width: 6, styles: const PosStyles(bold: true)),
      PosColumn(
        text: _formatRp(total),
        width: 6,
        styles: const PosStyles(align: PosAlign.right, bold: true),
      ),
    ]);
    if (paid > 0) {
      bytes += generator.row([
        PosColumn(text: 'Bayar', width: 6),
        PosColumn(
          text: _formatRp(paid),
          width: 6,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
      bytes += generator.row([
        PosColumn(text: 'Kembali', width: 6),
        PosColumn(
          text: _formatRp(change),
          width: 6,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }
    bytes += generator.hr();

    // Footer
    if (note != null && note.isNotEmpty) {
      bytes += generator.text(
        note,
        styles: const PosStyles(align: PosAlign.center),
      );
    }
    bytes += generator.text(
      'Terima kasih!',
      styles: const PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.feed(3);
    bytes += generator.cut();

    return bytes;
  }

  static String _formatRp(double amount) {
    final formatted = amount
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
    return 'Rp$formatted';
  }
}
