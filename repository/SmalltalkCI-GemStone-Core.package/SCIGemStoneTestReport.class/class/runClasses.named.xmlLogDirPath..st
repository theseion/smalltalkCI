running
runClasses: aCollectionOfClasses named: aString xmlLogDirPath: aDirectoryPath
  | suite classes |
  suite := TestSuite named: aString.
  classes := (aCollectionOfClasses
    select: [ :each | (each includesBehavior: TestCase) and: [ each isAbstract not ] ])
    asSortedCollection: [ :a :b | a name <= b name ].
  classes do: [ :each | each addToSuiteFromSelectors: suite ].
  ^ self runSuite: suite xmlLogDirPath: aDirectoryPath