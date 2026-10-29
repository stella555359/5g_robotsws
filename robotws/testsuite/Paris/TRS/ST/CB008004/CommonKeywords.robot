*** Settings ***
Documentation
...                 author: David Jollivet
...                 contact: david.jollivet@nokia.com
...                 CB008004: New SFN0 offset management library


*** Keywords ***
Get TL RU
    [Documentation]    Get RU in TL description from RU type
    [Arguments]    ${ru_type}

    ${index}=    Set Variable    ${0}

    FOR    ${gnb}    IN    @{tl.gnbs}
        FOR    ${du}    IN    @{gnb}.dus
            FOR    ${common_unit}    IN    @{du}.common_units
                FOR    ${capacity_unit}    IN    @{common_unit}.capacity_units
                    FOR    ${ru}    IN    @{capacity_unit}.rus
                        IF    "${ru.radio_type}" == "${ru_type}"
                            RETURN    ${ru}
                        END
                    END
                END
            END
        END
    END
    RETURN    ${-1}

Connect to RU with Type
    [Documentation]    Open SSH connection to RU through CPRI/eCPRI with its type
    [Arguments]
    ...    ${bts_addr}
    ...    ${bts_smod_username}
    ...    ${bts_smod_password}
    ...    ${ru_username}
    ...    ${ru_password}
    ...    ${ru_type}

    # connection to SMOD
    ${MyRU}=    SSHLibrary.Open Connection    host=${bts_addr}
    SSHLibrary.Login    username=${bts_smod_username}    password=${bts_smod_password}

    # remove ssh known hosts
    ${command}=    Set Variable    rm -f /user/toor4nsn/.ssh/known_hosts
    SSHLibrary.Write    text=${command}
    Sleep    5s
    ${output}=    SSHLibrary.Read

    # connection to FHNET
    ${command}=    Set Variable    ls -ld /tmp/* |grep FHNET|grep node_0x|awk '{print $9}'|awk -F_ '{print $2}'
    SSHLibrary.Write    text=${command}
    ${fhnet}=    SSHLibrary.Read
    SSHLibrary.Write    text=lxc-attach -n ${fhnet}
    Sleep    5s

    # connection to RU
    ${command}=    Set Variable    cat /rom/config/FRIps.txt | grep ${ru_type} | awk -F\\; '{print $3}'
    SSHLibrary.Write    text=${command}
    ${result}=    SSHLibrary.Read
    ${ru_ip}=    Get Line    ${result}    0
    ${command}=    Set Variable    ssh -o StrictHostKeyChecking=no ${ru_username}@${ru_ip}

    SSHLibrary.Write    text=${command}
    Sleep    5s
    ${output}=    SSHLibrary.Read

    ${command}=    Set Variable    ${ru_password}
    SSHLibrary.Write    text=${command}
    Sleep    5s
    ${output}=    SSHLibrary.Read

    [Return]    ${MyRU}
    RETURN    ${MyRU}

Start Remote Tcpdump
    [Documentation]    Start TCPdump on an ssh connection
    [Arguments]    ${theSSH}    ${interface}

    Switch Connection    ${theSSH}
    ${command}=    Set Variable    sudo tcpdump -i ${interface} -w /tmp/tcpdump.pcap &
    SSHLibrary.Write    text=${command}
    Sleep    5s
    ${result}=    SSHLibrary.Read
    ${first}=    Get Line    ${result}    0
    ${pid}=    Get Substring    ${first}    4
    [Return]    ${pid}
    RETURN    ${pid}

Stop Remote Tcpdump
    [Documentation]    Stop TCPdump on an ssh connection
    [Arguments]    ${theSSH}    ${thePid}

    Switch Connection    ${theSSH}

    ${command}=    Set Variable    ps -ef | grep tcpdump
    SSHLibrary.Write    text=${command}
    Sleep    1s
    ${result}=    SSHLibrary.Read
    Log To Console    ${result}

    ${command}=    Set Variable    kill ${thePid}
    SSHLibrary.Write    text=${command}

    ${command}=    Set Variable    ps -ef | grep tcpdump
    SSHLibrary.Write    text=${command}

    ${command}=    Set Variable    sudo chmod 777 /tmp/tcpdump.pcap
    SSHLibrary.Write    text=${command}
    Sleep    1s
    ${result}=    SSHLibrary.Read

Get PCAP from RU
    [Documentation]    Get /tmp/tcpdump.pcap on RU
    [Arguments]    ${theSSH}    ${ru_username}    ${ru_password}    ${ru_type}

    Switch Connection    ${theSSH}

    # go back fo FHNET
    ${command}=    Set Variable    exit
    SSHLibrary.Write    text=${command}
    Sleep    1s

    # get pcap in FHNET/SMOD common directory from RU
    ${result}=    SSHLibrary.Read
    Log To Console    ${result}
    ${command}=    Set Variable    cat /rom/config/FRIps.txt | grep ${ru_type} | awk -F\\; '{print $3}'
    SSHLibrary.Write    text=${command}
    ${result}=    SSHLibrary.Read
    ${ru_ip}=    Get Line    ${result}    0
    ${command}=    Set Variable    scp ${ru_username}@${ru_ip}:/tmp/tcpdump.pcap /ffs/run/ru_tcpdump.pcap
    SSHLibrary.Write    text=${command}
    Sleep    5s
    ${result}=    SSHLibrary.Read
    ${command}=    Set Variable    ${ru_password}
    SSHLibrary.Write    text=${command}
    Sleep    5s
    ${result}=    SSHLibrary.Read

    # go back to SMOD
    ${command}=    Set Variable    exit
    SSHLibrary.Write    text=${command}
    Sleep    1s
    ${result}=    SSHLibrary.Read

    # get pcap in VM
    SSHLibrary.Get File    /ffs/run/ru_tcpdump.pcap    /tmp/ru_tcpdump.pcap

Check All Cells Enabled
    [Documentation]    Get 4G&5G cells status
    [Arguments]    ${enb_addr}    ${gnb_addr}

    COAM Get 4g status enabled    ${enb_addr}
    COAM Get 5g status enabled    ${gnb_addr}

Connect to Spirent Sentinel
    [Documentation]    Authenticate to Spirent Sentinel
    [Arguments]    ${spirent_addr}

    ${spirent_log}=    Run    curl --noproxy "*" -k http://${spirent_addr}/api/getkey?seed=1234
    ${spirent_key}=    Get Line    ${spirent_log}    -1
    Log To Console    Spirent Authentication Key = ${spirent_key}

    Run    curl --noproxy "*" -k http://${spirent_addr}/api/login?key=${spirent_key}

Load Spirent Sentinel Preset
    [Documentation]    Load Spirent Sentinel Preset file
    [Arguments]    ${spirent_addr}    ${spirent_sentinel_preset}

    Run    curl --noproxy "*" -k http://${spirent_addr}/api/setsettings --data-binary @${spirent_sentinel_preset}

Get Spirent Sentinel Offset
    [Documentation]    Get the frameStartOffset value in us as read by Spirent Sentinel
    [Arguments]    ${spirent_addr}
    Run    curl --noproxy "*" -k http://${spirent_addr}/api/set/measure/meas_time?value=60
    Run    curl --noproxy "*" -k http://${spirent_addr}/api/startmeasurement
    Sleep    70s
    ${spirent_log}=    Run    curl --noproxy "*" -k http://${spirent_addr}/api/getdata?"channel=E&datatype=te"
    ${spirent_last_meas}=    Get Line    ${spirent_log}    -1
    ${dummy}    ${offset_sec}=    Split String    ${spirent_last_meas}    ,
    ${offset}=    Evaluate    ${offset_sec} * 1000000
    Log To Console    Spirent detected offset = ${offset} us
    [Return]    ${offset}
    RETURN    ${offset}
