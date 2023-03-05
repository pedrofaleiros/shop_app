import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/products.dart';

import 'product_item.dart';

class ProductsGrid extends StatelessWidget {
  const ProductsGrid({
    super.key,
    required this.showFavoritesOnly,
  });

  final bool showFavoritesOnly;

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(
      context,
      listen: true,
    );

    final products =
        showFavoritesOnly ? productsData.favoriteItems : productsData.items;

    return GridView.builder(
      padding: const EdgeInsets.all(10.0),
      itemCount: products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      //
      itemBuilder: (ctx, index) => ChangeNotifierProvider.value(
        // create: (c) => products[index],
        value: products[index], // .value
        child: ProductItem(
          key: UniqueKey(),
        ),
      ),
    );
  }
}
