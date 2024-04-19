import hu.bme.app.*
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Test

class ParserTest {


    @Test fun testParsePredicate() {
        val predicate = Parser.parsePredicate("p(a, X)")
        assertEquals(Predicate("p", listOf(Atom("a"), Variable("X"))), predicate)
    }

    @Test fun testParseClause() {
        val clause = Parser.parseClause("p(a, X) :- q(X, Y), r(Y)")
        assertEquals(
            Clause(
            Predicate("p", listOf(Atom("a"), Variable("X"))),
            listOf(
                Predicate("q", listOf(Variable("X"), Variable("Y"))),
                Predicate("r", listOf(Variable("Y")))
            )
        ), clause)
    }

    @Test fun testParseProlog() {
        val prologCode = """
            p(a, X) :- q(X, Y), r(Y).
            q(X, Y) :- s(X, Y).
            r(Y) :- t(Y).
            s(a, b).
            t(b).
        """.trimIndent()

        val clauses = Parser.parseProlog(prologCode)
        assertEquals(listOf(
            Clause(
                Predicate("p", listOf(Atom("a"), Variable("X"))),
                listOf(
                    Predicate("q", listOf(Variable("X"), Variable("Y"))),
                    Predicate("r", listOf(Variable("Y")))
                )
            ),
            Clause(
                Predicate("q", listOf(Variable("X"), Variable("Y"))),
                listOf(
                    Predicate("s", listOf(Variable("X"), Variable("Y")))
                )
            ),
            Clause(
                Predicate("r", listOf(Variable("Y"))),
                listOf(
                    Predicate("t", listOf(Variable("Y")))
                )
            ),
            Clause(
                Predicate("s", listOf(Atom("a"), Atom("b"))),
                emptyList()
            ),
            Clause(
                Predicate("t", listOf(Atom("b"))),
                emptyList()
            )
        ), clauses)
    }

    // Test arithmetics
    @Test fun testParseArithmetics() {
        val prologCode = """
            p(X) :- X is 1 + 2.
            q(X) :- X is 1 - 2.
            r(X) :- X is 1 * 2.
            s(X) :- X is 1 / 2.
            t(X) :- X is 1 // 2.
            u(X) :- X is 1 mod 2.
            v(X) :- X is 1 ** 2.
            w(X,Y) :- X \= Y.
        """.trimIndent()

        val clauses = Parser.parseProlog(prologCode)
        assertEquals(listOf(
            Clause(
                Predicate("p", listOf(Variable("X"))),
                listOf(
                    Predicate("is", listOf(Variable("X"), Predicate("+", listOf(Atom("1"), Atom("2")))))
                )
            ),
            Clause(
                Predicate("q", listOf(Variable("X"))),
                listOf(
                    Predicate("is", listOf(Variable("X"), Predicate("-", listOf(Atom("1"), Atom("2")))))
                )
            ),
            Clause(
                Predicate("r", listOf(Variable("X"))),
                listOf(
                    Predicate("is", listOf(Variable("X"), Predicate("*", listOf(Atom("1"), Atom("2")))))
                )
            ),
            Clause(
                Predicate("s", listOf(Variable("X"))),
                listOf(
                    Predicate("is", listOf(Variable("X"), Predicate("/", listOf(Atom("1"), Atom("2")))))
                )
            ),
            Clause(
                Predicate("t", listOf(Variable("X"))),
                listOf(
                    Predicate("is", listOf(Variable("X"), Predicate("//", listOf(Atom("1"), Atom("2")))))
                )
            ),
            Clause(
                Predicate("u", listOf(Variable("X"))),
                listOf(
                    Predicate("is", listOf(Variable("X"), Predicate("mod", listOf(Atom("1"), Atom("2")))))
                )
            ),
            Clause(
                Predicate("v", listOf(Variable("X"))),
                listOf(
                    Predicate("is", listOf(Variable("X"), Predicate("**", listOf(Atom("1"), Atom("2")))))
                )
            ),
            Clause(
                Predicate("w", listOf(Variable("X"), Variable("Y"))),
                listOf(
                    Predicate("\\=", listOf(Variable("X"), Variable("Y")))
                )
            )
        ), clauses)
    }

