import 'package:build/build.dart';
import 'package:model_factory_generator/src/model_factory_builder.dart';
import 'package:model_factory_generator/src/model_factory_generator.dart';
import 'package:model_factory_generator/src/model_factory_resolver.dart';
import 'package:source_gen/source_gen.dart';

// resolve all models to cache
Builder codeGeneratorResolver(BuilderOptions options) => ModelFactoryResolver();

// combile all resolved models to a single factory class
Builder codeGeneratorFactory(BuilderOptions options) => ModelFactoryGenerator();

// generate every single model class to .g.dart
Builder codeGeneratorBuilder(BuilderOptions options) => SharedPartBuilder(
      [ModelFactoryBuilder()],
      'model_factory_generator',
    );
