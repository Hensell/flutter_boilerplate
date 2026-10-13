import 'package:flutter_boilerplate/features/about/presentation/views/about_page.dart';
import 'package:flutter_boilerplate/features/counter/counter.dart';
import 'package:flutter_boilerplate/features/notes/presentation/views/notes_page.dart';
import 'package:flutter_boilerplate/features/posts/presentation/views/posts_page.dart';
import 'package:flutter_boilerplate/features/settings/presentation/views/settings_page.dart';
import 'package:go_router/go_router.dart';

/// Creates an independent router owned by the application widget.
GoRouter createAppRouter() => GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const CounterPage()),
    GoRoute(path: '/posts', builder: (context, state) => const PostsPage()),
    GoRoute(path: '/notes', builder: (context, state) => const NotesPage()),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
    ),
    GoRoute(path: '/about', builder: (context, state) => const AboutPage()),
  ],
);
