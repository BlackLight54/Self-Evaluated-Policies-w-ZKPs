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
    var totalNodes = 80;
    
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
   signal input prevUnifiedBodies[13][5];
   signal input currentGoal[5];
   signal output transition_okay;

	var monthly_consumption = 86;
	var currentConsumption = 87;
	var currentPrice = 88;
	var inputPayment = 89;
	var rolling_treshold = 90;
	var savings_treshold = 91;
	var support_matrix = 92;
	var social_suport = 93;
	var monthlyConsumptions = 96;
	var sumOfMonthlyConsumptions = 94;
	var rollingConsumption = 100;
	var consumptionClass = 102;
	var savingsClass = 104;
	var priceBase = 106;
	var applySupport = 108;
	var applySavingsSupport = 109;
	var socialCreds = 110;
	var applySocialSupports = 95;
	var endPrice = 112;
	var inputPriceOk = 113;
	var writeSteps = 114;
	var true = 115;

  
   signal result[13];
   component isZero[13][5];
   component isAMatch[13];

   signal inner_result[13][5];
   isZero[0][0] = IsZero();
   isZero[0][0].in <== prevUnifiedBodies[0][0] - currentGoal[0];
   inner_result[0][0] <== isZero[0][0].out;
   for(var j = 1; j < 5; j++) {
      isZero[0][j] = IsZero();
      isZero[0][j].in <== prevUnifiedBodies[0][j] - currentGoal[j];
      inner_result[0][j] <== inner_result[0][j-1] + isZero[0][j].out;
   }

   isAMatch[0] = IsEqual();
   isAMatch[0].in[0] <== inner_result[0][5-1];
   isAMatch[0].in[1] <== 5;
   result[0] <== isAMatch[0].out;

   for(var i = 1; i < 13; i++) {
      isZero[i][0] = IsZero();
      isZero[i][0].in <== prevUnifiedBodies[i][0] - currentGoal[0];
      inner_result[i][0] <== isZero[i][0].out;
      for(var j = 1; j < 5; j++) {
         isZero[i][j] = IsZero();
         isZero[i][j].in <== prevUnifiedBodies[i][j] - currentGoal[j];
         inner_result[i][j] <== inner_result[i][j-1] + isZero[i][j].out;
      }
      isAMatch[i] = IsEqual();
      isAMatch[i].in[0] <== inner_result[i][5-1];
      isAMatch[i].in[1] <== 5;

      result[i] <== result[i-1] + isAMatch[i].out;
   }
   signal mathcing_result;
   mathcing_result <== result[13-1];
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
   signal input unified_body[13][5];
   signal input goal_args[5];
   signal output c;
	var monthly_consumption = 86;
	var currentConsumption = 87;
	var currentPrice = 88;
	var inputPayment = 89;
	var rolling_treshold = 90;
	var savings_treshold = 91;
	var support_matrix = 92;
	var social_suport = 93;
	var monthlyConsumptions = 96;
	var sumOfMonthlyConsumptions = 94;
	var rollingConsumption = 100;
	var consumptionClass = 102;
	var savingsClass = 104;
	var priceBase = 106;
	var applySupport = 108;
	var applySavingsSupport = 109;
	var socialCreds = 110;
	var applySocialSupports = 95;
	var endPrice = 112;
	var inputPriceOk = 113;
	var writeSteps = 114;
	var true = 115;

   var none = 0;
	component monthlyConsumptionsGoal = GoalMonthlyConsumptions();
	component sumOfMonthlyConsumptionsGoal = GoalSumOfMonthlyConsumptions();
	component rollingConsumptionGoal = GoalRollingConsumption();
	component consumptionClassGoal = GoalConsumptionClass();
	component savingsClassGoal = GoalSavingsClass();
	component priceBaseGoal = GoalPriceBase();
	component applySupportGoal = GoalApplySupport();
	component applySavingsSupportGoal = GoalApplySavingsSupport();
	component socialCredsGoal = GoalSocialCreds();
	component applySocialSupportsGoal = GoalApplySocialSupports();
	component endPriceGoal = GoalEndPrice();
	component inputPriceOkGoal = GoalInputPriceOk();
	component writeStepsGoal = GoalWriteSteps();
	component knowledge[10];
	for (var i = 0; i < 10; i++) {
		knowledge[i] = KnowledgeChecker();
	}
	signal result[28];
	signal ruleSelector[28];
	ruleSelector[0] <== IsEqual()([goal_args[0], monthlyConsumptions]);
	monthlyConsumptionsGoal.goal_args <== goal_args;
	monthlyConsumptionsGoal.unified_body[0] <== unified_body[0];
	result[0] <== monthlyConsumptionsGoal.c*ruleSelector[0];
	ruleSelector[1] <== IsEqual()([goal_args[0], sumOfMonthlyConsumptions]);
	sumOfMonthlyConsumptionsGoal.goal_args <== goal_args;
	sumOfMonthlyConsumptionsGoal.unified_body[0] <== unified_body[0];
	sumOfMonthlyConsumptionsGoal.unified_body[1] <== unified_body[1];
	result[1] <== sumOfMonthlyConsumptionsGoal.c*ruleSelector[1] + result[0];
	ruleSelector[2] <== IsEqual()([goal_args[0], rollingConsumption]);
	rollingConsumptionGoal.goal_args <== goal_args;
	rollingConsumptionGoal.unified_body[0] <== unified_body[0];
	result[2] <== rollingConsumptionGoal.c*ruleSelector[2] + result[1];
	ruleSelector[3] <== IsEqual()([goal_args[0], consumptionClass]);
	consumptionClassGoal.goal_args <== goal_args;
	consumptionClassGoal.unified_body[0] <== unified_body[0];
	consumptionClassGoal.unified_body[1] <== unified_body[1];
	consumptionClassGoal.unified_body[2] <== unified_body[2];
	result[3] <== consumptionClassGoal.c*ruleSelector[3] + result[2];
	ruleSelector[4] <== IsEqual()([goal_args[0], savingsClass]);
	savingsClassGoal.goal_args <== goal_args;
	savingsClassGoal.unified_body[0] <== unified_body[0];
	savingsClassGoal.unified_body[1] <== unified_body[1];
	savingsClassGoal.unified_body[2] <== unified_body[2];
	savingsClassGoal.unified_body[3] <== unified_body[3];
	result[4] <== savingsClassGoal.c*ruleSelector[4] + result[3];
	ruleSelector[5] <== IsEqual()([goal_args[0], priceBase]);
	priceBaseGoal.goal_args <== goal_args;
	priceBaseGoal.unified_body[0] <== unified_body[0];
	priceBaseGoal.unified_body[1] <== unified_body[1];
	priceBaseGoal.unified_body[2] <== unified_body[2];
	result[5] <== priceBaseGoal.c*ruleSelector[5] + result[4];
	ruleSelector[6] <== IsEqual()([goal_args[0], applySupport]);
	applySupportGoal.goal_args <== goal_args;
	applySupportGoal.unified_body[0] <== unified_body[0];
	applySupportGoal.unified_body[1] <== unified_body[1];
	result[6] <== applySupportGoal.c*ruleSelector[6] + result[5];
	ruleSelector[7] <== IsEqual()([goal_args[0], applySavingsSupport]);
	applySavingsSupportGoal.goal_args <== goal_args;
	applySavingsSupportGoal.unified_body[0] <== unified_body[0];
	applySavingsSupportGoal.unified_body[1] <== unified_body[1];
	result[7] <== applySavingsSupportGoal.c*ruleSelector[7] + result[6];
	ruleSelector[8] <== IsEqual()([goal_args[0], socialCreds]);
	socialCredsGoal.goal_args <== goal_args;
	socialCredsGoal.unified_body[0] <== unified_body[0];
	result[8] <== socialCredsGoal.c*ruleSelector[8] + result[7];
	ruleSelector[9] <== IsEqual()([goal_args[0], applySocialSupports]);
	applySocialSupportsGoal.goal_args <== goal_args;
	applySocialSupportsGoal.unified_body[0] <== unified_body[0];
	applySocialSupportsGoal.unified_body[1] <== unified_body[1];
	result[9] <== applySocialSupportsGoal.c*ruleSelector[9] + result[8];
	ruleSelector[10] <== IsEqual()([goal_args[0], endPrice]);
	endPriceGoal.goal_args <== goal_args;
	endPriceGoal.unified_body[0] <== unified_body[0];
	endPriceGoal.unified_body[1] <== unified_body[1];
	endPriceGoal.unified_body[2] <== unified_body[2];
	endPriceGoal.unified_body[3] <== unified_body[3];
	endPriceGoal.unified_body[4] <== unified_body[4];
	endPriceGoal.unified_body[5] <== unified_body[5];
	endPriceGoal.unified_body[6] <== unified_body[6];
	endPriceGoal.unified_body[7] <== unified_body[7];
	endPriceGoal.unified_body[8] <== unified_body[8];
	endPriceGoal.unified_body[9] <== unified_body[9];
	result[10] <== endPriceGoal.c*ruleSelector[10] + result[9];
	ruleSelector[11] <== IsEqual()([goal_args[0], inputPriceOk]);
	inputPriceOkGoal.goal_args <== goal_args;
	inputPriceOkGoal.unified_body[0] <== unified_body[0];
	inputPriceOkGoal.unified_body[1] <== unified_body[1];
	result[11] <== inputPriceOkGoal.c*ruleSelector[11] + result[10];
	ruleSelector[12] <== IsEqual()([goal_args[0], writeSteps]);
	writeStepsGoal.goal_args <== goal_args;
	writeStepsGoal.unified_body[0] <== unified_body[0];
	writeStepsGoal.unified_body[1] <== unified_body[1];
	writeStepsGoal.unified_body[2] <== unified_body[2];
	writeStepsGoal.unified_body[3] <== unified_body[3];
	writeStepsGoal.unified_body[4] <== unified_body[4];
	writeStepsGoal.unified_body[5] <== unified_body[5];
	writeStepsGoal.unified_body[6] <== unified_body[6];
	writeStepsGoal.unified_body[7] <== unified_body[7];
	writeStepsGoal.unified_body[8] <== unified_body[8];
	writeStepsGoal.unified_body[9] <== unified_body[9];
	result[12] <== writeStepsGoal.c*ruleSelector[12] + result[11];
	ruleSelector[13] <== IsEqual()([goal_args[0], monthly_consumption]);
	knowledge[0].a <== goal_args;
	result[13] <== knowledge[0].c*ruleSelector[13] + result[12];
	ruleSelector[14] <== IsEqual()([goal_args[0], currentConsumption]);
	knowledge[1].a <== goal_args;
	result[14] <== knowledge[1].c*ruleSelector[14] + result[13];
	ruleSelector[15] <== IsEqual()([goal_args[0], currentPrice]);
	knowledge[2].a <== goal_args;
	result[15] <== knowledge[2].c*ruleSelector[15] + result[14];
	ruleSelector[16] <== IsEqual()([goal_args[0], inputPayment]);
	knowledge[3].a <== goal_args;
	result[16] <== knowledge[3].c*ruleSelector[16] + result[15];
	ruleSelector[17] <== IsEqual()([goal_args[0], rolling_treshold]);
	knowledge[4].a <== goal_args;
	result[17] <== knowledge[4].c*ruleSelector[17] + result[16];
	ruleSelector[18] <== IsEqual()([goal_args[0], savings_treshold]);
	knowledge[5].a <== goal_args;
	result[18] <== knowledge[5].c*ruleSelector[18] + result[17];
	ruleSelector[19] <== IsEqual()([goal_args[0], support_matrix]);
	knowledge[6].a <== goal_args;
	result[19] <== knowledge[6].c*ruleSelector[19] + result[18];
	ruleSelector[20] <== IsEqual()([goal_args[0], social_suport]);
	knowledge[7].a <== goal_args;
	result[20] <== knowledge[7].c*ruleSelector[20] + result[19];
	ruleSelector[21] <== IsEqual()([goal_args[0], sumOfMonthlyConsumptions]);
	knowledge[8].a <== goal_args;
	result[21] <== knowledge[8].c*ruleSelector[21] + result[20];
	ruleSelector[22] <== IsEqual()([goal_args[0], applySocialSupports]);
	knowledge[9].a <== goal_args;
	result[22] <== knowledge[9].c*ruleSelector[22] + result[21];
	ruleSelector[23] <== IsEqual()([goal_args[0], 98]);
	result[23] <== ruleSelector[23] + result[22];
	ruleSelector[24] <== IsEqual()([goal_args[0], 97]);
	result[24] <== ruleSelector[24] + result[23];
	ruleSelector[25] <== IsEqual()([goal_args[0], 103]);
	result[25] <== ruleSelector[25] + result[24];

   component trueSelector = IsEqual();
   trueSelector.in[0] <== goal_args[0];
   trueSelector.in[1] <== true;
   result[25+3-2] <== trueSelector.out + result[25+3-3];

   component noneSelector = IsZero();
   noneSelector.in <== goal_args[0];
   result[25+3-1] <== noneSelector.out + result[25+3-2];


   signal finalResult;
   finalResult <== GreaterEqThan(8)([result[25+3-1], 1]);

   c <== finalResult;
   c === 1;
}

