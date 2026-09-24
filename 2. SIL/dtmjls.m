function [dx,zs]  = dtmjls(x,w,A,J,C,state)

 zs = C{state}*x;
 dx = A{state}*x + J{state}*w + [0.01 0 0 0;0 0.01 0 0;0 0 0.01 0;0 0 0 0.01]*randn(4,1); 
