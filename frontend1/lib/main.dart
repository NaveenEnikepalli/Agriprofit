import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import 'providers/app_provider.dart';
import 'providers/mandi_prices_provider.dart';
import 'providers/fertilizer_provider.dart';
import 'screens/mandi_prices_screen.dart';
import 'screens/fertilizer_guide_screen.dart';

void main() {
  runApp(const MyApp());
}

class ThemeProvider extends ChangeNotifier {
  bool isDarkMode = false;
  void toggleTheme() {
    isDarkMode = !isDarkMode;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => MandiPricesProvider()),
        ChangeNotifierProvider(create: (_) => FertilizerProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp.router(
            title: 'AgriProfit',
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.isDarkMode
                ? ThemeMode.dark
                : ThemeMode.light,
            theme: ThemeData(
              useMaterial3: true,
              fontFamily: 'Poppins',
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.green.shade700,
                brightness: Brightness.light,
              ),
            ),
            darkTheme: ThemeData.dark().copyWith(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.green.shade700,
                brightness: Brightness.dark,
              ),
            ),
            routerConfig: _router,
          );
        },
      ),
    );
  }
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => _buildPageWithTransition(
        child: const AppScaffold(bgImageIndex: 0, child: HomeScreen()),
      ),
    ),
    GoRoute(
      path: '/mandi-prices',
      pageBuilder: (context, state) => _buildPageWithTransition(
        child: const AppScaffold(bgImageIndex: 1, child: MandiPricesScreen()),
      ),
    ),
    GoRoute(
      path: '/fertilizer-guide',
      pageBuilder: (context, state) => _buildPageWithTransition(
        child: const AppScaffold(
          bgImageIndex: 2,
          child: FertilizerGuideScreen(),
        ),
      ),
    ),
  ],
);

CustomTransitionPage<void> _buildPageWithTransition({required Widget child}) {
  return CustomTransitionPage<void>(
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final fade = CurvedAnimation(parent: animation, curve: Curves.easeInOut);
      final slide = Tween<Offset>(
        begin: const Offset(0.05, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));
      return FadeTransition(
        opacity: fade,
        child: SlideTransition(position: slide, child: child),
      );
    },
    transitionDuration: const Duration(milliseconds: 500),
  );
}

class AppScaffold extends StatefulWidget {
  final Widget child;
  final int bgImageIndex;
  const AppScaffold({
    super.key,
    required this.child,
    required this.bgImageIndex,
  });

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  static const List<String> bgImages = [
    'https://images.unsplash.com/photo-1501004318641-b39e6451bec6?auto=format&fit=crop&w=1600&q=80',
    '',
    'https://images.unsplash.com/photo-1518977956815-00b7f34d7c11?auto=format&fit=crop&w=1600&q=80',
    'https://images.unsplash.com/photo-1556761175-129418cb2dfe?auto=format&fit=crop&w=1600&q=80',
    'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=1600&q=80',
  ];

  int get currentIndex => widget.bgImageIndex;

  void _navigate(BuildContext context, String path) {
    if (GoRouterState.of(context).uri.toString() != path) {
      context.go(path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Stack(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 700),
          child: Container(
            key: ValueKey(currentIndex),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(bgImages[currentIndex]),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.4),
                  BlendMode.darken,
                ),
              ),
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(65),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.25),
                border: const Border(
                  bottom: BorderSide(color: Colors.white24, width: 0.5),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.agriculture_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "AgriProfit",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  _NavButton(
                    label: "🏠 Home",
                    isActive: widget.bgImageIndex == 0,
                    onTap: () => _navigate(context, '/'),
                  ),
                  const SizedBox(width: 10),
                  _NavButton(
                    label: "📊 Mandi Prices",
                    isActive: widget.bgImageIndex == 1,
                    onTap: () => _navigate(context, '/mandi-prices'),
                  ),
                  const SizedBox(width: 10),
                  _NavButton(
                    label: "🌱 Fertilizer Guide",
                    isActive: widget.bgImageIndex == 2,
                    onTap: () => _navigate(context, '/fertilizer-guide'),
                  ),
                  const SizedBox(width: 10),

                  const SizedBox(width: 20),
                  IconButton(
                    icon: Icon(
                      themeProvider.isDarkMode
                          ? Icons.wb_sunny_rounded
                          : Icons.dark_mode_rounded,
                      color: Colors.white,
                    ),
                    onPressed: () => themeProvider.toggleTheme(),
                  ),
                ],
              ),
            ),
          ),
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: Container(
              key: ValueKey(widget.bgImageIndex),
              width: double.infinity,
              height: double.infinity,
              padding: const EdgeInsets.all(20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                    border: Border.all(color: Colors.white12),
                  ),
                  child: widget.child,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NavButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.white.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            fontSize: 14.5,
          ),
        ),
      ),
    );
  }
}

/// ---------------------------
/// HOME SCREEN (Marketing style)
/// ---------------------------
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _launchURL(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> infoCards = [
      {
        "title": "Empowering Farmers with Technology",
        "desc":
            "Smart Farming App bridges agriculture providing real-time Mandi prices, crop insights on using Fertilizers effectively.",
        "image": "./img farmer.jpg",
      },
      {
        "title": "Live Market Insights",
        "desc":
            "Get instant updates on Mandi rates across regions, enabling smarter selling and buying decisions.",
        "image": "./img2.jpg",
      },
      {
        "title": "Fertilizer Guide",
        "desc":
            "Access curated guides that suggest usage of fertilizer based on the crop.",
        "image":
            "https://images.unsplash.com/photo-1597362925123-77861d3fbac7?auto=format&fit=crop&w=800&q=80",
      },
    ];

    final Uri twitterUrl = Uri.parse('https://twitter.com/');
    final Uri facebookUrl = Uri.parse('https://facebook.com/');
    final Uri instagramUrl = Uri.parse('https://instagram.com/');

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 10),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 20,
            runSpacing: 20,
            children: infoCards.map((card) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOut,
                width: 330,
                height: 370,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.1),
                      Colors.white.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.network(
                        card["image"]!,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      card["title"]!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      card["desc"]!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                const Text(
                  "Contact Us",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Email: support@smartfarming.com\nPhone: XXXXX XXXXX",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.facebook,
                        color: Colors.white,
                        size: 26,
                      ),
                      onPressed: () => _launchURL(facebookUrl),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 26,
                      ),
                      onPressed: () => _launchURL(instagramUrl),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.alternate_email,
                        color: Colors.white,
                        size: 26,
                      ),
                      onPressed: () => _launchURL(twitterUrl),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  "",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