template GoalMonthlyConsumptions() {
	signal input unified_body[1][5];
	signal input goal_args[5];
	signal output c;
	var none = 0;
	var monthly_consumption = 86;
	var currentConsumption = 87;
	var currentPrice = 88;
	var inputPayment = 89;
	var rolling_treshold = 90;
	var savings_treshold = 91;
	var support_matrix = 92;
	var social_suport = 93;
	var monthlyConsumptions = 96;
	var sumOfMonthlyConsumptions = 94;
	var rollingConsumption = 100;
	var consumptionClass = 102;
	var savingsClass = 104;
	var priceBase = 106;
	var applySupport = 108;
	var applySavingsSupport = 109;
	var socialCreds = 110;
	var applySocialSupports = 95;
	var endPrice = 112;
	var inputPriceOk = 113;
	var writeSteps = 114;
	signal ruleSelector[1];
	signal ruleSelector_intermediate[1][1];
	ruleSelector_intermediate[0][0] <== IsEqual()([unified_body[0][0], 115]);
	ruleSelector[0] <== IsEqual()([ruleSelector_intermediate[0][0], 1]);
	signal result[2];
	signal intermediateResult0[1];
	intermediateResult0[0] <== 1;
	signal resConstraint0;
	resConstraint0 <== IsEqual()([intermediateResult0[0], 1]);
	result[0] <== resConstraint0 * ruleSelector[0];

	signal finalResult;
	finalResult <== GreaterEqThan(8)([result[0], 1]);
	if(finalResult != 1 && goal_args[0] == monthlyConsumptions) {
		log("monthlyConsumptions failed");
		log("Result[0] failed: ", result[0]);
	} else {
		log("monthlyConsumptions succeeded");
	}

	c <== finalResult;
}

template GoalSumOfMonthlyConsumptions() {
	signal input unified_body[2][5];
	signal input goal_args[5];
	signal output c;
	var none = 0;
	var monthly_consumption = 86;
	var currentConsumption = 87;
	var currentPrice = 88;
	var inputPayment = 89;
	var rolling_treshold = 90;
	var savings_treshold = 91;
	var support_matrix = 92;
	var social_suport = 93;
	var monthlyConsumptions = 96;
	var sumOfMonthlyConsumptions = 94;
	var rollingConsumption = 100;
	var consumptionClass = 102;
	var savingsClass = 104;
	var priceBase = 106;
	var applySupport = 108;
	var applySavingsSupport = 109;
	var socialCreds = 110;
	var applySocialSupports = 95;
	var endPrice = 112;
	var inputPriceOk = 113;
	var writeSteps = 114;
	signal ruleSelector[1];
	signal ruleSelector_intermediate[1][2];
	ruleSelector_intermediate[0][0] <== IsEqual()([unified_body[0][0], sumOfMonthlyConsumptions]);
	component isEqual0_1 = IsEqual();
	isEqual0_1.in[0] <== unified_body[1][0];
	isEqual0_1.in[1] <== 98;
	ruleSelector_intermediate[0][1] <== isEqual0_1.out + ruleSelector_intermediate[0][0];
	ruleSelector[0] <== IsEqual()([ruleSelector_intermediate[0][1], 2]);
	signal result[2];
	signal intermediateResult0[1];
	component constraint0_0 = IsEqual();
	constraint0_0.in[0] <== unified_body[1][1];
	constraint0_0.in[1] <== goal_args[2];
	intermediateResult0[0] <== constraint0_0.out;
	signal resConstraint0;
	resConstraint0 <== IsEqual()([intermediateResult0[0], 1]);
	result[0] <== resConstraint0 * ruleSelector[0];

		ruleSelector[0]*(unified_body[1][1] - unified_body[1][2] - unified_body[1][3]) === 0;



// Empty array check
	component constraint0 = IsEqual();
	constraint0.in[0] <== goal_args[1];
	constraint0.in[1] <== 83;
	result[1] <== constraint0.out + result[0];
	signal finalResult;
	finalResult <== GreaterEqThan(8)([result[1], 1]);
	if(finalResult != 1 && goal_args[0] == sumOfMonthlyConsumptions) {
		log("sumOfMonthlyConsumptions failed");
		log("Result[0] failed: ", result[0]);
		log("Result[1] failed: ", result[1]);
	} else {
		log("sumOfMonthlyConsumptions succeeded");
	}

	c <== finalResult;
}

