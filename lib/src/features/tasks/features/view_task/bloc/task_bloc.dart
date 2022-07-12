import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:gigaturnip_repository/gigaturnip_repository.dart';

part 'task_event.dart';

part 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final GigaTurnipRepository gigaTurnipRepository;
  Timer? timer;

  TaskBloc({
    required this.gigaTurnipRepository,
    required Task selectedTask,
  }) : super(TaskState.fromTask(selectedTask)) {
    timer = Timer.periodic(const Duration(seconds: 20), (timer) {
      _saveTask(state);
    });

    on<UpdateTaskEvent>(_onUpdateTask);
    on<SubmitTaskEvent>(_onSubmitTask);
    on<ExitTaskEvent>(_onExitTask);
  }

  void _saveTask(Task task) async {
    if (!task.complete) {
      await gigaTurnipRepository.updateTask(state);
    }
  }

  void _onUpdateTask(UpdateTaskEvent event, Emitter<TaskState> emit) {
    emit(state.copyWith(responses: event.formData));
  }

  void _onSubmitTask(SubmitTaskEvent event, Emitter<TaskState> emit) {
    final newState = state.copyWith(responses: event.formData, complete: true);
    _saveTask(newState);
    emit(newState);
  }

  void _onExitTask(ExitTaskEvent event, Emitter<TaskState> emit) {
    _saveTask(state);
  }

  @override
  Future<void> close() {
    timer?.cancel();
    return super.close();
  }
}
