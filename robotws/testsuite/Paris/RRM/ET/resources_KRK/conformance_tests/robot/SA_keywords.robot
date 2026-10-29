*** Settings ***
Documentation     [SUITE PURPOSE]   Perform Cell Setup with in gnb classical COAM and AP Classical
...               Test Case Scenario author:
...               Test Case Scenario contact:
...               Test Case automation author:
...               Test Case automation contact: adrien.hervat@nokia.com
...               Creation Date:
...               Modified Date:
...               Last Modified by:

Library           BuiltIn
Library           OperatingSystem
Library           Collections
Library           String
Library           DateTime
Library           ArchiveLibrary
Library           logging
Library           taf.lteemu
Library    	      taf.gnb.oam.coam.admin            WITH NAME   coam
Library           ../../../../../testsuite/FRT/resources/python_libs/ece_l1ByPass.py
Library           ../../../../../resources/python_libs/cells.py
Resource          ../../../../../testsuite/FRT/resources/robot/common_frt.robot
Resource          taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource          ../../../../../testsuite/FRT/resources/robot/AP_keywords.robot

*** Keywords ***

# ADT - KWs from KWs_Classical_GNB_Classical_AP.robot (to avoid having this module on master)
# -------------------------------------------------------------------------------------------

Start LTE Edaemon
    lteemu.Configure Lteemu Edaemon    edaemon_ssh_alias=lteemu    directory_path=${tl.core.dir_path}    port=${tl.core.edaemon_port}

Start LTE Egate
    lteemu.Configure Lteemu Egate    egate_ssh_alias=lteemu    directory_path=${tl.core.dir_path}    port=${tl.core.egate_port}

# ------------------------------------------------------------------------------------------

Setup LTEemu environment sudo SA
    [Arguments]         ${timeout}=300
    # Login to LTE emu
    Connect to LTEEMU  # root     password=${password}

    # ADT - replace pkill by lteemu.kill... + lteemu.stop...
    # ${output}    common_frt.Ssh Execute With Timeout    pkill -9 edaemon;sudo pkill -9 egate;sudo pkill -9 sim_enb    connection=lteemu

    lteemu.kill_lteemu_edaemon      edaemon_port=${tl.core.edaemon_port}
    ...                             connection=lteemu
    lteemu.kill_lteemu_egate        egate_port=${tl.core.egate_port}
    ...                             connection=lteemu
    lteemu.stop_lteemu

    ${output}    common_frt.Ssh Execute With Timeout    cd ${tl.core.dir_path}; rm -f *log*    connection=lteemu
    sleep    1s
    # Start up edaemon
    SA_keywords.Start LTE Edaemon
    # Start up egate
    SA_keywords.Start LTE Egate
    # Start Lteemu
    BuiltIn.Log    \nConnecting to: localhost, Port: ${tl.core.egate_port}    console=yes
    sleep    3s
    lteemu.Start Lteemu    egate_console_ip=${tl.core.default_ssh_connection_details.addr}    egate_port=${tl.core.egate_port}
    sleep    5s
    lteemu.Reset_Lteemu_Cfg
    sleep    15s
    BuiltIn.Log    Configuring LteEmu    console=yes
    lteemu.Configure    file=${tl.core.cfg_filename}
    sleep    7s
    lteemu.Read Lteemu Output Until Re    expected=SystemInformationBlockType1-NR updated         timeout=${timeout}


WA AP SA
    AP_keywords.Connect to Airphone DU
    ${output}    common_frt.Ssh Execute With Timeout
    ...          sysctl -w net.sctp.sack_timeout=10;sysctl -w net.sctp.rto_min=200;sysctl -w net.sctp.rto_initial=200;sysctl -w net.sctp.rto_max=800
    ...          connection=DU_AIRPHONE

Launch UE Attach SA
    [Arguments]            ${id}=1

    # ADT - do not use "profile" anymore
    # lteemu.Ue Register     id=${id}    profile=1
    lteemu.Ue Register     id=${id}

    lteemu.Read Lteemu Output Until Re    expected=UE now in NG RM Registered state         timeout=40
    BuiltIn.Log             \nUE now in NG RM Registered state    console=yes

    sleep    10s


Verify AP Classical UE attach SA
  	Connect to LTEEMU
    ${output}    common_frt.Ssh Execute With Timeout    cd ${tl.core.dir_path}; grep REGISTRATION_ACCEPT uec_1.log*   connection=lteemu
    should contain	${output}	REGISTRATION_ACCEPT

Verify UE RELEASED
  	Connect to LTEEMU
    ${output}    common_frt.Ssh Execute With Timeout    cd ${tl.core.dir_path}; grep REGISTRATION_ACCEPT uec_1.log*   connection=lteemu
    should contain	${output}	RELEASED

Launch PDU Session SA
    [Arguments]         ${ue}=1   ${pdu}=1    ${gw}=1
    lteemu.Ue Pdu Session Setup     ue=${ue}    pdu=${pdu}   gw=${gw}
    lteemu.Read Lteemu Output Until    expected=Initial Context Setup Successful for UE with AMF       timeout=30
    BuiltIn.Log             \nInitial Context Setup Successful for UE with AMF    console=yes
    sleep    10s


Verify PDU Session SA
  	Connect to LTEEMU
    ${output}    common_frt.Ssh Execute With Timeout    cd ${tl.core.dir_path}; grep PDU Establishment Accept uec_1.log*   connection=lteemu
    should contain	${output}	PDU Establishment Accept


