import 'package:flutter/material.dart';
import 'package:hero_container/components/hero_container_controller.dart';
import 'package:hero_container/components/hero_container_overlay.dart';

/// Signature for a function that builds the content widget
/// for a [HeroContainer] with an action callback.
///
/// The [action] parameter is a callback function that can be used
/// to trigger hero container actions such as opening the container.
typedef HeroContainerBuilder = Widget Function(
    BuildContext context, VoidCallback action);

/// Signature for a function that lets [HeroContainer]es self supply
/// a [Widget] that is shown during the hero container's
/// flight from one route to another instead of default.
typedef HeroContianerFlightShuttleBuilder = Widget Function(
  BuildContext context,
  Animation<double> animation,
  Widget fromWidget,
  Widget toWidget,
);

/// Signature for the callback function which is called when
/// the [HeroContainer] is closed.
typedef HeroContianerClosedCallback<S> = void Function(S data);

/// A widget that provides smooth animated transitions between a closed and opened state
/// using widget snapshots.
///
/// [HeroContainer] creates seamless animated transitions between two states:
/// a closed state that displays a compact widget, and an opened state that
/// displays a full-screen or expanded widget. Unlike traditional hero animations,
/// this widget captures snapshots (images) of both the closed and opened widgets,
/// then animates between these snapshots for consistently smooth performance
/// regardless of widget complexity.
///
/// The widget takes two builders:
/// * [closedBuilder]: Builds the widget shown in the closed state
/// * [openedBuilder]: Builds the widget shown in the opened state
///
/// When the [action] callback from [closedBuilder] is invoked, the container
/// will capture snapshots of both widgets and animate between them.
///
/// ## How it works
///
/// 1. **Snapshot Capture**: Both widgets are rendered and captured as images
/// 2. **Smooth Animation**: The transition animates between these snapshots
/// 3. **Performance**: Complex widgets animate smoothly since only images are animated
/// 4. **Visual Continuity**: Maintains perfect visual fidelity during transitions
///
/// ## Performance Benefits
///
/// Unlike traditional widget-based animations that can stutter with complex layouts,
/// [HeroContainer] maintains smooth 120fps performance by animating pre-captured
/// images instead of live widgets.
///
/// ## Example
///
/// ```dart
/// HeroContainer(
///   closedBuilder: (context, action) {
///     return TextButton(
///       onPressed: action,
///       child: Text("Tap to expand", style: TextStyle(fontSize: 50))
///     );
///   }
///   openedBuilder: (context) {
///     return Scaffold(
///       appBar: AppBar(title: Text("Expanded View")),
///       body: Center(
///         child: Text("Hello, World!", style: TextStyle(fontSize: 32)),
///       ),
///     );
///   },
/// )
/// ```
class HeroContainer extends StatefulWidget {
  /// Creates a hero container with customizable transition properties.
  const HeroContainer({
    super.key,
    this.openedColor,
    this.closedColor,
    this.openedShape,
    this.closedShape,
    this.onClosed,
    this.openedElevation = 4.0,
    this.closedElevation = 1.0,
    this.openedFit = BoxFit.fitWidth,
    this.closedFit = BoxFit.fitWidth,
    this.closedAlignment = Alignment.topCenter,
    this.openedAlignemnt = Alignment.topCenter,
    this.transitionDuration = const Duration(milliseconds: 300),
    this.transitionCurve = Curves.fastOutSlowIn,
    this.flightShuttleBuilder,
    required this.openedBuilder,
    required this.closedBuilder,
  });

  /// The background color of the container in the opened state.
  /// If null, defaults to the theme's surface color.
  final Color? openedColor;

  /// The background color of the container in the closed state.
  /// If null, defaults to the theme's surface color.
  final Color? closedColor;

  /// The shape of the container in the opened state.
  /// If null, the container will have no specific shape.
  final ShapeBorder? openedShape;

  /// The shape of the container in the closed state.
  /// If null, the container will have no specific shape.
  final ShapeBorder? closedShape;

  /// Called when the container transitions from opened back to closed state.
  ///
  /// This callback provides an opportunity to handle data or perform cleanup
  /// when the expanded view is dismissed.
  final HeroContianerClosedCallback? onClosed;

  /// The elevation of the container in the opened state.
  final double openedElevation;

  /// The elevation of the container in the closed state.
  final double closedElevation;

  /// How the image should be inscribed into the space allocated during
  /// the opened state of the transition.
  final BoxFit openedFit;

  /// How the image should be inscribed into the space allocated during
  /// the closed state of the transition.
  final BoxFit closedFit;

  /// How to align the image within its bounds during the opened state.
  final AlignmentGeometry openedAlignemnt;

  /// How to align the image within its bounds during the closed state.
  final AlignmentGeometry closedAlignment;

  /// The duration of the transition animation.
  final Duration transitionDuration;

  /// The curve used for the transition animation.
  final Curve transitionCurve;

  /// A custom builder for the widget shown during the snapshot transition.
  ///
  /// This function receives the captured snapshots as [fromWidget] and [toWidget]
  /// parameters, allowing custom blending or crossfade effects between the images.
  /// If null, a default crossfade transition is used.
  final HeroContianerFlightShuttleBuilder? flightShuttleBuilder;

  /// Builder for the widget displayed in the opened/expanded state.
  ///
  /// This widget is typically a full-screen view or detailed content
  /// that the user navigates to after tapping the closed state.
  final WidgetBuilder openedBuilder;

  /// Builder for the widget displayed in the closed/collapsed state.
  ///
  /// This builder receives an [action] callback that should be called
  /// (typically in response to a tap) to trigger the transition to
  /// the opened state.
  final HeroContainerBuilder closedBuilder;

  @override
  State<HeroContainer> createState() => _HeroContainerState();
}

class _HeroContainerState extends State<HeroContainer> {
  late final HeroContainerController controller = HeroContainerController(
    fromKey: GlobalKey(debugLabel: "fromWidget"),
    toKey: GlobalKey(debugLabel: "toWidget"),
    builder: widget.openedBuilder,
  );

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: controller.fromKey,
      child: ListenableBuilder(
        listenable: controller.statusNotifier,
        builder: (context, child) {
          return Visibility(
            visible: controller.status == HeroContainerStatus.idle,
            maintainSize: true,
            maintainState: true,
            maintainAnimation: true,
            child: Material(
              animationDuration: Duration.zero,
              elevation: widget.openedElevation,
              color: widget.closedColor,
              shape: widget.closedShape,
              child: child!,
            ),
          );
        },
        child: widget.closedBuilder(context, _openContainer),
      ),
    );
  }

  void _openContainer() {
    HeroContainerOverlay.push(
      context: context,
      controller: controller,
      openedColor: widget.openedColor,
      closedColor: widget.closedColor,
      openedShape: widget.openedShape,
      closedShape: widget.closedShape,
      openedElevation: widget.openedElevation,
      closedElevation: widget.closedElevation,
      openedFit: widget.openedFit,
      closedFit: widget.closedFit,
      openedAlignemnt: widget.openedAlignemnt,
      closedAlignment: widget.closedAlignment,
      transitionDuration: widget.transitionDuration,
      transitionCurve: widget.transitionCurve,
      onClosed: widget.onClosed,
      flightShuttleBuilder: widget.flightShuttleBuilder,
    );
  }
}
