import 'dart:io';
import 'package:image_picker/image_picker.dart';

class MediaService {
  final ImagePicker _imagePicker = ImagePicker();

  MediaService();

  Future<File?> getMediaImageFromUserGallery() async {
    try {
      final XFile? _file =
          await _imagePicker.pickImage(source: ImageSource.gallery);

      if (_file != null) {
        print("Image selected: ${_file.path}");
        return File(_file.path);
      } else {
        print("No image selected");
      }
    } catch (e) {
      print("Error picking image: $e");
    }
    return null;
  }
}
