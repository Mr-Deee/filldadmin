import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/app_constant.dart';

class PaymentToggleWidget extends StatefulWidget {
  final bool isMomoSelected;
  final bool isBankSelected;
  final Function(bool) onMomoChanged;
  final Function(bool) onBankChanged;

  PaymentToggleWidget({
    required this.isMomoSelected,
    required this.isBankSelected,
    required this.onMomoChanged,
    required this.onBankChanged,
  });

  @override
  _PaymentToggleWidgetState createState() => _PaymentToggleWidgetState();
}

class _PaymentToggleWidgetState extends State<PaymentToggleWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: widget.isMomoSelected ? Colors.green : Colors.redAccent,
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.symmetric(
          vertical: AppConstant.verticalPadding,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: Image.asset(
                    'momo_icon.png', // Replace with your Momo icon path
                    height: 75,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 20.0,
                    ),
                    child: Text(
                      'Mobile Money', // Replace with your Momo text
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color:
                            widget.isMomoSelected ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ),
                Transform.rotate(
                  angle: -math.pi / 2,
                  child: CupertinoSwitch(
                    thumbColor:
                        widget.isMomoSelected ? Colors.white : Colors.black,
                    trackColor:
                        widget.isMomoSelected ? Colors.grey[400] : Colors.white,
                    activeColor:
                        widget.isMomoSelected ? Colors.grey[400] : null,
                    value: widget.isMomoSelected,
                    onChanged: widget.onMomoChanged,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20), // Add some spacing between toggle buttons
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: Image.asset(
                    'bank_icon.png', // Replace with your Bank icon path
                    height: 75,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 20.0,
                    ),
                    child: Text(
                      'Bank Payment', // Replace with your Bank text
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color:
                            widget.isBankSelected ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ),
                Transform.rotate(
                  angle: -math.pi / 2,
                  child: CupertinoSwitch(
                    thumbColor:
                        widget.isBankSelected ? Colors.white : Colors.black,
                    trackColor:
                        widget.isBankSelected ? Colors.grey[400] : Colors.white,
                    activeColor:
                        widget.isBankSelected ? Colors.grey[400] : null,
                    value: widget.isBankSelected,
                    onChanged: widget.onBankChanged,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
