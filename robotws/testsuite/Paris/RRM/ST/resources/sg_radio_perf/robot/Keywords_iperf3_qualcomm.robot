*** Settings ***
Documentation
...      resources file for iperf3 traffic
...      last update: 27/05/2021  change iperf port setting value, annie.wong@nokia.com


*** Keywords ***
#Get traffic port iperf3
#    [Documentation]  Retrieve iperf port from UEid.
#    ...              and values that should contain.
#    ...              at th moment, argument ${direction} has no function
#    [Arguments]      ${direction}    ${ueid}=0    ${index}=0
#    ${port}          Evaluate         34000 + ${ueid} + ${index}
#    Return from Keyword           ${port}

Get traffic port iperf3
    [Arguments]      ${direction}     ${ueid}=${0}
    ${_dl}        Evaluate         34201 + ${ueid}
    ${_ul}        Evaluate         33201 + ${ueid}
    ${port}       set variable if   '${direction}' == 'DL'     ${_dl}       ${_ul}
    Log       direction=${direction} and port=${port}    console=${DEBUG_MODE_CONSOLE}
    Return from Keyword           ${port}

Get DL traffic port iperf3
    [Arguments]        ${ueid}=${0}
    ${_dl}           Evaluate          34203 + ${ueid}
    ${_dl_port}      set variable      ${tl.ues[${ueid}].iperf_details.port}
    ${final_port}    set variable if    '${_dl_port}'=='' or '${_dl_port}'=='None'      ${_dl}       ${_dl_port}
    Log        UE ${ueid} DL Port=${final_port}        console=${DEBUG_MODE_CONSOLE}
    Return from Keyword           ${final_port}

Get UL traffic port iperf3
    [Arguments]        ${ueid}=${0}
    ${_ul}           set variable      33203
    ${_ul_port}      set variable      ${tl.appserver.iperf_details.port}
    ${port}          set variable if   '${_ul_port}'=='' or '${_ul_port}'=='None'      ${_ul}       ${_ul_port}
    ${final_port}    Evaluate           ${port} + ${ueid}
    Log        UE ${ueid} UL Port=${final_port}        console=${DEBUG_MODE_CONSOLE}
    Return from Keyword           ${final_port}


Start DL Traffic iperf3
    [Documentation]  Launch DL traffic with iperf command (UDP). Server info are valued in __init__.py (custom part)
    ...              This keyword take as argument:
    ...                    . ${distantip}
    ...                    . ${tput} by default 100M     DL Tput
    ...                    . ${duration} by default 10   duration of DL traffic
    ...                    . ${ueid} by default 0        number to compute used port,
    ...                                                  discriminating each mobile of the test on same server.

    [Arguments]           ${distantip}      ${tput}=100M     ${duration}=0     ${ueid}=0

    ${port}                     Get DL traffic port iperf3        ueid=${ueid}

    ssh.Connect To              ${ULserver_ip}         ${ULserver_login}       ${ULserver_pwd}
    ...                         alias=iPerfUE
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

    ssh.Connect To              ${DLserver_ip}         ${DLserver_login}          ${DLserver_pwd}
    ...                         alias=iPerfCN
    ssh.Send Command            command=pkill -e iperf
    ...                         connection=iPerfCN
    ssh.Send Command            command=rm iperf.log
    ...                         connection=iPerfCN
    Log                         Send cmd=iperf3 -c ${distantip} -u -i 1 -b ${tput} -t ${duration} -p ${port} -l 1300
    ...                         console=${DEBUG_MODE_CONSOLE}
    ssh.Send Command
    ...        command=iperf3 -c ${distantip} -u -i 1 -b ${tput} -t ${duration} -p ${port} -l 1300 --logfile iperf.log
    ...        connection=iPerfCN
    sleep                       5s
    ${result}                   ssh.Execute     command=cat iperf.log
    ...                         connection=iPerfCN
    Log                         ${result}   console=${DEBUG_MODE_CONSOLE}
    #should contain              ${result}       local ${COREIPTRAFFICSERVER} port
    should contain              ${result}        local ${DLserver_uplane_ip} port
    should contain              ${result}       connected to ${distantip} port ${port}

    ssh.disconnect              connection=iPerfUE
    ssh.disconnect              connection=iPerfCN


Stop DL traffic iperf3
    [Documentation]  Stop DL traffic by killing Iperf process on port numbered based on ueid.
    ...        Server info are valued in tlconfig.py (config file). This keyword take as argument:
    ...        ${ueid} by default 0       number to compute port, discriminating each mobile of the test on same server.
    ...              Author: Denis
    [Arguments]         ${ueid}=0
    # ${port}             Get traffic port iperf3        DL       ${ueid}
    ssh.Connect To              ${DLserver_ip}         ${DLserver_login}          ${DLserver_pwd}
    ...                         alias=iPerfCN

    # Kill all iperf processes
    ${result}                   ssh.execute         command=pkill -e iperf         connection=iPerfCN
    ssh.disconnect              connection=iPerfCN
    ssh.Connect To              ${ULserver_ip}         ${ULserver_login}       ${ULserver_pwd}
    ...                         alias=iPerfUE
    ${result}                   ssh.Execute     command=adb shell "pkill iperf3"    connection=iPerfUE
    ssh.disconnect              connection=iPerfUE


