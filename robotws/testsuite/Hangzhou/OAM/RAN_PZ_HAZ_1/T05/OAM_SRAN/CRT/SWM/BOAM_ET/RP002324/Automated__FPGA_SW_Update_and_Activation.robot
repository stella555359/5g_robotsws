*** Settings ***
Documentation
...    Copyright 2018 Nokia Solutions and Networks. All rights reserved.
...    Author: piotr.sewerynek@nokia.com
...    Maintainer: mateusz.kowalczyk@nokia.com
...    Test Description: Verification update and activation FPGA software on FCT and FSP
...    AC/REQ: Legacy
...    FT in charge: FTTW23 > I_MBB_LTE_DEVWRO2_FTTW23_GMS <I_MBB_LTE_DEVWRO2_FTTW23@internal.nsn.com>
...    Confluence link: no confluence link
...    References: no references
...    QualityCenter: tds://fdd_lte.mn_lte.qc12-prod.int.net.nokia.com/qcbin/TestLabModule-000000003649890581?EntityType=ITestSet&EntityID=311708
...    Sample execution: pybot --variable CONFIGURATION:XXX -t XXX -L TRACE -b debug.log -d /home/ute/results/ general.robot

# Resource    system.robot
# Resource    admin.robot
# Resource    pretest_posttest.robot

Library    OperatingSystem
Library    String
Library    Process


*** Variables ***
@{ALLOWED_ALARMS}    &{4663}    &{10}    &{6202}
&{4663}     fault_id=4663
...         alarm_id=7115
...         alarm_severity=Warning
...         fault_name="Baseband card crash has been detected"
...         notifier=[MRBTS-1] MRBTS-1/EQM_R-4/APEQM_R-1/CABINET_R-1/BBMOD_R-1
&{10}       fault_id=10
...         alarm_id=7116
...         alarm_severity=Critical
...         fault_name="No connection to unit"
...         notifier=
&{6202}     fault_id=6202
...         alarm_id=7107
...         alarm_severity=Critical
...         fault_name="Transport layer connection failure in S1 interface"
...         notifier=

${SYSTEM_ENB_LOCAL_IP}=        192.168.255.129
${SYSTEM_ENB_SSH_USERNAME}=    toor4nsn
${SYSTEM_ENB_SSH_PASSWORD}=    oZPS0POrRieRtu
${SYSTEM_ENB_SSH_PROMPT}=      :~ >
${UPGRADE_TOOL_PATH}           /usr/bin
${FPGA_FILE_PATH}              /ffs/run/swpool/LFS/boot
${FILE_NAME_BIN}               FSP-BMUQ-A101-174.bin
${UPGRADE_TOOL}                fsmr4_fpga_upgrade
${BMUQ_174}                    ${CURDIR}/FSP-BMUQ-A101-174.bin
${RF_module_path}			    /MRBTS-1/RAT-1//EQM_L-1/RMOD_L-*/RU_L-1


*** Keywords ***
Automated_FPGA_SW_Update_and_Activation
    [Documentation]    Short description.
    Set Board Id And Infomodel Path
    Remove SSH Keys
    Check FSP FPGA SW Version
    Prepare File To Downgrade
    Downgrade And Activate FPGA SW
    FPGA Reconfig
    Wait Until Keyword Succeeds    120    5    Check FSP FPGA SW Version ${FPGA_VERSION}
    Wait for eNB configure and RF swCheckDone status
    Verify BTS states
    #Check BBMODs Availability Status
    #Check RMOD Online Status
    #WTSSIM S1 Link Establish
    #ADMIN Assert All Cells Are In OnAirDone State    timeout=120
    #WTSSIM Make Call In Every Cell And Check Parameters

Remove SSH Keys
    [Documentation]    Short description.
    Run    ssh-keygen -f "/home/ute/.ssh/known_hosts" -R 192.168.255.129

Check FSP FPGA SW Version
    [Documentation]    Short description.
    SYSTEM Open SSH Connection To Enb
    SSHLibrary.Switch Connection    index_or_alias=ssh_enb
    ${fpga_version}    SSHLibrary.Execute Command    cat /dev/ddal/fpga/board_id_${Board_Id}/fpga_version
    SYSTEM Close SSH Connection To Enb
    Set Test Variable    ${fpga_version}    ${FPGA_VERSION}
    Log    Actual FPGA SW Version: ${FPGA_VERSION}    console=yes

Check FSP FPGA SW Version ${value}
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${value}: <description>
    SYSTEM Open SSH Connection To Enb
    SSHLibrary.Switch Connection    index_or_alias=ssh_enb
    ${fpga_version}    SSHLibrary.Execute Command    cat /dev/ddal/fpga/board_id_${Board_Id}/fpga_version
    SYSTEM Close SSH Connection To Enb
    Should Be Equal As Integers   ${value}    ${fpga_version}
    Log    Actual FPGA SW Version: ${fpga_version}    console=yes

