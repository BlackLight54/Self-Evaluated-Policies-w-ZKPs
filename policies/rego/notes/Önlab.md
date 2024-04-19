 # Quick Start
CLI Tool
REST API
JVM Dep. 
# ![[Demo]]
# Összehasonlítás
## Indy/Aries-el 
- DID:
	- átfedés: did:key ; did:web
	- [DIF Universal Resolver](https://dev.uniresolver.io) aries oldalon támogatott, unofficial plugin keretében, walt.id-ben nem
- VC representation: Megszokottan JSON-LD, vagyis szemantikus információ csatolt az adatokhoz
	- ZKP?: Aries-ben ugye van, walt.id-bem még nem találtam, de ami a tavalyi rotokollhoz kellene, azt mindenkép ki kellene húzni egy Zokrates layerbe, ahogy tavaly beszéltük, ha támogatja az openID kommunikációs protokoll
- Communication protocol: DIF DIDCom nem támogatott, helyette openID; meg kell nézni az openID mit tud, mennyire biztonságos, mi küldhető rajta JSON-LD-n túl

- EBSI: ebsi DID method mellett támogatott mind a openID Connect protocol és az EBSI specifikus validációs policyk; ezek közül az Aries csak az EBSI DID resolution-t támogatja, a [DIF Universal Resolver](https://dev.uniresolver.io) -el 

- A két fő flow, az *onboarding* és az *authentication* automatizálva van, nem kell kézzel megírni
- Futtatható mind JVM-ben, mind CLI-n, mind REST-API ként; Aries-hez képest kisebb komplexitásúak ezek az interfészek
- Újdonság: Open Policy Agent integráció: formális nyelven megfogalmazható policy-k a W3C VC-k validálására

- [ ] TODO: Walt-os okat megkérdezni ZKP-ról
- [ ] TODO: OpenID-t megnézni
- [x] TODO: [European Digital Identity Architecture and Reference Framework](https://digital-strategy.ec.europa.eu/en/library/european-digital-identity-architecture-and-reference-framework-outline) 
no answer
- [ ] TODO: ToIP? Melyik kommunikaciós protokoll lesz a nyerő? mik vannak? [Talán ez az?](https://trustoverip.org/blog/2023/01/05/the-toip-trust-spanning-protocol/)

- [x] TODO: Rego-t megnézni

# 5. hét
Nem találtam a walt.id API-jában biztonságos kommunikációra lehetőséget adó endpointot. Ez egy további különbség a DIDCom-hoz képest, mert itt, ahogy én látom, OAuth-osan, TLS-el mennek át az üzenetek

## REGO (pr.: *ray-go*)
### Jellemzők
- Deklaratív nyelv (Prolog-hoz hasonlít számomra)
- Magas szintű
- Open Policy Agent-hez használható; OPA: Ágens aki enforce-olja a policy-ket
- [Datalog](https://en.wikipedia.org/wiki/Datalog) inspirálta, azt kiterjeszti hogy JSON és egyéb strukturált adatmodellekhez is lehessen használni
- Célja, hogy a policy-kat könnyen írható és olvasható módon, deklaratívan tudjuk leírni
### Felépítés
- Alapegysége a szabály
  `pi := 3.1415`
- Ez mutathat összetett értékre
  `rect := { "width" : 2 , "height" = 3 } `
- Olyan mint a prolog


## OpenID / OpenID Connect
### Jellemzők 
- API specifikáció
- OAuth 2.0 -hoz tartozik, a felett utazik, azt egészíti ki
- Issuance and presentitation of Verifiable Credentials
- Az OpenID core a dokumentáció szerint könnyedén bővíthető

- [x] [KILT](https://github.com/KILTprotocol/kilt-parachain#24-hierarchy-of-trust-module) Hierarchy of trust: Lecsekkolni, milyen policy-ket támogat a KILT, abból inspirálódni
- [x] TODO: REGO demo
# 6. hét
## Open Policy Agent
Auditor API-n keresztül policy enforcement
unifes policy enforcement across the stack
goal: separate policy-decision making from business logic
flexible validation of w3c credentials
policy from file-system, DB or trusted registry(DLT)

vreification requrest = policy, to-be-verified data, action
to-be-verified data: relevant data points of credential, in JSON-LD
![[opa-service.svg]]
- Can function as a Kubernetes Admission Controller
	For example, by deploying OPA as an admission controller you can:
	-   Require specific labels on all resources.
	-   Require container images come from the corporate image registry.
	-   Require all Pods specify resource requests and limits.
	-   Prevent conflicting Ingress objects from being created.
### Docker HTTP API tutorial
policy fájlok (opa build)=> bundle
bundle => bundle server

seq:
nginx (policy req)-> opa (feth policies)-> bundle server (policy data)-> opa (policy decision) -> nginx

allows for arbitrarily complex policies, based on arbitrary structured data(JSON)
for examle: easy imlpementation of jWT tokens 
### Walt.id Dynamic Policies
The SSIKit allows for specifying custom policies written in one of the supported policy engine lingos. A dynamic policy can be executed on the fly, if all required parameters are given, or saved with a name, by which it can be referenced in the verify command or REST API lateron. In this example I'm going to use a very simple policy written in the Rego language, for the **Open Policy Agent** engine.

## Dynamic policy argument
The dynamic policy requires an argument of the DynamicPolicyArg type, which is defined like follows:
```
data class DynamicPolicyArg (
val name: String = "DynamicPolicy",
val description: String? = null,
val input: Map<String, Any?>,
val policy: String,
val dataPath: String = "\$",
val policyQuery: String = "data.system.main",
val policyEngine: PolicyEngineType = PolicyEngineType.OPA,
val applyToVC: Boolean = true,
val applyToVP: Boolean = false
)
```

**Properties:**
-   `name`: policy name, defaults to "DynamicPolicy"
-   `description`: Optional description of the policy
-   `input`: A generic map (JSON object), holding the input data required by the policy (or an empty map if no input is required)
-   `policy`: the policy definition (e.g. rego file), which can be a file path, URL, ==JSON Path (if policy is defined in a credential property)== or the code/script directly.
-   `dataPath`: The path to the credential data, which should be verified, by default it's the whole credential object `$`. To use e.g. only the credential subject as verification data, specify the JSON path like this: `$.credentialSubject`.
-   `policyQuery`: The query string in the policy engine lingo, defaults to "data.system.main"
-   `policyEngine`: The engine to use for execution of the policy. By default `OPA` (Open Policy Agent) is used.
-   `applyToVC`: Apply this policy to verifiable credentials (Default: true)
-   `applyToVP`: Apply this policy to verifiable presentations (Default: false)
## Issuance OIDC4CI
## Presentation OIDC4VP

- [ ] TODO: példa walt-ban VC ellenőrzésre egy VC-ben leírt policy-t, amit OPA rego segítségével értékelünk ki, use-case gázártámogatás: dinamikusan változik a támogatás, a VC egy állítás azzal kapcsolatban, hogy jogosult vagyok valamennyi gázártámogatásra, a VS akkor érvényes, ha kiszámíthatóan

# 7. hét 
## Saját rego policy használata walt.id-ben
szükséges api hívások postman-ben, workspace id: 082571e2-c81f-48f1-8831-c147a489520e

basic.rego:
``` rego
package system
default main = false

main {
	regex.match(input.credentialData.credentialSubject.id)
}
```

>[!warning] Nagyon rossz az API leírás
>több helyen elvault információt közöl, ütköznek a magyarázatok, a Swaggerben nincs default, hogy tudni lehessen mi a friss, a választörzsek olykor sokat segítenek, olykor semmitmondóak, küzdelem volt
>Tippre a friss az [ez](https://docs.walt.id/v/ssikit/concepts/verification-policies/dynamic-policies)

- [x] TODO: Basic Dynamic policy .rego source-ból
Válasz!:
``` json
{
    "valid": true,
    "results": [
        {
            "result": true,
            "policyResults": {
                "SignaturePolicy": {
                    "isSuccess": true,
                    "isFailure": false
                },
                "MyPolicy": {
                    "isSuccess": true,
                    "isFailure": false
                }
            },
            "valid": true
        }
    ]
}
```
- [ ] TODO: Create template for VC-s that contain a policy 
- [ ] TODO: Dynamic Policy Json(VC) -ből; ötlet: verifikálandó VC és policy VC elkülönítése VP-vel
- [ ] TODO: Dynamic Policy VC-ből, komplex vc-t verifikálva
- [ ] TODO: Dynamic Policy VC-ből, komplex vc-t verifikálva, inputtól függően
- [ ] TODO: Dynamic Policy VC-ből, komplex vc-t verifikálva, inputtól függően, külső adatot (OPA DATA) használva 


> [!question] Where is the "data"? 
> In OPA there are two global objects, the INPUT and the DATA
> with walt.id, the `dataPath` variable points to the data in the credential, but is accesed in opa as `input.credentialData`
> So my question is how can I acces this DATA object in walt.id? is it a database? how do i connect i

Policy-t publikál a Minisztérium vc-ként, ideálisan updatelhető módon egy trusted vrified registryn, publikusan

End user magának helyben le tudja futtattatni otthon is, input a fogyasztás, és egy két igazoló VC, vulnerable status-ről, hogy mennyi fogyasztásra jogosult

Köv. lépés: privacy - ne lássák mennyi supportot kaptam; ne tudják mi miatt kaptam támogatást
- [ ] TODO: LOOKUP: milyen ZKP-ra integrálható a rego mint deklaratív nyelv
- [ ] TODO: ASK: walt-nak, van-e=(lesz-e) kivezetése a OPA eredmények

- [ ] TODO: READ: [You Can’t Spell Identity without an “I”](https://www.lifewithalacrity.com/2016/04/the-path-to-self-soverereign-identity.html)


# 8.hét
## Policy Vc-ben
Credential root-jába rakom a policy-t
A dynamic policy `"policy"` argumentuma a verifikálandó credential JSON-jéből induló JSON path.
Ezenkívül fontos, hogy a kiadás során a policy szövege JSON-escape-elve legyen (`JSON.stringify()`)
Sikeresen kiadtam egy VC-t, amit a benne található policy-val ellenőriztem.
VC:
```json
{
  "type" : [ "VerifiableCredential", "UniversityDegreeCredential" ],
  "@context" : [ "https://www.w3.org/2018/credentials/v1", "https://www.w3.org/2018/credentials/examples/v1", "https://w3id.org/security/suites/jws-2020/v1" ],
  "id" : "urn:uuid:93416a56-01d6-463a-bc1b-78dbeff450f9",
  "issuer" : {
    "id" : "did:key:z6MkgMCMabUfySepuSy2PGLhrg24cJyKRq7tMZQf8gV1iK3c"
  },
  "issuanceDate" : "2023-04-20T18:58:11Z",
  "issued" : "2023-04-20T18:58:11Z",
  "validFrom" : "2023-04-20T18:58:11Z",
  "credentialSubject" : {
    "id" : "did:key:z6Mkg3HREpoPKd8fi5NkYreJTAopoEaG6CTEf2Agxch5ced2",
    "degree" : {
      "name" : "Bachelor of Science and Arts",
      "type" : "BachelorDegree"
    }
  },
  "policy" : "package system\nimport future.keywords.if\n\ndefault allow = false\n\n# main {\n#     regex.match(\".+\",input.credentialData.credentialSubject.id)\n# }\n\n\nallow {\n    regex.match(\".+\",input.credentialData.credentialSubject.id)\n}\n\nnumber := 4\nnumberout { number}",
  "proof" : {
    "type" : "JsonWebSignature2020",
    "creator" : "did:key:z6MkgMCMabUfySepuSy2PGLhrg24cJyKRq7tMZQf8gV1iK3c",
    "created" : "2023-04-20T18:58:11Z",
    "verificationMethod" : "did:key:z6MkgMCMabUfySepuSy2PGLhrg24cJyKRq7tMZQf8gV1iK3c#z6MkgMCMabUfySepuSy2PGLhrg24cJyKRq7tMZQf8gV1iK3c",
    "jws" : "eyJiNjQiOmZhbHNlLCJjcml0IjpbImI2NCJdLCJhbGciOiJFZERTQSJ9..-wP-KR2TQ63uIgH2yuJkmTHZtw-npy1OM8B6rBkh1Wt4dAENlDWSHxUYz9AdB_RxH8NHbwNxTqSgo2rfh5ZZCw"
  }
}
```
Dynamic Policy Argument:
``` json
{
    "name": "{{policyName}}",
    "input": {},
    "policy": "{{policyRegoPath}}",
    "dataPath": "{{policyDatapath}}",
    "policyQuery": "data.system.allow"
}
```
## Policy VP-ben
Nem elérhető a VP Json rootja, a credential-okat egyesével járja végig a verifier.
A VP ellenőrzés walt.id-ban úgy van implementálva, hogy a VP-t egy VC-nek tekinti, és ha az ok, akkor a benne található egyes credential-okat járja végig. Nincs lehetőség a teljes VP egy kontextusnak tekintésére, és az arra vonatkozó OPA ellenőrzésre. 
Emiattt jelenleg nem lehet a VC-től elválasztani az ő ellenőrzésére szolgáló policy-t ebben az ökoszisztémában, és nem lehet a VC-ket egymáshoz képest sem vizsgálni.

Nem értem teljesen hogy ennek mi az oka, mivel a Dynamic Policy-nek meg lehet adni hogy vc-re és/vagy vp-re legyen érvényes, és ahogy néztem a kód ezt figyelembe is veszi.
Sajnos a debugger valamiért nem logol, hiába adom meg neki a megfeleló flaget.
Próbált VP(single credential):
```json 
{
  "type" : [ "VerifiablePresentation" ],
  "@context" : [ "https://www.w3.org/2018/credentials/v1", "https://w3id.org/security/suites/jws-2020/v1" ],
  "id" : "urn:uuid:35ef2d87-838a-4fa4-b151-bdde50d3891d",
  "holder" : "did:key:z6Mkg3HREpoPKd8fi5NkYreJTAopoEaG6CTEf2Agxch5ced2",
  "verifiableCredential" : [ {
    "type" : [ "VerifiableCredential", "UniversityDegreeCredential" ],
    "@context" : [ "https://www.w3.org/2018/credentials/v1", "https://www.w3.org/2018/credentials/examples/v1", "https://w3id.org/security/suites/jws-2020/v1" ],
    "id" : "urn:uuid:93416a56-01d6-463a-bc1b-78dbeff450f9",
    "issuer" : {
      "id" : "did:key:z6MkgMCMabUfySepuSy2PGLhrg24cJyKRq7tMZQf8gV1iK3c"
    },
    "issuanceDate" : "2023-04-20T18:58:11Z",
    "issued" : "2023-04-20T18:58:11Z",
    "validFrom" : "2023-04-20T18:58:11Z",
    "proof" : {
      "type" : "JsonWebSignature2020",
      "creator" : "did:key:z6MkgMCMabUfySepuSy2PGLhrg24cJyKRq7tMZQf8gV1iK3c",
      "created" : "2023-04-20T18:58:11Z",
      "verificationMethod" : "did:key:z6MkgMCMabUfySepuSy2PGLhrg24cJyKRq7tMZQf8gV1iK3c#z6MkgMCMabUfySepuSy2PGLhrg24cJyKRq7tMZQf8gV1iK3c",
      "jws" : "eyJiNjQiOmZhbHNlLCJjcml0IjpbImI2NCJdLCJhbGciOiJFZERTQSJ9..-wP-KR2TQ63uIgH2yuJkmTHZtw-npy1OM8B6rBkh1Wt4dAENlDWSHxUYz9AdB_RxH8NHbwNxTqSgo2rfh5ZZCw"
    },
    "credentialSubject" : {
      "id" : "did:key:z6Mkg3HREpoPKd8fi5NkYreJTAopoEaG6CTEf2Agxch5ced2",
      "degree" : {
        "name" : "Bachelor of Science and Arts",
        "type" : "BachelorDegree"
      }
    },
    "policy" : "package system\nimport future.keywords.if\n\ndefault allow = false\n\n# main {\n#     regex.match(\".+\",input.credentialData.credentialSubject.id)\n# }\n\n\nallow {\n    regex.match(\".+\",input.credentialData.credentialSubject.id)\n}\n\nnumber := 4\nnumberout { number}"
  } ],
  "proof" : {
    "type" : "JsonWebSignature2020",
    "creator" : "did:key:z6Mkg3HREpoPKd8fi5NkYreJTAopoEaG6CTEf2Agxch5ced2",
    "created" : "2023-04-20T20:15:06Z",
    "proofPurpose" : "authentication",
    "verificationMethod" : "did:key:z6Mkg3HREpoPKd8fi5NkYreJTAopoEaG6CTEf2Agxch5ced2#z6Mkg3HREpoPKd8fi5NkYreJTAopoEaG6CTEf2Agxch5ced2",
    "jws" : "eyJiNjQiOmZhbHNlLCJjcml0IjpbImI2NCJdLCJhbGciOiJFZERTQSJ9..zhIvNnLyLbjax4ao6G8fAMrWlfnVdfrC_gQEOOEUAyEC6vETBbNkUy9BqjRQR3LXIG8ePS8VCfMfCzNvpTGBDA"
  }
}
```
Próbált VP(double credential):
``` json
{
  "type" : [ "VerifiablePresentation" ],
  "@context" : [ "https://www.w3.org/2018/credentials/v1", "https://w3id.org/security/suites/jws-2020/v1" ],
  "id" : "urn:uuid:8392cf26-f055-48b5-ae0d-3fc3747ae48c",
  "holder" : "did:key:z6Mkg3HREpoPKd8fi5NkYreJTAopoEaG6CTEf2Agxch5ced2",
  "verifiableCredential" : [ {
    "type" : [ "VerifiableCredential", "UniversityDegreeCredential" ],
    "@context" : [ "https://www.w3.org/2018/credentials/v1", "https://www.w3.org/2018/credentials/examples/v1", "https://w3id.org/security/suites/jws-2020/v1" ],
    "id" : "urn:uuid:93416a56-01d6-463a-bc1b-78dbeff450f9",
    "issuer" : {
      "id" : "did:key:z6MkgMCMabUfySepuSy2PGLhrg24cJyKRq7tMZQf8gV1iK3c"
    },
    "issuanceDate" : "2023-04-20T18:58:11Z",
    "issued" : "2023-04-20T18:58:11Z",
    "validFrom" : "2023-04-20T18:58:11Z",
    "proof" : {
      "type" : "JsonWebSignature2020",
      "creator" : "did:key:z6MkgMCMabUfySepuSy2PGLhrg24cJyKRq7tMZQf8gV1iK3c",
      "created" : "2023-04-20T18:58:11Z",
      "verificationMethod" : "did:key:z6MkgMCMabUfySepuSy2PGLhrg24cJyKRq7tMZQf8gV1iK3c#z6MkgMCMabUfySepuSy2PGLhrg24cJyKRq7tMZQf8gV1iK3c",
      "jws" : "eyJiNjQiOmZhbHNlLCJjcml0IjpbImI2NCJdLCJhbGciOiJFZERTQSJ9..-wP-KR2TQ63uIgH2yuJkmTHZtw-npy1OM8B6rBkh1Wt4dAENlDWSHxUYz9AdB_RxH8NHbwNxTqSgo2rfh5ZZCw"
    },
    "credentialSubject" : {
      "id" : "did:key:z6Mkg3HREpoPKd8fi5NkYreJTAopoEaG6CTEf2Agxch5ced2",
      "degree" : {
        "name" : "Bachelor of Science and Arts",
        "type" : "BachelorDegree"
      }
    },
    "policy" : "package system\nimport future.keywords.if\n\ndefault allow = false\n\n# main {\n#     regex.match(\".+\",input.credentialData.credentialSubject.id)\n# }\n\n\nallow {\n    regex.match(\".+\",input.credentialData.credentialSubject.id)\n}\n\nnumber := 4\nnumberout { number}"
  }, {
    "type" : [ "VerifiableCredential", "UniversityDegreeCredential" ],
    "@context" : [ "https://www.w3.org/2018/credentials/v1", "https://www.w3.org/2018/credentials/examples/v1", "https://w3id.org/security/suites/jws-2020/v1" ],
    "id" : "urn:uuid:6b3d738d-db09-4e85-a6d2-3704741016b6",
    "issuer" : {
      "id" : "did:key:z6MkgMCMabUfySepuSy2PGLhrg24cJyKRq7tMZQf8gV1iK3c"
    },
    "issuanceDate" : "2023-04-20T20:13:45Z",
    "issued" : "2023-04-20T20:13:45Z",
    "validFrom" : "2023-04-20T20:13:45Z",
    "proof" : {
      "type" : "JsonWebSignature2020",
      "creator" : "did:key:z6MkgMCMabUfySepuSy2PGLhrg24cJyKRq7tMZQf8gV1iK3c",
      "created" : "2023-04-20T20:13:45Z",
      "verificationMethod" : "did:key:z6MkgMCMabUfySepuSy2PGLhrg24cJyKRq7tMZQf8gV1iK3c#z6MkgMCMabUfySepuSy2PGLhrg24cJyKRq7tMZQf8gV1iK3c",
      "jws" : "eyJiNjQiOmZhbHNlLCJjcml0IjpbImI2NCJdLCJhbGciOiJFZERTQSJ9..9Ns9H26vT1Itn5YBIGbBFgUOndWPSE4KPapZhUa4ITgQ2hpQIcP9M94WoDZQo-Ym-9vXBcRumjrKp-8kdYVpCw"
    },
    "credentialSubject" : {
      "id" : "did:key:z6Mkg3HREpoPKd8fi5NkYreJTAopoEaG6CTEf2Agxch5ced2",
      "degree" : {
        "name" : "Bachelor of Science and Arts",
        "type" : "BachelorDegree"
      }
    }
  } ],
  "proof" : {
    "type" : "JsonWebSignature2020",
    "creator" : "did:key:z6Mkg3HREpoPKd8fi5NkYreJTAopoEaG6CTEf2Agxch5ced2",
    "created" : "2023-04-20T20:27:54Z",
    "proofPurpose" : "authentication",
    "verificationMethod" : "did:key:z6Mkg3HREpoPKd8fi5NkYreJTAopoEaG6CTEf2Agxch5ced2#z6Mkg3HREpoPKd8fi5NkYreJTAopoEaG6CTEf2Agxch5ced2",
    "jws" : "eyJiNjQiOmZhbHNlLCJjcml0IjpbImI2NCJdLCJhbGciOiJFZERTQSJ9..QCL2JsLF4Z0deG3QitHb-LokeIwhtOcTBB3TTDI9g6ImtByC3A7Q-tZUuQMm1w3nBv3oNY0bJQieZ2Mp0-dDAQ"
  }
}
```

>[!info]- A dokumentációban beszélnek róla, hogy DLT-ről is betölthető egy policy: 
>In order to verify W3C Verifiable Credentials and Presentations, the SSI Kit offers the [Auditor API](https://auditor.ssikit.walt.id/). This API serves as integration point for a Verifier application, but also can be used for testing by the built-in CLI tool. In either way a Verifiable Credential (VC) is forwarded to the SSI Kit in order to have it verified.
>The SSI Kit loads a Rego Policy either from a file-system, database or a ==trusted registry that most likely is implemented using Distributed Ledger Technology.==
>Further on the SSI Kit generates the verification request which is processed by the OPA engine. This request consists of the policy, the input-data to be verified and the action. The input-data is just the relevant data-points of the credential - typically the nested JSON-object "credentialSubject" or part of it. The "action" is the request that should be granted by the policy.
>The Open Policy Agent processes the verification request and returns the result to the SSI Kit. The SSI Kit evaluates the result and composes an aggregated credential validation response (as also other validation checks are performed) for the calling party.

De erre nem találtam metódust, ami a szimpla API-n kívül letöltöm és plain-text-ben átadom neki-nél komplexebb lenne.

A policy az ökoszisztémában megadható on-the-fly is, triviális megoldás a DLT-ről letölteni a policy-t, *"kézzel"* odaadni az SSI-kit-nek, és meggyőződni róla hogy az eredmény ugyanaz, mint amit a kezelő szerv futtat.

Továbbá a walt.id-ba integrált OPA nem nyitott arra, hogy adatbázist társítsunk hozzá

TODO:ASK: VP-t hogy tudunk ellenőrizni
TODO:ASK: Hogy tudunk DLT-ről policy-t lekérdezni.

TODO:LOOKUP: w3c és rego policy és a magasabb szintű protokolloknak van-e metszete? van-e szabvány a kommunikációs protokollokban(eljárásrendek kjommunikációja és kiértékelése)?
TODO:LOOKUP: Aries környékén csinálnk-e OPA integrációt.

# 9.hét 
## walt.id VP verification with OPA rego policies
Megpróbáltam újra az általam kitalált workflow-t double-checkelve a kódot és a requesteket, nem tudom hol lehet a baj, csak annyit, hogy valahol a JSON-parsing környékén.

Írtam a walt.id discord-ra a VP verificationnel, még nem válaszoltak.
## walt.id verificaton with OPA rego policies obtained from a Trusted Registry

## W3C/Aries and OPA intersection / relation

## Open Policy Agent/REGO w/ZKPs
Open policy agent can be easily extended with [custom built-in functions and plugins](https://www.openpolicyagent.org/docs/latest/extensions/), written in golang

## Hyperledger Aries and Open Policy Agent


# 10.hét 
TODO: Modell a gázártámogatásra **rego-ban**, OPA-val, ZKP nélkül, VC-k -ben strukturált adat, VC-k: Social status, történelmi fogyasztás, stb.
TODO: komponensábra: saját oldalunkon kicsámoljuk jogosult vagyok-e ártámogatásra.

TODO:LOOKUP: Zilch cikk scholar-on, cite-ok alapjén keresni interktiv ZKP megoldást
TODO: Datalog/Prolog ZKP rezolúció

- [x] TODO: [[Design]] dokumentum elkészítése

# 11. hét 
## Megtakarítási modell
Sávos - fogyasztási kategóriánként leosztva, low-mid-high
12 hónapos gördülő éves megtakarításhoz nézzük az aktuális megtakarítást, minden sávra külön, és a megtakarítás mértékéhez tartozó támogatás is sávos pl.: 50-100 KWh
3x3 mátrix + implicit 0
támogatás százalálékos és nominális is lehet

A szociális támogatás a megtakarításból következő összeget módosítja, százalékos vagy nominális
Szociális támogatás checkboxos, ha teljesíti akkor apply-olódik

# 12. hét 

Complex OPA policy in VP sequence in walt.id:
1.  Create a DID for the issuer
2.  Issue a VC containing the REGO policy
3.  Issue the VCs that that prove social support
```json 
{
	"type": [
		"VerifiableCredential",
		"ChangedWorkcapacityCredential"
	],
	"category": "D1",
	"percentage": 50
}```
4. Issue 12 credentials that prove past consumption, one for each month
```json
{
	"type": [
		"VerifiableCredential",
		"ProofOfActualGasConsumptionCredential"
	],
	"year": "2023",
	"month": "04",
	"consumption": 1000
}
```
5.  Create a VP from the VCs
6.  Add a Custom policy, which only applies to VPs, and uses JSONPath to find the policy in the VP that is in the process of verification
7.  Verify the VP, using this custom policy

Összes korábbi TODO:

walt.id:
- [ ] TODO: ASK: walt.id foglalkozik-e valamilyen ZKP integrációjával
	GH-on erre nincs semmi nyom 
- [x] TODO: példa walt-ban VC ellenőrzésre egy VC-ben leírt policy-t, amit OPA rego segítségével értékelünk ki, use-case gázártámogatás: dinamikusan változik a támogatás, a VC egy állítás azzal kapcsolatban, hogy jogosult vagyok valamennyi gázártámogatásra, a VS akkor érvényes, ha kiszámíthatóan
- [x] TODO: Create template for VC-s that contain a policy 
- [x] TODO: Dynamic Policy Json(VC) -ből; ötlet: verifikálandó VC és policy VC elkülönítése VP-vel
- [x] TODO: Dynamic Policy VC-ből, komplex vc-t verifikálva
- [x] TODO: Dynamic Policy VC-ből, komplex vc-t verifikálva, inputtól függően
- [ ] TODO: Dynamic Policy VC-ből, komplex vc-t verifikálva, inputtól függően, külső adatot (OPA DATA) használva 
- [ ] TODO: ASK: wal.id SSI kit OPA integrációjából kivezethetők lesznek-e a komplex eredények?
- [ ] TODO: ASK: VP-t hogy tudunk ellenőrizni?
- [ ] TODO: ASK: Hogy tudunk DLT-ről policy-t lekérdezni?

OPA/REGO
- [ ] TODO: LOOKUP: milyen ZKP-ra integrálható a rego mint deklaratív nyelv
- [x] TODO: DatalogZKP rezolúció
	- létezik: [Circuitree: a Datalog Reasoner in Zero-Knowledge](https://ieeexplore.ieee.org/iel7/6287639/6514899/09718332.pdf)
- [ ] TODO: Prolog ZKP rezolúció
- [x] TODO:LOOKUP: w3c és rego policy és a magasabb szintű protokolloknak van-e metszete? van-e szabvány a kommunikációs protokollokban(eljárásrendek kjommunikációja és kiértékelése)?
	- nincs, erre egyedül egyelőre a walt.id alkalmas
- [x] TODO:LOOKUP: Aries környékén készítenek-e OPA integrációt.
	- Meeting notes-ban benne van: [DIDCom v2 WG](https://wiki.hyperledger.org/display/ARIES/Aries+DIDCommV2+Working+Group+2023-05-08+meeting)
	- Hyperledger Tape használja az OPA-t : ????
- [x] TODO: Modell a gázártámogatásra **rego-ban**, OPA-val, ZKP nélkül, VC-k -ben strukturált adat, VC-k: Social status, történelmi fogyasztás, stb.
- [x] TODO: komponensábra: saját oldalunkon kicsámoljuk jogosult vagyok-e ártámogatásra.
- [x] TODO: [[Design]] dokumentum elkészítése

- [x] TODO: OpenID hogy működik?
[[OpenID]]
- [ ] TODO: ToIP? Melyik kommunikaciós protokoll lesz a nyerő? mik vannak? [Talán ez az?](https://trustoverip.org/blog/2023/01/05/the-toip-trust-spanning-protocol/)
[[Trust Protocols]]
- [ ] TODO: Survey: policies as verfiable credentials
- [ ] TODO: READ: [You Can’t Spell Identity without an “I”](https://www.lifewithalacrity.com/2016/04/the-path-to-self-soverereign-identity.html)
- [x] TODO: LOOKUP: Zilch cikk scholar-on, cite-ok alapján keresni interktiv ZKP megoldást
	- [Virgo](https://people.eecs.berkeley.edu/~kubitron/courses/cs262a-F19/projects/reports/project5_report_ver2.pdf)[GH](https://github.com/TAMUCrypto/virgo-plus)
	- [zk-Stark](https://link.springer.com/chapter/10.1007/978-3-030-26954-8_23)

- [ ] TODO: READ: possible use case for OPA [Distributed Security Framework for Reliable Threat Intelligence Sharing](https://www.researchgate.net/publication/343384076_Distributed_Security_Framework_for_Reliable_Threat_Intelligence_Sharing)



# 13. hét 

Sligthly below average consumption in Hungary: 4000 kWh

Száraz Próba complete!

## SSI megoldások
[Iden3: Ethereum based SSI protocol](https://iden3.io/)

## ZKP explained 
[A simple explanation of ZKPs](https://medium.com/web3studio/a-simple-explanation-of-zero-knowledge-proofs-ca574092e73b)
[STARKs vs. SNARKs](https://consensys.net/blog/blockchain-explained/zero-knowledge-proofs-starks-vs-snarks/)

## Programmable Zero Knowledge 
[Iden3:Circom: An efficient circuit framework for programmable zero-knowledge](https://iden3.io/circom)
[Circuitree: a Datalog Reasoner in Zero-Knowledge](https://ieeexplore.ieee.org/iel7/6287639/6514899/09718332.pdf)
## ZK-Stark megoldások
- [Virgo](https://people.eecs.berkeley.edu/~kubitron/courses/cs262a-F19/projects/reports/project5_report_ver2.pdf)[GH](https://github.com/TAMUCrypto/virgo-plus)
- [zk-Stark](https://link.springer.com/chapter/10.1007/978-3-030-26954-8_23)
- [StarkWare](https://starkware.co/)(Ethereum)

Önkiértékelésű eljárásrendek SSI megközelítésben

# 14. hét 
Célkítűzést is bele lehet írni 

Fólia deck

Hétfőn New yorki idő szerint 

Mo. du 4 .

Magyarország:

•Igazolvány alapú Single Sign-On : eudiw

•Erős hitelességű digitalis aláírások

•Szociális alapú támogatások automatizációja, pédául: energiaártámogatás