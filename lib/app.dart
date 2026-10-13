import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'core/theme/app_theme.dart';
import 'core/network/token_storage.dart';
import 'core/storage/settings_storage.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/field_repository.dart';
import 'bloc/auth/auth_bloc.dart';
import 'bloc/customer/customer_bloc.dart';
import 'bloc/site/site_bloc.dart';
import 'bloc/note/note_bloc.dart';
import 'bloc/sync/sync_bloc.dart';
import 'bloc/settings/settings_bloc.dart';
import 'bloc/connectivity/connectivity_bloc.dart';

import 'presentation/screens/splash/splash_screen.dart';
import 'presentation/screens/onboarding/onboarding_screen.dart';
import 'presentation/screens/auth/auth_flow_screen.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/settings/settings_screen.dart';
import 'presentation/screens/customer/customer_form_screen.dart';
import 'presentation/screens/site/site_form_screen.dart';
import 'presentation/screens/site/site_list_screen.dart';
import 'presentation/screens/note/note_form_screen.dart';
import 'presentation/screens/customer/customer_detail_screen.dart';
import 'presentation/screens/note/note_list_screen.dart';
import 'presentation/screens/sync/sync_status_screen.dart';
import 'presentation/screens/profile/profile_screen.dart';

class App extends StatelessWidget {
  const App({
    super.key,
    required this.authRepo,
    required this.fieldRepo,
    required this.settings,
    required this.tokenStorage,
  });

  final AuthRepository authRepo;
  final FieldRepository fieldRepo;
  final SettingsStorage settings;
  final TokenStorage tokenStorage;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<FieldRepository>.value(value: fieldRepo),
        RepositoryProvider<SettingsStorage>.value(value: settings),
        RepositoryProvider<TokenStorage>.value(value: tokenStorage),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => AuthBloc(authRepo, settings)),
          BlocProvider(create: (_) => CustomerBloc(fieldRepo)),
          BlocProvider(create: (_) => SiteBloc(fieldRepo)),
          BlocProvider(create: (_) => NoteBloc(fieldRepo)),
          BlocProvider(create: (_) => SyncBloc(fieldRepo)),
          BlocProvider(create: (_) => SettingsBloc(settings)),
          BlocProvider(create: (_) => ConnectivityBloc(Connectivity())),
        ],
        child: BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, settingsState) {
            final themeMode = settingsState is SettingsLoaded
                ? settingsState.themeMode
                : ThemeMode.system;

            return MaterialApp(
              title: 'Field Notes',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeMode,
              home: const AppRoot(),
              routes: appRoutes,
            );
          },
        ),
      ),
    );
  }
}

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(AppStarted());
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is Authenticated) {
              context.read<ConnectivityBloc>().add(ConnectivityStarted());
              context.read<SyncBloc>().add(SyncRequested());
              context.read<CustomerBloc>().add(LoadCustomers());
              context.read<SiteBloc>().add(const LoadSites());
              context.read<NoteBloc>().add(const LoadNotes());
            }
          },
        ),
        BlocListener<ConnectivityBloc, ConnectivityState>(
          listenWhen: (previous, current) => !previous.isOnline && current.isOnline,
          listener: (context, state) {
            final auth = context.read<AuthBloc>().state;
            if (auth is Authenticated) {
              context.read<SyncBloc>().add(SyncRequested());
            }
          },
        ),
      ],
      child: const SplashScreen(),
    );
  }
}

final appRoutes = <String, WidgetBuilder>{
  '/splash': (_) => const SplashScreen(),
  '/onboarding': (_) => const OnboardingScreen(),
  '/auth': (_) => const AuthFlowScreen(),
  '/home': (_) => const HomeScreen(),
  '/settings': (_) => const SettingsScreen(),
  '/customer-form': (_) => const CustomerFormScreen(),
  '/site-form': (_) => const SiteFormScreen(),
  '/site-list': (_) => const SiteListScreen(),
  '/note-form': (_) => const NoteFormScreen(),
  '/customer-detail': (_) => const CustomerDetailScreen(),
  '/note-list': (_) => const NoteListScreen(),
  '/sync-status': (_) => const SyncStatusScreen(),
  '/profile': (_) => const ProfileScreen(),
};
