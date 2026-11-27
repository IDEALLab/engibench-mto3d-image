/*--------------------------------*- C++ -*----------------------------------*\
| =========                 |                                                 |
| \\      /  F ield         | OpenFOAM: The Open Source CFD Toolbox           |
|  \\    /   O peration     | Version:  5                                     |
|   \\  /    A nd           | Web:      www.OpenFOAM.org                      |
|    \\/     M anipulation  |                                                 |
\*---------------------------------------------------------------------------*/
FoamFile
{
    version     2.0;
    format      ascii;
    class       dictionary;
    object      blockMeshDict;
}
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //

changecom(//)changequote([,])

define(calc, [esyscmd(perl -e 'printf ($1)')])

define(VCOUNT, 0)

define(vlabel, [[// ]Vertex $1 = VCOUNT define($1, VCOUNT)define([VCOUNT], incr(VCOUNT))])


define(hex2D, hex ($1b $2b $3b $4b $1t $2t $3t $4t))
define(hex2Dbb, hex ($1bb $2bb $3bb $4bb $1b $2b $3b $4b))
define(hex2Dtt, hex ($1t $2t $3t $4t $1tt $2tt $3tt $4tt))

define(quad4B, ($1b $2b $3b $4b))
define(quad4BB, ($1bb $2bb $3bb $4bb))
define(quad4T, ($1t $2t $3t $4t))
define(quad4TT, ($1tt $2tt $3tt $4tt))
define(quad2B2T, ($1b $2b $2t $1t))
define(quad2BB2B, ($1bb $2bb $2b $1b))
define(quad2TT2T, ($1t $2t $2tt $1tt))

define(Zb, 0.0)
define(Zt, 1.0)
define(Zbb, calc(Zb-.1))
define(Ztt, calc(Zt+.1))

define(nParam,2)


define(xL,calc(32*nParam))
define(xR,calc(8*nParam))

define(yB,calc(4*nParam))
define(yM,calc(15*nParam))
define(yT,calc(1*nParam))

define(zL,calc(80*nParam))
define(zF,calc(8*nParam))


convertToMeters 0.01;
vertices
(
    (0 0 Zb) vlabel(n0b)
    (0.4 0 Zb) vlabel(n1b)
    (0.5 0 Zb) vlabel(n2b)
    
    (0 0.05 Zb) vlabel(n3b)
    (0.4 0.05 Zb) vlabel(n4b)
    (0.5 0.05 Zb) vlabel(n5b)
    
    (0 .2375 Zb) vlabel(n6b)
    (0.4 .2375 Zb) vlabel(n7b)
    (0.5 .2375 Zb) vlabel(n8b)
    
    (0 .25 Zb) vlabel(n9b)
    (0.4 .25 Zb) vlabel(n10b)
    (0.5 .25 Zb) vlabel(n11b)
    
    (0 0 Zt) vlabel(n0t)
    (0.4 0 Zt) vlabel(n1t)
    (0.5 0 Zt) vlabel(n2t)
    
    (0 0.05 Zt) vlabel(n3t)
    (0.4 0.05 Zt) vlabel(n4t)
    (0.5 0.05 Zt) vlabel(n5t)
    
    (0 .2375 Zt) vlabel(n6t)
    (0.4 .2375 Zt) vlabel(n7t)
    (0.5 .2375 Zt) vlabel(n8t)
    
    (0 .25 Zt) vlabel(n9t)
    (0.4 .25 Zt) vlabel(n10t)
    (0.5 .25 Zt) vlabel(n11t)

    (0.4 0 Zbb) vlabel(n1bb)
    (0.5 0 Zbb) vlabel(n2bb)
    (0.4 0.05 Zbb) vlabel(n4bb)
    (0.5 0.05 Zbb) vlabel(n5bb)

    (0.4 0 Ztt) vlabel(n1tt)
    (0.5 0 Ztt) vlabel(n2tt)
    (0.4 0.05 Ztt) vlabel(n4tt)
    (0.5 0.05 Ztt) vlabel(n5tt)
);


// 9 10 11
// 6 7 8
// 3 4 5
// 0 1 2

blocks
(
    hex2Dbb(n1,n2,n5,n4)
    fluid_area
    (xR yB zF)
    simpleGrading (1 1 1)
    hex2Dtt(n1,n2,n5,n4)
    fluid_area
    (xR yB zF)
    simpleGrading (1 1 1)

    hex2D(n0,n1,n4,n3)
    (xL yB zL)
    simpleGrading (1 1 1)
    hex2D(n1,n2,n5,n4)
    (xR yB zL)
    simpleGrading (1 1 1)

    hex2D(n3,n4,n7,n6)
    (xL yM zL)
    simpleGrading (1 1 1)
    hex2D(n4,n5,n8,n7)
    (xR yM zL)
    simpleGrading (1 1 1)

    hex2D(n6,n7,n10,n9)
    solid_area
    (xL yT zL)
    simpleGrading (1 1 1)
    hex2D(n7,n8,n11,n10)
    solid_area
    (xR yT zL)
    simpleGrading (1 1 1)

);

edges
(
);

// 9 10 11
// 6 7 8
// 3 4 5
// 0 1 2

boundary
(
    outlet
    {
        type patch;
        faces
        (
            quad4BB(n1,n2,n5,n4)
        );
    }
    inlet
    {
        type patch;
        faces
        (
            quad4TT(n1,n2,n5,n4)
        );
    }
    force
    {
        type patch;
        faces
        (
            //top surface
            quad2B2T(n9,n10)
            quad2B2T(n10,n11)
        );    
    }
	wall
    {
        type patch;
        faces
        (
            //around inlet
            quad2BB2B(n1,n4)          		
            quad2BB2B(n4,n5)          		
            //around outlet
            quad2TT2T(n1,n4)          		
            quad2TT2T(n4,n5)          		
            //the chest on inlet
            quad4B(n0,n1,n4,n3)
            quad4B(n3,n4,n7,n6)
            quad4B(n4,n5,n8,n7)
            quad4B(n6,n7,n10,n9)
            quad4B(n7,n8,n11,n10)  
            //the chest on outlet
            quad4T(n0,n1,n4,n3)
            quad4T(n3,n4,n7,n6)
            quad4T(n4,n5,n8,n7)
            quad4T(n6,n7,n10,n9)
            quad4T(n7,n8,n11,n10) 	
            //left side
            quad2B2T(n0,n3)	
            quad2B2T(n3,n6)	
            quad2B2T(n6,n9)
        );
    }
    sym
    {
        type symmetry;
        faces
        (
            //right main body       
            quad2B2T(n2,n5)
            quad2B2T(n5,n8)
            quad2B2T(n8,n11)
            //right inlet       
            quad2BB2B(n2,n5)
            //right outlet       
            quad2TT2T(n2,n5)
            //bot main body       
            quad2B2T(n0,n1)
            quad2B2T(n1,n2)
            //bot inlet       
            quad2BB2B(n1,n2)
            //bot outlet
            quad2TT2T(n1,n2)
        );
    }
);
mergePatchPairs
(
);

// ************************************************************************* //

