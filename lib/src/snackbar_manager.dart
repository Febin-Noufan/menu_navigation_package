import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get_it/get_it.dart';

enum SnackBarType { success, failure, alert, normal }

showCustomSnackBar({
  required BuildContext context,
  required String message,
  VoidCallback? onRetry,
  SnackBarType type = SnackBarType.normal,
  int duration = 3000,
  bool autoDismiss = true,
}) {
  // Ensure NotificationManager is registered
  if (!GetIt.I.isRegistered<NotificationManager>()) {
    GetIt.I.registerSingleton<NotificationManager>(NotificationManager());
  }
  GetIt.I<NotificationManager>()
      .showNotification(context, message, type, duration, autoDismiss);
}

Color getSnackBarBackgroundColor(SnackBarType type) {
  switch (type) {
    case SnackBarType.alert:
      return Colors.orange;
    case SnackBarType.failure:
      return Colors.red;
    case SnackBarType.success:
      return Colors.green;
    case SnackBarType.normal:
      return Colors.blue;
  }
}

IconData getSnackBarIcon(SnackBarType type) {
  switch (type) {
    case SnackBarType.alert:
      return Icons.warning_rounded;
    case SnackBarType.failure:
      return Icons.error_rounded;
    case SnackBarType.success:
      return Icons.check_circle_rounded;
    case SnackBarType.normal:
      return Icons.info_rounded;
  }
}

class NotificationManager {
  final List<NotificationData> _notifications = [];
  OverlayEntry? _overlayEntry;

  void showNotification(BuildContext context, String message, SnackBarType type,
      int duration, bool autoDismiss) {
    final overlay = Overlay.of(context);

    final animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: overlay,
    );

    final curvedAnimation = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeInOutCubic,
    );

    final notificationData = NotificationData(
      autoDismiss: autoDismiss,
      message: message,
      backgroundColor: getSnackBarBackgroundColor(type),
      icon: getSnackBarIcon(type),
      animationController: animationController,
      curvedAnimation: curvedAnimation,
      onDismiss: (notification) => _dismissNotification(notification),
    );

    _notifications.add(notificationData);

    if (_overlayEntry == null) {
      _overlayEntry = OverlayEntry(
        builder: (context) => Positioned(
          bottom: 40.0,
          left: 20.0,
          child: Material(
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < _notifications.length; i++) ...[
                  if (i > 0) const Gap(12),
                  AnimatedNotificationWidget(
                    notification: _notifications[i],
                  ),
                ],
              ],
            ),
          ),
        ),
      );
      overlay.insert(_overlayEntry!);
    } else {
      _overlayEntry!.markNeedsBuild();
    }

    animationController.forward();

    Future.delayed(Duration(milliseconds: duration), () {
      if (_notifications.contains(notificationData)) {
        if (autoDismiss) {
          _dismissNotification(notificationData);
        }
      }
    });
  }

  void _dismissNotification(NotificationData notification) {
    notification.animationController.reverse().then((_) {
      _notifications.remove(notification);
      if (_notifications.isEmpty) {
        _overlayEntry?.remove();
        _overlayEntry = null;
      } else {
        _overlayEntry?.markNeedsBuild();
      }
    });
  }
}

class AnimatedNotificationWidget extends StatelessWidget {
  final NotificationData notification;

  const AnimatedNotificationWidget({
    super.key,
    required this.notification,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: notification.curvedAnimation,
      builder: (context, child) {
        final opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: notification.curvedAnimation,
            curve: Curves.easeInOut,
          ),
        );

        final offset =
            Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
                .animate(
          CurvedAnimation(
            parent: notification.curvedAnimation,
            curve: Curves.easeInOut,
          ),
        );

        final scale = Tween<double>(begin: 0.98, end: 1.0).animate(
          CurvedAnimation(
            parent: notification.curvedAnimation,
            curve: Curves.easeInOut,
          ),
        );

        return FadeTransition(
          opacity: opacity,
          child: SlideTransition(
            position: offset,
            child: ScaleTransition(
              scale: scale,
              child: Dismissible(
                key: UniqueKey(),
                direction: DismissDirection.horizontal,
                onDismissed: (direction) =>
                    notification.onDismiss(notification),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(8),
                    color: const Color(0xFF2B2D31),
                    shadowColor: Colors.black.withOpacity(0.2),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 420),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            notification.icon,
                            color: notification.backgroundColor,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Text(
                              notification.message,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    height: 1.4,
                                  ),
                            ),
                          ),
                          if (!notification.autoDismiss) ...[
                            const SizedBox(width: 8),
                            InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () => notification.onDismiss(notification),
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: Icon(
                                  Icons.close,
                                  color: Colors.white.withOpacity(0.7),
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class NotificationData {
  final String message;
  final Color backgroundColor;
  final IconData icon;
  final AnimationController animationController;
  final Animation<double> curvedAnimation;
  final void Function(NotificationData notification) onDismiss;
  final bool autoDismiss;

  NotificationData({
    required this.message,
    required this.autoDismiss,
    required this.icon,
    required this.backgroundColor,
    required this.animationController,
    required this.curvedAnimation,
    required this.onDismiss,
  });
}
