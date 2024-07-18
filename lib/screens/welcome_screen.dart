import 'package:flutter/material.dart';
import '../screens/signin_screen.dart';
import '../screens/signup_screen.dart';
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
                            fontFamily: 'Raleway',
                            fontSize: 25.0,
                            fontWeight: FontWeight.w600,
                            color: Color.fromRGBO(200, 155, 87, 1),
                          )),
                      TextSpan(
                          text: 'FLASHLEARN\n',
                          style: TextStyle(
                            fontFamily: 'Raleway',
                            fontSize: 45.0,
                            fontWeight: FontWeight.w900,
                            color: Color.fromRGBO(200, 155, 87, 1),
                          )),
                      TextSpan(
                          text: '\nLearn Smarter, Recall Faster',
                          style: TextStyle(
                            fontFamily: 'Raleway',
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: Color.fromRGBO(200, 155, 87, 1),
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
                  textColor: const Color.fromRGBO(200, 155, 87, 1),
                ),
              ),
              Expanded(
                child: WelcomeButton(
                  buttonText: 'Sign up',
                  onTap: const SignUpScreen(),
                  color: const Color.fromRGBO(200, 155, 87, 1),
                  textColor: const Color.fromRGBO(255, 255, 255, 1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
