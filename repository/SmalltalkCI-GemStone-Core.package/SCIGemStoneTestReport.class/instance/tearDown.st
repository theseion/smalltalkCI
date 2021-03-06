running
tearDown
  | xmlFile lastPosition |
  suite resources do: [ :each | each reset ].
  self stream
    tab;
    nextPutAll: '<system-out><![CDATA[]]></system-out>';
    lf;
    tab;
    nextPutAll: '<system-err><![CDATA[]]></system-err>';
    lf;
    nextPutAll: '</testsuite>';
    lf.
  lastPosition := stream position.
  self stream
    position: suitePosition;
    nextPutAll: ' failures="';
    print: suiteFailures;
    nextPutAll: '" errors="';
    print: suiteErrors;
    nextPutAll: '" time="';
    nextPutAll: ((self formatTime: suiteTime) printShowingDecimalPlaces: 3);
    nextPutAll: '">'.
  stream position: lastPosition.
  xmlFile := BinaryOrTextFile openWrite: self xmlFilePath.
  xmlFile nextPutAll: stream contents.
  xmlFile close.
  stream := nil.
  progressFile
    cr;
    nextPutAll: self printString;
    cr;
    nextPutAll: 'finished running suite: ';
    nextPutAll: suite name