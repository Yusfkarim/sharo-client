import 'dart:async';
import 'package:flutter/material.dart';
import 'services/api_service.dart';

void main() {
  runApp(const SharoApp());
}

class SharoApp extends StatelessWidget {
  const SharoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'شاڕۆ | دەربەندیخان',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Bahij',
        primaryColor: const Color(0xFFFF5A36),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF5A36),
          primary: const Color(0xFFFF5A36),
          secondary: const Color(0xFFFF7A00),
        ),
        useMaterial3: true,
      ),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      home: const SharoMainScreen(),
    );
  }
}

class SharoMainScreen extends StatefulWidget {
  const SharoMainScreen({super.key});

  @override
  State<SharoMainScreen> createState() => _SharoMainScreenState();
}

class _SharoMainScreenState extends State<SharoMainScreen> {
  int _currentIndex = 0;
  String currentLocation = "دەربەندیخان - سەنتەری شار";
  int walletBalance = 12500;
  bool isCloudConnected = false;
  String searchQuery = "";
  String selectedCategory = "all";
  String? appliedCoupon;
  int discountAmount = 0;

  List<Map<String, dynamic>> cartItems = [];
  Map<String, dynamic>? activeOrder;
  Timer? _orderTrackerTimer;

  // Locations strictly for Darbandikhan (گەڕەکەکانی دەربەندیخان)
  final List<String> darbandikhanAreas = [
    "دەربەندیخان - سەنتەری شار (ناو بازاڕ)",
    "دەربەندیخان - گەڕەکی سەرسیر",
    "دەربەندیخان - گەڕەکی بیرکێ",
    "دەربەندیخان - گەڕەکی زانکۆ",
    "دەربەندیخان - گەڕەکی شەمێران",
    "دەربەندیخان - بەنداوی دەربەندیخان",
    "دەربەندیخان - گەڕەکی سیروان",
    "دەربەندیخان - گەڕەکی کانی سارد",
    "دەربەندیخان - گەڕەکی شەهیدان",
    "دەربەندیخان - گەڕەکی هۆنراوە",
  ];

  // Visual Category Tiles with Real Photography and Vivid Gradients
  final List<Map<String, dynamic>> categories = [
    {
      "id": "market",
      "name": "شاڕۆ کڕین",
      "sub": "مارکێت و بازاڕ",
      "image": "assets/images/cat_market.jpg",
      "tag": "فرێش",
      "gradient": const [Color(0xFF059669), Color(0xFF10B981)],
      "bgLight": const Color(0xFFECFDF5),
    },
    {
      "id": "food",
      "name": "چێشتخانە و کەباب",
      "sub": "خواردنی گەرم",
      "image": "assets/images/cat_kebab.jpg",
      "tag": "گەرم",
      "gradient": const [Color(0xFFFF5A36), Color(0xFFFF8E53)],
      "bgLight": const Color(0xFFFFF1EE),
    },
    {
      "id": "fish",
      "name": "ماسی بەنداو",
      "sub": "ڕاوکراوی فرێش",
      "image": "assets/images/cat_fish.jpg",
      "tag": "تایبەت",
      "gradient": const [Color(0xFF0284C7), Color(0xFF38BDF8)],
      "bgLight": const Color(0xFFF0F9FF),
    },
    {
      "id": "burger",
      "name": "برگر و فاست فوود",
      "sub": "پیتزا و برگر",
      "image": "assets/images/cat_burger.jpg",
      "tag": "خێرا",
      "gradient": const [Color(0xFFEA580C), Color(0xFFFBA919)],
      "bgLight": const Color(0xFFFFF7ED),
    },
    {
      "id": "sweets",
      "name": "شیرینی و کێک",
      "sub": "باقڵاوە و کێک",
      "image": "assets/images/cat_sweets.jpg",
      "tag": "شیرین",
      "gradient": const [Color(0xFF9333EA), Color(0xFFC084FC)],
      "bgLight": const Color(0xFFFAF5FF),
    },
    {
      "id": "ride",
      "name": "شاڕۆ تەکسی",
      "sub": "تەکسی بەنداو",
      "image": "assets/images/cat_taxi.jpg",
      "tag": "٢٤ کاتژمێر",
      "gradient": const [Color(0xFFD97706), Color(0xFFFBBF24)],
      "bgLight": const Color(0xFFFEFCE8),
    },
    {
      "id": "cargo",
      "name": "بارهەڵگر و بار",
      "sub": "گواستنەوەی کەلوپەل",
      "image": "assets/images/cat_cargo.jpg",
      "tag": "ئەمانەت",
      "gradient": const [Color(0xFF475569), Color(0xFF94A3B8)],
      "bgLight": const Color(0xFFF8FAFC),
    },
    {
      "id": "prizes",
      "name": "خەڵات و دیاری",
      "sub": "داشکاندن و خەڵات",
      "image": "assets/images/cat_gift.jpg",
      "tag": "پاداشت",
      "gradient": const [Color(0xFFE11D48), Color(0xFFFB7185)],
      "bgLight": const Color(0xFFFFF1F2),
    },
  ];

