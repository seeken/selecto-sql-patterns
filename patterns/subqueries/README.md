# Subqueries

Planned IDs: `S001` to `S010`

Favor non-escape subquery patterns; use `patterns/ESCAPE_HATCH_GUIDE.md` only when unavoidable.

Current intentional escape-hatch cases are correlated `EXISTS`/`NOT EXISTS` (`S003`, `S006`, `S010`).

- `S001` `IN` subquery filter ✅
- `S002` subquery join delivered orders ✅
- `S003` `EXISTS` correlated filter ✅
- `S004` `NOT EXISTS` anti-filter ✅
- `S005` `IN` subquery with params ✅
- `S006` `EXISTS` correlated with params ✅
- `S007` `IN` subquery plus root filter ✅
- `S008` compare total against `ALL` subquery ✅
- `S009` compare total against `ANY` subquery ✅
- `S010` `NOT EXISTS` correlated with params ✅