template GoalRollingConsumption() {
	signal input unified_body[1][5];
	signal input goal_args[5];
	signal output c;
	var none = 0;
	var monthly_consumption = 86;
	var currentConsumption = 87;
	var currentPrice = 88;
	var inputPayment = 89;
	var rolling_treshold = 90;
	var savings_treshold = 91;
	var support_matrix = 92;
	var social_suport = 93;
	var monthlyConsumptions = 96;
	var sumOfMonthlyConsumptions = 94;
	var rollingConsumption = 100;
	var consumptionClass = 102;
	var savingsClass = 104;
	var priceBase = 106;
	var applySupport = 108;
	var applySavingsSupport = 109;
	var socialCreds = 110;
	var applySocialSupports = 95;
	var endPrice = 112;
	var inputPriceOk = 113;
	var writeSteps = 114;
	signal ruleSelector[1];
	signal ruleSelector_intermediate[1][1];
	ruleSelector_intermediate[0][0] <== IsEqual()([unified_body[0][0], 98]);
	ruleSelector[0] <== IsEqual()([ruleSelector_intermediate[0][0], 1]);
	signal result[2];
	signal intermediateResult0[1];
	component constraint0_0 = IsEqual();
	constraint0_0.in[0] <== unified_body[0][1];
	constraint0_0.in[1] <== goal_args[2];
	intermediateResult0[0] <== constraint0_0.out;
	signal resConstraint0;
	resConstraint0 <== IsEqual()([intermediateResult0[0], 1]);
	result[0] <== resConstraint0 * ruleSelector[0];


	/*unified_body[0][1] == (unified_body[0][2] - (unified_body[0][2] % 12)) / 12
		ruleSelector[0]*() === 0;*/

	component goalCheck = IsEqual();
	goalCheck.in[0] <== goal_args[0];
	goalCheck.in[1] <== rollingConsumption;

	signal x1;
	x1 <== unified_body[0][1];
	signal y1;
	signal y2;
	y1 <-- unified_body[0][2] \ 12;
	y2 <-- unified_body[0][2] % 12;
	unified_body[0][2] === y1*12 + y2;
	signal y3;
	y3 <== x1 - y1;
	signal y4;
	y4 <== ruleSelector[0] * goalCheck.out;
	y3 * y4 === 0;

	signal finalResult;
	finalResult <== GreaterEqThan(8)([result[0], 1]);
	if(finalResult != 1 && goal_args[0] == rollingConsumption) {
		log("rollingConsumption failed");
		log("Result[0] failed: ", result[0]);
	} else {
		log("rollingConsumption succeeded");
	}

	c <== finalResult;
}

template GoalConsumptionClass() {
	signal input unified_body[3][5];
	signal input goal_args[5];
	signal output c;
	var none = 0;
	var monthly_consumption = 86;
	var currentConsumption = 87;
	var currentPrice = 88;
	var inputPayment = 89;
	var rolling_treshold = 90;
	var savings_treshold = 91;
	var support_matrix = 92;
	var social_suport = 93;
	var monthlyConsumptions = 96;
	var sumOfMonthlyConsumptions = 94;
	var rollingConsumption = 100;
	var consumptionClass = 102;
	var savingsClass = 104;
	var priceBase = 106;
	var applySupport = 108;
	var applySavingsSupport = 109;
	var socialCreds = 110;
	var applySocialSupports = 95;
	var endPrice = 112;
	var inputPriceOk = 113;
	var writeSteps = 114;
	signal ruleSelector[3];
	signal ruleSelector_intermediate[3][3];
	ruleSelector_intermediate[0][0] <== IsEqual()([unified_body[0][0], rolling_treshold]);
	component isEqual0_1 = IsEqual();
	isEqual0_1.in[0] <== unified_body[1][0];
	isEqual0_1.in[1] <== 103;
	ruleSelector_intermediate[0][1] <== isEqual0_1.out + ruleSelector_intermediate[0][0];
	component isEqual0_2 = IsEqual();
	isEqual0_2.in[0] <== unified_body[2][0];
	isEqual0_2.in[1] <== 97;
	ruleSelector_intermediate[0][2] <== isEqual0_2.out + ruleSelector_intermediate[0][1];
	ruleSelector[0] <== IsEqual()([ruleSelector_intermediate[0][2], 3]);
	ruleSelector_intermediate[1][0] <== IsEqual()([unified_body[0][0], rolling_treshold]);
	component isEqual1_1 = IsEqual();
	isEqual1_1.in[0] <== unified_body[1][0];
	isEqual1_1.in[1] <== 103;
	ruleSelector_intermediate[1][1] <== isEqual1_1.out + ruleSelector_intermediate[1][0];
	component isEqual1_2 = IsEqual();
	isEqual1_2.in[0] <== unified_body[2][0];
	isEqual1_2.in[1] <== 97;
	ruleSelector_intermediate[1][2] <== isEqual1_2.out + ruleSelector_intermediate[1][1];
	ruleSelector[1] <== IsEqual()([ruleSelector_intermediate[1][2], 3]);
	ruleSelector_intermediate[2][0] <== IsEqual()([unified_body[0][0], 97]);
	component isZero2_1 = IsZero();
	isZero2_1.in <== unified_body[1][0];
	ruleSelector_intermediate[2][1] <== isZero2_1.out + ruleSelector_intermediate[2][0];
	component isZero2_2 = IsZero();
	isZero2_2.in <== unified_body[2][0];
	ruleSelector_intermediate[2][2] <== isZero2_2.out + ruleSelector_intermediate[2][1];
	ruleSelector[2] <== IsEqual()([ruleSelector_intermediate[2][2], 3]);
	signal result[6];
	signal intermediateResult0[3];
	component constraint0_0 = IsEqual();
	constraint0_0.in[0] <== unified_body[1][1];
	constraint0_0.in[1] <== goal_args[1];
	intermediateResult0[0] <== constraint0_0.out;
	component constraint0_1 = IsEqual();
	constraint0_1.in[0] <== unified_body[2][1];
	constraint0_1.in[1] <== goal_args[2];
	intermediateResult0[1] <== constraint0_1.out + intermediateResult0[0];
	component constraint0_2 = IsEqual();
	constraint0_2.in[0] <== unified_body[0][2];
	constraint0_2.in[1] <== unified_body[1][2];
	intermediateResult0[2] <== constraint0_2.out + intermediateResult0[1];
	signal resConstraint0;
	resConstraint0 <== IsEqual()([intermediateResult0[2], 3]);
	result[0] <== resConstraint0 * ruleSelector[0];

	signal intermediateResult1[3];
	component constraint1_0 = IsEqual();
	constraint1_0.in[0] <== unified_body[1][1];
	constraint1_0.in[1] <== goal_args[1];
	intermediateResult1[0] <== constraint1_0.out;
	component constraint1_1 = IsEqual();
	constraint1_1.in[0] <== unified_body[2][1];
	constraint1_1.in[1] <== goal_args[2];
	intermediateResult1[1] <== constraint1_1.out + intermediateResult1[0];
	component constraint1_2 = IsEqual();
	constraint1_2.in[0] <== unified_body[0][2];
	constraint1_2.in[1] <== unified_body[1][2];
	intermediateResult1[2] <== constraint1_2.out + intermediateResult1[1];
	signal resConstraint1;
	resConstraint1 <== IsEqual()([intermediateResult1[2], 3]);
	result[1] <== resConstraint1 * ruleSelector[1] + result[0];

	signal intermediateResult2[1];
	intermediateResult2[0] <== 1;
	signal resConstraint2;
	resConstraint2 <== IsEqual()([intermediateResult2[0], 1]);
	result[2] <== resConstraint2 * ruleSelector[2] + result[1];

	signal finalResult;
	finalResult <== GreaterEqThan(8)([result[2], 1]);
	if(finalResult != 1 && goal_args[0] == consumptionClass) {
		log("consumptionClass failed");
		log("Result[0] failed: ", result[0]);
		log("Result[1] failed: ", result[1]);
		log("Result[2] failed: ", result[2]);
	} else {
		log("consumptionClass succeeded");
	}

	c <== finalResult;
}

