import 'package:model_factory/model_factory.dart';
import 'package:model_factory_example/models/my_model.dart' as m0;
import 'package:model_factory_example/models/model_lain.dart' as m1;

void registerFactories() {
  registerJsonFactory((json) => m0.MyModel.fromJson(json));
  registerJsonFactory((json) => m1.ModelLain.fromJson(json));
  registerJsonFactory((json) => m1.ModelYangLain.fromJson(json));
}
