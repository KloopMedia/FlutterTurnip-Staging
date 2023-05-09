import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gigaturnip/extensions/buildcontext/loc.dart';
import 'package:gigaturnip/src/bloc/bloc.dart';
import 'package:gigaturnip/src/theme/index.dart';
import 'package:gigaturnip/src/widgets/app_bar/default_app_bar.dart';
import 'package:gigaturnip/src/widgets/widgets.dart';
import 'package:gigaturnip_api/gigaturnip_api.dart' as api;
import 'package:gigaturnip_repository/gigaturnip_repository.dart';

import '../bloc/campaign_cubit.dart';
import 'available_campaign_view.dart';
import 'user_campaign_view.dart';

class CampaignPage extends StatefulWidget {
  const CampaignPage({Key? key}) : super(key: key);

  @override
  State<CampaignPage> createState() => _CampaignPageState();
}

class _CampaignPageState extends State<CampaignPage> {
  @override
  Widget build(BuildContext context) {
    final isGridView = context.isDesktop || context.isTablet;

    return MultiBlocProvider(
      providers: [
        BlocProvider<SelectableCampaignCubit>(
          create: (context) => CampaignCubit(
            SelectableCampaignRepository(
              gigaTurnipApiClient: context.read<api.GigaTurnipApiClient>(),
              limit: isGridView ? 9 : 10,
            ),
          )..initialize(),
        ),
        BlocProvider<UserCampaignCubit>(
          create: (context) => CampaignCubit(
            UserCampaignRepository(
              gigaTurnipApiClient: context.read<api.GigaTurnipApiClient>(),
              limit: isGridView ? 9 : 10,
            ),
          )..initialize(),
        ),
      ],
      child: const CampaignView(),
    );
  }
}

class CampaignView extends StatelessWidget {
  const CampaignView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SelectableCampaignCubit, RemoteDataState<Campaign>>(
      builder: (context, state) {
        final theme = Theme.of(context).colorScheme;
        final hasAvailableCampaigns = state is RemoteDataLoaded<Campaign> && state.data.isNotEmpty;

        return DefaultTabController(
          length: 2,
          child: SafeArea(
            child: DefaultAppBar(
              title: Text(context.loc.campaigns),
              actions: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
                ),
                FilterButton(
                  onPressed: () {},
                ),
              ],
              bottom: BaseTabBar(
                hidden: !hasAvailableCampaigns,
                width: calculateTabWidth(context),
                border: context.formFactor == FormFactor.mobile
                    ? Border(
                        bottom: BorderSide(
                          color: theme.isLight ? theme.neutralVariant80 : theme.neutralVariant40,
                          width: 2,
                        ),
                      )
                    : null,
                tabs: [
                  Tab(text: context.loc.available_campaigns),
                  Tab(text: context.loc.campaigns),
                ],
              ),
              child: hasAvailableCampaigns
                  ? const TabBarView(
                      children: [
                        AvailableCampaignView(),
                        UserCampaignView(),
                      ],
                    )
                  : const UserCampaignView(),
            ),
          ),
        );
      },
    );
  }
}
