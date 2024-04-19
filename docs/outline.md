---
mindmap-plugin: basic
---

# Self-evaluated policies using zero knowledge proofs

## [[0. Abstract eng|English abstract]]

## [[0. Abstract hun|Hungarian asbtract]]
- Tételmodat: kontextusteremtés
- absztrakt problémafelvetés
- Megoldás
- Ez miért jó? Generikus. Miért prolog? Kifejező ereje nagy. Miért ZKP?
- Potenciálisan CLP(Korlátkielégítés logikai programozás)
- konkrét use-case-en prototípuson keresztül bemutatjuk a megoldásunkat
- Már létező de kezdeti megközelítésekkel szemben

## [[1. Introduction]]

## [[2. From Self-sovereign Identities to Self-evaluated policies]]
- Prolog
	- Meta-interpretation
	- Zero knowledge proofs, how do they typically work?
	- Zero knowledge frameworks for proving program exectuion, using R1CS
	- Existing use-cases for ZKPs in SSI and DLT ecosystems
		- Brief introductrion to SSI
		- Brief introduction to DLTs
		- exsisting: walt.id and OPA

## [[3. Related works]]
- "Bár léteznek datalog alapú rendszerek, ezeak azonban korlátozottak a következő módon, ezzel szeben a mi munkánk...
- Circuitree
- Efficient representation of CSP...

## [[4. A ZKP based approach for Self-evaluated Policies]]
- Policies over SSI credentials using declarative languages
- Self-evaluating policies as security and privacy guarantees
- Privacy preserving polcies using ZKPs

## [[5. Constraint system representation of proof tree checking]]
- Proof of prolog evaluation with public program and private input
	- Design of the Meta-Interpreter
		- limitations, sub language defintion: no cut, no negation
	- Implementation
- Efficient representation of prolog proof-trees
- Algorithm for verifying prolog proof trees
- ZKP framework for proving a prolog evaluation with public program and private input
	- intro
		- Future work: recursive proofs
		- IDEA: construct a circuit that is able to prove inputs of a specific prolog program, and then use it to prove the correctness of the proof tree. This circuit is designed in suh a way that it can be generated from the prolog program itself.
	- Architecture
	- Designing circuits
		- Alice ancestor example
	- Generating circuits for a specific prolog program
		- Design of the generator
		- Implementation

## [[6. Circom-based toolchain and evaluation]]
- Results
	- Konrét use-case-t teszteljük: Alice ancestor example
	- Validtation and analisys
	- Performance evaluation
- Discussion

## [[7. Conclusion and future work]]