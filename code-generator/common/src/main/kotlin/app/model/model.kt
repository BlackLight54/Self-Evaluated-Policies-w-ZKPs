package hu.bme.app

sealed class Term(val name: String) {
    open fun encode(mapping: Map<String, Int>): List<Int> {
        return listOf(mapping[name] ?: error("Unknown term: $name"))
    }

    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (javaClass != other?.javaClass) return false

        other as Term

        return name == other.name
    }

    override fun hashCode(): Int {
        return name.hashCode()
    }

    override fun toString(): String {
        return "Term(name='$name')"
    }


}

class Atom(name: String) : Term(name) {
    override fun toString(): String {
        return "Atom(name='$name')"
    }
}

class Variable(name: String) : Term(name) {
    override fun toString(): String {
        return "Variable(name='$name')"
    }

    override fun encode(mapping: Map<String, Int>): List<Int> {
        // Return the int if applicable, otherwise return the string hashcode
        return listOf(name.toIntOrNull() ?: name.hashCode())
    }
}

class Predicate(name: String, val terms: List<Term>) : Term(name) {
    override fun encode(mapping: Map<String, Int>): List<Int> {
        val result = mutableListOf<Int>()
        result.add(mapping[name] ?: error("Unknown predicate: $name"))
        terms.forEach { term ->
            result.addAll(term.encode(mapping))
        }
        return result
    }

    override fun toString(): String {
        return "Predicate(name=$name,terms=$terms)"
    }

    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (javaClass != other?.javaClass) return false
        if (!super.equals(other)) return false

        other as Predicate

        return name == other.name && terms == other.terms
    }

    override fun hashCode(): Int {
        var result = super.hashCode()
        result = 31 * result + terms.hashCode() + name.hashCode()
        return result
    }

    fun hasArray(): Boolean {
        return terms.any { it is Predicate && it.name ==  "[]" }
    }

    fun hasAritmetic(): Boolean {
        return terms.any { it is Predicate && it.name ==  "is" } || name == "is"
    }


}

data class Clause(val head: Predicate, val body: List<Predicate>)
