import 'package:flutter/material.dart';
import 'package:shop_app/providers/products.dart';
import 'package:provider/provider.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key});

  static const routeName = '/product-detail';

  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context)!.settings.arguments as String;

    final loadedProduct = Provider.of<Products>(
      context,
      listen: false,
    ).findById(productId);

    return Scaffold(
      // appBar: AppBar(
      //   title: Text(loadedProduct.title),
      // ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(loadedProduct.title),
              background: Container(
                width: double.infinity,
                height: 300,
                child: Builder(builder: (context) {
                  return Hero(
                    tag: loadedProduct.id,
                    child: Image.network(
                      loadedProduct.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  );
                }),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Column(
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      'R\$${loadedProduct.price}',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 20,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                      ),
                      width: double.infinity,
                      child: Text(
                        loadedProduct.description,
                        textAlign: TextAlign.center,
                        softWrap: true,
                      ),
                    )
                  ],
                ),
                SizedBox(height: 800),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
