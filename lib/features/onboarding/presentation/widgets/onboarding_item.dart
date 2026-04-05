import 'package:flutter/material.dart';

import 'package:muslim/features/onboarding/data/models/onboarding_model.dart';

class OnboardingItem extends StatelessWidget {
  final OnBoardingModel model;

  const OnboardingItem({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 50),

        Expanded(child: Image.asset(model.image)),

        const SizedBox(height: 40),

        Text(
          model.title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xffE2BE7F),
          ),
        ),

        const SizedBox(height: 20),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Text(
            model.description,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, color: Color(0xffE2BE7F)),
          ),
        ),
      ],
    );
  }
}
