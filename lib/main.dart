import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:local/address/address_cubit.dart';
import 'package:local/address/address_screen.dart';
import 'package:local/analytics/analytics.dart';
import 'package:local/auth/register/register_cubit.dart';
import 'package:local/auth/register/register_screen.dart';
import 'package:local/cart/mentions_screen.dart';
import 'package:local/food_details/food_details_cubit.dart';
import 'package:local/food_details/food_details_screen.dart';
import 'package:local/help/help_cubit.dart';
import 'package:local/help/help_screen.dart';
import 'package:local/orders/orders_cubit.dart';
import 'package:local/orders/orders_screen.dart';
import 'package:local/profile/profile_cubit.dart';
import 'package:local/home/home_cubit.dart';
import 'package:local/home/home_screen.dart';
import 'package:local/profile/profile_screen.dart';
import 'package:local/repos/auth_repo.dart';
import 'package:local/repos/cart_repo.dart';
import 'package:local/repos/notifications_repo.dart';
import 'package:local/repos/orders_repo.dart';
import 'package:local/repos/restaurants_repo.dart';
import 'package:local/repos/user_repo.dart';
import 'package:local/restaurant/info/restaurant_info_cubit.dart';
import 'package:local/restaurant/info/restaurant_info_screen.dart';
import 'package:local/restaurant/restaurant_cubit.dart';
import 'package:local/restaurant/restaurant_screen.dart';
import 'package:local/routes.dart';
import 'package:local/settings/notifications/notifications_cubit.dart';
import 'package:local/settings/notifications/notifications_screen.dart';
import 'package:local/settings/settings_cubit.dart';
import 'package:local/settings/settings_screen.dart';
import 'package:local/theme/theme.dart';
import 'package:models/food_model.dart';
import 'package:models/restaurant_model.dart';
import 'package:models/user_order.dart';

import 'address/addresses/addresses_cubit.dart';
import 'address/addresses/addresses_screen.dart';
import 'analytics/metric.dart';
import 'auth/auth_cubit.dart';
import 'auth/auth_screen.dart';
import 'cart/cart_cubit.dart';
import 'cart/cart_screen.dart';
import 'environment/app_config.dart';
import 'generated/l10n.dart';
import 'order/order_cubit.dart';
import 'order/order_screen.dart';

