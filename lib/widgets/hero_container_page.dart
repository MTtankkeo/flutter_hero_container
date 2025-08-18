import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// A widget that conditionally paints and handles hit testing for its child.
///
/// [HeroContainerPage] is used internally by [HeroContainer] to control
/// when the opened widget should be visible and interactive during the
/// transition animation. It provides fine-grained control over painting
/// and hit testing based on the [shouldPaint] property.
///
/// When [shouldPaint] is false, the widget is rendered but not painted
/// to the screen and does not respond to hit tests, effectively making
/// it invisible and non-interactive while still maintaining its layout.
@protected
class HeroContainerPage extends SingleChildRenderObjectWidget {
  /// Creates a hero container page with conditional painting.
  const HeroContainerPage({
    super.key,
    required this.shouldPaint,
    required super.child,
  });

  /// Whether the child widget should be painted and respond to hit tests.
  ///
  /// When true, the widget behaves normally. When false, the widget
  /// maintains its layout but is not painted and does not respond to
  /// touch events.
  final bool shouldPaint;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderHeroContainerPage(shouldPaint: shouldPaint);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderObject renderObject,
  ) {
    (renderObject as _RenderHeroContainerPage).shouldPaint = shouldPaint;
  }
}

/// The render object for [HeroContainerPage].
///
/// This render object extends [RenderProxyBox] to provide conditional
/// painting and hit testing capabilities. It allows the widget tree
/// to be built and laid out normally while controlling visibility
/// and interactivity at the rendering level.
class _RenderHeroContainerPage extends RenderProxyBox {
  /// Creates a render object with conditional painting behavior.
  _RenderHeroContainerPage({required bool shouldPaint})
      : _shouldPaint = shouldPaint;

  @override
  RenderBox get child => super.child!;

  bool _shouldPaint;

  /// Whether this render object should paint its child.
  ///
  /// When this changes, the render object will be marked as needing
  /// to repaint to reflect the new visibility state.
  bool get shouldPaint => _shouldPaint;
  set shouldPaint(bool value) {
    if (_shouldPaint != value) {
      _shouldPaint = value;
      markNeedsPaint();
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_shouldPaint) {
      context.paintChild(child, offset);
    } else {
      // When not painting, still push a layer to maintain proper
      // layer tree structure but with full opacity to ensure
      // the child is properly laid out but not visible.
      context.pushLayer(
        OpacityLayer(alpha: 1),
        (context, offset) => context.paintChild(child, offset),
        offset,
      );
    }
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    // Only perform hit testing when the widget should be painted,
    // making it non-interactive when invisible.
    return shouldPaint ? super.hitTest(result, position: position) : false;
  }
}
