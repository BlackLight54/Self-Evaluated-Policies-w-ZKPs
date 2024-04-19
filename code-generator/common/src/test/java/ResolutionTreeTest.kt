import app.model.ResolutionTree
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Test

class ResolutionTreeTest {


    @Test
    fun testMaxChildrenCountNoChildren() {
        val tree = ResolutionTree(listOf(1, 2), listOf(listOf(1, 2)), listOf())
        assertEquals(0, tree.getMaxChildrenCount())
    }

    @Test
    fun testMaxChildrenCountOneChild() {
        val tree = ResolutionTree(listOf(1, 2), listOf(listOf(1, 2)), listOf(ResolutionTree(listOf(1, 2), listOf(listOf(1, 2)), listOf())))
        assertEquals(1, tree.getMaxChildrenCount())
    }

    @Test
    fun testMaxChildrenCountTwoChildren() {
        val tree = ResolutionTree(listOf(1, 2), listOf(listOf(1, 2)), listOf(ResolutionTree(listOf(1, 2), listOf(listOf(1, 2)), listOf(ResolutionTree(listOf(1, 2), listOf(listOf(1, 2)), listOf()))), ResolutionTree(listOf(1, 2), listOf(listOf(1, 2)), listOf())))
        assertEquals(2, tree.getMaxChildrenCount())
    }

    @Test
    fun testMaxChildrenCountChildHasThreeChildren() {
        val tree = ResolutionTree(listOf(1, 2), listOf(listOf(1, 2)), listOf(ResolutionTree(listOf(1, 2), listOf(listOf(1, 2)), listOf(ResolutionTree(listOf(1, 2), listOf(listOf(1, 2)), listOf()), ResolutionTree(listOf(1, 2), listOf(listOf(1, 2)), listOf()), ResolutionTree(listOf(1, 2), listOf(listOf(1, 2)), listOf()))), ResolutionTree(listOf(1, 2), listOf(listOf(1, 2)), listOf())))
        assertEquals(3, tree.getMaxChildrenCount())
    }

    // Test max element count
    @Test
    fun testMaxElementCountNoChildren() {
        val tree = ResolutionTree(listOf(1, 2), listOf(listOf(1, 2)), listOf())
        assertEquals(2, tree.getMaxElementCount())
    }

    @Test
    fun testMaxElementCountOneChild() {
        val tree = ResolutionTree(listOf(1, 2), listOf(listOf(1, 2)), listOf(ResolutionTree(listOf(1, 2, 3), listOf(listOf(1, 2)), listOf())))
        assertEquals(3, tree.getMaxElementCount())
    }

    @Test
    fun testMaxElementCountOneChild2() {
        val tree = ResolutionTree(listOf(1, 2), listOf(listOf(1, 2)), listOf(ResolutionTree(listOf(1, 2), listOf(listOf(1, 2, 3)), listOf())))
        assertEquals(3, tree.getMaxElementCount())
    }

    // Test max depth
    @Test
    fun testMaxDepthNoChildren() {
        val tree = ResolutionTree(listOf(1, 2), listOf(listOf(1, 2)), listOf())
        assertEquals(1, tree.getMaxDepth())
    }

    @Test
    fun testMaxDepthOneChild() {
        val tree = ResolutionTree(listOf(1, 2), listOf(listOf(1, 2)), listOf(ResolutionTree(listOf(1, 2, 3), listOf(listOf(1, 2)), listOf())))
        assertEquals(2, tree.getMaxDepth())
    }

    @Test
    fun testMaxDepthOneChild2() {
        val tree = ResolutionTree(listOf(1, 2), listOf(listOf(1, 2)), listOf(ResolutionTree(listOf(1, 2), listOf(listOf(1, 2, 3)), listOf())))
        assertEquals(2, tree.getMaxDepth())
    }

    // Test standardizing tree
    @Test
    fun testStandardizingTreeNoChildren() {
        val tree = ResolutionTree(listOf(1, 2), listOf(listOf(1, 2)), listOf())
        val standardizedTree = tree.standardize()
        assertEquals(2, standardizedTree.getMaxElementCount())
        assertEquals(0, standardizedTree.getMaxChildrenCount())
    }

