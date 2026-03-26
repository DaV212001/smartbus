import 'package:flutter/material.dart';

class RouteSearchScreen extends StatelessWidget {
  const RouteSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFD),
      body: SafeArea(
        child: Column(
          children: [
            // _header(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [_searchSection(), _sectionHeader(), _routeList()],
                ),
              ),
            ),
          ],
        ),
      ),
      // bottomNavigationBar: _bottomNav(),
    );
  }

  // ================= HEADER =================
  Widget _header() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0x14000000))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Color(0xFF0066CC),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.directions_bus,
                  size: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                "AddisBus",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0066CC),
                ),
              ),
            ],
          ),
          CircleAvatar(
            backgroundColor: Color(0xFFF3F7FF),
            child: Icon(Icons.person, color: Colors.black),
          ),
        ],
      ),
    );
  }

  // ================= SEARCH =================
  Widget _searchSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Where to?",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Stack(
            children: [
              // Connector line
              Positioned(
                left: 18,
                top: 30,
                bottom: 30,
                child: Container(width: 2, color: Color(0x14000000)),
              ),
              Column(
                children: const [
                  _SearchField(icon: Icons.circle, hint: "Departure Stop"),
                  SizedBox(height: 12),
                  _SearchField(
                    icon: Icons.location_on,
                    hint: "Destination Stop",
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _filters(),
        ],
      ),
    );
  }

  Widget _filters() {
    final filters = ["Lowest Price", "Fastest", "Route #"];

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, i) {
          final active = i == 0;
          return Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: active ? Color(0xFF0066CC) : Color(0xFFF3F7FF),
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.center,
            child: Text(
              filters[i],
              style: TextStyle(
                color: active ? Colors.white : Colors.black,
                fontSize: 13,
              ),
            ),
          );
        },
      ),
    );
  }

  // ================= SECTION =================
  Widget _sectionHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          "Available Routes",
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  // ================= ROUTES =================
  Widget _routeList() {
    return Column(
      children: const [
        RouteCard2(
          route: "Route 12",
          price: "5.00 ETB",
          start: "Bole",
          end: "Piazza",
          duration: "45m",
          stops: "12 stops",
          frequency: "Every 15 min",
          offline: true,
        ),
        RouteCard2(
          route: "Route 04",
          price: "4.00 ETB",
          start: "Megenagna",
          end: "Stadium",
          duration: "30m",
          stops: "8 stops",
          frequency: "Every 10 min",
        ),
        RouteCard2(
          route: "Route 22",
          price: "3.50 ETB",
          start: "Mexico",
          end: "Piassa",
          duration: "25m",
          stops: "6 stops",
          frequency: "Every 20 min",
          offline: true,
        ),
      ],
    );
  }

  // ================= NAV =================
  Widget _bottomNav() {
    return BottomNavigationBar(
      currentIndex: 0,
      selectedItemColor: Color(0xFF0066CC),
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.map), label: "Routes"),
        BottomNavigationBarItem(icon: Icon(Icons.qr_code), label: "My Ticket"),
        BottomNavigationBarItem(icon: Icon(Icons.wallet), label: "Wallet"),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications),
          label: "Alerts",
        ),
      ],
    );
  }
}

// ================= SEARCH FIELD =================
class _SearchField extends StatelessWidget {
  final IconData icon;
  final String hint;

  const _SearchField({required this.icon, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.only(left: 44, right: 16),
      decoration: BoxDecoration(
        color: Color(0xFFF6F7F9),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.centerLeft,
      child: Stack(
        children: [
          Positioned(
            left: -28,
            child: Icon(icon, size: 16, color: Color(0xFF0066CC)),
          ),
          Text(hint, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

// ================= ROUTE CARD =================
class RouteCard2 extends StatelessWidget {
  final String route, price, start, end, duration, stops, frequency;
  final bool offline;

  const RouteCard2({
    super.key,
    required this.route,
    required this.price,
    required this.start,
    required this.end,
    required this.duration,
    required this.stops,
    required this.frequency,
    this.offline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        border: Border.all(color: Color(0x14000000)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Color(0xFF0066CC),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(route, style: const TextStyle(color: Colors.white)),
              ),
              Text(price, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(start),
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(height: 2, color: Colors.grey.shade300),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      color: Colors.white,
                      child: Text(
                        duration,
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                  ],
                ),
              ),
              Text(end),
            ],
          ),
          const Divider(),
          Row(
            children: [
              const Icon(Icons.directions_bus, size: 14),
              const SizedBox(width: 4),
              Text(frequency),
              const SizedBox(width: 12),
              const Icon(Icons.map, size: 14),
              const SizedBox(width: 4),
              Text(stops),
              if (offline) ...[
                const Spacer(),
                const Icon(Icons.check_circle, size: 14, color: Colors.green),
                const SizedBox(width: 4),
                const Text("Offline", style: TextStyle(color: Colors.green)),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
