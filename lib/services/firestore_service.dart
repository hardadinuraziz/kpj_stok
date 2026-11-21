import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  Product({
    this.id,
    this.order = 0,
    required this.name,
    required this.added,
    required this.sold,
    required this.buyPrice,
    required this.sellPrice,
    required this.salesByDay,
    required this.salesBySalesman,
    required this.salesmanDiscounts,
    this.discountAmount = 0,
  });

  final String? id;
  final int order;
  final String name;
  int added;
  int sold;
  int buyPrice;
  int sellPrice;
  int discountAmount;
  final Map<int, int> salesByDay;
  final Map<String, Map<String, int>> salesBySalesman;
  final Map<String, int> salesmanDiscounts;

  int get remaining => added - sold;
  int get margin => sellPrice - buyPrice;

  factory Product.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final Map<String, dynamic> data = doc.data() ?? <String, dynamic>{};

    final Map<int, int> parsedSalesByDay = <int, int>{};
    final dynamic rawSalesByDay = data['salesByDay'];
    if (rawSalesByDay is Map) {
      rawSalesByDay.forEach((dynamic key, dynamic value) {
        final int? day = int.tryParse(key.toString());
        if (day != null && value is num) {
          parsedSalesByDay[day] = value.toInt();
        }
      });
    }

    final Map<String, Map<String, int>> parsedSalesBySalesman =
        <String, Map<String, int>>{};
    final dynamic rawSalesBySalesman = data['salesBySalesman'];
    if (rawSalesBySalesman is Map) {
      rawSalesBySalesman.forEach((dynamic salesmanKey, dynamic dateMap) {
        if (dateMap is Map) {
          final Map<String, int> inner = <String, int>{};
          dateMap.forEach((dynamic dateKey, dynamic qty) {
            if (qty is num) {
              inner[dateKey.toString()] = qty.toInt();
            }
          });
          parsedSalesBySalesman[salesmanKey.toString()] = inner;
        }
      });
    }

    final Map<String, int> parsedSalesmanDiscounts = <String, int>{};
    final dynamic rawDiscounts = data['salesmanDiscounts'];
    if (rawDiscounts is Map) {
      rawDiscounts.forEach((dynamic key, dynamic value) {
        if (value is num) {
          parsedSalesmanDiscounts[key.toString()] = value.toInt();
        }
      });
    }

    return Product(
      id: doc.id,
      order: (data['order'] as num?)?.toInt() ?? 0,
      name: data['name'] as String? ?? '',
      added: (data['added'] as num?)?.toInt() ?? 0,
      sold: (data['sold'] as num?)?.toInt() ?? 0,
      buyPrice: (data['buyPrice'] as num?)?.toInt() ?? 0,
      sellPrice: (data['sellPrice'] as num?)?.toInt() ?? 0,
      discountAmount: (data['discountAmount'] as num?)?.toInt() ?? 0,
      salesByDay: parsedSalesByDay,
      salesBySalesman: parsedSalesBySalesman,
      salesmanDiscounts: parsedSalesmanDiscounts,
    );
  }

  Map<String, dynamic> toFirestore() {
    return <String, dynamic>{
      'order': order,
      'name': name,
      'added': added,
      'sold': sold,
      'buyPrice': buyPrice,
      'sellPrice': sellPrice,
      'discountAmount': discountAmount,
      'salesByDay': <String, int>{
        for (final MapEntry<int, int> entry in salesByDay.entries)
          entry.key.toString(): entry.value,
      },
      'salesBySalesman': salesBySalesman,
      'salesmanDiscounts': salesmanDiscounts,
    };
  }
}

class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _productsRef =>
      _db.collection('products');

  DocumentReference<Map<String, dynamic>> get _configRef =>
      _db.collection('meta').doc('config');

  Stream<List<Product>> streamProducts() {
    return _productsRef.orderBy('order').snapshots().map(
      (QuerySnapshot<Map<String, dynamic>> snapshot) {
        return snapshot.docs
            .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                Product.fromFirestore(doc))
            .toList();
      },
    );
  }

  Stream<List<String>> streamSalesmen() {
    return _configRef.snapshots().map(
      (DocumentSnapshot<Map<String, dynamic>> doc) {
        final dynamic raw = doc.data()?['salesmen'];
        if (raw is List) {
          return raw.map((dynamic item) => item.toString()).toList();
        }
        return <String>[];
      },
    );
  }

  Future<void> seedDefaultsIfEmpty({
    required List<Product> defaultProducts,
    required List<String> defaultSalesmen,
  }) async {
    final QuerySnapshot<Map<String, dynamic>> existingProducts =
        await _productsRef.limit(1).get();
    if (existingProducts.docs.isEmpty) {
      final WriteBatch batch = _db.batch();
      for (int i = 0; i < defaultProducts.length; i++) {
        final DocumentReference<Map<String, dynamic>> docRef = _productsRef.doc();
        final Product product = defaultProducts[i];
        final Map<String, dynamic> data = product.toFirestore();
        data['order'] = i + 1;
        batch.set(docRef, data);
      }
      await batch.commit();
    }

    final DocumentSnapshot<Map<String, dynamic>> configDoc =
        await _configRef.get();
    if (!configDoc.exists) {
      await _configRef.set(<String, dynamic>{'salesmen': defaultSalesmen});
    }
  }

  Future<void> addProduct(Product product) async {
    await _productsRef.add(product.toFirestore());
  }

  Future<void> updateProduct(Product product) async {
    if (product.id == null) return;
    await _productsRef.doc(product.id).set(product.toFirestore());
  }

  Future<void> saveSalesmen(List<String> salesmen) async {
    await _configRef.set(<String, dynamic>{'salesmen': salesmen});
  }
}
