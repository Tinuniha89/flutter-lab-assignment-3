import 'package:go_router/go_router.dart';
import '../screens/album_list_screen.dart';
import '../screens/photo_list_screen.dart';

final GoRouter router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const AlbumListScreen()),
    GoRoute(
      path: '/photos/:albumId',
      builder: (context, state) =>
          PhotoListScreen(albumId: int.parse(state.pathParameters['albumId']!)),
    ),
  ],
);
