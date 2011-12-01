//
//  Model.h
//  OpenGLES2Test
//
//  Created by hx on 10/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>

#define PI 3.1415926
#define PI2 6.2831852
#define HALFPI 1.5707963
#define SUBDIVIDE 64

#define PARTNUM 5

typedef struct {
    float r;
    float g;
    float b;
    float a;
}Color;
typedef struct {
    float Position[3];
    float Color[4];
    float Normal[3];
    float TexCoord[2];
} Vertex;

Vertex pieVertices[(SUBDIVIDE+(PARTNUM-1)*4)*7+1+PARTNUM];
GLshort pieIndices[(SUBDIVIDE+(PARTNUM-1)*4)*27];
//Vertex pieVertices[SUBDIVIDE*3+1+PARTNUM];
//GLshort pieIndices[SUBDIVIDE*15];
float partValue[PARTNUM];
float partMarkedGreenValue[PARTNUM];
float partMarkedYellowValue[PARTNUM];

Vertex shadowVertices[4];
GLshort shadowIndices[6];

Color color[PARTNUM];

float lightDirection[3];


void buildShadow();
void buildModel();

void makeADivide(int trianglePoint,float ang ,float sinAng, float cosAng,int partId,int divideCount, int dividetype,int isMakeTriangle);

//Vertex pieVertices[(SUBDIVIDE+PARTNUM-1)*3+1+PARTNUM];
//GLshort pieIndices[(SUBDIVIDE+PARTNUM-1)*15];

