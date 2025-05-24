import '../models/album.dart';
import '../models/photo.dart';
import '../services/api_service.dart';

class AlbumRepository {
  final ApiService _apiService = ApiService();

  Future<List<Album>> getAlbums() async {
    return await _apiService.getAlbums();
  }

  Future<List<Photo>> getPhotosForAlbum(int albumId) async {
    return await _apiService.getPhotosForAlbum(albumId);
  }
}