template GoalSavingsClass() {
	signal input unified_body[4][5];
	signal input goal_args[5];
	signal output c;
	var none = 0;
	var monthly_consumption = 86;
	var currentConsumption = 87;
	var currentPrice = 88;
	var inputPayment = 89;
	var rolling_treshold = 90;
	var savings_treshold = 91;
	var support_matrix = 92;
	var social_suport = 93;
	var monthlyConsumptions = 96;
	var sumOfMonthlyConsumptions = 94;
	var rollingConsumption = 100;
	var consumptionClass = 102;
	var savingsClass = 104;
	var priceBase = 106;
	var applySupport = 108;
	var applySavingsSupport = 109;
	var socialCreds = 110;
	var applySocialSupports = 95;
	var endPrice = 112;
	var inputPriceOk = 113;
	var writeSteps = 114;
	signal ruleSelector[4];
	signal ruleSelector_intermediate[4][4];
	ruleSelector_intermediate[0][0] <== IsEqual()([unified_body[0][0], savings_treshold]);
	component isEqual0_1 = IsEqual();
	isEqual0_1.in[0] <== unified_body[1][0];
	isEqual0_1.in[1] <== 98;
	ruleSelector_intermediate[0][1] <== isEqual0_1.out + ruleSelector_intermediate[0][0];
	component isEqual0_2 = IsEqual();
	isEqual0_2.in[0] <== unified_body[2][0];
	isEqual0_2.in[1] <== 103;
	ruleSelector_intermediate[0][2] <== isEqual0_2.out + ruleSelector_intermediate[0][1];
	component isEqual0_3 = IsEqual();
	isEqual0_3.in[0] <== unified_body[3][0];
	isEqual0_3.in[1] <== 97;
	ruleSelector_intermediate[0][3] <== isEqual0_3.out + ruleSelector_intermediate[0][2];
	ruleSelector[0] <== IsEqual()([ruleSelector_intermediate[0][3], 4]);
	ruleSelector_intermediate[1][0] <== IsEqual()([unified_body[0][0], savings_treshold]);
	component isEqual1_1 = IsEqual();
	isEqual1_1.in[0] <== unified_body[1][0];
	isEqual1_1.in[1] <== 98;
	ruleSelector_intermediate[1][1] <== isEqual1_1.out + ruleSelector_intermediate[1][0];
	component isEqual1_2 = IsEqual();
	isEqual1_2.in[0] <== unified_body[2][0];
	isEqual1_2.in[1] <== 103;
	ruleSelector_intermediate[1][2] <== isEqual1_2.out + ruleSelector_intermediate[1][1];
	component isEqual1_3 = IsEqual();
	isEqual1_3.in[0] <== unified_body[3][0];
	isEqual1_3.in[1] <== 97;
	ruleSelector_intermediate[1][3] <== isEqual1_3.out + ruleSelector_intermediate[1][2];
	ruleSelector[1] <== IsEqual()([ruleSelector_intermediate[1][3], 4]);
	ruleSelector_intermediate[2][0] <== IsEqual()([unified_body[0][0], savings_treshold]);
	component isEqual2_1 = IsEqual();
	isEqual2_1.in[0] <== unified_body[1][0];
	isEqual2_1.in[1] <== 98;
	ruleSelector_intermediate[2][1] <== isEqual2_1.out + ruleSelector_intermediate[2][0];
	component isEqual2_2 = IsEqual();
	isEqual2_2.in[0] <== unified_body[2][0];
	isEqual2_2.in[1] <== 103;
	ruleSelector_intermediate[2][2] <== isEqual2_2.out + ruleSelector_intermediate[2][1];
	component isEqual2_3 = IsEqual();
	isEqual2_3.in[0] <== unified_body[3][0];
	isEqual2_3.in[1] <== 97;
	ruleSelector_intermediate[2][3] <== isEqual2_3.out + ruleSelector_intermediate[2][2];
	ruleSelector[2] <== IsEqual()([ruleSelector_intermediate[2][3], 4]);
	ruleSelector_intermediate[3][0] <== IsEqual()([unified_body[0][0], 97]);
	component isZero3_1 = IsZero();
	isZero3_1.in <== unified_body[1][0];
	ruleSelector_intermediate[3][1] <== isZero3_1.out + ruleSelector_intermediate[3][0];
	component isZero3_2 = IsZero();
	isZero3_2.in <== unified_body[2][0];
	ruleSelector_intermediate[3][2] <== isZero3_2.out + ruleSelector_intermediate[3][1];
	component isZero3_3 = IsZero();
	isZero3_3.in <== unified_body[3][0];
	ruleSelector_intermediate[3][3] <== isZero3_3.out + ruleSelector_intermediate[3][2];
	ruleSelector[3] <== IsEqual()([ruleSelector_intermediate[3][3], 4]);
	signal result[8];
	signal intermediateResult0[3];
	component constraint0_0 = IsEqual();
	constraint0_0.in[0] <== unified_body[3][1];
	constraint0_0.in[1] <== goal_args[3];
	intermediateResult0[0] <== constraint0_0.out;
	component constraint0_1 = IsEqual();
	constraint0_1.in[0] <== unified_body[0][2];
	constraint0_1.in[1] <== unified_body[2][2];
	intermediateResult0[1] <== constraint0_1.out + intermediateResult0[0];
	component constraint0_2 = IsEqual();
	constraint0_2.in[0] <== unified_body[1][1];
	constraint0_2.in[1] <== unified_body[2][1];
	intermediateResult0[2] <== constraint0_2.out + intermediateResult0[1];
	signal resConstraint0;
	resConstraint0 <== IsEqual()([intermediateResult0[2], 3]);
	result[0] <== resConstraint0 * ruleSelector[0];

	signal intermediateResult1[3];
	component constraint1_0 = IsEqual();
	constraint1_0.in[0] <== unified_body[3][1];
	constraint1_0.in[1] <== goal_args[3];
	intermediateResult1[0] <== constraint1_0.out;
	component constraint1_1 = IsEqual();
	constraint1_1.in[0] <== unified_body[0][2];
	constraint1_1.in[1] <== unified_body[2][2];
	intermediateResult1[1] <== constraint1_1.out + intermediateResult1[0];
	component constraint1_2 = IsEqual();
	constraint1_2.in[0] <== unified_body[1][1];
	constraint1_2.in[1] <== unified_body[2][1];
	intermediateResult1[2] <== constraint1_2.out + intermediateResult1[1];
	signal resConstraint1;
	resConstraint1 <== IsEqual()([intermediateResult1[2], 3]);
	result[1] <== resConstraint1 * ruleSelector[1] + result[0];

	signal intermediateResult2[3];
	component constraint2_0 = IsEqual();
	constraint2_0.in[0] <== unified_body[3][1];
	constraint2_0.in[1] <== goal_args[3];
	intermediateResult2[0] <== constraint2_0.out;
	component constraint2_1 = IsEqual();
	constraint2_1.in[0] <== unified_body[0][2];
	constraint2_1.in[1] <== unified_body[2][2];
	intermediateResult2[1] <== constraint2_1.out + intermediateResult2[0];
	component constraint2_2 = IsEqual();
	constraint2_2.in[0] <== unified_body[1][1];
	constraint2_2.in[1] <== unified_body[2][1];
	intermediateResult2[2] <== constraint2_2.out + intermediateResult2[1];
	signal resConstraint2;
	resConstraint2 <== IsEqual()([intermediateResult2[2], 3]);
	result[2] <== resConstraint2 * ruleSelector[2] + result[1];

	signal intermediateResult3[1];
	intermediateResult3[0] <== 1;
	signal resConstraint3;
	resConstraint3 <== IsEqual()([intermediateResult3[0], 1]);
	result[3] <== resConstraint3 * ruleSelector[3] + result[2];

		ruleSelector[0]*(unified_body[1][1] - unified_body[1][2] + unified_body[1][3]) === 0;

		ruleSelector[1]*(unified_body[1][1] - unified_body[1][2] + unified_body[1][3]) === 0;

		ruleSelector[2]*(unified_body[1][1] - unified_body[1][2] + unified_body[1][3]) === 0;

	signal finalResult;
	finalResult <== GreaterEqThan(8)([result[3], 1]);
	if(finalResult != 1 && goal_args[0] == savingsClass) {
		log("savingsClass failed");
		log("Result[0] failed: ", result[0]);
		log("Result[1] failed: ", result[1]);
		log("Result[2] failed: ", result[2]);
		log("Result[3] failed: ", result[3]);
	} else {
		log("savingsClass succeeded");
	}

	c <== finalResult;
}

