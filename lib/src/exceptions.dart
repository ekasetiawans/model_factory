class ModelParseException implements Exception {
  final Object? innerException;

  const ModelParseException({
    this.innerException,
  });

  @override
  String toString() {
    if (innerException != null) {
      return 'ModelParseException.innerException: ${innerException.toString()}';
    }

    return super.toString();
  }
}
