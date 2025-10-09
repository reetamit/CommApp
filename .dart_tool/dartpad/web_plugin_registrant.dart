// Flutter web plugin registrant file.
//
// Generated file. Do not edit.
//

// @dart = 2.13
// ignore_for_file: type=lint

import 'package:firebase_auth_web/firebase_auth_web.dart';
import 'package:firebase_core_web/firebase_core_web.dart';
import 'package:firebase_database_web/firebase_database_web.dart';
import 'package:geolocator_web/geolocator_web.dart';
import 'package:package_info_plus/src/package_info_plus_web.dart';
import 'package:permission_handler_html/permission_handler_html.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

void registerPlugins([final Registrar? pluginRegistrar]) {
  final Registrar registrar = pluginRegistrar ?? webPluginRegistrar;
  FirebaseAuthWeb.registerWith(registrar);
  FirebaseCoreWeb.registerWith(registrar);
  FirebaseDatabaseWeb.registerWith(registrar);
  GeolocatorPlugin.registerWith(registrar);
  PackageInfoPlusWebPlugin.registerWith(registrar);
  WebPermissionHandler.registerWith(registrar);
  registrar.registerMessageHandler();
}
