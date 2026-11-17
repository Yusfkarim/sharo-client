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
      title: 'شاڕۆ | Sharo Super App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Bahij',
        primaryColor: const Color(0xFFFF5A36),
        scaffoldBackgroundColor: const Color(0xFFF9FAFB),
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
  String currentLocation = "سلێمانی - تووی مەلیك";
  int walletBalance = 12500;
  bool isCloudConnected = false;
  String searchQuery = "";
  String? appliedCoupon;
  int discountAmount = 0;

  List<Map<String, dynamic>> cartItems = [];
  Map<String, dynamic>? activeOrder;
  Timer? _orderTrackerTimer;

  final List<String> sulaymaniyahAreas = [
    "سلێمانی - تووی مەلیك",
    "سلێمانی - سەرچنار",
    "سلێمانی - شەقامی سالمی",
    "سلێمانی - بەختیاری",
    "سلێمانی - ڕاپەڕین",
    "سلێمانی - تاسڵوجە",
    "سلێمانی - چوارباخ",
    "سلێمانی - عەقاری",
    "سلێمانی - کانی با",
    "سلێمانی - ئاشتی",
  ];

  final List<Map<String, dynamic>> categories = [
    {"id": "food", "name": "چێشتخانە و فاست فوود", "icon": "assets/images/burger.png", "tag": "گەرم"},
    {"id": "market", "name": "سوپەرمارکێتی شاڕۆ", "icon": "assets/images/markets.jpg", "tag": "فرێش"},
    {"id": "ride", "name": "شاڕۆ ڕاید و تەکسی", "icon": "assets/images/taxi.jpg", "tag": "خێرا"},
    {"id": "cargo", "name": "کارگۆ و بارهەڵگر", "icon": "assets/images/truck.jpg", "tag": "بار"},
    {"id": "sweets", "name": "کێک و شیرینی", "icon": "assets/images/market-prize.png", "tag": "نوێ"},
    {"id": "prize", "name": "خەڵاتی بەردەوام", "icon": "assets/images/food-discount.png", "tag": "دیاری"},
  ];

  final List<Map<String, dynamic>> shops = [
    {
      "id": "shop-1",
      "name": "چێشتخانەی کەیف (Keyf)",
      "category": "food",
      "rating": 4.9,
      "reviews": 840,
      "eta": "20-30",
      "fee": 0,
      "image": "assets/images/foods.jpg",
      "featuredTag": "گەیاندن بە خۆڕایی",
      "menu": [
        {"id": "m1", "name": "کەبابی تایبەتی کەیف", "desc": "سێ شیش کەبابی گۆشتی فرێش بە نانی گەرم و سەوزە", "price": 9500, "image": "assets/images/foods.jpg"},
        {"id": "m2", "name": "قۆزی بەرخ بە برنجی کوردی", "desc": "گۆشتی نەرمی کوڵاو لەگەڵ شلەی پاقلە و نیسک", "price": 14000, "image": "assets/images/foods.jpg"},
        {"id": "m3", "name": "شیش تاووقی مەریەنەتکراو", "desc": "سنگی مریشکی برژاو بە سۆسی سیری شاڕۆ", "price": 8500, "image": "assets/images/foods.jpg"},
      ]
    },
    {
      "id": "shop-2",
      "name": "برگرزۆن پرۆ (Burger Zone Pro)",
      "category": "food",
      "rating": 4.8,
      "reviews": 1120,
      "eta": "15-25",
      "fee": 1000,
      "image": "assets/images/burger1.png",
      "featuredTag": "تایبەت بە شاڕۆ",
      "menu": [
        {"id": "m4", "name": "دەبڵ سمەش برگر شاڕۆ", "desc": "دوو پەتی گۆشتی ئاڵۆزکراو بە پەنیر و سۆسی تایبەت", "price": 8000, "image": "assets/images/burger1.png"},
        {"id": "m5", "name": "کریسبی چیکن سوپریم", "desc": "سنگی کریسپی سوورکراوە بە کۆڵسڵۆ و پەتاتە", "price": 7500, "image": "assets/images/burger1.png"},
      ]
    },
    {
      "id": "shop-3",
      "name": "شاڕۆ مارکێتی ناوەندی",
      "category": "market",
      "rating": 4.95,
      "reviews": 2300,
      "eta": "15-20",
      "fee": 1000,
      "image": "assets/images/markets.jpg",
      "featuredTag": "هەموو ڕۆژێک کراوەیە",
      "menu": [
        {"id": "m6", "name": "سەبەتەی میوەی وەرزی (٥ کگم)", "desc": "سێو، مۆز، پرتەقاڵ و شلک بە کوالیتی بەرز", "price": 11000, "image": "assets/images/markets.jpg"},
        {"id": "m7", "name": "شیری فرێشی کوردی و ماست", "desc": "شیرەمەنی تەندروست و ناوخۆیی", "price": 5500, "image": "assets/images/markets.jpg"},
      ]
    }
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
        const SnackBar(backgroundColor: Colors.green, content: Text('کۆپۆنی SHARO2026 چالاککرا: ۳,۰۰۰ د.ع داشکاندن!')),
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
      customerName: "کڕیاری شاڕۆ",
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
        'status': 'داواکاری لە شاڕۆ تۆمارکرا',
        'driver': null,
      };
      cartItems.clear();
      appliedCoupon = null;
      discountAmount = 0;
      _currentIndex = 3; // Navigate to Tracker / Basket
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
        String statusText = 'نێردرا بۆ ستۆر';

        if (s == 'store_preparing') {
          step = 2;
          statusText = 'لە چێشتخانە ئامادە دەکرێت';
        } else if (s == 'store_ready') {
          step = 3;
          statusText = 'پاکێج ئامادەیە بۆ وەرگرتن';
        } else if (s == 'on_way') {
          step = 4;
          statusText = 'کاپتن لە ڕێگایە بەرەو تۆ';
        } else if (s == 'delivered') {
          step = 5;
          statusText = 'داواکاری بە سەرکەوتوویی گەیشت';
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
            const Text('ناوچە و ناونیشانی خۆت لە سلێمانی دیاری بکە', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: sulaymaniyahAreas.length,
                itemBuilder: (ctx, idx) {
                  final area = sulaymaniyahAreas[idx];
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
            const BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'شاڕۆ سەرەکی'),
            const BottomNavigationBarItem(icon: Icon(Icons.confirmation_number_outlined), label: 'ئۆفەرەکان'),
            const BottomNavigationBarItem(icon: Icon(Icons.local_taxi_rounded), label: 'شاڕۆ ڕاید'),
            BottomNavigationBarItem(
              icon: Badge(
                isLabelVisible: cartItems.isNotEmpty,
                label: Text('${cartItems.fold<int>(0, (a, b) => a + (b['quantity'] as int))}'),
                backgroundColor: const Color(0xFFFF5A36),
                child: const Icon(Icons.shopping_bag_outlined),
              ),
              label: 'سەبەتە و چاودێری',
            ),
            const BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'پرۆفایل'),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // TAB 1: HOME
  // -------------------------------------------------------------
  Widget _buildHomeTab() {
    final filteredShops = searchQuery.isEmpty
        ? shops
        : shops.where((s) => (s['name'] as String).contains(searchQuery)).toList();

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          backgroundColor: Colors.white,
          elevation: 0.5,
          title: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFFF5A36), Color(0xFFFF7A00)]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text('شاڕۆ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ),
              const SizedBox(width: 10),
              InkWell(
                onTap: _selectLocationSheet,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('شوێنی گەیاندن', style: TextStyle(fontSize: 10, color: Colors.grey)),
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
                // Cloud Status
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isCloudConnected ? Colors.green.shade50 : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isCloudConnected ? Colors.green.shade200 : Colors.blue.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bolt, size: 14, color: isCloudConnected ? Colors.green.shade700 : Colors.blue.shade700),
                      const SizedBox(width: 6),
                      Text(
                        isCloudConnected ? 'سێرڤەری کلاودی خێرای شاڕۆ چالاکە' : 'بەستراوە بە سیستەمی شاڕۆ',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isCloudConnected ? Colors.green.shade800 : Colors.blue.shade800),
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
                      hintText: 'گەڕان بۆ چێشتخانە، خواردن، یان کەرەستەی مارکێت...',
                      hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
                      border: InputBorder.none,
                      icon: Icon(Icons.search, color: Color(0xFFFF5A36)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Promotional Banners
                SizedBox(
                  height: 145,
                  child: PageView(
                    children: [
                      _buildPromoCard(
                        title: "شاڕۆ پریم کڕین: بە خۆڕایی بگاتە دەستت!",
                        desc: "بۆ هەموو داواکارییەکی چێشتخانەکان سەروو ۲۰,۰۰۰ د.ع",
                        image: "assets/images/foods.jpg",
                        gradient: [const Color(0xFF1E3A8A).withOpacity(0.85), Colors.transparent],
                      ),
                      _buildPromoCard(
                        title: "داشکاندنی ۳۵٪ کۆپۆنی: SHARO2026",
                        desc: "لەبەرگرتنەوە لە بەشی ئۆفەرەکان بەردەستە",
                        image: "assets/images/burger1.png",
                        gradient: [const Color(0xFFFF5A36).withOpacity(0.85), Colors.transparent],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Categories Grid
                const Text('خزمەتگوزارییە سەرەکییەکانی شاڕۆ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 10),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: categories.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.05,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemBuilder: (context, idx) {
                    final cat = categories[idx];
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(cat['icon'], width: 38, height: 38),
                          const SizedBox(height: 6),
                          Text(cat['name'], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),

                // Featured Places
                const Text('پێشنیارکراوەکان لە دەوروبەرت', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 10),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredShops.length,
                  itemBuilder: (ctx, idx) {
                    final s = filteredShops[idx];
                    return GestureDetector(
                      onTap: () => _showShopDetails(s),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                              child: Stack(
                                children: [
                                  Image.asset(s['image'], height: 130, width: double.infinity, fit: BoxFit.cover),
                                  Positioned(
                                    top: 10,
                                    right: 10,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.7),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text('${s['featuredTag']}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(s['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                        Row(
                                          children: [
                                            const Icon(Icons.star, color: Colors.amber, size: 14),
                                            Text(' ${s['rating']} (${s['reviews']}) · ${s['eta']} خولەک', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    s['fee'] == 0 ? 'گەیاندن بە خۆڕایی' : '${s['fee']} د.ع کرێ',
                                    style: const TextStyle(color: Color(0xFFFF5A36), fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
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

  Widget _buildPromoCard({required String title, required String desc, required String image, required List<Color> gradient}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(image: AssetImage(image), fit: BoxFit.cover),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: gradient,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            Text(desc, style: const TextStyle(color: Colors.white70, fontSize: 10)),
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
      appBar: AppBar(title: const Text('ئۆفەر و کۆپۆنەکانی شاڕۆ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
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
                      Text('کۆدی داشکاندنی تایبەت', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      Text('SHARO2026', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22, letterSpacing: 2)),
                      SizedBox(height: 4),
                      Text('بڕی ۳,۰۰۰ د.ع داشکاندن بۆ داواکارییەکەت', style: TextStyle(color: Colors.white, fontSize: 11)),
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
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: const ListTile(
              leading: Icon(Icons.celebration, color: Color(0xFFFF5A36)),
              title: Text('خەڵاتی بەکارهێنەری بەردەوام'),
              subtitle: Text('هەر ٥ داواکارییەک، گەیاندنی داواکاری شەشەم بە خۆڕاییە!'),
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
      appBar: AppBar(title: const Text('شاڕۆ ڕاید | تەکسی و بارهەڵگر', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Container(
            height: 130,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: const DecorationImage(image: AssetImage('assets/images/taxi.jpg'), fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 16),
          const Text('داواکردنی ڕاستەوخۆی شۆفێر', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          _buildTaxiDriverCard("ئاراس کمال عەلی", "تۆیۆتا کرۆلا سپی ٢٠٢٢", "سلێمانی - ٧٢٤٥١ ت", "٤ خولەک", "0770 123 4567"),
          _buildTaxiDriverCard("هۆگر مەحموود", "هیۆندای ئیلانترا ٢٠٢١", "سلێمانی - ٥١٨٩٢ ت", "٦ خولەک", "0750 987 6543"),
          _buildTaxiDriverCard("کاروان فەریق", "کیا سیراتۆ ٢٠٢٠", "سلێمانی - ١٩٠٣٢ ت", "٨ خولەک", "0771 444 5566"),
        ],
      ),
    );
  }

  Widget _buildTaxiDriverCard(String name, String car, String plate, String eta, String phone) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFFFF1EE),
          child: Icon(Icons.local_taxi, color: Color(0xFFFF5A36)),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        subtitle: Text('$car · کات: $eta\nتابلۆ: $plate', style: const TextStyle(fontSize: 11)),
        isThreeLine: true,
        trailing: ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(backgroundColor: Colors.green, content: Text('تەکسی داواکرا! شۆفێر $name لە ڕێگایە.')),
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
      appBar: AppBar(title: const Text('سەبەتە و بەدواداچوونی شاڕۆ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), centerTitle: true),
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
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/no_order.png', width: 140),
                      const SizedBox(height: 12),
                      const Text('سەبەتەکەت بەتاڵە', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const Text('خواردن و کەلوپەلەکان زیاد بکە بۆ کڕین', style: TextStyle(color: Colors.grey, fontSize: 12)),
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
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(it['image'], width: 52, height: 52, fit: BoxFit.cover),
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
                        const Text('کۆی خواردن و کەرەستە:'),
                        Text('$subtotal د.ع', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('کرێی گەیاندن:'),
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
                        child: const Text('ناردنی داواکاری بۆ شاڕۆ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Image.asset('assets/images/ic_amada_user.png', width: 50, height: 50),
                  const SizedBox(width: 14),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('محەمەد شاڕۆیی', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Text('+964 770 123 4567 · بەکارهێنەری VIP', style: TextStyle(color: Colors.grey, fontSize: 12)),
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
                    const Text('باڵانسی جزدانی شاڕۆ', style: TextStyle(color: Colors.white70, fontSize: 12)),
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
              subtitle: Text(isCloudConnected ? 'پەیوەستە بە سێرڤەری شاڕۆ (Fly.io)' : 'لە دۆخی خۆجێیی'),
              trailing: Icon(isCloudConnected ? Icons.check_circle : Icons.info, color: isCloudConnected ? Colors.green : Colors.grey),
            ),
          ),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: const ListTile(
              leading: Icon(Icons.support_agent, color: Color(0xFFFF5A36)),
              title: Text('پشتیوانی و پەیوەندی بە شاڕۆ'),
              subtitle: Text('0770 000 0000 · سلێمانی'),
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// SHOP MODAL
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
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              image: DecorationImage(image: AssetImage(shop['image']), fit: BoxFit.cover),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              alignment: Alignment.bottomRight,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.75), Colors.transparent],
                ),
              ),
              child: Text(shop['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
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
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(it['image'], width: 64, height: 64, fit: BoxFit.cover),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(it['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            Text(it['desc'], style: const TextStyle(fontSize: 10, color: Colors.grey), maxLines: 2),
                            const SizedBox(height: 4),
                            Text('${it['price']} د.ع', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFF5A36))),
                          ],
                        ),
                      ),
                      if (qty == 0)
                        IconButton(
                          onPressed: () => onAddToCart(it),
                          icon: const Icon(Icons.add_circle, color: Color(0xFFFF5A36), size: 28),
                        )
                      else
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => onRemoveFromCart(it['id']),
                              icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 22),
                            ),
                            Text('$qty', style: const TextStyle(fontWeight: FontWeight.bold)),
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
