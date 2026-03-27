import 'package:flutter/material.dart';
import 'dart:ui';

class PremiumPaywallScreen extends StatefulWidget {
  const PremiumPaywallScreen({super.key});

  @override
  State<PremiumPaywallScreen> createState() => _PremiumPaywallScreenState();
}

class _PremiumPaywallScreenState extends State<PremiumPaywallScreen> {
  // 0 = Monthly, 1 = Annual
  int _selectedPlan = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // --- PREMIUM HEADER ---
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.amberAccent.withOpacity(0.1),
                    boxShadow: [
                      BoxShadow(color: Colors.amberAccent.withOpacity(0.2), blurRadius: 30, spreadRadius: 5)
                    ]
                ),
                child: const Icon(Icons.workspace_premium_rounded, color: Colors.amberAccent, size: 50),
              ),
              const SizedBox(height: 20),
              const Text("ESTRALLIS NEURAL+", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2)),
              const SizedBox(height: 10),
              const Text(
                "Unlock proactive behavioral conditioning and full environmental synchronization.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
              const SizedBox(height: 40),

              // --- PRICING TOGGLE ---
              Row(
                children: [
                  Expanded(child: _buildPricingCard(0, "MONTHLY", "₹79", "/mo")),
                  const SizedBox(width: 15),
                  Expanded(child: _buildPricingCard(1, "ANNUAL", "₹899", "/yr", isBestValue: true)),
                ],
              ),
              const SizedBox(height: 40),

              // --- PREMIUM FEATURES LIST ---
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("NEURAL+ FEATURES", style: TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 2)),
              ),
              const SizedBox(height: 15),

              _buildFeatureRow(Icons.route_rounded, "Goal-Oriented Mood Shifting", "AI dynamically phases audio to move you from negative to positive states over time."),
              _buildFeatureRow(Icons.calendar_month_rounded, "Predictive Calendar Sync", "Detects high-stress events (exams, meetings) and pre-loads focus/calm frequencies."),
              _buildFeatureRow(Icons.cloud_sync_rounded, "Weather-Based Adaptation", "Modulates audio valence based on local barometric pressure and sunlight data."),
              _buildFeatureRow(Icons.format_paint_rounded, "Full Adaptive UI", "Unlocks dynamic, emotion-based app themes and personalized orbit patterns."),

              const SizedBox(height: 40),

              // --- CHECKOUT BUTTON ---
              GestureDetector(
                onTap: () {
                  // Just a demo pop-up for the pitch
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: Colors.amberAccent,
                        content: Text("Payment Gateway Sandbox Initiated.", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      )
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Colors.amberAccent, Colors.orangeAccent]),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.amberAccent.withOpacity(0.4), blurRadius: 15, spreadRadius: 1)],
                  ),
                  child: const Center(
                    child: Text("INITIATE UPGRADE", style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPricingCard(int index, String title, String price, String period, {bool isBestValue = false}) {
    bool isSelected = _selectedPlan == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? Colors.amberAccent.withOpacity(0.1) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? Colors.amberAccent : Colors.white.withOpacity(0.1), width: isSelected ? 2 : 1),
        ),
        child: Column(
          children: [
            if (isBestValue)
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.amberAccent, borderRadius: BorderRadius.circular(10)),
                child: const Text("BEST VALUE", style: TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),
            Text(title, style: TextStyle(color: isSelected ? Colors.amberAccent : Colors.white54, fontSize: 12, letterSpacing: 1, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(price, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                Text(period, style: const TextStyle(color: Colors.white54, fontSize: 14)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: Colors.amberAccent, size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}