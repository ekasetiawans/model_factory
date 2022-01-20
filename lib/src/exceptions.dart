class ModelParseException implements Exception {
  final Object? innerException;

  const ModelParseException({
    this.innerException,
  });
}
