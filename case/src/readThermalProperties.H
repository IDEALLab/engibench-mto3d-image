Info<< "Reading thermal properties\n" << endl;
IOdictionary thermalProperties
(
    IOobject
    (
        "thermalProperties",
        runTime.constant(),
        mesh,
        IOobject::MUST_READ_IF_MODIFIED,
        IOobject::NO_WRITE
    )
);

dimensionedScalar rhoc(thermalProperties.lookup("rhoc"));//rho_fluid*heat_capacity
dimensionedScalar kf(thermalProperties.lookup("kf"));//Thermal Conductivity of fluid
dimensionedScalar ks(thermalProperties.lookup("ks"));//Thermal Conductivity of solid
dimensionedScalar Q(thermalProperties.lookup("Q"));//Primal body force heat source
dimensionedScalar adjointQ(thermalProperties.lookup("adjointQ"));//Adjoint body force heat source
scalar nSolid(readScalar(thermalProperties.lookup("numberOfPassiveElements")));

volScalarField DT
(
    IOobject
    (
        "DT",
        runTime.timeName(),
        mesh,
        IOobject::READ_IF_PRESENT,
        IOobject::NO_WRITE
    ),
    (ks+(kf-ks)*xh*(1+qu)/(qu+xh))/rhoc
);
Info<< "Reading field T\n" << endl;
    volScalarField T
    (
        IOobject
        (
            "T",
            runTime.timeName(),
            mesh,
            IOobject::MUST_READ,
            IOobject::NO_WRITE
        ),
        mesh
    );
Info<< "Reading field Tb\n" << endl;
   volScalarField Tb
   (
       IOobject
       (
           "Tb",
           runTime.timeName(),
           mesh,
           IOobject::MUST_READ,
           IOobject::NO_WRITE
       ),
       mesh
   ); 
volScalarField T2(T);
volScalarField fsensMeanT
(
    IOobject
    (
        "fsensMeanT",
        runTime.timeName(),
        mesh,
        IOobject::NO_READ,
        IOobject::NO_WRITE
    ),
    -alphaMax*(1+qu)*qu/((qu+xh)*(qu+xh))*(U&Ub),
    zeroGradientFvPatchScalarField::typeName
);
volScalarField fsenshMeanT(fsensMeanT);