Start UL traffic iperf3
    [Documentation]  Launch UL traffic with iperf command (UDP). Server info are valued in tlconfig.py (config file)
    ...              This keyword take as argument:
    ...                    . ${distantip}
    ...                    . ${tput} by default 100M     DL Tput
    ...                    . ${duration} by default 10   duration of DL traffic
    ...                    . ${ueid} by default 0        number to compute used port,
    ...                                                  discriminating each mobile of the test on same server.
    ...              Author: Denis
    ...             05.11.2019 : Modification to launch iperf receiver
    [Arguments]         ${distantip}     ${tput}=100M     ${duration}=0     ${ueid}=0

    ${port}             Get UL traffic port iperf3       ueid=${ueid}

    ssh.Connect To              ${DLserver_ip}         ${DLserver_login}          ${DLserver_pwd}
    ...                         alias=iPerfCN
    ssh.Connect To              ${ULserver_ip}         ${ULserver_login}       ${ULserver_pwd}
    ...                         alias=iPerfUE

    # Start the server on the UE
    ssh.Send Command            command=adb shell "pkill iperf3"
    ...                         connection=iPerfUE
    ssh.Send Command            command=adb shell -n "rm /data/iPerfUE.log"
    ...                         connection=iPerfUE
    #ssh.Send Command        command=adb shell -n "/data/iperf3 -4 -s -i 1 -p ${port} -V --logfile /data/iPerfUE.log" &
    #...                     connection=iPerfUE
    ssh.Send Command            command=adb shell "/data/iperf3 -4 -s -i 1 -p ${port} -V --logfile /data/iPerfUE.log" &
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
    Log                         Send cmd=iperf3 -R -c ${distantip} -u -i 1 -b ${tput} -t ${duration} -p ${port} -l 1300
    ...                         console=${DEBUG_MODE_CONSOLE}
    ssh.Send Command
    ...     command=iperf3 -R -c ${distantip} -u -i 1 -b ${tput} -t ${duration} -p ${port} -l 1300 --logfile iperf.log
    ...     connection=iPerfCN
    # Retrieve the first output of iperf to check if the command has well started
    sleep                       10s
    ${result}                   ssh.Execute     command=cat iperf.log
    ...                         connection=iPerfCN
    Log                         ${result}   console=${DEBUG_MODE_CONSOLE}
    #should contain              ${result}       local ${COREIPTRAFFICSERVER} port
    should contain              ${result}        local ${DLserver_uplane_ip} port
    should contain              ${result}       connected to ${distantip} port ${port}

    ssh.disconnect              connection=iPerfUE
    ssh.disconnect              connection=iPerfCN


Stop UL traffic iperf3
    [Documentation]  Stop UL receiver by killing Iperf process on port numbered based on ueid. Server info are valued in tlconfig.py (config file)
    ...              This keyword take as argument:
    ...                    . ${ueid} by default 0         number to compute port, discriminating each mobile of the test on same server.
    ...              Author: Yves
    [Arguments]         ${ueid}=0
    # ${port}             Get traffic port iperf3        UL       ${ueid}
    ssh.Connect To              ${DLserver_ip}         ${DLserver_login}       ${DLserver_pwd}
    ...                         alias=iPerfCN
    ssh.Connect To              ${ULserver_ip}         ${ULserver_login}       ${ULserver_pwd}
    ...                         alias=iPerfUE

    # Stop the client on the VM traffic
    ${result}                   ssh.execute         command=pkill -e iperf         connection=iPerfCN

    # Stop the server on the UE
    ${result}                   ssh.Execute     command=adb shell "pkill iperf3"    connection=iPerfUE

    ssh.disconnect              connection=iPerfCN
    ssh.disconnect              connection=iPerfUE


