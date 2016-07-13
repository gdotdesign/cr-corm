# Corm
SQL Statement Builder (currently supporting PostgreSQL)


## Installation
Add this to your application's `shard.yml`:

```yaml
dependencies:
  corm:
    github: gdotdesign/corm
```


## Features
TODO: Finalize feature list

Statements:
- [x] SELECT
- [x] INNER_JOIN
- [x] GROUP BY
- [x] WHERE
- [ ] INSERT
- [ ] CREATE
- [ ] DELETE
- [ ] OUTER_JOIN
- [ ] LIMIT
- [ ] ORDER BY
- [ ] ALTER TABLE
- [ ] CREATE TABLE

Functions:
- [x] MAX
- [x] MIN
- [x] COUNT
- [ ] SUM
- [ ] AVG
- [ ] ROUND
- [ ] DISTINCT

Helpers:
- [ ] .columns



## Usage
TODO: Write more useful documentation

```crystal
require "corm"

# Simple query without type casting
Corm.table("users")
    .select("id", "name")
    .where({ "id" => 23 })
    .one
# [[23 : PG::PGValue, "Some User" : PG::PGValue ]]

# Simple query with type casting
Corm.table("users")
    .select("id", "name")
    .where({ "id" => 23 })
    .one({Int32, String})
# {23 : Int32, "Some User" : String}
```


## Development
There is no special development dependencies other then PostgreSQL so far.


## Contributing

1. Fork it ( https://github.com/gdotdesign/corm/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [gdotdesign](https://github.com/gdotdesign) Szikszai Gusztáv - creator, maintainer