rootute_prefix
    #LteEmu password help to choose if a sudo prefix is needed or not on lteemu commend (like iperf)
    ${prefix}    Set variable if    '${HOST_EPCSIM.sshConnection.password}'=='root'    '${EMPTY}'    'sudo'
    Dated log    ${prefix}   ${HOST_EPCSIM.sshConnection.password}
    [Return]     ${prefix}

Traffic DL SA

    ${prefix}=  rootute_prefix
    Connect to LTEEMU
    [Arguments]         ${rate}=2      ${time}=30      ${prefix}=${EMPTY}

    Debug Dated Log  prefix value is ${prefix}
    ${ip}    common_frt.Ssh Execute With Timeout
    ...      ${prefix} ifconfig tunUPF | grep "inet " | awk -F inet {'print $2'} | awk -F " " {'print $1'}
    ...      connection=lteemu
    ...      timeout=${time}
    ${rest}    ${last} =   Split String From Right    ${ip}    .    1
    ${temp} =    Convert To Integer    ${last}
    ${temp2} =    Evaluate    ${temp}+1
    ${result} =    Set Variable    ${rest}.${temp2}
    BuiltIn.Log       \nTest DL ${rate} Mbits ${time}'' \nIP=${result}    console=yes
    # ${output}    common_frt.Ssh Execute With Timeout    iperf -c ${result} -u -l 1400 -b ${rate}M -i 1 -t ${time}  connection=lteemu
    ${output}    common_frt.Ssh Execute With Timeout     ${prefix} iperf -c ${result} -u -l 1400 -b ${rate}M -i 1 -t ${time}  connection=lteemu
    ...          timeout=${time}
    should contain	${output}	 connected with ${result}


Traffic UL SA
    ${prefix}=  rootute_prefix
    Connect to LTEEMU
    [Arguments]         ${rate}=2      ${time}=30    ${prefix}=${EMPTY}

    ${ip}    common_frt.Ssh Execute With Timeout
    ...      ${prefix} ifconfig tunUE1PDU1 | grep "inet " | awk -F inet {'print $2'} | awk -F " " {'print $1'}   connection=lteemu
    ...      timeout=${time}
    ${rest}    ${last} =   Split String From Right    ${ip}    .    1
    ${temp} =    Convert To Integer    ${last}
    ${temp2} =    Evaluate    ${temp}+1
    ${result} =    Set Variable    ${rest}.${temp2}
    BuiltIn.Log       \nTest UL ${rate} Mbits ${time}'' \nIP=${result}    console=yes
    ${output}    common_frt.Ssh Execute With Timeout    ${prefix} iperf -c ${result} -u -l 1400 -b ${rate}M -i 1 -t ${time}  connection=lteemu
    ...          timeout=${time}
    should contain	${output}	 connected with ${result}



Traffic DL/UL SA
    @{interfaces}    Create List    tunUPF      tunUE1PDU1
    @{IPs}           Create List

    ${prefix}=  rootute_prefix
    Connect to LTEEMU
    [Arguments]         ${rate}=2        ${time}=30    ${prefix}=${EMPTY}
    ${output}    common_frt.Ssh Execute With Timeout    echo '#!/bin/bash' > testtraffic    connection=lteemu    timeout=${time}

        FOR     ${key}    IN     @{interfaces}
            ${ip}    common_frt.Ssh Execute With Timeout
            ...      ${prefix} ifconfig ${key} | grep "inet " | awk -F inet {'print $2'} | awk -F " " {'print $1'}
            ...      connection=lteemu    timeout=${time}
            ${rest}    ${last} =   Split String From Right    ${ip}    .    1
            ${temp} =    Convert To Integer    ${last}
            ${temp2} =    Evaluate    ${temp}+1
            ${result} =    Set Variable    ${rest}.${temp2}
            Append To List       ${IPs}        ${result}
            ${output}    common_frt.Ssh Execute With Timeout
            ...          echo "${prefix} iperf -c ${result} -u -l 1400 -b ${rate}M -i 1 -t ${time} &" >> testtraffic
            ...          connection=lteemu    timeout=${time}

        END
    BuiltIn.Log       \nTest DL/UL ${rate} Mbits ${time}''    console=yes
    ${output}    common_frt.Ssh Execute With Timeout   chmod 777 testtraffic ; ./testtraffic     connection=lteemu    timeout=${time}

       FOR     ${key}    IN     @{IPs}
            should contain 	 ${output}   connected with ${key}

       END
    ${output}    common_frt.Ssh Execute With Timeout     rm testtraffic    connection=lteemu    timeout=${time}


Collect Snapshot
    [Arguments]        ${subname}=${EMPTY}
    coam_gnb_classical.Get GNB Logs from Coam
    ${alias}            SSH Connect         host=${HOST_AP_SYS0_M}
    csn.execute    command=(echo "log -a -z snapshot.zip";sleep 50)|telnet 0 15007    connection=${alias}
    sleep    80s
    ${timestamp}=    DateTime.Get Current Date    result_format=%Y%m%d-%H%M%S
    ${snapshot_path}                 set variable                            /tmp/snapshot.zip
    ${snapshot_local_path}           Set variable if    '${subname}'==''    ${LOG_PATH}/Snapshot_AP_${timestamp}.zip
    ...                              ${LOG_PATH}/Snapshot_AP_${subname}_${timestamp}.zip
    csn.download_file                remote_path=${snapshot_path}
    ...                              local_path=${snapshot_local_path}
    ...                              connection=${alias}


