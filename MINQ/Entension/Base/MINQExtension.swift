struct MINQExtension<Base> {
  let base: Base
  init (_ base: Base) {
    self.base = base
  }
}

protocol MINQExtensible {
  associatedtype Compatible
  static var minq: MINQExtension<Compatible>.Type { get }
  var minq: MINQExtension<Compatible> { get }
}

extension MINQExtensible {
  static var minq: MINQExtension<Self>.Type {
    return MINQExtension<Self>.self
  }

  var minq: MINQExtension<Self> {
    return MINQExtension(self)
  }
}
