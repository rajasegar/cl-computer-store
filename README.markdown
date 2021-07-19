# cl-computer-store

A sample Computer store demo web application in Common Lisp

## Usage
```lisp
(ql:quickload :cl-computer-store)
(cl-computer-store:start :port 3000)
```

Go to `http://localhost:3000` in your browser and see the app in action.


## Installation
```
cd ~/quicklisp/local-projects
git clone https://github.com/rajasegar/cl-computer-store
```

## Creating SQLite db file from the schema
You can generate a persistent database file like `computer-store.db` from the `db/schema.sql`

```
$ sqlite3
sqlite3> .read db/schema.sql
sqlite3> .save computer-store.db
sqlite3> .quit
```

## Author

* Rajasegar Chandran

## Copyright

Copyright (c) 2021 Rajasegar Chandran