template GoalPriceBase() {
	signal input unified_body[3][5];
	signal input goal_args[5];
	signal output c;
	var none = 0;
	var monthly_consumption = 86;
	var currentConsumption = 87;
	var currentPrice = 88;
	var inputPayment = 89;
	var rolling_treshold = 90;
	var savings_treshold = 91;
	var support_matrix = 92;
	var social_suport = 93;
	var monthlyConsumptions = 96;
	var sumOfMonthlyConsumptions = 94;
	var rollingConsumption = 100;
	var consumptionClass = 102;
	var savingsClass = 104;
	var priceBase = 106;
	var applySupport = 108;
	var applySavingsSupport = 109;
	var socialCreds = 110;
	var applySocialSupports = 95;
	var endPrice = 112;
	var inputPriceOk = 113;
	var writeSteps = 114;
	signal ruleSelector[1];
	signal ruleSelector_intermediate[1][3];
	ruleSelector_intermediate[0][0] <== IsEqual()([unified_body[0][0], currentConsumption]);
	component isEqual0_1 = IsEqual();
	isEqual0_1.in[0] <== unified_body[1][0];
	isEqual0_1.in[1] <== currentPrice;
	ruleSelector_intermediate[0][1] <== isEqual0_1.out + ruleSelector_intermediate[0][0];
	component isEqual0_2 = IsEqual();
	isEqual0_2.in[0] <== unified_body[2][0];
	isEqual0_2.in[1] <== 98;
	ruleSelector_intermediate[0][2] <== isEqual0_2.out + ruleSelector_intermediate[0][1];
	ruleSelector[0] <== IsEqual()([ruleSelector_intermediate[0][2], 3]);
	signal result[2];
	signal intermediateResult0[1];
	component constraint0_0 = IsEqual();
	constraint0_0.in[0] <== unified_body[2][1];
	constraint0_0.in[1] <== goal_args[1];
	intermediateResult0[0] <== constraint0_0.out;
	signal resConstraint0;
	resConstraint0 <== IsEqual()([intermediateResult0[0], 1]);
	result[0] <== resConstraint0 * ruleSelector[0];

		//ruleSelector[0]*(unified_body[2][1] - unified_body[2][2] * unified_body[2][3]) === 0;
	signal x1;
	x1 <== unified_body[2][1];
	signal y1;
	y1 <== unified_body[2][2] * unified_body[2][3];
	signal y2;
	y2 <== x1 - y1;
	signal y3;
	y3 <== y2 * ruleSelector[0];
	y3 === 0;

	signal finalResult;
	finalResult <== GreaterEqThan(8)([result[0], 1]);
	if(finalResult != 1 && goal_args[0] == priceBase) {
		log("priceBase failed");
		log("Result[0] failed: ", result[0]);
	} else {
		log("priceBase succeeded");
	}

	c <== finalResult;
}

template GoalApplySupport() {
	signal input unified_body[2][5];
	signal input goal_args[5];
	signal output c;
	var none = 0;
	var monthly_consumption = 86;
	var currentConsumption = 87;
	var currentPrice = 88;
	var inputPayment = 89;
	var rolling_treshold = 90;
	var savings_treshold = 91;
	var support_matrix = 92;
	var social_suport = 93;
	var monthlyConsumptions = 96;
	var sumOfMonthlyConsumptions = 94;
	var rollingConsumption = 100;
	var consumptionClass = 102;
	var savingsClass = 104;
	var priceBase = 106;
	var applySupport = 108;
	var applySavingsSupport = 109;
	var socialCreds = 110;
	var applySocialSupports = 95;
	var endPrice = 112;
	var inputPriceOk = 113;
	var writeSteps = 114;
	signal ruleSelector[2];
	signal ruleSelector_intermediate[2][2];
	ruleSelector_intermediate[0][0] <== IsEqual()([unified_body[0][0], 98]);
	component isZero0_1 = IsZero();
	isZero0_1.in <== unified_body[1][0];
	ruleSelector_intermediate[0][1] <== isZero0_1.out + ruleSelector_intermediate[0][0];
	ruleSelector[0] <== IsEqual()([ruleSelector_intermediate[0][1], 2]);

	ruleSelector_intermediate[1][0] <== IsEqual()([unified_body[0][0], 98]);
	component isEqual1_1 = IsEqual();
	isEqual1_1.in[0] <== unified_body[1][0];
	isEqual1_1.in[1] <== 98;
	ruleSelector_intermediate[1][1] <== isEqual1_1.out + ruleSelector_intermediate[1][0];
	ruleSelector[1] <== IsEqual()([ruleSelector_intermediate[1][1], 2]);

	signal result[4];
	signal intermediateResult0[1];
	component constraint0_0 = IsEqual();
	constraint0_0.in[0] <== unified_body[0][1];
	constraint0_0.in[1] <== goal_args[4];
	intermediateResult0[0] <== constraint0_0.out;
	signal resConstraint0;
	resConstraint0 <== IsEqual()([intermediateResult0[0], 1]);
	result[0] <== resConstraint0 * ruleSelector[0];

	signal intermediateResult1[1];
	component constraint1_0 = IsEqual();
	constraint1_0.in[0] <== unified_body[1][1];
	constraint1_0.in[1] <== goal_args[4];
	intermediateResult1[0] <== constraint1_0.out;
	signal resConstraint1;
	resConstraint1 <== IsEqual()([intermediateResult1[0], 1]);
	result[1] <== resConstraint1 * ruleSelector[1] + result[0];
	log("RuleSelector[0]: ", ruleSelector[0]);
	log("unified_body[0]:", unified_body[0][0], unified_body[0][1], unified_body[0][2], unified_body[0][3]);
	log("unified_body[1]:", unified_body[1][0], unified_body[1][1], unified_body[1][2], unified_body[1][3]);

	component goalCheck = IsEqual();
	goalCheck.in[0] <== goal_args[0];
	goalCheck.in[1] <== applySupport;
	signal q1;
	q1 <== goalCheck.out*ruleSelector[0];
		q1*(unified_body[0][1] - (unified_body[0][2] - unified_body[0][3])) === 0;

		//ruleSelector[1]*(unified_body[0][1] == unified_body[0][2] * ((unified_body[0][3] - (unified_body[0][3] % 100)) / 100)) === 0;
	signal x1;
	x1 <== unified_body[0][1];
	signal y1;
	y1 <== unified_body[0][2] * unified_body[0][3];
	signal y2;
	signal y3;
	y2 <-- y1\100;
	y3 <-- y1%100;
	y1 === y2*100 + y3;
	signal y4;
	y4 <== x1 - y2;
	y4 * ruleSelector[1] === 0;
		ruleSelector[1]*(unified_body[1][1] - unified_body[1][2] + unified_body[1][3]) === 0;

	signal finalResult;
	finalResult <== GreaterEqThan(8)([result[1], 1]);
	if(finalResult != 1 && goal_args[0] == applySupport) {
		log("applySupport failed");
		log("Result[0] failed: ", result[0]);
		log("Result[1] failed: ", result[1]);
	} else {
		log("applySupport succeeded");
	}

	c <== finalResult;
}

