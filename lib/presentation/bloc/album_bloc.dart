import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/album.dart';
import '../../data/models/photo.dart';
import '../../data/repositories/album_repository.dart';

// Events
abstract class AlbumEvent {}

class LoadAlbums extends AlbumEvent {}

class LoadPhotos extends AlbumEvent {
  final int albumId;
  LoadPhotos(this.albumId);
}

class LoadMorePhotos extends AlbumEvent {
  final int albumId;
  final int page;
  final int itemsPerPage;
  LoadMorePhotos(this.albumId, this.page, this.itemsPerPage);
}

// States
abstract class AlbumState {}

class AlbumInitial extends AlbumState {}

class AlbumLoading extends AlbumState {}

class PhotosLoadingMore extends AlbumState {
  final List<Photo> currentPhotos;
  PhotosLoadingMore(this.currentPhotos);
}

class AlbumLoaded extends AlbumState {
  final List<Album> albums;
  AlbumLoaded(this.albums);
}

class PhotosLoaded extends AlbumState {
  final List<Photo> photos;
  final bool hasReachedMax;
  PhotosLoaded({
    required this.photos,
    this.hasReachedMax = false,
  });

  PhotosLoaded copyWith({
    List<Photo>? photos,
    bool? hasReachedMax,
  }) {
    return PhotosLoaded(
      photos: photos ?? this.photos,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}

class AlbumError extends AlbumState {
  final String message;
  AlbumError(this.message);
}

// BLoC
class AlbumBloc extends Bloc<AlbumEvent, AlbumState> {
  final AlbumRepository repository;
  List<Photo> _cachedPhotos = [];

  AlbumBloc({required this.repository}) : super(AlbumInitial()) {
    on<LoadAlbums>((event, emit) async {
      emit(AlbumLoading());
      try {
        final albums = await repository.getAlbums();
        emit(AlbumLoaded(albums));
      } catch (e) {
        emit(AlbumError(e.toString()));
      }
    });

    on<LoadPhotos>((event, emit) async {
      emit(AlbumLoading());
      try {
        _cachedPhotos = await repository.getPhotosForAlbum(event.albumId);
        emit(PhotosLoaded(photos: _cachedPhotos));
      } catch (e) {
        emit(AlbumError(e.toString()));
      }
    });

    on<LoadMorePhotos>((event, emit) async {
      if (state is PhotosLoaded) {
        final currentState = state as PhotosLoaded;
        if (currentState.hasReachedMax) return;

        emit(PhotosLoadingMore(currentState.photos));
        try {
          final morePhotos = await repository.getPhotosForAlbum(
            event.albumId,
            page: event.page,
            itemsPerPage: event.itemsPerPage,
          );

          if (morePhotos.isEmpty) {
            emit(currentState.copyWith(hasReachedMax: true));
          } else {
            _cachedPhotos = [..._cachedPhotos, ...morePhotos];
            emit(PhotosLoaded(
              photos: _cachedPhotos,
              hasReachedMax: morePhotos.length < event.itemsPerPage,
            ));
          }
        } catch (e) {
          emit(AlbumError(e.toString()));
        }
      }
    });
  }
}