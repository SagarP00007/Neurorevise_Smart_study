import 'package:flutter/material.dart';
import 'package:flutter_cube/flutter_cube.dart' as cube;
import 'package:lottie/lottie.dart';
import 'package:study_smart/core/theme/app_theme.dart';
import 'package:study_smart/core/widgets/three_d_elements.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ThreeDObject — Unified 3D display with automatic fallback chain
// ─────────────────────────────────────────────────────────────────────────────

/// Renders a 3D element using the best available method:
///
///   1. **OBJ model** via `flutter_cube` (if [objPath] is provided)
///   2. **Lottie animation** via `lottie` (if [lottiePath] is provided)
///   3. **Pure-Flutter fallback** — rotating cube or sphere (always works)
///
/// ```dart
/// // OBJ model (most realistic)
/// ThreeDObject.obj('assets/models/book.obj', size: 200)
///
/// // Lottie (pre-made smooth animation)
/// ThreeDObject.lottie('assets/animations/study_3d.json', size: 200)
///
/// // Pure Flutter (zero deps — cube or sphere)
/// ThreeDObject.cube(size: 100, color: AppTheme.primary)
/// ThreeDObject.sphere(size: 160)
/// ```
class ThreeDObject extends StatelessWidget {
  // ── Named constructors ────────────────────────────────────────────────────

  /// Render a real OBJ 3D model via flutter_cube.
  const ThreeDObject.obj(
    this._objPath, {
    super.key,
    this.size = 200,
    Color? glowColor,
  })  : _mode = _Mode.obj,
        _lottiePath = null,
        _cubeColor = glowColor ?? AppTheme.primary,
        _useCube = false;

  /// Render a Lottie animation (pseudo-3D or stylised).
  const ThreeDObject.lottie(
    this._lottiePath, {
    super.key,
    this.size = 200,
  })  : _mode = _Mode.lottie,
        _objPath = null,
        _cubeColor = AppTheme.primary,
        _useCube = false;

  /// Render a pure-Flutter rotating neon cube (zero deps).
  const ThreeDObject.cube({
    super.key,
    this.size = 100,
    Color color = AppTheme.primary,
    IconData? icon,
  })  : _mode = _Mode.flutterCube,
        _objPath = null,
        _lottiePath = null,
        _cubeColor = color,
        _useCube = true;

  /// Render a pure-Flutter rotating wireframe sphere (zero deps).
  const ThreeDObject.sphere({
    super.key,
    this.size = 160,
    Color color = AppTheme.primary,
  })  : _mode = _Mode.flutterSphere,
        _objPath = null,
        _lottiePath = null,
        _cubeColor = color,
        _useCube = false;

  // ── Fields ────────────────────────────────────────────────────────────────
  final _Mode _mode;
  final String? _objPath;
  final String? _lottiePath;
  final double size;
  final Color _cubeColor;
  final bool _useCube;

  @override
  Widget build(BuildContext context) {
    return switch (_mode) {
      _Mode.obj          => _ObjWidget(path: _objPath!, size: size, glowColor: _cubeColor),
      _Mode.lottie       => _LottieWidget(path: _lottiePath!, size: size),
      _Mode.flutterCube  => Rotating3DCube(size: size * 0.6, faceColor: _cubeColor),
      _Mode.flutterSphere => Rotating3DSphere(size: size, color: _cubeColor),
    };
  }
}

enum _Mode { obj, lottie, flutterCube, flutterSphere }

// ─────────────────────────────────────────────────────────────────────────────
// _ObjWidget — flutter_cube OBJ renderer
// ─────────────────────────────────────────────────────────────────────────────

class _ObjWidget extends StatefulWidget {
  const _ObjWidget({
    required this.path,
    required this.size,
    required this.glowColor,
  });

  final String path;
  final double size;
  final Color glowColor;

  @override
  State<_ObjWidget> createState() => _ObjWidgetState();
}

class _ObjWidgetState extends State<_ObjWidget> {
  cube.Scene? _scene;

  void _onSceneCreated(cube.Scene scene) {
    _scene = scene;
    scene.world.add(cube.Object(fileName: widget.path));
    scene.camera.zoom = 5;
    // Enable auto-rotation
    scene.world.rotation.y = 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: widget.glowColor.withOpacity(0.25),
            blurRadius: 40,
            spreadRadius: -4,
          ),
        ],
      ),
      child: cube.Cube(
        onSceneCreated: _onSceneCreated,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _LottieWidget — Lottie animation (already installed)
// ─────────────────────────────────────────────────────────────────────────────

class _LottieWidget extends StatelessWidget {
  const _LottieWidget({required this.path, required this.size});

  final String path;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Lottie.asset(
        path,
        fit: BoxFit.contain,
        // Lottie handles its own animation loop
        repeat: true,
        animate: true,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PrebuiltModels — Convenience constants for bundled assets
// ─────────────────────────────────────────────────────────────────────────────

/// Paths to bundled OBJ / Lottie assets. Add your files and reference them here.
abstract final class PrebuiltModels {
  // OBJ models (place in assets/models/)
  static const String book    = 'assets/models/book.obj';
  static const String dna     = 'assets/models/dna.obj';
  static const String atom    = 'assets/models/atom.obj';
  static const String globe   = 'assets/models/globe.obj';

  // Lottie animations (place in assets/animations/)
  static const String studyAi   = 'assets/animations/study_ai.json';
  static const String brainScan = 'assets/animations/brain_scan.json';
  static const String orbiting  = 'assets/animations/orbiting.json';

  PrebuiltModels._();
}
