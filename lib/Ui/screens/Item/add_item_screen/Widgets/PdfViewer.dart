import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class PdfViewer extends StatelessWidget {
  final String url;

  const PdfViewer({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('PDF Viewer')),
      body: PDFView(
        filePath: url,
      ),
    );
  }
}