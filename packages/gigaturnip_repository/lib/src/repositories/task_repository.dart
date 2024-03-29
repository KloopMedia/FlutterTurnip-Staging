import 'package:gigaturnip_api/gigaturnip_api.dart' as api;
import 'package:gigaturnip_repository/gigaturnip_repository.dart';
import 'package:local_database/local_database.dart' as db;

abstract class TaskRepository extends GigaTurnipRepository<Task> {
  final api.GigaTurnipApiClient _gigaTurnipApiClient;
  final int campaignId;

  TaskRepository({
    required api.GigaTurnipApiClient gigaTurnipApiClient,
    required this.campaignId,
    super.limit,
  }) : _gigaTurnipApiClient = gigaTurnipApiClient;

  List<Task> parseData(List<api.Task> data) {
    return data.map(Task.fromApiModel).toList();
  }
}

class AllTaskRepository extends TaskRepository {
  AllTaskRepository({
    required super.gigaTurnipApiClient,
    required super.campaignId,
    super.limit,
  });

  @override
  Future<api.PaginationWrapper<Task>> fetchAndParseData({Map<String, dynamic>? query}) async {
    try {
      fetchAllTaskStages();
      final data = await _gigaTurnipApiClient.getUserRelevantTasks(query: {
        'stage__chain__campaign': campaignId,
        ...?query,
      });
      final parsed = parseData(data.results);

      for (final item in parsed) {
        final entity = item.toDB();
        db.LocalDatabase.insertTask(entity);
      }

      return data.copyWith<Task>(results: parsed);
    } catch (e) {
      print(e);
      final wrapper = await db.LocalDatabase.getTasks(campaignId, limit: limit, offset: query?['offset']);
      final results = wrapper['results'] as List<Map<String, dynamic>>;
      final parsed = results.map(Task.fromJson).toList();
      return api.PaginationWrapper(count: wrapper['count'], results: parsed);
    }
  }

  void fetchAllTaskStages() async {
    try {
      final data = await _gigaTurnipApiClient.getAvailableTaskStages(
        query: {'chain__campaign': campaignId, 'limit': 1000},
      );

      final parsed = data.results.map(TaskStageDetail.fromApiModel).toList();
      for (final item in parsed) {
        final entity = item.toDB();
        db.LocalDatabase.insertTaskStage(entity);
      }
    } catch (e) {
      print('FETCHING ALL TASK STAGES ERROR $e');
    }

  }
}

class ClosedTaskRepository extends TaskRepository {
  ClosedTaskRepository({required super.gigaTurnipApiClient, required super.campaignId});

  @override
  Future<api.PaginationWrapper<Task>> fetchAndParseData({Map<String, dynamic>? query}) async {
    final data = await _gigaTurnipApiClient.getUserRelevantTasks(query: {
      'complete': true,
      'stage__chain__campaign': campaignId,
      ...?query,
    });
    return data.copyWith<Task>(results: parseData(data.results));
  }
}

class OpenTaskRepository extends TaskRepository {
  OpenTaskRepository({required super.gigaTurnipApiClient, required super.campaignId});

  @override
  Future<api.PaginationWrapper<Task>> fetchAndParseData({Map<String, dynamic>? query}) async {
    final data = await _gigaTurnipApiClient.getUserRelevantTasks(query: {
      'complete': false,
      'stage__chain__campaign': campaignId,
      ...?query,
    });
    return data.copyWith<Task>(results: parseData(data.results));
  }
}

class AvailableTaskRepository extends TaskRepository {
  final int stageId;

  AvailableTaskRepository({
    required super.gigaTurnipApiClient,
    required super.campaignId,
    required this.stageId,
  });

  @override
  Future<api.PaginationWrapper<Task>> fetchAndParseData({Map<String, dynamic>? query}) async {
    final data = await _gigaTurnipApiClient.getUserSelectableTasks(
      query: {
        'stage': stageId,
        'stage__chain__campaign': campaignId,
        ...?query,
      },
    );
    return data.copyWith<Task>(results: parseData(data.results));
  }

  Future<void> requestAssignment(int id) async {
    return _gigaTurnipApiClient.requestTask(id);
  }
}

class CreatableTaskRepository extends GigaTurnipRepository<TaskStage> {
  final api.GigaTurnipApiClient _gigaTurnipApiClient;
  final int campaignId;
  final bool? isProactive;

  CreatableTaskRepository({
    required api.GigaTurnipApiClient gigaTurnipApiClient,
    required this.campaignId,
    this.isProactive,
  }) : _gigaTurnipApiClient = gigaTurnipApiClient;

  @override
  Future<api.PaginationWrapper<TaskStage>> fetchAndParseData({Map<String, dynamic>? query}) async {
    final String? stageType;
    if (isProactive != null) {
      stageType = isProactive! ? "PR" : "AC";
    } else {
      stageType = null;
    }

    final data = await _gigaTurnipApiClient.getUserRelevantTaskStages(
      query: {
        'chain__campaign': campaignId,
        'stage_type': stageType,
        ...?query,
      },
    );

    return data.copyWith<TaskStage>(results: parseData(data.results));
  }

  List<TaskStage> parseData(List<api.TaskStage> data) {
    return data.map(TaskStage.fromApiModel).toList();
  }

  Future<int> createTask(int id) async {
    final response = await _gigaTurnipApiClient.createTaskFromStageId(id);
    return response.id;
  }
}

class SelectableTaskStageRepository extends GigaTurnipRepository<TaskStage> {
  final api.GigaTurnipApiClient _gigaTurnipApiClient;
  final int campaignId;

  SelectableTaskStageRepository({
    required api.GigaTurnipApiClient gigaTurnipApiClient,
    required this.campaignId,
  }) : _gigaTurnipApiClient = gigaTurnipApiClient;

  @override
  Future<api.PaginationWrapper<TaskStage>> fetchAndParseData({Map<String, dynamic>? query}) async {
    final data = await _gigaTurnipApiClient.getSelectableTaskStages(
      query: {
        'chain__campaign': campaignId,
        ...?query,
      },
    );
    return data.copyWith<TaskStage>(results: parseData(data.results));
  }

  List<TaskStage> parseData(List<api.TaskStage> data) {
    return data.map(TaskStage.fromApiModel).toList();
  }
}
