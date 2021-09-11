import UIKit

struct Markdown {
  struct CSS {}
  struct JS {}
}

extension Markdown.CSS {
  static let github: String = {
    let path = Bundle.main.path(forResource: "github_styled", ofType: "css")!
    let url = URL(fileURLWithPath: path)
    return try! String(contentsOf: url, encoding: String.Encoding.utf8)
  }()

  static let highlight: String = {
    let path = Bundle.main.path(forResource: "highlight", ofType: "css")!
    let url = URL(fileURLWithPath: path)
    return try! String(contentsOf: url, encoding: String.Encoding.utf8)
  }()

  static let iPad: String = {
    let path = Bundle.main.path(forResource: "iPad", ofType: "css")!
    let url = URL(fileURLWithPath: path)
    return try! String(contentsOf: url, encoding: String.Encoding.utf8)
  }()

  static let markdown: String = {
    if UIDevice.current.userInterfaceIdiom == .pad {
      return github + highlight + iPad
    } else {
      return github + highlight
    }
  }()
}

extension Markdown.JS {
  static var footnote: String {
    let path = Bundle.main.path(forResource: "markdown-it-footnote.min", ofType: "js")!
    let url = URL(fileURLWithPath: path)
    return try! String(contentsOf: url, encoding: String.Encoding.utf8)
  }

  static var sup: String {
    let path = Bundle.main.path(forResource: "markdown-it-sup.min", ofType: "js")!
    let url = URL(fileURLWithPath: path)
    return try! String(contentsOf: url, encoding: String.Encoding.utf8)
  }

  static var sub: String {
    let path = Bundle.main.path(forResource: "markdown-it-sub.min", ofType: "js")!
    let url = URL(fileURLWithPath: path)
    return try! String(contentsOf: url, encoding: String.Encoding.utf8)
  }

  static var plugins: [String] {
    [footnote, sup, sub]
  }
}
