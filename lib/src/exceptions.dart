class FieldParseException implements Exception {
  final Object? innerException;
  final String? key;

  const FieldParseException({
    this.innerException,
    this.key,
  });
}

class ModelParseException implements Exception {
  final Object? innerException;
  final String? key;
  final String? className;

  const ModelParseException({
    this.innerException,
    this.key,
    this.className,
  });

  @override
  String toString() {
    if (innerException != null) {
      return '''
ModelParseException (
  className: $className,
  key: $key,
  innerException: ${innerException.toString()}
)
'''
          .trim();
    }

    return super.toString();
  }
}