  // Visual Shops with Real Banners and Real Product Thumbnails
  final List<Map<String, dynamic>> shops = [
    {
      "id": "shop-market-1",
      "name": "شاڕۆ کڕین - سوپەرمارکێتی دەربەندیخان",
      "category": "market",
      "rating": 4.95,
      "reviews": 2100,
      "eta": "10-20",
      "fee": 1000,
      "location": "دەربەندیخان - ناو بازاڕ",
      "featuredTag": "کەرەستەی خۆراکی و پێداویستی ڕۆژانە",
      "banner": "assets/images/shop_market_banner.jpg",
      "menu": [
        {"id": "m_g1", "name": "سەبەتەی پێداویستی خۆراکی تەواو", "desc": "پاقلەمەنی، دۆشاوی تەماتە، زەیت، شەکر، چا و ئارد", "price": 18000, "image": "assets/images/item_grocery_box.jpg"},
        {"id": "m_g2", "name": "برنجی کوردی پلە یەک (٥ کگم)", "desc": "برنجی کوردی خەست و ڕۆنی حەیوانی مەحلی", "price": 14000, "image": "assets/images/item_rice_staples.jpg"},
        {"id": "m_g3", "name": "ماست و پەنیر و شیرەمەنی خۆماڵی", "desc": "ماستی مەڕی دەربەندیخان بە تامی سروشتی و پەنیر", "price": 6000, "image": "assets/images/item_dairy.jpg"},
        {"id": "m_g4", "name": "شەربەت و مەستاو و خواردنەوەی فرێش", "desc": "شەربەتی میوەی فرێش و دۆوی خۆماڵی تەزیو", "price": 3000, "image": "assets/images/item_drinks.jpg"},
      ]
    },
    {
      "id": "shop-market-2",
      "name": "شاڕۆ کڕین - میوە و سەوزەی بەنداو",
      "category": "market",
      "rating": 4.92,
      "reviews": 1140,
      "eta": "10-15",
      "fee": 500,
      "location": "دەربەندیخان - شەقامی گشتی بەنداو",
      "featuredTag": "میوە و سەوزەی فرێشی باخەکان",
      "banner": "assets/images/shop_grocery_fresh.jpg",
      "menu": [
        {"id": "m_f1", "name": "سەبەتەی میوەی وەرزی فرێش (٥ کگم)", "desc": "سێو، مۆز، پرتەقاڵ و ترێی پاککراوە و کوالیتی بەرز", "price": 11000, "image": "assets/images/item_fruits.jpg"},
        {"id": "m_f2", "name": "سەوزەی تازەی باخەکانی دەربەندیخان", "desc": "خەیار، تەماتە، بیبەر، کەرەوز و تەڕەتیزەی باخەکان", "price": 4500, "image": "assets/images/item_grocery_box.jpg"},
      ]
    },
    {
      "id": "shop-1",
      "name": "چێشتخانەی کەیف (دەربەندیخان)",
      "category": "food",
      "rating": 4.9,
      "reviews": 840,
      "eta": "15-25",
      "fee": 0,
      "location": "دەربەندیخان - شەقامی گشتی",
      "featuredTag": "گەیاندن لە دەربەندیخان خۆڕاییە",
      "banner": "assets/images/shop_kebab_banner.jpg",
      "menu": [
        {"id": "m1", "name": "کەبابی تایبەتی دەربەندیخان", "desc": "سێ شیش کەبابی بەرخی فرێش بە نانی تیری و تەماتە و بیبەر", "price": 9500, "image": "assets/images/dish_kebab.jpg"},
        {"id": "m2", "name": "قۆزی بەرخی کوردی بە برنج", "desc": "گۆشتی نەرمی کوڵاو بە برنجی کوردی و شلەی پاقلە", "price": 14000, "image": "assets/images/dish_qozy.jpg"},
        {"id": "m3", "name": "شیش تاووقی مەریەنەتکراو", "desc": "سنگی مریشکی برژاو لەسەر خەڵووز بە سۆسی تایبەت", "price": 8500, "image": "assets/images/dish_tikka.jpg"},
      ]
    },
    {
      "id": "shop-2",
      "name": "ماسی بەنداوی دەربەندیخان",
      "category": "fish",
      "rating": 5.0,
      "reviews": 1250,
      "eta": "20-30",
      "fee": 1000,
      "location": "دەربەندیخان - نزیک بەنداو",
      "featuredTag": "ماسی فرێشی ڕاوکراوی بەنداو",
      "banner": "assets/images/shop_fish_banner.jpg",
      "menu": [
        {"id": "m4", "name": "ماسی مسکۆفی گەورە لەسەر خەڵووز", "desc": "ماسی گەورەی دەربەندیخان بە سۆسی نارنج و بەهاراتی کوردی", "price": 18000, "image": "assets/images/dish_masi_tanoor.jpg"},
        {"id": "m5", "name": "ماسی سوورکراوەی بەنداو", "desc": "ماسی فرێش بە پەتاتە، ترشیاتی خۆماڵی و نانی گەرم", "price": 15000, "image": "assets/images/dish_fish_fillet.jpg"},
      ]
    },
    {
      "id": "shop-3",
      "name": "برگرزۆن پرۆ (دەربەندیخان)",
      "category": "burger",
      "rating": 4.8,
      "reviews": 920,
      "eta": "15-20",
      "fee": 1000,
      "location": "دەربەندیخان - گەڕەکی سەرسیر",
      "featuredTag": "فست فوودی تایبەتی شاڕۆ",
      "banner": "assets/images/shop_burger_banner.jpg",
      "menu": [
        {"id": "m6", "name": "دەبڵ سمەش برگر شاڕۆ", "desc": "دوو پەتی گۆشتی ئاڵۆزکراو بە پەنیر چیدەر و سۆسی تایبەت", "price": 8000, "image": "assets/images/dish_smash_burger.jpg"},
        {"id": "m7", "name": "کریسبی چیکن سوپریم", "desc": "سنگی کریسپی سوورکراوە بە کۆڵسڵۆ و فنگەر", "price": 7500, "image": "assets/images/dish_crispy_chicken.jpg"},
      ]
    },
    {
      "id": "shop-6",
      "name": "شیرینی و کێکی شاڕۆ",
      "category": "sweets",
      "rating": 4.88,
      "reviews": 760,
      "eta": "15-25",
      "fee": 1000,
      "location": "دەربەندیخان - گەڕەکی بیرکێ",
      "featuredTag": "شیرینی و بەستەنی فرێش",
      "banner": "assets/images/cat_sweets.jpg",
      "menu": [
        {"id": "m14", "name": "باقڵاوەی فستقی تایبەت (١ کگم)", "desc": "باقڵاوەی مەحلی گەرم بە فستق و شیلەی خۆماڵی", "price": 12000, "image": "assets/images/item_sweets_baklava.jpg"},
      ]
    },
  ];

