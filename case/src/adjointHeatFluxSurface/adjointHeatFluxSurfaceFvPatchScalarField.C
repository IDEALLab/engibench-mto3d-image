
#include "adjointHeatFluxSurfaceFvPatchScalarField.H"
#include "addToRunTimeSelectionTable.H"
#include "volFields.H"
#include "surfaceFields.H"

// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //

namespace Foam
{

// * * * * * * * * * * * * * * * * Constructors  * * * * * * * * * * * * * * //

adjointHeatFluxSurfaceFvPatchScalarField::
adjointHeatFluxSurfaceFvPatchScalarField
(
    const fvPatch& p,
    const DimensionedField<scalar, volMesh>& iF
)
:
    fixedGradientFvPatchScalarField(p, iF),
    pressure_(p.size(), 0.0)
{
    fvPatchScalarField::operator=(patchInternalField());
    gradient() = Zero;
}


adjointHeatFluxSurfaceFvPatchScalarField::
adjointHeatFluxSurfaceFvPatchScalarField
(
    const adjointHeatFluxSurfaceFvPatchScalarField& tdpvf,
    const fvPatch& p,
    const DimensionedField<scalar, volMesh>& iF,
    const fvPatchFieldMapper& mapper
)
:
    fixedGradientFvPatchScalarField(tdpvf, p, iF, mapper),
    pressure_(tdpvf.pressure_, mapper)
{}


adjointHeatFluxSurfaceFvPatchScalarField::
adjointHeatFluxSurfaceFvPatchScalarField
(
    const fvPatch& p,
    const DimensionedField<scalar, volMesh>& iF,
    const dictionary& dict
)
:
    fixedGradientFvPatchScalarField(p, iF),
    pressure_("LHS", dict, p.size())
{
    fvPatchScalarField::operator=(patchInternalField());
    gradient() = Zero;
}


adjointHeatFluxSurfaceFvPatchScalarField::
adjointHeatFluxSurfaceFvPatchScalarField
(
    const adjointHeatFluxSurfaceFvPatchScalarField& tdpvf
)
:
    fixedGradientFvPatchScalarField(tdpvf),
    pressure_(tdpvf.pressure_)
{}


adjointHeatFluxSurfaceFvPatchScalarField::
adjointHeatFluxSurfaceFvPatchScalarField
(
    const adjointHeatFluxSurfaceFvPatchScalarField& tdpvf,
    const DimensionedField<scalar, volMesh>& iF
)
:
    fixedGradientFvPatchScalarField(tdpvf, iF),
    pressure_(tdpvf.pressure_)
{}


// * * * * * * * * * * * * * * * Member Functions  * * * * * * * * * * * * * //

void adjointHeatFluxSurfaceFvPatchScalarField::autoMap
(
    const fvPatchFieldMapper& m
)
{
    fixedGradientFvPatchScalarField::autoMap(m);
    pressure_.autoMap(m);
}


void adjointHeatFluxSurfaceFvPatchScalarField::rmap
(
    const fvPatchScalarField& ptf,
    const labelList& addr
)
{
    fixedGradientFvPatchScalarField::rmap(ptf, addr);

    const adjointHeatFluxSurfaceFvPatchScalarField& dmptf =
        refCast<const adjointHeatFluxSurfaceFvPatchScalarField>(ptf);

    pressure_.rmap(dmptf.pressure_, addr);
}


void adjointHeatFluxSurfaceFvPatchScalarField::updateCoeffs()
{
    if (updated())
    {
        return;
    }

    const dictionary& thermalProperties = db().lookupObject<IOdictionary>("thermalProperties");
     dimensionedScalar rhoc(thermalProperties.lookup("rhoc"));
    

    const fvPatchField<scalar>& DT =
        patch().lookupPatchField<volScalarField, scalar>("DT");
    // Info << DT[0] << endl;
    const fvPatchField<scalar>& Tb =
        patch().lookupPatchField<volScalarField, scalar>("Tb");    
    const fvsPatchField<scalar>& phi =
    	patch().lookupPatchField<surfaceScalarField, scalar>("phi");
    scalarField U_dot_n = phi/patch().magSf();

    gradient() = 
    (
        (pressure_/rhoc.value()-U_dot_n*Tb)/DT
    );
    fixedGradientFvPatchScalarField::updateCoeffs();
}

void adjointHeatFluxSurfaceFvPatchScalarField::write(Ostream& os) const
{
    fvPatchScalarField::write(os);
    pressure_.writeEntry("pressure", os);
    writeEntry("value", os);
}


// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //

makePatchTypeField
(
    fvPatchScalarField,
    adjointHeatFluxSurfaceFvPatchScalarField
);

// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //

} // End namespace Foam

// ************************************************************************* //