Prepare File To Downgrade
    [Documentation]    Short description.
    Log    Prepare File To Downgrade    console=yes
    Get Bin file from Server
    SYSTEM Open SSH Connection To Enb
    SYSTEM Put File To Enb Over Ssh    source_file=${BMUQ_174}
    ...                                destination_file=${FPGA_FILE_PATH}
    SYSTEM Close SSH Connection To Enb

Downgrade And Activate FPGA SW
    [Documentation]    Short description.
    SSHLibrary.Open Connection    host=${SYSTEM_ENB_LOCAL_IP}
    ...                           port=22
    ...                           timeout=60
    ...                           alias=ssh_enb
    ...                           prompt=${SYSTEM_ENB_SSH_PROMPT}
    SSHLibrary.Login    username=${SYSTEM_ENB_SSH_USERNAME}
    ...                 password=${SYSTEM_ENB_SSH_PASSWORD}
    ...                 delay=1s
    SSHLibrary.Switch Connection    index_or_alias=ssh_enb
    SSHLibrary.Write    ssh -o "StrictHostKeyChecking no" $(rio-ip FSP2) -l ${SYSTEM_ENB_SSH_USERNAME}
    SSHLibrary.Read Until    Password:
    SSHLibrary.Write    ${SYSTEM_ENB_SSH_PASSWORD}
    SSHLibrary.Read Until Prompt
    SSHLibrary.Write    cd ${UPGRADE_TOOL_PATH}
    SSHLibrary.Write   ${UPGRADE_TOOL} ${FPGA_FILE_PATH}/${FILE_NAME_BIN}
    Wait Until Keyword Succeeds    300    5    SSHLibrary.Read Until    upgrade was successful
    SYSTEM Close SSH Connection To Enb
    Log    Successful Downgrade    console=yes

FPGA Reconfig
    [Documentation]    Short description.
    SSHLibrary.Open Connection    host=${SYSTEM_ENB_LOCAL_IP}
    ...                           port=22
    ...                           timeout=60
    ...                           alias=ssh_enb
    ...                           prompt=${SYSTEM_ENB_SSH_PROMPT}
    SSHLibrary.Login    username=${SYSTEM_ENB_SSH_USERNAME}
    ...                 password=${SYSTEM_ENB_SSH_PASSWORD}
    ...                 delay=1s
    SSHLibrary.Switch Connection    index_or_alias=ssh_enb
    SSHLibrary.Write    ssh $(rio-ip FSP2) -l ${SYSTEM_ENB_SSH_USERNAME}
    SSHLibrary.Read Until    Password:
    SSHLibrary.Write    ${SYSTEM_ENB_SSH_PASSWORD}
    SSHLibrary.Read Until Prompt
    SSHLibrary.Write    cd ${UPGRADE_TOOL_PATH}
    SSHLibrary.Write   ${UPGRADE_TOOL} -reconfig
    sleep    500s
    SYSTEM Close SSH Connection To Enb
    Log    FPGA Reconfig    console=yes

Wait for eNB configure and RF swCheckDone status
    [Documentation]    Short description.
    sleep    300s
    Log  Waiting for ping return  console=${TRUE}
    ${ping_regain}  Run keyword and return status  Wait for target to be reachable  hostname=192.168.255.129  timeout=600
    Run keyword if    not ${ping_regain}  Fail  Ping has not been regained within timeout
    Wait until eNB reaches configured state
    Check if every RF module is on swCheckDone status

Wait until eNB reaches configured state
    [Documentation]    Short description.
    Wait Until Keyword Succeeds  500s  10s  ute_admin_infomodel.Query infomodel
    ...  query=/MRBTS-1/RAT-1/MCTRL-*/BBTOP_M-1/MRBTS_M-1/LNBTS_M-* is [stateInfo.proceduralState=regex"Configured|IntegratedToRan|OnAir"]
    ...  timeout=50

Check if every RF module is on swCheckDone status
    [Documentation]    Short description.
    ute_admin_infomodel.Query Infomodel    query=every ${RF_module_path} is [stateInfo.proceduralState=swCheckDone]   timeout=400
    ute_admin_infomodel.Query Infomodel    query=every ${RF_module_path} is [stateInfo.availabilityStatus!=regex"Offline|offline"]   timeout=50
    Log to console    Every RU_L is swCheckDone

Remove FPGA Modified File
    [Documentation]    Short description.
    SYSTEM Open SSH Connection To Enb
    SSHLibrary.Write    rm ${FPGA_FILE_PATH}/${FILE_NAME_BIN}
    SYSTEM Close SSH Connection To Enb

