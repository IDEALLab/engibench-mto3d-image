Info<< "Initialization\n" << endl;
std::remove("Voluse.txt");
std::remove("Time.txt");
std::remove("MeanT.txt"); 
std::remove("PowerDiss.txt"); 
std::remove("Compliance.txt"); 
std::remove("BI.txt"); 
std::remove("viol.txt"); 
std::remove("normL2.txt"); 
std::remove("qd.txt"); 
std::remove("qu.txt"); 
std::remove("aMax.txt"); 
std::remove("Heaviside.txt"); 

int i=0,opt=0;
label currIt(0);
// double del=0;
// List<double> del_List(optProperties.lookup("del_List"));
// label del_every(readLabel(optProperties.lookup("del_every")));
// label del_pos(0);
// double del(del_List[del_pos]);

scalar n(0),N(0),eta0,eta5,eta1,y0,y5,BI(0);
n=x.size();//n:length of x in the i-th core
N=x.size();//N:design freedom
reduce(N, sumOp<scalar>()); 

scalar C(0),V(0),area=gSum(mesh.V()),MeanT(0),PowerDiss(0);
double len=std::pow(area/N, 1.0/3);
b.value()=1.0/(filterR*len/3.464)/(filterR*len/3.464);
//***********************************//Petsc
PetscInt n_dof=n,N_dof=N,m=2;//m:number of constraints
PetscScalar Xmin=0; // Min. value of design variables
PetscScalar Xmax=1; // Max. value of design variables

Vec xmma,xold,xmin,xmax;
PetscScalar *xmma_array;
VecCreate(PETSC_COMM_WORLD,&xmma);
VecSetSizes(xmma,n_dof,N_dof);
VecSetFromOptions(xmma);
VecGetArray(xmma,&xmma_array);
for(i=0;i<n;i++)
{
  xmma_array[i]=x[i];
}
VecRestoreArray(xmma,&xmma_array);

VecDuplicate(xmma,&xold); 
VecDuplicate(xmma,&xmin);
VecDuplicate(xmma,&xmax); 

PetscScalar aMMA[m];
PetscScalar cMMA[m];
PetscScalar dMMA[m];

for (PetscInt i=0;i<m;i++)
{
  aMMA[i]=0.0;
  dMMA[i]=1.0;
  cMMA[i]=mma_cmma;
}

MMA *mma;
mma=new MMA(N_dof,m,xmma, aMMA, cMMA, dMMA,mma_init,mma_dec,mma_inc);

Vec dfdx; // Sensitivities of objective
VecDuplicate(xmma,&dfdx); 
PetscScalar *dfdx_array;
VecGetArray(dfdx,&dfdx_array);
VecRestoreArray(dfdx,&dfdx_array); 

PetscScalar *gx= new PetscScalar[m]; // Array with constraint values
Vec *dgdx; // Sensitivities of constraints
VecDuplicateVecs(xmma,m, &dgdx); 
PetscScalar **dgdx_array;
VecGetArrays(dgdx,m,&dgdx_array);
VecRestoreArrays(dgdx,m,&dgdx_array);

// const objectRegistry& db = mesh.thisDb();
// label maxIter_=db.time().endTime().value();

// dictionary ContinuationDict(optProperties.subDict("continuation"));
// scalar n_levels(readScalar(ContinuationDict.lookup("n_levels")));
// Info << n_levels << endl;
// return 0;
// dictionary qD_subdict( ContinuationDict.subDict("qD"));
// List<scalar> qD_list;label qD_nSteps, qD_currentPos(0);
// readContinuationParams(qD_subdict, qD_list, qD_nSteps);
// label qD_every(maxIter_/qD_nSteps);

// dictionary qU_subdict( ContinuationDict.subDict("qU"));
// List<scalar> qU_list;label qU_nSteps, qU_currentPos(0);
// readContinuationParams(qU_subdict, qU_list, qU_nSteps);
// label qU_every(maxIter_/qU_nSteps);

// dictionary alphaMax_subdict( ContinuationDict.subDict("alphaMax"));
// List<scalar> alphaMax_list;label alphaMax_nSteps, alphaMax_currentPos(0);
// readContinuationParams(alphaMax_subdict, alphaMax_list, alphaMax_nSteps);
// label alphaMax_every(maxIter_/alphaMax_nSteps);

// dictionary Heaviside_subdict( ContinuationDict.subDict("Heaviside"));
// List<scalar> Heaviside_list;label Heaviside_nSteps, Heaviside_currentPos(0);
// readContinuationParams(Heaviside_subdict, Heaviside_list, Heaviside_nSteps);
// label Heaviside_every(maxIter_/Heaviside_nSteps);

// dictionary jmaxCoeff_subdict( ContinuationDict.subDict("jmaxCoeff"));
// List<scalar> jmaxCoeff_list;label jmaxCoeff_nSteps, jmaxCoeff_currentPos(0);
// readContinuationParams(jmaxCoeff_subdict, jmaxCoeff_list, jmaxCoeff_nSteps);
// label jmaxCoeff_every(maxIter_/jmaxCoeff_nSteps);
// scalar jmaxCoeff(0);

// dictionary cmaxCoeff_subdict( ContinuationDict.subDict("cmaxCoeff"));
// List<scalar> cmaxCoeff_list;label cmaxCoeff_nSteps, cmaxCoeff_currentPos(0);
// readContinuationParams(cmaxCoeff_subdict, cmaxCoeff_list, cmaxCoeff_nSteps);
// label cmaxCoeff_every(maxIter_/cmaxCoeff_nSteps);
// scalar cmaxCoeff(0);

#include "convergenceInit.H"

double del(Heaviside_from);
scalar optConvergenceThreshold(readScalar(optProperties.lookup("optConvergenceThreshold")));