import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/album_bloc.dart';

class AlbumListScreen extends StatelessWidget {
  const AlbumListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Albums')),
      body: BlocBuilder<AlbumBloc, AlbumState>(
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
                    context.push(
                      '/photos/${album.id}',
                    ); // Using GoRouter's push
                  },
                );
              },
            );
          } else if (state is AlbumError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: Text('No albums found'));
        },
      ),
    );
  }
}
