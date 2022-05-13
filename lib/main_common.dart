import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:track_star/Plans/plans_provider.dart';
import 'package:track_star/User/user_provider.dart';
import 'package:track_star/router_delegate.dart';
import 'Login/auth_service.dart';
import 'config/app_config.dart';

void mainCommon() async {
  WidgetsFlutterBinding.ensureInitialized();

  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  String currentVersion = packageInfo.version;

  UserSettings? settings = await UserSettingsProvider.get();
  String? userVersion = settings?.appVersion;

  if (currentVersion == '1.1.0') {
    // Save plans to firebase with updated 'planType'
    var plans = await PlansProvider.getPlans();
    for (var plan in plans) {
      plan.savePlanUpdate();
    }
  }

  if (userVersion == '0' || userVersion != currentVersion) {
    print('Updating version from $userVersion to $currentVersion');
    settings?.setVersion(currentVersion);
    settings?.save();
  }
}

class TrackStar extends StatelessWidget {
  const TrackStar({Key? key, required this.authService}) : super(key: key);

  final AuthService authService;

  @override
  Widget build(BuildContext context) {
    var config = AppConfig.of(context);
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: _buildApp(config?.appDisplayName)
    );
  }

  Widget _buildApp(String? appName) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Router(routerDelegate: AppRouterDelegate(authService: authService)),
      title: appName ?? 'TrackStar',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Colors.black,
          secondary: const Color.fromRGBO(251, 244, 244, 1)
        ),
        textTheme: const TextTheme(
          subtitle2: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold)
        ),
      ),
    );
  }
}
