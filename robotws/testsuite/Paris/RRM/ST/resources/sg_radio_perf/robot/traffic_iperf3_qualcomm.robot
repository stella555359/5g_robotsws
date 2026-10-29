*** Keywords ***
Start DL Traffic IPerf
    [Documentation]  Launch DL traffic with iperf command (UDP). Server info are valued in __init__.py (custom part)
    ...              This keyword take as argument:
    ...                    . ${distantip}
    ...                    . ${tput} by default 100M     DL Tput
    ...                    . ${duration} by default 10   duration of DL traffic
    ...                    . ${ueid} by default 0        number to compute used port, discriminating each mobile of the test on same server.
    ...              Author: Denis
    ...                      Update 2019.08.22  Annie Wong
    [Arguments]         ${distantip}   ${tput}=100M     ${duration}=0     ${ueid}=0

    ${port}                     Get traffic port    DL      ${ueid}

    # ssh.Connect To      ${IPERF_VM_UL_IPADDRESS}     ${IPERF_VM_UL_LOGIN}     ${IPERF_VM_UL_PASSWD}   alias=iPerfUE
    ssh.Connect To      ${ULserver_ip}     ${ULserver_login}    ${ULserver_pwd}    alias=iPerfUE

    ssh.Send Command            command=adb shell "pkill iperf3"
    ...                         connection=iPerfUE
    ssh.Send Command            command=adb shell -n "rm /data/iPerfUE.log"
    ...                         connection=iPerfUE
    ssh.Send Command            command=adb shell "/data/iperf3 -4 -s -i 1 -p ${port} -V --logfile /data/iPerfUE.log" &
    ...                         connection=iPerfUE
    # Retrieve the first output of iperf to check if the command has well started
    sleep                       1s
    ${result}                   ssh.Execute     command= adb shell -n "cat /data/iPerfUE.log"
    ...                         connection=iPerfUE
    should not contain          ${result}       iperf3: exiting

    # ssh.Connect To       ${IPERF_VM_DL_IPADDRESS}     ${IPERF_VM_DL_LOGIN}    ${IPERF_VM_DL_PASSWD}    alias=iPerfCN
    ssh.Connect To      ${DLserver_ip}     ${DLserver_login}    ${DLserver_pwd}     alias=iPerfCN

    ssh.Send Command            command=pkill -e iperf
    ...                         connection=iPerfCN
    ssh.Send Command            command=rm iperf.log
    ...                         connection=iPerfCN
    log                         iperf3 -c ${distantip} -u -i 1 -b ${tput} -t ${duration} -p ${port} -l 1300
    ssh.Send Command            command=iperf3 -c ${distantip} -u -i 1 -b ${tput} -t ${duration} -p ${port} -l 1300 --logfile iperf.log
    ...                         connection=iPerfCN
    sleep                       10s
    ${result}                   ssh.Execute     command=cat iperf.log
    ...                         connection=iPerfCN
    # should contain              ${result}       local ${COREIPTRAFFICSERVER} port
    should contain              ${result}       local ${DLserver_uplane_ip} port
    should contain              ${result}       connected to ${distantip} port ${port}

    ssh.disconnect              connection=iPerfUE
    ssh.disconnect              connection=iPerfCN


Get traffic port
    [Documentation]  Retrieve iperf port from UEid.
    ...              and values that should contain.
    [Arguments]      ${direction}    ${ueid}=0
    ${port}       Evaluate         34000 + ${ueid}
    Return from Keyword           ${port}


Stop DL traffic
    [Documentation]  Stop DL traffic by killing Iperf process on port numbered based on ueid. Server info are valued in tlconfig.py (config file)
    ...              This keyword take as argument:
    ...                    . ${ueid} by default 0       number to compute port, discriminating each mobile of the test on same server.
    ...              Author: Denis
    [Arguments]         ${ueid}=0

    ${port}             Get traffic port        DL       ${ueid}
    # ssh.Connect To       ${IPERF_VM_DL_IPADDRESS}     ${IPERF_VM_DL_LOGIN}    ${IPERF_VM_DL_PASSWD}   alias=iPerfCN
    ssh.Connect To      ${DLserver_ip}     ${DLserver_login}    ${DLserver_pwd}     alias=iPerfCN
    # Kill all iperf processes
    ${result}                   ssh.execute         command=pkill -e iperf         connection=iPerfCN
    ssh.disconnect              connection=iPerfCN

    # ssh.Connect To       ${IPERF_VM_UL_IPADDRESS}    ${IPERF_VM_UL_LOGIN}    ${IPERF_VM_UL_PASSWD}   alias=iPerfUE
    ssh.Connect To      ${ULserver_ip}     ${ULserver_login}    ${ULserver_pwd}    alias=iPerfUE
    ${result}                   ssh.Execute     command=adb shell "pkill iperf3"    connection=iPerfUE
    ssh.disconnect              connection=iPerfUE


