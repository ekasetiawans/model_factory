import 'package:build/build.dart';
import 'package:model_factory/src/model_factory_builder.dart';
import 'package:model_factory/src/model_factory_generator.dart';
import 'package:model_factory/src/model_factory_resolver.dart';
import 'package:source_gen/source_gen.dart';

Builder codeGeneratorResolver(BuilderOptions options) => ModelFactoryResolver();
Builder codeGeneratorFactory(BuilderOptions options) => ModelFactoryGenerator();
Builder codeGeneratorBuilder(BuilderOptions options) => PartBuilder(
      [ModelFactoryBuilder()],
      '.g.dart',
    );
