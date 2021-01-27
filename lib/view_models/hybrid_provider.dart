import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:atsign_events/models/event_notification.dart';
import 'package:atsign_location/location_modal/location_notification.dart';
import 'package:atsign_location/service/send_location_notification.dart';
import 'package:atsign_location_app/models/hybrid_notifiation_model.dart';
import 'package:atsign_location_app/services/client_sdk_service.dart';
import 'package:atsign_location_app/view_models/event_provider.dart';
// import 'package:atsign_location_app/view_models/send_location_model.dart';
import 'package:atsign_location_app/view_models/request_location_provider.dart';
import 'package:atsign_location_app/view_models/share_location_provider.dart';
import 'package:flutter/material.dart';

import 'base_model.dart';

class HybridProvider extends RequestLocationProvider {
  HybridProvider();
  AtClientImpl atClientInstance;
  String currentAtSign;
  List<HybridNotificationModel> allHybridNotifications;
  List<LocationNotificationModel> shareLocationData;
  // ignore: non_constant_identifier_names
  String HYBRID_GET_ALL_EVENTS = 'hybrid_get_all_events';
  // ignore: non_constant_identifier_names
  String HYBRID_CHECK_ACKNOWLEDGED_EVENT = 'hybrid_check_acknowledged_event';
  // ignore: non_constant_identifier_names
  String HYBRID_ADD_EVENT = 'hybrid_ADD_EVENT';
  // ignore: non_constant_identifier_names
  String HYBRID_MAP_UPDATED_EVENT_DATA = 'hybrid_map_event_event';
  // ignore: non_constant_identifier_names
  String FIND_ATSIGNS_TO_SHARE_WITH = 'find_atsigns_to_share_with';

  init(AtClientImpl clientInstance) {
    print('hyrbid clientInstance $clientInstance');
    allHybridNotifications = [];
    shareLocationData = [];
    super.init(clientInstance);
  }

  getAllHybridEvents() async {
    setStatus(HYBRID_GET_ALL_EVENTS, Status.Loading);

    await super.getAllEvents();
    await super.getSingleUserLocationSharing();
    await super.getSingleUserLocationRequest();

    allHybridNotifications = [
      ...super.allNotifications,
      ...super.allShareLocationNotifications,
      ...super.allRequestNotifications
    ];

    setStatus(HYBRID_GET_ALL_EVENTS, Status.Done);
    findAtSignsToShareLocationWith();
    // shareLocationData.forEach((element) {
    //   print('to sahre location with:${shareLocationData.ats}');
    // });
    print('share location array:${shareLocationData} ');
    initialiseLacationSharing();
  }

  mapUpdatedData(HybridNotificationModel notification, {bool remove = false}) {
    setStatus(HYBRID_MAP_UPDATED_EVENT_DATA, Status.Loading);
    String newEventDataKeyId = notification.notificationType ==
            NotificationType.Event
        ? notification.eventNotificationModel.key
            .split('createevent-')[1]
            .split('@')[0]
        : notification.locationNotificationModel.key.contains('sharelocation')
            ? notification.locationNotificationModel.key
                .split('sharelocation-')[1]
                .split('@')[0]
            : notification.locationNotificationModel.key
                .split('requestlocation-')[1]
                .split('@')[0];

    for (int i = 0; i < allHybridNotifications.length; i++) {
      if ((allHybridNotifications[i].key.contains(newEventDataKeyId))) {
        if (NotificationType.Event == notification.notificationType) {
          allHybridNotifications[i].eventNotificationModel =
              notification.eventNotificationModel;
        } else {
          if (notification.locationNotificationModel.key
              .contains('sharelocation')) {
            allHybridNotifications[i].locationNotificationModel =
                notification.locationNotificationModel;
          } else {
            if (!remove)
              allHybridNotifications[i].locationNotificationModel =
                  notification.locationNotificationModel;
            else
              allHybridNotifications.remove(allRequestNotifications[i]);
          }
        }
        break;
      }
    }

    setStatus(HYBRID_MAP_UPDATED_EVENT_DATA, Status.Done);
  }

