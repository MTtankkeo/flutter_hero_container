import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:hero_container/widgets/hero_container.dart';

/// A widget that paints its child at an absolute offset position.
///
/// Used internally by [HeroContainer] to position widgets at
/// specific screen coordinates during transition animations.
@protected
class AbsoluteOffset extends SingleChildRenderObjectWidget {
  /// Creates a widget that paints its child at the specified [offset].
  const AbsoluteOffset({super.key, required this.offset, required super.child});

  /// The absolute position where the child should be painted.
  final Offset offset;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderAbsoluteOffset(offset);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderObject renderObject,
  ) {
    (renderObject as _RenderAbsoluteOffset).offset = offset;
  }
}

/// The render object for [AbsoluteOffset].
///
/// Paints the child widget at the specified absolute position
/// while maintaining the original layout constraints.
class _RenderAbsoluteOffset extends RenderProxyBox {
  _RenderAbsoluteOffset(this._offset);

  Offset _offset;

  /// The absolute offset where the child should be painted.
  set offset(Offset value) {
    if (value == _offset) return;
    _offset = value;
    markNeedsPaint();
  }

  @override
  void paint(PaintingContext context, Offset _) {
    if (child != null) {
      // Convert global offset to local coordinates and paint the child
      final Offset offset = child?.globalToLocal(_offset) ?? _offset;
      context.paintChild(child!, offset);
    }
  }
}
