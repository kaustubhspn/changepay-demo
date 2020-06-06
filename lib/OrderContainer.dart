import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

///OrdersType class specifies the structure of the each Order
class OrdersType {

  OrdersType({@required this.additionalCharge, @required this.logoImageUrl, @required this.cardViewLine, @required this.deliveryCharge,
    @required this.orderId, @required this.orderItemsName, @required this.orderItemsPrice, @required this.orderStatus,
    @required this.orderDateTimeString, @required this.shopName, @required this.totalOrderCost});

  final String logoImageUrl;
  final String orderDateTimeString;
  final String orderId;
  final String shopName;
  final String orderStatus;
  final int totalOrderCost;
  final String cardViewLine;
  final int deliveryCharge;
  final int additionalCharge;
  final List<String> orderItemsName;
  final List<int> orderItemsPrice;


}

///OrderBuilder class is used to parse the JSON, and the data structure containing the orders
///details and building the a list of orders

class OrderBuilder {


  static List getOrderFromJson(Map json) {

    List<OrdersType> ordersDataStructure = [];

    final List<dynamic> orders = json['orders'];

    for (Map<String, dynamic> order in orders) {

      final String logoImageUrl = order['displayPicture'];

      final String cardViewLine = order['cardViewLine2'];

      final orderDateTimeString = DateFormat('yyyy-MM-dd, kk:mm').format(DateTime.fromMillisecondsSinceEpoch(

          int.parse(order['placedAt'])).toLocal());

      final String orderId = order['orderOTP'];

      final String shopName = order['shopName'];

      final String orderStatus = order['status'];

      final int totalOrderCost = order['totalOrderCost'].toInt();

      final int deliveryCharge = (order['serviceSpecificData']['DELIVERY_CHARGE'] as double).toInt();

      final int additionalCharge = (order['serviceSpecificData']['PACKING_CHARGE'] as double).toInt();

      debugPrint('Delivery charge $deliveryCharge packing charge $additionalCharge');

      final List cartItems = order['cart']['itemsEnhanced'];

      List<String> orderItemsName = [];

      List<int> orderItemsPrice = [];

      for (var cartItem in cartItems) {

        orderItemsName.add(cartItem['item']['name']);

        orderItemsPrice.add((cartItem['item']['price']).toInt());

      }

      ordersDataStructure.add(OrdersType(
          additionalCharge: additionalCharge,
          logoImageUrl: logoImageUrl,
          cardViewLine: cardViewLine,
          deliveryCharge: deliveryCharge,
          orderId: orderId,
          orderItemsName: orderItemsName,
          orderItemsPrice: orderItemsPrice,
          orderStatus: orderStatus,
          orderDateTimeString: orderDateTimeString,
          shopName: shopName,
          totalOrderCost: totalOrderCost,),
      );

    }

    return ordersDataStructure;

  }

}

