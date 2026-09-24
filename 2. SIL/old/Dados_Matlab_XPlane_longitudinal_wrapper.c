
/*
 * Include Files
 *
 */
#if defined(MATLAB_MEX_FILE)
#include "tmwtypes.h"
#include "simstruc_types.h"
#else
#include "rtwtypes.h"
#endif



/* %%%-SFUNWIZ_wrapper_includes_Changes_BEGIN --- EDIT HERE TO _END */
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
/* %%%-SFUNWIZ_wrapper_includes_Changes_END --- EDIT HERE TO _BEGIN */
#define u_width 1
#define y_width 1

/*
 * Create external references here.  
 *
 */
/* %%%-SFUNWIZ_wrapper_externs_Changes_BEGIN --- EDIT HERE TO _END */
/* extern double func(double a); */
/* %%%-SFUNWIZ_wrapper_externs_Changes_END --- EDIT HERE TO _BEGIN */

/*
 * Output function
 *
 */
void Dados_Matlab_XPlane_longitudinal_Outputs_wrapper(const real32_T *Profundor,
			const real32_T *Aileron,
			const real32_T *Rudder,
			const real32_T *Throttle,
			uint8_T *Atuadores_Out,
			real_T *elevator_out,
			real_T *aileron_out,
			real_T *rudder_out,
			real_T *throttle_out)
{
/* %%%-SFUNWIZ_wrapper_Outputs_Changes_BEGIN --- EDIT HERE TO _END */
char a[16];
int i;
float prof,ail,rud,thr;

prof=Profundor[0];
ail= Aileron[0];
rud = Rudder[0];
thr = Throttle[0];

elevator_out[0] = prof;
aileron_out[0] = ail; 
rudder_out[0] = rud;
throttle_out[0]=thr;
 
 memcpy(&a[0],&prof,4);
 memcpy(&a[4],&ail,4);
 memcpy(&a[8],&rud,4);
 memcpy(&a[12],&thr,4);

//cabecalho
Atuadores_Out[0] = 68;
Atuadores_Out[1] = 65;
Atuadores_Out[2] = 84;
Atuadores_Out[3] = 65;
Atuadores_Out[4] = 48;//26;

//superficie de comando.
Atuadores_Out[5] = 8;
Atuadores_Out[6] = 0;
Atuadores_Out[7] = 0;
Atuadores_Out[8] = 0;

//DADO 1
for (i=9; i<13; i++)
  Atuadores_Out[i]=a[i-9];
  
//DADO 2
for (i=13; i<17; i++) 
    Atuadores_Out[i]=a[i-9];

//DADO 3
for (i=17; i<21; i++) 
    Atuadores_Out[i]=a[i-9];

//DEMAIS DADOS
for (i=21; i<41; i++)
   {
    Atuadores_Out[i]=0;
    Atuadores_Out[i]=192;
    Atuadores_Out[i]=121;
    Atuadores_Out[i]=196;
}


//Atualizando controle manual
Atuadores_Out[41] = 8;
Atuadores_Out[42] = 0;
Atuadores_Out[43] = 0;
Atuadores_Out[44] = 0;


for (i=0; i<8; i++)
{
    Atuadores_Out[45+4*i]=0;
    Atuadores_Out[46+4*i]=192;
    Atuadores_Out[47+4*i]=121;
    Atuadores_Out[48+4*i]=196;
}

//Throttle 

Atuadores_Out[77] = 25;
Atuadores_Out[78] = 0;
Atuadores_Out[79] = 0;
Atuadores_Out[80] = 0;

//Dado 1
for (i=81; i<85; i++)
    Atuadores_Out[i]=a[i-69];

//Dado 2
for (i=85; i<89; i++)
    Atuadores_Out[i]=a[i-73];

//Dado 3
for (i=89; i<93; i++)
    Atuadores_Out[i]=a[i-77];

//Dado 4
for (i=93; i<97; i++)
    Atuadores_Out[i]=a[i-81];

//DEMAIS DADOS
for (i=97; i<113; i++)
{
    Atuadores_Out[i]=0;
    Atuadores_Out[i]=192;
    Atuadores_Out[i]=121;
    Atuadores_Out[i]=196;
}
/* %%%-SFUNWIZ_wrapper_Outputs_Changes_END --- EDIT HERE TO _BEGIN */
}


