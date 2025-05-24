import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'data/repositories/album_repository.dart';
import 'presentation/bloc/album_bloc.dart';
import 'presentation/router/app_router.dart';

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              AlbumBloc(repository: AlbumRepository())..add(LoadAlbums()),
        ),
      ],
      child: MaterialApp.router(
        title: 'Album Viewer',
        theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
        routerConfig: router,
      ),
    );
  }
}
