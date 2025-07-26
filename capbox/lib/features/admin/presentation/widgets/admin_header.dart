import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/user_display_service.dart';

class AdminHeader extends StatelessWidget {
  const AdminHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Stack(
          alignment: Alignment.centerLeft,
          children: [
            Image.asset(
              'assets/icons/nombre_card.png',
              height: 90,
              width: 260,
              fit: BoxFit.fill,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 46, bottom: 11),
              child: FutureBuilder<UserDisplayData>(
                future:
                    context
                        .read<UserDisplayService>()
                        .getCurrentUserDisplayData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircleAvatar(
                          backgroundColor: Colors.red,
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Cargando...',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    );
                  }

                  final userData = snapshot.data;
                  final displayName = userData?.displayName ?? 'Gym Admin';
                  final avatarInitial = userData?.avatarInitial ?? 'G';

                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.red,
                        child: Text(
                          avatarInitial,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        displayName,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
        Padding(
          padding: const EdgeInsets.only(right: 4),
          child: Image.asset('assets/images/logo.png', height: 56),
        ),
      ],
    );
  }
}
