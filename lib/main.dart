import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crypto Listing',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.grey[900],
      ),
      home: const MyHomePage(title: 'Crypto Listing'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, dynamic>> cryptoData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    setState(() {
      isLoading = true;
    });

    final dio = Dio();
    try {
      final response = await dio.get(
        'https://api.coingecko.com/api/v3/coins/markets',
        queryParameters: {
          'vs_currency': 'usd',
          'order': 'volume_desc',
          'per_page': 10,
          'page': 1,
          'sparkline': false,
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          cryptoData = List<Map<String, dynamic>>.from(response.data);
          isLoading = false;
        });
      } else {
        print('Failed to load data');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                        onRefresh: getData,
                        child: ListView.builder(
                          itemCount: cryptoData.length,
                          itemBuilder: (context, index) {
                            final crypto = cryptoData[index];
                            return CryptoListItem(
                              icon: crypto['image'] as String? ?? '',
                              name: (crypto['symbol'] as String? ?? '')
                                  .toUpperCase(),
                              fullName: crypto['name'] as String? ?? '',
                              price: (crypto['current_price'] as num?)
                                      ?.toDouble() ??
                                  0.0,
                              change: (crypto['price_change_percentage_24h']
                                          as num?)
                                      ?.toDouble() ??
                                  0.0,
                              volume: (crypto['total_volume'] as num?)
                                      ?.toDouble() ??
                                  0.0,
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CryptoListItem extends StatelessWidget {
  final String icon;
  final String name;
  final String fullName;
  final double price;
  final double change;
  final double volume;

  const CryptoListItem({
    super.key,
    required this.icon,
    required this.name,
    required this.fullName,
    required this.price,
    required this.change,
    required this.volume,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          icon.isNotEmpty
              ? Image.network(
                  icon,
                  width: 40,
                  height: 40,
                  errorBuilder: (_, __, ___) => const Icon(Icons.error),
                )
              : const Icon(Icons.monetization_on, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                // Text(fullName, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('\$${price.toStringAsFixed(2)}'),
              // Text(
              //   '${change.toStringAsFixed(2)}%',
              //   style:
              //       TextStyle(color: change >= 0 ? Colors.green : Colors.red),
              // ),
              // Text(
              //   'Vol: \$${(volume / 1000000).toStringAsFixed(2)}M',
              //   style: const TextStyle(color: Colors.grey, fontSize: 12),
              // ),
            ],
          ),
        ],
      ),
    );
  }
}