  addNewEvent(HybridNotificationModel notification) async {
    setStatus(HYBRID_ADD_EVENT, Status.Loading);
    HybridNotificationModel tempNotification;
    if (notification.notificationType == NotificationType.Location) {
      if (notification.locationNotificationModel.key
          .contains('sharelocation')) {
        tempNotification =
            await super.addDataToList(notification.locationNotificationModel);
      } else {
        tempNotification = await super
            .addDataToListRequest(notification.locationNotificationModel);
      }
    } else {
      tempNotification =
          await super.addDataToListEvent(notification.eventNotificationModel);
    }
    allHybridNotifications.add(tempNotification);
    setStatus(HYBRID_ADD_EVENT, Status.Done);
  }

  findAtSignsToShareLocationWith() {
    String currentAtsign = ClientSdkService.getInstance()
        .atClientServiceInstance
        .atClient
        .currentAtSign;
    allHybridNotifications.forEach((notification) {
      LocationNotificationModel location = LocationNotificationModel();
      if (notification.notificationType == NotificationType.Event) {
        if (!notification.eventNotificationModel.isCancelled) {
          if (notification.eventNotificationModel.atsignCreator ==
              currentAtsign) {
            location = LocationNotificationModel()
              ..atsignCreator =
                  notification.eventNotificationModel.atsignCreator
              ..isAcknowledgment = true
              ..isAccepted = true
              ..receiver = notification.eventNotificationModel.group.members
                  .elementAt(0)
                  .atSign;
            location = getLocationNotificationData(notification, location);
          } else {
            if (notification.eventNotificationModel.group.members
                        .elementAt(0)
                        .tags['isAccepted'] ==
                    true &&
                notification.eventNotificationModel.group.members
                        .elementAt(0)
                        .tags['isSharing'] ==
                    true &&
                notification.eventNotificationModel.group.members
                        .elementAt(0)
                        .tags['isExited'] ==
                    false) {
              location = LocationNotificationModel()
                ..atsignCreator = notification
                    .eventNotificationModel.group.members
                    .elementAt(0)
                    .atSign
                ..isAcknowledgment = true
                ..isAccepted = true
                ..receiver = notification.eventNotificationModel.atsignCreator;
              location = getLocationNotificationData(notification, location);
            }
          }
        }
      } else if (notification.notificationType == NotificationType.Location) {
        if (notification.locationNotificationModel.isSharing &&
            notification.locationNotificationModel.isAccepted &&
            !notification.locationNotificationModel.isExited) {}
        location = LocationNotificationModel()
          ..atsignCreator = notification.locationNotificationModel.atsignCreator
          ..isAcknowledgment = true
          ..isAccepted = true
          ..receiver = notification.locationNotificationModel.receiver;
        location = getLocationNotificationData(notification, location);
      }
    });
  }

  LocationNotificationModel getLocationNotificationData(
      HybridNotificationModel notification,
      LocationNotificationModel location) {
    if (notification.notificationType == NotificationType.Event) {
      if (notification.eventNotificationModel.event.isRecurring) {
        // for recurring
        if (notification.eventNotificationModel.event.repeatCycle ==
            RepeatCycle.MONTH) {
          // repeat cycle is month
          List<Map<String, dynamic>> months = [];
          for (int i = 1; i <= 12; i++) {
            if (i % notification.eventNotificationModel.event.repeatDuration ==
                0) {
              print(
                  'month matched:${notification.eventNotificationModel.title}');
              months.add(monthsList['$i']);
            }
          }
          print('recurring months: ${months}');
        } else if (notification.eventNotificationModel.event.repeatCycle ==
            RepeatCycle.WEEK) {
          // repeat every week cycle
        }
      } else {
        print(
            'date matching:${dateToString(notification.eventNotificationModel.event.date)} ,${dateToString(DateTime.now())} ');

        if (dateToString(notification.eventNotificationModel.event.date) ==
            dateToString(DateTime.now())) {
          location.from = notification.eventNotificationModel.event.startTime;
          location.to = notification.eventNotificationModel.event.endTime;
          print(
              'adding data to share location: ${notification.eventNotificationModel.title}');
          shareLocationData.add(location);
          return location;
        }
      }
    } else if (notification.notificationType == NotificationType.Location) {
      print(
          'adding data to share location: ${notification.locationNotificationModel.atsignCreator}');
      shareLocationData.add(notification.locationNotificationModel);
      return location;
    }
  }

  initialiseLacationSharing() {
    SendLocationNotification().init(shareLocationData, atClientInstance);
    print('location sending started');
  }
}
