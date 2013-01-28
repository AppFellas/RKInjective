# RKInjective


## Installation

* Using `cocoapods`

``` ruby
pod 'RKInjective', :podspec => 'https://raw.github.com/AppFellas/RKInjective/master/RKInjective.podspec'
```

## Usage
* Check Tests

* Check code snippet

``` objc
@interface Article : NSObject <RKInjectiveProtocol>
@end

@implementation Article
rkinjective_register(Article)
@end
```
