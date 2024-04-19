> [!info]+ Komponens diagram
![[opa-service.svg]]
- Service: Kiértékelést kérő szolgáltatás
- OPA: Open Policy Agent kiértékelő motor

- Policy: REGO nyelven megfolgalmazott policy, deklarált szabálok halmaza, nem feltétlen Service oldalon tárolt, lehet JSON-be ágyazva, VC-be ágyazva, vagy Trusted Registry-ből lekérdezve is.
- Query: Kiértékelendő statement(itt: VC), helye: `input.*`, tetszőleges JSON
- Data: A kiértékelő oldaláról származó egyéb adatok, helye `data.*`, tetszőleges JSON
- Decision: A kiértékelés eredménye, tetszőleges JSON