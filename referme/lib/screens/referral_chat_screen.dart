import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/referral_controller.dart';
import '../constants/app_constants.dart';
import '../utils/autotextsize.dart';
import '../models/referral_model.dart';
import '../utils/custom_snackbar.dart';

class ReferralChatScreen extends StatefulWidget {
  final Referral referral;
  final bool isFromReceivedTab;
  
  const ReferralChatScreen({
    super.key,
    required this.referral,
    this.isFromReceivedTab = false,
  });

  @override
  State<ReferralChatScreen> createState() => _ReferralChatScreenState();
}

class _ReferralChatScreenState extends State<ReferralChatScreen> {
  final ReferralController referralController = Get.find<ReferralController>();
  final TextEditingController _linkController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();
  final RxBool _hasSentLink = false.obs;
  final RxString _sentLinkMessage = ''.obs;
  final RxString _sentLinkUrl = ''.obs;

  @override
  void initState() {
    super.initState();
    // Clear any existing chat data and load new referral details
    WidgetsBinding.instance.addPostFrameCallback((_) {
      referralController.currentReferral.value = null; // Clear previous chat
      referralController.getReferralDetails(widget.referral.id);
    });
  }

  @override
  void dispose() {
    _linkController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final otherUser = widget.referral.otherUser;
    if (otherUser == null) {
      return Scaffold(
        backgroundColor: Color(AppConstants.backgroundColorHex),
        body: const Center(
          child: Text('User information not available'),
        ),
      );
    }

    // Determine user role based on referral data
    final isTargetUser = widget.referral.userRole == 'target' || 
                        (widget.referral.type == 'received') ||
                        widget.isFromReceivedTab;
    final userRole = isTargetUser ? 'target' : 'requester';

    return Scaffold(
      backgroundColor: Color(AppConstants.backgroundColorHex),
      appBar: AppBar(
        backgroundColor: Color(AppConstants.backgroundColorHex),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Color(AppConstants.primaryColorHex),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Row(
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
              padding: const EdgeInsets.all(1),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 16,
                child: Text(
                  _getInitials(_getDisplayName(otherUser.name)),
                  style: TextStyle(
                    color: Color(AppConstants.primaryColorHex),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getDisplayName(otherUser.name),
                    style: TextStyle(
                      color: Color(AppConstants.primaryColorHex),
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    referralController.getReferralStatusText(widget.referral.status),
                    style: TextStyle(
                      color: referralController.getReferralStatusColor(widget.referral.status),
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Status Banner
          _buildStatusBanner(),
          
          // Chat Content
          Expanded(
              child: Column(
                children: [
                // Messages Area
                Expanded(
                  child: GetBuilder<ReferralController>(
                    builder: (controller) {
                      final currentReferral = controller.currentReferral.value;
                      final chatHistory = currentReferral?.chatHistory ?? [];
                      
                      // Show loading if no current referral data yet, if loading this specific chat, or if current chat is different from widget chat
                      if (currentReferral == null || 
                          controller.isChatLoading.value ||
                          (currentReferral != null && currentReferral!.id != widget.referral.id)) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(AppConstants.primaryColorHex),
                  ),
                              ),
                  const SizedBox(height: 16),
                              Text(
                                'Loading chat...',
                                style: TextStyle(
                                  color: Color(AppConstants.primaryColorHex).withOpacity(0.7),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      
                      return ListView(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        children: [
                          // Show chat history from API
                          if (chatHistory.isNotEmpty) ...[
                            ...chatHistory.map((chatMessage) {
                                                          // Determine if message is from current user
                            final isFromMe = (widget.referral.userRole == 'requester' && chatMessage.senderId == widget.referral.requesterId) ||
                                           (widget.referral.userRole == 'target' && chatMessage.senderId == widget.referral.targetUserId);
                            
                            // Get the correct message title based on type
                            final messageTitle = chatMessage.type == 'referral_request' 
                                ? 'Request' 
                                : 'Referral';
                              
                              return Column(
                                children: [
                                                                  _buildMessageBubble(
                                  message: chatMessage.message,
                                  isFromMe: isFromMe,
                                  timestamp: chatMessage.createdAt,
                                  type: chatMessage.type == 'referral_request' ? 'request' : 'referral',
                                  messageTitle: messageTitle,
                                ),
                                  if (chatMessage.link != null) ...[
                                    const SizedBox(height: 12),
                                    _buildLinkBubble(chatMessage.link),
                                  ],
                                  const SizedBox(height: 16),
                                ],
                              );
                            }).toList(),
                          ] else ...[
                                                      // Fallback to old method if no chat history
                          _buildMessageBubble(
                            message: widget.referral.message,
                            isFromMe: widget.referral.userRole != 'target',
                            timestamp: widget.referral.createdAt,
                            type: 'request',
                            messageTitle: 'Request',
                          ),
                            const SizedBox(height: 16),
                          ],
                          
                          // Show link input form for pending referrals (only for target user)
                          if ((currentReferral?.status ?? widget.referral.status) == 'pending' && userRole == 'target' && !_hasSentLink.value)
                            _buildLinkInputForm(),
                          
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBanner() {
    Color bannerColor;
    IconData bannerIcon;
    String bannerText;
    
    switch (widget.referral.status) {
      case 'pending':
        bannerColor = Colors.orange;
        bannerIcon = Icons.schedule;
        bannerText = 'Waiting for referral link';
        break;
      case 'completed':
        bannerColor = const Color(0xFF4CAF50);
        bannerIcon = Icons.check_circle;
        bannerText = 'Referral completed';
        break;
      default:
        bannerColor = Colors.grey;
        bannerIcon = Icons.info;
        bannerText = 'Referral in progress';
    }
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
        color: bannerColor.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(
            color: bannerColor.withOpacity(0.2),
            width: 1,
          ),
        ),
                    ),
      child: Row(
        children: [
          Icon(
            bannerIcon,
            color: bannerColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            bannerText,
            style: TextStyle(
              color: bannerColor,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble({
    required String message,
    required bool isFromMe,
    required DateTime timestamp,
    required String type,
    required String messageTitle,
  }) {
    return Align(
      alignment: isFromMe ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isFromMe 
              ? Colors.white
              : Color(AppConstants.primaryColorHex),
          borderRadius: BorderRadius.circular(20).copyWith(
            bottomLeft: isFromMe ? const Radius.circular(4) : const Radius.circular(20),
            bottomRight: isFromMe ? const Radius.circular(20) : const Radius.circular(4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.person,
                  color: isFromMe ? Color(AppConstants.primaryColorHex).withOpacity(0.6) : Colors.white.withOpacity(0.8),
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  messageTitle,
                  style: TextStyle(
                    color: isFromMe ? Color(AppConstants.primaryColorHex).withOpacity(0.6) : Colors.white.withOpacity(0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                color: isFromMe ? Color(AppConstants.primaryColorHex) : Colors.white,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              referralController.formatDate(timestamp),
              style: TextStyle(
                color: isFromMe 
                    ? Color(AppConstants.primaryColorHex).withOpacity(0.5)
                    : Colors.white.withOpacity(0.7),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkBubble(String? link) {
    if (link == null) return const SizedBox.shrink();
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Color(AppConstants.primaryColorHex),
          borderRadius: BorderRadius.circular(20).copyWith(
            bottomLeft: const Radius.circular(4),
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
                Icon(
                  Icons.link_rounded,
                  color: Colors.white,
                  size: 16,
              ),
                const SizedBox(width: 6),
                    Text(
                      'Referral Link',
                      style: TextStyle(
                    color: Colors.white,
                        fontSize: 12,
                    fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
            const SizedBox(height: 12),
          Container(
              padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: Colors.white.withOpacity(0.2),
              ),
            ),
              child: GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: link));
                  CustomSnackBar.showSuccess(message: 'Link copied to clipboard!');
                },
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    link,
                    style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                        overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                    Icon(
                      Icons.copy_rounded,
                      color: Colors.white.withOpacity(0.7),
                      size: 18,
                    ),
                  ],
                    ),
                ),
              ),
            ],
          ),
      ),
    );
  }

  Widget _buildLinkInputForm() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Simple header
            Row(
              children: [
                Icon(
                  Icons.credit_card_rounded,
                    color: Color(AppConstants.primaryColorHex),
                    size: 20,
                  ),
                const SizedBox(width: 8),
                      Text(
                  'Send Credit Card Referral',
                        style: TextStyle(
                          color: Color(AppConstants.primaryColorHex),
                    fontWeight: FontWeight.w600,
                          fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Clean input field
            Container(
              decoration: BoxDecoration(
                color: Color(AppConstants.primaryColorHex).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _linkController.text.isNotEmpty
                      ? Color(AppConstants.primaryColorHex).withOpacity(0.3)
                      : Color(AppConstants.primaryColorHex).withOpacity(0.1),
                  ),
                ),
              child: TextFormField(
                controller: _linkController,
                decoration: InputDecoration(
                  hintText: 'Paste your credit card referral link here...',
                  hintStyle: TextStyle(
                    color: Color(AppConstants.primaryColorHex).withOpacity(0.5),
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                suffixIcon: _linkController.text.isNotEmpty
                    ? IconButton(
                          onPressed: () {
                            _linkController.clear();
                            setState(() {});
                          },
                        icon: Icon(
                          Icons.clear_rounded,
                          color: Color(AppConstants.primaryColorHex).withOpacity(0.6),
                            size: 18,
                        ),
                      )
                    : null,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a referral link';
                }
                
                final uri = Uri.tryParse(value);
                if (uri == null || !uri.hasAbsolutePath) {
                  return 'Please enter a valid URL';
                }
                
                if (uri.scheme.toLowerCase() != 'https') {
                  return 'URL must use HTTPS protocol';
                }
                
                if (uri.host.isEmpty) {
                  return 'Please enter a valid domain';
                }
                
                return null;
              },
              onChanged: (value) {
                  setState(() {});
              },
              ),
            ),
            const SizedBox(height: 12),
            
            // Simple send button
            SizedBox(
              width: double.infinity,
              child: Obx(() {
                return ElevatedButton(
                  onPressed: _linkController.text.isNotEmpty && !referralController.isLoading.value
                      ? _sendReferralLink
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _linkController.text.isNotEmpty
                        ? Color(AppConstants.primaryColorHex)
                        : Color(AppConstants.primaryColorHex).withOpacity(0.3),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: _linkController.text.isNotEmpty ? 2 : 0,
                  ),
                  child: referralController.isLoading.value
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Sending...',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.send_rounded,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Send Referral',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _sendReferralLink() async {
    if (!_formKey.currentState!.validate()) return;

    final linkUrl = _linkController.text.trim();

    // Show loading state
    referralController.isChatLoading.value = true;

    final success = await referralController.sendReferralLink(
      widget.referral.id,
      linkUrl,
    );

    if (success) {
      // Clear input and hide form instantly
      _linkController.clear();
      
      // Refresh referral details to get updated chat history
      await referralController.getReferralDetails(widget.referral.id);
      
      // Scroll to bottom to show the new message
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
    
    referralController.isChatLoading.value = false;
  }

  void _copyToClipboard(String link) async {
    await Clipboard.setData(ClipboardData(text: link));
    CustomSnackBar.showSuccess(message: 'Link copied to clipboard!');
  }

  void _openLink(String link) async {
    try {
      final uri = Uri.parse(link);
      // For now, just show a success message
      CustomSnackBar.showSuccess(message: 'Link opened: $link');
    } catch (e) {
      CustomSnackBar.showError(message: 'Could not open link');
    }
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    
    final parts = name.split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  String _getDisplayName(String name) {
    // Check if this user is a global user from the referral data
    if (widget.referral.isGlobalUser) {
      return _maskName(name);
    }
    
    return name;
  }

  String _maskName(String name) {
    if (name.isEmpty) return '*****';
    
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      // For names with multiple words like "Gaurav Malode"
      final firstName = parts[0];
      final lastName = parts[1];
      
      String maskedFirstName = '';
      if (firstName.length <= 3) {
        maskedFirstName = firstName;
      } else {
        maskedFirstName = '${firstName.substring(0, 3)}***';
      }
      
      String maskedLastName = '';
      if (lastName.length <= 3) {
        maskedLastName = '***${lastName}';
      } else {
        maskedLastName = '***${lastName.substring(lastName.length - 3)}';
      }
      
      return '$maskedFirstName $maskedLastName';
    } else {
      // For single word names like "Gaurav"
      if (name.length <= 3) {
        return name;
      } else {
        return '${name.substring(0, 3)}***';
      }
    }
  }
} 