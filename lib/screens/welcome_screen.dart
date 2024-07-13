import 'package:flutter/material.dart';
import '../screens/signin_screen.dart';
import '../screens/signup_screen.dart';
import '../theme/theme.dart';
import '../widgets/custom_scaffold.dart';
import '../widgets/welcome_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 0,
                horizontal: 40.0,
              ),
              child: Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    children: [
                      TextSpan(
                          text: 'Welcome to\n',
                          style: TextStyle(
                            fontSize: 25.0,
                            fontWeight: FontWeight.w600,
                            color: Color.fromRGBO(156, 222, 251, 1),
                          )),
                      TextSpan(
                          text: 'FLASHLEARN\n',
                          style: TextStyle(
                            fontSize: 45.0,
                            fontWeight: FontWeight.w600,
                            color: Color.fromRGBO(156, 222, 251, 1),
                          )),
                      TextSpan(
                          text: '\nEnter personal details to your account',
                          style: TextStyle(
                            fontSize: 10,
                            color: Color.fromRGBO(156, 222, 251, 1),
                          ))
                    ],
                  ),
                ),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: WelcomeButton(
                  buttonText: 'Sign in',
                  onTap: SignInScreen(),
                  color: Colors.transparent,
                  textColor: const Color.fromRGBO(156, 222, 251, 1),
                ),
              ),
              Expanded(
                child: WelcomeButton(
                  buttonText: 'Sign up',
                  onTap: const SignUpScreen(),
                  color: const Color.fromRGBO(156, 222, 251, 1),
                  textColor: const Color.fromRGBO(14, 23, 33, 1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
