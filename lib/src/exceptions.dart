class ModelParseException implements Exception {
  final Object? innerException;

  ModelParseException({
    this.innerException,
  });
}
