import 'package:flutter/material.dart';

class AppTextField extends StatefulWidget {
  final String? labelText;
  final String? hintText;
  final String? errorText;
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final bool obscureText;
  final bool enabled;
  final bool isMultiline;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int? maxLines;
  final int? maxLength;
  final FocusNode? focusNode;
  final VoidCallback? onTap;
  final bool readOnly;

  const AppTextField({
    super.key,
    this.labelText,
    this.hintText,
    this.errorText,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.obscureText = false,
    this.enabled = true,
    this.isMultiline = false,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.textInputAction,
    this.maxLines,
    this.maxLength,
    this.focusNode,
    this.onTap,
    this.readOnly = false,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField>
    with SingleTickerProviderStateMixin {
  late FocusNode _focusNode;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
    
    // Initialize shake animation for error state
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _shakeAnimation = Tween<double>(
      begin: 0.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticIn,
    ));
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    _shakeController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {});
  }

  void _triggerShakeAnimation() {
    _shakeController.forward().then((_) {
      _shakeController.reverse();
    });
  }

  @override
  void didUpdateWidget(AppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Trigger shake animation when error appears
    if (widget.errorText != null && 
        widget.errorText!.isNotEmpty && 
        oldWidget.errorText != widget.errorText) {
      _hasError = true;
      _triggerShakeAnimation();
    } else if (widget.errorText == null || widget.errorText!.isEmpty) {
      _hasError = false;
    }
  }

  Color _getBorderColor() {
    if (!widget.enabled) {
      return const Color.fromARGB(255, 161, 161, 161).withOpacity(0.5);
    }
    
    if (_hasError) {
      return Colors.red.shade400;
    }
    
    if (_focusNode.hasFocus) {
      return const Color(0xFF007AFF); // iOS blue
    }
    
    return const Color.fromARGB(255, 161, 161, 161);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Label
              if (widget.labelText != null) ...[
                Text(
                  widget.labelText!,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 8),
              ],
              
              // Text Field
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getBorderColor(),
                    width: 1.5,
                  ),
                ),
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  onChanged: widget.onChanged,
                  onSubmitted: widget.onSubmitted,
                  onTap: widget.onTap,
                  obscureText: widget.obscureText,
                  enabled: widget.enabled,
                  readOnly: widget.readOnly,
                  keyboardType: widget.keyboardType,
                  textInputAction: widget.textInputAction,
                  maxLines: widget.isMultiline 
                      ? (widget.maxLines ?? 4) 
                      : 1,
                  maxLength: widget.maxLength,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade800,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    hintStyle: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade400,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                    ),
                    prefixIcon: widget.prefixIcon,
                    prefixIconColor: const Color.fromARGB(255, 161, 161, 161),
                    suffixIcon: widget.suffixIcon,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical:  10,
                    ),
                    counterText: '', // Hide character counter
                  ),
                ),
              ),
              
              // Error Text
              if (widget.errorText != null && widget.errorText!.isNotEmpty) ...[
                const SizedBox(height: 8),
                AnimatedOpacity(
                  opacity: _hasError ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    widget.errorText!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.red.shade500,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
} 