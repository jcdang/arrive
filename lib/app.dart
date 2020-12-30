import 'package:atsign_location_app/routes/routes.dart';
import 'package:atsign_location_app/services/nav_service.dart';
import 'package:atsign_location_app/utils/themes/theme.dart';
import 'package:atsign_location_app/view_models/add_contact_provider.dart';
import 'package:atsign_location_app/view_models/blocked_contact_provider.dart';
import 'package:atsign_location_app/view_models/contact_provider.dart';
import 'package:atsign_location_app/view_models/scan_qr_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'view_models/theme_view_model.dart';

class MyApp extends StatefulWidget {
  final ThemeColor currentTheme;
  MyApp({this.currentTheme});
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider<ThemeProvider>(
          create: (context) => ThemeProvider(themeColor: widget.currentTheme)),
      ChangeNotifierProvider<AddContactProvider>(
          create: (context) => AddContactProvider()),
      ChangeNotifierProvider<ContactProvider>(
          create: (context) => ContactProvider()),
      ChangeNotifierProvider<BlockedContactProvider>(
          create: (context) => BlockedContactProvider()),
    ], child: MaterialAppClass());
  }
}

class MaterialAppClass extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('app dart called');
    return MaterialApp(
      title: 'AtSign Location App',
      debugShowCheckedModeBanner: false,
      initialRoute: SetupRoutes.initialRoute,
      navigatorKey: NavService.navKey,
      theme: Themes.getThemeData(Provider.of<ThemeProvider>(context).getTheme),
      routes: SetupRoutes.routes,
    );
  }
}
