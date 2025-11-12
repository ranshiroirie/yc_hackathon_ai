String normalizeNickname(String value) => value.trim().toLowerCase();

String sanitizeForPartialMatch(String value) =>
    value.replaceAll(RegExp(r'[^a-z0-9]'), '');

bool hasPartialMatch(List<String> existingValues, String candidate) {
  if (candidate.isEmpty) {
    return false;
  }

  for (final value in existingValues) {
    if (isPartialMatch(value, candidate)) {
      return true;
    }
  }
  return false;
}

bool isPartialMatch(String a, String b) {
  if (a.isEmpty || b.isEmpty) {
    return false;
  }
  if (a == b) {
    return true;
  }

  if (a.contains(b) || b.contains(a)) {
    return true;
  }

  final sanitizedA = sanitizeForPartialMatch(a);
  final sanitizedB = sanitizeForPartialMatch(b);

  if (sanitizedA.isEmpty || sanitizedB.isEmpty) {
    return false;
  }

  return sanitizedA.contains(sanitizedB) || sanitizedB.contains(sanitizedA);
}

