import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:at_commons/at_commons.dart';
import 'package:at_contact/at_contact.dart';
import 'package:atsign_events/models/event_notification.dart';
import 'package:atsign_location/location_modal/location_notification.dart';
// import 'package:atsign_events/models/event_notification.dart';
import 'package:atsign_location_app/common_components/dialog_box/share_location_notifier_dialog.dart';
import 'package:atsign_location_app/common_components/provider_callback.dart';
import 'package:atsign_location_app/models/location_notification.dart';
import 'package:atsign_location_app/models/message_notification.dart';
import 'package:atsign_location_app/services/client_sdk_service.dart';
import 'package:atsign_location_app/services/nav_service.dart';
import 'package:atsign_location_app/utils/constants/constants.dart';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_lookup/src/connection/outbound_connection.dart';
import 'package:atsign_location_app/utils/constants/texts.dart';
import 'package:atsign_location_app/view_models/event_provider.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

class BackendService {
  static final BackendService _singleton = BackendService._internal();
  BackendService._internal();

  factory BackendService.getInstance() {
    return _singleton;
  }
  AtClientService atClientServiceInstance;
  AtClientImpl atClientInstance;
  String _atsign;
  Function ask_user_acceptance;
  String app_lifecycle_state;
  AtClientPreference atClientPreference;
  bool autoAcceptFiles = false;
  final String AUTH_SUCCESS = "Authentication successful";
  String get currentAtsign => _atsign;
  OutboundConnection monitorConnection;
  Directory downloadDirectory;

  Future<bool> onboard({String atsign}) async {
    atClientServiceInstance = AtClientService();
    if (Platform.isIOS) {
      downloadDirectory =
          await path_provider.getApplicationDocumentsDirectory();
    } else {
      downloadDirectory = await path_provider.getExternalStorageDirectory();
    }

    final appSupportDirectory =
        await path_provider.getApplicationSupportDirectory();
    print("paths => $downloadDirectory $appSupportDirectory");
    String path = appSupportDirectory.path;
    atClientPreference = AtClientPreference();

    atClientPreference.isLocalStoreRequired = true;
    atClientPreference.commitLogPath = path;
    atClientPreference.syncStrategy = SyncStrategy.IMMEDIATE;
    atClientPreference.rootDomain = MixedConstants.ROOT_DOMAIN;
    atClientPreference.hiveStoragePath = path;
    atClientPreference.downloadPath = downloadDirectory.path;
    atClientPreference.outboundConnectionTimeout = MixedConstants.TIME_OUT;
    var result = await atClientServiceInstance.onboard(
        atClientPreference: atClientPreference,
        atsign: atsign,
        namespace: 'arrive');
    atClientInstance = atClientServiceInstance.atClient;
    return result;
  }

  ///Fetches atsign from device keychain.
  Future<String> getAtSign() async {
    return await atClientServiceInstance.getAtSign();
  }

  // ///Fetches privatekey for [atsign] from device keychain.
  Future<String> getPrivateKey(String atsign) async {
    return await atClientServiceInstance.getPrivateKey(atsign);
  }

  ///Fetches publickey for [atsign] from device keychain.
  Future<String> getPublicKey(String atsign) async {
    return await atClientServiceInstance.getPublicKey(atsign);
  }

  Future<String> getAESKey(String atsign) async {
    return await atClientServiceInstance.getAESKey(atsign);
  }

  Future<Map<String, String>> getEncryptedKeys(String atsign) async {
    return await atClientServiceInstance.getEncryptedKeys(atsign);
  }

  // startMonitor needs to be called at the beginning of session
  // called again if outbound connection is dropped
  Future<bool> startMonitor() async {
    _atsign = await getAtSign();
    String privateKey = await getPrivateKey(_atsign);
    monitorConnection =
        await atClientInstance.startMonitor(privateKey, fnCallBack);
    print("Monitor started");
    return true;
  }

  fnCallBack(var response) async {
    response = response.replaceFirst('notification:', '');
    var responseJson = jsonDecode(response);
    var value = responseJson['value'];
    var notificationKey = responseJson['key'];
    print('fn call back:${response} ');
    var fromAtSign = responseJson['from'];
    var atKey = notificationKey.split(':')[1];
    var decryptedMessage = await atClientInstance.encryptionService
        .decrypt(value, fromAtSign)
        .catchError((e) => print("error in get ${e} ${e}"));
    if (atKey.toString().contains(AllText().MSG_NOTIFY)) {
      MessageNotificationModel msg =
          MessageNotificationModel.fromJson(jsonDecode(decryptedMessage));
      print('recieved notification ==>$msg');
    } else if (atKey.toString().contains(AllText().LOCATION_NOTIFY)) {
      LocationNotificationModel msg =
          LocationNotificationModel.fromJson(jsonDecode(decryptedMessage));
      print('recieved notification ==>$msg');
    } else if (atKey.toString().contains(AllText().EVENT_NOTIFY)) {
      print(jsonDecode(decryptedMessage));
      EventNotificationModel msg =
          EventNotificationModel.fromJson(jsonDecode(decryptedMessage));
      print('recieved notification ==>$msg');
      showMyDialog(msg, fromAtSign);
    } else if (atKey.toString().contains('createevent')) {
      print('decrypted message:${decryptedMessage}');
      print(jsonDecode(decryptedMessage));
      EventNotificationModel eventData =
          EventNotificationModel.fromJson(jsonDecode(decryptedMessage));
      print('recieved notification ==>${eventData.isUpdate}');
      if (eventData.isUpdate != null && eventData.isUpdate == false) {
        showMyDialog(eventData, fromAtSign);
      } else {
        mapUpdatedDataToWidget(eventData);
      }
    } else if (atKey.toString().contains('eventacknowledged')) {
      print(jsonDecode(decryptedMessage));
      EventNotificationModel msg =
          EventNotificationModel.fromJson(jsonDecode(decryptedMessage));
      print('acknowledged event received ==>$msg');
      createEventAcknowledge(msg, atKey);
    }
  }