Start simultaneous ULDL traffic iperf3
    [Documentation]  Launch UL and DL traffic with iperf3 command (UDP).
    ...             Server info are valued in tlconfig.py (config file).
    ...             This keyword take as argument:
    ...                    . ${distantip}
    ...                    . ${tput_ul} by default 100M     UL Tput
    ...                    . ${tput_dl} by default 100M     DL Tput
    ...                    . ${duration} by default 10      duration of DL and UL traffic
    ...                    . ${ueid} by default 0
    ...                    number to compute used port discriminating each direction and each mobile of the test :
    ...                       in ul: +2
    ...                       in dl: +1
    ...              Author: Yves Gorjux
    [Arguments]      ${distantip}     ${tput_ul}=200M     ${tput_dl}=600M     ${duration}=30000     ${ueid}=0
    ...    ${len}=1300    ${parallel_thread}=${EMPTY}

    ${parallel_thread}    Run Keyword If    '${parallel_thread}' != '${EMPTY}'    Set Variable    -P${parallel_thread}


    #${_ul}        Get traffic port iperf3    UL    ${ueid}    2
    #${_dl}        Get traffic port iperf3    DL    ${ueid}    1
    ${_ul}         Get UL traffic port iperf3        ueid=${ueid}
    ${_dl}         Get DL traffic port iperf3        ueid=${ueid}

    ssh.Connect To              ${DLserver_ip}         ${DLserver_login}       ${DLserver_pwd}
    ...                         alias=iPerfCN
    ssh.Connect To              ${ULserver_ip}         ${ULserver_login}       ${ULserver_pwd}
    ...                         alias=iPerfUE

    # Stop any existing iperf3 server on the UE and start the two servers for UL and DL
    ssh.Send Command       command=adb shell "pkill iperf3"
    ...                    connection=iPerfUE
    ssh.Send Command       command=adb shell -n "rm /data/iPerfUE_*.log"
    ...                    connection=iPerfUE
    ssh.Send Command       command=adb shell "/data/iperf3 -4 -s -i 1 -p ${_ul} -V --logfile /data/iPerfUE_UL.log" &
    ...                    connection=iPerfUE
    ssh.Send Command       command=adb shell "/data/iperf3 -4 -s -i 1 -p ${_dl} -V --logfile /data/iPerfUE_DL.log" &
    ...                    connection=iPerfUE
    # Retrieve the first output of iperf3 servers to check if the servers have well started
    sleep                       1s
    ${result}                   ssh.Execute     command= adb shell -n "cat /data/iPerfUE_DL.log"
    ...                         connection=iPerfUE
    should not contain          ${result}       iperf3: exiting
    ${result}                   ssh.Execute     command= adb shell -n "cat /data/iPerfUE_UL.log"
    ...                         connection=iPerfUE
    should not contain          ${result}       iperf3: exiting
    # Stop any existing iperf3 clients on the VM traffic and start the two clients for UL and DL
    ssh.Send Command            command=pkill -e iperf
    ...                         connection=iPerfCN
    ssh.Send Command            command=rm iperf_*.log
    ...                         connection=iPerfCN
    Log           Send cmd=iperf3 -R -c ${distantip} -u -i 1 -b ${tput_ul} -t ${duration} -p ${_ul} -l ${len}
    ...           console=${DEBUG_MODE_CONSOLE}
    ssh.Send Command
    ...   command=iperf3 -R -c ${distantip} -u -i 1 -b ${tput_ul} -t ${duration} -p ${_ul} -l ${len} ${parallel_thread} --logfile iperf_ul.log
    ...   connection=iPerfCN

    Log           Send cmd=iperf3 -c ${distantip} -u -i 1 -b ${tput_dl} -t ${duration} -p ${_dl} -l ${len}
    ...           console=${DEBUG_MODE_CONSOLE}
    sleep                       10s
    ssh.Send Command
    ...    command=iperf3 -c ${distantip} -u -i 1 -b ${tput_dl} -t ${duration} -p ${_dl} -l ${len} --logfile iperf_dl.log
    ...    connection=iPerfCN
    sleep                       10s

    # Retrieve the first output of iperf3 client to check if the two clients have well started
    ${result}                   ssh.Execute     command=cat iperf_ul.log
    ...                         connection=iPerfCN
    Log                         ${result}   console=${DEBUG_MODE_CONSOLE}
    should contain              ${result}       local ${DLserver_uplane_ip} port
    should contain              ${result}       connected to ${distantip} port ${_ul}
    sleep                       10s
    ${result}                   ssh.Execute     command=cat iperf_dl.log
    ...                         connection=iPerfCN
    Log                         ${result}   console=${DEBUG_MODE_CONSOLE}
    should contain              ${result}       local ${DLserver_uplane_ip} port
    should contain              ${result}       connected to ${distantip} port ${_dl}
    ssh.disconnect              connection=iPerfUE
    ssh.disconnect              connection=iPerfCN


Stop simultaneous ULDL traffic iperf3
    [Documentation]  Stop UL and DL receiver by killing Iperf process. Server info are valued in tlconfig.py (config file)
    ...              Author: Yves
    ssh.Connect To              ${DLserver_ip}         ${DLserver_login}       ${DLserver_pwd}
    ...                         alias=iPerfCN
    ssh.Connect To              ${ULserver_ip}         ${ULserver_login}       ${ULserver_pwd}
    ...                         alias=iPerfUE
    # Stop the client on the VM traffic
    ${result}                   ssh.execute         command=pkill -e iperf         connection=iPerfCN
    # Stop the server on the UE
    ${result}                   ssh.Execute     command=adb shell "pkill iperf3"    connection=iPerfUE
    ssh.disconnect              connection=iPerfCN
    ssh.disconnect              connection=iPerfUE
