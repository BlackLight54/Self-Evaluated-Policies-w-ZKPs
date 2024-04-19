package hu.bme.app

private var counter = 1;

fun createMapping(clauses: List<Clause>) :Map<String,Int>{
    val knowledgeBase = clauses.filter { it.body.isEmpty() }

    val mapping = mutableMapOf<String, Int>()
    knowledgeBase.forEach { clause ->
        clause.head.terms.forEach { term ->
            val trimmed = term.name.trim { it == '\'' }
            if(trimmed == term.name) {
                mapping[term.name] = counter++
            } else {
                mapping[trimmed] = counter
                mapping[term.name] = counter++
            }
        }
    }
    val rules = clauses.filter { it.body.isNotEmpty() }
    rules.forEach { clause ->
        clause.head.terms.forEach { term ->
            if (!mapping.contains(term.name) && term is Atom) {
                mapping[term.name] = counter++
            }
            if(term is Predicate){
                predicateAtomMapping(term, mapping)
            }
        }
        clause.body.forEach { predicate ->
            predicateAtomMapping(predicate, mapping)
        }
    }
    // Add mapping for predicates
    knowledgeBase.forEach { clause ->
        if (!mapping.contains(clause.head.name)) {
            mapping[clause.head.name] = counter++
        }
    }
    rules.forEach { clause ->
        if (!mapping.contains(clause.head.name)) {
            mapping[clause.head.name] = counter++
        }
        clause.body.forEach { predicate ->
            predicatePredicateMapping(predicate, mapping)
        }
    }
    mapping["true"] = counter++
    mapping["false"] = counter++
    // Add mapping for variables
    rules.forEach { clause ->
        clause.head.terms.forEach { term ->
            if (!mapping.contains(term.name) && term is Variable) {
                mapping[term.name] = counter++
            }
            if(term is Predicate){
                predicateVariableMapping(term, mapping)
            }
        }
        clause.body.forEach { predicate ->
            predicateVariableMapping(predicate, mapping)
        }
    }
    return mapping
}

private fun predicateAtomMapping(predicate: Predicate, mapping: MutableMap<String,Int>) {

    predicate.terms.forEach { term ->
        if (!mapping.contains(term.name) && term is Atom) {
            val trimmed = term.name.trim { it == '\'' }
            if(trimmed == term.name) {
                mapping[term.name] = counter++
            } else {
                mapping[trimmed] = counter
                mapping[term.name] = counter++
            }
        }
    }

    predicate.terms.forEach { term ->
        if (term is Predicate) {
            predicateAtomMapping(term, mapping)
        }
    }
}


private fun predicateVariableMapping(predicate: Predicate, mapping: MutableMap<String,Int>) {

    predicate.terms.forEach { term ->
        if (!mapping.contains(term.name) && term is Variable) {
            mapping[term.name] = counter++
        }
    }

    predicate.terms.forEach { term ->
        if (term is Predicate) {
            predicateVariableMapping(term, mapping)
        }
    }
}

private fun predicatePredicateMapping(predicate: Predicate, mapping: MutableMap<String,Int>) {
    if (!mapping.contains(predicate.name)) {
        mapping[predicate.name] = counter++
    }

    predicate.terms.forEach { term ->
        if (term is Predicate) {
            predicatePredicateMapping(term, mapping)
        }
    }
}