import 'package:flutter/material.dart';
import 'package:muslim/core/theme/colors_manager.dart';
import 'package:muslim/features/onboarding/presentation/widgets/onboarding_item.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'package:muslim/features/main_layout/presentation/screens/main_screen.dart';
import 'package:muslim/features/onboarding/data/onboarding_data.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController controller = PageController();
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsManager.blackColor,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              /// Logo
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Image.asset("assets/logo.png", height: 100),
              ),

              /// Pages
              Expanded(
                child: PageView.builder(
                  controller: controller,
                  itemCount: onboardingList.length,
                  onPageChanged: (index) {
                    setState(() {
                      currentIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return OnboardingItem(model: onboardingList[index]);
                  },
                ),
              ),
              SizedBox(height: 20),

              /// Indicator
              SmoothPageIndicator(
                controller: controller,
                count: onboardingList.length,
                effect: const ExpandingDotsEffect(
                  activeDotColor: Color(0xffE2BE7F),
                  dotColor: Colors.grey,
                  dotHeight: 8,
                  dotWidth: 8,
                ),
              ),

              const SizedBox(height: 30),

              /// Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        controller.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeIn,
                        );
                      },
                      child: const Text(
                        "Back",
                        style: TextStyle(
                          color: Color(0xffE2BE7F),
                          fontSize: 16,
                        ),
                      ),
                    ),

                    TextButton(
                      onPressed: () {
                        if (currentIndex == onboardingList.length - 1) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MainScreen(),
                            ),
                          );
                        } else {
                          controller.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeIn,
                          );
                        }
                      },
                      child: Text(
                        currentIndex == onboardingList.length - 1
                            ? "Finish"
                            : "Next",
                        style: const TextStyle(
                          color: Color(0xffE2BE7F),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
