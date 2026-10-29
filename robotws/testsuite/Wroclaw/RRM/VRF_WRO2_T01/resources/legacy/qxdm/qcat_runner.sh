#!/bin/bash
sshpass -p $2 ssh -t -t $1@$3 "cd /cygdrive/c/Program\ Files\ \(x86\)/Qualcomm/QCAT\ 6.x/Bin/;./QCAT.exe -txt C:\\\\auto\\\\ue_logs.hdf"
