import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

import '../../../core/api/services.dart';
import '../../../core/models/models.dart';
import '../../../widgets/app_widgets.dart';

class AddPaymentScreen extends StatefulWidget {
  final FeeSummary? fee;

  const AddPaymentScreen({super.key, this.fee});

  @override
  State<AddPaymentScreen> createState() => _AddPaymentScreenState();
}

class _AddPaymentScreenState extends State<AddPaymentScreen> {
  final _amountCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();
  final _discountCtrl = TextEditingController();
  final _svc = PaymentService();
  bool _saving = false;

  // ─────────────────────────────────────────────
  // NUMBER TO WORDS
  // ─────────────────────────────────────────────
  String _numberToWords(int number) {
    if (number == 0) return "Zero Rupees Only.";

    const units = [
      "", "One", "Two", "Three", "Four", "Five",
      "Six", "Seven", "Eight", "Nine"
    ];
    const teens = [
      "Ten", "Eleven", "Twelve", "Thirteen", "Fourteen",
      "Fifteen", "Sixteen", "Seventeen", "Eighteen", "Nineteen"
    ];
    const tens = [
      "", "", "Twenty", "Thirty", "Forty",
      "Fifty", "Sixty", "Seventy", "Eighty", "Ninety"
    ];

    String convert(int n) {
      if (n == 0) return "";
      if (n < 10) return units[n];
      if (n < 20) return teens[n - 10];
      if (n < 100) {
        final rem = n % 10 == 0 ? "" : " ${units[n % 10]}";
        return "${tens[n ~/ 10]}$rem";
      }
      if (n < 1000) {
        final rem = n % 100 == 0 ? "" : " ${convert(n % 100)}";
        return "${units[n ~/ 100]} Hundred$rem";
      }
      if (n < 100000) {
        final rem = n % 1000 == 0 ? "" : " ${convert(n % 1000)}";
        return "${convert(n ~/ 1000)} Thousand$rem";
      }
      if (n < 10000000) {
        final rem = n % 100000 == 0 ? "" : " ${convert(n % 100000)}";
        return "${convert(n ~/ 100000)} Lakh$rem";
      }
      final rem = n % 10000000 == 0 ? "" : " ${convert(n % 10000000)}";
      return "${convert(n ~/ 10000000)} Crore$rem";
    }

    return "${convert(number).trim()} Rupees Only.";
  }

  // ─────────────────────────────────────────────
  // PRINT / PDF GENERATION
  // ─────────────────────────────────────────────
  Future<void> _generateAndPrintPdf(double amount) async {
    final receiptDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
    final receiptNumber = "RCPT-${DateTime.now().millisecondsSinceEpoch}";
    final amountWords = _numberToWords(amount.toInt());
    final studentName = widget.fee?.name ?? "-";
    final mobile = widget.fee?.mobile ?? "-";
    final course = widget.fee?.courses.first.name ?? "-";
    final nextDue = _dateCtrl.text.isEmpty ? "NA" : _dateCtrl.text;
    final discount = double.tryParse(_discountCtrl.text) ?? 0;
    final netAmount = amount - discount;

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context ctx) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              // ── Student's Copy label ──
              pw.Center(
                child: pw.Text(
                  "Student's Copy",
                  style: pw.TextStyle(fontSize: 11, color: PdfColors.grey600),
                ),
              ),
              pw.SizedBox(height: 12),

