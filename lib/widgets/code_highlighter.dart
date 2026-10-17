import 'package:flutter/material.dart';

class CodeHighlighter {
  static const _keywords = {
    'import',
    'class',
    'extends',
    'with',
    'implements',
    'return',
    'final',
    'const',
    'var',
    'void',
    'if',
    'else',
    'for',
    'while',
    'switch',
    'case',
    'new',
    'this',
    'super',
    'true',
    'false',
    'null',
    'async',
    'await',
    'static',
    'late',
    'required',
    'override',
    'get',
    'set',
    'in',
    'is',
  };

  static final _token = RegExp(
    r"(//.*)|('(?:[^'\\]|\\.)*'|"
    r'"(?:[^"\\]|\\.)*")|(@\w+)|(\b\d+(?:\.\d+)?\b)|(\b[A-Z]\w*\b)|(\b[a-z_]\w*\b)',
  );

  static const base = TextStyle(
    fontFamily: 'monospace',
    fontSize: 12.5,
    height: 1.55,
    color: Color(0xFFE4E4F0),
  );

  static TextSpan build(String code) {
    final spans = <TextSpan>[];
    var last = 0;

    for (final m in _token.allMatches(code)) {
      if (m.start > last) {
        spans.add(TextSpan(text: code.substring(last, m.start)));
      }

      final text = m.group(0)!;
      Color? color;
      if (m.group(1) != null) {
        color = const Color(0xFF6B7280);
      } else if (m.group(2) != null) {
        color = const Color(0xFFA3E635);
      } else if (m.group(3) != null) {
        color = const Color(0xFFFBBF24);
      } else if (m.group(4) != null) {
        color = const Color(0xFFFF9F68);
      } else if (m.group(5) != null) {
        color = const Color(0xFF22D3EE);
      } else if (_keywords.contains(text)) {
        color = const Color(0xFFC084FC);
      }

      spans.add(
        TextSpan(
          text: text,
          style: color == null ? null : TextStyle(color: color),
        ),
      );
      last = m.end;
    }

    if (last < code.length) spans.add(TextSpan(text: code.substring(last)));
    return TextSpan(style: base, children: spans);
  }
}
