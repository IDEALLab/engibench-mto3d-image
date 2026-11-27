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
define(calcr, [esyscmd(perl -E '$_ = ($1);$_ = sprintf("%.0f", $_);print($_)')])

define(VCOUNT, 0)

define(vlabel, [[// ]Vertex $1 = VCOUNT define($1, VCOUNT)define([VCOUNT], incr(VCOUNT))])

define(cellSize,0.005)

define(x1,-.50)
define(x2,-.49)
define(x3,-.10)
define(x4,0.00)

define(y1,0.00)
define(y2,0.01)
define(y3,0.11)
define(y4,0.12)

define(z1,-0.15)
define(z2,0.000)
define(z3,0.200)
define(z4,0.300)
define(z5,0.500)
define(z6,0.650)

define(node, [(x$1 y$2 z$3) vlabel(n_$1_$2_$3)])
define(PP, n_$1_$2_$3)
define(planeZ_z_x12_y12, (PP($2,$4,$1) PP($3,$4,$1) PP($3,$5,$1) PP($2,$5,$1)))
define(planeY_y_x12_z12, (PP($2,$1,$4) PP($3,$1,$4) PP($3,$1,$5) PP($2,$1,$5)))
define(planeX_x_y12_z12, (PP($1,$2,$4) PP($1,$3,$4) PP($1,$3,$5) PP($1,$2,$5)))
define(hex_X_Y_Z, [hex (PP($1,$3,$5) PP($2,$3,$5) PP($2,$4,$5) PP($1,$4,$5) PP($1,$3,$6) PP($2,$3,$6) PP($2,$4,$6) PP($1,$4,$6)) $7 (calcr(abs((x$2)-(x$1))/cellSize) calcr(abs((y$4)-(y$3))/cellSize) calcr(abs((z$6)-(z$5))/cellSize)) simpleGrading (1 1 1)])



convertToMeters 0.01;
vertices
(
    //Z1
    node(3,2,1)
    node(4,2,1)
    node(3,3,1)
    node(4,3,1)

    //Z2
    node(1,1,2)
    node(2,1,2)
    node(3,1,2)
    node(4,1,2)
    node(1,2,2)
    node(2,2,2)
    node(3,2,2)
    node(4,2,2)    
    node(1,3,2)
    node(2,3,2)
    node(3,3,2)
    node(4,3,2)
    node(1,4,2)
    node(2,4,2)
    node(3,4,2)
    node(4,4,2)

    //Z3
    node(1,1,3)
    node(2,1,3)
    node(3,1,3)
    node(4,1,3)
    node(1,2,3)
    node(2,2,3)
    node(3,2,3)
    node(4,2,3)    
    node(1,3,3)
    node(2,3,3)
    node(3,3,3)
    node(4,3,3)
    node(1,4,3)
    node(2,4,3)
    node(3,4,3)
    node(4,4,3)

    //Z4
    node(1,1,4)
    node(2,1,4)
    node(3,1,4)
    node(4,1,4)
    node(1,2,4)
    node(2,2,4)
    node(3,2,4)
    node(4,2,4)    
    node(1,3,4)
    node(2,3,4)
    node(3,3,4)
    node(4,3,4)
    node(1,4,4)
    node(2,4,4)
    node(3,4,4)
    node(4,4,4)


    //Z5
    node(1,1,5)
    node(2,1,5)
    node(3,1,5)
    node(4,1,5)
    node(1,2,5)
    node(2,2,5)
    node(3,2,5)
    node(4,2,5)    
    node(1,3,5)
    node(2,3,5)
    node(3,3,5)
    node(4,3,5)
    node(1,4,5)
    node(2,4,5)
    node(3,4,5)
    node(4,4,5)

    //Z6
    node(3,2,6)
    node(4,2,6)
    node(3,3,6)
    node(4,3,6)
);  

blocks
(
    //Outlet
    hex_X_Y_Z(3,4,2,3,1,2,fluid_area)
    //Main Body #1
    hex_X_Y_Z(1,2,1,2,2,3,solid_area)
    hex_X_Y_Z(2,3,1,2,2,3,solid_area)
    hex_X_Y_Z(3,4,1,2,2,3,solid_area)
    hex_X_Y_Z(1,2,2,3,2,3,)
    hex_X_Y_Z(2,3,2,3,2,3,)
    hex_X_Y_Z(3,4,2,3,2,3,)
    hex_X_Y_Z(1,2,3,4,2,3,solid_area)
    hex_X_Y_Z(2,3,3,4,2,3,solid_area)
    hex_X_Y_Z(3,4,3,4,2,3,solid_area)
    //Main Body #2
    hex_X_Y_Z(1,2,1,2,3,4,solid_area)
    hex_X_Y_Z(2,3,1,2,3,4,solid_area)
    hex_X_Y_Z(3,4,1,2,3,4,solid_area)
    hex_X_Y_Z(1,2,2,3,3,4,)
    hex_X_Y_Z(2,3,2,3,3,4,)
    hex_X_Y_Z(3,4,2,3,3,4,)
    hex_X_Y_Z(1,2,3,4,3,4,solid_area)
    hex_X_Y_Z(2,3,3,4,3,4,solid_area)
    hex_X_Y_Z(3,4,3,4,3,4,solid_area)
    //Main Body #3
    hex_X_Y_Z(1,2,1,2,4,5,solid_area)
    hex_X_Y_Z(2,3,1,2,4,5,solid_area)
    hex_X_Y_Z(3,4,1,2,4,5,solid_area)
    hex_X_Y_Z(1,2,2,3,4,5,)
    hex_X_Y_Z(2,3,2,3,4,5,)
    hex_X_Y_Z(3,4,2,3,4,5,)
    hex_X_Y_Z(1,2,3,4,4,5,solid_area)
    hex_X_Y_Z(2,3,3,4,4,5,solid_area)
    hex_X_Y_Z(3,4,3,4,4,5,solid_area)
    //Inlet
    hex_X_Y_Z(3,4,2,3,5,6,fluid_area)
);

edges
(
);


boundary
(
    outlet
    {
        type patch;
        faces
        (
            planeZ_z_x12_y12(1,3,4,2,3) //top
        );
    }
    inlet
    {
        type patch;
        faces
        (
            planeZ_z_x12_y12(6,3,4,2,3) //top
        );
    }
    force
    {
        type patch;
        faces
        (
            //Body 1
            planeY_y_x12_z12(4,1,2,2,3)
            planeY_y_x12_z12(4,2,3,2,3)
            planeY_y_x12_z12(4,3,4,2,3)
            //Body 2
            planeY_y_x12_z12(4,1,2,3,4)
            planeY_y_x12_z12(4,2,3,3,4)
            planeY_y_x12_z12(4,3,4,3,4)
            //Body 3
            planeY_y_x12_z12(4,1,2,4,5)
            planeY_y_x12_z12(4,2,3,4,5)
            planeY_y_x12_z12(4,3,4,4,5)
            
        );    
    }
	wall
    {
        type patch;
        faces
        (
            //around inlet
            planeY_y_x12_z12(3,3,4,5,6) //t
            planeX_x_y12_z12(3,2,3,5,6) //l
            planeY_y_x12_z12(2,3,4,5,6) //b
            //around outlet
            planeY_y_x12_z12(3,3,4,1,2) //t
            planeX_x_y12_z12(3,2,3,1,2) //l
            planeY_y_x12_z12(2,3,4,1,2) //b
            //left
            planeX_x_y12_z12(1,1,2,2,3) //11
            planeX_x_y12_z12(1,2,3,2,3) //12
            planeX_x_y12_z12(1,3,4,2,3) //13
            planeX_x_y12_z12(1,1,2,3,4) //21
            planeX_x_y12_z12(1,2,3,3,4) //22
            planeX_x_y12_z12(1,3,4,3,4) //23
            planeX_x_y12_z12(1,1,2,4,5) //31
            planeX_x_y12_z12(1,2,3,4,5) //32
            planeX_x_y12_z12(1,3,4,4,5) //33
            //chest inlet
            planeZ_z_x12_y12(5,1,2,1,2)
            planeZ_z_x12_y12(5,2,3,1,2)
            planeZ_z_x12_y12(5,3,4,1,2)
            planeZ_z_x12_y12(5,1,2,2,3)
            planeZ_z_x12_y12(5,2,3,2,3)
            planeZ_z_x12_y12(5,1,2,3,4)
            planeZ_z_x12_y12(5,2,3,3,4)
            planeZ_z_x12_y12(5,3,4,3,4)
            //chest outlet
            planeZ_z_x12_y12(2,1,2,1,2)
            planeZ_z_x12_y12(2,2,3,1,2)
            planeZ_z_x12_y12(2,3,4,1,2)
            planeZ_z_x12_y12(2,1,2,2,3)
            planeZ_z_x12_y12(2,2,3,2,3)
            planeZ_z_x12_y12(2,1,2,3,4)
            planeZ_z_x12_y12(2,2,3,3,4)
            planeZ_z_x12_y12(2,3,4,3,4)
        );
    }
    sym
    {
        type symmetry;
        faces
        (
            //right body 1
            planeX_x_y12_z12(4,1,2,2,3)
            planeX_x_y12_z12(4,2,3,2,3)
            planeX_x_y12_z12(4,3,4,2,3)
            //right body 2
            planeX_x_y12_z12(4,1,2,3,4)
            planeX_x_y12_z12(4,2,3,3,4)
            planeX_x_y12_z12(4,3,4,3,4)
            //right body 3
            planeX_x_y12_z12(4,1,2,4,5)
            planeX_x_y12_z12(4,2,3,4,5)
            planeX_x_y12_z12(4,3,4,4,5)
            //right inlet
            planeX_x_y12_z12(4,2,3,5,6)
            //right outlet
            planeX_x_y12_z12(4,2,3,1,2)
        );
    }
    bot
    {
        type patch;
        faces
        (
            //bot surface 1
            planeY_y_x12_z12(1,1,2,2,3)
            planeY_y_x12_z12(1,2,3,2,3)
            planeY_y_x12_z12(1,3,4,2,3)
            //bot surface 2
            planeY_y_x12_z12(1,1,2,3,4)
            planeY_y_x12_z12(1,2,3,3,4)
            planeY_y_x12_z12(1,3,4,3,4)
            //bot surface 3
            planeY_y_x12_z12(1,1,2,4,5)
            planeY_y_x12_z12(1,2,3,4,5)
            planeY_y_x12_z12(1,3,4,4,5)
        );
    }
);
mergePatchPairs
(
);

// ************************************************************************* //

