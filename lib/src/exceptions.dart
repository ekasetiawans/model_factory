class FieldParseException implements Exception {
  final Object? innerException;
  final String? key;
  final dynamic value;

  const FieldParseException({
    this.innerException,
    this.key,
    this.value,
  });

  @override
  String toString() {
    return '''
FieldParseException (
  key: $key,
  innerException: ${innerException.toString()}
  value: ${value.toString()}
)
'''
        .trim();
  }
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