Check BBMODs Availability Status
    [Documentation]    Short description.
    ${release}=    Run Keyword And Return Status    Should Contain Any    ${OUT_ACTIVE_SW}    22R1    22R2
    Run Keyword If    ${release}    ADMIN Assert All Bbmods Are In Expected Availability State
    ...    expected_state=Offline
    ...    timeout=1000
    Run keyword if    not ${release}    Wait Until Bbmod Is In Expected Availability Status
    ...    expected_state=Failed
    Run Keyword If    ${release}    ADMIN Assert All Bbmods Are In Expected Availability State
    ...    expected_state=Online
    ...    timeout=1000
     Run keyword if    not ${release}    Wait Until Bbmod Is In Expected Availability Status
    ...    expected_state=Online                                                     timeout=1000

Check RMOD Online Status
    [Documentation]    Short description.
    ADMIN Assert All Rmods Are In Expected Operational State
    ...    expected_state=regex"Enabled|enabled"
    ...    timeout=500

Set Board Id And Infomodel Path
    [Documentation]    Short description.
    PREPOST Get Smod Position
    Run Keyword If    "${OUT_ADMIN_SMOD_POSITION}" == "left"    Set Suite Variable
    ...    ${Board_Id}    02
    Run Keyword If    "${OUT_ADMIN_SMOD_POSITION}" == "left"    Set Suite Variable
    ...    ${BTS_L_PATH}    /MRBTS-1/RAT-1/BTS_L-1
    Run Keyword If    "${OUT_ADMIN_SMOD_POSITION}" == "right"    Set Suite Variable
    ...    ${Board_Id}    0B
    Run Keyword If    "${OUT_ADMIN_SMOD_POSITION}" == "right"    Set Suite Variable
    ...    ${BTS_L_PATH}    /MRBTS-1/RAT-1/BTS_L-4

EDA Preconditions
    [Documentation]    Short description.
    Test Preconditions
    ADMIN Add Allowed Alarms    faults_list=@{ALLOWED_ALARMS}
    Set Board Id And Infomodel Path

Wait Until Bbmod Is In Expected Availability Status
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${expected_state}: <description>
    ...        ${timeout}: <description>
    [Arguments]    ${expected_state}
    ...            ${timeout}=1000
    wait until keyword succeeds
    ...    ${timeout}
    ...    5
    ...    Assert Bbmod Is In Expected Availability Status    ${expected_state}

Assert Bbmod Is In Expected Availability Status
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${expected_state}: <description>
    [Arguments]    ${expected_state}
    ${availability_status}    taf.sbts.oam.coam.admin.Get Parameters
    ...    ${BTS_L_PATH}/EQM_L-1/CABINET_L-1/BBMOD_L-1/BBU_L-1
    ...     availabilityStatus
    Should Match Regexp    ${availability_status['stateInfo']['availabilityStatus']}    ${expected_state}

Get Bin file from Server
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${IP}: <description>
    ...        ${usr}: <description>
    ...        ${pwd}: <description>
    [Arguments]    ${IP}=10.68.93.70    ${usr}=ute    ${pwd}=ute@dmin5
    ${remote_full_path}    set variable    /home/ute/HZOAM/01_BTS_SW/BigFile/${FILE_NAME_BIN}
    sftp download    ${IP}  ${usr}    ${pwd}    ${remote_full_path}    ${CURDIR}/${FILE_NAME_BIN}

SYSTEM Open SSH Connection To Enb
    [Documentation]    Short description.
    SSHLibrary.Open Connection    host=${SYSTEM_ENB_LOCAL_IP}    port=22    timeout=60    alias=ssh_enb
    SSHLibrary.Login              username=${SYSTEM_ENB_SSH_USERNAME}    password=${SYSTEM_ENB_SSH_PASSWORD}    delay=1s
    SSHLibrary.Switch Connection    index_or_alias=ssh_enb
    SSHLibrary.Write   echo "connection established"

SYSTEM Close SSH Connection To Enb
    [Documentation]    Short description.
    SSHLibrary.Switch Connection    index_or_alias=ssh_enb
    SSHLibrary.Close Connection

SYSTEM Put File To Enb Over Ssh
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${source_file}: <description>
    ...        ${destination_file}: <description>
    ...        ${mode}: <description>
    [Arguments]    ${source_file}    ${destination_file}=/user/${SYSTEM_ENB_SSH_USERNAME}/    ${mode}=0744
    SSHLibrary.Switch Connection    index_or_alias=ssh_enb
    SSHLibrary.Put File    source=${source_file}    destination=${destination_file}    mode=${mode}

PREPOST Get Smod Position
    [Documentation]    Short description.
    ${out_smod_position}=    taf.sbts.oam.coam.admin.Get Smod Position    timeout=10s
    Set Suite Variable    ${OUT_ADMIN_SMOD_POSITION}    ${out_smod_position}

Custom TC Teardown
    [Documentation]    Short description.
    Remove FPGA Modified File
    TC Teardown
