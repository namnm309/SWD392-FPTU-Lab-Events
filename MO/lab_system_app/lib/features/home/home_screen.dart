import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../calendar/calendar_screen.dart';
import '../labs/labs_screen.dart';
import '../bookings/my_bookings_screen.dart';
import '../admin/admin_dashboard_screen.dart';
import '../../domain/enums/role.dart';
import '../auth/auth_controller.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final isAdmin = ref.watch(isAdminProvider);
    final isLabManager = ref.watch(isLabManagerProvider);
    
    // Determine which tabs to show based on user role
    final showAdminTab = isAdmin || isLabManager;
    
    final List<Widget> screens = [
      const CalendarScreen(),
      const LabsScreen(),
      const MyBookingsScreen(),
      if (showAdminTab) const AdminDashboardScreen(),
    ];

    final List<NavigationDestination> destinations = [
      const NavigationDestination(
        icon: Icon(Icons.calendar_month),
        label: 'Calendar',
      ),
      const NavigationDestination(
        icon: Icon(Icons.science),
        label: 'Labs',
      ),
      const NavigationDestination(
        icon: Icon(Icons.book_online),
        label: 'My Bookings',
      ),
      if (showAdminTab)
        const NavigationDestination(
          icon: Icon(Icons.admin_panel_settings),
          label: 'Admin',
        ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('FPT Lab System'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'logout') {
                final authController = ref.read(authControllerProvider.notifier);
                await authController.logout();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'profile',
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(currentUser?.name[0].toUpperCase() ?? 'U'),
                  ),
                  title: Text(currentUser?.name ?? 'User'),
                  subtitle: Text(currentUser?.role.displayName ?? ''),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Logout'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: destinations,
      ),
    );
  }
}
