package app.model

import hu.bme.app.Atom
import hu.bme.app.Parser
import hu.bme.app.Predicate
import hu.bme.app.Term
import org.json.JSONException
import org.json.JSONObject

data class ResolutionTree(var goal: List<Int>, var unification: List<List<Int>>, val children: List<ResolutionTree>) {


    fun getMaxChildrenCount(): Int {
        if (children.isEmpty()) return 0
        var max = children.size
        for (child in children) {
            val count = child.getMaxChildrenCount()
            if (count > max) {
                max = count
            }
        }
        return max
    }

    fun standardize(unificationCount_input: Int = 0, max_elements: Int = 0): ResolutionTree {
        val elementCount = if (max_elements == 0) getMaxElementCount() else max_elements
        val unificationCount = if (unificationCount_input != 0) unificationCount_input else getMaxUnficationCount()
        return standardizeElements(elementCount, unificationCount)
    }

    fun toBFSJson(totalElements: Int = 200,bucketSize : Int = 10): String {
        // Generate a BFS json
        // It should have two fields: goals and unifications
        // goals should be a list of lists
        // unifications should be a list of lists of lists
        // The first element of the goals list should be the root node
        // The first element of the unifications list should be the root node
        // The second element of the goals list should be the first child of the root node
        // The second element of the unifications list should be the first child of the root node
        // The third element of the goals list should be the second child of the root node
        // ... and so on
        val goals = mutableListOf<List<Int>>()
        val unifications = mutableListOf<List<List<Int>>>()
        val childrenCount = mutableListOf<Int>()

        // Do the BFS
        val queue = mutableListOf<ResolutionTree>()
        queue.add(this)
        while (queue.isNotEmpty()) {
            val current = queue.removeAt(0)
            goals.add(current.goal)
            unifications.add(current.unification)
            childrenCount.add(current.children.size)
            queue.addAll(current.children)
        }

        while (goals.size < totalElements) {
            goals.add(IntArray(goals[0].size) { 0 }.toList())
            childrenCount.add(0)
            val mutableList = mutableListOf<List<Int>>()
            for (i in 0 until unifications[0].size) {
                mutableList.add(IntArray(unifications[0][i].size) { 0 }.toList())
            }
            unifications.add(mutableList)
        }

        val json = JSONObject()
        json.put("goals", goals)
        json.put("unifiedBodies", unifications)
        json.put("childCountArray", childrenCount)
        json.put("bucket", bucket.balanceBucket(bucketSize).values )
        return json.toString()
    }

    private fun standardizeBranching(branchingFactor: Int, maxDepth: Int, depth: Int = 1): ResolutionTree {
        // If we are at the max depth, we don't need to do anything
        if (depth == maxDepth) return this

        val newChildren = mutableListOf<ResolutionTree>()
        children.forEach { newChildren.add(it.standardizeBranching(branchingFactor, maxDepth, depth + 1)) }
        while (newChildren.size < branchingFactor) {
            newChildren.add(
                ResolutionTree(listOf(), listOf(), listOf()).standardizeBranching(
                    branchingFactor,
                    maxDepth,
                    depth + 1
                )
            )
        }
        return ResolutionTree(goal, unification, newChildren)
    }

    private fun standardizeElements(elementCount: Int, unificationCount: Int): ResolutionTree {
        val newGoal = mutableListOf<Int>()
        val newUnification = mutableListOf<MutableList<Int>>()
        goal.forEach { newGoal.add(it) }
        while (newGoal.size < elementCount) {
            newGoal.add(0)
        }
        unification.forEach { newUnification.add(it.toMutableList()) }
        while (newUnification.size < unificationCount) {
            newUnification.add(mutableListOf())
        }
        newUnification.forEach {
            if(it.size > elementCount) {
                println("Warning: unification size is larger than element count")
                println("Unification: $it")
            }
            while (it.size < elementCount) {
                it.add(0)
            }
        }
        val newChildren = mutableListOf<ResolutionTree>()
        children.forEach { newChildren.add(it.standardizeElements(elementCount, unificationCount)) }
        return ResolutionTree(newGoal, newUnification, newChildren)
    }

    fun getMaxDepth(): Int {
        if (children.isEmpty()) return 1
        var max = 0
        for (child in children) {
            val depth = child.getMaxDepth()
            if (depth > max) {
                max = depth
            }
        }
        return max + 1
    }

    fun getMaxElementCount(): Int {
        val goalCount = goal.size
        val unificationCount = if (unification.isNotEmpty()) unification.maxOf { it.size } else 0
        val maxHere = if (goalCount > unificationCount) goalCount else unificationCount
        if (children.isEmpty()) return maxHere
        var max = maxHere
        for (child in children) {
            val count = child.getMaxElementCount()
            if (count > max) {
                max = count
            }
        }
        return max
    }

