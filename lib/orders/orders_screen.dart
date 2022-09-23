import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local/orders/orders_cubit.dart';
import 'package:local/widgets/order_list_item.dart';
import 'package:local/widgets/order_mini.dart';

import '../generated/l10n.dart';
import '../routes.dart';
import '../theme/dimens.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OrdersCubit, OrdersState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(S.of(context).orders_title),
          ),
          body: ListView.separated(
            itemCount: state.orders.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    Navigator.of(context).pushNamed(Routes.orderDetails,
                        arguments: state.orders[index]);
                  },
                  child: OrderListItem(order: state.orders[index]));
            },
            separatorBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: Dimens.defaultPadding, vertical: 8),
                child: Container(
                  height: 1,
                  color: Colors.black.withOpacity(0.1),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