  @override
  void initState() {
    super.initState();
    _checkServer();
  }

  @override
  void dispose() {
    _orderTrackerTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkServer() async {
    final res = await ApiService.checkHealth();
    if (mounted) {
      setState(() => isCloudConnected = res != null && res['status'] == 'healthy');
    }
  }

  void addToCart(Map<String, dynamic> shop, Map<String, dynamic> item) {
    setState(() {
      final idx = cartItems.indexWhere((e) => e['id'] == item['id']);
      if (idx >= 0) {
        cartItems[idx]['quantity'] = (cartItems[idx]['quantity'] as int) + 1;
      } else {
        cartItems.add({
          ...item,
          'shopId': shop['id'],
          'shopName': shop['name'],
          'quantity': 1,
        });
      }
    });
  }

  void removeFromCart(String itemId) {
    setState(() {
      final idx = cartItems.indexWhere((e) => e['id'] == itemId);
      if (idx >= 0) {
        if ((cartItems[idx]['quantity'] as int) > 1) {
          cartItems[idx]['quantity'] = (cartItems[idx]['quantity'] as int) - 1;
        } else {
          cartItems.removeAt(idx);
        }
      }
    });
  }

  void applyCoupon(String code) {
    if (code.toUpperCase() == "SHARO2026") {
      setState(() {
        appliedCoupon = "SHARO2026";
        discountAmount = 3000;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(backgroundColor: Colors.green, content: Text('کۆپۆنی SHARO2026 لە دەربەندیخان چالاککرا: ۳,۰۰۰ د.ع داشکاندن!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(backgroundColor: Colors.red, content: Text('کۆدی کۆپۆن نادروستە')),
      );
    }
  }

  Future<void> submitOrder() async {
    if (cartItems.isEmpty) return;

    final subtotal = cartItems.fold<int>(0, (s, i) => s + (i['price'] as int) * (i['quantity'] as int));
    const deliveryFee = 1000;
    final total = (subtotal + deliveryFee - discountAmount).clamp(0, 99999999);
    final shopName = cartItems[0]['shopName'] as String;
    final summary = cartItems.map((e) => "${e['quantity']}x ${e['name']}").join(", ");

    final res = await ApiService.makeOrder(
      shopName: shopName,
      customerName: "کڕیاری دەربەندیخان",
      customerPhone: "0770 123 4567",
      customerLocation: currentLocation,
      itemsSummary: summary,
      total: total,
    );

    String orderId = "SHR-${DateTime.now().millisecondsSinceEpoch % 10000}";
    if (res != null && res['data'] != null && res['data']['id'] != null) {
      orderId = res['data']['id'];
    }

    setState(() {
      activeOrder = {
        'id': orderId,
        'shop': shopName,
        'total': total,
        'step': 1,
        'status': 'داواکاری لە دەربەندیخان تۆمارکرا',
        'driver': null,
      };
      cartItems.clear();
      appliedCoupon = null;
      discountAmount = 0;
      _currentIndex = 3; // Navigate to Tracker
    });

    _startOrderTracking(orderId);
  }

  void _startOrderTracking(String orderId) {
    _orderTrackerTimer?.cancel();
    _orderTrackerTimer = Timer.periodic(const Duration(seconds: 4), (timer) async {
      final res = await ApiService.getOrderStatus(orderId);
      if (res != null && res['data'] != null && mounted) {
        final d = res['data'];
        final s = d['status'];
        int step = 1;
        String statusText = 'نێردرا بۆ ستۆر لە دەربەندیخان';

        if (s == 'store_preparing') {
          step = 2;
          statusText = 'لە چێشتخانە ئامادە دەکرێت';
        } else if (s == 'store_ready') {
          step = 3;
          statusText = 'پاکێج ئامادەیە بۆ کاپتن';
        } else if (s == 'on_way') {
          step = 4;
          statusText = 'کاپتن لە دەربەندیخان لە ڕێگایە بەرەو تۆ';
        } else if (s == 'delivered') {
          step = 5;
          statusText = 'داواکاری بە سەرکەوتوویی گەیشتە دەستت';
          timer.cancel();
        }

        setState(() {
          if (activeOrder != null) {
            activeOrder!['step'] = step;
            activeOrder!['status'] = statusText;
            if (d['assignedDriver'] != null) {
              activeOrder!['driver'] = d['assignedDriver']['name'];
            }
          }
        });
      }
    });
  }

  void _selectLocationSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.location_city, color: Color(0xFFFF5A36)),
                SizedBox(width: 8),
                Text('گەڕەکەکانی دەربەندیخان', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 6),
            const Text('شوێنی وەرگرتنی داواکاری لە دەربەندیخان دیاری بکە', style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: darbandikhanAreas.length,
                itemBuilder: (ctx, idx) {
                  final area = darbandikhanAreas[idx];
                  final isSel = area == currentLocation;
                  return ListTile(
                    leading: Icon(Icons.location_on, color: isSel ? const Color(0xFFFF5A36) : Colors.grey),
                    title: Text(area, style: TextStyle(fontWeight: isSel ? FontWeight.bold : FontWeight.normal, fontSize: 13)),
                    trailing: isSel ? const Icon(Icons.check_circle, color: Color(0xFFFF5A36)) : null,
                    onTap: () {
                      setState(() => currentLocation = area);
                      Navigator.pop(ctx);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showShopDetails(Map<String, dynamic> shop) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SharoShopModal(
        shop: shop,
        cartItems: cartItems,
        onAddToCart: (it) => addToCart(shop, it),
        onRemoveFromCart: removeFromCart,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      _buildHomeTab(),
      _buildOffersTab(),
      _buildRideTab(),
      _buildBasketTab(),
      _buildProfileTab(),
    ];

    return Scaffold(
      body: tabs[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, -4)),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (idx) => setState(() => _currentIndex = idx),
          selectedItemColor: const Color(0xFFFF5A36),
          unselectedItemColor: const Color(0xFF9CA3AF),
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          items: [
            const BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'شاڕۆ دەربەندیخان'),
            const BottomNavigationBarItem(icon: Icon(Icons.confirmation_number_outlined), label: 'ئۆفەرەکان'),
            const BottomNavigationBarItem(icon: Icon(Icons.local_taxi_rounded), label: 'تەکسی بەنداو'),
            BottomNavigationBarItem(
              icon: Badge(
                isLabelVisible: cartItems.isNotEmpty,
                label: Text('${cartItems.fold<int>(0, (a, b) => a + (b['quantity'] as int))}'),
                backgroundColor: const Color(0xFFFF5A36),
                child: const Icon(Icons.shopping_bag_outlined),
              ),
              label: 'سەبەتە و چاودێری',
            ),
            const BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'هەژمارەکەم'),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // TAB 1: HOME
  // -------------------------------------------------------------
  Widget _buildHomeTab() {
    final filteredShops = shops.where((s) {
      final matchesSearch = searchQuery.isEmpty || (s['name'] as String).contains(searchQuery);
      final matchesCat = selectedCategory == "all" || s['category'] == selectedCategory;
      return matchesSearch && matchesCat;
    }).toList();

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          backgroundColor: Colors.white,
          elevation: 0.5,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFFF5A36), Color(0xFFFF7A00)]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('شاڕۆ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              ),
              const SizedBox(width: 10),
              InkWell(
                onTap: _selectLocationSheet,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('شوێنی ئێوە لە دەربەندیخان', style: TextStyle(fontSize: 10, color: Colors.grey)),
                        const SizedBox(width: 4),
                        Icon(Icons.keyboard_arrow_down, size: 14, color: Colors.grey.shade700),
                      ],
                    ),
                    Text(currentLocation, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1EE),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFFD5CC)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.account_balance_wallet, size: 14, color: Color(0xFFFF5A36)),
                    const SizedBox(width: 4),
                    Text('$walletBalance د.ع', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFFF5A36))),
                  ],
                ),
              ),
            ],
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Live Cloud Banner
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isCloudConnected ? Colors.green.shade50 : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isCloudConnected ? Colors.green.shade200 : Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.cloud_done, size: 16, color: isCloudConnected ? Colors.green.shade700 : Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Text(
                        isCloudConnected ? 'خزمەتگوزاری شاڕۆ لە دەربەندیخان چالاکە و بەستراوەتەوە' : 'پەیوەستە بە سیستەمی دەربەندیخان',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isCloudConnected ? Colors.green.shade900 : Colors.blue.shade900),
                      ),
                    ],
                  ),
                ),

                // Active order tracking snack-card
                if (activeOrder != null)
                  GestureDetector(
                    onTap: () => setState(() => _currentIndex = 3),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFFFF5A36), Color(0xFFFF8E53)]),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(color: const Color(0xFFFF5A36).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.moped, color: Colors.white, size: 30),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${activeOrder!['status']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                Text('${activeOrder!['shop']} · #${activeOrder!['id']}', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
                        ],
                      ),
                    ),
                  ),

                // Search Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: TextField(
                    onChanged: (val) => setState(() => searchQuery = val),
                    decoration: const InputDecoration(
                      hintText: 'گەڕان لەناو شاڕۆ کڕین، مارکێت و چێشتخانەکان...',
                      hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
                      border: InputBorder.none,
                      icon: Icon(Icons.search, color: Color(0xFFFF5A36)),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Promotional Banners with Real High-Resolution Photography
                SizedBox(
                  height: 150,
                  child: PageView(
                    children: [
                      _buildPromoCard(
                        title: "شاڕۆ کڕین: بازاڕی دەربەندیخان لە گیرفانتدا",
                        desc: "سەوزە، میوە و پێداویستی ڕۆژانە بە گەیاندنی فرێش",
                        badge: "شاڕۆ کڕین",
                        image: "assets/images/banner_promo_3.jpg",
                        gradient: [const Color(0xFF059669), const Color(0xFF10B981)],
                      ),
                      _buildPromoCard(
                        title: "ماسی فرێشی بەنداوی دەربەندیخان!",
                        desc: "ڕاستەوخۆ لە بەنداوەوە بە کەمتر لە ۲۵ خولەک دەگاتە بەردەم ماڵت",
                        badge: "ماسی بەنداو",
                        image: "assets/images/banner_promo_2.jpg",
                        gradient: [const Color(0xFF0284C7), const Color(0xFF38BDF8)],
                      ),
                      _buildPromoCard(
                        title: "کۆدی داشکاندنی دەربەندیخان: SHARO2026",
                        desc: "بڕی ۳,۰۰۰ د.ع داشکاندن لەسەر هەر داواکارییەک",
                        badge: "داشکاندن",
                        image: "assets/images/banner_promo_1.jpg",
                        gradient: [const Color(0xFFFF5A36), const Color(0xFFFF8E53)],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Category Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('بەشە سەرەکییەکانی شاڕۆ دەربەندیخان', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    if (selectedCategory != "all")
                      TextButton(
                        onPressed: () => setState(() => selectedCategory = "all"),
                        child: const Text('پیشاندانی هەمووی', style: TextStyle(fontSize: 11, color: Color(0xFFFF5A36))),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // Visual Category Grid with Real Photos & Vivid Badges
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: categories.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 0.74,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 10,
                  ),
                  itemBuilder: (context, idx) {
                    final cat = categories[idx];
                    final isSelected = selectedCategory == cat['id'];
                    final gradient = cat['gradient'] as List<Color>;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedCategory = isSelected ? "all" : cat['id'];
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFFFF1EE) : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isSelected ? const Color(0xFFFF5A36) : Colors.grey.shade200,
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isSelected ? const Color(0xFFFF5A36).withOpacity(0.18) : Colors.black.withOpacity(0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  width: 54,
                                  height: 54,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: gradient[0].withOpacity(0.3),
                                        blurRadius: 6,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Image.asset(
                                      cat['image'] as String,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: -4,
                                  right: -4,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(colors: gradient),
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4),
                                      ],
                                    ),
                                    child: Text(
                                      cat['tag'] as String,
                                      style: const TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              cat['name'] as String,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                color: isSelected ? const Color(0xFFFF5A36) : const Color(0xFF1E293B),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                // Special Spotlight Section for "شاڕۆ کڕین" (Shopping & Supermarket)
                if (selectedCategory == "all" || selectedCategory == "market") ...[
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF065F46), Color(0xFF047857)],
                      ),
                      boxShadow: [
                        BoxShadow(color: const Color(0xFF059669).withOpacity(0.25), blurRadius: 12, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: Image.asset(
                              'assets/images/shop_market_banner.jpg',
                              fit: BoxFit.cover,
                              opacity: const AlwaysStoppedAnimation(0.22),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 68,
                                height: 68,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.white, width: 2),
                                  boxShadow: [
                                    BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Image.asset(
                                    'assets/images/cat_market.jpg',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text('بەشی تایبەتی شاڕۆ کڕین 🛒', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text('مارکێت و بازاڕی دەربەندیخان', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                                    const SizedBox(height: 2),
                                    const Text('سەوزە، میوە و کەرەستەی خۆراکی بە گەیاندنی فرێش', style: TextStyle(color: Colors.white70, fontSize: 10.5)),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() => selectedCategory = "market");
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF047857),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text('کڕین ئێستا', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Featured Places in Darbandikhan
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedCategory == "market"
                          ? 'مارکێت و دوکانەکانی شاڕۆ کڕین'
                          : (selectedCategory == "fish" ? 'ماسی بەنداوی دەربەندیخان' : 'چێشتخانە و مارکێتە بەردەستەکان'),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    Text('${filteredShops.length} شوێن لە دەربەندیخان', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 12),

                // Visual Shop Cards with Real Banners & Food Previews
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredShops.length,
                  itemBuilder: (ctx, idx) {
                    final s = filteredShops[idx];
                    return GestureDetector(
                      onTap: () => _showShopDetails(s),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Banner Photo with Gradient Overlay
                            SizedBox(
                              height: 140,
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                                    child: Image.asset(
                                      s['banner'] as String,
                                      height: 140,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                                      gradient: LinearGradient(
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                        colors: [
                                          Colors.black.withOpacity(0.85),
                                          Colors.black.withOpacity(0.15),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.92),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(Icons.star, color: Colors.amber, size: 14),
                                                  const SizedBox(width: 4),
                                                  Text('${s['rating']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                                                  Text(' (${s['reviews']})', style: const TextStyle(color: Colors.grey, fontSize: 10)),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                gradient: const LinearGradient(colors: [Color(0xFFFF5A36), Color(0xFFFF7A00)]),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Text(s['featuredTag'] as String, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              s['name'] as String,
                                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                            ),
                                            const SizedBox(height: 2),
                                            Row(
                                              children: [
                                                const Icon(Icons.location_on, color: Colors.white70, size: 12),
                                                const SizedBox(width: 4),
                                                Text(s['location'] as String, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Quick Food / Product Preview Thumbnails
                            Padding(
                              padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                              child: Row(
                                children: [
                                  for (var item in ((s['menu'] as List<dynamic>?) ?? []).take(3))
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Image.asset(
                                              item['image'] as String,
                                              width: 26,
                                              height: 26,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            item['name'].toString().split(' ').take(2).join(' '),
                                            style: const TextStyle(fontSize: 10.5, color: Color(0xFF475569)),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.timer_outlined, size: 14, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text('${s['eta']} خولەک', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                    ],
                                  ),
                                  const Spacer(),
                                  Text(
                                    s['fee'] == 0 ? 'گەیاندن خۆڕاییە' : '${s['fee']} د.ع کرێ',
                                    style: const TextStyle(color: Color(0xFFFF5A36), fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_forward_ios, size: 12, color: Color(0xFFFF5A36)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPromoCard({
    required String title,
    required String desc,
    required String image,
    required String badge,
    required List<Color> gradient,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        image: DecorationImage(
          image: AssetImage(image),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withOpacity(0.85),
              Colors.black.withOpacity(0.2),
            ],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradient),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(badge, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 6),
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 3),
            Text(desc, style: const TextStyle(color: Colors.white70, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // TAB 2: OFFERS
  // -------------------------------------------------------------
  Widget _buildOffersTab() {
    return Scaffold(
      appBar: AppBar(title: const Text('ئۆفەرەکانی شاڕۆ دەربەندیخان', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFFF5A36), Color(0xFFFF8E53)]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('کۆدی داشکاندنی دەربەندیخان', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      Text('SHARO2026', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24, letterSpacing: 2)),
                      SizedBox(height: 4),
                      Text('بڕی ۳,۰۰۰ د.ع داشکاندن بۆ هەموو گەڕەکەکانی دەربەندیخان', style: TextStyle(color: Colors.white, fontSize: 11)),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => applyCoupon("SHARO2026"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFFFF5A36)),
                  child: const Text('بەکارهێنان'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Visual Offer 1
          Container(
            height: 140,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(18)),
              image: DecorationImage(
                image: AssetImage('assets/images/banner_promo_2.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.85), Colors.transparent],
                ),
              ),
              padding: const EdgeInsets.all(14),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('داشکاندنی تایبەتی ماسی بەنداو', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  Text('هەموو ڕۆژانی هەینی، گەیاندنی ماسی بەنداوی دەربەندیخان خۆڕاییە!', style: TextStyle(color: Colors.white70, fontSize: 11)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          // Visual Offer 2
          Container(
            height: 140,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(18)),
              image: DecorationImage(
                image: AssetImage('assets/images/banner_promo_3.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.85), Colors.transparent],
                ),
              ),
              padding: const EdgeInsets.all(14),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('شاڕۆ کڕین: گەیاندنی خۆڕایی بۆ یەکەم کڕین', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  Text('کڕینی پێداویستی خۆراکی و میوە لە دەربەندیخان بە گەیاندنی خێرا', style: TextStyle(color: Colors.white70, fontSize: 11)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // TAB 3: SHARO RIDE & TAXI
  // -------------------------------------------------------------
  Widget _buildRideTab() {
    return Scaffold(
      appBar: AppBar(title: const Text('شاڕۆ ڕاید | تەکسی دەربەندیخان', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Container(
            height: 130,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              image: DecorationImage(
                image: AssetImage('assets/images/cat_taxi.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.85), Colors.black.withOpacity(0.2)],
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('تەکسی و هاتوچۆی دەربەندیخان', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('هاتوچۆ لە نێوان ناو بازاڕ، سەرسیر، بەنداو، زانکۆ و گەڕەکەکان', style: TextStyle(color: Colors.white70, fontSize: 11)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('شۆفێرە نزیکەکانی ناو دەربەندیخان', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          _buildTaxiDriverCard("ئاراس کەمال", "تۆیۆتا کرۆلا سپی", "دەربەندیخان - ٧٢٤٥١ ت", "٣ خولەک", "سەنتەری دەربەندیخان"),
          _buildTaxiDriverCard("هۆگر مەحموود", "هیۆندای ئیلانترا", "دەربەندیخان - ٥١٨٩٢ ت", "٥ خولەک", "گەڕەکی سەرسیر"),
          _buildTaxiDriverCard("کاروان فەریق", "کیا سیراتۆ", "دەربەندیخان - ١٩٠٣٢ ت", "٧ خولەک", "نزیک بەنداو"),
        ],
      ),
    );
  }

  Widget _buildTaxiDriverCard(String name, String car, String plate, String eta, String zone) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFFFF1EE),
          child: Icon(Icons.local_taxi, color: Color(0xFFFF5A36)),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        subtitle: Text('$car · شوێن: $zone\nکات: $eta · تابلۆ: $plate', style: const TextStyle(fontSize: 11)),
        isThreeLine: true,
        trailing: ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(backgroundColor: Colors.green, content: Text('تەکسی دەربەندیخان داواکرا! شۆفێر $name لە ڕێگایە.')),
            );
          },
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF5A36), foregroundColor: Colors.white),
          child: const Text('داواکردن'),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // TAB 4: BASKET & ORDER TRACKER
  // -------------------------------------------------------------
  Widget _buildBasketTab() {
    final subtotal = cartItems.fold<int>(0, (s, i) => s + (i['price'] as int) * (i['quantity'] as int));
    const deliveryFee = 1000;
    final total = (subtotal + deliveryFee - discountAmount).clamp(0, 99999999);

    return Scaffold(
      appBar: AppBar(title: const Text('سەبەتە و بەدواداچوونی دەربەندیخان', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            if (activeOrder != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFF5A36), width: 1.5),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFFFF5A36).withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('داواکاری #${activeOrder!['id']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        Text('${activeOrder!['status']}', style: const TextStyle(color: Color(0xFFFF5A36), fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: (activeOrder!['step'] as int) / 5,
                      color: const Color(0xFFFF5A36),
                      backgroundColor: const Color(0xFFFFF1EE),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(currentLocation, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        const Spacer(),
                        if (activeOrder!['driver'] != null)
                          Text('کاپتن: ${activeOrder!['driver']}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        _orderTrackerTimer?.cancel();
                        setState(() => activeOrder = null);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade50, foregroundColor: Colors.red),
                      child: const Text('داخستنی بەدواداچوون'),
                    ),
                  ],
                ),
              ),

            if (cartItems.isEmpty && activeOrder == null)
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_bag_outlined, size: 72, color: Colors.grey),
                      SizedBox(height: 12),
                      Text('سەبەتەکەت لە دەربەندیخان بەتاڵە', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('خواردن و ماسی بەنداو و کەلوپەلی شاڕۆ کڕین زیاد بکە', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
              )
            else if (cartItems.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (ctx, idx) {
                    final it = cartItems[idx];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              it['image'] as String? ?? 'assets/images/cat_market.jpg',
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(it['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                Text('${it['price']} د.ع', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 20),
                                onPressed: () => removeFromCart(it['id']),
                              ),
                              Text('${it['quantity']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              IconButton(
                                icon: const Icon(Icons.add_circle, color: Color(0xFFFF5A36), size: 20),
                                onPressed: () => addToCart({'id': it['shopId'], 'name': it['shopName']}, it),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

            if (cartItems.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2)),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('کۆی کەلوپەل:'),
                        Text('$subtotal د.ع', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('کرێی گەیاندن لە دەربەندیخان:'),
                        Text('1,000 د.ع', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    if (discountAmount > 0)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('داشکاندنی کۆپۆن:'),
                          Text('-$discountAmount د.ع', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                        ],
                      ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('کۆی گشتی بۆ پارەدان:', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('$total د.ع', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFF5A36), fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: submitOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF5A36),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text('ناردنی داواکاری لە دەربەندیخان', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // TAB 5: PROFILE
  // -------------------------------------------------------------
  Widget _buildProfileTab() {
    return Scaffold(
      appBar: AppBar(title: const Text('هەژماری شاڕۆ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(backgroundColor: Color(0xFFFFF1EE), child: Icon(Icons.person, color: Color(0xFFFF5A36))),
                  SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('محەمەد شاڕۆیی', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Text('دەربەندیخان · بەکارهێنەری VIP', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFFF5A36), Color(0xFFFF8E53)]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('باڵانسی جزدانی شاڕۆ دەربەندیخان', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    Text('$walletBalance د.ع', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() => walletBalance += 10000);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(backgroundColor: Colors.green, content: Text('١٠,٠٠٠ د.ع خرایە سەر جزدانەکەت!')),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFFFF5A36)),
                  child: const Text('پڕکردنەوە'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: const Icon(Icons.cloud_done, color: Color(0xFFFF5A36)),
              title: const Text('دۆخی سێرڤەری کلاود'),
              subtitle: Text(isCloudConnected ? 'پەیوەستە بە سێرڤەری دەربەندیخان (Fly.io)' : 'لە دۆخی خۆجێیی'),
              trailing: Icon(isCloudConnected ? Icons.check_circle : Icons.info, color: isCloudConnected ? Colors.green : Colors.grey),
            ),
          ),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: const ListTile(
              leading: const Icon(Icons.location_city, color: Color(0xFFFF5A36)),
              title: Text('شار و سنوری خزمەتگوزاری'),
              subtitle: Text('دەربەندیخان - هەموو گەڕەکەکان'),
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// SHOP MODAL WITH REAL PHOTOGRAPHY
// -------------------------------------------------------------
class SharoShopModal extends StatelessWidget {
  final Map<String, dynamic> shop;
  final List<Map<String, dynamic>> cartItems;
  final Function(Map<String, dynamic>) onAddToCart;
  final Function(String) onRemoveFromCart;

  const SharoShopModal({
    super.key,
    required this.shop,
    required this.cartItems,
    required this.onAddToCart,
    required this.onRemoveFromCart,
  });

  @override
  Widget build(BuildContext context) {
    final menu = (shop['menu'] as List<dynamic>?) ?? [];

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Header with real banner photography
          SizedBox(
            height: 130,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  child: Image.asset(
                    shop['banner'] as String,
                    height: 130,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.black.withOpacity(0.85), Colors.black.withOpacity(0.2)],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 6)],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.asset(shop['banner'] as String, fit: BoxFit.cover),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(shop['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 2),
                            Text('${shop['location']} · گەیاندن: ${shop['eta']} خولەک', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(14),
              itemCount: menu.length,
              itemBuilder: (context, idx) {
                final it = menu[idx];
                final inCart = cartItems.firstWhere((e) => e['id'] == it['id'], orElse: () => {});
                final qty = inCart.isNotEmpty ? (inCart['quantity'] as int) : 0;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.asset(
                          it['image'] as String,
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(it['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            const SizedBox(height: 2),
                            Text(it['desc'], style: const TextStyle(fontSize: 10.5, color: Colors.grey), maxLines: 2),
                            const SizedBox(height: 6),
                            Text('${it['price']} د.ع', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFF5A36), fontSize: 12.5)),
                          ],
                        ),
                      ),
                      if (qty == 0)
                        IconButton(
                          onPressed: () => onAddToCart(it),
                          icon: const Icon(Icons.add_circle, color: Color(0xFFFF5A36), size: 34),
                        )
                      else
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => onRemoveFromCart(it['id']),
                              icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 22),
                            ),
                            Text('$qty', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            IconButton(
                              onPressed: () => onAddToCart(it),
                              icon: const Icon(Icons.add_circle, color: Color(0xFFFF5A36), size: 22),
                            ),
                          ],
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
