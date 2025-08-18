import 'package:flutter/material.dart';
import 'package:hero_container/components/hero_container_controller.dart';
import 'package:hero_container/widgets/absolute_offset.dart';
import 'package:hero_container/widgets/hero_container.dart';
import 'package:hero_container/widgets/hero_container_page.dart';

/// A custom modal route that handles the hero container transition animation.
///
/// This route manages the snapshot-based animation between the closed and
/// opened states, handling widget capture, animation curves, and proper
/// lifecycle management during the transition.
class HeroContainerRoute<T> extends ModalRoute<T> {
  HeroContainerRoute({
    this.openedColor,
    this.closedColor,
    this.openedShape,
    this.closedShape,
    required this.openedElevation,
    required this.closedElevation,
    required this.openedFit,
    required this.closedFit,
    required this.openedAlignemnt,
    required this.closedAlignment,
    required this.transitionDuration,
    required this.transitionCurve,
    this.onClosed,
    required this.heroController,
    required this.flightShuttleBuilder,
  });

  final Color? openedColor;
  final Color? closedColor;
  final ShapeBorder? openedShape;
  final ShapeBorder? closedShape;
  final double openedElevation;
  final double closedElevation;
  final BoxFit openedFit;
  final BoxFit closedFit;
  final AlignmentGeometry openedAlignemnt;
  final AlignmentGeometry closedAlignment;
  final Curve transitionCurve;
  final HeroContianerClosedCallback? onClosed;
  final HeroContainerController heroController;
  final HeroContianerFlightShuttleBuilder flightShuttleBuilder;

  @override
  final Duration transitionDuration;

  @override
  void install() {
    // Mark the hero controller as active when route is installed.
    heroController.statusNotifier.value = HeroContainerStatus.active;
    super.install();
  }

  bool _isPopping = false;
  bool _canCapture = false;

  @override
  bool didPop(T? result) {
    if (!_canCapture || _isPopping) {
      onClosed?.call(result);
      return super.didPop(result);
    }

    // Capture the final state before popping.
    () async {
      heroController.toFragment = await heroController.fragmentOf(
        navigator!.context,
        heroController.toKey,
      );

      _isPopping = true;
      navigator!.pop(result);
    }();

    return false;
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _canCapture = true;
      }

      if (status == AnimationStatus.dismissed) {
        heroController.status = HeroContainerStatus.idle;
      }
    });

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final Animation<double> curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: transitionCurve,
          reverseCurve: transitionCurve.flipped,
        );

        return _RenderOverlay(
          controller: heroController,
          animation: curvedAnimation,
          openedColor: openedColor,
          closedColor: closedColor,
          openedShape: openedShape,
          closedShape: closedShape,
          openedElevation: openedElevation,
          closedElevation: closedElevation,
          openedFit: openedFit,
          closedFit: closedFit,
          openedAlignemnt: openedAlignemnt,
          closedAlignment: closedAlignment,
          onClosed: onClosed,
          flightShuttleBuilder: flightShuttleBuilder,
        );
      },
    );
  }

  @override
  Color? get barrierColor => null;

  @override
  bool get maintainState => true;

  @override
  String? get barrierLabel => null;

  @override
  bool get opaque => true;

  @override
  bool get barrierDismissible => false;
}

/// Utility class for launching hero container transitions.
///
/// Provides a static method to initiate the snapshot-based
/// transition animation by capturing the initial widget
/// state and pushing the hero container route.
class HeroContainerOverlay {
  /// Launches a hero container transition.
  ///
  /// Captures the current widget state and pushes a [HeroContainerRoute]
  /// with the specified transition properties. The route handles the
  /// animation between the captured snapshots.
  static Future<void> push({
    required BuildContext context,
    required HeroContainerController controller,
    Color? openedColor,
    Color? closedColor,
    ShapeBorder? openedShape,
    ShapeBorder? closedShape,
    required double openedElevation,
    required double closedElevation,
    required BoxFit openedFit,
    required BoxFit closedFit,
    required AlignmentGeometry openedAlignemnt,
    required AlignmentGeometry closedAlignment,
    required Duration transitionDuration,
    required Curve transitionCurve,
    HeroContianerClosedCallback? onClosed,
    HeroContianerFlightShuttleBuilder? flightShuttleBuilder,
  }) async {
    // Capture the initial widget state before transition.
    controller.fromFragment = await controller.fragmentOf(
      context,
      controller.fromKey,
    );

    if (context.mounted) {
      await Navigator.push(
        context,
        HeroContainerRoute(
          openedColor: openedColor,
          closedColor: closedColor,
          openedShape: openedShape,
          closedShape: closedShape,
          openedElevation: openedElevation,
          closedElevation: closedElevation,
          openedFit: openedFit,
          closedFit: closedFit,
          openedAlignemnt: openedAlignemnt,
          closedAlignment: closedAlignment,
          transitionDuration: transitionDuration,
          transitionCurve: transitionCurve,
          heroController: controller,
          onClosed: onClosed,
          flightShuttleBuilder:
              flightShuttleBuilder ?? _defaultFlightShuttleBuilder,
        ),
      );
    }
  }