    // Test comments
    @Test fun testParseComments() {
        val prologCode = """
            % Knowledge base
            q(a).
            q(b).
            % This is a comment
            p(X) :- q(X). % This is another comment
        """.trimIndent()

        val clauses = Parser.parseProlog(prologCode)
        assertEquals(listOf(
            Clause(
                Predicate("q", listOf(Atom("a"))),
                emptyList()
            ),
            Clause(
                Predicate("q", listOf(Atom("b"))),
                emptyList()
            ),
            Clause(
                Predicate("p", listOf(Variable("X"))),
                listOf(
                    Predicate("q", listOf(Variable("X")))
                )
            )
        ), clauses)
    }

    @Test fun testParseList() {
        val prologCode = """
            p([a, b, c]).
            q([a, b, c | X]).
            r([a, b, c | X]) :- s(X).
            s([a, b, c],d).
            t([a, b], [c, d]).
            u([a, b | X]) :- u(X).
            u([]).
        """.trimIndent()

        val clauses = Parser.parseProlog(prologCode)
        assertEquals(listOf(
            Clause(
                Predicate("p", listOf(Predicate(".", listOf(Atom("a"), Predicate(".", listOf(Atom("b"), Predicate(".", listOf(Atom("c"))))))))),
                emptyList()
            ),
            Clause(
                Predicate("q", listOf(Predicate(".", listOf(Atom("a"), Predicate(".", listOf(Atom("b"), Predicate(".", listOf(Atom("c"), Variable("X"))))))))),
                emptyList()
            ),
            Clause(
                Predicate("r", listOf(Predicate(".", listOf(Atom("a"), Predicate(".", listOf(Atom("b"), Predicate(".", listOf(Atom("c"), Variable("X"))))))))),
                listOf(
                    Predicate("s", listOf(Variable("X")))
                )
            ),
            Clause(
                Predicate("s", listOf(Predicate(".", listOf(Atom("a"), Predicate(".", listOf(Atom("b"), Predicate(".", listOf(Atom("c"))))))), Atom("d"))),
                emptyList()
            ),
            Clause(
                Predicate("t", listOf(Predicate(".", listOf(Atom("a"), Predicate(".", listOf(Atom("b"))))), Predicate(".", listOf(Atom("c"), Predicate(".", listOf(Atom("d"))))))),
                emptyList()
            ),
            Clause(
                Predicate("u", listOf(Predicate(".", listOf(Atom("a"), Predicate(".", listOf(Atom("b"), Variable("X"))))))),
                listOf(
                    Predicate("u", listOf(Variable("X")))
                )
            ),
            Clause(
                Predicate("u", listOf(Predicate(".", listOf()))),
                emptyList()
            )
        ), clauses)
    }

    // Test tuple management
    @Test
    fun testTuple() {
        val code = """
            p((a,b)).
            q((a, b), c).
            r((a, b), (c, d)).
            s((_, b), c).
        """.trimIndent()

        val clauses = Parser.parseProlog(code)
        assertEquals(listOf(
            Clause(
                Predicate("p", listOf(Predicate(",", listOf(Atom("a"), Atom("b"))))),
                emptyList()
            ),
            Clause(
                Predicate("q", listOf(Predicate(",", listOf(Atom("a"), Atom("b"))), Atom("c"))),
                emptyList()
            ),
            Clause(
                Predicate("r", listOf(Predicate(",", listOf(Atom("a"), Atom("b"))), Predicate(",", listOf(Atom("c"), Atom("d"))))),
                emptyList()
            ),
            Clause(
                Predicate("s", listOf(Predicate(",", listOf(Variable("_"), Atom("b"))), Atom("c"))),
                emptyList()
            )
        ), clauses)
    }
}