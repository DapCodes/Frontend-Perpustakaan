import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/post_model.dart';
import 'dart:typed_data';
import 'package:http_parser/http_parser.dart';

class PostService {
  static const String postUrl = 'http://127.0.0.1:8000/api/posts/';

  static Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  static Future<PostModel> listPosts() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse(postUrl),
      headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return PostModel.fromJson(data);
    } else {
      throw Exception('Failed to load posts');
    }
  }

  static Future<Map<String, dynamic>?> showPost(int postId) async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse('$postUrl$postId'),
        headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? data;
      }
      return null;
    } catch (e) {
      print('Error showPost: $e');
      return null;
    }
  }

  static Future<bool> createPost({
    required String title,
    required String content,
    required int status,
    required Uint8List coverBytes,
    required String coverName,
  }) async {
    try {
      final token = await getToken();
      final uri = Uri.parse(postUrl);
      final request = http.MultipartRequest('POST', uri);

      // Set form fields
      request.fields['title'] = title;
      request.fields['content'] = content;
      request.fields['status'] = status.toString();

      // Tentukan content type berdasarkan ekstensi file
      String extension = coverName.split('.').last.toLowerCase();
      MediaType contentType;

      switch (extension) {
        case 'jpg':
        case 'jpeg':
          contentType = MediaType('image', 'jpeg');
          break;
        case 'png':
          contentType = MediaType('image', 'png');
          break;
        case 'webp':
          contentType = MediaType('image', 'webp');
          break;
        default:
          contentType = MediaType('image', 'jpeg'); // default
      }

      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          coverBytes,
          filename: coverName,
          contentType: contentType,
        ),
      );

      request.headers['Authorization'] = 'Bearer $token';

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      //test dbug
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        try {
          final errorData = jsonDecode(response.body);
          print('Error: ${errorData['message']}');
        } catch (e) {
          print('Failed to parse error response');
        }
        return false;
      }
    } catch (e) {
      print('Exception in createPost: $e');
      return false;
    }
  }

  // Tambahkan method ini ke dalam class PostService yang sudah ada

  static Future<bool> updatePost({
    required int id,
    required String title,
    required String content,
    required int status,
    Uint8List? coverBytes, // Optional, jika tidak ingin ganti image
    String? coverName, // Optional, jika tidak ingin ganti image
  }) async {
    try {
      final token = await getToken();
      final uri = Uri.parse('${postUrl}$id'); // PUT /api/posts/{id}

      // Jika ada image baru, gunakan multipart request
      if (coverBytes != null && coverName != null) {
        final request = http.MultipartRequest(
            'POST', uri); // Laravel biasanya pakai POST dengan _method

        // Laravel method spoofing untuk PUT
        request.fields['_method'] = 'PUT';

        // Set form fields
        request.fields['title'] = title;
        request.fields['content'] = content;
        request.fields['status'] = status.toString();

        // Tentukan content type berdasarkan ekstensi file
        String extension = coverName.split('.').last.toLowerCase();
        MediaType contentType;

        switch (extension) {
          case 'jpg':
          case 'jpeg':
            contentType = MediaType('image', 'jpeg');
            break;
          case 'png':
            contentType = MediaType('image', 'png');
            break;
          case 'webp':
            contentType = MediaType('image', 'webp');
            break;
          default:
            contentType = MediaType('image', 'jpeg');
        }

        // Tambahkan file image
        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            coverBytes,
            filename: coverName,
            contentType: contentType,
          ),
        );

        request.headers['Authorization'] = 'Bearer $token';

        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        print('Update Response status: ${response.statusCode}');
        print('Update Response body: ${response.body}');

        return response.statusCode == 200;
      } else {
        // Jika tidak ada image baru, gunakan JSON request biasa
        final response = await http.put(
          uri,
          headers: {
            HttpHeaders.authorizationHeader: 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'title': title,
            'content': content,
            'status': status,
          }),
        );

        print('Update Response status: ${response.statusCode}');
        print('Update Response body: ${response.body}');

        return response.statusCode == 200;
      }
    } catch (e) {
      print('Exception in updatePost: $e');
      return false;
    }
  }

  static Future<bool> deletePost(int id) async {
    final token = await getToken();
    final response = await http.delete(
      Uri.parse('$postUrl$id'),
      headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
    );
    return response.statusCode == 200;
  }
}