    @Test
    fun testStandardizingFewChildren() {
        val tree = ResolutionTree(listOf(1, 2), listOf(listOf(1, 2)),
                listOf(
                        ResolutionTree(listOf(1, 2, 3), listOf(listOf(1, 2)), listOf(
                                ResolutionTree(listOf(1, 2, 3), listOf(listOf(1, 2),listOf(2, 1)), listOf())
                        )
                        ),
                        ResolutionTree(listOf(1, 2, 3), listOf(), listOf())
                )
        )
        val standardizedTree = tree.standardize()
        println(standardizedTree)
        assertEquals(tree.getMaxDepth(), standardizedTree.getMaxDepth())
        assertEquals(3, standardizedTree.getMaxElementCount())
        assertEquals(2, standardizedTree.getMaxChildrenCount())
        assertEquals(3, standardizedTree.children[0].getMaxElementCount())
        assertEquals(3, standardizedTree.goal.size)
        standardizedTree.unification.forEach {
            assertEquals(3, it.size)
        }
        assertEquals(2, standardizedTree.children[1].children.size)
    }


    // Parse json test
    @Test
    fun testParseJson() {
        val json = "{\"goal\":\"ancestor(anne,carol)\"," +
                "\"unification\":{" +
                    "\"body\":" +
                        "[\"parent(anne,X)\"," +
                        "\"ancestor(X,carol)\"]" +
                    ",\"goal\":" +
                        "\"ancestor(anne,carol)\"}," +
                "\"ztree\":" +
                    "[" +
                        "{\"goal\":" +
                            "\"parent(anne,bob)\",\"unification\":{\"body\":[\"true\"],\"goal\":\"parent(anne,bob)\"},\"ztree\":[\"true\"]},{\"goal\":\"ancestor(bob,carol)\",\"unification\":{\"body\":[\"parent(bob,carol)\"],\"goal\":\"ancestor(bob,carol)\"},\"ztree\":[{\"goal\":\"parent(bob,carol)\",\"unification\":{\"body\":[\"true\"],\"goal\":\"parent(bob,carol)\"},\"ztree\":[\"true\"]}]}]}"
        val mapping = mapOf("anne" to 1, "bob" to 2, "carol" to 3, "parent" to 4, "ancestor" to 5, "true" to 6, "X" to 8)
        val tree = ResolutionTree.parseJson(json, mapping)
        assertEquals(listOf(5, 1, 3), tree.goal)
        assertEquals(listOf(listOf(4, 1, 8), listOf(5, 8, 3)), tree.unification)
        assertEquals(2, tree.children.size)
        assertEquals(listOf(4, 1, 2), tree.children[0].goal)
        assertEquals(listOf(listOf(6)), tree.children[0].unification)
    }

    // Test to json
    @Test
    fun testToJson() {
        val json = "{\"goal\":\"ancestor(anne,carol)\",\"unification\":{\"body\":[\"parent(anne,X)\",\"ancestor(X,carol)\"],\"goal\":\"ancestor(anne,carol)\"},\"ztree\":[{\"goal\":\"parent(anne,bob)\",\"unification\":{\"body\":[\"true\"],\"goal\":\"parent(anne,bob)\"},\"ztree\":[\"true\"]},{\"goal\":\"ancestor(bob,carol)\",\"unification\":{\"body\":[\"parent(bob,carol)\"],\"goal\":\"ancestor(bob,carol)\"},\"ztree\":[{\"goal\":\"parent(bob,carol)\",\"unification\":{\"body\":[\"true\"],\"goal\":\"parent(bob,carol)\"},\"ztree\":[\"true\"]}]}]}"
        val mapping = mapOf("anne" to 1, "bob" to 2, "carol" to 3, "parent" to 4, "ancestor" to 5, "true" to 6, "X" to 8)
        val tree = ResolutionTree.parseJson(json, mapping).standardize()
        println(tree)
        val jsonNew = tree.toBFSJson()
        println(jsonNew)
    }
}