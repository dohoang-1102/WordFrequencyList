//
//  ModelBuilder.c
//  OpenGLES2Test
//
//  Created by hx on 10/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#include <stdio.h>
#include<stdlib.h>
#include <math.h>
#include "ModelBuilder.h"

int divideCountInPart;
int divideCompletePart;
void buildModel(){
    lightDirection[0]   = -2;
    lightDirection[1]   = 2;
    lightDirection[2]   = 4.5;
    
    buildShadow();
    
    color[0].r  = 1;
    color[0].g  = .2;
    color[0].b  = .1;
    color[0].a  = 1;
    
    color[1].r  = 1;
    color[1].g  = .38;
    color[1].b  = .1;
    color[1].a  = 1;
    
    color[2].r  = 1;
    color[2].g  = .56;
    color[2].b  = .1;
    color[2].a  = 1;
    
    color[3].r  = 1;
    color[3].g  = .72;
    color[3].b  = .1;
    color[3].a  = 1;
    
    color[4].r  = 1;
    color[4].g  = .9;
    color[4].b  = .1;
    color[4].a  = 1;
    


    for (int i=0; i<PARTNUM; i++) {
        pieVertices[i].Position[0]     = 0;
        pieVertices[i].Position[1]     = 0.6;
        pieVertices[i].Position[2]     = 0;
        pieVertices[i].Color[0]        = color[i].r*.2;
        pieVertices[i].Color[1]        = powf(color[i].g,.4)+.2;
        pieVertices[i].Color[2]        = color[i].b;
        pieVertices[i].Color[3]        = color[i].a;
        pieVertices[i].Normal[0]       = 0.0;
        pieVertices[i].Normal[1]       = 1.0;
        pieVertices[i].Normal[2]       = 0.0;
        
    }
    
    
    float thisDivideValue   = 0;
    float partEndValue      = 0;
    float partStartValue    = 0;
    
    float divideStep        = 1.0 / SUBDIVIDE;
    float breakStep         = .005f;
    
    int divideCount         = 0;
    
    
    for (int i=0; i<PARTNUM; i++) {
        divideCompletePart  = (float)rand()/RAND_MAX*40;
        partStartValue      = partEndValue;
        partEndValue        += partValue[i];

        thisDivideValue     = partStartValue;
        
        int isEndDivideBuild    = 0;
        divideCountInPart   = 0;
        while (thisDivideValue<partEndValue) {
            
            float ang           = PI2*thisDivideValue;
            float sinAng        = sinf(ang);
            float cosAng        = -cosf(ang);
            
            int trianglePoint   = divideCount*7+PARTNUM;
            if(partStartValue==thisDivideValue){
                makeADivide(trianglePoint,ang,sinAng,cosAng,i,divideCount,1,1);
                divideCount ++;
                trianglePoint   = divideCount*7+PARTNUM;
                thisDivideValue += breakStep;
                ang             = PI2*thisDivideValue;
                sinAng          = sinf(ang);
                cosAng          = -cosf(ang);
                makeADivide(trianglePoint,ang,sinAng,cosAng,i,divideCount,0,1);
            }else{
                makeADivide(trianglePoint,ang,sinAng,cosAng,i,divideCount,0,1);
            }
            
            
            divideCount ++;
            if(isEndDivideBuild==1 || thisDivideValue+divideStep<partEndValue-breakStep){
                thisDivideValue += divideStep;
            }else{
                isEndDivideBuild = 1;
                thisDivideValue  = partEndValue-breakStep;
            }
        }
        float ang           = PI2*partEndValue;
        float sinAng        = sinf(ang);
        float cosAng        = -cosf(ang);
        int trianglePoint   = divideCount*7+PARTNUM;
        makeADivide(trianglePoint,ang,sinAng,cosAng,i,divideCount,-1,0);
        divideCount ++;
    }
    
    
    /*for (int i=0; i<SUBDIVIDE; i++) {
        int partId         = floorf((float)i/SUBDIVIDE*PARTNUM);
        int trianglePoint  = i*3+PARTNUM;
        float ang           = PI2*(float)i/SUBDIVIDE;
        float sinAng        = sinf(ang);
        float cosAng        = cosf(ang);
        
        makeAVertice(trianglePoint,sinAng,cosAng,partId);
        if(i<SUBDIVIDE-1){
            int id  =i*15;
            
            pieIndices[id]     =  partId;
            
            pieIndices[id+1]   = trianglePoint;
            pieIndices[id+2]   = trianglePoint+3;
            
            pieIndices[id+3]   = trianglePoint;
            pieIndices[id+4]   = trianglePoint+1;
            pieIndices[id+5]   = trianglePoint+3;
            
            pieIndices[id+6]   = trianglePoint+3;
            pieIndices[id+7]   = trianglePoint+1;
            pieIndices[id+8]   = trianglePoint+4;
            
            pieIndices[id+9]   = trianglePoint+1;
            pieIndices[id+10]  = trianglePoint+2;
            pieIndices[id+11]  = trianglePoint+4;
            
            pieIndices[id+12]  = trianglePoint+4;
            pieIndices[id+13]  = trianglePoint+2;
            pieIndices[id+14]  = trianglePoint+5;
        }else{
            int id  =i*15;
            pieIndices[id]     = partId;
            pieIndices[id+1]   = trianglePoint;
            pieIndices[id+2]   = PARTNUM;
            
            pieIndices[id+3]   = trianglePoint;
            pieIndices[id+4]   = trianglePoint+1;
            pieIndices[id+5]   = PARTNUM;
            
            pieIndices[id+6]   = PARTNUM;
            pieIndices[id+7]   = trianglePoint+1;
            pieIndices[id+8]   = 1+PARTNUM;
            
            pieIndices[id+9]   = trianglePoint+1;
            pieIndices[id+10]  = trianglePoint+2;
            pieIndices[id+11]  = 1+PARTNUM;
            
            pieIndices[id+12]  = 1+PARTNUM;
            pieIndices[id+13]  = trianglePoint+2;
            pieIndices[id+14]  = 2+PARTNUM;
        }
    }*/

}

