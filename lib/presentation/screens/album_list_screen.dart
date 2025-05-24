import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../main.dart';
import '../bloc/album_bloc.dart';

class AlbumListScreen extends StatefulWidget {
  const AlbumListScreen({super.key});

  @override
  State<AlbumListScreen> createState() => _AlbumListScreenState();
}

class _AlbumListScreenState extends State<AlbumListScreen> with RouteAware {
  @override
  void initState() {
    super.initState();
    // Load albums when screen is first created
    context.read<AlbumBloc>().add(LoadAlbums());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Reload albums when returning to this screen
    context.read<AlbumBloc>().add(LoadAlbums());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Albums')),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<AlbumBloc>().add(LoadAlbums());
        },
        child: BlocBuilder<AlbumBloc, AlbumState>(
          builder: (context, state) {
            if (state is AlbumLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is AlbumLoaded) {
              return ListView.builder(
                itemCount: state.albums.length,
                itemBuilder: (context, index) {
                  final album = state.albums[index];
                  return ListTile(
                    title: Text(album.title),
                    onTap: () {
                      context.push('/photos/${album.id}');
                    },
                  );
                },
              );
            } else if (state is AlbumError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<AlbumBloc>().add(LoadAlbums());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            return const Center(child: Text('No albums found'));
          },
        ),
      ),
    );
  }
}
