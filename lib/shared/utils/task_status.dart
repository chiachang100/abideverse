import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:abideverse/shared/localization/locale_keys.g.dart';

enum TaskStatus { all, done, pending }

class TaskStatusFilterIcon extends StatelessWidget {
  final TaskStatus status;
  final VoidCallback onTap;

  const TaskStatusFilterIcon({
    super.key,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color? color;

    switch (status) {
      case TaskStatus.all:
        icon = Icons.filter_list;
        color = Colors.grey;
        break;
      case TaskStatus.done:
        icon = Icons.favorite;
        color = Colors.red;
        break;
      case TaskStatus.pending:
        icon = Icons.favorite_border;
        color = null;
        break;
    }

    return IconButton(
      icon: Icon(icon, color: color),
      tooltip: LocaleKeys.showFavorites.tr(),
      onPressed: onTap,
    );
  }
}
