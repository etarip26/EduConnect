import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'dart:async';
import 'package:test_app/src/core/services/auth_service.dart';
import 'package:test_app/src/core/utils/snackbar_utils.dart';

class OtpPage extends StatefulWidget {
  final String email;
  const OtpPage({super.key, required this.email});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final auth = GetIt.instance<AuthService>();
  final _controller = TextEditingController();

  bool loading = false;
  bool resendLoading = false;
  bool otpSent = false;

  int countdownSeconds = 0;
  Timer? countdownTimer;

  @override
  void initState() {
    super.initState();
    _triggerOtpSend();
  }

  // Auto-trigger OTP send on page load
  Future<void> _triggerOtpSend() async {
    if (otpSent) return;

    try {
      setState(() => resendLoading = true);
      await auth.requestOtp();
      setState(() {
        otpSent = true;
        countdownSeconds = 600; // 10 minutes
        resendLoading = false;
      });
      _startCountdown();
      if (mounted) {
        showSnackBar(context, "OTP sent to your email");
      }
    } catch (e) {
      setState(() => resendLoading = false);
      if (mounted) {
        showSnackBar(context, "Failed to send OTP", isError: true);
      }
    }
  }

  void _startCountdown() {
    countdownTimer?.cancel();
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        countdownSeconds--;
      });

      if (countdownSeconds <= 0) {
        timer.cancel();
      }
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _controller.dispose();
    countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F9FC),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            width: 430,
            padding: const EdgeInsets.all(26),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              color: Colors.white,
              boxShadow: const [
                BoxShadow(
                  blurRadius: 40,
                  spreadRadius: -12,
                  color: Colors.black12,
                ),
              ],
            ),
            child: Column(
              children: [
                // ICON
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.mail_outline,
                    size: 40,
                    color: Colors.indigo,
                  ),
                ),

                const SizedBox(height: 20),

                // TITLE
                Text(
                  "Verify Your Email 📧",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey.shade900,
                  ),
                ),
                const SizedBox(height: 10),

                // EMAIL INFO
                Text(
                  "An OTP code has been sent to",
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.email,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.indigo,
                  ),
                ),

                const SizedBox(height: 40),

                // OTP INPUT LABEL
                const Text(
                  "Enter 6-Digit OTP",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),

                // OTP INPUT FIELD
                SizedBox(
                  width: 200,
                  child: TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 32,
                      letterSpacing: 16,
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: InputDecoration(
                      hintText: "000000",
                      counterText: "",
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Colors.indigo,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // VERIFY BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: loading ? null : _verify,
                    child: loading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            "Verify OTP",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 24),

                // COUNTDOWN / RESEND OTP
                if (countdownSeconds > 0)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8DC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.amber.shade300),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.schedule,
                          color: Colors.amber,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Resend in ${_formatTime(countdownSeconds)}",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.amber,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  TextButton(
                    onPressed: resendLoading ? null : _resendOtp,
                    child: resendLoading
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            "Didn't receive code? Resend OTP",
                            style: TextStyle(
                              color: Colors.indigo,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                  ),

                const SizedBox(height: 16),

                // BACK TO LOGIN
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Back to Login",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------------------
  // VERIFY OTP
  // --------------------------------------------------------------
  Future<void> _verify() async {
    final code = _controller.text.trim();

    if (code.isEmpty) {
      showSnackBar(context, "Please enter the OTP", isError: true);
      return;
    }

    if (code.length != 6) {
      showSnackBar(context, "OTP must be 6 digits", isError: true);
      return;
    }

    setState(() => loading = true);

    try {
      await auth.verifyOtp(code);

      if (!auth.isVerified) {
        throw Exception("Verification failed — please try again.");
      }

      if (!mounted) return;
      showSnackBar(context, "Email verified successfully! 🎉");

      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.pushReplacementNamed(context, "/dashboard");
        }
      });
    } catch (e) {
      if (!mounted) return;
      showSnackBar(context, e.toString(), isError: true);
    }

    setState(() => loading = false);
  }

  // --------------------------------------------------------------
  // RESEND OTP
  // --------------------------------------------------------------
  Future<void> _resendOtp() async {
    setState(() => resendLoading = true);

    try {
      await auth.requestOtp();
      if (!mounted) return;
      showSnackBar(context, "OTP re-sent to your email ✓");

      setState(() {
        countdownSeconds = 600; // Reset 10-minute countdown
        resendLoading = false;
      });

      _startCountdown();
    } catch (e) {
      if (!mounted) return;
      showSnackBar(context, e.toString(), isError: true);
      setState(() => resendLoading = false);
    }
  }
}