  Future<void> showMyDialog(
      EventNotificationModel eventData, String fromAtSign) async {
    String userName, inviteCount;
    userName = fromAtSign;
    // inviteCount = eventData.contactList.length.toString();
    return showDialog<void>(
      context: NavService.navKey.currentContext,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return ShareLocationNotifierDialog(eventData, userName: userName);
      },
    );
  }

  createEventAcknowledge(
      EventNotificationModel acknowledgedEvent, String atKey) async {
    String eventId = atKey.split('eventacknowledged-')[1].split('@')[0];
    print(
        'acknowledged notification received:${acknowledgedEvent} , key:${atKey} , ${eventId}');

    List<String> response = await atClientInstance.getKeys(
      regex: 'createevent-$eventId',
      // sharedBy: '@test_ga3',
      // sharedWith: '@test_ga3',
    );

    AtKey key = AtKey.fromString(response[0]);
    print('key:${key} , responses:${response}');

    AtValue value = await atClientInstance.get(key).catchError(
        (e) => print("error in get ${e.errorCode} ${e.errorMessage}"));

    EventNotificationModel msg =
        EventNotificationModel.fromJson(jsonDecode(value.value));

    print('members: ${msg.group.members}');
    print('members: ${acknowledgedEvent.group.members}');

    acknowledgedEvent.isUpdate = true;
    var notification = EventNotificationModel.convertEventNotificationToJson(
        acknowledgedEvent);

    print('notification:$notification');

    var result = await atClientInstance.put(key, notification);
    if (result is bool && result == true)
      mapUpdatedDataToWidget(acknowledgedEvent);
    print('acknowledgement received:$result');
  }

  mapUpdatedDataToWidget(EventNotificationModel eventData) {
    providerCallback<EventProvider>(NavService.navKey.currentContext,
        task: (t) => t.mapUpdatedEventDataToWidget(eventData),
        showLoader: false,
        taskName: (t) => t.MAP_UPDATED_EVENTS,
        onSuccess: (t) {});
  }

  sendMessage() async {
    AtKey atKey = AtKey()
      ..metadata = Metadata()
      ..metadata.ttr = -1
      // ..metadata.ttr = 10
      ..key = "${AllText().MSG_NOTIFY}/${DateTime.now()}"
      // ..key = "${AllText().LOCATION_NOTIFY}}"
      ..sharedWith = '@baila82brilliant';
    print('atKey: ${atKey.metadata}');

    var notification = json.encode({
      'content': 'Hi..',
      'acknowledged': 'false',
      'timeStamp': DateTime.now().toString()
    });
    // var notification = json.encode({
    //   'lat': '12',
    //   'long': '10'
    //   // 'timeStamp': DateTime.now().toString()
    // });
    var result = await atClientInstance.put(atKey, notification);
    print('send msg result:$result');
  }

  getAllNotificationKeys() async {
    atClientInstance =
        ClientSdkService.getInstance().atClientServiceInstance.atClient;
    List<String> response = await atClientInstance.getKeys(
      regex: '1611145615767065',
      // sharedBy: '@test_ga3',
      // sharedWith: '@test_ga3',
    );
    print('keys:${response}');
    print('sharedBy:${response[0]}, ${response[0].contains('cached')}');

    AtKey key = AtKey.fromString(response[0]);
    print('key :${key} ');

    AtValue result = await atClientInstance.get(key).catchError(
        (e) => print("error in get ${e.errorCode} ${e.errorMessage}"));
    print('result - ${result.value}');

    EventNotificationModel msg =
        EventNotificationModel.fromJson(jsonDecode(result.value));

    print(
        'EventNotificationModel msg:${msg.group.name},members: ${msg.group.members}');
  }

  updateNotification() async {
    List<String> response = await atClientInstance.getKeys(
      regex: '1610602925484075',
    );
    print('response:${response}, ${response.length}');
    AtKey key0 = AtKey.fromString(response[0]);
    AtKey key1 = AtKey.fromString(response[1]);
    print('key0 :${key0} ,key1: ${key1}');

    // var result =
    //     await atClientInstance.put(key, json.encode({'changed': 'value2'}));
    // print('update result:${result}');
  }
}
