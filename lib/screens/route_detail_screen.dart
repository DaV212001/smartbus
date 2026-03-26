import 'package:flutter/material.dart';

class RouteDetailScreen extends StatelessWidget {
  const RouteDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Theme Constants based on your CSS
    const primaryBlue = Color(0xFF2563EB);
    const backgroundGray = Color(0xFFF8F9FA);
    const textMain = Color(0xFF1A1A1A);
    const textMuted = Color(0xFF64748B);

    return Scaffold(
      backgroundColor: backgroundGray,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textMain),
          onPressed: () {},
        ),
        title: const Text(
          'Route 12',
          style: TextStyle(color: textMain, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: textMain),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 160), // Space for bottom UI
            child: Column(
              children: [
                // 1. Active Trip Card
                const ActiveTripCard(),

                // 2. Route Stats Bar
                const RouteStatsBar(),

                // 3. Stop Selectors (From/To)
                const StopSelectors(),

                // 4. Timeline
                const RouteTimeline(),
              ],
            ),
          ),

          // // 5. Floating Action Bar (Fare & Purchase)
          // const Positioned(
          //   bottom: 64, // Just above bottom nav
          //   left: 0,
          //   right: 0,
          //   child: ActionBar(),
          // ),
        ],
      ),
      bottomNavigationBar: ActionBar(),
    );
  }
}

class ActiveTripCard extends StatelessWidget {
  const ActiveTripCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2563EB),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Current Trip",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  "LIVE",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.qr_code, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      "View Active Ticket",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                Icon(Icons.chevron_right, color: Colors.white, size: 18),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.front_hand, color: Colors.red, size: 18),
            label: const Text(
              "Request Weraj (Drop-off)",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RouteStatsBar extends StatelessWidget {
  const RouteStatsBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStat("DISTANCE", "8.4 km"),
          _buildStat("STOPS", "12"),
          _buildStat("EST. TIME", "45 min"),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class StopSelectors extends StatelessWidget {
  const StopSelectors({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildRow("From", "Bole Terminal"),
          const SizedBox(height: 12),
          _buildRow("To", "Stadium"),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 40,
          child: Text(
            label,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const Icon(
                  Icons.expand_more,
                  size: 18,
                  color: Color(0xFF64748B),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class RouteTimeline extends StatelessWidget {
  const RouteTimeline({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "ROUTE SCHEDULE",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 20),
          _buildTimelineItem(
            "Bole Terminal",
            "Departure Station",
            "08:00 AM",
            true,
            true,
          ),
          _buildTimelineItem("Friendship", "Zone A", "08:05 AM", true, true),
          _buildTimelineItem("Edna Mall", "Zone A", "08:12 AM", true, true),
          _buildTimelineItem(
            "Stadium",
            "Selected Destination",
            "08:45 AM",
            true,
            false,
            isSelected: true,
          ),
          _buildTimelineItem("Piazza", "Terminus", "09:05 AM", false, false),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    String title,
    String subtitle,
    String time,
    bool isActive,
    bool hasLine, {
    bool isSelected = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFF2563EB) : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isActive
                      ? const Color(0xFF2563EB)
                      : const Color(0xFF64748B),
                  width: 3,
                ),
              ),
            ),
            if (hasLine)
              Container(
                width: 2,
                height: 40,
                color: isActive
                    ? const Color(0xFF2563EB)
                    : const Color(0xFFE2E8F0),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected
                          ? const Color(0xFF2563EB)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              Text(
                time,
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ActionBar extends StatelessWidget {
  const ActionBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Total Fare",
                style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
              ),
              Text(
                "5.00 ETB",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.confirmation_number_outlined, size: 18),
            label: const Text("Purchase Ticket"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A1A1A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
