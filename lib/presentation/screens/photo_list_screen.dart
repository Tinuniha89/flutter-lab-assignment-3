import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_lab_assignment_3/data/models/photo.dart';
import '../bloc/album_bloc.dart';

class PhotoListScreen extends StatefulWidget {
  final int albumId;

  const PhotoListScreen({super.key, required this.albumId});

  @override
  State<PhotoListScreen> createState() => _PhotoListScreenState();
}

class _PhotoListScreenState extends State<PhotoListScreen> {
  final ScrollController _scrollController = ScrollController();
  static const int _itemsPerPage = 20;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Use existing Bloc instance and load initial photos
    context.read<AlbumBloc>().add(LoadPhotos(widget.albumId));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      _currentPage++;
      context.read<AlbumBloc>().add(
        LoadMorePhotos(widget.albumId, _currentPage, _itemsPerPage),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photos'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _currentPage = 1;
          context.read<AlbumBloc>().add(LoadPhotos(widget.albumId));
        },
        child: BlocBuilder<AlbumBloc, AlbumState>(
          builder: (context, state) {
            if (state is AlbumLoading && _currentPage == 1) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is PhotosLoaded) {
              return CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1.0,
                          mainAxisSpacing: 8.0,
                          crossAxisSpacing: 8.0,
                        ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      if (index >= state.photos.length) {
                        return null;
                      }
                      final photo = state.photos[index];
                      return PhotoCard(photo: photo);
                    }, childCount: state.photos.length),
                  ),
                  if (state is PhotosLoadingMore)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ),
                ],
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
                        context.read<AlbumBloc>().add(
                          LoadPhotos(widget.albumId),
                        );
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class PhotoCard extends StatelessWidget {
  final Photo photo;

  const PhotoCard({super.key, required this.photo});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Hero(
              tag: 'photo_${photo.id}',
              child: CachedNetworkImage(
                imageUrl: photo.url,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(
                      Icons.image_not_supported,
                      size: 40,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              photo.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
