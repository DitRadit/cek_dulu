import 'package:flutter/material.dart';

import 'core/app_state.dart';
import 'core/constants.dart';
import 'core/theme.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final state = AppState();
  await state.load();
  runApp(CekDuluApp(state: state));
}

class CekDuluApp extends StatelessWidget {
  const CekDuluApp({super.key, required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: state,
      child: MaterialApp(
        title: kAppName,
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        // Mode Lansia memperbesar teks di seluruh aplikasi.
        builder: (context, child) {
          final senior = AppScope.of(context).senior;
          return MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(senior ? 1.2 : 1.0)),
            child: child!,
          );
        },
        home: const HomeScreen(),
      ),
    );
  }
}
