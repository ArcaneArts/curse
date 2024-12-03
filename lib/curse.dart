library curse;

import 'dart:mirrors';

extension XCurseObject on Object {
  CursedInstance get cursed => Curse.object(this)!;
}

extension XCurseType on Type {
  CursedClass get cursed => Curse.clazz(this);
}

extension XInstanceMirror on InstanceMirror {
  dynamic get reflecteeOr => hasReflectee ? reflectee : null;
}

extension XCursedFieldIterable on Iterable<CursedField> {
  Iterable<CursedField> withType<T>([Type? t]) =>
      where((f) => f.type == (t ?? T));
  Iterable<CursedField> withTypeAssignableTo<T>([Type? t]) =>
      where((f) => f.type.cursed.isAssignableTo(t ?? T));
  Iterable<CursedField> whereStatic() => where((f) => f.isStatic);
  Iterable<CursedField> whereNotStatic() => where((f) => !f.isStatic);
  Iterable<CursedField> whereConst() => where((f) => f.isConst);
  Iterable<CursedField> whereNotConst() => where((f) => !f.isConst);
  Iterable<CursedField> whereFinal() => where((f) => f.isFinal);
  Iterable<CursedField> whereNotFinal() => where((f) => !f.isFinal);
  Iterable<CursedField> whereExtensionMember() =>
      where((f) => f.isExtensionMember);
  Iterable<CursedField> whereNotExtensionMember() =>
      where((f) => !f.isExtensionMember);
  Iterable<CursedField> whereExtensionTypeMember() =>
      where((f) => f.isExtensionTypeMember);
  Iterable<CursedField> whereNotExtensionTypeMember() =>
      where((f) => !f.isExtensionTypeMember);
}

extension XCursedMethodIterable on Iterable<CursedMethod> {
  Iterable<CursedMethod> withReturnType<T>([Type? t]) =>
      where((m) => m.returnType == (t ?? T));
  Iterable<CursedMethod> withReturnTypeAssignableTo<T>([Type? t]) =>
      where((m) => m.returnType.cursed.isAssignableTo(t ?? T));
  Iterable<CursedMethod> withParameters(
          {Iterable<Type> positional = const [],
          Map<String, Type> named = const {}}) =>
      where((m) {
        List<CursedParameter> pos = m.positionalParameters.toList();
        List<Type> p = positional.toList();

        if (p.length < pos.length) {
          return false;
        }

        for (int i = 0; i < pos.length; i++) {
          if (!pos[i].wouldAcceptType(p[i])) {
            return false;
          }
        }

        List<CursedParameter> opt = m.optionalPositionalParameters.toList();
        List<Type> o = p.length > pos.length ? p.sublist(pos.length) : [];

        if (o.length > opt.length) {
          return false;
        }

        for (int i = 0; i < o.length; i++) {
          if (!opt[i].wouldAcceptType(o[i])) {
            return false;
          }
        }

        List<CursedParameter> nam = m.namedParameters.toList();
        nam.removeWhere((i) =>
            (i.isOptional || i.hasDefaultValue) &&
            (!named.containsKey(i.name.toString()) ||
                i.wouldAcceptType(named[i.name.toString()]!)));
        nam.removeWhere((i) =>
            !i.isOptional &&
            !i.hasDefaultValue &&
            (!named.containsKey(i.name.toString()) ||
                !i.wouldAcceptType(named[i.name.toString()]!)));

        if (nam.isNotEmpty) {
          return false;
        }

        return true;
      });

