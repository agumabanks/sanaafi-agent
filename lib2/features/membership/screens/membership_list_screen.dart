// lib/features/membership/presentation/screens/membership_list_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/membership_controller.dart';
import 'membership_detail_screen.dart';
// import 'package:six_cash/features/membership/presentation/screens/membership_detail_screen.dart';

class MembershipListScreen extends StatefulWidget {
  const MembershipListScreen({Key? key}) : super(key: key);

  @override
  State<MembershipListScreen> createState() => _MembershipListScreenState();
}

class _MembershipListScreenState extends State<MembershipListScreen> {
  final membershipController = Get.find<MembershipController>();

  @override
  void initState() {
    super.initState();
    // Fetch memberships on screen load
    membershipController.fetchAllMemberships();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memberships'),
      ),
      body: GetBuilder<MembershipController>(
        builder: (controller) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.membershipList.isEmpty) {
            return const Center(child: Text('No Memberships Found'));
          }

          return ListView.builder(
            itemCount: controller.membershipList.length,
            itemBuilder: (context, index) {
              final membership = controller.membershipList[index];
              final clientName = membership.client?.name ?? 'Unknown';
              return ListTile(
                title: Text('$clientName - ${membership.membershipType}'),
                subtitle: Text('Shares: ${membership.shares}'),
                onTap: () async {
                  // Fetch single membership detail
                  await membershipController.getMembershipById(membership.id);
                  // Navigate to detail screen
                  Get.to(() => const MembershipDetailScreen());
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Example: create a test membership or navigate to a creation screen
          // membershipController.createMembership(...);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
