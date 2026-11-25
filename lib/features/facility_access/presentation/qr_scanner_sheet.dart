import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/theme/ritma_spacing.dart';
import '../../../core/theme/ritma_status_colors.dart';
import '../../../core/widgets/ritma_status_pill.dart';

/// Camera-based QR scanner modal with 2-second scan debounce, camera permission
/// error fallback, malformed token handling, and live check-in outcome banner.
class QrScannerSheet extends StatefulWidget {
  const QrScannerSheet({
    required this.branchName,
    required this.onScanToken,
    this.debugTokenStream,
    super.key,
  });

  final String branchName;
  final Future<({bool allowed, String message, String? reasonCode})> Function(
    String token,
  )
  onScanToken;
  final Stream<String>? debugTokenStream;

  @override
  State<QrScannerSheet> createState() => _QrScannerSheetState();
}

class _QrScannerSheetState extends State<QrScannerSheet> {
  late final MobileScannerController _controller;
  final _manualFallbackCtrl = TextEditingController();
  StreamSubscription<String>? _debugSub;
  DateTime? _lastScanAt;
  String? _lastScannedToken;
  bool _processing = false;
  ({bool allowed, String message, String? reasonCode})? _outcome;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      formats: const <BarcodeFormat>[BarcodeFormat.qrCode],
      detectionSpeed: DetectionSpeed.normal,
    );
    _debugSub = widget.debugTokenStream?.listen((token) {
      unawaited(_handleToken(token));
    });
  }

  @override
  void dispose() {
    unawaited(_debugSub?.cancel());
    _manualFallbackCtrl.dispose();
    unawaited(_controller.dispose());
    super.dispose();
  }

  Future<void> _handleToken(String raw) async {
    final token = raw.trim();
    if (token.isEmpty || _processing) return;

    final now = DateTime.now();
    if (_lastScannedToken == token &&
        _lastScanAt != null &&
        now.difference(_lastScanAt!) < const Duration(seconds: 2)) {
      return;
    }

    _lastScannedToken = token;
    _lastScanAt = now;

    if (!token.contains('.') || token.length < 12) {
      if (!mounted) return;
      setState(() {
        _outcome = (
          allowed: false,
          message: 'Unrecognized QR format. Present a valid RITMA pass.',
          reasonCode: 'QR_MALFORMED',
        );
      });
      return;
    }

    setState(() => _processing = true);
    try {
      final result = await widget.onScanToken(token);
      if (!mounted) return;
      setState(() {
        _processing = false;
        _outcome = result;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _processing = false;
        _outcome = (
          allowed: false,
          message: 'Unable to validate pass right now. Please try again.',
          reasonCode: 'SCAN_ERROR',
        );
      });
    }
  }

  Future<void> _toggleTorchSafely() async {
    try {
      await _controller.toggleTorch();
    } catch (_) {
      // Devices without flash or uninitialized camera views safely ignore torch requests.
    }
  }

  Future<void> _retryCameraSafely() async {
    try {
      await _controller.start();
    } catch (_) {
      // MobileScanner errorBuilder handles unavailable or permission-denied camera states.
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColors = context.statusColors;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: RitmaSpacing.md,
          right: RitmaSpacing.md,
          top: RitmaSpacing.md,
          bottom: MediaQuery.viewInsetsOf(context).bottom + RitmaSpacing.md,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Camera QR Check-In',
                          style: theme.textTheme.titleLarge,
                        ),
                        Text(
                          'Branch: ${widget.branchName}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  ValueListenableBuilder<MobileScannerState>(
                    valueListenable: _controller,
                    builder: (context, scanState, _) {
                      final isTorchOn = scanState.torchState == TorchState.on;
                      return IconButton(
                        tooltip: isTorchOn ? 'Turn off flash' : 'Turn on flash',
                        onPressed: _toggleTorchSafely,
                        icon: Icon(
                          isTorchOn ? Icons.flash_on : Icons.flash_off_outlined,
                        ),
                      );
                    },
                  ),
                  IconButton(
                    tooltip: 'Close scanner',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: RitmaSpacing.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(RitmaRadius.lg),
                child: SizedBox(
                  height: 280,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      MobileScanner(
                        controller: _controller,
                        onDetect: (capture) {
                          for (final barcode in capture.barcodes) {
                            final value = barcode.rawValue;
                            if (value != null && value.trim().isNotEmpty) {
                              unawaited(_handleToken(value));
                              break;
                            }
                          }
                        },
                        errorBuilder: (ctx, error) => _ScannerFallbackPanel(
                          error: error,
                          controller: _manualFallbackCtrl,
                          processing: _processing,
                          onRetryCamera: () => unawaited(_retryCameraSafely()),
                          onSubmitManual: () =>
                              _handleToken(_manualFallbackCtrl.text),
                        ),
                      ),
                      IgnorePointer(
                        child: Center(
                          child: _ScannerReticleOverlay(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      if (_processing)
                        Container(
                          color: Colors.black.withValues(alpha: 0.55),
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircularProgressIndicator(),
                              const SizedBox(height: RitmaSpacing.xs),
                              Text(
                                'Validating pass...',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (_outcome != null) ...[
                const SizedBox(height: RitmaSpacing.sm),
                Container(
                  padding: const EdgeInsets.all(RitmaSpacing.sm),
                  decoration: BoxDecoration(
                    color: _outcome!.allowed
                        ? statusColors.successBg
                        : statusColors.dangerBg,
                    borderRadius: BorderRadius.circular(RitmaRadius.md),
                    border: Border.all(
                      color: _outcome!.allowed
                          ? statusColors.successFg
                          : statusColors.dangerFg,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _outcome!.allowed
                            ? Icons.check_circle_outline
                            : Icons.block_outlined,
                        color: _outcome!.allowed
                            ? statusColors.successFg
                            : statusColors.dangerFg,
                      ),
                      const SizedBox(width: RitmaSpacing.sm),
                      Expanded(
                        child: Text(
                          _outcome!.message,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: _outcome!.allowed
                                ? statusColors.successFg
                                : statusColors.dangerFg,
                          ),
                        ),
                      ),
                      if (_outcome!.reasonCode != null)
                        RitmaStatusPill(
                          label: _outcome!.reasonCode!,
                          tone: _outcome!.allowed
                              ? RitmaPillTone.success
                              : RitmaPillTone.danger,
                        ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: RitmaSpacing.sm),
              Wrap(
                spacing: RitmaSpacing.xs,
                runSpacing: RitmaSpacing.xs,
                alignment: WrapAlignment.spaceBetween,
                children: [
                  Text(
                    'Duplicate scans within 2s are ignored automatically.',
                    style: theme.textTheme.bodySmall,
                  ),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Use Manual Lookup'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScannerReticleOverlay extends StatelessWidget {
  const _ScannerReticleOverlay({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 176,
      height: 176,
      child: CustomPaint(painter: _CornerReticlePainter(color: color)),
    );
  }
}

class _CornerReticlePainter extends CustomPainter {
  const _CornerReticlePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.85)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const corner = 24.0;
    final w = size.width;
    final h = size.height;

    final path = Path()
      ..moveTo(0, corner)
      ..lineTo(0, 0)
      ..lineTo(corner, 0)
      ..moveTo(w - corner, 0)
      ..lineTo(w, 0)
      ..lineTo(w, corner)
      ..moveTo(w, h - corner)
      ..lineTo(w, h)
      ..lineTo(w - corner, h)
      ..moveTo(corner, h)
      ..lineTo(0, h)
      ..lineTo(0, h - corner);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CornerReticlePainter oldDelegate) =>
      oldDelegate.color != color;
}

class _ScannerFallbackPanel extends StatelessWidget {
  const _ScannerFallbackPanel({
    required this.error,
    required this.controller,
    required this.processing,
    required this.onRetryCamera,
    required this.onSubmitManual,
  });

  final MobileScannerException error;
  final TextEditingController controller;
  final bool processing;
  final VoidCallback onRetryCamera;
  final VoidCallback onSubmitManual;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPermission =
        error.errorCode == MobileScannerErrorCode.permissionDenied;
    final headline = isPermission
        ? 'Camera permission denied'
        : 'Camera unavailable on this device';
    final detail = isPermission
        ? 'Allow camera access in browser/device settings or paste a member QR token below.'
        : (error.errorDetails?.message ??
              'No active camera was detected. You can paste a QR token or use manual lookup.');

    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.all(RitmaSpacing.md),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(Icons.videocam_off_outlined),
                  const SizedBox(width: RitmaSpacing.xs),
                  Expanded(
                    child: Text(headline, style: theme.textTheme.titleSmall),
                  ),
                ],
              ),
              const SizedBox(height: RitmaSpacing.xxs),
              Text(detail, style: theme.textTheme.bodySmall),
              const SizedBox(height: RitmaSpacing.sm),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Paste Member QR Token',
                  isDense: true,
                ),
                onSubmitted: (_) => onSubmitManual(),
              ),
              const SizedBox(height: RitmaSpacing.xs),
              Wrap(
                spacing: RitmaSpacing.xs,
                children: [
                  OutlinedButton(
                    onPressed: onRetryCamera,
                    child: const Text('Retry Camera'),
                  ),
                  FilledButton(
                    onPressed: processing ? null : onSubmitManual,
                    child: const Text('Validate Token'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
