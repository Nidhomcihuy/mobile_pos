import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import '../utils/printer_service.dart';

class PrinterScreen extends StatefulWidget {
  const PrinterScreen({super.key});

  @override
  State<PrinterScreen> createState() => _PrinterScreenState();
}

class _PrinterScreenState extends State<PrinterScreen> {
  List<BluetoothInfo> _devices = [];
  String? _savedMac;
  String? _connectedMac;
  String? _connectedName;
  bool _isLoading = false;
  bool _isConnecting = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _savedMac = await PrinterService.getSavedAddress();
    final connected = await PrinterService.isConnected;
    if (connected) _connectedMac = _savedMac;
    setState(() {});
    await _requestPermissions();

    // Tunggu sebentar agar permission benar-benar granted
    await Future<void>.delayed(const Duration(milliseconds: 500));

    final btOn = await PrinterService.isBluetoothEnabled();
    if (mounted && !btOn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bluetooth tidak aktif! Aktifkan Bluetooth dulu.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
    }
    await _loadDevices();
  }

  Future<void> _requestPermissions() async {
    final statuses = await [
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.locationWhenInUse,
    ].request();

    // Cek apakah ada izin penting yang denied/permanentlyDenied
    final btConnect = statuses[Permission.bluetoothConnect];
    final btScan = statuses[Permission.bluetoothScan];

    final denied =
        (btConnect?.isDenied ?? false) ||
        (btScan?.isDenied ?? false) ||
        (btConnect?.isPermanentlyDenied ?? false) ||
        (btScan?.isPermanentlyDenied ?? false);

    if (denied && mounted) {
      final isPermanent =
          (btConnect?.isPermanentlyDenied ?? false) ||
          (btScan?.isPermanentlyDenied ?? false);

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.bluetooth_disabled, color: Colors.red),
              SizedBox(width: 8),
              Text('Izin Bluetooth Diperlukan'),
            ],
          ),
          content: Text(
            isPermanent
                ? 'Izin Nearby Devices ditolak permanen. Buka Pengaturan Aplikasi untuk mengaktifkannya secara manual.'
                : 'Aplikasi memerlukan izin Bluetooth (Nearby Devices) untuk terhubung ke printer.',
            style: const TextStyle(fontFamily: 'Inter'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Nanti'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                openAppSettings();
              },
              child: const Text('Buka Pengaturan'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _loadDevices() async {
    setState(() => _isLoading = true);
    try {
      final devices = await PrinterService.getPairedDevices();
      setState(() => _devices = devices);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Gagal memuat daftar perangkat. Pastikan Bluetooth aktif.',
            ),
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _connectTo(BluetoothInfo device) async {
    setState(() => _isConnecting = true);
    try {
      // Putuskan koneksi lama dulu jika ada
      final alreadyConnected = await PrinterService.isConnected;
      if (alreadyConnected) await PrinterService.disconnect();

      final ok = await PrinterService.connect(device.macAdress);
      if (ok) {
        await PrinterService.saveAddress(device.macAdress);
        setState(() {
          _savedMac = device.macAdress;
          _connectedMac = device.macAdress;
          _connectedName = device.name;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Terhubung ke ${device.name}'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal terhubung ke ${device.name}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } finally {
      setState(() => _isConnecting = false);
    }
  }

  Future<void> _testPrint() async {
    setState(() => _isLoading = true);
    try {
      // Jalankan diagnosa dulu
      final diag = await PrinterService.diagnose();
      if (diag != 'OK') {
        if (mounted) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.orange),
                  SizedBox(width: 8),
                  Text('Masalah Printer'),
                ],
              ),
              content: Text(diag, style: const TextStyle(fontFamily: 'Inter')),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
        return;
      }

      final result = await PrinterService.printReceiptWithDiag(
        storeName: 'ILS MART',
        cashierName: 'Test Kasir',
        transactionId: 'TRX-TEST-001',
        dateTime: DateTime.now(),
        items: [
          {
            'name': 'Indomie Goreng',
            'qty': 2,
            'price': 3500.0,
            'subtotal': 7000.0,
          },
          {
            'name': 'Teh Botol 350ml',
            'qty': 1,
            'price': 5000.0,
            'subtotal': 5000.0,
          },
        ],
        subtotal: 12000.0,
        tax: 0.0,
        total: 12000.0,
        paid: 20000.0,
        change: 8000.0,
      );
      if (mounted) {
        if (result.ok) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Struk berhasil dicetak!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.error, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Gagal Cetak'),
                ],
              ),
              content: Text(
                result.error,
                style: const TextStyle(fontFamily: 'Inter'),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFEBEE),
      appBar: AppBar(
        title: const Text(
          'Pengaturan Printer',
          style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700),
        ),
        backgroundColor: const Color(0xFFC62828),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Muat ulang perangkat',
            onPressed: _loadDevices,
          ),
        ],
      ),
      body: Column(
        children: [
          // Status bar
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _connectedMac != null
                  ? const Color(0xFFE8F5E9)
                  : const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _connectedMac != null ? Colors.green : Colors.orange,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _connectedMac != null ? Icons.print : Icons.print_disabled,
                  color: _connectedMac != null ? Colors.green : Colors.orange,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _connectedMac != null
                            ? 'Printer Terhubung'
                            : 'Belum Ada Printer Terhubung',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                          color: _connectedMac != null
                              ? Colors.green[800]
                              : Colors.orange[800],
                        ),
                      ),
                      if (_connectedMac != null)
                        Text(
                          '${_connectedName ?? ''} $_connectedMac',
                          style: const TextStyle(
                            fontSize: 12,
                            fontFamily: 'Inter',
                            color: Colors.black54,
                          ),
                        )
                      else
                        const Text(
                          'Pilih printer dari daftar di bawah',
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'Inter',
                            color: Colors.black54,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Judul daftar
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.bluetooth, color: Color(0xFFC62828)),
                SizedBox(width: 8),
                Text(
                  'Perangkat Bluetooth Terpasang',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Pastikan printer sudah dipasangkan (paired) di pengaturan Bluetooth HP Anda terlebih dahulu.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black54,
                fontFamily: 'Inter',
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Daftar device
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFFC62828)),
                  )
                : _devices.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.bluetooth_disabled,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Tidak ada perangkat yang ditemukan',
                          style: TextStyle(fontFamily: 'Inter'),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: _loadDevices,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Coba Lagi'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFC62828),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _devices.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final device = _devices[index];
                      final isSaved = device.macAdress == _savedMac;
                      final isConnected = device.macAdress == _connectedMac;
                      return ListTile(
                        leading: Icon(
                          Icons.print,
                          color: isConnected
                              ? Colors.green
                              : const Color(0xFFC62828),
                        ),
                        title: Text(
                          device.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Inter',
                          ),
                        ),
                        subtitle: Text(
                          device.macAdress,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                          ),
                        ),
                        trailing: isConnected
                            ? const Chip(
                                label: Text(
                                  'Terhubung',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                                backgroundColor: Colors.green,
                              )
                            : isSaved
                            ? const Chip(
                                label: Text(
                                  'Tersimpan',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                                backgroundColor: Colors.orange,
                              )
                            : null,
                        onTap: _isConnecting ? null : () => _connectTo(device),
                      );
                    },
                  ),
          ),

          // Tombol test print
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _testPrint,
                icon: const Icon(Icons.print),
                label: const Text(
                  'Cetak Struk Uji Coba',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB71C1C),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
          // Tombol diagnosa
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isLoading
                    ? null
                    : () async {
                        setState(() => _isLoading = true);
                        final msg = await PrinterService.diagnose();
                        setState(() => _isLoading = false);
                        if (mounted) {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Row(
                                children: [
                                  Icon(
                                    msg == 'OK'
                                        ? Icons.check_circle
                                        : Icons.info_outline,
                                    color: msg == 'OK'
                                        ? Colors.green
                                        : Colors.orange,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text('Diagnosa Printer'),
                                ],
                              ),
                              content: Text(
                                msg == 'OK'
                                    ? 'Semua kondisi printer OK. Siap cetak!'
                                    : msg,
                                style: const TextStyle(fontFamily: 'Inter'),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                icon: const Icon(Icons.medical_services_outlined),
                label: const Text(
                  'Diagnosa Koneksi',
                  style: TextStyle(fontFamily: 'Inter'),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFC62828),
                  side: const BorderSide(color: Color(0xFFC62828)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
