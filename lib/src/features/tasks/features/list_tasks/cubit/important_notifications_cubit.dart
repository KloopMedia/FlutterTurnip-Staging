import 'package:bloc/bloc.dart';
import 'package:gigaturnip_repository/gigaturnip_repository.dart';

part 'important_notifications_state.dart';

class ImportantNotificationsCubit extends Cubit<ImportantNotificationsState> {
  final GigaTurnipRepository gigaTurnipRepository;
  final Campaign selectedCampaign;

  ImportantNotificationsCubit({
    required this.gigaTurnipRepository,
    required this.selectedCampaign,
  }) : super(const ImportantNotificationsInitial([]));

  void getNotifications() async {
    final notifications =
        await gigaTurnipRepository.getNotifications(selectedCampaign.id, false) ?? [];
    emit(ImportantNotificationsLoaded(notifications));
  }

  void onReadNotification(int id) async {
    await gigaTurnipRepository.getOpenNotification(id);
  }

  void getLastTaskNotifications() async {
    final lastTaskNotifications =
        await gigaTurnipRepository.getLastTaskNotifications(selectedCampaign.id);
    final reversedNotifications = lastTaskNotifications.reversed.toList();
    emit(ImportantNotificationsLoaded(reversedNotifications));
  }
}
