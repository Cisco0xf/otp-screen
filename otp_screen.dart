import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:switcher/commons/app_commons.dart';
import 'package:switcher/commons/app_dimensions.dart';
import 'package:switcher/commons/gaps.dart';
import 'package:switcher/commons/navigator_key.dart';
import 'package:switcher/constants/colors.dart';
import 'package:switcher/presentaition_layer/widgets/clicker.dart';
import 'package:toastification/toastification.dart';

// The Body of the Screen

class OTPScreen extends ConsumerStatefulWidget {
  const OTPScreen({super.key});

  @override
  ConsumerState<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends ConsumerState<OTPScreen> {
  late final OTPManager otp;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    otp.disposeControllerList;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ControllersList otpControllers = ref.watch(otpManagerProvider);

    return Scaffold(
      backgroundColor: ColorsSwitcher.background2,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          gapH(0.06),
          const CustomBackButton(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  gapH(0.04),
                  const LockLogo(),
                  gapH(0.03),
                  const Text(
                    otpCode,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  gapH(0.02),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      insertCodeTxt,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  gapH(0.04),
                  Form(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        for (int i = 0; i < otpControllers.length; i++) ...{
                          OtpField(controller: otpControllers[i]),
                        }
                      ],
                    ),
                  ),
                  gapH(0.05),
                  const Text(
                    didNot,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const ResendOTP(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Back Button in the Top Left of the Screen

class CustomBackButton extends StatelessWidget {
  const CustomBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        gapW(0.06),
        CircleAvatar(
          radius: 25,
          backgroundColor: Colors.grey,
          child: Clicker(
            isCirclar: true,
            onClick: () {
              popRoute();
            },
            child: CircleAvatar(
              radius: 22,
              backgroundColor: ColorsSwitcher.background2,
              child: const Icon(Icons.arrow_back),
            ),
          ),
        ),
      ],
    );
  }
}

// The Lock Logo

class LockLogo extends StatelessWidget {
  const LockLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: const Color(0xFFEBD3F8).withOpacity(0.6),
      radius: 50,
      child: const CircleAvatar(
        radius: 30,
        backgroundColor: Color(0xFF121212),
        child: Icon(
          Icons.lock,
          color: Colors.deepPurple,
        ),
      ),
    );
  }
}

// OTP Field

class OtpField extends StatelessWidget {
  const OtpField({
    super.key,
    required this.controller,
  });

  final TextEditingController controller;

  bool get hasTargetValue => controller.text.length == 1;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: context.screenWidth * .13,
      child: TextFormField(
        controller: controller,
        inputFormatters: <TextInputFormatter>[
          LengthLimitingTextInputFormatter(1),
        ],
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
        textAlign: TextAlign.center,
        textAlignVertical: const TextAlignVertical(y: 1.0),
        onChanged: (String? target) {
          if (target!.length == 1) {
            FocusScope.of(context).nextFocus();
          } else {
            FocusScope.of(context).previousFocus();
          }
        },
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFF121212),
          hintText: "-",
          hintStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: borderRadius(10.0),
            borderSide: const BorderSide(
              color: Colors.grey,
              width: 1.3,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: borderRadius(10.0),
            borderSide: const BorderSide(
              color: Colors.purple,
              width: 2.0,
            ),
          ),
        ),
      ),
    );
  }
}

// Resent OTP Widget with the counter and its button

class ResendOTP extends StatefulWidget {
  const ResendOTP({super.key});

  @override
  State<ResendOTP> createState() => _ResendOTPState();
}

class _ResendOTPState extends State<ResendOTP> {
  static const int _target = 15;
  static const int _trials = 3;

  int duration = _target;
  int numberOfTrial = _trials;

  bool isButtonActive = false;
  bool showCounter = true;

  void get startCounter {
    setState(() => isButtonActive = false);
    if (numberOfTrial == 0) {
      return;
    }

    if (numberOfTrial < _trials) {
      showToastification(description: sendOTP);
    }

    setState(() => showCounter = true);

    numberOfTrial--;

    log("Counter Start");

    Timer.periodic(
      const Duration(seconds: 1),
      (counter) {
        if (duration > 0) {
          setState(
            () {
              log("Current Value :$duration");
              duration--;
            },
          );
        } else if (duration <= 0) {
          setState(
            () {
              counter.cancel();
              duration = _target;
              showCounter = false;
              if (!(numberOfTrial == 0)) {
                isButtonActive = true;
              }

              log(buttonActivationLog);
            },
          );
        }
      },
    );
  }

  String get formattedCounter {
    if (duration >= 10) {
      return "00:$duration";
    }
    return "00:0$duration";
  }

  // Manage Otp

