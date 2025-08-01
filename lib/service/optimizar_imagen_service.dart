// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

class ImageOptimizationService {
  static const int maxSizeInBytes = 5 * 1024 * 1024; // 5MB
  static const int initialQuality = 85;
  static const int minQuality = 30;
  static const int maxWidth = 1920;
  static const int maxHeight = 1920;

  /// Optimiza una imagen para que no exceda los 5MB
  static Future<File> optimizeImage(File imageFile) async {
    try {
      // Leer el archivo original
      final Uint8List originalBytes = await imageFile.readAsBytes();
      
      // Si ya es menor a 5MB, retornarlo tal como está
      if (originalBytes.length <= maxSizeInBytes) {
        print('Imagen ya optimizada: ${(originalBytes.length / 1024 / 1024).toStringAsFixed(2)}MB');
        return imageFile;
      }

      print('Optimizando imagen de ${(originalBytes.length / 1024 / 1024).toStringAsFixed(2)}MB');

      // Decodificar la imagen
      img.Image? image = img.decodeImage(originalBytes);
      if (image == null) {
        throw Exception('No se pudo decodificar la imagen');
      }

      // Redimensionar si es necesario
      image = _resizeIfNeeded(image);

      // Comprimir con diferentes calidades hasta conseguir el tamaño deseado
      File optimizedFile = await _compressToTargetSize(image, imageFile.path);
      
      final optimizedSize = await optimizedFile.length();
      print('Imagen optimizada: ${(optimizedSize / 1024 / 1024).toStringAsFixed(2)}MB');
      
      return optimizedFile;
    } catch (e) {
      print('Error optimizando imagen: $e');
      // Si hay error, retornar la imagen original
      return imageFile;
    }
  }

  /// Redimensiona la imagen si excede las dimensiones máximas
  static img.Image _resizeIfNeeded(img.Image image) {
    if (image.width <= maxWidth && image.height <= maxHeight) {
      return image;
    }

    // Calcular el factor de escala manteniendo la relación de aspecto
    double scaleWidth = maxWidth / image.width;
    double scaleHeight = maxHeight / image.height;
    double scale = scaleWidth < scaleHeight ? scaleWidth : scaleHeight;

    int newWidth = (image.width * scale).round();
    int newHeight = (image.height * scale).round();

    print('Redimensionando de ${image.width}x${image.height} a ${newWidth}x$newHeight');
    
    return img.copyResize(
      image,
      width: newWidth,
      height: newHeight,
      interpolation: img.Interpolation.linear,
    );
  }

  /// Comprime la imagen con diferentes calidades hasta conseguir el tamaño objetivo
  static Future<File> _compressToTargetSize(img.Image image, String originalPath) async {
    int quality = initialQuality;
    Uint8List? compressedBytes;
    
    // Obtener la extensión del archivo original
    String extension = originalPath.toLowerCase().split('.').last;
    
    while (quality >= minQuality) {
      // Codificar según el formato
      if (extension == 'png') {
        compressedBytes = Uint8List.fromList(img.encodePng(image));
      } else {
        // Para JPG y otros formatos, usar JPEG
        compressedBytes = Uint8List.fromList(img.encodeJpg(image, quality: quality));
      }
      
      print('Probando calidad $quality: ${(compressedBytes.length / 1024 / 1024).toStringAsFixed(2)}MB');
      
      // Si el tamaño es aceptable, usar esta compresión
      if (compressedBytes.length <= maxSizeInBytes) {
        break;
      }
      
      // Reducir calidad para la siguiente iteración
      quality -= 10;
    }

    // Si no se pudo conseguir el tamaño deseado, usar la última compresión
    compressedBytes ??= Uint8List.fromList(img.encodeJpg(image, quality: minQuality));

    // Crear archivo temporal optimizado
    final optimizedFile = await _createOptimizedFile(originalPath, compressedBytes);
    return optimizedFile;
  }

  /// Crea un archivo temporal con la imagen optimizada
  static Future<File> _createOptimizedFile(String originalPath, Uint8List optimizedBytes) async {
    try {
      // Crear nombre para archivo optimizado
      final originalFile = File(originalPath);
      final directory = originalFile.parent;
      final baseName = originalFile.uri.pathSegments.last.split('.').first;
      final extension = originalFile.uri.pathSegments.last.split('.').last;
      
      final optimizedPath = '${directory.path}/${baseName}_optimized.$extension';
      final optimizedFile = File(optimizedPath);
      
      // Escribir los bytes optimizados
      await optimizedFile.writeAsBytes(optimizedBytes);
      
      return optimizedFile;
    } catch (e) {
      print('Error creando archivo optimizado: $e');
      
      // Como fallback, sobrescribir el archivo original
      final originalFile = File(originalPath);
      await originalFile.writeAsBytes(optimizedBytes);
      return originalFile;
    }
  }

  /// Obtiene información de una imagen
  static Future<Map<String, dynamic>> getImageInfo(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) {
        throw Exception('No se pudo decodificar la imagen');
      }

      return {
        'width': image.width,
        'height': image.height,
        'sizeInBytes': bytes.length,
        'sizeInMB': (bytes.length / 1024 / 1024),
        'format': imageFile.path.split('.').last.toUpperCase(),
      };
    } catch (e) {
      print('Error obteniendo información de imagen: $e');
      return {};
    }
  }
}