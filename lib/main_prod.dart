import 'package:flutter/cupertino.dart';
import 'package:track_star/config/firebase_options_prod.dart';
import 'Login/auth_service.dart';
import 'config/app_config.dart';
import 'main_common.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  var firebaseOptions = DefaultFirebaseOptions.currentPlatform;
  var authService = AuthService();
  await authService.init(firebaseOptions);

  var configuredApp = AppConfig(
    appDisplayName: "TrackStar",
    firebaseOptions: DefaultFirebaseOptions.currentPlatform,
    child: TrackStar(authService: authService),
  );

  mainCommon();

  runApp(configuredApp);
}
