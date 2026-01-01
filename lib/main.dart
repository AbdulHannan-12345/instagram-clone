import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:flutter_test_app/core/config/supabase_config.dart';
import 'package:flutter_test_app/core/utils/cache_service.dart';
import 'package:flutter_test_app/core/utils/local_storage_service.dart';
import 'package:flutter_test_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_test_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:flutter_test_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_test_app/features/auth/presentation/pages/auth_page.dart';
import 'package:flutter_test_app/features/home/presentation/bloc/post_bloc.dart';
import 'package:flutter_test_app/features/home/presentation/pages/home_page.dart';
import 'package:flutter_test_app/service_locator/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize Supabase
  await supabase.Supabase.initialize(
    url: SupabaseConfig.projectUrl,
    anonKey: SupabaseConfig.publishableKey,
  );

  // Initialize Cache Service
  await CacheService().initialize();

  // Initialize Local Storage (Hive)
  await LocalStorageService.init();

  await setupServiceLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) =>
              getIt<AuthBloc>()..add(const CheckCurrentUserEvent()),
        ),
        BlocProvider<PostBloc>(create: (context) => getIt<PostBloc>()),
      ],
      child: MaterialApp(
        title: 'Instagram Clone',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          scaffoldBackgroundColor: Colors.white,
        ),
        home: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthSignedOut) {
              Navigator.of(context).pushReplacementNamed('/auth');
            }
          },
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthLoading) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              if (state is AuthSuccess) {
                return const HomePage();
              }
              return const AuthPage();
            },
          ),
        ),
        routes: {
          '/auth': (context) => const AuthPage(),
          '/home': (context) => const HomePage(),
        },
      ),
    );
  }
}