  /// Default crossfade transition between widget snapshots.
  static Widget _defaultFlightShuttleBuilder(
    BuildContext context,
    Animation<double> animation,
    Widget fromWidget,
    Widget toWidget,
  ) {
    return Stack(
      clipBehavior: Clip.antiAlias,
      children: [
        Opacity(opacity: 1 - animation.value, child: fromWidget),
        Opacity(opacity: animation.value, child: toWidget),
      ],
    );
  }
}

/// Internal widget that renders the transition overlay.
///
/// Manages the animation between captured widget snapshots and handles
/// the transition from snapshot-based rendering to live widget rendering.
class _RenderOverlay extends StatefulWidget {
  const _RenderOverlay({
    this.openedColor,
    this.closedColor,
    this.openedShape,
    this.closedShape,
    required this.closedElevation,
    required this.openedElevation,
    required this.openedFit,
    required this.closedFit,
    required this.openedAlignemnt,
    required this.closedAlignment,
    this.onClosed,
    required this.controller,
    required this.animation,
    required this.flightShuttleBuilder,
  });

  final Color? openedColor;
  final Color? closedColor;
  final ShapeBorder? openedShape;
  final ShapeBorder? closedShape;
  final double openedElevation;
  final double closedElevation;
  final BoxFit openedFit;
  final BoxFit closedFit;
  final AlignmentGeometry openedAlignemnt;
  final AlignmentGeometry closedAlignment;
  final HeroContianerClosedCallback? onClosed;
  final HeroContainerController controller;
  final Animation<double> animation;
  final HeroContianerFlightShuttleBuilder flightShuttleBuilder;

  @override
  State<_RenderOverlay> createState() => _RenderOverlayState();
}

class _RenderOverlayState extends State<_RenderOverlay>
    with TickerProviderStateMixin {
  double get animValue => widget.animation.value;

  HeroContainerController get controller => widget.controller;

  /// Whether the opened widget can be captured (animation is complete).
  bool get canCapture => animValue == 1;

  /// Captures the opened widget state for the reverse animation.
  void captureWidget() async {
    controller.toFragment = await controller.fragmentOf(
      context,
      controller.toKey,
    );
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    // Capture the opened widget after the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) => captureWidget());
  }

  @override
  void dispose() {
    // Clean up the captured fragment.
    controller.toFragment = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Set up animation tweens for smooth transitions.

    final SizeTween sizeTween = SizeTween(
      begin: controller.fromFragment.size,
      end: controller.toFragment?.size ?? controller.fromFragment.size,
    );

    final Tween<Offset> offsetTween = Tween<Offset>(
      begin: controller.fromFragment.offset,
      end: controller.toFragment?.offset ?? controller.fromFragment.offset,
    );

    final ShapeBorderTween shapeTween = ShapeBorderTween(
      begin: widget.closedShape,
      end: widget.openedShape,
    );

    final ColorTween colorTween = ColorTween(
      begin: widget.closedColor,
      end: widget.openedColor,
    );

    final Tween<double> elevationTween = Tween<double>(
      begin: widget.closedElevation,
      end: widget.openedElevation,
    );

    return AnimatedBuilder(
      animation: widget.animation,
      builder: (context, child) {
        final double elevation = elevationTween.transform(animValue);
        final Offset offset = offsetTween.transform(animValue);
        final ShapeBorder? shape = shapeTween.transform(animValue);
        final Color? color = colorTween.transform(animValue);
        final Size size = sizeTween.transform(animValue)!;

        return Stack(
          children: [
            // Animated snapshot overlay (hidden when animation completes)
            Offstage(
              offstage: canCapture,
              child: AbsoluteOffset(
                offset: offset,
                child: Material(
                  animationDuration: Duration.zero,
                  elevation: elevation,
                  color: color,
                  shape: shape,
                  child: SizedBox(
                    width: size.width,
                    height: size.height,
                    child: widget.flightShuttleBuilder(
                      context,
                      widget.animation,
                      RawImage(
                        image: controller.fromFragment.capturedImage,
                        width: double.infinity,
                        height: double.infinity,
                        fit: widget.closedFit,
                        alignment: widget.closedAlignment,
                      ),
                      RawImage(
                        image: controller.toFragment?.capturedImage,
                        width: double.infinity,
                        height: double.infinity,
                        fit: widget.openedFit,
                        alignment: widget.openedAlignemnt,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Live widget (shown when animation completes)
            HeroContainerPage(
              shouldPaint: canCapture,
              child: RepaintBoundary(
                key: widget.controller.toKey,
                child: Visibility(
                  visible: controller.toFragment == null || canCapture,
                  maintainSize: false,
                  maintainState: false,
                  maintainAnimation: false,
                  child: widget.controller.builder(context),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