void makeADivide(int trianglePoint,float ang,float sinAng, float cosAng,int partId,int divideCount, int dividetype,int isMakeTriangle){
    float r;
    float h;
    
    
    
    if(dividetype==0){
        h   = 0.6;
        r   = 2.1;
        
    }else{
        h   = 0.55;
        r   = 2.08;

    }
    
    Color rndColor;
    rndColor.r  = color[partId].r;
    rndColor.g  = color[partId].g;
    rndColor.b  = color[partId].b;
    rndColor.a  = color[partId].a;
    
    pieVertices[trianglePoint].Position[0]     = sinAng*r*partMarkedGreenValue[partId];
    pieVertices[trianglePoint].Position[1]     = h;
    pieVertices[trianglePoint].Position[2]     = cosAng*r*partMarkedGreenValue[partId];
    
    pieVertices[trianglePoint].Color[0]        = rndColor.r*.2;
    pieVertices[trianglePoint].Color[1]        = powf(rndColor.g,.4)+.2;
    pieVertices[trianglePoint].Color[2]        = rndColor.b;
    pieVertices[trianglePoint].Color[3]        = rndColor.a;
    if(dividetype==0){
        pieVertices[trianglePoint].Normal[0]       = 0.0;
        pieVertices[trianglePoint].Normal[1]       = 1.0;
        pieVertices[trianglePoint].Normal[2]       = 0.0;
    }else{
        pieVertices[trianglePoint].Normal[0]       = sinAng;
        pieVertices[trianglePoint].Normal[1]       = 1.0;
        pieVertices[trianglePoint].Normal[2]       = cosAng;
    }
    pieVertices[trianglePoint].TexCoord[0]     = sinAng;
    pieVertices[trianglePoint].TexCoord[1]     = cosAng;
    
    
    trianglePoint+=1;
    
    
    pieVertices[trianglePoint].Position[0]     = sinAng*r*partMarkedGreenValue[partId];
    pieVertices[trianglePoint].Position[1]     = h;
    pieVertices[trianglePoint].Position[2]     = cosAng*r*partMarkedGreenValue[partId];
    
    pieVertices[trianglePoint].Color[0]        = rndColor.r*.7;
    pieVertices[trianglePoint].Color[1]        = powf(rndColor.g,.5)+.1;
    pieVertices[trianglePoint].Color[2]        = rndColor.b;
    pieVertices[trianglePoint].Color[3]        = rndColor.a;
    if(dividetype==0){
        pieVertices[trianglePoint].Normal[0]       = 0.0;
        pieVertices[trianglePoint].Normal[1]       = 1.0;
        pieVertices[trianglePoint].Normal[2]       = 0.0;
    }else{
        pieVertices[trianglePoint].Normal[0]       = sinAng;
        pieVertices[trianglePoint].Normal[1]       = 1.0;
        pieVertices[trianglePoint].Normal[2]       = cosAng;
    }
    pieVertices[trianglePoint].TexCoord[0]     = sinAng;
    pieVertices[trianglePoint].TexCoord[1]     = cosAng;
    
    
    trianglePoint+=1;
    
    pieVertices[trianglePoint].Position[0]     = sinAng*r*(partMarkedGreenValue[partId]+partMarkedYellowValue[partId]);
    pieVertices[trianglePoint].Position[1]     = h;
    pieVertices[trianglePoint].Position[2]     = cosAng*r*(partMarkedGreenValue[partId]+partMarkedYellowValue[partId]);
    
    pieVertices[trianglePoint].Color[0]        = rndColor.r*.7;
    pieVertices[trianglePoint].Color[1]        = powf(rndColor.g,.5)+.1;
    pieVertices[trianglePoint].Color[2]        = rndColor.b;
    pieVertices[trianglePoint].Color[3]        = rndColor.a;
    if(dividetype==0){
        pieVertices[trianglePoint].Normal[0]       = 0.0;
        pieVertices[trianglePoint].Normal[1]       = 1.0;
        pieVertices[trianglePoint].Normal[2]       = 0.0;
    }else{
        pieVertices[trianglePoint].Normal[0]       = sinAng;
        pieVertices[trianglePoint].Normal[1]       = 1.0;
        pieVertices[trianglePoint].Normal[2]       = cosAng;
    }
    pieVertices[trianglePoint].TexCoord[0]     = sinAng;
    pieVertices[trianglePoint].TexCoord[1]     = cosAng;
    
    
    trianglePoint+=1;
    
    pieVertices[trianglePoint].Position[0]     = sinAng*r*(partMarkedGreenValue[partId]+partMarkedYellowValue[partId]);
    pieVertices[trianglePoint].Position[1]     = h;
    pieVertices[trianglePoint].Position[2]     = cosAng*r*(partMarkedGreenValue[partId]+partMarkedYellowValue[partId]);
    
    pieVertices[trianglePoint].Color[0]        = rndColor.r;
    pieVertices[trianglePoint].Color[1]        = rndColor.g;
    pieVertices[trianglePoint].Color[2]        = rndColor.b;
    pieVertices[trianglePoint].Color[3]        = rndColor.a;
    if(dividetype==0){
        pieVertices[trianglePoint].Normal[0]       = 0.0;
        pieVertices[trianglePoint].Normal[1]       = 1.0;
        pieVertices[trianglePoint].Normal[2]       = 0.0;
    }else{
        pieVertices[trianglePoint].Normal[0]       = sinAng;
        pieVertices[trianglePoint].Normal[1]       = 1.0;
        pieVertices[trianglePoint].Normal[2]       = cosAng;
    }
    pieVertices[trianglePoint].TexCoord[0]     = sinAng;
    pieVertices[trianglePoint].TexCoord[1]     = cosAng;
    
    
    trianglePoint+=1;
    
    pieVertices[trianglePoint].Position[0]     = sinAng*r;
    pieVertices[trianglePoint].Position[1]     = h;
    pieVertices[trianglePoint].Position[2]     = cosAng*r;
    
    pieVertices[trianglePoint].Color[0]        = rndColor.r;
    pieVertices[trianglePoint].Color[1]        = rndColor.g;
    pieVertices[trianglePoint].Color[2]        = rndColor.b;
    pieVertices[trianglePoint].Color[3]        = rndColor.a;
    if(dividetype==0){
        pieVertices[trianglePoint].Normal[0]       = 0.0;
        pieVertices[trianglePoint].Normal[1]       = 1.0;
        pieVertices[trianglePoint].Normal[2]       = 0.0;
    }else{
        pieVertices[trianglePoint].Normal[0]       = sinAng;
        pieVertices[trianglePoint].Normal[1]       = 1.0;
        pieVertices[trianglePoint].Normal[2]       = cosAng;
    }
    pieVertices[trianglePoint].TexCoord[0]     = sinAng;
    pieVertices[trianglePoint].TexCoord[1]     = cosAng;
    
    
    if(dividetype==0){
        h   = 0.6;
        r   = 2.2;
    }else{
        h   = 0.55;
        r   = 2.18;
    }
    
    trianglePoint+=1;
    
    rndColor.r+=.2;
    rndColor.g+=.2;
    pieVertices[trianglePoint].Position[0]     = sinAng*r;
    pieVertices[trianglePoint].Position[1]     = h;
    pieVertices[trianglePoint].Position[2]     = cosAng*r;
    
    pieVertices[trianglePoint].Color[0]        = rndColor.r;
    pieVertices[trianglePoint].Color[1]        = rndColor.g;
    pieVertices[trianglePoint].Color[2]        = rndColor.b;
    pieVertices[trianglePoint].Color[3]        = rndColor.a;
    if(dividetype==0){
        pieVertices[trianglePoint].Normal[0]       = sinAng;
        pieVertices[trianglePoint].Normal[1]       = 0;
        pieVertices[trianglePoint].Normal[2]       = cosAng;
    }else if(dividetype==-1){
        pieVertices[trianglePoint].Normal[0]       = sin(ang+PI/12);
        pieVertices[trianglePoint].Normal[1]       = 0;
        pieVertices[trianglePoint].Normal[2]       = -cos(ang+PI/12);
    }else if(dividetype==1){
        pieVertices[trianglePoint].Normal[0]       = sin(ang-PI/12);
        pieVertices[trianglePoint].Normal[1]       = 0;
        pieVertices[trianglePoint].Normal[2]       = -cos(ang-PI/12);
        
    }    pieVertices[trianglePoint].TexCoord[0]     = sinAng;
    pieVertices[trianglePoint].TexCoord[1]     = cosAng;
    
    
        //rndColor.r  += .2;
        //rndColor.g  += .2;
    
    trianglePoint+=1;
    pieVertices[trianglePoint].Position[0]     = sinAng*r;
    pieVertices[trianglePoint].Position[1]     = 0;
    pieVertices[trianglePoint].Position[2]     = cosAng*r;
    pieVertices[trianglePoint].Color[0]        = rndColor.r;
    pieVertices[trianglePoint].Color[1]        = rndColor.g;
    pieVertices[trianglePoint].Color[2]        = rndColor.b;
    pieVertices[trianglePoint].Color[3]        = rndColor.a;
    if(dividetype==0){
        pieVertices[trianglePoint].Normal[0]       = sinAng;
        pieVertices[trianglePoint].Normal[1]       = 0;
        pieVertices[trianglePoint].Normal[2]       = cosAng;
    }else if(dividetype==-1){
        pieVertices[trianglePoint].Normal[0]       = sin(ang+PI/12);
        pieVertices[trianglePoint].Normal[1]       = 0;
        pieVertices[trianglePoint].Normal[2]       = -cos(ang+PI/12);
    }else if(dividetype==1){
        pieVertices[trianglePoint].Normal[0]       = sin(ang-PI/12);
        pieVertices[trianglePoint].Normal[1]       = 0;
        pieVertices[trianglePoint].Normal[2]       = -cos(ang-PI/12);
    }
    

    pieVertices[trianglePoint].TexCoord[0]     = sinAng;
    pieVertices[trianglePoint].TexCoord[1]     = cosAng;
    
    if(isMakeTriangle){
        trianglePoint-=6;
    int id  =divideCount*27;
    
    pieIndices[id]     = partId;
    pieIndices[id+1]   = trianglePoint;
    pieIndices[id+2]   = trianglePoint+7;
    
    pieIndices[id+3]   = trianglePoint+1;
    pieIndices[id+4]   = trianglePoint+2;
    pieIndices[id+5]   = trianglePoint+9;
    
    pieIndices[id+6]   = trianglePoint+1;
    pieIndices[id+7]   = trianglePoint+9;
    pieIndices[id+8]   = trianglePoint+8;
    
    pieIndices[id+9]   = trianglePoint+3;
    pieIndices[id+10]  = trianglePoint+4;
    pieIndices[id+11]  = trianglePoint+11;
    
    pieIndices[id+12]  = trianglePoint+3;
    pieIndices[id+13]  = trianglePoint+10;
    pieIndices[id+14]  = trianglePoint+11;
        
    pieIndices[id+15]  = trianglePoint+4;
    pieIndices[id+16]  = trianglePoint+5;
    pieIndices[id+17]  = trianglePoint+12;
        
    pieIndices[id+18]  = trianglePoint+4;
    pieIndices[id+19]  = trianglePoint+12;
    pieIndices[id+20]  = trianglePoint+11;
        
    pieIndices[id+21]  = trianglePoint+5;
    pieIndices[id+22]  = trianglePoint+6;
    pieIndices[id+23]  = trianglePoint+13;
        
    pieIndices[id+24]  = trianglePoint+5;
    pieIndices[id+25]  = trianglePoint+13;
    pieIndices[id+26]  = trianglePoint+12;
    }
    divideCountInPart++;
}



