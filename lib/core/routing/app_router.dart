import 'package:data_gen_ai/screens/ai_chat/ai_chat_screen.dart';
import 'package:data_gen_ai/screens/browser/so_browser_screen.dart';
import 'package:data_gen_ai/screens/character/character_editor_screen.dart';
import 'package:data_gen_ai/screens/character/character_list_screen.dart';
import 'package:data_gen_ai/screens/generic_editor/generic_editor_screen.dart';
import 'package:data_gen_ai/screens/home/home_screen.dart';
import 'package:data_gen_ai/screens/item/item_editor_screen.dart';
import 'package:data_gen_ai/screens/item/item_list_screen.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  const AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: <RouteBase>[
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/characters',
        builder: (context, state) => const CharacterListScreen(),
      ),
      GoRoute(
        path: '/characters/edit',
        builder: (context, state) => const CharacterEditorScreen(),
      ),
      GoRoute(
        path: '/items',
        builder: (context, state) => const ItemListScreen(),
      ),
      GoRoute(
        path: '/items/edit',
        builder: (context, state) => const ItemEditorScreen(),
      ),
      GoRoute(
        path: '/browser',
        builder: (context, state) => const SOBrowserScreen(),
      ),
      GoRoute(
        path: '/generic',
        builder: (context, state) => const GenericEditorScreen(),
      ),
      GoRoute(path: '/ai', builder: (context, state) => const AIChatScreen()),
    ],
  );
}
