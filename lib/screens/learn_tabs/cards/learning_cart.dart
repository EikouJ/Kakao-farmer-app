import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Assurez-vous que ce chemin est correct

class LearnedCard extends StatelessWidget {
  const LearnedCard({
    Key? key,
    required this.currentLearned,
    required this.targetLearned,
    this.onPressed,
  }) : super(key: key);

  final int currentLearned;
  final int targetLearned;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(20);

    return Padding(
      padding: const EdgeInsets.only(right: 18, left: 18, bottom: 20, top: 8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: borderRadius,
        child: Ink(
          padding: const EdgeInsets.all(20),
          height: 110,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: borderRadius,
            boxShadow: [
              BoxShadow(
                color: Colors.grey[200]!,
                blurRadius: 10,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                width: 65,
                height: 65,
                decoration: BoxDecoration(
                  color: const Color(0xFF2F80ED).withValues(),
                  borderRadius: BorderRadius.circular(17),
                ),
                // child: SvgPicture.asset(
                //   width: 50,
                //   height: 50,
                // ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Learned today',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5.0),
                        child: Row(
                          children: [
                            RichText(
                              text: TextSpan(
                                text: currentLearned.toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  fontSize: 28,
                                ),
                                children: [
                                  TextSpan(
                                    text: "/$targetLearned",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 19,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'minutes',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontSize: 22,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
