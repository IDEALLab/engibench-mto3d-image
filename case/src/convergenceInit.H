volScalarField xhm1(xh);
volScalarField xhm1debug(xh);
double maxViolation(1e6);
scalar norm_i(1e6);
scalar norm_i_debug(1e6);
int convergedIterAtThisLevel(0);


bool convergedAtThisLevel=false;
label currentLevel(0);
label iterAtThisLevel(0);




dictionary ContinuationDict(optProperties.subDict("continuation"));

label n_beginning(readLabel(ContinuationDict.lookup("n_beginning")));label maxIterAtThisLevel(n_beginning);
label n_levels(readLabel(ContinuationDict.lookup("n_levels")));
label n_transitionItersAtEachLevel(readLabel(ContinuationDict.lookup("n_transitionItersAtEachLevel")));
label n_restPeriodAtEachLevel(readLabel(ContinuationDict.lookup("n_restPeriodAtEachLevel")));
label n_maxIterAtEach(readLabel(ContinuationDict.lookup("n_maxIterAtEach")));
label n_consecutiveConverged(readLabel(ContinuationDict.lookup("n_consecutiveConverged")));

// read continuation parameters from continuation dictionary
//qD
dictionary qD_subdict( ContinuationDict.subDict("qD"));
word qD_overallType = word(qD_subdict.lookup("overallType"));
word qD_transitionAtLevelType = word(qD_subdict.lookup("transitionAtLevelType"));
scalar qD_from = scalar(readScalar(qD_subdict.lookup("from")));
scalar qD_to = scalar(readScalar(qD_subdict.lookup("to")));
List<scalar> qD_overallList;
List<scalar> qD_transitionAtThisLevelList;
createContinuationList(qD_overallType,qD_from,qD_to, qD_overallList, n_levels);
//qU
dictionary qU_subdict( ContinuationDict.subDict("qU"));
word qU_overallType = word(qU_subdict.lookup("overallType"));
word qU_transitionAtLevelType = word(qU_subdict.lookup("transitionAtLevelType"));
scalar qU_from = scalar(readScalar(qU_subdict.lookup("from")));
scalar qU_to = scalar(readScalar(qU_subdict.lookup("to")));
List<scalar> qU_overallList;
List<scalar> qU_transitionAtThisLevelList;
createContinuationList(qU_overallType,qU_from,qU_to, qU_overallList, n_levels);
//alphaMax
dictionary alphaMax_subdict( ContinuationDict.subDict("alphaMax"));
word alphaMax_overallType = word(alphaMax_subdict.lookup("overallType"));
word alphaMax_transitionAtLevelType = word(alphaMax_subdict.lookup("transitionAtLevelType"));
scalar alphaMax_from = scalar(readScalar(alphaMax_subdict.lookup("from")));
scalar alphaMax_to = scalar(readScalar(alphaMax_subdict.lookup("to")));
List<scalar> alphaMax_overallList;
List<scalar> alphaMax_transitionAtThisLevelList;
createContinuationList(alphaMax_overallType,alphaMax_from,alphaMax_to, alphaMax_overallList, n_levels);
//Heaviside
dictionary Heaviside_subdict( ContinuationDict.subDict("Heaviside"));
word Heaviside_overallType = word(Heaviside_subdict.lookup("overallType"));
word Heaviside_transitionAtLevelType = word(Heaviside_subdict.lookup("transitionAtLevelType"));
scalar Heaviside_from = scalar(readScalar(Heaviside_subdict.lookup("from")));
scalar Heaviside_to = scalar(readScalar(Heaviside_subdict.lookup("to")));
List<scalar> Heaviside_overallList;
List<scalar> Heaviside_transitionAtThisLevelList;
createContinuationList(Heaviside_overallType,Heaviside_from,Heaviside_to, Heaviside_overallList, n_levels);
Info << "aMax:" << nl <<alphaMax_overallList << endl;
Info << "qu:" <<nl << qU_overallList << endl;
Info << "Heaviside:" << nl << Heaviside_overallList << endl;
// return 0;


// - create the beginning of each level based on their overallType
//     linspace/geomspace from to n_levels
// - 