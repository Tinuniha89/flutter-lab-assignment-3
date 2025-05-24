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

// States
abstract class AlbumState {}

class AlbumInitial extends AlbumState {}

class AlbumLoading extends AlbumState {}

class AlbumLoaded extends AlbumState {
  final List<Album> albums;
  AlbumLoaded(this.albums);
}

class PhotosLoaded extends AlbumState {
  final List<Photo> photos;
  PhotosLoaded(this.photos);
}

class AlbumError extends AlbumState {
  final String message;
  AlbumError(this.message);
}

// BLoC
class AlbumBloc extends Bloc<AlbumEvent, AlbumState> {
  final AlbumRepository repository;

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
        final photos = await repository.getPhotosForAlbum(event.albumId);
        emit(PhotosLoaded(photos));
      } catch (e) {
        emit(AlbumError(e.toString()));
      }
    });
  }
}