void buildShadow(){
    shadowVertices[0].Position[0]   = -3.3;
    shadowVertices[0].Position[1]   = 0;
    shadowVertices[0].Position[2]   = -3.3;
    shadowVertices[0].Normal[0]     = 0.0;
    shadowVertices[0].Normal[1]     = 1.0;
    shadowVertices[0].Normal[2]     = 0.0;
    shadowVertices[0].TexCoord[0]   = 0;
    shadowVertices[0].TexCoord[1]   = 0;
    
    shadowVertices[1].Position[0]   = 3.3;
    shadowVertices[1].Position[1]   = 0;
    shadowVertices[1].Position[2]   = -3.3;
    shadowVertices[1].Normal[0]     = 0.0;
    shadowVertices[1].Normal[1]     = 1.0;
    shadowVertices[1].Normal[2]     = 0.0;
    shadowVertices[1].TexCoord[0]   = 1;
    shadowVertices[1].TexCoord[1]   = 0;
    
    shadowVertices[2].Position[0]   = 3.3;
    shadowVertices[2].Position[1]   = 0;
    shadowVertices[2].Position[2]   = 3.3;
    shadowVertices[2].Normal[0]     = 0.0;
    shadowVertices[2].Normal[1]     = 1.0;
    shadowVertices[2].Normal[2]     = 0.0;
    shadowVertices[2].TexCoord[0]   = 1;
    shadowVertices[2].TexCoord[1]   = 1;
    
    shadowVertices[3].Position[0]   = -3.3;
    shadowVertices[3].Position[1]   = 0;
    shadowVertices[3].Position[2]   = 3.3;
    shadowVertices[3].Normal[0]     = 0.0;
    shadowVertices[3].Normal[1]     = 1.0;
    shadowVertices[3].Normal[2]     = 0.0;
    shadowVertices[3].TexCoord[0]   = 0;
    shadowVertices[3].TexCoord[1]   = 1;
    
    shadowIndices[0]    = 0;
    shadowIndices[1]    = 1;
    shadowIndices[2]    = 2;
    shadowIndices[3]    = 0;
    shadowIndices[4]    = 2;
    shadowIndices[5]    = 3;
}
