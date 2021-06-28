function y = remap(b,ac,xz)
%REMAP Remap numerical values from range [a c] to range [x z].
%
% -------------
% INPUT
% -------------
% b - input scalar, vector, matrix
% ac - source range: 1-by-2 vector, a <= b <= c
% xz - target range: 1-by-2 vector, x <= y <= z
% 
% -------------
% OUTPUT
% -------------
% y - output vector, remapped from range ac to xz
% 
% -------------
% ALGORITHM
% -------------
% Formula to remap values comprised in the range [a c] 
% to the range [x z] (b is the original value, y the target value):
% 
% y = (b - a) * (z - x) / (c - a) + x
% 
% -------------
% EXAMPLE
% -------------
% remap(5,[0 10],[0 1]) % = 0.5
% remap(128,[0 255],[0 1]) % = 0.502
% X = magic(3)
% remap(X,[min(min(X)) max(max(X))],[0 1])
%
% -------------
% TODO
% -------------
% Make this work for all matlab data classes.
%
% -------------
% LOG
% -------------
% 2015.12.07 - [new] transformed script to function
% 2010.10.11 - creation
%
% -------------
% CREDITS
% -------------
% Vlad Atanasiu, atanasiu@alum.mit.edu, http://alum.mit.edu/www/atanasiu/
a = ac(1);
c = ac(2);
x = xz(1);
z = xz(2);
y = (b - a) * (z - x) / (c - a) + x;