template GoalApplySavingsSupport() {
	signal input unified_body[2][5];
	signal input goal_args[5];
	signal output c;
	var none = 0;
	var monthly_consumption = 86;
	var currentConsumption = 87;
	var currentPrice = 88;
	var inputPayment = 89;
	var rolling_treshold = 90;
	var savings_treshold = 91;
	var support_matrix = 92;
	var social_suport = 93;
	var monthlyConsumptions = 96;
	var sumOfMonthlyConsumptions = 94;
	var rollingConsumption = 100;
	var consumptionClass = 102;
	var savingsClass = 104;
	var priceBase = 106;
	var applySupport = 108;
	var applySavingsSupport = 109;
	var socialCreds = 110;
	var applySocialSupports = 95;
	var endPrice = 112;
	var inputPriceOk = 113;
	var writeSteps = 114;
	signal ruleSelector[1];
	signal ruleSelector_intermediate[1][2];
	ruleSelector_intermediate[0][0] <== IsEqual()([unified_body[0][0], support_matrix]);
	component isEqual0_1 = IsEqual();
	isEqual0_1.in[0] <== unified_body[1][0];
	isEqual0_1.in[1] <== applySupport;
	ruleSelector_intermediate[0][1] <== isEqual0_1.out + ruleSelector_intermediate[0][0];
	ruleSelector[0] <== IsEqual()([ruleSelector_intermediate[0][1], 2]);
	signal result[2];
	signal intermediateResult0[5];
	component constraint0_0 = IsEqual();
	constraint0_0.in[0] <== unified_body[0][1];
	constraint0_0.in[1] <== goal_args[3];
	intermediateResult0[0] <== constraint0_0.out;
	component constraint0_1 = IsEqual();
	constraint0_1.in[0] <== unified_body[0][2];
	constraint0_1.in[1] <== goal_args[2];
	intermediateResult0[1] <== constraint0_1.out + intermediateResult0[0];
	component constraint0_2 = IsEqual();
	constraint0_2.in[0] <== unified_body[1][1];
	constraint0_2.in[1] <== goal_args[1];
	intermediateResult0[2] <== constraint0_2.out + intermediateResult0[1];
	component constraint0_3 = IsEqual();
	constraint0_3.in[0] <== unified_body[1][4];
	constraint0_3.in[1] <== goal_args[4];
	intermediateResult0[3] <== constraint0_3.out + intermediateResult0[2];
	component constraint0_4 = IsEqual();
	constraint0_4.in[0] <== unified_body[0][3];
	constraint0_4.in[1] <== unified_body[1][2];
	intermediateResult0[4] <== constraint0_4.out + intermediateResult0[3];
	signal resConstraint0;
	resConstraint0 <== IsEqual()([intermediateResult0[4], 5]);
	result[0] <== resConstraint0 * ruleSelector[0];

	signal finalResult;
	finalResult <== GreaterEqThan(8)([result[0], 1]);
	if(finalResult != 1 && goal_args[0] == applySavingsSupport) {
		log("applySavingsSupport failed");
		log("Result[0] failed: ", result[0]);
	} else {
		log("applySavingsSupport succeeded");
	}

	c <== finalResult;
}

template GoalSocialCreds() {
	signal input unified_body[1][5];
	signal input goal_args[5];
	signal output c;
	var none = 0;
	var monthly_consumption = 86;
	var currentConsumption = 87;
	var currentPrice = 88;
	var inputPayment = 89;
	var rolling_treshold = 90;
	var savings_treshold = 91;
	var support_matrix = 92;
	var social_suport = 93;
	var monthlyConsumptions = 96;
	var sumOfMonthlyConsumptions = 94;
	var rollingConsumption = 100;
	var consumptionClass = 102;
	var savingsClass = 104;
	var priceBase = 106;
	var applySupport = 108;
	var applySavingsSupport = 109;
	var socialCreds = 110;
	var applySocialSupports = 95;
	var endPrice = 112;
	var inputPriceOk = 113;
	var writeSteps = 114;
	signal ruleSelector[1];
	signal ruleSelector_intermediate[1][1];
	ruleSelector_intermediate[0][0] <== IsEqual()([unified_body[0][0], 115]);
	ruleSelector[0] <== IsEqual()([ruleSelector_intermediate[0][0], 1]);
	signal result[2];
	signal intermediateResult0[1];
	intermediateResult0[0] <== 1;
	signal resConstraint0;
	resConstraint0 <== IsEqual()([intermediateResult0[0], 1]);
	result[0] <== resConstraint0 * ruleSelector[0];

	signal finalResult;
	finalResult <== GreaterEqThan(8)([result[0], 1]);
	if(finalResult != 1 && goal_args[0] == socialCreds) {
		log("socialCreds failed");
		log("Result[0] failed: ", result[0]);
	} else {
		log("socialCreds succeeded");
	}

	c <== finalResult;
}

template GoalApplySocialSupports() {
	signal input unified_body[2][5];
	signal input goal_args[5];
	signal output c;
	var none = 0;
	var monthly_consumption = 86;
	var currentConsumption = 87;
	var currentPrice = 88;
	var inputPayment = 89;
	var rolling_treshold = 90;
	var savings_treshold = 91;
	var support_matrix = 92;
	var social_suport = 93;
	var monthlyConsumptions = 96;
	var sumOfMonthlyConsumptions = 94;
	var rollingConsumption = 100;
	var consumptionClass = 102;
	var savingsClass = 104;
	var priceBase = 106;
	var applySupport = 108;
	var applySavingsSupport = 109;
	var socialCreds = 110;
	var applySocialSupports = 95;
	var endPrice = 112;
	var inputPriceOk = 113;
	var writeSteps = 114;
	signal ruleSelector[1];
	signal ruleSelector_intermediate[1][2];
	ruleSelector_intermediate[0][0] <== IsEqual()([unified_body[0][0], applySupport]);
	component isEqual0_1 = IsEqual();
	isEqual0_1.in[0] <== unified_body[1][0];
	isEqual0_1.in[1] <== applySocialSupports;
	ruleSelector_intermediate[0][1] <== isEqual0_1.out + ruleSelector_intermediate[0][0];
	ruleSelector[0] <== IsEqual()([ruleSelector_intermediate[0][1], 2]);
	signal result[2];
	signal intermediateResult0[3];
	component constraint0_0 = IsEqual();
	constraint0_0.in[0] <== unified_body[0][1];
	constraint0_0.in[1] <== goal_args[1];
	intermediateResult0[0] <== constraint0_0.out;
	component constraint0_1 = IsEqual();
	constraint0_1.in[0] <== unified_body[1][3];
	constraint0_1.in[1] <== goal_args[3];
	intermediateResult0[1] <== constraint0_1.out + intermediateResult0[0];
	component constraint0_2 = IsEqual();
	constraint0_2.in[0] <== unified_body[0][4];
	constraint0_2.in[1] <== unified_body[1][1];
	intermediateResult0[2] <== constraint0_2.out + intermediateResult0[1];
	signal resConstraint0;
	resConstraint0 <== IsEqual()([intermediateResult0[2], 3]);
	result[0] <== resConstraint0 * ruleSelector[0];

// Empty array check
	component constraint0 = IsEqual();
	constraint0.in[0] <== goal_args[2];
	constraint0.in[1] <== 83;
	result[1] <== constraint0.out + result[0];
	signal finalResult;
	finalResult <== GreaterEqThan(8)([result[1], 1]);
	if(finalResult != 1 && goal_args[0] == applySocialSupports) {
		log("applySocialSupports failed");
		log("Result[0] failed: ", result[0]);
		log("Result[1] failed: ", result[1]);
	} else {
		log("applySocialSupports succeeded");
	}

	c <== finalResult;
}

