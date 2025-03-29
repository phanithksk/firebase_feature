// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:firebase_feature/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:pinput/pinput.dart';

class VerifyOtpPage extends StatefulWidget {
  final String phone;
  final String verificationId;
  final int? forceResendingToken;

  const VerifyOtpPage({
    super.key,
    required this.phone,
    required this.verificationId,
    this.forceResendingToken,
  });

  @override
  State<VerifyOtpPage> createState() => _VerifyOtpPageState();
}

class _VerifyOtpPageState extends State<VerifyOtpPage> {
  int timeUntilNextResend = Duration.secondsPerMinute;

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    Timer.periodic(oneSec, (timer) {
      if (timeUntilNextResend < 1) {
        timer.cancel();
      } else {
        setState(() {
          timeUntilNextResend--;
        });
      }
    });
  }

  Future<void> resendOtp() async {
    AuthService().sendOtp(
      context: context,
      phoneNumber: widget.phone,
      forceResendingToken: widget.forceResendingToken,
    );
    startTimer();
  }

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 46,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      textStyle: const TextStyle(
        fontSize: 18,
        color: Colors.black54,
        fontFamily: "Karla",
        fontWeight: FontWeight.bold,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromRGBO(234, 239, 243, 1)),
        borderRadius: BorderRadius.circular(6),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(
        color: Colors.deepPurple[400]!.withOpacity(0.6),
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        border: Border.all(
          color: Colors.deepPurple[100]!.withOpacity(0.6),
        ),
        color: Colors.deepPurple[100]!.withOpacity(0.2),
      ),
    );

    return LoaderOverlay(
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                const FlutterLogo(
                  size: 120,
                  duration: Duration(seconds: 2),
                  curve: Curves.easeIn,
                ),
                const SizedBox(height: 60),
                const Text(
                  "To complete your phone number verification, please enter the 6 digit code sent to your phone number.",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  widget.phone,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Pinput(
                  length: 6,
                  pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: focusedPinTheme,
                  submittedPinTheme: submittedPinTheme,
                  onCompleted: (value) {
                    AuthService().verifyOtp(
                      context: context,
                      otp: value,
                      verificationId: widget.verificationId,
                    );
                  },
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: timeUntilNextResend == 0 ? resendOtp : null,
                  child: Text(
                    timeUntilNextResend == 0
                        ? "Resend code again"
                        : "Resend code in 00:${timeUntilNextResend.toString().padLeft(2, '0')}",
                  ),
                ),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
