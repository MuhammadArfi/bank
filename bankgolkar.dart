import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BANKGOLKARScreen(),
    );
  }
}

class BANKGOLKARScreen extends StatefulWidget {
  @override
  _BANKGOLKARScreenState createState() => _BANKGOLKARScreenState();
}

class _BANKGOLKARScreenState extends State<BANKGOLKARScreen> {
  int saldo = 500000; // Saldo awal Rp 500.000
  List<String> riwayatTransaksi = [];

  void _updateSaldo(int amount) {
    setState(() {
      saldo += amount;
      riwayatTransaksi.add('Tambah Saldo: Rp ${_formatCurrency(amount)}');
    });
  }

  void _transferSaldo(int amount, String rekening) {
    if (saldo >= amount) {
      setState(() {
        saldo -= amount;
        riwayatTransaksi.add('Transfer Rp ${_formatCurrency(amount)} ke $rekening');
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saldo tidak mencukupi!')),
      );
    }
  }

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text('BANKGOLKAR', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Icon(Icons.mail_outline, color: Colors.black),
          SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total Saldo Section
            Container(
              color: Colors.yellow,
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Saldo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text(
                    'Rp ${_formatCurrency(saldo)}',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.qr_code, size: 30),
                      IconButton(
                        icon: Icon(Icons.add_circle_outline, size: 30),
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => TambahSaldoScreen()),
                          );
                          if (result != null) _updateSaldo(result);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.sync_alt, size: 30),
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => TransferScreen()),
                          );
                          if (result != null) _transferSaldo(result['amount'], result['rekening']);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.history, size: 30),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => RiwayatScreen(riwayatTransaksi)),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            // Maintenance Notification
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.notifications, color: Colors.black),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text('Maintenance Terjadwal Untuk BANKGOLKAR'),
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

// Halaman Tambah Saldo
class TambahSaldoScreen extends StatefulWidget {
  @override
  _TambahSaldoScreenState createState() => _TambahSaldoScreenState();
}

class _TambahSaldoScreenState extends State<TambahSaldoScreen> {
  final TextEditingController _amountController = TextEditingController();

  void _submitSaldo() {
    if (_amountController.text.isNotEmpty) {
      int amount = int.tryParse(_amountController.text) ?? 0;
      Navigator.pop(context, amount);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tambah Saldo')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Masukkan jumlah saldo'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitSaldo,
              child: Text('Tambah Saldo'),
            ),
          ],
        ),
      ),
    );
  }
}

// Halaman Transfer Saldo
class TransferScreen extends StatefulWidget {
  @override
  _TransferScreenState createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  void _submitTransfer() {
    if (_accountController.text.isNotEmpty && _amountController.text.isNotEmpty) {
      int amount = int.tryParse(_amountController.text) ?? 0;
      Navigator.pop(context, {'amount': amount, 'rekening': _accountController.text});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Transfer Saldo')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _accountController,
              decoration: InputDecoration(labelText: 'Masukkan nomor rekening tujuan'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Masukkan jumlah saldo'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitTransfer,
              child: Text('Kirim Transfer'),
            ),
          ],
        ),
      ),
    );
  }
}

// Halaman Riwayat Transaksi
class RiwayatScreen extends StatelessWidget {
  final List<String> riwayatTransaksi;
  RiwayatScreen(this.riwayatTransaksi);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Riwayat Transaksi')),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: riwayatTransaksi.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(riwayatTransaksi[index]),
              leading: Icon(Icons.monetization_on, color: Colors.green),
            ),
          );
        },
      ),
    );
  }
}
