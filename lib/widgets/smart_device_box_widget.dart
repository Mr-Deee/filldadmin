import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/app_constant.dart';

class SmartOptionBoxWidget extends StatelessWidget {
  final String smartDeviceName;
  final String iconPath;
  final bool isPowerOn;
  final Function(bool)? onChanged;

  const SmartOptionBoxWidget({
    Key? key,
    required this.smartDeviceName,
    required this.iconPath,
    required this.isPowerOn,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isPowerOn ? Colors.green : Colors.redAccent,
          borderRadius: BorderRadius.circular(24),
          /*boxShadow: [
            BoxShadow(
              color: isPowerOn ? Colors.white : Colors.grey.withOpacity(0.2),
              blurRadius: 2,
              spreadRadius: 2,
              offset: const Offset(0, 0),
            )
          ],*/
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
                    iconPath,
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
                      smartDeviceName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: isPowerOn ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ),
                Transform.rotate(
                  angle: -pi / 2,
                  child: CupertinoSwitch(
                    thumbColor: isPowerOn ? Colors.white : Colors.black,
                    trackColor: isPowerOn ? Colors.grey[400] : Colors.white,
                    activeColor: isPowerOn ? Colors.grey[400] : null,
                    value: isPowerOn,
                    onChanged: onChanged,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}