  @override
  void initState() {
    startCounter;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        return Column(
          children: <Widget>[
            gapH(0.02),
            TextButton(
              onPressed: () {
                if (!isButtonActive) {
                  return;
                }

                startCounter;
              },
              style: const ButtonStyle(
                overlayColor: WidgetStatePropertyAll(
                  Colors.transparent,
                ),
              ),
              child: Text(
                "Resend it",
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: isButtonActive ? Colors.blue : Colors.grey,
                ),
              ),
            ),
            if (showCounter) ...{
              SizedBox(
                height: context.screenHeight * .05,
                child: Text(
                  formattedCounter,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
            } else ...{
              SizedBox(
                height: context.screenHeight * .05,
              )
            },
            SubmitButton(
              onSubmit: () {
                ref.read(otpManagerProvider.notifier).doSomethingWithTheCode;
              },
            ),
          ],
        );
      },
    );
  }
}

// Submit Button at the end of the Column

class SubmitButton extends StatelessWidget {
  const SubmitButton({
    super.key,
    required this.onSubmit,
  });

  final void Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: context.screenHeight * .07,
      width: context.screenWidth * .7,
      child: MaterialButton(
        onPressed: onSubmit,
        color: Colors.green,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius(30),
        ),
        child: const Text("Submit"),
      ),
    );
  }
}

// Show Toastifcation message after a specific action

void showToastification({
  String? title,
  required String description,
  ToastificationType type = ToastificationType.info,
  bool showProgressBar = false,
}) {
  final BuildContext context = navigatorKey.currentContext as BuildContext;

  toastification.show(
    context: context,
    title: title != null
        ? Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          )
        : null,
    description: Text(
      description,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
    ),
    padding: padding(5.0),
    showProgressBar: showProgressBar,
    type: type,
    applyBlurEffect: true,
    alignment: Alignment.topCenter,
    closeButtonShowType: CloseButtonShowType.none,
    animationDuration: const Duration(milliseconds: 500),
    autoCloseDuration: const Duration(milliseconds: 3000),
  );
}

// Code Texts that will be used in the presentaition layer

const String otpCode = "OTP Code";
const String insertCodeTxt =
    "Please insert the 6-digit code you receive on your email";
const String didNot = "Did not get the code ?";

const String insertFullCode =
    "The inserted code is not complete, please insert the 6-digit code";

const String goodCode = "The code has been submitted successully";
const String sendOTP =
    "We've sent a 6-digit verification code to your email address.";

const String buttonActivationLog = "Button is Active right now !!";

const String internetError = "Please check your internet connection";

const String disposeLog = " Controllers Has been disposed";
const String initLog = " Controllers Has been initialized";

// Improved Verssion of the OTP Code

typedef ControllersList = List<TextEditingController>;

class OTPManager extends Notifier<ControllersList> {
  static const int _numDigits = 6;

  // Initialize Controlles in build
  @override
  ControllersList build() {
    final ControllersList controllers = <TextEditingController>[
      for (int i = 0; i < _numDigits; i++) ...{
        TextEditingController(),
      }
    ];
    log(initLog);
    return controllers;
  }

  // Dispose controllers after use
  void get disposeControllerList {
    for (int i = 0; i < state.length; i++) {
      state[i].dispose();
    }

    log(disposeLog);
  }

  // Check that each controller has value
  bool get _checkIsFullCode {
    for (int c = 0; c < state.length; c++) {
      final bool emptyController = state[c].text.trim().isEmpty;

      if (emptyController) {
        return false;
      }
    }

    return true;
  }

  // Catch the full code after user submit
  String get _fullCode {
    String fullCode = "";

    for (int t = 0; t < state.length; t++) {
      final String otp = state[t].text.trim();
      fullCode = "$fullCode$otp";
    }

    log("Code : $fullCode");

    return fullCode;
  }

  // Clean the controllers in case I will not pop the screen
  void get clearControllers {
    for (int i = 0; i < state.length; i++) {
      state[i].clear();
    }
  }

  // Do something with the code after catch it like supabase verifing
  void get doSomethingWithTheCode {
    if (!_checkIsFullCode) {
      showToastification(
        description: insertFullCode,
        type: ToastificationType.error,
      );
      return;
    }

    try {
      log("The insertted code : $_fullCode");

      showToastification(
        title: "Code: $_fullCode",
        description: goodCode,
        type: ToastificationType.success,
      );

      clearControllers;
    } on SocketException {
      showToastification(
        description: internetError,
        type: ToastificationType.error,
      );
    } catch (error) {
      log("Error while verification: $error");
    } finally {
      clearControllers;
    }
  }
}

// Create a provider to access the notifer class

final otpManagerProvider = NotifierProvider<OTPManager, ControllersList>(
  OTPManager.new,
);
