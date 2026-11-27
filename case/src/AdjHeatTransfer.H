//Tb=T2;
fvScalarMatrix TEqnb
(
   -fvm::div(-phi,Tb) 
   +fvm::laplacian(DT, Tb)
 ==
    adjointQ
);
TEqnb.solve();