Start UL traffic
    [Documentation]  Launch UL traffic with iperf command (UDP). Server info are valued in tlconfig.py (config file)
    ...              This keyword take as argument:
    ...                    . ${distantip}
    ...                    . ${tput} by default 100M     DL Tput
    ...                    . ${duration} by default 10   duration of DL traffic
    ...                    . ${ueid} by default 0        number to compute used port, discriminating each mobile of the test on same server.
    ...              Author: Denis
    ...             05.11.2019 : Modification to launch iperf receiver
    [Arguments]         ${distantip}   ${tput}=100M     ${duration}=0     ${ueid}=0

    ${port}             Get traffic port    UL      ${ueid}

    # ssh.Connect To      ${IPERF_VM_DL_IPADDRESS}     ${IPERF_VM_DL_LOGIN}    ${IPERF_VM_DL_PASSWD}    alias=iPerfCN
    ssh.Connect To      ${DLserver_ip}     ${DLserver_login}    ${DLserver_pwd}     alias=iPerfCN
    # ssh.Connect To      ${IPERF_VM_UL_IPADDRESS}     ${IPERF_VM_UL_LOGIN}    ${IPERF_VM_UL_PASSWD}    alias=iPerfUE
    ssh.Connect To      ${ULserver_ip}     ${ULserver_login}    ${ULserver_pwd}    alias=iPerfUE

    # Start the server on the UE
    ssh.Send Command            command=adb shell "pkill iperf3"
    ...                         connection=iPerfUE
    ssh.Send Command            command=adb shell -n "rm /data/iPerfUE.log"
    ...                         connection=iPerfUE
    ssh.Send Command            command=adb shell -n "/data/iperf3 -4 -s -i 1 -p ${port} -V --logfile /data/iPerfUE.log" &
    ...                         connection=iPerfUE
    # Retrieve the first output of iperf to check if the command has well started
    sleep                       1s
    ${result}                   ssh.Execute     command= adb shell -n "cat /data/iPerfUE.log"
    ...                         connection=iPerfUE
    should not contain          ${result}       iperf3: exiting

    # Start the client on the VM traffic
    ssh.Send Command            command=pkill -e iperf
    ...                         connection=iPerfCN
    ssh.Send Command            command=rm iperf.log
    ...                         connection=iPerfCN
    ssh.Send Command            command=iperf3 -R -c ${distantip} -u -i 1 -b ${tput} -t ${duration} -p ${port} -l 1300 --logfile iperf.log
    ...                         connection=iPerfCN
    # Retrieve the first output of iperf to check if the command has well started
    sleep                       10s
    ${result}                   ssh.Execute     command=cat iperf.log
    ...                         connection=iPerfCN
    # should contain            ${result}       local ${COREIPTRAFFICSERVER} port
    should contain              ${result}       local ${DLserver_uplane_ip} port

    should contain              ${result}       connected to ${distantip} port ${port}

    ssh.disconnect              connection=iPerfUE
    ssh.disconnect              connection=iPerfCN


Stop UL traffic
    [Documentation]  Stop UL receiver by killing Iperf process on port numbered based on ueid. Server info are valued in tlconfig.py (config file)
    ...              This keyword take as argument:
    ...                    . ${ueid} by default 0         number to compute port, discriminating each mobile of the test on same server.
    ...              Author: Yves
    # ssh.Connect To    ${IPERF_VM_DL_IPADDRESS}   ${IPERF_VM_DL_LOGIN}    ${IPERF_VM_DL_PASSWD}   alias=iPerfCN
    ssh.Connect To      ${DLserver_ip}     ${DLserver_login}    ${DLserver_pwd}    alias=iPerfCN
    # ssh.Connect To    ${IPERF_VM_UL_IPADDRESS}   ${IPERF_VM_UL_LOGIN}    ${IPERF_VM_UL_PASSWD}    alias=iPerfUE
    ssh.Connect To      ${ULserver_ip}     ${ULserver_login}    ${ULserver_pwd}    alias=iPerfUE

    # Stop the client on the VM traffic
    ${result}                   ssh.execute         command=pkill -e iperf         connection=iPerfCN

    # Stop the server on the UE
    ${result}                   ssh.Execute     command=adb shell "pkill iperf3"    connection=iPerfUE

    ssh.disconnect              connection=iPerfCN
    ssh.disconnect              connection=iPerfUE
