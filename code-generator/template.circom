pragma circom 2.1.0;

include "node_modules/circomlib/circuits/comparators.circom";


template ArrayIsEqual(N) {
   signal input in[2][N];
   signal output out;
   
   signal results[N];
   component isequal[N];

   isequal[0] = IsEqual();
   isequal[0].in[0] <== in[0][0];
   isequal[0].in[1] <== in[1][0];
   results[0] <== isequal[0].out;
   for(var i = 1; i < N; i++) {
      isequal[i] = IsEqual();
      isequal[i].in[0] <== in[0][i];
      isequal[i].in[1] <== in[1][i];
      results[i] <== results[i-1] + isequal[i].out;
   }

   signal final_result;
   final_result <== IsEqual()([results[N-1], N]);

   out <== final_result;
}

template TreeNode(branchFactor) {
   // Each node's data
   signal input goal[5];
   signal input unified_body[branchFactor][5];

    // If it's not a leaf, we connect the children
   signal input children_goals[branchFactor][5];
   signal output c;
   
   signal result[branchFactor*2+1];
   component transitiontochild[branchFactor];
   transitiontochild[0] = TransitionLogic();
   transitiontochild[0].prevUnifiedBodies <== unified_body;
   transitiontochild[0].currentGoal <== children_goals[0];
   result[0] <==  transitiontochild[0].transition_okay;
   for(var i =1; i < branchFactor; i++) {
      log("Visiting child:", i+1, "of", branchFactor, "with goal", children_goals[i][0], children_goals[i][1], children_goals[i][2], "from parent", goal[0], goal[1], goal[2]);
      transitiontochild[i] = TransitionLogic();
      transitiontochild[i].prevUnifiedBodies <== unified_body;
      transitiontochild[i].currentGoal <== children_goals[i];
      result[i] <==  result[i-1] + transitiontochild[i].transition_okay;
   }
   signal emptyResult[branchFactor+1];
   component isZero[branchFactor+1];
   for(var i = 0; i < branchFactor+1; i++) {
      isZero[i] = IsZero();
   }

   isZero[0].in <== goal[0];
   emptyResult[0] <== isZero[0].out;
   component offset = IsZero();
   offset.in <== isZero[0].out;
   
   
   for(var i = 0; i < branchFactor; i++) {
		isZero[i+1].in <== children_goals[i][0]; 
		result[i+branchFactor] <== result[i+branchFactor-1] + (isZero[i+1].out*isZero[0].out) + offset.out;
    }
    

   component checknode = CheckNode();
   checknode.goal_args <== goal;
   checknode.unified_body <== unified_body;
   result[branchFactor*2] <== ((result[branchFactor*2-1] + checknode.c -1 )/2)/branchFactor;
   log(result[branchFactor*2]);

   c <== result[branchFactor*2];
   c === 1;
}

template PrologResolutionTree(depth, branchFactor) {
    // Define the maximum number of tree nodes
    var totalNodes = 200;

    // Define the tree structure
    signal input goals[totalNodes][5];
    signal input unifiedBodies[totalNodes][branchFactor][5]; 
    signal input childCountArray[totalNodes]; // This is the number of children each node has
    signal input bucket[13][13];

    signal output c;
    component nodes[totalNodes];
    for(var i = 0; i < totalNodes; i++) {
        nodes[i] = TreeNode(branchFactor);
    }

    signal result[totalNodes];

   var numChildren = childCountArray[0];
   nodes[0].goal <== goals[0];
   nodes[0].unified_body <== unifiedBodies[0];

   for(var j = 0; j < branchFactor; j++) {
         var childGoal[5];
			var childIndex = j + 1;
			if(j < numChildren && childIndex < totalNodes) {
				childGoal = goals[childIndex];
			} else {
            childGoal = [0,0,0,0,0];
			}
         nodes[0].children_goals[j] <-- childGoal;
   }

   result[0] <== nodes[0].c;

   for(var i = 1; i < totalNodes; i++) {


        // Get number of children for the current node
        var numChildren = childCountArray[i];
        nodes[i].goal <== goals[i];
        nodes[i].unified_body <== unifiedBodies[i];

	     var sum = 0;
		  for(var j = 0; j < i;j++) {
		     sum += childCountArray[j];
		  }
        // Traverse through children
        for(var j = 0; j < branchFactor; j++) {
         var childGoal[5];
			var childIndex = sum + j + 1;
			if(j < numChildren && childIndex < totalNodes) {
				childGoal = goals[childIndex];
			} else {
            childGoal = [0,0,0,0,0];
			}
            nodes[i].children_goals[j] <-- childGoal;
        }
        result[i] <== result[i-1]+nodes[i].c;
    }

   c <== result[totalNodes-1]/totalNodes;
   log("Result:", c);
   c === 1;
}

