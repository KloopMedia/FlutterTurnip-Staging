import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gigaturnip/src/features/app/app.dart';
import 'package:gigaturnip/src/features/tasks/constants/status.dart';
import 'package:gigaturnip/src/features/tasks/features/list_tasks/cubit/index.dart';
import 'package:gigaturnip/src/features/tasks/features/list_tasks/view/index.dart';
import 'package:gigaturnip/src/utilities/dialogs/error_dialog.dart';
import 'package:gigaturnip/src/widgets/lists/generic_list_view.dart';
import 'package:gigaturnip_repository/gigaturnip_repository.dart';

class TasksView extends StatefulWidget {
  const TasksView({Key? key}) : super(key: key);

  @override
  State<TasksView> createState() => _TasksViewState();
}

class _TasksViewState extends State<TasksView> {
  @override
  initState() {
    context.read<TasksCubit>().initialize();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(createTasksRoute);
            },
            icon: const Icon(Icons.add),
          ),
          IconButton(
            key: const Key('homePage_logout_iconButton'),
            icon: const Icon(Icons.exit_to_app),
            onPressed: () => context.read<AppBloc>().add(AppLogoutRequested()),
          )
        ],
      ),
      body: BlocConsumer<TasksCubit, TasksState>(
        listener: (context, state) {
          if (state.status == TasksStatus.error) {
            showErrorDialog(
              context,
              state.errorMessage ?? 'An error occurred while fetching tasks',
            );
          }
        },
        builder: (context, state) {
          if (state.status == TasksStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return GenericListView<Task>(
            items: state.tasks,
            onRefresh: () {
              context.read<TasksCubit>().refresh();
            },
            onTap: (task) {
              context.read<AppBloc>().add(AppSelectedTaskChanged(task));
              Navigator.of(context).pushNamed(createTasksRoute);
            },
          );
        },
      ),
      bottomNavigationBar: BlocBuilder<TasksCubit, TasksState>(
        builder: (context, state) {
          return TasksBottomNavigationBar(
            index: state.tabIndex,
            onTap: (index) {
              context.read<TasksCubit>().onTabChange(index);
            },
          );
        },
      ),
    );
  }
}