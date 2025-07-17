import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../constants/app_constants.dart';
import '../controllers/card_selection_controller.dart';
import '../controllers/contacts_controller.dart';
import '../screens/dashboard_screen.dart';
import '../utils/autotextsize.dart';
import '../utils/app_button.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/custom_snackbar.dart';

class SelectCardScreen extends StatefulWidget {
  const SelectCardScreen({super.key});

  @override
  State<SelectCardScreen> createState() => _SelectCardScreenState();
}

class _SelectCardScreenState extends State<SelectCardScreen> {
  final CardSelectionController _controller = Get.put(CardSelectionController());
  final ContactsController _contactsController = Get.put(ContactsController());

  @override
  void initState() {
    super.initState();
    // Request contact permission when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🔄 Requesting contact permission...');
      _contactsController.requestContactPermission();
    });
  }

  void _handleDashboardNavigation() async {
    // Store selected cards and mark selection as completed
    await _controller.saveCardSelectionStatus();
    
    // Navigate to dashboard and remove all previous routes
    Get.offAll(() => const DashboardScreen());
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // Prevent back button press if coming from signup
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Color(AppConstants.backgroundColorHex),
        appBar: AppBar(
          title: MusaffaAutoSizeText.headlineMedium(
            'Select Your Credit Card',
            color: Color(AppConstants.primaryColorHex),
            fontWeight: FontWeight.w600,
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false, // Remove back button
        ),
        body: Stack(
          children: [
            Column(
              children: [
                // Search Box
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        onChanged: _controller.searchCards,
                        decoration: InputDecoration(
                          hintText: 'Search banks or cards...',
                          prefixIcon: Icon(
                            CupertinoIcons.search,
                            color: Colors.grey.shade400,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Color(AppConstants.primaryColorHex).withOpacity(0.1),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Color(AppConstants.primaryColorHex),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Obx(() {
                        if (_controller.selectedCards.isNotEmpty) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Text(
                              'Selected ${_controller.selectedCards.length} ${_controller.selectedCards.length == 1 ? 'card' : 'cards'}',
                              style: TextStyle(
                                color: Color(AppConstants.primaryColorHex),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      }),
                    ],
                  ),
                ),

                // Bank List
                Container(
                  constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.15),
                  child: Obx(() {
                    if (_controller.filteredBanks.isEmpty) {
                      return Center(
                        child: MusaffaAutoSizeText.bodyLarge(
                          'No banks found matching your search',
                          color: Color(AppConstants.primaryColorHex).withOpacity(0.7),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _controller.filteredBanks.length,
                      itemBuilder: (context, index) {
                        final bank = _controller.filteredBanks[index];
                        return Obx(() {
                          final isSelected = _controller.selectedBank.value == bank.bank;
                          return GestureDetector(
                            onTap: () => _controller.selectBank(bank.bank),
                            child: Container(
                              width: 100,
                              margin: const EdgeInsets.only(right: 16),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                      border: Border.all(
                                        color: isSelected
                                            ? Color(AppConstants.primaryColorHex)
                                            : Colors.transparent,
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 10,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: ClipOval(
                                      child: _buildBankLogo(bank.logo),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Flexible(
                                    child: SizedBox(
                                      width: 80,
                                      child: MusaffaAutoSizeText.bodySmall(
                                        bank.bank,
                                        color: Color(AppConstants.primaryColorHex),
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        });
                      },
                    );
                  }),
                ),

                // Card List
                Expanded(
                  child: Obx(() {
                    final cards = _controller.getSelectedBankCards();
                    final searchQuery = _controller.searchQuery.value.toLowerCase();
                    
                    if (_controller.selectedBank.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.credit_card_outlined,
                              size: 64,
                              color: Color(AppConstants.primaryColorHex).withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            MusaffaAutoSizeText.headlineSmall(
                              'Select a bank to view cards',
                              color: Color(AppConstants.primaryColorHex).withOpacity(0.7),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 32),
                              child: MusaffaAutoSizeText.bodyMedium(
                                'You can select multiple cards if you have more than one credit card',
                                color: Color(AppConstants.primaryColorHex).withOpacity(0.5),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    if (cards.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 64,
                              color: Color(AppConstants.primaryColorHex).withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            MusaffaAutoSizeText.headlineSmall(
                              'No matching cards found',
                              color: Color(AppConstants.primaryColorHex).withOpacity(0.7),
                              textAlign: TextAlign.center,
                            ),
                            if (searchQuery.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                                child: MusaffaAutoSizeText.bodyMedium(
                                  'Try a different search term or check the spelling',
                                  color: Color(AppConstants.primaryColorHex).withOpacity(0.5),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                ),
                              ),
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: cards.length,
                      itemBuilder: (context, index) {
                        final card = cards[index];
                        final isMatching = searchQuery.isNotEmpty &&
                            card.toLowerCase().contains(searchQuery);
                            
                        return Obx(() {
                          final isSelected = _controller.selectedCards.contains(card);
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Material(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () => _controller.toggleCardSelection(card),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected
                                          ? Color(AppConstants.primaryColorHex)
                                          : Color(AppConstants.primaryColorHex).withOpacity(0.1),
                                    ),
                                    color: isMatching 
                                        ? Color(AppConstants.primaryColorHex).withOpacity(0.05)
                                        : Colors.white,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            MusaffaAutoSizeText.headlineSmall(
                                              card,
                                              color: Color(AppConstants.primaryColorHex),
                                              maxLines: 1,
                                              fontWeight: isMatching ? FontWeight.w600 : FontWeight.normal,
                                            ),
                                            if (isSelected)
                                              MusaffaAutoSizeText.bodySmall(
                                                'Tap to unselect',
                                                color: Color(AppConstants.primaryColorHex).withOpacity(0.5),
                                              ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: isSelected
                                                ? Color(AppConstants.primaryColorHex)
                                                : Color(AppConstants.primaryColorHex).withOpacity(0.3),
                                            width: 2,
                                          ),
                                          color: isSelected
                                              ? Color(AppConstants.primaryColorHex)
                                              : Colors.transparent,
                                        ),
                                        child: isSelected
                                            ? const Icon(
                                                Icons.check,
                                                size: 16,
                                                color: Colors.white,
                                              )
                                            : null,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        });
                      },
                    );
                  }),
                ),

                // Bottom Button
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Obx(() => AppButton(
                    text: _controller.selectedCards.isEmpty
                        ? 'Select at least one card'
                        : 'Continue with ${_controller.selectedCards.length} ${_controller.selectedCards.length == 1 ? 'card' : 'cards'}',
                    onPressed: _controller.selectedCards.isEmpty
                        ? null
                        : _handleDashboardNavigation,
                  )),
                ),
              ],
            ),
            // Contact Permission Overlay
            Obx(() {
              if (_contactsController.isLoading.value) {
                return Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              if (_contactsController.permissionDenied.value) {
                return Container(
                  color: Colors.black.withOpacity(0.9),
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.contacts_rounded,
                        size: 80,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      const SizedBox(height: 24),
                      MusaffaAutoSizeText.headlineMedium(
                        'Contact Access Required',
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      MusaffaAutoSizeText.bodyLarge(
                        'To help you find your friends and earn referral rewards, we need access to your contacts.',
                        color: Colors.white.withOpacity(0.9),
                        textAlign: TextAlign.center,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: () async {
                          await _contactsController.requestContactPermission();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Grant Access',
                          style: TextStyle(
                            color: Color(AppConstants.primaryColorHex),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildBankLogo(String logoUrl) {
    if (logoUrl.toLowerCase().endsWith('.svg')) {
      return SvgPicture.network(
        logoUrl,
        width: 50,
        height: 50,
        placeholderBuilder: (context) => _buildLoadingIndicator(),
        fit: BoxFit.contain,
      );
    } else {
      return Image.network(
        logoUrl,
        width: 50,
        height: 50,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorWidget();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildLoadingIndicator();
        },
      );
    }
  }

  Widget _buildLoadingIndicator() {
    return Container(
      width: 50,
      height: 50,
      color: Colors.grey[200],
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            Color(AppConstants.primaryColorHex),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: 50,
      height: 50,
      color: Colors.grey[200],
      child: Icon(
        Icons.credit_card,
        color: Color(AppConstants.primaryColorHex),
      ),
    );
  }
} 