template TransitionLogic() {
   signal input prevUnifiedBodies[REPLACE_BRANCH_FACTOR][MAX_BODY_SIZE];
   signal input currentGoal[MAX_BODY_SIZE];
   signal output transition_okay;

REPLACE_PREDICATE_MAPPINGS
  
   signal result[REPLACE_BRANCH_FACTOR];
   component isZero[REPLACE_BRANCH_FACTOR][MAX_BODY_SIZE];
   component isAMatch[REPLACE_BRANCH_FACTOR];

   signal inner_result[REPLACE_BRANCH_FACTOR][MAX_BODY_SIZE];
   isZero[0][0] = IsZero();
   isZero[0][0].in <== prevUnifiedBodies[0][0] - currentGoal[0];
   inner_result[0][0] <== isZero[0][0].out;
   for(var j = 1; j < MAX_BODY_SIZE; j++) {
      isZero[0][j] = IsZero();
      isZero[0][j].in <== prevUnifiedBodies[0][j] - currentGoal[j];
      inner_result[0][j] <== inner_result[0][j-1] + isZero[0][j].out;
   }

   isAMatch[0] = IsEqual();
   isAMatch[0].in[0] <== inner_result[0][MAX_BODY_SIZE-1];
   isAMatch[0].in[1] <== MAX_BODY_SIZE;
   result[0] <== isAMatch[0].out;

   for(var i = 1; i < REPLACE_BRANCH_FACTOR; i++) {
      isZero[i][0] = IsZero();
      isZero[i][0].in <== prevUnifiedBodies[i][0] - currentGoal[0];
      inner_result[i][0] <== isZero[i][0].out;
      for(var j = 1; j < MAX_BODY_SIZE; j++) {
         isZero[i][j] = IsZero();
         isZero[i][j].in <== prevUnifiedBodies[i][j] - currentGoal[j];
         inner_result[i][j] <== inner_result[i][j-1] + isZero[i][j].out;
      }
      isAMatch[i] = IsEqual();
      isAMatch[i].in[0] <== inner_result[i][MAX_BODY_SIZE-1];
      isAMatch[i].in[1] <== MAX_BODY_SIZE;

      result[i] <== result[i-1] + isAMatch[i].out;
   }
   signal mathcing_result;
   mathcing_result <== result[REPLACE_BRANCH_FACTOR-1];
   log("Matching result:", mathcing_result);

   component checkGoalZero = IsZero();
   checkGoalZero.in <== currentGoal[0];
   component invertZero = IsZero();
   invertZero.in <== checkGoalZero.out;

   component mathcheck = IsEqual();
   mathcheck.in[0] <== mathcing_result;
   mathcheck.in[1] <== 1;

   component checkGoalTrue = IsEqual();
   checkGoalTrue.in[0] <== currentGoal[0];
   checkGoalTrue.in[1] <== true;

   signal final_result;
   final_result <== (mathcheck.out + (checkGoalZero.out*2) + invertZero.out + (checkGoalTrue.out - mathcheck.out)*checkGoalTrue.out )/2;
   log("Final result:", final_result);
   log(mathcheck.out, checkGoalZero.out, invertZero.out);

   if(final_result != 1){
      log("Failed transition:", currentGoal[0], currentGoal[1], currentGoal[2]);
   }

   transition_okay <-- final_result;
   transition_okay === 1;
}


template CheckNode(){
   signal input unified_body[REPLACE_BRANCH_FACTOR][MAX_BODY_SIZE];
   signal input goal_args[MAX_BODY_SIZE];
   signal output c;
REPLACE_PREDICATE_MAPPINGS
   var none = 0;
REPLACE_RULE_CALLS
   component trueSelector = IsEqual();
   trueSelector.in[0] <== goal_args[0];
   trueSelector.in[1] <== true;
   result[REPLACE_RULE_COUNT+ARITMETHICS_COUNT-2] <== trueSelector.out + result[REPLACE_RULE_COUNT+ARITMETHICS_COUNT-3];

   component noneSelector = IsZero();
   noneSelector.in <== goal_args[0];
   result[REPLACE_RULE_COUNT+ARITMETHICS_COUNT-1] <== noneSelector.out + result[REPLACE_RULE_COUNT+ARITMETHICS_COUNT-2];


   signal finalResult;
   finalResult <== GreaterEqThan(8)([result[REPLACE_RULE_COUNT+ARITMETHICS_COUNT-1], 1]);

   c <== finalResult;
   c === 1;
}

REPLACE_RULE_TEMPLATES

template KnowledgeChecker() {
   
   signal input a[MAX_BODY_SIZE];
   signal output c;
   var len = REPLACE_KNOWLEDGE_BASE_LEN;
   var knowledgeBase[len][MAX_BODY_SIZE] = [REPLACE_KNOWLEDGE_BASE_ARRAY];
   signal result[len];
   component arrayIsEqual[len];


   arrayIsEqual[0] = ArrayIsEqual(MAX_BODY_SIZE);
   arrayIsEqual[0].in[0] <== a;
   arrayIsEqual[0].in[1] <== knowledgeBase[0];
   result[0] <== arrayIsEqual[0].out;

   for(var i = 1; i < len; i++){
      arrayIsEqual[i] = ArrayIsEqual(MAX_BODY_SIZE);
      arrayIsEqual[i].in[0] <== a;
      arrayIsEqual[i].in[1] <== knowledgeBase[i];
      result[i] <== arrayIsEqual[i].out + result[i-1];
   }

   signal final_result;
   final_result <== IsEqual()([result[len-1], 1]);
   c <-- final_result;
 }

 component main = PrologResolutionTree(REPLACE_MAX_DEPTH, REPLACE_BRANCH_FACTOR);
