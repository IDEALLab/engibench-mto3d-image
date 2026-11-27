Info<< "\nslove linear elasticity equation\n" << endl;

initialResidual_D = convergenceTolerance_D;
iterD=0;
do
{
  {
      fvVectorMatrix DEqn
      (
          fvm::d2dt2(D)
       ==
          fvm::laplacian(2*mu + lambda, D, "laplacian(DD,D)")
        + divSigmaExp
        //- fvc::grad(threeKalpha*T)
      );

      initialResidual_D = DEqn.solve().max().initialResidual();

      if (!compactNormalStress)
      {
          divSigmaExp = fvc::div(DEqn.flux());
      }
  }

  {
      volTensorField gradD(fvc::grad(D));
      sigmaD = mu*twoSymm(gradD) + (lambda*I)*tr(gradD);

      if (compactNormalStress)
      {
          divSigmaExp = fvc::div
          (
              sigmaD - (2*mu + lambda)*gradD,
              "div(sigmaD)"
          );
      }
      else
      {
          divSigmaExp += fvc::div(sigmaD);
      }
  }

} while (initialResidual_D > convergenceTolerance_D && ++iterD < maxIterD);
