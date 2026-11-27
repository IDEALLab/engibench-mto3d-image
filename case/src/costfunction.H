Info<<"cost function"<<endl;
// gradD=fvc::grad(D);  
// sigmaD=mu*twoSymm(gradD) + (lambda*I)*tr(gradD);  
// volScalarField Energy(0.25*(gradD+gradD.T())&&sigmaD); 

// C=fvc::domainIntegrate(Energy).value()/C0;
// MeanT=fvc::domainIntegrate(T).value()/area;
V=fvc::domainIntegrate(xh).value()/area-voluse;  

MeanT=0;
for (i=0; i<nObjPatch_solid; i++)
{
   MeanT=MeanT+sum(T.boundaryField()[conPatchList_solid[i]]);
}

// Info << "sum t is: " << MeanT << endl;
MeanT = MeanT/nSolid;
reduce(MeanT, sumOp<scalar>()); 
// Info << "mean t is: " << MeanT << endl;
// return 0;
PowerDiss=0;
for (i=0; i<nObjPatch; i++)
{
     PowerDiss =PowerDiss - sum(
     phi.boundaryField()[conPatchList[i]]*(p.boundaryField()[conPatchList[i]]
     + 0.5*magSqr(U.boundaryField()[conPatchList[i]]))); 
}
PowerDiss=PowerDiss/PowerDiss0;
if(GeoDim==2)
{
 PowerDiss=PowerDiss/std::pow(mesh.V()[0],1.0/3);
}
reduce(PowerDiss, sumOp<scalar>()); 
BI = (4*N*100)*fvc::domainIntegrate(xh*(1-xh)).value();
//输出目标及约束值
if (Pstream::master())
{ 
   ofstream outfile1("Voluse.txt",std::ios::app);
   outfile1<<opt<<"\t"<<V<<"\n";
   outfile1.close();

   ofstream outfile2("PowerDiss.txt",std::ios::app);
   outfile2<<opt<<"\t"<<PowerDiss<<"\n";
   outfile2.close(); 

   ofstream outfile3("MeanT.txt",std::ios::app);
   outfile3<<opt<<"\t"<<MeanT<<"\n";
   outfile3.close(); 

   ofstream outfile4("Time.txt",std::ios::app);
   outfile4<<opt<<"\t"<<runTime.elapsedClockTime()<<"\n";
   outfile4.close();   


   ofstream outfile6("BI.txt",std::ios::app);
   outfile6<<opt<<"\t"<<BI<<"\n";
   outfile6.close();  
}
