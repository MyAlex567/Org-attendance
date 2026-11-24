import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../theme/app_theme.dart';
import '../atoms/app_text.dart';

/// The camera box on the Scan QR screen. It only reads QR codes and hands
/// the text to [onScan]; the page decides what to do with it.
class QrScanner extends StatefulWidget {
  final void Function(String code) onScan;

  const QrScanner({super.key, required this.onScan});

  @override
  State<QrScanner> createState() => _QrScannerState();
}

class _QrScannerState extends State<QrScanner> {
  // Only QR codes, so barcodes on IDs or books are ignored.
  final _controller = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
  );

  @override
  void dispose() {
    // Turns the camera off when the screen closes.
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (capture.barcodes.isEmpty) return;

    final code = capture.barcodes.first.rawValue;
    if (code != null) widget.onScan(code);
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 300,
        color: AppColors.text, // dark box behind the camera
        child: Stack(
          children: [
            MobileScanner(
              controller: _controller,
              onDetect: _onDetect,
              errorBuilder: (context, error) => const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: AppText(
                    text: 'Camera unavailable. Allow camera access for this '
                        'app in your phone settings.',
                    variant: AppTextVariant.body,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
            // Green frame on top of the camera. IgnorePointer lets taps pass
            // through to the camera.
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  margin: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.green, width: 3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