              // ── Header: Institute + Student ──
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Logo box
                  pw.Container(
                    width: 50,
                    height: 50,
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey),
                    ),
                    child: pw.Center(
                      child: pw.Text("logo",
                          style: const pw.TextStyle(fontSize: 10)),
                    ),
                  ),
                  pw.SizedBox(width: 12),

                  // Institute info
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text("RUCHI MAKEUP ZONE",
                            style: pw.TextStyle(
                                fontSize: 14, fontWeight: pw.FontWeight.bold)),
                        pw.Text(
                            "302 19 sukh shanti nagar bicholi road\nBangali square indore 452016",
                            style: const pw.TextStyle(fontSize: 10)),
                        pw.Text("Email : ruchimakeupzone@gmail.com",
                            style: const pw.TextStyle(fontSize: 10)),
                        pw.Text("Contact No. : 6260336048",
                            style: const pw.TextStyle(fontSize: 10)),
                      ],
                    ),
                  ),

                  // Student info
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(studentName,
                            style: pw.TextStyle(
                                fontSize: 13, fontWeight: pw.FontWeight.bold)),
                        pw.Text("Address : ${ "-"}",
                            style: const pw.TextStyle(fontSize: 10)),
                        pw.Text("Email : ${widget.fee?.email ?? ""}",
                            style: const pw.TextStyle(fontSize: 10)),
                        pw.Text("Contact No. : $mobile",
                            style: const pw.TextStyle(fontSize: 10)),
                      ],
                    ),
                  ),
                ],
              ),
              pw.Divider(),

              // ── Receipt Title ──
              pw.Center(
                child: pw.Text(
                  "FEES RECEIPT",
                  style: pw.TextStyle(
                      fontSize: 16, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.Divider(),
              pw.SizedBox(height: 8),

              // ── Receipt Date & Number ──
              _pdfTwoCol(
                  "Receipt Date :", receiptDate,
                  "Receipt No. :", receiptNumber),
              pw.SizedBox(height: 6),

              // ── Course ──
              _pdfRow("Courses :", course),
              pw.SizedBox(height: 6),

              // ── Amount ──
              _pdfRow("Amount received :",
                  "₹ ${netAmount.toStringAsFixed(2)}"),
              pw.SizedBox(height: 6),

              // ── Amount in words ──
              _pdfRow("Amount received (in words) :",
                  _numberToWords(netAmount.toInt())),
              pw.SizedBox(height: 6),

              // ── Payment details ──
              _pdfTwoCol("Payment mode :", "Cash", "Cheque No. :", "NA"),
              pw.SizedBox(height: 6),
              _pdfTwoCol("Cheque Dated :", "NA", "Bank Name :", "NA"),
              pw.SizedBox(height: 6),
              _pdfTwoCol("IFSC Code :", "NA", "Online Tranx. No. :", "NA"),
              pw.SizedBox(height: 6),
              _pdfTwoCol("Due Date :", nextDue, "Due Fees :", "₹ 0.00"),
              pw.SizedBox(height: 12),
              pw.Divider(),

              // ── Terms ──
              _pdfRow("Terms & Conditions :", ""),
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
            text: "$label ",
            style:
                pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
          ),
          pw.TextSpan(
              text: value, style: const pw.TextStyle(fontSize: 11)),
        ],
      ),
    );
  }

  pw.Widget _pdfTwoCol(String l1, String v1, String l2, String v2) {
    return pw.Row(
      children: [
        pw.Expanded(child: _pdfRow(l1, v1)),
        pw.Expanded(child: _pdfRow(l2, v2)),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // DATE PICKER
  // ─────────────────────────────────────────────
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      _dateCtrl.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  // ─────────────────────────────────────────────
  // SAVE PAYMENT
  // ─────────────────────────────────────────────
  Future<void> _save() async {
    final amount = double.tryParse(_amountCtrl.text);
    final discount = double.tryParse(_discountCtrl.text) ?? 0;

    if (amount == null || amount <= 0) {
      showSnack(context, 'Enter valid amount', error: true);
      return;
    }

    final studentId = widget.fee?.studentId ?? 5;
    setState(() => _saving = true);

    try {
      await _svc.addPayment(
        studentId: studentId,
        amount: amount,
        nextDueDate: _dateCtrl.text.isEmpty ? null : _dateCtrl.text,
        discount: discount,
      );

      if (mounted) {
        _showReceipt(amount - discount);
      }
    } catch (e) {
      if (mounted) {
        showSnack(context, e.toString(), error: true);
        setState(() => _saving = false);
      }
    }
  }

  // ─────────────────────────────────────────────
  // RECEIPT DIALOG
  // ─────────────────────────────────────────────
  void _showReceipt(double netAmount) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Payment Receipt"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _receiptRow("Student", widget.fee?.name ?? "-"),
            _receiptRow("Amount", "₹${netAmount.toStringAsFixed(2)}"),
            _receiptRow(
                "Date", DateFormat('dd/MM/yyyy').format(DateTime.now())),
            if (_dateCtrl.text.isNotEmpty)
              _receiptRow("Next Due", _dateCtrl.text),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => _generateAndPrintPdf(netAmount),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.print, size: 18),
                SizedBox(width: 6),
                Text("Print Receipt"),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, true);
            },
            child: const Text("Done"),
          ),
        ],
      ),
    );
  }

  Widget _receiptRow(String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(key,
              style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(value),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // LIFECYCLE
  // ─────────────────────────────────────────────
  @override
  void dispose() {
    _amountCtrl.dispose();
    _dateCtrl.dispose();
    _discountCtrl.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Payment")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ── Student info banner ──
            if (widget.fee != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person),
                    const SizedBox(width: 10),
                    Expanded(child: Text(widget.fee!.name)),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // ── Amount field ──
            AppField(
              controller: _amountCtrl,
              label: 'Amount (₹)',
              icon: Icons.currency_rupee,
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 12),

            // ── Discount field ──
            AppField(
              controller: _discountCtrl,
              label: 'Discount (₹)',
              icon: Icons.percent,
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 12),

            // ── Next due date ──
            TextField(
              controller: _dateCtrl,
              readOnly: true,
              onTap: _pickDate,
              decoration: const InputDecoration(
                labelText: "Next Due Date",
                prefixIcon: Icon(Icons.calendar_today),
              ),
            ),

            const SizedBox(height: 20),

            // ── Save button ──
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Save Payment"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}