  Iterable<CursedMethod> returningVoid() => withReturnType<void>();
  Iterable<CursedMethod> whereStatic() => where((m) => m.isStatic);
  Iterable<CursedMethod> whereNotStatic() => where((m) => !m.isStatic);
  Iterable<CursedMethod> whereAbstract() => where((m) => m.isAbstract);
  Iterable<CursedMethod> whereNotAbstract() => where((m) => !m.isAbstract);
  Iterable<CursedMethod> whereOperator() => where((m) => m.isOperator);
  Iterable<CursedMethod> whereNotOperator() => where((m) => !m.isOperator);
  Iterable<CursedMethod> whereGetter() => where((m) => m.isGetter);
  Iterable<CursedMethod> whereNotGetter() => where((m) => !m.isGetter);
  Iterable<CursedMethod> whereSetter() => where((m) => m.isSetter);
  Iterable<CursedMethod> whereNotSetter() => where((m) => !m.isSetter);
  Iterable<CursedMethod> whereConstructor() => where((m) => m.isConstructor);
  Iterable<CursedMethod> whereNotConstructor() =>
      where((m) => !m.isConstructor);
  Iterable<CursedMethod> whereConstConstructor() =>
      where((m) => m.isConstConstructor);
  Iterable<CursedMethod> whereNotConstConstructor() =>
      where((m) => !m.isConstConstructor);
  Iterable<CursedMethod> whereFactoryConstructor() =>
      where((m) => m.isFactoryConstructor);
  Iterable<CursedMethod> whereNotFactoryConstructor() =>
      where((m) => !m.isFactoryConstructor);
  Iterable<CursedMethod> whereRedirectingConstructor() =>
      where((m) => m.isRedirectingConstructor);
  Iterable<CursedMethod> whereNotRedirectingConstructor() =>
      where((m) => !m.isRedirectingConstructor);
  Iterable<CursedMethod> whereRegularMethod() =>
      where((m) => m.isRegularMethod);
  Iterable<CursedMethod> whereNotRegularMethod() =>
      where((m) => !m.isRegularMethod);
  Iterable<CursedMethod> whereExtensionMember() =>
      where((m) => m.isExtensionMember);
  Iterable<CursedMethod> whereNotExtensionMember() =>
      where((m) => !m.isExtensionMember);
  Iterable<CursedMethod> whereExtensionTypeMember() =>
      where((m) => m.isExtensionTypeMember);
  Iterable<CursedMethod> whereNotExtensionTypeMember() =>
      where((m) => !m.isExtensionTypeMember);
}

class Curse {
  static CursedClass clazz(Type type) => CursedClass(type);

  static CursedInstance? object(dynamic d) {
    if (d == null || d is! Object) {
      return null;
    }

    return CursedInstance(d);
  }
}

class CursedDeclaration {
  final DeclarationMirror $declaration;

  CursedDeclaration(this.$declaration);

  bool get isPrivate => $declaration.isPrivate;

  bool get isTopLevel => $declaration.isTopLevel;

  List<InstanceMirror> get $metadata => $declaration.metadata;
}

class CursedField extends CursedDeclaration {
  final CursedClass clazz;
  final Symbol name;
  final VariableMirror $field;

  CursedField(this.clazz, this.name)
      : $field = clazz.$class.declarations[name] as VariableMirror,
        super(clazz.$class.declarations[name] as DeclarationMirror);

  CursedField withInstance(Object inst) => CursedField(inst.cursed, name);

  T? getAnnotation<T>() => $metadata
      .where((m) => m.reflectee is T)
      .map((m) => m.reflectee as T)
      .firstOrNull;

  bool hasAnnotation<T>() => $metadata.any((m) => m.reflectee is T);

  bool get isConst => $field.isConst;

  bool get isFinal => $field.isFinal;

  bool get isStatic => $field.isStatic;

  bool get isExtensionMember => $field.isExtensionMember;

  bool get isExtensionTypeMember => $field.isExtensionTypeMember;

  Type get type => $field.type.reflectedType;

  dynamic get value => isStatic
      ? clazz.$class.getField(name).reflectee
      : (clazz as CursedInstance).$instance.getField(name).reflectee;

  set value(dynamic newValue) => isStatic
      ? clazz.$class.setField(name, newValue)
      : (clazz as CursedInstance).$instance.setField(name, newValue);

  bool isExactType(Type t) => type == t;

  bool wouldAcceptType(Type t) => t.cursed.isAssignableTo(type);
}

class CursedParameter extends CursedDeclaration {
  final CursedMethod method;
  final Symbol name;
  final ParameterMirror $parameter;
  final bool _positional;

  CursedParameter(
    this.method,
    this.name,
    this.$parameter, {
    bool positional = true,
  })  : _positional = positional,
        super($parameter);

  CursedParameter withInstance(Object inst) =>
      CursedParameter(method.withInstance(inst.cursed), name, $parameter);

  T? getAnnotation<T>() => $metadata
      .where((m) => m.reflectee is T)
      .map((m) => m.reflectee as T)
      .firstOrNull;