    fun getMaxUnficationCount(): Int {
        var max = unification.size
        if (children.isEmpty()) return max
        children.forEach {
            val count = it.getMaxUnficationCount()
            if (count > max) {
                max = count
            }
        }
        return max
    }

    companion object {
        private val bucket = Bucket()

        fun parseJson(json: String, mapping: Map<String, Int>): ResolutionTree {
            val jsonObject = try {
                JSONObject(json)
            } catch (e: JSONException) {
                JSONObject("{}")
            }
            if (jsonObject.has("goal")) {
                val goal = Parser.parseProlog(jsonObject.getString("goal") + ".")[0].head
                val encodedGoal = refactorPredicateMapping(goal, mapping)

                val unification = if ((jsonObject.getJSONObject("unification")
                        .get("body") is String).not()
                ) jsonObject.getJSONObject("unification").getJSONArray("body")
                    .map {
                        val predicate = Parser.parsePredicate(it.toString())
                        refactorPredicateMapping(predicate, mapping)
                    } else listOf<List<Int>>()
                val children = jsonObject.getJSONArray("ztree").map { parseJson(it.toString(), mapping) }
                return ResolutionTree(encodedGoal, unification, children)
            } else {
                // Its a leaf, i.e. either true or false
                val goal = listOf(mapping[json]!!)
                val unification = listOf<List<Int>>()
                val children = listOf<ResolutionTree>()
                return ResolutionTree(goal, unification, children)
            }
        }

        private fun refactorPredicateMapping(predicate: Predicate, mapping: Map<String, Int>): List<Int> {

            return if (predicate.hasArray()) {
                removeArraysFromPredicateAndAddThemToTheBucket(predicate, mapping, bucket)
            } else if (predicate.name == "is") {
                removeISpredicateEmbeddedPredicateNames(predicate, mapping).encode(mapping)
            } else {
                predicate.encode(mapping)
            }
        }

        /**
         * This function takes a predicate as an input and returns a mapping for it. It also takes a bucket as an input which this function will modify.
         * The function will remove the arrays from the predicate and add them to the bucket if they are not already there. The bucket stores the
         * mapping for the arrays. The encoded predicate will not contain the arrays anymore, but instead it will contain the index of the array in the bucket.
         * @param predicate The predicate to be encoded
         * @param mapping The mapping symbol table for the prolog program
         * @param bucket The bucket to which the arrays should be added
         * @return The encoded predicate with the arrays removed and replaced with their index in the bucketMapping
         */
        private fun removeArraysFromPredicateAndAddThemToTheBucket(
            predicate: Predicate,
            mapping: Map<String, Int>,
            bucket: Bucket
        ): List<Int> {

            val newTerms = mutableListOf<Term>()
            val mappingCopy = mapping.toMutableMap()
            val maxMap = mappingCopy.values.max()
            predicate.terms.forEach { term ->
                if (term is Predicate && term.name == "[]") {

                    if (!bucket.predicates.contains(term)) {
                        bucket.predicates.add(term)
                        bucket.values.add(term.encode(mapping))
                    }
                    val index = maxMap + bucket.predicates.indexOf(term) + 1
                    mappingCopy["[$index]"] = index
                    newTerms.add(Atom("[$index]"))
                } else {
                    newTerms.add(term)
                }
            }
            val resultPredicate = Predicate(predicate.name, newTerms)
            return resultPredicate.encode(mappingCopy)
        }


        /**
         * This function will return a modified version of the input predicate. The input predicate should not contain any other predicates.
         * The returned predicate will not contain any predicates, but it will contain the terms of the embedded predicates.
         * @param predicate The predicate to be modified
         * @param mapping The mapping symbol table for the prolog program
         * @return The modified predicate
         */
        private fun removeISpredicateEmbeddedPredicateNames(
            predicate: Predicate,
            mapping: Map<String, Int>
        ): Predicate {
            val newTerms = mutableListOf<Term>()
            val mappingCopy = mapping.toMutableMap()
            val maxMap = mappingCopy.values.max()
            predicate.terms.forEach { term ->
                if (term is Predicate) {
                    newTerms.addAll(removeISpredicateEmbeddedPredicateNames(term, mapping).terms)
                } else {
                    newTerms.add(term)
                }
            }
            return Predicate(predicate.name, newTerms)
        }
    }

    private data class Bucket(val predicates: MutableList<Predicate> = mutableListOf(), val values: MutableList<List<Int>> = mutableListOf()) {

        fun balanceBucket(elementCount: Int) :Bucket{

            while (predicates.size < elementCount) {
                predicates.add(Predicate("[]", listOf()))
                values.add(listOf())
            }
            // Make sure that each element in the bucket has the same size
            val maxSize = values.maxOf { it.size }
            val newValues = values.toMutableList()
            for (i in 0 until values.size) {
                val value = values[i].toMutableList()
                while (value.size < maxSize) {
                    value.add(0)
                }
                newValues[i] = value
            }

            return Bucket(predicates, newValues)
        }
    }

}