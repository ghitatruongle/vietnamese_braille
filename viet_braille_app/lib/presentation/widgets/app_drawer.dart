import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Navigation drawer cho ứng dụng.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  child: Image.asset(
                    'assets/icon/app_icon.png',
                    height: 36,
                    width: 36,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Vietnamese Braille',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Chuyển đổi văn bản sang chữ Braille',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          Semantics(
            label: 'Trang chủ - Chuyển đổi Braille',
            button: true,
            child: ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Trang chủ'),
              onTap: () => Navigator.pop(context),
            ),
          ),
          Semantics(
            label: 'Lịch sử chuyển đổi',
            button: true,
            child: ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Lịch sử'),
              onTap: () {
                Navigator.pop(context);
                context.push('/history');
              },
            ),
          ),
          Semantics(
            label: 'Chuyển Braille sang văn bản',
            button: true,
            child: ListTile(
              leading: const Icon(Icons.swap_horiz),
              title: const Text('Braille → Văn bản'),
              onTap: () {
                Navigator.pop(context);
                context.push('/braille-to-text');
              },
            ),
          ),
          Semantics(
            label: 'Chuyển đổi hàng loạt',
            button: true,
            child: ListTile(
              leading: const Icon(Icons.batch_prediction),
              title: const Text('Chuyển đổi hàng loạt'),
              onTap: () {
                Navigator.pop(context);
                context.push('/batch');
              },
            ),
          ),
          Semantics(
            label: 'Cài đặt ứng dụng',
            button: true,
            child: ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Cài đặt'),
              onTap: () {
                Navigator.pop(context);
                context.push('/settings');
              },
            ),
          ),
          const Divider(),
          Semantics(
            label: 'Học chữ Braille tương tác',
            button: true,
            child: ListTile(
              leading: const Icon(Icons.school),
              title: const Text('Học Braille'),
              onTap: () {
                Navigator.pop(context);
                context.push('/learn');
              },
            ),
          ),
          Semantics(
            label: 'Quiz kiểm tra kiến thức Braille',
            button: true,
            child: ListTile(
              leading: const Icon(Icons.quiz),
              title: const Text('Quiz Braille'),
              onTap: () {
                Navigator.pop(context);
                context.push('/quiz');
              },
            ),
          ),
        ],
      ),
    );
  }
}