template GoalEndPrice() {
	signal input unified_body[10][5];
	signal input goal_args[5];
	signal output c;
	var none = 0;
	var monthly_consumption = 86;
	var currentConsumption = 87;
	var currentPrice = 88;
	var inputPayment = 89;
	var rolling_treshold = 90;
	var savings_treshold = 91;
	var support_matrix = 92;
	var social_suport = 93;
	var monthlyConsumptions = 96;
	var sumOfMonthlyConsumptions = 94;
	var rollingConsumption = 100;
	var consumptionClass = 102;
	var savingsClass = 104;
	var priceBase = 106;
	var applySupport = 108;
	var applySavingsSupport = 109;
	var socialCreds = 110;
	var applySocialSupports = 95;
	var endPrice = 112;
	var inputPriceOk = 113;
	var writeSteps = 114;
	signal ruleSelector[1];
	signal ruleSelector_intermediate[1][10];
	ruleSelector_intermediate[0][0] <== IsEqual()([unified_body[0][0], monthlyConsumptions]);
	component isEqual0_1 = IsEqual();
	isEqual0_1.in[0] <== unified_body[1][0];
	isEqual0_1.in[1] <== sumOfMonthlyConsumptions;
	ruleSelector_intermediate[0][1] <== isEqual0_1.out + ruleSelector_intermediate[0][0];
	component isEqual0_2 = IsEqual();
	isEqual0_2.in[0] <== unified_body[2][0];
	isEqual0_2.in[1] <== rollingConsumption;
	ruleSelector_intermediate[0][2] <== isEqual0_2.out + ruleSelector_intermediate[0][1];
	component isEqual0_3 = IsEqual();
	isEqual0_3.in[0] <== unified_body[3][0];
	isEqual0_3.in[1] <== currentConsumption;
	ruleSelector_intermediate[0][3] <== isEqual0_3.out + ruleSelector_intermediate[0][2];
	component isEqual0_4 = IsEqual();
	isEqual0_4.in[0] <== unified_body[4][0];
	isEqual0_4.in[1] <== consumptionClass;
	ruleSelector_intermediate[0][4] <== isEqual0_4.out + ruleSelector_intermediate[0][3];
	component isEqual0_5 = IsEqual();
	isEqual0_5.in[0] <== unified_body[5][0];
	isEqual0_5.in[1] <== savingsClass;
	ruleSelector_intermediate[0][5] <== isEqual0_5.out + ruleSelector_intermediate[0][4];
	component isEqual0_6 = IsEqual();
	isEqual0_6.in[0] <== unified_body[6][0];
	isEqual0_6.in[1] <== priceBase;
	ruleSelector_intermediate[0][6] <== isEqual0_6.out + ruleSelector_intermediate[0][5];
	component isEqual0_7 = IsEqual();
	isEqual0_7.in[0] <== unified_body[7][0];
	isEqual0_7.in[1] <== applySavingsSupport;
	ruleSelector_intermediate[0][7] <== isEqual0_7.out + ruleSelector_intermediate[0][6];
	component isEqual0_8 = IsEqual();
	isEqual0_8.in[0] <== unified_body[8][0];
	isEqual0_8.in[1] <== socialCreds;
	ruleSelector_intermediate[0][8] <== isEqual0_8.out + ruleSelector_intermediate[0][7];
	component isEqual0_9 = IsEqual();
	isEqual0_9.in[0] <== unified_body[9][0];
	isEqual0_9.in[1] <== applySocialSupports;
	ruleSelector_intermediate[0][9] <== isEqual0_9.out + ruleSelector_intermediate[0][8];
	ruleSelector[0] <== IsEqual()([ruleSelector_intermediate[0][9], 10]);
	signal result[2];
	signal intermediateResult0[10];
	component constraint0_0 = IsEqual();
	constraint0_0.in[0] <== unified_body[9][3];
	constraint0_0.in[1] <== goal_args[1];
	intermediateResult0[0] <== constraint0_0.out;
	component constraint0_1 = IsEqual();
	constraint0_1.in[0] <== unified_body[0][1];
	constraint0_1.in[1] <== unified_body[1][1];
	intermediateResult0[1] <== constraint0_1.out + intermediateResult0[0];
	component constraint0_2 = IsEqual();
	constraint0_2.in[0] <== unified_body[1][2];
	constraint0_2.in[1] <== unified_body[2][1];
	intermediateResult0[2] <== constraint0_2.out + intermediateResult0[1];
	component constraint0_3 = IsEqual();
	constraint0_3.in[0] <== unified_body[2][2];
	constraint0_3.in[1] <== unified_body[4][1];
	intermediateResult0[3] <== constraint0_3.out + intermediateResult0[2];
	component constraint0_4 = IsEqual();
	constraint0_4.in[0] <== unified_body[4][1];
	constraint0_4.in[1] <== unified_body[5][1];
	intermediateResult0[4] <== constraint0_4.out + intermediateResult0[3];
	component constraint0_5 = IsEqual();
	constraint0_5.in[0] <== unified_body[3][1];
	constraint0_5.in[1] <== unified_body[5][2];
	intermediateResult0[5] <== constraint0_5.out + intermediateResult0[4];
	component constraint0_6 = IsEqual();
	constraint0_6.in[0] <== unified_body[5][3];
	constraint0_6.in[1] <== unified_body[7][2];
	intermediateResult0[6] <== constraint0_6.out + intermediateResult0[5];
	component constraint0_7 = IsEqual();
	constraint0_7.in[0] <== unified_body[6][1];
	constraint0_7.in[1] <== unified_body[7][1];
	intermediateResult0[7] <== constraint0_7.out + intermediateResult0[6];
	component constraint0_8 = IsEqual();
	constraint0_8.in[0] <== unified_body[7][4];
	constraint0_8.in[1] <== unified_body[9][1];
	intermediateResult0[8] <== constraint0_8.out + intermediateResult0[7];
	component constraint0_9 = IsEqual();
	constraint0_9.in[0] <== unified_body[8][1];
	constraint0_9.in[1] <== unified_body[9][2];
	intermediateResult0[9] <== constraint0_9.out + intermediateResult0[8];
	signal resConstraint0;
	resConstraint0 <== IsEqual()([intermediateResult0[9], 10]);
	result[0] <== resConstraint0 * ruleSelector[0];

	signal finalResult;
	finalResult <== GreaterEqThan(8)([result[0], 1]);
	if(finalResult != 1 && goal_args[0] == endPrice) {
		log("endPrice failed");
		log("Result[0] failed: ", result[0]);
	} else {
		log("endPrice succeeded");
	}

	c <== finalResult;
}

template GoalInputPriceOk() {
	signal input unified_body[2][5];
	signal input goal_args[5];
	signal output c;
	var none = 0;
	var monthly_consumption = 86;
	var currentConsumption = 87;
	var currentPrice = 88;
	var inputPayment = 89;
	var rolling_treshold = 90;
	var savings_treshold = 91;
	var support_matrix = 92;
	var social_suport = 93;
	var monthlyConsumptions = 96;
	var sumOfMonthlyConsumptions = 94;
	var rollingConsumption = 100;
	var consumptionClass = 102;
	var savingsClass = 104;
	var priceBase = 106;
	var applySupport = 108;
	var applySavingsSupport = 109;
	var socialCreds = 110;
	var applySocialSupports = 95;
	var endPrice = 112;
	var inputPriceOk = 113;
	var writeSteps = 114;
	signal ruleSelector[1];
	signal ruleSelector_intermediate[1][2];
	ruleSelector_intermediate[0][0] <== IsEqual()([unified_body[0][0], endPrice]);
	component isEqual0_1 = IsEqual();
	isEqual0_1.in[0] <== unified_body[1][0];
	isEqual0_1.in[1] <== inputPayment;
	ruleSelector_intermediate[0][1] <== isEqual0_1.out + ruleSelector_intermediate[0][0];
	ruleSelector[0] <== IsEqual()([ruleSelector_intermediate[0][1], 2]);
	signal result[2];
	signal intermediateResult0[1];
	component constraint0_0 = IsEqual();
	constraint0_0.in[0] <== unified_body[0][1];
	constraint0_0.in[1] <== unified_body[1][1];
	intermediateResult0[0] <== constraint0_0.out;
	signal resConstraint0;
	resConstraint0 <== IsEqual()([intermediateResult0[0], 1]);
	result[0] <== resConstraint0 * ruleSelector[0];

	signal finalResult;
	finalResult <== GreaterEqThan(8)([result[0], 1]);
	if(finalResult != 1 && goal_args[0] == inputPriceOk) {
		log("inputPriceOk failed");
		log("Result[0] failed: ", result[0]);
	} else {
		log("inputPriceOk succeeded");
	}

	c <== finalResult;
}

