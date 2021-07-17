import 'package:build/build.dart';
import 'package:model_factory/src/model_factory_generator.dart';
import 'package:model_factory/src/model_factory_resolver.dart';

Builder codeGeneratorResolver(BuilderOptions options) => ModelFactoryResolver();
Builder codeGeneratorFactory(BuilderOptions options) => ModelFactoryGenerator();
