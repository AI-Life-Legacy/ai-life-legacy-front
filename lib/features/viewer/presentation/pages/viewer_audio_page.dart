import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ai_life_legacy/app/core/theme/app_theme.dart';

class ViewerAudioPage extends StatefulWidget {
  const ViewerAudioPage({super.key});

  @override
  State<ViewerAudioPage> createState() => _ViewerAudioPageState();
}

class _ViewerAudioPageState extends State<ViewerAudioPage> {
  int _sec = 0;
  Timer? _timer;
  final Random _random = Random();
  late List<double> _heights;

  @override
  void initState() {
    super.initState();
    _heights = List.generate(12, (_) => 10.0 + _random.nextDouble() * 30.0);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _sec++;
        _heights = List.generate(12, (_) => 10.0 + _random.nextDouble() * 30.0);
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.close, color: AppTheme.text, size: 20),
                  onPressed: () => Get.back(),
                ),
              ),
            ),
            
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '듣고 있어요...',
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.text,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '00:${_sec.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                        color: AppTheme.textSec,
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    // Audio Bars
                    SizedBox(
                      height: 40,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: _heights.map((h) {
                          return Container(
                            width: 4,
                            height: h,
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            decoration: BoxDecoration(
                              color: AppTheme.cta,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    
                    const SizedBox(height: 60),
                    
                    // Stop Button
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: const BoxDecoration(
                          color: AppTheme.errorBg,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: AppTheme.error,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
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
}
