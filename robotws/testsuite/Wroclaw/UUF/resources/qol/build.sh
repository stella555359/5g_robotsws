#!/bin/bash
sshpass -p 'oZPS0POrRieRtu' ssh -q toor4nsn@192.168.255.129 ls /ffs/run/ | grep Target.*p7 | sed 's:TargetBD_::;s:.xml.p7::'
sshpass -p 'oZPS0POrRieRtu' ssh -q toor4nsn@192.168.255.129 ls /ffs/stb/ | grep Target.*p7 | sed 's:TargetBD_::;s:.xml.p7::'
