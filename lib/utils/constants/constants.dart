class MixedConstants {
  // static const String WEBSITE_URL = 'https://staging.atsign.wtf/';
  static const String WEBSITE_URL = 'https://atsign.com/';

  // for local server
  static const String ROOT_DOMAIN = 'test.do-sf2.atsign.zone';
  // for staging server
  // static const String ROOT_DOMAIN = 'root.atsign.wtf';
  // for production server
  // static const String ROOT_DOMAIN = 'root.atsign.org';

  static const String TERMS_CONDITIONS = 'https://atsign.com/terms-conditions/';
  // static const String PRIVACY_POLICY = 'https://atsign.com/privacy-policy/';
  static const String PRIVACY_POLICY =
      "https://atsign.com/apps/atmosphere/atmosphere-privacy/";

  // the time to await for file transfer acknowledgement in milliseconds
  static const int TIME_OUT = 60000;

  static List<String> startTimeOptions = [
    '2 hours before the event',
    '60 hours before the event',
    '30 hours before the event'
  ];

  static List<String> endTimeOptions = [
    '10 mins after I reach the venue',
    'After everyone’s at the venue',
    'At the end of the day'
  ];
}
