import 'package:http/http.dart' as http;

class FetchService {
    Future<String> fetch() async {
        const url = 'http://localhost:3000/';
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
            return response.body;
        } else {
            throw Exception('Failed to load data');
        }
    }
}