import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/task.dart';

class PdfService {
  static Future<void> generateTasksSummaryPdf(String projectName, List<AppTask> tasks) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text(
                'Resumen de Tareas',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              'Proyecto: $projectName',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.teal),
            ),
            pw.SizedBox(height: 20),
            pw.TableHelper.fromTextArray(
              headers: ['Tarea', 'Prioridad', 'Estado', 'Responsable', 'Inicio', 'Fin'],
              data: tasks.map((t) => [
                t.title,
                t.priority,
                t.status,
                t.responsible,
                t.startDate,
                t.endDate ?? 'Pendiente',
              ]).toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.teal),
              cellAlignment: pw.Alignment.centerLeft,
              cellStyle: const pw.TextStyle(fontSize: 10),
              headerHeight: 30,
              cellHeight: 25,
            ),
            pw.SizedBox(height: 20),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Text(
                  'Total de tareas: ${tasks.length}',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                )
              ]
            )
          ];
        },
      ),
    );

    final cleanName = projectName.replaceAll(RegExp(r'[^\w\s]+'), '').replaceAll(' ', '_');

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Resumen_Tareas_$cleanName.pdf',
    );
  }
}
