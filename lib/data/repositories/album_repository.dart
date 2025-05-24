import '../models/album.dart';
import '../models/photo.dart';
import '../services/api_service.dart';

class AlbumRepository {
  final ApiService _apiService = ApiService();
  final Map<int, List<Photo>> _photoCache = {};

  Future<List<Album>> getAlbums() async {
    return await _apiService.getAlbums();
  }

  Future<List<Photo>> getPhotosForAlbum(int albumId, {int page = 1, int itemsPerPage = 20}) async {
    if (page == 1) {
      _photoCache.remove(albumId); // Clear cache when refreshing
    }

    if (_photoCache.containsKey(albumId)) {
      final cachedPhotos = _photoCache[albumId]!;
      final startIndex = (page - 1) * itemsPerPage;
      if (startIndex < cachedPhotos.length) {
        final endIndex = startIndex + itemsPerPage;
        return cachedPhotos.sublist(startIndex, endIndex.clamp(0, cachedPhotos.length));
      }
    }

    final photos = await _apiService.getPhotosForAlbum(albumId);
    
    if (page == 1) {
      _photoCache[albumId] = photos;
    } else {
      _photoCache[albumId] = [...?_photoCache[albumId], ...photos];
    }

    final startIndex = (page - 1) * itemsPerPage;
    if (startIndex < photos.length) {
      final endIndex = startIndex + itemsPerPage;
      return photos.sublist(startIndex, endIndex.clamp(0, photos.length));
    }
    
    return [];
  }

  void clearCache() {
    _photoCache.clear();
  }
}