## Usage

```dart
import 'package:curse/curse.dart';

void main() {
  CursedInstance c = SomeObject().cursed;
  
  int id = c.getField("id").value;
  c.getField("id").value++; // id is now 1
  
  c.getMethod("setName").invoke(
    positionalArguments: ['New Name']
  );
  
  c.methods.returningVoid().withParameters(
    positionalParameters: [String]
  ).firstOrNull.invoke(
    positionalArguments: ['Another Name']
  );
  
  c.getField("setter").value = 5;
  
  CursedClass cl = SomeObject.cursed;
  SomeObject s2 = cl.constructors.first.invoke();
}

class SomeObject {
  int id = 0;
  
  String getName() => 'SomeObject';
  
  void setName(String name) {
      print('Setting name to $name');
  }
  
  void set setter(int value) {
      id = value;
  }
  
  int get getter => id;
}
```