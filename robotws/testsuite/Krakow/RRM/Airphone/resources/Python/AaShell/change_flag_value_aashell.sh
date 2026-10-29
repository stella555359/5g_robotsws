
#!/bin/bash

if [[ -z $1 && -z $2 ]]; then
    echo "run_aashell_cmd.sh FAILURE: No flag and its value to aashell passed!"
    echo "Example:"
    echo "./run_aashell_cmd.sh 0x10043 "
    exit 1
fi

echo Changing $1 flag to value $2
aashellcmd="rad -mw $1 $2"
echo aashell ${aashellcmd}
gnbcmd="{ echo ${aashellcmd}; sleep 1; } | telnet 0 15007"
echo gnbcmd ${gnbcmd}

ssh toor4nsn@192.168.255.129 ${gnbcmd}
