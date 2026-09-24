
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
void Dados_XPlane_Matlab_Outputs_wrapper(const uint8_T *Dados_in,
			real_T *Vind_kias,
			real_T *Vind_keas,
			real_T *Vtrue_ktas,
			real_T *Vtrue_ktgs,
			real_T *Vind_mph,
			real_T *Vtrue_mphas,
			real_T *Vtrue_mphgs,
			real_T *Mach,
			real_T *VVI,
			real_T *Elevator,
			real_T *Aileron,
			real_T *Rudder,
			real_T *Q,
			real_T *P,
			real_T *R,
			real_T *Pitch,
			real_T *Roll,
			real_T *Heading_true,
			real_T *Heading_mag,
			real_T *AoA,
			real_T *Sideslip,
			real_T *Latitude,
			real_T *Longitude,
			real_T *Altitude,
			real_T *X,
			real_T *Y,
			real_T *Z,
			real_T *Vu,
			real_T *Vv,
			real_T *Vw,
			real_T *Throtle_com,
			real_T *Throtle_sen)
{
/* %%%-SFUNWIZ_wrapper_Outputs_Changes_BEGIN --- EDIT HERE TO _END */


unsigned char vkias[4], vkeas[4], vktas[4], vktgs[4], vimph[4], vtmphas[4], vtmphgs[4],
    mach[4], vvi[4],
    elev[4], ailer[4], ruddr[4], 
    q[4], p[4], r[4],
    pit[4], rll[4], yaw_true[4], yaw_mag[4],
    aoa[4], sideslip[4],
    lat[4], longi[4], alti[4],
     x[4], y[4], z[4],
    vu[4], vv[4], vw[4],
    throtle_c[4], throtle_s[4];
float vkias_1, vkeas_1, vktas_1, vktgs_1, vimph_1, vtmphas_1, vtmphgs_1, 
    mach_1, vvi_1,
    elev_1, ailer_1, ruddr_1, 
    q_1, p_1, r_1,
    pitch_1, roll_1, hding_true, hding_mag,
    aoa_1, sideslip_1,
    lat_1, longi_1, alti_1,
    x_1, y_1, z_1,
    vu_1, vv_1, vw_1,
    throtle_c_1, throtle_s_1;
    
vkias[0]=Dados_in[9];
vkias[1]=Dados_in[10];
vkias[2]=Dados_in[11];
vkias[3]=Dados_in[12];  
    
vkeas[0]=Dados_in[13];
vkeas[1]=Dados_in[14];
vkeas[2]=Dados_in[15];
vkeas[3]=Dados_in[16];   
    
vktas[0]=Dados_in[17];
vktas[1]=Dados_in[18];
vktas[2]=Dados_in[19];
vktas[3]=Dados_in[20];         

vktgs[0]=Dados_in[21];
vktgs[1]=Dados_in[22];
vktgs[2]=Dados_in[23];
vktgs[3]=Dados_in[24];        
    
vimph[0]=Dados_in[29];
vimph[1]=Dados_in[30];
vimph[2]=Dados_in[31];
vimph[3]=Dados_in[32];    
    
vtmphas[0]=Dados_in[33];
vtmphas[1]=Dados_in[34];
vtmphas[2]=Dados_in[35];
vtmphas[3]=Dados_in[36];   
    
vtmphgs[0]=Dados_in[37];
vtmphgs[1]=Dados_in[38];
vtmphgs[2]=Dados_in[39];
vtmphgs[3]=Dados_in[40];
    
mach[0]=Dados_in[45];
mach[1]=Dados_in[46];
mach[2]=Dados_in[47];
mach[3]=Dados_in[48];
    
vvi[0]=Dados_in[53];
vvi[1]=Dados_in[54];
vvi[2]=Dados_in[55];
vvi[3]=Dados_in[56];            
        
elev[0]=Dados_in[81];
elev[1]=Dados_in[82];
elev[2]=Dados_in[83];
elev[3]=Dados_in[84];
ailer[0]=Dados_in[85];
ailer[1]=Dados_in[86];
ailer[2]=Dados_in[87];
ailer[3]=Dados_in[88];
ruddr[0]=Dados_in[89];
ruddr[1]=Dados_in[90];
ruddr[2]=Dados_in[91];
ruddr[3]=Dados_in[92];

q[0]=Dados_in[117];
q[1]=Dados_in[118];
q[2]=Dados_in[119];
q[3]=Dados_in[120];
    
p[0]=Dados_in[121];
p[1]=Dados_in[122];
p[2]=Dados_in[123];
p[3]=Dados_in[124];        

r[0]=Dados_in[125];
r[1]=Dados_in[126];
r[2]=Dados_in[127];
r[3]=Dados_in[128];    
        
    
memcpy(&vkias_1,&vkias[0],4);
Vind_kias[0] = (double)vkias_1;
memcpy(&vkeas_1,&vkeas[0],4);
Vind_keas[0] = (double)vkeas_1;      
memcpy(&vktas_1,&vktas[0],4);
Vtrue_ktas[0] = (double)vktas_1;      
memcpy(&vktgs_1,&vktgs[0],4);
Vtrue_ktgs[0] = (double)vktgs_1;  
memcpy(&vimph_1,&vimph[0],4);
Vind_mph[0] = (double)vimph_1;             
memcpy(&vtmphas_1,&vtmphas[0],4);
Vtrue_mphas[0] = (double)vtmphas_1;    
memcpy(&vtmphgs_1,&vtmphgs[0],4);
Vtrue_mphgs[0] = (double)vtmphgs_1;
memcpy(&mach_1,&mach[0],4);
Mach[0] = (double)mach_1;
memcpy(&vvi_1,&vvi[0],4);
VVI[0] = (double)vvi_1;     
               
memcpy(&elev_1,&elev[0],4);
Elevator[0] = (double)elev_1;
memcpy(&ailer_1,&ailer[0],4);
Aileron[0] = (double)ailer_1;
memcpy(&ruddr_1,&ruddr[0],4);
Rudder[0] = (double)ruddr_1;
    
memcpy(&q_1,&q[0],4);
Q[0] = (double)q_1;
memcpy(&p_1,&p[0],4);
P[0] = (double)p_1;             
memcpy(&r_1,&r[0],4);
R[0] = (double)r_1;
        
pit[0]=Dados_in[153];
pit[1]=Dados_in[154];
pit[2]=Dados_in[155];
pit[3]=Dados_in[156];
rll[0]=Dados_in[157];
rll[1]=Dados_in[158];
rll[2]=Dados_in[159];
rll[3]=Dados_in[160];
yaw_true[0]=Dados_in[161];
yaw_true[1]=Dados_in[162];
yaw_true[2]=Dados_in[163];
yaw_true[3]=Dados_in[164];
yaw_mag[0]=Dados_in[165];
yaw_mag[1]=Dados_in[166];
yaw_mag[2]=Dados_in[167];
yaw_mag[3]=Dados_in[168];
    
aoa[0]=Dados_in[189];
aoa[1]=Dados_in[190];
aoa[2]=Dados_in[191];
aoa[3]=Dados_in[192];    

sideslip[0]=Dados_in[193];
sideslip[1]=Dados_in[194];
sideslip[2]=Dados_in[195];
sideslip[3]=Dados_in[196];       

lat[0]=Dados_in[225];
lat[1]=Dados_in[226];
lat[2]=Dados_in[227];
lat[3]=Dados_in[228];  
    
longi[0]=Dados_in[229];
longi[1]=Dados_in[230];
longi[2]=Dados_in[231];
longi[3]=Dados_in[232];    
    
alti[0]=Dados_in[233];
alti[1]=Dados_in[234];
alti[2]=Dados_in[235];
alti[3]=Dados_in[236];    
    
x[0]=Dados_in[261];
x[1]=Dados_in[262];
x[2]=Dados_in[263];
x[3]=Dados_in[264];   

y[0]=Dados_in[265];
y[1]=Dados_in[266];
y[2]=Dados_in[267];
y[3]=Dados_in[268];   

z[0]=Dados_in[269];
z[1]=Dados_in[270];
z[2]=Dados_in[271];
z[3]=Dados_in[272]; 
    
vu[0]=Dados_in[273];
vu[1]=Dados_in[274];
vu[2]=Dados_in[275];
vu[3]=Dados_in[276]; 
    
vv[0]=Dados_in[277];
vv[1]=Dados_in[278];
vv[2]=Dados_in[279];
vv[3]=Dados_in[280];
    
vw[0]=Dados_in[281];
vw[1]=Dados_in[282];
vw[2]=Dados_in[283];
vw[3]=Dados_in[284]; 
    
throtle_c[0]=Dados_in[297];
throtle_c[1]=Dados_in[298];
throtle_c[2]=Dados_in[299];
throtle_c[3]=Dados_in[300];      

throtle_s[0]=Dados_in[333];
throtle_s[1]=Dados_in[334];
throtle_s[2]=Dados_in[335];
throtle_s[3]=Dados_in[336];                                                             
        
memcpy(&pitch_1,&pit[0],4);
Pitch[0] = (double)pitch_1;
memcpy(&roll_1,&rll[0],4);
Roll[0] = (double)roll_1;
memcpy(&hding_true,&yaw_true[0],4);
Heading_true[0] = (double)hding_true;
memcpy(&hding_mag,&yaw_mag[0],4);
Heading_mag[0] = (double)hding_mag;
    
memcpy(&aoa_1,&aoa[0],4);
AoA[0] = (double)aoa_1;
memcpy(&sideslip_1,&sideslip[0],4);
Sideslip[0] = (double)sideslip_1;

memcpy(&lat_1,&lat[0],4);
Latitude[0] = (double)lat_1;
memcpy(&longi_1,&longi[0],4);
Longitude[0] = (double)longi_1;
memcpy(&alti_1,&alti[0],4);
Altitude[0] = (double)alti_1;
    
memcpy(&x_1,&x[0],4);
X[0] = (double)x_1;
memcpy(&y_1,&y[0],4);
Y[0] = (double)y_1;        
memcpy(&z_1,&z[0],4);
Z[0] = (double)z_1;
memcpy(&vu_1,&vu[0],4);
Vu[0] = (double)vu_1;        
memcpy(&vv_1,&vv[0],4);
Vv[0] = (double)vv_1;
memcpy(&vw_1,&vw[0],4);
Vw[0] = (double)vw_1;
memcpy(&throtle_c_1,&throtle_c[0],4);
Throtle_com[0] = (double)throtle_c_1;
memcpy(&throtle_s_1,&throtle_s[0],4);
Throtle_sen[0] = (double)throtle_s_1;
/* %%%-SFUNWIZ_wrapper_Outputs_Changes_END --- EDIT HERE TO _BEGIN */
}


