package hu.bme.app

import org.antlr.v4.runtime.CharStreams
import org.antlr.v4.runtime.CommonTokenStream
import org.antlr.v4.runtime.tree.ParseTreeWalker
import prologBaseListener
import prologLexer
import prologParser
import prologParser.TermlistContext

/**
 * The Parser class is responsible for parsing Prolog code and generating a list of clauses.
 */
class Parser : prologBaseListener() {
    companion object {
        /**
         * Parses the given Prolog code and returns a list of clauses.
         *
         * @param code the Prolog code to parse
         * @return a list of clauses
         */
        fun parseProlog(code: String): MutableList<Clause> {
            return Parser().parse(code)
        }

        /**
         * Parses the given predicate string and returns a Predicate object.
         *
         * @param predicateString the predicate string to parse
         * @return a Predicate object
         */
        fun parsePredicate(predicateString: String): Predicate {
            val programString = "$predicateString."
            val clauses = parseProlog(programString)
            return clauses[0].head
        }

        /**
         * Parses the given term string and returns a Term object.
         *
         * @param termString the term string to parse
         * @return a Term object
         */
        fun parseTerm(termString: String): Term {
            val programString = "$termString."
            val clauses = parseProlog(programString)
            return clauses[0].head
        }

        /**
         * Parses the given clause string and returns a Clause object.
         *
         * @param clauseString the clause string to parse
         * @return a Clause object
         */
        fun parseClause(clauseString: String): Clause {
            val programString = "$clauseString."
            val clauses = parseProlog(programString)
            return clauses[0]
        }
        /**
         * The list of Prolog operators, excluding ":-", "," and ";"
         */
        val OPERATORS = listOf(
//            ":-",
            "-->",
            "?-",
            "dynamic",
            "multifile",
            "discontiguous",
            "public",
//            ";",
            "->",
            ",",
            "\\+",
            "=",
            "\\=",
            "==",
            "\\==",
            "@<",
            "@=<",
            "@>",
            "@>=",
            "=..",
            "is",
            "=:=",
            "=\\=",
            "<",
            "=<",
            ">",
            ">=",
            ":",
            "+",
            "-",
            "/\\",
            "\\/",
            "*",
            "/",
            "//",
            "rem",
            "mod",
            "<<",
            ">>",
            "**",
            "^",
            "\\"
        )

        /**
         * The list of built-in Prolog predicates.
         */
        val BUILT_INS = listOf(
            "findall",
            "nl"
        )

        /**
         * The list of special Prolog terms.
         *
         * TODO: What are the special terms exactly?
         */
        val SPECIAL_TERMS = listOf(
            "{}",
            "[]"
        )
    }

    private var zeroTermPedicates: Set<String> = setOf()

    private val result = mutableListOf<Clause>()

    /**
     * Parses the given Prolog code and returns a list of clauses.
     *
     * This function is called by the companion object's parseProlog function.
     * Goes through the steps of parsing the code using ANTLR.
     *
     * @param code the Prolog code to parse
     * @return a list of clauses
     */
    private fun parse(code: String): MutableList<Clause> {
        val lexer = prologLexer(CharStreams.fromString(code))
        val tokens = CommonTokenStream(lexer)
        val parser = prologParser(tokens)

        ParseTreeWalker.DEFAULT.walk(this, parser.p_text())
        val res = result.toMutableList()
        result.clear()
        return res
    }

    /**
     * Handles true/0, false/0 and other/0 type predicates
     *
     */
    private fun atomToZeroTermPredicate(atom: Atom): Predicate {
        zeroTermPedicates = zeroTermPedicates.plus(atom.name)
        return Predicate(atom.name, listOf())
    }

    /**
     * Handles the clause rule. Adds the parsed clause to the result list.
     *
     * Disjoint bodies are treated as separate clauses. The ";" operator is reified in the grammar to return a list of bodies as termlists.
     *
     * @param ctx the clause context
     */
    override fun exitClause(ctx: prologParser.ClauseContext?) {
        ctx?.fact()?.let {
            result.add(Clause(parseTerm(it.term()!!) as Predicate, listOf()))
//            println("fact: ${it.term().text}")
        }
        ctx?.rule_()?.let { ruleContext ->
            val headTermContext = ruleContext.head().term()
            val bodyTermListContexts = ruleContext.body().termlist()
            val head = parseTerm(headTermContext!!)
            // each disjoint body is treated as separate clause
            val bodies = MutableList(bodyTermListContexts.size) { mutableListOf<Predicate>() }
            bodyTermListContexts.forEachIndexed { index, bodyTermListNode ->
                parseTermList(bodyTermListNode).forEach { term ->
                    bodies[index].add(term as? Predicate ?: atomToZeroTermPredicate(term as Atom))
                }
            }
            bodies.forEach() {
                result.add(Clause(head as? Predicate ?: atomToZeroTermPredicate(head as Atom), it))
            }
//            println("rule: ${ruleContext.head().term().text} :- ${ruleContext.body().text}")
        }
    }


