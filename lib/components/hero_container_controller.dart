import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:hero_container/components/hero_container_fragment.dart';
import 'package:hero_container/widgets/hero_container.dart';

/// Status of a [HeroContainer] transition.
enum HeroContainerStatus {
  /// The hero container is not animating.
  idle,

  /// The hero container is currently animating.
  active,
}

/// Controller that manages the snapshot-based transition animation
/// for [HeroContainer] widget.
///
/// This controller captures widget snapshots and manages the transition state
/// between the closed and opened widgets. It handles the creation of
///
/// [HeroContainerFragment]s which contain the captured images and positional
/// information needed for smooth animations.
class HeroContainerController {
  HeroContainerController({
    required this.fromKey,
    required this.toKey,
    required this.builder,
  });

  /// Global key for the closed state widget.
  final GlobalKey fromKey;

  /// Global key for the opened state widget.
  final GlobalKey toKey;

  /// Builder for the opened state widget.
  final WidgetBuilder builder;

  /// Fragment containing the closed state snapshot and position.
  late HeroContainerFragment fromFragment;

  /// Fragment containing the opened state snapshot and position.
  /// Null until the opened widget is rendered and captured.
  HeroContainerFragment? toFragment;

  /// Current status of the hero container transition.
  HeroContainerStatus get status => statusNotifier.value;
  set status(HeroContainerStatus newStatus) {
    statusNotifier.value = newStatus;
  }

  /// Notifier for the current transition status.
  final statusNotifier = ValueNotifier<HeroContainerStatus>(
    HeroContainerStatus.idle,
  );

  /// Captures a widget as an image using its global key.
  ///
  /// Returns a high-resolution image of the widget bounded by
  /// [RenderRepaintBoundary] for smooth animation rendering.
  Future<ui.Image?> captureWidget(BuildContext context, GlobalKey key) async {
    RenderRepaintBoundary boundary =
        key.currentContext!.findRenderObject() as RenderRepaintBoundary;

    // Convert to image with device pixel ratio for high resolution.
    ui.Image image = await boundary.toImage(
      pixelRatio: MediaQuery.of(context).devicePixelRatio,
    );

    return image;
  }

  /// Creates a [HeroContainerFragment] from a widget key.
  ///
  /// Captures the widget's image, global position, and size to create
  /// a fragment that can be used for transition animations.
  Future<HeroContainerFragment> fragmentOf(
    BuildContext context,
    GlobalKey key,
  ) async {
    final ui.Image? capturedImage = await captureWidget(context, key);

    final RenderBox renderBox =
        key.currentContext?.findRenderObject() as RenderBox;
    final Offset globalPosition = renderBox.localToGlobal(Offset.zero);
    final Size intrinsicSize = renderBox.size;

    return HeroContainerFragment(
      capturedImage: capturedImage!,
      offset: globalPosition,
      size: intrinsicSize,
    );
  }
}
