enum AiMessageType { foundMatch, requestMatch, matchIntro }

AiMessageType typeFromString(String value) {
  switch (value) {
    case 'FOUND_MATCH':
      return AiMessageType.foundMatch;
    case 'REQUEST_MATCH':
      return AiMessageType.requestMatch;
    case 'MATCH_INTRO':
      return AiMessageType.matchIntro;
    default:
      return AiMessageType.foundMatch;
  }
}

