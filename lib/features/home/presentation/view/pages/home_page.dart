import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../widgets/brand_header_section.dart';
import '../widgets/hero_section.dart';
import '../widgets/primary_action_button.dart';
import '../../../../../../app/routes.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slate900,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final contentWidth = constraints.maxWidth * 0.80;
            final height = constraints.maxHeight;
            final spaceM  = height * 0.04;
            final spaceL  = height * 0.06;
            final spaceXL = height * 0.08;

            return Center(
              child: SingleChildScrollView(
                child: SizedBox(
                  width: contentWidth,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const BrandHeaderSection(),
                      SizedBox(height: spaceL),
                      const HeroSection(),
                      SizedBox(height: spaceXL),
                      PrimaryActionButton(
                        label: 'Iniciar sesión',
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.login);
                        },
                      ),
                      SizedBox(height: spaceM),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}