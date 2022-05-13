import 'package:flutter/material.dart';
import 'package:track_star/config/firebase_options_dev.dart';
import 'Login/auth_service.dart';
import 'config/app_config.dart';
import 'main_common.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  var firebaseOptions = DefaultFirebaseOptions.currentPlatform;
  var authService = AuthService();
  await authService.init(firebaseOptions);

  var configuredApp = AppConfig(
    appDisplayName: "TrackStar Dev",
    firebaseOptions: firebaseOptions,
    child: TrackStar(authService: authService),
  );

  mainCommon();

  runApp(configuredApp);
}