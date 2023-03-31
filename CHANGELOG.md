# Changelog

- please enter new entries in format 


```
- <description> (#<PR_number>, kudos to @<author>)
```

## main

### Added
<!--- - <description> (#<PR_number, kudos to @<author>) --->
- Run SwiftLint on build if installed locally ([#29](https://github.com/AckeeCZ/Reqres/pull/29), kudos to @olejnjak)

### Changed
- Update structure ([#35](https://github.com/AckeeCZ/Reqres/pull/35), kudos to @olejnjak)
    - use Xcode 14.3
    - bump deployment target to iOS 11
- Use Xcode 12.4 on CI ([#31](https://github.com/AckeeCZ/Reqres/pull/31), kudos to @olejnjak)

## 3.1.1

- Migrate to Swift 5 and Xcode 10.2 (#20, kudos to @olejnjak)
- Add public inits to built-in loggers so they can really be used (#21, kudos to @olejnjak)
- Add SPM support (#23, kudos to @olejnjak)
- Fix a typo and a link in README.md (#24, kudos to @michalsrutek)
- Fix the example app (#25, kudos to @michalsrutek)

SPM release also supports macOS 🎉

## 3.1.0

- Move from NSLog to unified logging (#19, kudos to @fortmarek)
