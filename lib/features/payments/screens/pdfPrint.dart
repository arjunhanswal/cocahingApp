import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';

// ─────────────────────────────────────────────
// DATA MODEL — swap these values dynamically
// ─────────────────────────────────────────────
class ReceiptData {
  final String instituteName;
  final String instituteAddress;
  final String instituteEmail;
  final String instituteContact;

  final String studentName;
  final String studentAddress;
  final String studentEmail;
  final String studentContact;

  final DateTime receiptDate;
  final String receiptNo;
  final String courses;

  final double amountReceived;
  final String amountInWords;
  final String paymentMode;

  final String chequeNo;
  final String chequeDated;
  final String bankName;
  final String ifscCode;
  final String onlineTranxNo;

  final String dueDate;
  final double dueFees;

  final String termsAndConditions;

  const ReceiptData({
    this.instituteName = 'RUCHI MAKEUP ZONE',
    this.instituteAddress =
        '302 19 sukh shanti nagar bicholi road\nBangali square indore 452016',
    this.instituteEmail = 'ruchimakeupzone@gmail.com',
    this.instituteContact = '6260336048',
    this.studentName = 'RAJNI KUSHWAHA',
    this.studentAddress = 'A SECTOR SUKHLIYA BAPAT SQUARE INDORE',
    this.studentEmail = '',
    this.studentContact = '8109809697',
    required this.receiptDate,
    this.receiptNo = '2025-26187',
    this.courses = 'COSMETOLOGY (All), Hair Style RMUZ',
    this.amountReceived = 15999.00,
    this.amountInWords =
        'Fifteen Thousand Nine Hundred Ninety Nine Rupees Only.',
    this.paymentMode = 'Cash',
    this.chequeNo = 'NA',
    this.chequeDated = 'NA',
    this.bankName = 'NA',
    this.ifscCode = 'NA',
    this.onlineTranxNo = 'NA',
    this.dueDate = 'NA',
    this.dueFees = 0.00,
    this.termsAndConditions = '',
  });
}

// ─────────────────────────────────────────────
// ENTRY POINT
// ─────────────────────────────────────────────
void main() {
  runApp(const FeesReceiptApp());
}