template GoalWriteSteps() {
	signal input unified_body[10][5];
	signal input goal_args[5];
	signal output c;
	var none = 0;
	var monthly_consumption = 86;
	var currentConsumption = 87;
	var currentPrice = 88;
	var inputPayment = 89;
	var rolling_treshold = 90;
	var savings_treshold = 91;
	var support_matrix = 92;
	var social_suport = 93;
	var monthlyConsumptions = 96;
	var sumOfMonthlyConsumptions = 94;
	var rollingConsumption = 100;
	var consumptionClass = 102;
	var savingsClass = 104;
	var priceBase = 106;
	var applySupport = 108;
	var applySavingsSupport = 109;
	var socialCreds = 110;
	var applySocialSupports = 95;
	var endPrice = 112;
	var inputPriceOk = 113;
	var writeSteps = 114;
	signal ruleSelector[1];
	signal ruleSelector_intermediate[1][10];
	ruleSelector_intermediate[0][0] <== IsEqual()([unified_body[0][0], monthlyConsumptions]);
	component isEqual0_1 = IsEqual();
	isEqual0_1.in[0] <== unified_body[1][0];
	isEqual0_1.in[1] <== sumOfMonthlyConsumptions;
	ruleSelector_intermediate[0][1] <== isEqual0_1.out + ruleSelector_intermediate[0][0];
	component isEqual0_2 = IsEqual();
	isEqual0_2.in[0] <== unified_body[2][0];
	isEqual0_2.in[1] <== rollingConsumption;
	ruleSelector_intermediate[0][2] <== isEqual0_2.out + ruleSelector_intermediate[0][1];
	component isEqual0_3 = IsEqual();
	isEqual0_3.in[0] <== unified_body[3][0];
	isEqual0_3.in[1] <== currentConsumption;
	ruleSelector_intermediate[0][3] <== isEqual0_3.out + ruleSelector_intermediate[0][2];
	component isEqual0_4 = IsEqual();
	isEqual0_4.in[0] <== unified_body[4][0];
	isEqual0_4.in[1] <== consumptionClass;
	ruleSelector_intermediate[0][4] <== isEqual0_4.out + ruleSelector_intermediate[0][3];
	component isEqual0_5 = IsEqual();
	isEqual0_5.in[0] <== unified_body[5][0];
	isEqual0_5.in[1] <== savingsClass;
	ruleSelector_intermediate[0][5] <== isEqual0_5.out + ruleSelector_intermediate[0][4];
	component isEqual0_6 = IsEqual();
	isEqual0_6.in[0] <== unified_body[6][0];
	isEqual0_6.in[1] <== priceBase;
	ruleSelector_intermediate[0][6] <== isEqual0_6.out + ruleSelector_intermediate[0][5];
	component isEqual0_7 = IsEqual();
	isEqual0_7.in[0] <== unified_body[7][0];
	isEqual0_7.in[1] <== applySavingsSupport;
	ruleSelector_intermediate[0][7] <== isEqual0_7.out + ruleSelector_intermediate[0][6];
	component isEqual0_8 = IsEqual();
	isEqual0_8.in[0] <== unified_body[8][0];
	isEqual0_8.in[1] <== socialCreds;
	ruleSelector_intermediate[0][8] <== isEqual0_8.out + ruleSelector_intermediate[0][7];
	component isEqual0_9 = IsEqual();
	isEqual0_9.in[0] <== unified_body[9][0];
	isEqual0_9.in[1] <== applySocialSupports;
	ruleSelector_intermediate[0][9] <== isEqual0_9.out + ruleSelector_intermediate[0][8];
	ruleSelector[0] <== IsEqual()([ruleSelector_intermediate[0][9], 10]);
	signal result[2];
	signal intermediateResult0[9];
	component constraint0_0 = IsEqual();
	constraint0_0.in[0] <== unified_body[0][1];
	constraint0_0.in[1] <== unified_body[1][1];
	intermediateResult0[0] <== constraint0_0.out;
	component constraint0_1 = IsEqual();
	constraint0_1.in[0] <== unified_body[1][2];
	constraint0_1.in[1] <== unified_body[2][1];
	intermediateResult0[1] <== constraint0_1.out + intermediateResult0[0];
	component constraint0_2 = IsEqual();
	constraint0_2.in[0] <== unified_body[2][2];
	constraint0_2.in[1] <== unified_body[4][1];
	intermediateResult0[2] <== constraint0_2.out + intermediateResult0[1];
	component constraint0_3 = IsEqual();
	constraint0_3.in[0] <== unified_body[4][1];
	constraint0_3.in[1] <== unified_body[5][1];
	intermediateResult0[3] <== constraint0_3.out + intermediateResult0[2];
	component constraint0_4 = IsEqual();
	constraint0_4.in[0] <== unified_body[3][1];
	constraint0_4.in[1] <== unified_body[5][2];
	intermediateResult0[4] <== constraint0_4.out + intermediateResult0[3];
	component constraint0_5 = IsEqual();
	constraint0_5.in[0] <== unified_body[5][3];
	constraint0_5.in[1] <== unified_body[7][2];
	intermediateResult0[5] <== constraint0_5.out + intermediateResult0[4];
	component constraint0_6 = IsEqual();
	constraint0_6.in[0] <== unified_body[6][1];
	constraint0_6.in[1] <== unified_body[7][1];
	intermediateResult0[6] <== constraint0_6.out + intermediateResult0[5];
	component constraint0_7 = IsEqual();
	constraint0_7.in[0] <== unified_body[7][4];
	constraint0_7.in[1] <== unified_body[9][1];
	intermediateResult0[7] <== constraint0_7.out + intermediateResult0[6];
	component constraint0_8 = IsEqual();
	constraint0_8.in[0] <== unified_body[8][1];
	constraint0_8.in[1] <== unified_body[9][2];
	intermediateResult0[8] <== constraint0_8.out + intermediateResult0[7];
	signal resConstraint0;
	resConstraint0 <== IsEqual()([intermediateResult0[8], 9]);
	result[0] <== resConstraint0 * ruleSelector[0];

	signal finalResult;
	finalResult <== GreaterEqThan(8)([result[0], 1]);
	if(finalResult != 1 && goal_args[0] == writeSteps) {
		log("writeSteps failed");
		log("Result[0] failed: ", result[0]);
	} else {
		log("writeSteps succeeded");
	}

	c <== finalResult;
}



template KnowledgeChecker() {
   
   signal input a[5];
   signal output c;
   var len = 33;
   var knowledgeBase[len][5] = [[86, 1, 2001, 0, 0],[86, 2, 2001, 0, 0],[86, 3, 2001, 0, 0],[86, 4, 2001, 0, 0],[86, 5, 2001, 0, 0],[86, 6, 2001, 0, 0],[86, 7, 2000, 0, 0],[86, 8, 2000, 0, 0],[86, 9, 2000, 0, 0],[86, 10, 2000, 0, 0],[86, 11, 2000, 0, 0],[86, 12, 2000, 0, 0],[87, 1400, 0, 0, 0],[88, 747, 27, 0, 0],[89, 931220, 0, 0, 0],[90, 66, 0, 0, 0],[90, 70, 3000, 0, 0],[90, 74, 7000, 0, 0],[91, 66, 250, 0, 0],[91, 70, 500, 0, 0],[91, 74, 1000, 0, 0],[92, 66, 66, 78, 500],[92, 66, 70, 47, 10],[92, 66, 74, 78, 500],[92, 70, 66, 78, 500],[92, 70, 70, 78, 500],[92, 70, 74, 78, 500],[92, 74, 66, 78, 500],[92, 74, 70, 78, 500],[92, 74, 74, 78, 500],[93, 77, 78, 10000, 0],[94, 83, 0, 0, 0],[95, 70805418, 83, 70805418, 0]];
   signal result[len];
   component arrayIsEqual[len];


   arrayIsEqual[0] = ArrayIsEqual(5);
   arrayIsEqual[0].in[0] <== a;
   arrayIsEqual[0].in[1] <== knowledgeBase[0];
   result[0] <== arrayIsEqual[0].out;

   for(var i = 1; i < len; i++){
      arrayIsEqual[i] = ArrayIsEqual(5);
      arrayIsEqual[i].in[0] <== a;
      arrayIsEqual[i].in[1] <== knowledgeBase[i];
      result[i] <== arrayIsEqual[i].out + result[i-1];
   }

   signal final_result;
   final_result <== IsEqual()([result[len-1], 1]);
   c <-- final_result;
 }

 component main = PrologResolutionTree(4, 13);
