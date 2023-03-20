import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gigaturnip/src/features/task/view/relevant_task_page.dart';
import 'package:go_router/go_router.dart';

class TaskRelevantRoute {
  static const String name = 'taskRelevant';

  static String path = "/campaign/:cid/task/relevant";

  final GlobalKey<NavigatorState> parentKey;
  final FutureOr<String?> Function(BuildContext context, GoRouterState state)? redirect;

  TaskRelevantRoute({required this.parentKey, this.redirect});

  GoRoute get route {
    return GoRoute(
      parentNavigatorKey: parentKey,
      name: name,
      path: path,
      redirect: redirect,
      builder: (BuildContext context, GoRouterState state) {
        final id = state.params['cid'];
        if (id == null) {
          return const Text('Unknown Page');
        }
        return RelevantTaskPage(
          campaignId: int.parse(id),
        );
      },
    );
  }
}
