import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui;

class BarcodeScannerWeb extends StatefulWidget {
  final void Function(String upc) onScanned;

  const BarcodeScannerWeb({super.key, required this.onScanned});

  @override
  State<BarcodeScannerWeb> createState() => _BarcodeScannerWebState();
}

class _BarcodeScannerWebState extends State<BarcodeScannerWeb> {
  late final String _viewType;
  String? _scannedUpc;
  late final html.EventListener _messageListener;

  @override
  void initState() {
    super.initState();

    _viewType = 'scanner-iframe-${UniqueKey().toString()}';

    // Register iframe view
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
      final iframe =
          html.IFrameElement()
            ..src = 'barcode_scanner.html'
            ..style.border = 'none'
            ..style.width = '350px'
            ..style.height = '320px';
      return iframe;
    });

    // Define and register message listener
    _messageListener = (event) {
      final upc = (event as html.MessageEvent).data.toString().trim();
      if (upc.isNotEmpty) {
        print('📦 Scanned UPC: $upc');
        if (!mounted) return;
        setState(() => _scannedUpc = upc);
        widget.onScanned(upc);
      }
    };

    html.window.addEventListener('message', _messageListener);
  }

  @override
  void dispose() {
    html.window.removeEventListener('message', _messageListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 350,
          height: 320,
          child: HtmlElementView(viewType: _viewType),
        ),
        if (_scannedUpc != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              '📦 UPC: $_scannedUpc',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),
      ],
    );
  }
}
