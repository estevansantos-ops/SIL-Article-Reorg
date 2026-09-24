function [dx,zs]  = dtmjls(x,w,A,J,C,state)

 zs = C{state}*x;
 dx = A{state}*x + J{state}*w; 
