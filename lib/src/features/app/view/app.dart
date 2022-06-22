import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gigaturnip/src/features/app/app.dart';
import 'package:gigaturnip/src/features/authentication/authentication.dart';
import 'package:gigaturnip/src/features/campaigns/view/campaigns_page.dart';
import 'package:gigaturnip/src/features/home/home.dart';
import 'package:gigaturnip/src/features/tasks/view/tasks_page.dart';
import 'package:gigaturnip_repository/gigaturnip_repository.dart';
import 'package:gigaturnip/src/features/app/routes/routes.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class App extends StatelessWidget {
  const App({
    Key? key,
    required AuthenticationRepository authenticationRepository,
    required GigaTurnipRepository gigaTurnipRepository,
  })  : _authenticationRepository = authenticationRepository,
        _gigaTurnipRepository = gigaTurnipRepository,
        super(key: key);

  final AuthenticationRepository _authenticationRepository;
  final GigaTurnipRepository _gigaTurnipRepository;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthenticationRepository>(
            create: (context) => _authenticationRepository),
        RepositoryProvider<GigaTurnipRepository>(
          create: ((context) => _gigaTurnipRepository),
        )
      ],
      child: BlocProvider<AppBloc>(
        create: (_) => AppBloc(
          authenticationRepository: _authenticationRepository,
          gigaTurnipRepository: _gigaTurnipRepository,
        ),
        child: MaterialApp(
          theme: ThemeData(
            primarySwatch: Colors.purple,
            accentColor: Colors.red,
          ),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: BlocBuilder<AppBloc, AppState>(
            builder: (context, state) {
              if (state.user != null) {
                return const CampaignsPage();
              } else {
                return const LoginPage();
              }
            },
          ),
          routes: {
            campaignsRoute: (context) => const CampaignsPage(),
            tasksRoute: (context) => const TasksPage(),
            createOrUpdateTaskRoute: (context) => const HomePage(),
          },
        ),
      ),
    );
  }
}
