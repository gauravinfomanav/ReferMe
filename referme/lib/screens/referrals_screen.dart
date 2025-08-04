import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/referral_controller.dart';
import '../constants/app_constants.dart';
import '../utils/autotextsize.dart';
import '../models/referral_model.dart';
import 'referral_chat_screen.dart';

class ReferralsScreen extends StatefulWidget {
  const ReferralsScreen({super.key});

  @override
  State<ReferralsScreen> createState() => _ReferralsScreenState();
}

class _ReferralsScreenState extends State<ReferralsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ReferralController referralController = Get.put(ReferralController());

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(AppConstants.backgroundColorHex),
      appBar: AppBar(
        backgroundColor: Color(AppConstants.backgroundColorHex),
        elevation: 0,
        automaticallyImplyLeading: false, // Remove back button
        title: MusaffaAutoSizeText.headlineSmall(
          'Referrals',
          color: Color(AppConstants.primaryColorHex),
          fontWeight: FontWeight.w600,
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: Color(AppConstants.primaryColorHex).withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Color(AppConstants.primaryColorHex),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Color(AppConstants.primaryColorHex).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding: const EdgeInsets.all(4),
              labelColor: Colors.white,
              unselectedLabelColor: Color(AppConstants.primaryColorHex).withOpacity(0.7),
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
              dividerColor: Colors.transparent,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.send_rounded, size: 18),
                      const SizedBox(width: 8),
                      const Text('Sent'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox_rounded, size: 18),
                      const SizedBox(width: 8),
                      const Text('Received'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSentReferralsTab(),
          _buildReceivedReferralsTab(),
        ],
      ),
    );
  }

  Widget _buildSentReferralsTab() {
    return Obx(() {
      if (referralController.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      // Get all sent referrals and add referral messages from received tab
      final List<Referral> allSentItems = [];
      
      // Add sent referrals
      allSentItems.addAll(referralController.sentReferrals);
      
      // Add referral messages from received tab that have been responded to
      for (final receivedReferral in referralController.receivedReferrals) {
        if (receivedReferral.referralMessage != null && receivedReferral.status == 'completed') {
          // Create a referral object to show the response in sent tab
          final responseReferral = Referral(
            id: receivedReferral.id,
            requesterId: receivedReferral.requesterId,
            targetUserId: receivedReferral.targetUserId,
            status: 'completed',
            message: receivedReferral.referralMessage!.message,
            isActive: receivedReferral.isActive,
            createdAt: receivedReferral.referralMessage!.createdAt,
            updatedAt: receivedReferral.referralMessage!.updatedAt,
            type: 'response',
            otherUser: receivedReferral.otherUser,
            userRole: 'target',
            referralMessage: receivedReferral.referralMessage,
          );
          allSentItems.add(responseReferral);
        }
      }

      if (allSentItems.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Color(AppConstants.primaryColorHex).withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.send_outlined,
                  size: 48,
                  color: Color(AppConstants.primaryColorHex).withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 24),
              MusaffaAutoSizeText.headlineSmall(
                'No sent referrals',
                color: Color(AppConstants.primaryColorHex).withOpacity(0.8),
                fontWeight: FontWeight.w600,
              ),
              const SizedBox(height: 12),
              MusaffaAutoSizeText.bodyMedium(
                'You haven\'t sent any referral requests yet',
                color: Color(AppConstants.primaryColorHex).withOpacity(0.6),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => referralController.fetchReferrals(),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: allSentItems.length + 1, // +1 for extra space
          itemBuilder: (context, index) {
            if (index == allSentItems.length) {
              // Extra space at the bottom
              return const SizedBox(height: 100);
            }
            final referral = allSentItems[index];
            return _buildReferralCard(referral, isSent: true);
          },
        ),
      );
    });
  }

  Widget _buildReceivedReferralsTab() {
    return Obx(() {
      if (referralController.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      if (referralController.receivedReferrals.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Color(AppConstants.primaryColorHex).withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.inbox_outlined,
                  size: 48,
                  color: Color(AppConstants.primaryColorHex).withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 24),
              MusaffaAutoSizeText.headlineSmall(
                'No received referrals',
                color: Color(AppConstants.primaryColorHex).withOpacity(0.8),
                fontWeight: FontWeight.w600,
              ),
              const SizedBox(height: 12),
              MusaffaAutoSizeText.bodyMedium(
                'You haven\'t received any referral requests yet',
                color: Color(AppConstants.primaryColorHex).withOpacity(0.6),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => referralController.fetchReferrals(),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: referralController.receivedReferrals.length + 1, // +1 for extra space
          itemBuilder: (context, index) {
            if (index == referralController.receivedReferrals.length) {
              // Extra space at the bottom
              return const SizedBox(height: 100);
            }
            final referral = referralController.receivedReferrals[index];
            return _buildReferralCard(referral, isSent: false);
          },
        ),
      );
    });
  }

  Widget _buildReferralCard(Referral referral, {required bool isSent}) {
    final otherUser = referral.otherUser;
    if (otherUser == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Color(AppConstants.primaryColorHex).withOpacity(0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(AppConstants.primaryColorHex).withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Get.to(() => ReferralChatScreen(
              referral: referral,
              isFromReceivedTab: !isSent,
            ));
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with user info and status
                Row(
                  children: [
                    // User avatar
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Color(AppConstants.primaryColorHex),
                            Color(AppConstants.primaryColorHex).withOpacity(0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color(AppConstants.primaryColorHex).withOpacity(0.15),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(1.5),
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 24,
                        child: Text(
                          _getInitials(otherUser.name),
                          style: TextStyle(
                            color: Color(AppConstants.primaryColorHex),
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // User info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            otherUser.name,
                            style: TextStyle(
                              color: Color(AppConstants.primaryColorHex),
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            otherUser.email,
                            style: TextStyle(
                              color: Color(AppConstants.primaryColorHex).withOpacity(0.6),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: referralController.getReferralStatusColor(referral.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: referralController.getReferralStatusColor(referral.status).withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        referralController.getReferralStatusText(referral.status),
                        style: TextStyle(
                          color: referralController.getReferralStatusColor(referral.status),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Compact status indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: referral.type == 'response' 
                        ? const Color(0xFF4CAF50).withOpacity(0.1)
                        : Color(AppConstants.primaryColorHex).withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: referral.type == 'response'
                          ? const Color(0xFF4CAF50).withOpacity(0.2)
                          : Color(AppConstants.primaryColorHex).withOpacity(0.1),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                        referral.type == 'response' 
                            ? Icons.check_circle_rounded
                            : (isSent ? Icons.send_rounded : Icons.inbox_rounded),
                        size: 14,
                        color: referral.type == 'response'
                            ? const Color(0xFF4CAF50)
                            : Color(AppConstants.primaryColorHex).withOpacity(0.6),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        referral.type == 'response' 
                            ? 'Response sent'
                            : (isSent ? 'Request sent' : 'Request received'),
                        style: TextStyle(
                          color: referral.type == 'response'
                              ? const Color(0xFF4CAF50)
                              : Color(AppConstants.primaryColorHex).withOpacity(0.6),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      if (referral.type == 'response' && referral.referralMessage?.link != null) ...[
                        const SizedBox(width: 6),
                        Icon(
                          Icons.link_rounded,
                          color: const Color(0xFF4CAF50),
                          size: 12,
                        ),
                      ],
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Footer with timestamp and action
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 14,
                      color: Color(AppConstants.primaryColorHex).withOpacity(0.5),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      referralController.formatDate(referral.createdAt),
                      style: TextStyle(
                        color: Color(AppConstants.primaryColorHex).withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    if (referral.status == 'pending' && !isSent)
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(AppConstants.primaryColorHex),
                              Color(AppConstants.primaryColorHex).withOpacity(0.8),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Color(AppConstants.primaryColorHex).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Get.to(() => ReferralChatScreen(
                                referral: referral,
                                isFromReceivedTab: !isSent,
                              ));
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.reply_rounded,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Reply',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (referral.status == 'completed')
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            color: const Color(0xFF4CAF50),
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Completed',
                            style: TextStyle(
                              color: const Color(0xFF4CAF50),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }



  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    
    final parts = name.split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }
} 