Future<void> main() async {
  final startTime = DateTime.now();
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await AppConfig.init();

  SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.white));

  final analytics = Analytics();
  final authRepo = AuthRepo();
  final restaurantsRepo = RestaurantsRepo();
  final ordersRepo = OrdersRepo();
  final userRepo = UserRepo(restaurantsRepo, ordersRepo);
  final isLoggedIn = await authRepo.isLoggedIn();

  if (isLoggedIn) {
    await userRepo.getUser();
  }

  final finishTime = DateTime.now();
  final appStartDuration = finishTime.difference(startTime).inMilliseconds;
  analytics.logEventWithParams(name: Metric.eventAppStart, parameters: {
    Metric.propertyAppStartDuration: appStartDuration,
    Metric.propertyAppStartLoggedIn: isLoggedIn.toString(),
  });

  runApp(MultiRepositoryProvider(
    providers: [
      RepositoryProvider<Analytics>(
        create: (context) => analytics,
      ),
      RepositoryProvider<AuthRepo>(
        create: (context) => authRepo,
      ),
      RepositoryProvider<UserRepo>(
        create: (context) => userRepo,
      ),
      RepositoryProvider<RestaurantsRepo>(
        create: (context) => restaurantsRepo,
      ),
      RepositoryProvider<CartRepo>(
        create: (context) => CartRepo(userRepo),
      ),
      RepositoryProvider<OrdersRepo>(
        create: (context) => ordersRepo,
      ),
      RepositoryProvider<NotificationsRepo>(
        create: (context) => NotificationsRepo(),
      ),
    ],
    child: MyApp(
      isLoggedIn: isLoggedIn,
    ),
  ));
  FlutterNativeSplash.remove();
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key, required this.isLoggedIn}) : super(key: key);
  final bool isLoggedIn;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Local Bites',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      theme: AppThemeData().appThemeData,
      initialRoute: isLoggedIn ? Routes.home : Routes.auth,
      routes: {
        Routes.auth: (context) => BlocProvider<AuthCubit>(
              create: (context) => AuthCubit(
                RepositoryProvider.of<AuthRepo>(context),
                RepositoryProvider.of<UserRepo>(context),
              ),
              child: const AuthScreen(),
            ),
        Routes.register: (context) => BlocProvider<RegisterCubit>(
              create: (context) => RegisterCubit(
                RepositoryProvider.of<AuthRepo>(context),
                RepositoryProvider.of<UserRepo>(context),
              ),
              child: const RegisterScreen(),
            ),
        Routes.profile: (context) => BlocProvider<ProfileCubit>(
              create: (context) => ProfileCubit(
                RepositoryProvider.of<UserRepo>(context),
              ),
              child: const ProfileScreen(),
            ),
        Routes.home: (context) => BlocProvider<HomeCubit>(
              create: (context) => HomeCubit(
                RepositoryProvider.of<UserRepo>(context),
                RepositoryProvider.of<RestaurantsRepo>(context),
                RepositoryProvider.of<OrdersRepo>(context),
                RepositoryProvider.of<CartRepo>(context),
                RepositoryProvider.of<NotificationsRepo>(context),
                RepositoryProvider.of<Analytics>(context),
              ),
              child: const HomeScreen(),
            ),
        Routes.settings: (context) => BlocProvider<SettingsCubit>(
              create: (context) => SettingsCubit(
                RepositoryProvider.of<AuthRepo>(context),
                RepositoryProvider.of<UserRepo>(context),
              ),
              child: SettingsScreen(),
            ),
        Routes.address: (context) => BlocProvider<AddressCubit>(
              create: (context) => AddressCubit(
                RepositoryProvider.of<UserRepo>(context),
                RepositoryProvider.of<Analytics>(context),
              ),
              child: const AddressScreen(),
            ),
        Routes.addresses: (context) => BlocProvider<AddressesCubit>(
              create: (context) => AddressesCubit(
                RepositoryProvider.of<UserRepo>(context),
                RepositoryProvider.of<Analytics>(context),
              ),
              child: const AddressesScreen(),
            ),
        Routes.cart: (context) => BlocProvider<CartCubit>(
              create: (context) => CartCubit(
                RepositoryProvider.of<CartRepo>(context),
                RepositoryProvider.of<RestaurantsRepo>(context),
                RepositoryProvider.of<UserRepo>(context),
                RepositoryProvider.of<OrdersRepo>(context),
              ),
              child: const CartScreen(),
            ),
        Routes.mentions: (context) => const MentionsScreen(),
        Routes.orders: (context) => BlocProvider<OrdersCubit>(
              create: (context) => OrdersCubit(
                RepositoryProvider.of<OrdersRepo>(context),
              ),
              child: const OrdersScreen(),
            ),
        Routes.restaurantInfo: (context) => BlocProvider<RestaurantInfoCubit>(
              create: (context) => RestaurantInfoCubit(
                RepositoryProvider.of<RestaurantsRepo>(context),
              ),
              child: const RestaurantInfoScreen(),
            ),
        Routes.notifications: (context) => BlocProvider<NotificationsCubit>(
              create: (context) => NotificationsCubit(
                RepositoryProvider.of<NotificationsRepo>(context),
              ),
              child: const NotificationsScreen(),
            ),
        Routes.help: (context) => BlocProvider<HelpCubit>(
              create: (context) => HelpCubit(),
              child: const HelpScreen(),
            ),
      },
      onGenerateRoute: (settings) {
        if (settings.name == Routes.restaurant) {
          return MaterialPageRoute(
            builder: (context) => BlocProvider<RestaurantCubit>(
              create: (context) => RestaurantCubit(
                RepositoryProvider.of<UserRepo>(context),
                RepositoryProvider.of<RestaurantsRepo>(context),
                RepositoryProvider.of<CartRepo>(context),
                settings.arguments as RestaurantModel,
              ),
              child: const RestaurantScreen(),
            ),
          );
        }
        if (settings.name == Routes.foodDetails) {
          return MaterialPageRoute(
            fullscreenDialog: true,
            builder: (context) => BlocProvider<FoodDetailsCubit>(
              create: (context) => FoodDetailsCubit(
                RepositoryProvider.of<RestaurantsRepo>(context),
                RepositoryProvider.of<CartRepo>(context),
                settings.arguments as FoodModel,
              ),
              child: const FoodDetailsScreen(),
            ),
          );
        }
        if (settings.name == Routes.orderDetails) {
          final userOrder = settings.arguments as UserOrder;
          return MaterialPageRoute(
            fullscreenDialog: true,
            builder: (context) => BlocProvider<OrderCubit>(
              create: (context) => OrderCubit(
                RepositoryProvider.of<OrdersRepo>(context),
                RepositoryProvider.of<RestaurantsRepo>(context),
                RepositoryProvider.of<UserRepo>(context),
                userOrder.orderId,
                userOrder.restaurantId,
              ),
              child: const OrderScreen(),
            ),
          );
        }
        return null;
      },
    );
  }
}