  bool hasAnnotation<T>() => $metadata.any((m) => m.reflectee is T);

  bool get isOptional => $parameter.isOptional;

  bool get isNamed => $parameter.isNamed;

  bool get isPositional => _positional;

  bool get hasDefaultValue => $parameter.hasDefaultValue;

  Type get type => $parameter.type.reflectedType;

  bool wouldAcceptType(Type t) => t.cursed.isAssignableTo(type);

  dynamic get defaultValue =>
      $parameter.hasDefaultValue ? $parameter.defaultValue : null;
}

class CursedMethod extends CursedDeclaration {
  final CursedClass clazz;
  final Symbol name;
  final MethodMirror $method;

  CursedMethod(this.clazz, this.name)
      : $method = clazz.$class.declarations[name] as MethodMirror,
        super(clazz.$class.declarations[name] as DeclarationMirror);

  CursedMethod withInstance(Object inst) => CursedMethod(inst.cursed, name);

  T? getAnnotation<T>() => $metadata
      .where((m) => m.reflectee is T)
      .map((m) => m.reflectee as T)
      .firstOrNull;

  bool hasAnnotation<T>() => $metadata.any((m) => m.reflectee is T);

  bool get isAbstract => $method.isAbstract;

  bool get isStatic => $method.isStatic;

  bool get isOperator => $method.isOperator;

  bool get isGetter => $method.isGetter;

  bool get isSetter => $method.isSetter;

  bool get isConstructor => $method.isConstructor;

  bool get isConstConstructor => $method.isConstConstructor;

  bool get isFactoryConstructor => $method.isFactoryConstructor;

  bool get isRedirectingConstructor => $method.isRedirectingConstructor;

  bool get isRegularMethod => $method.isRegularMethod;

  bool get isExtensionMember => $method.isExtensionMember;

  bool get isExtensionTypeMember => $method.isExtensionTypeMember;

  Type get returnType => $method.returnType.hasReflectedType
      ? $method.returnType.reflectedType
      : voidType;

  Iterable<CursedParameter> get positionalParameters => $method.parameters
      .where((i) => !i.isNamed && !i.isOptional)
      .map((p) => CursedParameter(this, p.simpleName, p, positional: true));

  Iterable<CursedParameter> get optionalPositionalParameters =>
      $method.parameters
          .where((i) => !i.isNamed && i.isOptional)
          .map((p) => CursedParameter(this, p.simpleName, p, positional: true));

  Iterable<CursedParameter> get namedParameters => $method.parameters
      .where((i) => i.isNamed)
      .map((p) => CursedParameter(this, p.simpleName, p, positional: false));

  Iterable<CursedParameter> get allPositionalParameters =>
      positionalParameters.followedBy(optionalPositionalParameters);

  Iterable<CursedParameter> get allParameters => positionalParameters
      .followedBy(optionalPositionalParameters)
      .followedBy(namedParameters);

  bool returnAssignableTo(Type t) => returnType.cursed.isAssignableTo(t);

  dynamic construct({
    List<dynamic> positionalArguments = const [],
    Map<String, dynamic> namedArguments = const {},
  }) =>
      clazz.$class
          .newInstance($method.constructorName, positionalArguments,
              namedArguments.map((k, v) => MapEntry(Symbol(k), v)))
          .reflectee;

  dynamic invoke({
    List<dynamic> positionalArguments = const [],
    Map<String, dynamic> namedArguments = const {},
  }) {
    if (isStatic) {
      return clazz.$class
          .invoke(name, positionalArguments,
              namedArguments.map((k, v) => MapEntry(Symbol(k), v)))
          .reflectee;
    } else {
      return (clazz as CursedInstance)
          .$instance
          .invoke(name, positionalArguments,
              namedArguments.map((k, v) => MapEntry(Symbol(k), v)))
          .reflectee;
    }
  }
}

class CursedClass extends CursedDeclaration {
  final Type type;
  final ClassMirror $class;

  CursedClass(this.type)
      : $class = reflectClass(type),
        super(reflectClass(type));

  bool hasStaticField(String name) => $class.declarations.values
      .where((i) => i.simpleName == Symbol(name))
      .any((i) => i is VariableMirror && i.isStatic);