class FeesReceiptApp extends StatelessWidget {
  const FeesReceiptApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fees Receipt',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8B1A4A)),
        useMaterial3: true,
        fontFamily: 'Georgia',
      ),
      home: FeesReceiptScreen(
        data: ReceiptData(receiptDate: DateTime(2026, 3, 25)),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// MAIN SCREEN
// ─────────────────────────────────────────────
class FeesReceiptScreen extends StatelessWidget {
  final ReceiptData data;

  const FeesReceiptScreen({super.key, required this.data});

  String get _formattedDate =>
      DateFormat('dd/MM/yyyy').format(data.receiptDate);

  String get _formattedAmount =>
      '₹ ${data.amountReceived.toStringAsFixed(2)}';

  String get _formattedDue =>
      '₹ ${data.dueFees.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0EC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8B1A4A),
        foregroundColor: Colors.white,
        title: const Text(
          'Student\'s Copy — Fees Receipt',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: 'Print Receipt',
            onPressed: () => _printReceipt(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 780),
            child: _buildReceiptCard(),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF8B1A4A),
        foregroundColor: Colors.white,
        onPressed: () => _printReceipt(context),
        icon: const Icon(Icons.print),
        label: const Text('Print'),
      ),
    );
  }

  Widget _buildReceiptCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── HEADER ──
            _buildHeader(),
            const Divider(thickness: 1.5, height: 24),

            // ── FEES RECEIPT TITLE ──
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.black38),
                  bottom: BorderSide(color: Colors.black38),
                ),
              ),
              child: const Center(
                child: Text(
                  'FEES RECEIPT',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── RECEIPT DATE & NO ──
            _buildTwoColRow(
              'Receipt Date :', _formattedDate,
              'Receipt No. :', data.receiptNo,
            ),
            const SizedBox(height: 8),

            // ── COURSES ──
            _buildLabelValue('Courses :', data.courses),
            const SizedBox(height: 8),

            // ── AMOUNT ──
            _buildLabelValue('Amount received :', _formattedAmount),
            const SizedBox(height: 8),

            // ── AMOUNT IN WORDS ──
            _buildLabelValue(
                'Amount received (in words) :', data.amountInWords),
            const SizedBox(height: 8),

            // ── PAYMENT ROW ──
            _buildTwoColRow(
              'Payment mode :', data.paymentMode,
              'Cheque No. :', data.chequeNo,
            ),
            const SizedBox(height: 8),
            _buildTwoColRow(
              'Cheque Dated :', data.chequeDated,
              'Bank Name :', data.bankName,
            ),
            const SizedBox(height: 8),
            _buildTwoColRow(
              'IFSC Code :', data.ifscCode,
              'Online Tranx. No. :', data.onlineTranxNo,
            ),
            const SizedBox(height: 8),
            _buildTwoColRow(
              'Due Date :', data.dueDate,
              'Due Fees :', _formattedDue,
            ),
            const SizedBox(height: 16),
            const Divider(thickness: 1),
            const SizedBox(height: 8),

            // ── TERMS ──
            _buildLabelValue(
              'Terms & Conditions :',
              data.termsAndConditions.isEmpty ? '' : data.termsAndConditions,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ── HEADER: institute + student info side by side ──
  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo placeholder
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Icon(Icons.store, size: 36, color: Color(0xFF8B1A4A)),
        ),
        const SizedBox(width: 14),
        // Institute info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.instituteName,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(data.instituteAddress,
                  style: const TextStyle(fontSize: 12)),
              Text('Email : ${data.instituteEmail}',
                  style: const TextStyle(fontSize: 12)),
              Text('Contact No. : ${data.instituteContact}',
                  style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
        const SizedBox(width: 14),
        // Student info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.studentName,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text('Address : ${data.studentAddress}',
                  style: const TextStyle(fontSize: 12)),
              Text('Email : ${data.studentEmail}',
                  style: const TextStyle(fontSize: 12)),
              Text('Contact No. : ${data.studentContact}',
                  style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  // ── Two label-value pairs in one row ──
  Widget _buildTwoColRow(
    String label1, String value1,
    String label2, String value2,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildLabelValue(label1, value1)),
        Expanded(child: _buildLabelValue(label2, value2)),
      ],
    );
  }

  // ── Single label + value ──
  Widget _buildLabelValue(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 13, color: Colors.black),
          children: [
            TextSpan(
              text: '$label ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // PRINT / PDF GENERATION
  // ─────────────────────────────────────────────
  Future<void> _printReceipt(BuildContext context) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context ctx) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              // Title
              pw.Center(
                child: pw.Text(
                  'Student\'s Copy',
                  style: pw.TextStyle(
                      fontSize: 12, color: PdfColors.grey600),
                ),
              ),
              pw.SizedBox(height: 12),

              // Header
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Container(
                    width: 50,
                    height: 50,
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey),
                    ),
                    child: pw.Center(
                        child: pw.Text('logo',
                            style: pw.TextStyle(fontSize: 10))),
                  ),
                  pw.SizedBox(width: 12),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(data.instituteName,
                            style: pw.TextStyle(
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold)),
                        pw.Text(data.instituteAddress,
                            style: const pw.TextStyle(fontSize: 10)),
                        pw.Text('Email : ${data.instituteEmail}',
                            style: const pw.TextStyle(fontSize: 10)),
                        pw.Text(
                            'Contact No. : ${data.instituteContact}',
                            style: const pw.TextStyle(fontSize: 10)),
                      ],
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(data.studentName,
                            style: pw.TextStyle(
                                fontSize: 13,
                                fontWeight: pw.FontWeight.bold)),
                        pw.Text('Address : ${data.studentAddress}',
                            style: const pw.TextStyle(fontSize: 10)),
                        pw.Text('Email : ${data.studentEmail}',
                            style: const pw.TextStyle(fontSize: 10)),
                        pw.Text(
                            'Contact No. : ${data.studentContact}',
                            style: const pw.TextStyle(fontSize: 10)),
                      ],
                    ),
                  ),
                ],
              ),
              pw.Divider(),

              // Receipt title
              pw.Center(
                child: pw.Text(
                  'FEES RECEIPT',
                  style: pw.TextStyle(
                      fontSize: 16, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.Divider(),
              pw.SizedBox(height: 8),

              _pdfTwoCol('Receipt Date :', _formattedDate,
                  'Receipt No. :', data.receiptNo),
              pw.SizedBox(height: 6),
              _pdfRow('Courses :', data.courses),
              pw.SizedBox(height: 6),
              _pdfRow('Amount received :', _formattedAmount),
              pw.SizedBox(height: 6),
              _pdfRow(
                  'Amount received (in words) :', data.amountInWords),
              pw.SizedBox(height: 6),
              _pdfTwoCol('Payment mode :', data.paymentMode,
                  'Cheque No. :', data.chequeNo),
              pw.SizedBox(height: 6),
              _pdfTwoCol('Cheque Dated :', data.chequeDated,
                  'Bank Name :', data.bankName),
              pw.SizedBox(height: 6),
              _pdfTwoCol('IFSC Code :', data.ifscCode,
                  'Online Tranx. No. :', data.onlineTranxNo),
              pw.SizedBox(height: 6),
              _pdfTwoCol('Due Date :', data.dueDate,
                  'Due Fees :', _formattedDue),
              pw.SizedBox(height: 12),
              pw.Divider(),
              _pdfRow('Terms & Conditions :', data.termsAndConditions),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  pw.Widget _pdfRow(String label, String value) {
    return pw.RichText(
      text: pw.TextSpan(
        children: [
          pw.TextSpan(
            text: '$label ',
            style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold, fontSize: 11),
          ),
          pw.TextSpan(
              text: value, style: const pw.TextStyle(fontSize: 11)),
        ],
      ),
    );
  }

  pw.Widget _pdfTwoCol(
      String l1, String v1, String l2, String v2) {
    return pw.Row(
      children: [
        pw.Expanded(child: _pdfRow(l1, v1)),
        pw.Expanded(child: _pdfRow(l2, v2)),
      ],
    );
  }
}