# SmartCache

A util to cache and resuse any instance in configuratable interval.

## Use cases

Let's assume that we have an DateParser class:

```swift
struct DateParser {
    let formater = DateFormaterr()
    
    func dateFromServerString(_ string: String) -> Date {
        return formatter.date(string: string)
    }
}
```

Then we parse birthDate for a Person

```swift
struct Person {
    let birthDate: Date
    
    init(string: String) {
        date = DateParser().dateFromServerString(date)
    }
}
```

In bellow code, DateParser will created 2 times and detroy in code line.
```swift
let a = Person("1999-09-25 18:00:00")
let b = Person("2000-09-25 18:00:00")

```

But with SmartCache, only 1 instance created to cache and reuse
 ```swift 
struct Person {
    let birthDate: Date
    
    init(string: String) {
        date = smartCache.resolve(DateParser.self).dateFromServerString(date)
    }
}
```


## Usage

For custom class, let it conform to protocol SmartInitializable
 ```swift
 struct DateParser: SmartInitializable {
    let formater = DateFormaterr()
    
    init() { }
    
    func dateFromServerString(_ string: String) -> Date {
        return formatter.date(string: string)
    }
}
```

For existed classes, let it conform to protocol SmartInitializable
 ```swift
extension B: StaticSmartInitializable {
    static func getInstance() -> B {
        return B()
    }
}
```
