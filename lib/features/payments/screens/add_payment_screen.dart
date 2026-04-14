import 'package:flutter/material.dart';
import '../../../core/api/services.dart';
import '../../../core/models/models.dart';
import '../../../widgets/app_widgets.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class AddPaymentScreen extends StatefulWidget {
  final FeeSummary? fee; // optional if opened from FeesScreen

  const AddPaymentScreen({super.key, this.fee});

  @override
  State<AddPaymentScreen> createState() => _AddPaymentScreenState();
}

class _AddPaymentScreenState extends State<AddPaymentScreen> {
  final _amountCtrl = TextEditingController();
  final _dateCtrl   = TextEditingController();

  final _svc = PaymentService();

  bool _saving = false;


Future<void> _generateAndSharePdf(double amount) async {
  final pdf = pw.Document();

  final studentName = widget.fee?.studentName ?? "-";
  final date = DateTime.now().toString().split(' ')[0];
  final nextDue = _dateCtrl.text;

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Padding(
          padding: const pw.EdgeInsets.all(24),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("Payment Receipt",
                  style: pw.TextStyle(
                      fontSize: 22, fontWeight: pw.FontWeight.bold)),

              pw.SizedBox(height: 20),

              _pdfRow("Student", studentName),
              _pdfRow("Amount", "₹${amount.toStringAsFixed(0)}"),
              _pdfRow("Date", date),

              if (nextDue.isNotEmpty)
                _pdfRow("Next Due", nextDue),

              pw.SizedBox(height: 30),

              pw.Divider(),

              pw.SizedBox(height: 10),

              pw.Text("Thank you!",
                  style: pw.TextStyle(fontSize: 14)),
            ],
          ),
        );
      },
    ),
  );

  // ✅ Share PDF
  await Printing.sharePdf(
    bytes: await pdf.save(),
    filename: 'receipt_${DateTime.now().millisecondsSinceEpoch}.pdf',
  );
}

pw.Widget _pdfRow(String key, String value) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 6),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(key, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.Text(value),
      ],
    ),
  );
}
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      _dateCtrl.text = picked.toIso8601String().split('T')[0];
    }
  }

  Future<void> _save() async {
    final amount = double.tryParse(_amountCtrl.text);

    if (amount == null || amount <= 0) {
      showSnack(context, 'Enter valid amount', error: true);
      return;
    }
    print("Student ID: ${widget.fee?.studentId}");
    final studentId = widget.fee?.studentId ?? 5;
    if (studentId == null) {
      showSnack(context, 'Student not found', error: true);
      return;
    }

    setState(() => _saving = true);

    try {
      await _svc.addPayment(
        studentId: studentId,
        amount: amount,
        nextDueDate: _dateCtrl.text.isEmpty ? null : _dateCtrl.text,
      );

      if (mounted) {
        _showReceipt(amount);
      }
    } catch (e) {
      if (mounted) {
        showSnack(context, e.toString(), error: true);
        setState(() => _saving = false);
      }
    }
  }

  // 🧾 Receipt Dialog
  void _showReceipt(double amount) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Payment Receipt"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _r("Student", widget.fee?.studentName ?? "-"),
          _r("Amount", "₹${amount.toStringAsFixed(0)}"),
          _r("Date", DateTime.now().toString().split(' ')[0]),
          if (_dateCtrl.text.isNotEmpty)
            _r("Next Due", _dateCtrl.text),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => _generateAndSharePdf(amount),
          child: const Text("Share PDF"),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.pop(context, true);
          },
          child: const Text("Done"),
        )
      ],
    ),
  );
}

  Widget _r(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(k, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(v),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _dateCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Payment"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
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
                    Expanded(child: Text(widget.fee!.studentName)),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            AppField(
              controller: _amountCtrl,
              label: 'Amount (₹)',
              icon: Icons.currency_rupee,
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 12),

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

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Save Payment"),
              ),
            )
          ],
        ),
      ),
    );
  }
}