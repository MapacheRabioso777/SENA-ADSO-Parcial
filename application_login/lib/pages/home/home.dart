import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/theme_app.dart';
import '../../widgets/appbar.dart';
import '../../widgets/navigation_bottom.dart';
import '../user/user.dart';

class HomeScreen extends StatefulWidget {
  final String username;
  final String token;

  const HomeScreen({
    super.key,
    required this.username,
    required this.token,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeContent(username: widget.username),
      UserScreen(
        username: widget.username,
        token: widget.token,
      ),
    ];
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: _getTitle(),
        showBackButton: false,
      ), // CustomAppBar
      body: PageView(
        controller: _pageController,
        children: _pages,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ), // PageView
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          _pageController.jumpToPage(index);
        },
      ), // BottomNavigation
    ); // Scaffold
  }

  String _getTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Inicio';
      case 1:
        return 'Estado de Usuario';
      default:
        return 'Mi App';
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Home Content
// ─────────────────────────────────────────────────────────────────────────────

class HomeContent extends StatelessWidget {
  final String username;

  const HomeContent({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppTheme.primaryDark, AppTheme.primary],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.waving_hand_rounded,
                      color: Colors.white, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '¡Bienvenido!',
                        style: GoogleFonts.poppins(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        username,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Info card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.info_outline_rounded,
                        color: AppTheme.primary, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Usa el menú lateral o la barra inferior para navegar entre secciones.',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: const Color(0xFF666666),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'Secciones',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2D2D2D),
            ),
          ),
          const SizedBox(height: 12),

          // Features grid
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.95,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildFeatureCard(Icons.person_rounded, 'Perfil', const Color(0xFF6C63FF)),
              _buildFeatureCard(
                Icons.verified_user_rounded,
                'Estado de Usuario',
                const Color(0xFF11BE8A),
              ),
              _buildFeatureCard(
                Icons.notifications_rounded,
                'Notificaciones',
                const Color(0xFFFF8A48),
              ),
              _buildFeatureCard(Icons.help_rounded, 'Ayuda', const Color(0xFFD153C4)),
            ],
          ), // GridView.count
        ],
      ), // Column
    ); // Padding
  }

  Widget _buildFeatureCard(IconData icon, String title, Color color) {
    return Card(
      elevation: 4,
      shadowColor: color.withValues(alpha: 0.2),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: const Color(0xFF2D2D2D),
              ),
              textAlign: TextAlign.center,
            ), // Text
          ],
        ), // Column
      ), // Padding
    ); // Card
  }
}
