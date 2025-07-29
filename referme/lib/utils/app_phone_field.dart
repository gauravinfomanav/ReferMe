import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class AppPhoneField extends StatefulWidget {
  final TextEditingController? controller;
  final TextEditingController? countryCodeController;
  final FocusNode? focusNode;
  final String? errorText;
  final String labelText;
  final String hintText;
  final TextInputAction? textInputAction;
  final Function(String)? onSubmitted;
  final Function(String)? onChanged;
  final bool enabled;

  const AppPhoneField({
    super.key,
    this.controller,
    this.countryCodeController,
    this.focusNode,
    this.errorText,
    this.labelText = 'Phone Number',
    this.hintText = 'Enter phone number',
    this.textInputAction,
    this.onSubmitted,
    this.onChanged,
    this.enabled = true,
  });

  @override
  State<AppPhoneField> createState() => _AppPhoneFieldState();
}

class _AppPhoneFieldState extends State<AppPhoneField> {
  late FocusNode _focusNode;
  late TextEditingController _countryCodeController;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
    _countryCodeController = widget.countryCodeController ?? TextEditingController(text: '+91');
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    if (widget.countryCodeController == null) {
      _countryCodeController.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {});
  }

  @override
  void didUpdateWidget(AppPhoneField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.errorText != null && 
        widget.errorText!.isNotEmpty && 
        oldWidget.errorText != widget.errorText) {
      _hasError = true;
    } else if (widget.errorText == null || widget.errorText!.isEmpty) {
      _hasError = false;
    }
  }

  Color _getBorderColor() {
    if (!widget.enabled) {
      return const Color.fromARGB(255, 164, 163, 163).withOpacity(0.5);
    }
    
    if (_hasError) {
      return Colors.red.shade400;
    }
    
    if (_focusNode.hasFocus) {
      return const Color(0xFF007AFF); // iOS blue
    }
    
    return const Color.fromARGB(255, 164, 163, 163);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          widget.labelText,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 8),
        
        // Phone Field
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _getBorderColor(),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              // Country Code Input
              Container(
                width: 70,
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      color: _getBorderColor(),
                      width: 1.5,
                    ),
                  ),
                ),
                child: TextField(
                  controller: _countryCodeController,
                  enabled: widget.enabled,
                  keyboardType: TextInputType.phone,
                  textAlign: TextAlign.center,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[+\d]')),
                    LengthLimitingTextInputFormatter(4),
                  ],
                  style: TextStyle(
                    fontSize: 16,
                    color: widget.enabled ? Colors.grey.shade800 : Colors.grey.shade400,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
              
              // Phone Number Field
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  enabled: widget.enabled,
                  keyboardType: TextInputType.phone,
                  textInputAction: widget.textInputAction,
                  onSubmitted: widget.onSubmitted,
                  onChanged: widget.onChanged,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
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
                    
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
            ],
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
    );
  }
} 