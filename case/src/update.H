
opt++;
currIt++;
//不可设计域
if(solid_area)
{
   forAll(cells_solid, i)
   {
      xh[cells_solid[i]]=0;
   }
}
if(fluid_area)
{
   forAll(cells_fluid, i)
   {
      xh[cells_fluid[i]]=1.0;
   }
}
xh.correctBoundaryConditions();
//流体问题一些参数的放松
// if(opt<=63)//45,95,145
// {
//   alphaMax=alphamax*(opt/7.0+1.0);
// }
// if(opt>63)
// {
//   alphaMax=alphaMax*1.05;
// }

// alphaMax.value()=Foam::min(alphaMax.value(),alphaMAX.value());
//
// if(opt>=63)
// {
//   qu=0.01+(opt-63)*1e-4;
// }
// qu=Foam::min(qu,0.02);
//
// alphaMax.value()=fromListContinuation(alphaMax.value(), alphaMax_list, alphaMax_every, currIt, alphaMax_currentPos);
// qu=fromListContinuation(qu, qU_list, qU_every, currIt, qU_currentPos);
// qd=fromListContinuation(qd, qD_list, qD_every, currIt, qD_currentPos);
Info << "begining: "  <<currentLevel << "iterAtThisLevel: " << iterAtThisLevel << endl;
reduce(convergedIterAtThisLevel,maxOp<int>());
// usleep(3 * 1000000);//sleeps for 3 second
std::vector<bool> ors{iterAtThisLevel >= maxIterAtThisLevel,convergedIterAtThisLevel>n_consecutiveConverged};
bool any = std::accumulate(ors.begin(), ors.end(), false, std::logical_or<bool>());
if (any){
// if ((iterAtThisLevel >= maxIterAtThisLevel) || convergedAtThisLevel){//go to next level
   Info << "converged: "  <<currentLevel << "iterAtThisLevel: " << iterAtThisLevel << endl;
   // usleep(3 * 1000000);//sleeps for 3 second
   currentLevel++;
   iterAtThisLevel=0;
   convergedIterAtThisLevel=0;
   convergedAtThisLevel=false;
}
reduce(currentLevel,maxOp<label>());
if (currentLevel==0){//we're at the beginning, so all parameters are constant for n_beginning iterations
   Info << "at level 0" << endl;
   // usleep(3 * 1000000);//sleeps for 3 second
   alphaMax.value()=alphaMax_overallList[0];
   qu=qU_overallList[0];
   // qd=qD_overallList[0];
   del=Heaviside_overallList[0];
} 
else if (currentLevel < n_levels){
   if(iterAtThisLevel==0){//we need to initialize the ramps and stuff
      maxIterAtThisLevel=n_maxIterAtEach;
      // createContinuationList(qD_transitionAtLevelType,qD_overallList[currentLevel-1],qD_overallList[currentLevel], qD_transitionAtThisLevelList, n_transitionItersAtEachLevel);
      createContinuationList(qU_transitionAtLevelType,qU_overallList[currentLevel-1],qU_overallList[currentLevel], qU_transitionAtThisLevelList, n_transitionItersAtEachLevel);
      createContinuationList(alphaMax_transitionAtLevelType,alphaMax_overallList[currentLevel-1],alphaMax_overallList[currentLevel], alphaMax_transitionAtThisLevelList, n_transitionItersAtEachLevel);
      createContinuationList(Heaviside_transitionAtLevelType,Heaviside_overallList[currentLevel-1],Heaviside_overallList[currentLevel], Heaviside_transitionAtThisLevelList, n_transitionItersAtEachLevel);
      Info << "lists created at level: " << currentLevel << "current Iteration:" << iterAtThisLevel << endl;
      // usleep(3 * 1000000);//sleeps for 3 second
   }
   alphaMax.value()=alphaMax_transitionAtThisLevelList[Foam::min(iterAtThisLevel,n_transitionItersAtEachLevel-1)];//So this index means after n_transitionItersAtEachLevel-1 the index is cte
   qu=qU_transitionAtThisLevelList[Foam::min(iterAtThisLevel,n_transitionItersAtEachLevel-1)];
   // qd=qD_transitionAtThisLevelList[Foam::min(iterAtThisLevel,n_transitionItersAtEachLevel-1)];
   del=Heaviside_transitionAtThisLevelList[Foam::min(iterAtThisLevel,n_transitionItersAtEachLevel-1)];
} else {//currentLevel>n_levels so, we're done!
   //finishparallelrun
   // #include "finalize.H"//程序终止，delete变量
   // break; 
   converged=true;
   changed = runTime.stopAt(Foam::Time::stopAtControls::saWriteNow);
   runTime++;
   Info << "all converged!" << endl;
   
   // usleep(3 * 1000000);//sleeps for 3 second
   
   
   // while (!runTime.end()){
   //    runTime++;
   // }
   // #include "finalize.H"//程序终止，delete变量
   // return 0;
}
iterAtThisLevel++;



//材料参数更新
alpha=alphaMax*qu*(1-xh)/(qu+xh);
DT=(ks+(kf-ks)*xh*(1+qu)/(qu+xh))/rhoc;
// mu=qd*(1-xh)/(qd+xh)*(E-Emin)/(2.0*(1.0+Po))+Emin/(2.0*(1.0+Po));
// lambda=qd*(1-xh)/(qd+xh)*Po*(E-Emin)/((1.0+Po)*(1.0-2.0*Po))+Po*Emin/((1.0+Po)*(1.0-2.0*Po));
// if (planeStress)
// {
//    lambda=qd*(1-xh)/(qd+xh)*Po*(E-Emin)/((1.0+Po)*(1.0-Po))+Po*Emin/((1.0+Po)*(1.0-Po));
// }