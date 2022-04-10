import 'package:meta/meta.dart';

class Images {
  final String? idImage;
  final String heading;
  final String body;
  final List<dynamic> url;

  const Images({
    this.idImage,
    required this.heading,
    required this.body,
    required this.url,
  });

  static Images fromJson(Map<String, dynamic> json) => Images(
        idImage: json['idImage'],
        heading: json['heading'],
        body: json['body'],
        url: json['url'],
      );

  Map<String, dynamic> toJson() => {
        'idImage': idImage,
        'heading': heading,
        'body': body,
        'url': url,
      };
}
