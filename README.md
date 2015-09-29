# yack

Yack. Ack for iOS developers.

Yack is a super-set of [ack](https://github.com/petdance/ack2), the popular grep-replacement tool 
maintained by Andy Lester. It introduces new functionality designed to improve the workflow of
Objective-C developers everywhere.

## Installation

```shell
git clone git@github.com:gsheld/yack.git # close repository
ln -s yack/yack.sh /usr/local/bin/yack # sym-link yack to bin
```

## Usage

##### 1. Search for Objective-C Selector
```shell
yack --sel "setObject:forKey:" # example of a well-formed selector
yack --sel "(void)fooBar:(NSString *)string baz:(NSInteger)integer;" # method signature
```

##### 2. Search Imports for Occurence of a String
Yack will search both the header and implementation files for each import of the specified file.
```shell
yack -j "foo" ./YCKSomeObjCFile.m
yack --imports "bar" ./YCKSomeOtherObjCFile.h
```

##### 3. More to come!

## Contributing

1. Fork it!
2. Create your feature branch: `git checkout -b my-new-yack-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-yack-feature`
5. Submit a pull request!
