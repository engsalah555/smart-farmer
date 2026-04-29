import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraView extends StatefulWidget {
  final List<CameraDescription> cameras;

  const CameraView({super.key, required this.cameras});

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool _isTakingPicture = false;
  int _selectedCameraIndex = 0;

  @override
  void initState() {
    super.initState();
    _initCamera(_selectedCameraIndex);
  }

  void _initCamera(int index) {
    _controller = CameraController(
      widget.cameras[index],
      ResolutionPreset.high,
      enableAudio: false,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _toggleCamera() async {
    if (widget.cameras.length < 2) return;
    setState(() {
      _selectedCameraIndex = (_selectedCameraIndex + 1) % widget.cameras.length;
      _isTakingPicture = false;
    });
    _controller.dispose();
    _initCamera(_selectedCameraIndex);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              fit: StackFit.expand,
              children: [
                // ── Camera Preview ──
                Center(child: CameraPreview(_controller)),

                // ── UI Overlay ──
                _buildOverlay(context),

                // ── Top Controls ──
                Positioned(
                  top: MediaQuery.of(context).padding.top + 10,
                  left: 20,
                  right: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _CircleIconButton(
                        icon: Icons.close_rounded,
                        onPressed: () => Navigator.pop(context),
                      ),
                      if (widget.cameras.length > 1)
                        _CircleIconButton(
                          icon: Icons.flip_camera_ios_rounded,
                          onPressed: _toggleCamera,
                        ),
                    ],
                  ),
                ),

                // ── Bottom Controls (Shutter) ──
                Positioned(
                  bottom: 50,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: _isTakingPicture
                        ? const CircularProgressIndicator(color: Colors.white)
                        : _ShutterButton(
                            onTap: () async {
                              try {
                                setState(() => _isTakingPicture = true);
                                await _initializeControllerFuture;
                                final image = await _controller.takePicture();
                                if (mounted) {
                                  Navigator.pop(context, image);
                                }
                              } catch (e) {
                                debugPrint('Take picture error: $e');
                              } finally {
                                if (mounted) {
                                  setState(() => _isTakingPicture = false);
                                }
                              }
                            },
                          ),
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget _buildOverlay(BuildContext context) {
    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          border: Border.symmetric(
            horizontal: BorderSide(
              color: Colors.black.withValues(alpha: 0.3),
              width: 100,
            ),
          ),
        ),
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            height: MediaQuery.of(context).size.width * 0.85,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.4),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Stack(
              children: [
                // Corners
                _buildCorner(0, 0),
                _buildCorner(null, 0),
                _buildCorner(0, null),
                _buildCorner(null, null),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCorner(double? top, double? left) {
    return Positioned(
      top: top,
      left: left,
      right: left == null ? 0 : null,
      bottom: top == null ? 0 : null,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          border: Border(
            top: top != null
                ? const BorderSide(color: Colors.white, width: 4)
                : BorderSide.none,
            left: left != null
                ? const BorderSide(color: Colors.white, width: 4)
                : BorderSide.none,
            right: left == null
                ? const BorderSide(color: Colors.white, width: 4)
                : BorderSide.none,
            bottom: top == null
                ? const BorderSide(color: Colors.white, width: 4)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _CircleIconButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 22),
        onPressed: onPressed,
      ),
    );
  }
}

class _ShutterButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ShutterButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 84,
        width: 84,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 2),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.camera_alt_rounded,
              color: Colors.black.withValues(alpha: 0.8),
              size: 32,
            ),
          ),
        ),
      ),
    );
  }
}