    private fun parseUnaryOperator(ctx: prologParser.TermContext): Predicate {
        val terms = mutableListOf<Term>()
        val name = ctx.getChild(0).text!!
        terms.add(parseTerm(ctx.getChild(1) as prologParser.TermContext))
        return Predicate(name, terms)
    }

    private fun parseBinaryOperator(ctx: prologParser.TermContext): Predicate {
        val terms = mutableListOf<Term>()
        val name = ctx.getChild(1).getChild(0).text!!
        terms.add(parseTerm(ctx.getChild(0) as prologParser.TermContext))
        terms.add(parseTerm(ctx.getChild(2) as prologParser.TermContext))
        return Predicate(name, terms)
    }

    private fun parseCompoundTerm(ctx: prologParser.TermContext): Predicate {
        val terms = mutableListOf<Term>()
        val name = ctx.getChild(0).getChild(0).text!!
        val termList = ctx.getChild(2)
        terms.addAll(parseTermList(termList as prologParser.TermlistContext))
        return Predicate(name, terms)
    }

    /**
     * Parses a list of terms. Replacement for the "," operator, and used on the "termlist" grammar rule.
     */
    private fun parseTermList(termListCtx: prologParser.TermlistContext): List<Term> {
        return termListCtx.term()?.map {
            // only parse the term if it's not ','
            if (it.text != ",") parseTerm(it as prologParser.TermContext) else null
        }!!.filterNotNull()
    }


    private fun parseCurlyBracedTerm(ctx: prologParser.TermContext): Term {
        if (ctx.text == "{}") return Atom("{}") //this line may be redundant
        val terms = mutableListOf<Term>()
        val name = "{}"
        val termList = ctx.getChild(2)
        terms.addAll(parseTermList(termList as prologParser.TermlistContext))
        return Predicate(name, terms)
    }

    private fun parseList(ctx: prologParser.TermContext): Term {
        if (ctx.text == "[]") return Atom("[]") //this line may be redundant
        val name = "[]"
        val terms = mutableListOf<Term>()
        val termList = ctx.getChild(1)
        terms.addAll(parseTermList(termList as prologParser.TermlistContext))
        if (ctx.getChild(3)?.text == "|") {
            terms.add(parseTerm(ctx.getChild(4) as prologParser.TermContext))
            return Predicate(
                name,
                terms + Predicate("|", listOf(parseTerm(ctx.getChild(2) as prologParser.TermContext)))
            )
        }
        return Predicate(name, terms)
    }

    private fun parseBuiltIn(ctx: prologParser.TermContext): Predicate {
        if (ctx.getChild(2) == null) return Predicate(ctx.getChild(0).text, listOf())
        return Predicate(
            ctx.getChild(0).text,
            listOf(
                parseTerm(ctx.getChild(2) as prologParser.TermContext)
            )
        )
    }

    private fun parseTerm(ctx: prologParser.TermContext): Term = when {
        // parse true, because true/0 is a built-in predicate
        ctx.childCount == 1 && ctx.getChild(0).text == "true" -> Predicate("true", listOf())
        // parse built-in predicates
        ctx.getChild(0).text in BUILT_INS -> parseBuiltIn(ctx)
        // parse compound terms(i.e. atom(termlist))
        ctx.childCount == 4 && ctx.getChild(1).text == "(" && ctx.getChild(3).text == ")" -> parseCompoundTerm(ctx)
        // parse binary operators
        ctx.childCount == 3 && ctx.getChild(1).text in OPERATORS -> parseBinaryOperator(ctx)
        // parse unary operators
        ctx.childCount == 2 && ctx.getChild(0).text in OPERATORS -> parseUnaryOperator(ctx)
        // parse list terms
        ctx.getChild(0).text == "[" && ctx.getChild(ctx.childCount - 1).text == "]" -> parseList(ctx)
        // parse curled terms
        ctx.getChild(0).text == "{" && ctx.getChild(ctx.childCount - 1).text == "}" -> parseCurlyBracedTerm(ctx)
        // parse braced terms
        ctx.getChild(0).text == "(" && ctx.getChild(2).text == ")" -> parseTermList(ctx.getChild(1) as TermlistContext).let { terms ->
            if (terms.size == 1) terms.first() else Predicate("()", terms)
        }
        // parse variables
        ctx.text.first().isUpperCase() || ctx.text.first()  == '_' || ctx.text.toIntOrNull() != null -> Variable(ctx.text)
        ctx.text in zeroTermPedicates -> atomToZeroTermPredicate(Atom(ctx.text))
        else -> Atom(ctx.text)
    }.also {
        if (it.name == ",") throw Exception("Comma in term: ${ctx.text}")
        if (it.name  == ";")  throw Exception("Semicolon in term: ${ctx.text}")
    }

}