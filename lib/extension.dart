import 'package:english_words/english_words.dart';

extension SeparateWords on WordPair {
  String get asSeparate =>
      '${first[0].toUpperCase()}${first.substring(1)} ${second[0].toUpperCase()}${second.substring(1)}';
}