  bool hasStaticMethod(String name) => $class.declarations.values
      .where((i) => i.simpleName == Symbol(name))
      .any((i) => i is MethodMirror && i.isStatic);

  T? getAnnotation<T>() => $metadata
      .where((m) => m.reflectee is T)
      .map((m) => m.reflectee as T)
      .firstOrNull;

  bool hasAnnotation<T>() => $metadata.any((m) => m.reflectee is T);

  bool get isAbstract => $class.isAbstract;

  bool get isEnum => $class.isEnum;

  bool get isOriginalDeclaration => $class.isOriginalDeclaration;

  Iterable<CursedMethod> get constructors => $class.declarations.values
      .where((i) => i is MethodMirror && i.isConstructor)
      .map((i) => CursedMethod(this, i.simpleName));

  Iterable<CursedMethod> get constConstructors => $class.declarations.values
      .where((i) => i is MethodMirror && i.isConstConstructor)
      .map((i) => CursedMethod(this, i.simpleName));

  Iterable<CursedMethod> get factoryConstructors => $class.declarations.values
      .where((i) => i is MethodMirror && i.isFactoryConstructor)
      .map((i) => CursedMethod(this, i.simpleName));

  Iterable<CursedMethod> get redirectingConstructors =>
      $class.declarations.values
          .where((i) => i is MethodMirror && i.isRedirectingConstructor)
          .map((i) => CursedMethod(this, i.simpleName));

  Iterable<CursedMethod> get regularMethods => $class.declarations.values
      .where((i) => i is MethodMirror && i.isRegularMethod)
      .map((i) => CursedMethod(this, i.simpleName));

  Iterable<CursedMethod> get extensionMethods => $class.declarations.values
      .where((i) => i is MethodMirror && i.isExtensionMember)
      .map((i) => CursedMethod(this, i.simpleName));

  Iterable<CursedMethod> get extensionTypeMethods => $class.declarations.values
      .where((i) => i is MethodMirror && i.isExtensionTypeMember)
      .map((i) => CursedMethod(this, i.simpleName));

  Iterable<CursedField> get staticFields => $class.declarations.values
      .where((i) => i is VariableMirror && i.isStatic)
      .map((i) => CursedField(this, i.simpleName));

  Iterable<CursedMethod> get staticMethods => $class.declarations.values
      .where((i) => i is MethodMirror && i.isStatic)
      .map((i) => CursedMethod(this, i.simpleName));

  bool isSubclassOf(Type superclass) =>
      $class.isSubclassOf(reflectClass(superclass));

  bool isSuperclassOf(Type subclass) =>
      reflectClass(subclass).isSubclassOf($class);

  bool isSubtypeOf(Type larger) => $class.isSubtypeOf(reflectClass(larger));

  bool isAssignableTo(Type broader) =>
      $class.isAssignableTo(reflectClass(broader));

  CursedField getField(String name) => CursedField(this, Symbol(name));

  CursedMethod getMethod(String name) => CursedMethod(this, Symbol(name));
}

class CursedInstance extends CursedClass {
  final Object object;
  final InstanceMirror $instance;

  CursedInstance(this.object)
      : $instance = reflect(object),
        super(object.runtimeType);

  CursedInstance withInstance(Object inst) => CursedInstance(inst);

  Iterable<CursedField> get fields => $class.declarations.values
      .where((i) => i is VariableMirror && !i.isStatic)
      .map((i) => CursedField(this, i.simpleName));

  Iterable<CursedField> get allFields => fields.followedBy(staticFields);

  Iterable<CursedMethod> get methods => $class.declarations.values
      .where((i) => i is MethodMirror && !i.isStatic)
      .map((i) => CursedMethod(this, i.simpleName));

  Iterable<CursedMethod> get allMethods => methods.followedBy(staticMethods);

  bool hasField(String name) => $class.declarations.values
      .where((i) => i.simpleName == Symbol(name))
      .any((i) => i is VariableMirror && !i.isStatic);

  bool hasMethod(String name) => $class.declarations.values
      .where((i) => i.simpleName == Symbol(name))
      .any((i) => i is MethodMirror && !i.isStatic);
}

Type _getRawType<T>() => T;
Type voidType = _getRawType<void>();
