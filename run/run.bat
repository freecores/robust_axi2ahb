
echo off

..\..\..\robust.exe ../src/base/axi2ahb.v -od out -I ../src/gen -list list.txt -listpath -header

echo Completed RobustVerilog axi2ahb run - results in run/out/
