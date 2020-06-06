import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:changepay_demo/ConfigConstants.dart';
import 'package:changepay_demo/OrderContainer.dart';
import 'package:cached_network_image/cached_network_image.dart';


final orderModel = OrdersModel();

class OrdersPage extends StatefulWidget {
  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<Orders
Page> {


  @override
  void initState() {
    // TODO: implement initState
    debugPrint('InitState called');
    orderModel.fetchOrders();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Orders',),),
      body: Material(
        child: ScopedModel<OrdersModel>(
          model: orderModel, child: ScopedModelDescendant<OrdersModel>(
          builder: (context, child, model) {
            if (model.ordersFetched) {
              ///This block is executed if the orders have been fetched
              ///and the orders data structure built successfully
              return SizedBox.expand(child: Container(color: Colors.white,
                child: ListView.builder(shrinkWrap: true,
                  itemCount: model.orderStructure.length * 2,
                  itemBuilder: (context, index) {
                    if (index % 2 == 0) {
                      ///This block is used to build the actual order list item
                      return buildListItem(model.orderStructure[index ~/ 2]);
                    } else {
                      ///This else block is used to insert the padding between
                      ///the order list items.
                      return SizedBox(
                        height: 20,
                        child: Container(
                          color: Color.fromRGBO(248, 248, 248, 1.0),),
                      );
                    }
                  },
                ),
              ),);
            } else {
              ///This part is executed when the orders list isn't fetched
              ///or still being fetched
              return loadingIndicator;
            }
          },),
        ),
      ),
    );
  }
///This is the code for the indicator when orders are being fetched
  Widget get loadingIndicator {
    return SizedBox.expand(
      child: Container(
        color: Colors.white, child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          CircularProgressIndicator(
            strokeWidth: 3.0, backgroundColor: Colors.blue,),
          Padding(padding: EdgeInsets.only(top: 10),
            child: Text('Fetching Orders...', style: TextStyle(
              color: Colors.blue, fontSize: 18,), textAlign: TextAlign.center,
            ),
          ),
        ],),
      ),
      ),
    );
  }

  Widget buildListItem(dynamic orderData) {

    final castedOrderData = orderData as OrdersType;

    return Container(padding: EdgeInsets.only(top: 10,bottom: 15),
      decoration: BoxDecoration(
          boxShadow: [BoxShadow(blurRadius: 5,color: Colors.black12,offset: Offset.zero,)],
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
      ),
      child: Column(children: <Widget>[
        ///This first child is used the build the upper part of the order tile
        ///when has the thumbnail, time, shop name, and amount
        generateOrderOverview(
          shopImageUrl: castedOrderData.logoImageUrl,
          shopName: castedOrderData.shopName,
          dateString: castedOrderData.orderDateTimeString,
          orderId: castedOrderData.orderId,
          viewLine: castedOrderData.cardViewLine,
          orderAmount: castedOrderData.totalOrderCost,
        ),
        ///This is the second child responsible for the expansion tile
        ExpansionTile(
          title: textWidgetGenerator('Order Details',color: Colors.blue,fontSize: 17),children: orderDetailsGenerator(
          itemCosts: castedOrderData.orderItemsPrice,
          itemsName: castedOrderData.orderItemsName,
          totalAmount: castedOrderData.totalOrderCost,
          deliveryCharge: castedOrderData.deliveryCharge,
        ),),
        ///A neat divider line
        separatorRow,
        ///The last part of tile containing the status and action button
        getStatusWidget(orderStatus: castedOrderData.orderStatus),

      ],),
    );
  }

  List<Widget> orderDetailsGenerator({
    List itemCosts, List itemsName, int totalAmount, int deliveryCharge,}) {

    List<Widget> orderDetailsList = [];
    int itemTotal = 0;

    for (var index = 0 ; index < itemsName.length ; index++ ) {

      orderDetailsList.add(itemSpecGenerator(itemsName[index], itemCosts[index]));
      itemTotal += itemCosts[index];

    }

    orderDetailsList.add(paymentLabel);

    final color = Color.fromRGBO(248, 248, 248, 1);

    orderDetailsList.add(itemSpecGenerator('Item Total', itemTotal,color: color));
    orderDetailsList.add(itemSpecGenerator('Additional Charges', totalAmount-deliveryCharge-itemTotal,color: color));
    orderDetailsList.add(itemSpecGenerator('Delivery Charges', deliveryCharge,color: color));
    orderDetailsList.add(separatorRow);
    orderDetailsList.add(itemSpecGenerator('Total Amount', totalAmount,fontColor: Colors.blue,fontSize: 19));
    orderDetailsList.add(supportButton);

    return orderDetailsList;

  }

  Widget get supportButton {

    return Padding(padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.help_outline,color: Colors.black,),
          Padding(padding: EdgeInsets.only(left: 10),child: textWidgetGenerator(
              'Suppport',fontSize: 16, fontWeight: FontWeight.bold,color: Colors.black
          ),)
        ],
      ),
    );
  }

  Widget get paymentLabel {
    return Container(width: double.maxFinite,
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: Color.fromRGBO(248, 248, 248, 1.0),
      ),
      child: Text(
        'Payment Details',
        style: TextStyle(color: Colors.black, fontSize: 20),
      ),
    );
  }

  Widget itemSpecGenerator(String name, int cost, {Color color = Colors.white, double fontSize=17, Color fontColor=Colors.grey}) {
    return Container(color: color,
      child: Padding(padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            textWidgetGenerator(name, fontSize: fontSize, color: fontColor),
            textWidgetGenerator(
                '₹$cost.00', fontSize: fontSize, color: fontColor),
          ],
        ),
      ),
    );
  }

  Widget get separatorRow {

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10,),
      child: Container(height: 0.7,color: Colors.grey[300],),
    );

  }

  Widget getStatusWidget({String orderStatus}) {

    return Row(crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceAround,children: <Widget>[
      getOrderStatus(orderStatus),
      orderButton,

    ],);

  }

  Widget getOrderStatus(String orderStatus) {

    return Padding(padding: EdgeInsets.only(left: 0,right: 25),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,children: <Widget>[
        Icon(Icons.check_circle_outline,color: Colors.green[400],),
        Padding(padding: EdgeInsets.only(left: 10),child: Text(
          orderStatus, style: TextStyle(fontSize: 16, color: Colors.grey),
        ),),
      ],),
    );

  }

  Widget get orderButton {

    return Container(
      padding: EdgeInsets.only(top: 15,bottom: 15,left: 50,right: 10),
      decoration: BoxDecoration(
        color: Color.fromRGBO(66, 141, 211, 1),
        boxShadow: [BoxShadow(color: Colors.grey,blurRadius: 5)],
        borderRadius: BorderRadius.circular(35),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: <Widget>[
        Text('Re-order',style: TextStyle(color: Colors.white),),
        Padding(padding: EdgeInsets.only(left: 20),child: Icon(Icons.arrow_forward_ios,color: Colors.white,size: 20,)),
      ],),
    );

  }

  Widget generateOrderOverview({String shopImageUrl, String shopName, String dateString,
    String orderId, int orderAmount, String viewLine}) {

    final imageSide = MediaQuery.of(context).size.width*0.23;

    return Row(crossAxisAlignment: CrossAxisAlignment.center,mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[

        SizedBox(height: imageSide,width: imageSide,
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [BoxShadow(color: Colors.black45, offset: Offset.zero,blurRadius: 5),],
              borderRadius: BorderRadius.circular(10),
            ),
            child: ClipRRect(clipBehavior: Clip.antiAliasWithSaveLayer,borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(imageUrl: shopImageUrl,fit: BoxFit.cover,placeholder: (_,__)=> CircularProgressIndicator(
                strokeWidth: 1.0,backgroundColor: Colors.blue,
              ),),
            ),
          ),
        ),
        Column(children: <Widget>[
          textWidgetGenerator(shopName,color: Colors.black54,fontSize: 16,fontWeight: FontWeight.bold),
          textWidgetGenerator(dateString),
          textWidgetGenerator('Order Id: $orderId'),
          textWidgetGenerator(viewLine),
        ],),
        textWidgetGenerator('₹$orderAmount.00',fontSize: 18,color: Colors.blue,fontWeight: FontWeight.bold),
      ],
    );

  }

  Widget textWidgetGenerator(String text,{double fontSize=14,Color color=Colors.grey,FontWeight fontWeight = FontWeight.normal} ) {

    return Padding(padding: EdgeInsets.symmetric(vertical: 3),
      child: Text(text,
        style: TextStyle(
          color: color,
          fontWeight: fontWeight,
          fontSize: fontSize,),
        overflow: TextOverflow.ellipsis,
      ),
    );

  }

}

///This is the model which is used for state management, handling the
///fetched status, and responsible for fetching the orders using the API
///and building the orders data structure
class OrdersModel extends Model {

  bool ordersFetched = false;

  List orderStructure = [];

  Future<void> fetchOrders() async {

    Map<String, String> headers = {
      'Content-Type' :UserConstants.contentType,
      'User-Agent' : UserConstants.userAgent,
      'authorization-key' : UserConstants.authKey,
    };

    final body = jsonEncode({
      'phoneNumber': UserConstants.phoneNumber,
    });

    http.Response response = await http.post(
        UserConstants.url, headers: headers,body: body);

    int statusCode = response.statusCode;

    if (statusCode == 200) {

      final responseJson = json.decode(response.body);
      debugPrint('responseJson $responseJson');
      orderStructure = OrderBuilder.getOrderFromJson(responseJson);
      ordersFetched = true;
      notifyListeners();
    }

  }

}