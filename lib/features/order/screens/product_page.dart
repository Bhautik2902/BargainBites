import 'package:bargainbites/features/homepage/models/listing_item_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'package:bargainbites/utils/constants/colors.dart';
import 'package:bargainbites/features/cart/models/cart_model.dart';
import 'package:bargainbites/features/order/controllers/order_controller.dart';

class ProductDetailsPage extends StatefulWidget {
  final ListingItemModel product;
  CartModel? cartModel;

  ProductDetailsPage({super.key, required this.product, required this.cartModel});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  OrderController _orderController = OrderController();
  String buttonText = 'Add To Cart';

  int quantity = 0;
  String des="";

  @override
  void initState() {
    super.initState();
    fetchProductDetail(widget.product.productId);
  }

  Future<String> fetchImageUrl(String productId) async {
    var product = (await FirebaseFirestore.instance
            .collection('CatalogItems')
            .where('productID', isEqualTo: productId)
            .get())
        .docs
        .first;

    String productImage = product['itemImage'];
    return productImage;
  }

  Future<String> getDownloadURL(String gsUrl) async {
    final ref = FirebaseStorage.instance.refFromURL(gsUrl);
    return await ref.getDownloadURL();
  }

  Future<void> fetchProductDetail(String productId) async {
    var detail = (await FirebaseFirestore.instance
        .collection('CatalogItems')
        .where('productID', isEqualTo: productId)
        .get())
    .docs
    .first;

    setState(() {
      des = detail['itemDescription'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: FutureBuilder<String>(
              future: fetchImageUrl(widget.product.productId)
                  .then((productImage) => getDownloadURL(productImage)),
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    height: 300,
                    color: Colors.grey[200],
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (snapshot.hasError) {
                  return Container(
                    height: 300,
                    color: Colors.grey[200],
                    child: Center(child: Icon(Icons.error, color: Colors.red)),
                  );
                } else if (!snapshot.hasData) {
                  return Container(
                    height: 300,
                    color: Colors.grey[200],
                    child: Center(
                        child: Icon(Icons.image, color: Colors.grey[700])),
                  );
                } else {
                  return Image.network(
                    snapshot.data!,
                    height: 300,
                    fit: BoxFit.cover,
                  );
                }
              },
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Container(
              decoration: BoxDecoration(
                color: TColors.primary,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        if (quantity > 0) quantity--;
                      });
                    },
                  ),
                  Text(
                    '$quantity/${widget.product.quantity}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontFamily: "Poppins"),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        if(quantity < widget.product.quantity)
                        quantity++;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 25.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.product.productName,
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Poppins"),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Quantity ${widget.product.quantity}',
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          fontFamily: "Poppins"),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      '\$${widget.product.price}',
                      style: TextStyle(
                          fontSize: 24,
                          color: Colors.green,
                          fontFamily: "Poppins"),
                    ),
                    // Container(
                    //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    //   decoration: BoxDecoration(
                    //     color: Colors.redAccent,
                    //     borderRadius: BorderRadius.circular(8),
                    //   ),
                    //   // child: Text(
                    //   //   '50% OFF',
                    //   //   style: TextStyle(color: Colors.white, fontSize: 14, fontFamily: "Poppins"),
                    //   // ),
                    // ),
                  ],
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 16.0),
            child: Text(
              'Details',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Poppins"),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Text(des,
              style: const TextStyle(
                  fontSize: 14, color: Colors.grey, fontFamily: "Poppins"),
            ),
          ),
          // Padding(
          //   padding:
          //       const EdgeInsets.symmetric(horizontal: 25.0, vertical: 8.0),
          //   child: InkWell(
          //     onTap: () {
          //       // Handle "See More Detail" tap
          //     },
          //     child: const Text(
          //       'See More Detail',
          //       style: TextStyle(
          //           fontSize: 14,
          //           color: TColors.primary,
          //           fontFamily: "Poppins"),
          //     ),
          //   ),
          // ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () async{
                  // print("ONPRESSED_clicked");
                  if (quantity > 0) {
                    // updating the quantity of selected product
                    try {
                      if (widget.cartModel!.itemQuantity.containsKey(widget.product.productId)) {
                        widget.cartModel!.itemQuantity[widget.product.productId] = widget.cartModel!.itemQuantity[widget.product.productId]! + quantity;
                      }
                      else {
                        widget.cartModel!.itemQuantity[widget.product.productId] = quantity;
                        // adding the product in the list
                        widget.cartModel?.items.add(widget.product);
                      }

                      // calculating cart total
                      widget.cartModel?.updateTotal();
                      setState(() {
                        buttonText = 'Add to cart (\$${widget.cartModel?.total.toStringAsFixed(2)})';
                      });
                    }
                    catch (e) {
                      print(e.toString());
                    }

                    if (await _orderController.updateCart(widget.cartModel)) {
                      // print("cart updated successfully!");
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Added to cart'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                    else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Couldn\'t update cart. Try again!'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                  else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Add some quantity'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: Text(
                  buttonText,
                  style: const TextStyle(
                      fontSize: 18, color: Colors.white, fontFamily: "Poppins"),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
