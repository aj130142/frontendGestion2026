import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/task.dart';

class PdfService {
  static Future<void> generateTasksSummaryPdf(String projectName, List<AppTask> tasks) async {
    final pdf = pw.Document();

    // Calculate stats for the chart
    final stats = <String, int>{};
    for (var t in tasks) {
      stats[t.status] = (stats[t.status] ?? 0) + 1;
    }

    final data = stats.entries.toList();

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
            pw.SizedBox(height: 40),
            pw.Text(
              'Distribución por Estado',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 20),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                pw.SizedBox(
                  width: 200,
                  height: 200,
                  child: pw.Chart(
                    grid: pw.PieGrid(),
                    datasets: data.map((entry) {
                      return pw.PieDataSet(
                        legend: entry.key,
                        value: entry.value.toDouble(),
                        color: _getPdfStatusColor(entry.key),
                        drawSurface: true,
                      );
                    }).toList(),
                  ),
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: data.map((entry) => pw.Row(
                    children: [
                      pw.Container(width: 10, height: 10, color: _getPdfStatusColor(entry.key)),
                      pw.SizedBox(width: 5),
                      pw.Text('${entry.key}: ${entry.value} (${((entry.value / tasks.length) * 100).toStringAsFixed(1)}%)'),
                    ],
                  )).toList(),
                ),
              ],
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

  static PdfColor _getPdfStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completada':
      case 'finalizada':
        return PdfColors.green;
      case 'en progreso':
        return PdfColors.blue;
      case 'cancelada':
        return PdfColors.red;
      case 'pendiente':
      default:
        return PdfColors.orange;
    }
  }
}
