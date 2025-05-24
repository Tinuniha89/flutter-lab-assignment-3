import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../main.dart';
import '../screens/album_list_screen.dart';
import '../screens/photo_list_screen.dart';

final GoRouter router = GoRouter(
  observers: [routeObserver],
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => MaterialPage<void>(
        key: state.pageKey,
        child: const AlbumListScreen(),
      ),
    ),
    GoRoute(
      path: '/photos/:albumId',
      pageBuilder: (context, state) => MaterialPage<void>(
        key: state.pageKey,
        child: PhotoListScreen(
          albumId: int.parse(state.pathParameters['albumId']!),
        ),
      ),
    ),
  ],
);
