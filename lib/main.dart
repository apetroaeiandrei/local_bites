import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:local/address/address_cubit.dart';
import 'package:local/address/address_screen.dart';
import 'package:local/analytics/analytics.dart';
import 'package:local/cart/mentions_screen.dart';
import 'package:local/food_details/food_details_cubit.dart';
import 'package:local/food_details/food_details_screen.dart';
import 'package:local/orders/orders_cubit.dart';
import 'package:local/orders/orders_screen.dart';
import 'package:local/profile/profile_cubit.dart';
import 'package:local/home/home_cubit.dart';
import 'package:local/home/home_screen.dart';
import 'package:local/profile/profile_screen.dart';
import 'package:local/repos/auth_repo.dart';
import 'package:local/repos/cart_repo.dart';
import 'package:local/repos/orders_repo.dart';
import 'package:local/repos/restaurants_repo.dart';
import 'package:local/repos/user_repo.dart';
import 'package:local/restaurant/restaurant_cubit.dart';
import 'package:local/restaurant/restaurant_screen.dart';
import 'package:local/routes.dart';
import 'package:local/settings/settings_cubit.dart';
import 'package:local/settings/settings_screen.dart';
import 'package:local/theme/theme.dart';
import 'package:models/food_model.dart';
import 'package:models/restaurant_model.dart';
import 'package:models/user_order.dart';

import 'analytics/metric.dart';
import 'auth/auth_cubit.dart';
import 'auth/auth_screen.dart';
import 'cart/cart_cubit.dart';
import 'cart/cart_screen.dart';
import 'firebase_options.dart';
import 'generated/l10n.dart';
import 'order/order_cubit.dart';
import 'order/order_screen.dart';

Future<void> main() async {
  final startTime = DateTime.now();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };


  final analytics = Analytics();
  final authRepo = AuthRepo();
  final userRepo = UserRepo();
  final ordersRepo = OrdersRepo();
  final isLoggedIn = await authRepo.isLoggedIn();
  await userRepo.getUser();

  final finishTime = DateTime.now();
  final appStartDuration = finishTime.difference(startTime).inMilliseconds;
  analytics.logEventWithParams(name: Metric.eventAppStart, parameters: {
    Metric.propertyAppStartDuration: appStartDuration,
    Metric.propertyAppStartLoggedIn: isLoggedIn,
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
        create: (context) => RestaurantsRepo(),
      ),
      RepositoryProvider<CartRepo>(
        create: (context) => CartRepo(userRepo),
      ),
      RepositoryProvider<OrdersRepo>(
        create: (context) => ordersRepo,
      ),
    ],
    child: MyApp(
      isLoggedIn: isLoggedIn,
    ),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key, required this.isLoggedIn}) : super(key: key);
  final bool isLoggedIn;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        // 1
        S.delegate,
        // 2
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
              child: AuthScreen(),
            ),
        Routes.profile: (context) => BlocProvider<ProfileCubit>(
              create: (context) => ProfileCubit(
                RepositoryProvider.of<UserRepo>(context),
              ),
              child: ProfileScreen(),
            ),
        Routes.home: (context) => BlocProvider<HomeCubit>(
              create: (context) => HomeCubit(
                RepositoryProvider.of<UserRepo>(context),
                RepositoryProvider.of<RestaurantsRepo>(context),
                RepositoryProvider.of<OrdersRepo>(context),
                RepositoryProvider.of<CartRepo>(context),
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
              ),
              child: const AddressScreen(),
            ),
        Routes.cart: (context) => BlocProvider<CartCubit>(
              create: (context) => CartCubit(
                RepositoryProvider.of<CartRepo>(context),
                RepositoryProvider.of<RestaurantsRepo>(context),
                RepositoryProvider.of<UserRepo>(context),
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
      },
      onGenerateRoute: (settings) {
        if (settings.name == Routes.restaurant) {
          return MaterialPageRoute(
            builder: (context) => BlocProvider<RestaurantCubit>(
              create: (context) => RestaurantCubit(
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

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
