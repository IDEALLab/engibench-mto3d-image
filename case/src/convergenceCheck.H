maxViolation=*std::max_element(gx,gx+2);
norm_i_debug=normL2(xh-xhm1debug);
Info << "Iteration at this level " << iterAtThisLevel << " violation= " << maxViolation << endl;
// usleep(3 * microsecond);//sleeps for 3 second

std::vector<bool> ands{maxViolation < 0 ,iterAtThisLevel>n_transitionItersAtEachLevel+n_restPeriodAtEachLevel};
bool all = std::accumulate(ands.begin(), ands.end(), true, std::logical_and<bool>());
if (all) {
// if (maxViolation < 0 && iterAtThisLevel>n_transitionItersAtEachLevel+n_restPeriodAtEachLevel) {
    norm_i=normL2(xh-xhm1);
    Info << "normL2= " << norm_i << endl;
    // usleep(3 * 1000000);//sleeps for 3 second
    if (norm_i < optConvergenceThreshold) {
        Info << "cnvrgnece iter " << ++convergedIterAtThisLevel << "          " << n_consecutiveConverged << endl;
        // usleep(3 * 1000000);//sleeps for 3 second
        // if (++convergedIterAtThisLevel >= n_consecutiveConverged) {
            // convergedAtThisLevel=true;
        // }
        // convergedIterAtThisLevel++;
        // reduce(convergedIterAtThisLevel, maxOp<int>());
    }
    else {convergedIterAtThisLevel=0;}
    
}
else {convergedIterAtThisLevel=0;}
if (maxViolation < 0){
    xhm1=xh;
}
xhm1debug=xh;

// if maximum violation less than 0 
// if maximum change between the current xh and the previous one for two consecutive
// iterations falls bellow a threshold, we converged!
// if maxViol<0 && iter>10
//      diffxh=xh-xh_im1
//      ni=norm(diffxh)
//      if ni < thresh
//          if convergedIter>nConverged
//              converged!
//          convergedIter++
//      else
//          convergedIter=0
//      xh_im1=xh
// else
//      convergedIter=0
