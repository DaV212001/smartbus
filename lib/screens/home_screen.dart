import 'package:flutter/material.dart';

import '../screens/route_detail_screen.dart';
import '../screens/route_search_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FBFF),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(context),
            _buildFilters(),
            _buildSectionTitle(),
            Expanded(child: _buildRouteList()),
          ],
        ),
      ),
      // bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "SmartBus",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          CircleAvatar(
            backgroundColor: Color(0xFFEAF4FF),
            child: Icon(Icons.person, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return GestureDetector(
      onTap: () => {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RouteSearchScreen()),
        ),
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Color(0xFFEAF4FF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: const [
              Icon(Icons.search, color: Colors.grey),
              SizedBox(width: 12),
              Text(
                "Search route, stop, or destination",
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    final filters = ["All Routes", "Price", "Recent", "Saved"];

    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final isActive = index == 0;
          return Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: isActive ? Color(0xFF0B66B2) : Color(0xFFEAF4FF),
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.center,
            child: Text(
              filters[index],
              style: TextStyle(color: isActive ? Colors.white : Colors.black),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          "Available Routes",
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildRouteList() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: const [
        RouteCard(
          route: "Route 12",
          price: "10 ETB",
          start: "Piazza Terminal",
          end: "Bole Airport",
          duration: "45 mins",
          stops: "14 stops",
        ),
        RouteCard(
          route: "Route 34",
          price: "8 ETB",
          start: "Mexico Square",
          end: "Megenagna",
          duration: "30 mins",
          stops: "9 stops",
        ),
        RouteCard(
          route: "Route 7",
          price: "5 ETB",
          start: "Tor Hailoch",
          end: "4 Kilo",
          duration: "25 mins",
          stops: "6 stops",
        ),
        RouteCard(
          route: "Route 22",
          price: "12 ETB",
          start: "Merkato",
          end: "Gotera",
          duration: "40 mins",
          stops: "11 stops",
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: 0,
      selectedItemColor: Color(0xFF0B66B2),
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.explore), label: "Routes"),
        BottomNavigationBarItem(icon: Icon(Icons.wallet), label: "Wallet"),
        BottomNavigationBarItem(icon: Icon(Icons.qr_code), label: "Ticket"),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications),
          label: "Alerts",
        ),
      ],
    );
  }
}

class RouteCard extends StatelessWidget {
  final String route, price, start, end, duration, stops;

  const RouteCard({
    super.key,
    required this.route,
    required this.price,
    required this.start,
    required this.end,
    required this.duration,
    required this.stops,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RouteDetailScreen()),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black12),
          color: Colors.white,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Color(0xFFFFF3CD),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(route),
                ),
                Text(
                  price,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Column(
                  children: const [
                    Icon(Icons.circle, size: 8),
                    SizedBox(height: 4),
                    SizedBox(height: 24, child: VerticalDivider()),
                    Icon(Icons.circle, size: 8, color: Colors.blue),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [Text(start), Text(end)],
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              children: [
                const Icon(Icons.access_time, size: 14),
                const SizedBox(width: 4),
                Text(duration),
                const SizedBox(width: 16),
                const Icon(Icons.location_on, size: 14),
                const SizedBox(width: 4),
                Text(stops),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
