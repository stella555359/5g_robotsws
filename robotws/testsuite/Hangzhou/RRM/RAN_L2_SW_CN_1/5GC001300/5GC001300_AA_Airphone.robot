*** Settings ***
Documentation    ...
#Resource    ../CUDU_L2/common_setup_teardown.robot
#Suite Setup    Prepare TL And Suite Setup
#Test Setup    Common Test Setup 2
#Test Teardown    Common Test Teardown
#Suite Teardown    Common Suite Teardown
#Force Tags        CLOUD_5G_I_LO_AP_LO_NSA_FS_ECPRI_MMWV_TDD    CRT    RAN_5G    RAN_5G_TDD
#...               SBTS00    SBTS23R1     CN1_SQ    Airphone    5GC001300    FR2    IPV4    IPV6
#...               Owner_Susie    PRI-Medium
#
#*** Variables ***
#${UE_ID}            11
#${PROFILE_ID}       1
#${GNB_ID}           2
#${CELL_ID}          1
#${BEARER_ID}        2
#${DST_FOR_FRM}      MRBTS-1/NRBTS-1/NRCELL-1
#${DST_FOR_PM}       MRBTS-1/MNL-1/MNLENT-1/PMCADM-1
#${WTS_DIR}          /opt/iphy/latest
#&{GNB_ASIK}       ip=192.168.255.1    username=toor4nsn    password=oZPS0POrRieRtu    connection=GNBDU
#&{AP_ASIK}        ip=192.168.200.1    username=toor4nsn    password=oZPS0POrRieRtu    connection=AP
#&{AP_SYSLOG}      ip=192.168.200.1    file_limit=209715200    log_name=AP_syslog    alias=AP_syslog
#&{GNB_SYSLOG}     ip=192.168.255.1    file_limit=209715200    log_name=Gnb_syslog    alias=Gnb_syslog
#${Pm_Para}        reportingIntervalPm
#${Pm_Value}       5min
#${Prach_Para}     prachConfigurationIndex
#${GNBCUTYPE}      NSA
#${MAX_WAITTIME_CONFIGURED}    17 min
#${WTS_CFG}        wts_config_LO_AP_LO_TDD_eCPRI_mmwv_NSA_FS_2S_1CC.cfg
#${SCF_BASIC}         ${CURDIR}/config/scf_CLOUD_5G_I_LO_AP_LO_NSA_FS_ECPRI_MMWV_TDD.xml
#${IPHY_BASIC}        ${CURDIR}/config/iphy_CLOUD_5G_I_LO_AP_LO_NSA_FS_ECPRI_MMWV_TDD.xml
#${RD}             0x4B000F=1
#
#*** Test Cases ***
#5GC001300-ET-A001 Verify enable and disable of PRACH format C2 with prach 175- 120kHz feature NSA Mode
#    [Tags]    A001    AP_REG
#    [Setup]
#    Clear PM counter reports
#    Set Prach Parameter  175
#    Reboot TL And Check Configured
#    Suite Setup Start WTS And Check OnAir
#    Sleep    120s    reason=wait PM flow finish
#    OperatingSystem.Run And Return Rc And Output    mkdir -p ${SUITE_LOG_DIRECTORY}/PMFile/175
#    NSA LTE Attach    ${UE_ID}    ${PROFILE_ID}
#    NSA 5G Attach    ${UE_ID}    ${GNB_ID}    ${CELL_ID}    ${BEARER_ID}
#    wait until keyword succeeds    20min    5min    Check PM counter  175
#
#5GC001300-ET-A002 Verify enable and disable of PRACH format C2 with prach 177- 120kHz feature NSA Mode
#    [Tags]    A002
#    [Setup]
#    Clear PM counter reports
#    Set Prach Parameter  177
#    Reboot TL And Check Configured
#    Suite Setup Start WTS And Check OnAir
#    Sleep    120s    reason=wait PM flow finish
#    OperatingSystem.Run And Return Rc And Output    mkdir -p ${SUITE_LOG_DIRECTORY}/PMFile/177
#    NSA LTE Attach    ${UE_ID}    ${PROFILE_ID}
#    NSA 5G Attach    ${UE_ID}    ${GNB_ID}    ${CELL_ID}    ${BEARER_ID}
#    wait until keyword succeeds    20min    5min    Check PM counter  177
#
#
#5GC001300-ET-A003 Verify enable and disable of PRACH format C2 with prach 178- 120kHz feature NSA Mode
#    [Tags]    A003
#    [Setup]
#    Clear PM counter reports
#    Set Prach Parameter  178
#    Reboot TL And Check Configured
#    Suite Setup Start WTS And Check OnAir
#    Sleep    120s    reason=wait PM flow finish
#    OperatingSystem.Run And Return Rc And Output    mkdir -p ${SUITE_LOG_DIRECTORY}/PMFile/178
#    NSA LTE Attach    ${UE_ID}    ${PROFILE_ID}
#    NSA 5G Attach    ${UE_ID}    ${GNB_ID}    ${CELL_ID}    ${BEARER_ID}
#    wait until keyword succeeds    20min    5min    Check PM counter  178
#
#
#5GC001300-ET-A004 Verify enable and disable of PRACH format C2 with prach 182- 120kHz feature NSA Mode
#    [Tags]    A004
#    [Setup]
#    Clear PM counter reports
#    Set Prach Parameter  182
#    Reboot TL And Check Configured
#    Suite Setup Start WTS And Check OnAir
#    Sleep    120s    reason=wait PM flow finish
#    OperatingSystem.Run And Return Rc And Output    mkdir -p ${SUITE_LOG_DIRECTORY}/PMFile/182
#    NSA LTE Attach    ${UE_ID}    ${PROFILE_ID}
#    NSA 5G Attach    ${UE_ID}    ${GNB_ID}    ${CELL_ID}    ${BEARER_ID}
#    wait until keyword succeeds    20min    5min    Check PM counter  182
#
#
#5GC001300-ET-A005 Verify enable and disable of PRACH format C2 with prach 185- 120kHz feature NSA Mode
#    [Tags]    A005
#    [Setup]
#    Clear PM counter reports
#    Set Prach Parameter  185
#    Reboot TL And Check Configured
#    Suite Setup Start WTS And Check OnAir
#    Sleep    120s    reason=wait PM flow finish
#    OperatingSystem.Run And Return Rc And Output    mkdir -p ${SUITE_LOG_DIRECTORY}/PMFile/185
#    NSA LTE Attach    ${UE_ID}    ${PROFILE_ID}
#    NSA 5G Attach    ${UE_ID}    ${GNB_ID}    ${CELL_ID}    ${BEARER_ID}
#    wait until keyword succeeds    20min    5min    Check PM counter  185
#
#
#5GC001300-ET-A006 Verify enable and disable of PRACH format C2 with prach 187- 120kHz feature NSA Mode
#    [Tags]    A006
#    [Setup]
#    Clear PM counter reports
#    Set Prach Parameter  187
#    Reboot TL And Check Configured
#    Suite Setup Start WTS And Check OnAir
#    Sleep    120s    reason=wait PM flow finish
#    OperatingSystem.Run And Return Rc And Output    mkdir -p ${SUITE_LOG_DIRECTORY}/PMFile/187
#    NSA LTE Attach    ${UE_ID}    ${PROFILE_ID}
#    NSA 5G Attach    ${UE_ID}    ${GNB_ID}    ${CELL_ID}    ${BEARER_ID}
#    wait until keyword succeeds    20min    5min    Check PM counter  187
#
#
#5GC001300-ET-A007 Verify enable and disable of PRACH format C2 with prach 196- 120kHz feature NSA Mode
#    [Tags]    A007
#    [Setup]
#    Clear PM counter reports
#    Set Prach Parameter  196
#    Reboot TL And Check Configured
#    Suite Setup Start WTS And Check OnAir
#    Sleep    120s    reason=wait PM flow finish
#    OperatingSystem.Run And Return Rc And Output    mkdir -p ${SUITE_LOG_DIRECTORY}/PMFile/196
#    NSA LTE Attach    ${UE_ID}    ${PROFILE_ID}
#    NSA 5G Attach    ${UE_ID}    ${GNB_ID}    ${CELL_ID}    ${BEARER_ID}
#    wait until keyword succeeds    20min    5min    Check PM counter  196
#
#
#*** Keywords ***
#Backup Configuration files
#    OperatingSystem.Run  cp ${WTS_DIR}/${WTS_AP_XML} ${WTS_DIR}/AirPhoneConfig_TA_backup.xml
#
#Backup Scf
#    [Arguments]    ${log_dir}    ${scf_backup_name}
#    [Documentation]    This keyword is to back up SCF file
#    ...
#    ...    | Input Parameters | Man. | Description |
#    ...    | ${log_dir} | Yes | the folder directory to store the scf file |
#    ...    | ${scf_backup_name} | Yes | the saved SCF file name. it like SCF_${scf_backup_name}.xml |
#    ...
#    ...    Examples:
#    ...    | Backup Scf | ${SUITE_LOG_DIRECTORY} | before_suite |
#    ...    | Backup Scf | ${TEST_LOG_DIRECTORY} | after_suite |
#    Log To Console    Backup Scf...
#    Run Keyword And Ignore Error    coam.Setup Admin    bts_host=${GNB_ASIK.ip}
#    coam.Get Current Scf File    local_dir_path=${log_dir}    file_name=SCF_${scf_backup_name}.xml
#    Set Suite Variable    ${log_dir}
#    Set Suite Variable    ${scf_backup_name}
#    [Teardown]    Run Keyword And Ignore Error    coam.Teardown Admin
#
#Verify BTS Is Configured
#    [Documentation]    This keyword is to check the state of gNB is Configured or IntegratedToRan
#    Log To Console    verify BTS is configured...
#    Run Keyword And Ignore Error    COAM.Setup Admin    bts_host=${GNB_ASIK.ip}
#    ${bts_state}    COAM.Get Mrbts State
#    Log To Console    [INFO] BTS STATE : ${bts_state}
#    Should Contain Any    ${bts_state}    Configured    IntegratedToRan    OnAir    ignore_case=True
#    [Teardown]    Run Keyword And Ignore Error    COAM.Teardown
#
#Common Test Teardown
#    [Documentation]    This keyword is to detach UE, and stop logs for case
#    #Run Keyword And Ignore Error    common_log_capture.Stop Logs    ${log_name_list}
#    #Run Keyword And Ignore Error    common_log_capture.Stop Sos Report    ${TEST_LOG_DIRECTORY}
#    Run Keyword And Ignore Error    Run Keyword If    '${GNBCUTYPE}'=='NSA'    NSA LTE Detach    ${ue_id}
#    Run Keyword And Ignore Error    Run Keyword If    '${GNBCUTYPE}'=='SA'    SA 5G Detach    ${ue_id}
#
#Start GNB AP Syslog
#    [Arguments]    ${log_dir}
#    Log To Console    \n *** Capture gnb AP syslog (stub)
#
#Set Pm Reporting interval
#    COAM.Setup Admin    bts_host=${GNB_ASIK.ip}
#    COAM.Perform Parameter Recommissioning
#    ...    dist_name=${DST_FOR_PM}    parameter=${Pm_Para}    operation=update    value=${Pm_Value}    skip_parameter_relation_errors=True
#    [Teardown]    COAM.Teardown
#
#Set Prach Parameter
#    [Arguments]    ${Prach_Value}
#    COAM.Setup Admin    bts_host=${GNB_ASIK.ip}
#    COAM.Perform Parameter Recommissioning
#    ...    dist_name=${DST_FOR_FRM}    parameter=${Prach_Para}    operation=update    value=${Prach_Value}    skip_parameter_relation_errors=True
#    [Teardown]    COAM.Teardown
#
#Get BTS Id
#    [Documentation]    This keyword is to get BTS id in current env
#    COAM.Setup Admin    bts_host=${GNB_ASIK.ip}
#    ${cells_info}=    COAM.Get Cell List
#    ${dist_name}=    Set Variable    ${cells_info['cells']['nr'][0]['id']['configuration']}
#    Log    ${dist_name}
#    ${mrbts}    ${nrbts}    ${nrcell}    String.Split String    ${dist_name}    /
#    ${bts_id}    Fetch From Right    ${mrbts}    -
#    [Return]    ${bts_id}
#    [Teardown]    Run Keyword And Ignore Error    COAM.Teardown
#
#Recover Configuration files
#    ${bts_id}    Get BTS Id
#    COAM.Setup Admin    bts_host=${GNB_ASIK.ip}
#    COAM.Perform Commissioning
#    ...    bts_id=${bts_id}
#    ...    scf_file=${log_dir}/SCF_${scf_backup_name}.xml
#    ...    skip_parameter_relation_errors=True
#    ...    should_activate=True
#    ...    timeout=300
#    Recover WTS Configuration
#    [Teardown]    COAM.Teardown
#
#Recover WTS Configuration
#     OperatingSystem.Run    cp ${WTS_DIR}/AirPhoneConfig_TA_backup.xml ${WTS_DIR}/${WTS_AP_XML}
#     OperatingSystem.Run    rm -rf ${WTS_DIR}/AirPhoneConfig_TA_backup.xml
#
#Reboot AP Via Ssh
#    Log To Console    reboot AP ...
#    SSH.connect to    hostname=${AP_ASIK.ip}    username=${AP_ASIK.username}    password=${AP_ASIK.password}    alias=Airphone
#    SSH.execute    reboot   connection=Airphone
#    [Teardown]    Run Keyword And Ignore Error    SSH.Disconnect    connection=Airphone
#
#Connect to GNB-DU
#    SSH.connect to    hostname=${GNB_ASIK.ip}    username=${GNB_ASIK.username}    password=${GNB_ASIK.password}    alias=GNB-DU
#
#Reboot gNB Via Ssh
#    Log To Console    reboot gNB DU ...
#    SSH.connect to    hostname=${GNB_ASIK.ip}    username=${GNB_ASIK.username}    password=${GNB_ASIK.password}    alias=GNB-DU
#    SSH.execute    reboot   connection=GNB-DU
#    Run Keyword And Ignore Error    SSH.Disconnect    connection=GNB-DU
#
#Get and Set wts Parameter
#    [Arguments]    ${prach_ID}    ${ratio}
#    ${PRACH_NUMBER}     OperatingSystem.Run   cat ${WTS_DIR}/${WTS_AP_XML} | grep prachConfigIndex
#    ${prach_value}    Should Match Regexp     ${PRACH_NUMBER}     \\d+
#    ${RATIO}    OperatingSystem.Run    cat ${WTS_DIR}/${WTS_AP_XML} | grep ulDlDataSlotRatio
#    ${ratio_value}    Should Match Regexp     ${RATIO}     \\d+
#    ${execute_info}    OperatingSystem.Run
#    ...    sudo sed -i 's/<prachConfigIndex>${prach_value}/<prachConfigIndex>${prach_ID}/' ${WTS_DIR}/${WTS_AP_XML}
#    ${execute_info}    OperatingSystem.Run
#    ...    sudo sed -i 's/<ulDlDataSlotRatio>${ratio_value}/<ulDlDataSlotRatio>${ratio}/' ${WTS_DIR}/${WTS_AP_XML}
#
#check egate status
#    FOR     ${var}     IN RANGE    5
#         ${execute_info}    OperatingSystem.Run    cd ${WTS_DIR}; ./egate --port 20000
#         ${output}    OperatingSystem.Run    ps -edf | grep egate | grep -v grep
#         ${result}    ${ERR}    run keyword and ignore error    should contain    ${output}    egate
#         exit for loop if    '${result}'=="PASS"
#
#    END
#Verify BTS Is OnAir
#    [Documentation]    This keyword is to check the state of gNB is onAir
#    Log To Console    verify BTS is onAir...
#    Run Keyword And Ignore Error    COAM.Setup Admin    bts_host=${GNB_ASIK.ip}
#    ${bts_state}    COAM.Get Mrbts State
#    Log To Console    [INFO] BTS STATE : ${bts_state}
#    Should Contain Any    ${bts_state}    OnAir    ignore_case=True
#    [Teardown]    Run Keyword And Ignore Error    COAM.Teardown
#
#Check PM counter
#    [Arguments]    ${prachconfigindex}
#    wait until keyword succeeds    15min    1min    Get PM file    ${prachconfigindex}
#    ${pm_counter_value}    Get PM counter value from xml    M55306C03001    ${prachconfigindex}
#    should be true    ${pm_counter_value}>0
#    ${pm_counter_value}    Get PM counter value from xml    M55306C06001    ${prachconfigindex}
#    should be true    ${pm_counter_value}==1
#    ${pm_counter_value}    Get PM counter value from xml    M55306C00001    ${prachconfigindex}
#    should be true    ${pm_counter_value}>0
#    ${pm_counter_value}    Get PM counter value from xml    M55306C00002    ${prachconfigindex}    non
#    should be true    ${pm_counter_value}==0
#    ${pm_counter_value}    Get PM counter value from xml    M55306C00003    ${prachconfigindex}    non
#    should be true    ${pm_counter_value}==0
#    ${pm_counter_value}    Get PM counter value from xml    M55306C00004    ${prachconfigindex}    non
#    should be true    ${pm_counter_value}==0
#    ${pm_counter_value}    Get PM counter value from xml    M55306C00005    ${prachconfigindex}    non
#    should be true    ${pm_counter_value}==0
#    ${pm_counter_value}    Get PM counter value from xml    M55306C00006    ${prachconfigindex}    non
#    should be true    ${pm_counter_value}==0
#    ${pm_counter_value}    Get PM counter value from xml    M55306C00007    ${prachconfigindex}    non
#    should be true    ${pm_counter_value}==0
#    ${pm_counter_value}    Get PM counter value from xml    M55306C00008    ${prachconfigindex}    non
#    should be true    ${pm_counter_value}==0
#    ${pm_counter_value}    Get PM counter value from xml    M55306C00009    ${prachconfigindex}    non
#    should be true    ${pm_counter_value}==0
#    ${pm_counter_value}    Get PM counter value from xml    M55306C00010    ${prachconfigindex}    non
#    should be true    ${pm_counter_value}==0
#    ${pm_counter_value}    Get PM counter value from xml    M55306C00011    ${prachconfigindex}    non
#    should be true    ${pm_counter_value}==0
#    ${pm_counter_value}    Get PM counter value from xml    M55306C00012    ${prachconfigindex}    non
#    should be true    ${pm_counter_value}==0
#    ${pm_counter_value}    Get PM counter value from xml    M55306C00013    ${prachconfigindex}    non
#    should be true    ${pm_counter_value}==0
#    ${pm_counter_value}    Get PM counter value from xml    M55306C00014    ${prachconfigindex}    non
#    should be true    ${pm_counter_value}==0
#    ${pm_counter_value}    Get PM counter value from xml    M55306C00015    ${prachconfigindex}    non
#    should be true    ${pm_counter_value}==0
#    ${pm_counter_value}    Get PM counter value from xml    M55306C00016    ${prachconfigindex}    non
#    should be true    ${pm_counter_value}==0
#    ${pm_counter_value}    Get PM counter value from xml    M55306C00017    ${prachconfigindex}    non
#    should be true    ${pm_counter_value}==0
#    ${pm_counter_value}    Get PM counter value from xml    M55306C00018    ${prachconfigindex}    non
#    should be true    ${pm_counter_value}==0
#    ${pm_counter_value}    Get PM counter value from xml    M55306C00019    ${prachconfigindex}    non
#    should be true    ${pm_counter_value}==0
#    ${pm_counter_value}    Get PM counter value from xml    M55306C00020    ${prachconfigindex}    non
#    should be true    ${pm_counter_value}==0
#    ${pm_counter_value}    Get PM counter value from xml    M55306C00021    ${prachconfigindex}    non
#    should be true    ${pm_counter_value}==0
#    ${pm_counter_value}    Get PM counter value from xml    M55306C00022    ${prachconfigindex}    non
#    should be true    ${pm_counter_value}==0
#    ${pm_counter_value}    Get PM counter value from xml    M55306C00023    ${prachconfigindex}    non
#    should be true    ${pm_counter_value}==0
#    ${pm_counter_value}    Get PM counter value from xml    M55306C00024    ${prachconfigindex}    non
#    should be true    ${pm_counter_value}==0
#    ${pm_counter_value}    Get PM counter value from xml    M55306C00025    ${prachconfigindex}    non
#    should be true    ${pm_counter_value}==0
#    ${pm_counter_value}    Get PM counter value from xml    M55306C00026    ${prachconfigindex}    non
#    should be true    ${pm_counter_value}==0
#    ${pm_counter_value}    Get PM counter value from xml    M55306C00027    ${prachconfigindex}    non
#    should be true    ${pm_counter_value}==0
#    ${pm_counter_value}    Get PM counter value from xml    M55306C00028    ${prachconfigindex}    non
#    should be true    ${pm_counter_value}==0
#    ${pm_counter_value}    Get PM counter value from xml    M55306C00029    ${prachconfigindex}    non
#    should be true    ${pm_counter_value}==0
#    ${pm_counter_value}    Get PM counter value from xml    M55306C00030    ${prachconfigindex}    non
#    should be true    ${pm_counter_value}==0
#    ${pm_counter_value}    Get PM counter value from xml    M55306C00031    ${prachconfigindex}    non
#    should be true    ${pm_counter_value}==0
#    ${pm_counter_value}    Get PM counter value from xml    M55306C00032    ${prachconfigindex}    non
#    should be true    ${pm_counter_value}==0
#
#Clear PM counter reports
#    Connect to GNB-DU
#    SSH.execute    command=rm /tmp/PM.BTS*    connection=GNB-DU
#    [Teardown]    Run Keyword And Ignore Error    SSH.Disconnect    connection=GNB-DU
#
#Get PM file
#    [Arguments]    ${prachconfigindex}    ${log_path}=${SUITE_LOG_DIRECTORY}/PMFile
#    Check PM File
#    Get PM File To Local    ${log_path}/${prachconfigindex}
#    [Teardown]    Run Keyword And Ignore Error    SSH.Disconnect    connection=GNB-DU
#
#Check PM File
#    Connect to GNB-DU
#    ${output}    SSH.Execute    ls -lrt /tmp/PM.BTS*|wc -l    connection=GNB-DU
#    ${num}    Replace String   ${output}   \r\n   ${EMPTY}
#    Should Be True    ${num}>=2
#    [Teardown]    Run Keyword And Ignore Error    SSH.Disconnect    connection=GNB-DU
#
#Get PM File To Local
#    [Arguments]    ${log_path}
#    OperatingSystem.Run And Return Rc And Output    rm -rf ${log_path}/*
#    OperatingSystem.Run    sshpass -p oZPS0POrRieRtu scp toor4nsn@192.168.255.1:/tmp/PM.BTS* ${log_path}
#    OperatingSystem.Run And Return Rc And Output    gunzip ${log_path}/PM.BTS*.gz
#
#Get PM counter value from xml
#    [Arguments]    ${counter}    ${prachconfigindex}=175    ${flag}=prach
#    ${counter_info}    OperatingSystem.Run    cat ${SUITE_LOG_DIRECTORY}/PMFile/${prachconfigindex}/PM.BTS*.xml|grep ${counter}
#    ${cell_var}    Set Variable    PLMN-PLMN\/MRBTS-1\/NRBTS-1\/NRCELL-1<\/DN><\/MO><NE-WBTS_1.0 measurementType="NRACH">
#    ${count_var}    Set Variable    [\\s\\S]*?<${counter}>(?P<couner_num>\\d+)<\/${counter}>
#    ${count_var2}    Set Variable    \\S+<${counter}>(?P<couner_num>\\d+)<\/${counter}>
#    ${regex} =    Run Keyword If    '${counter}' == 'M55306C00001'
#    ...    Catenate    SEPARATOR=    ${cell_var}    ${count_var}
#    ...    ELSE    Catenate    SEPARATOR=    ${cell_var}    ${count_var2}
#    #${regex} =    Catenate    SEPARATOR=    ${cell_var}    ${count_var2}
#    Log To Console    ${regex}
#    ${list}    Get Regexp Matches    ${counter_info}    ${regex}    1
#    BuiltIn.Log    ${list}
#    ${len}    Get Length    ${list}
#    FOR    ${id}    IN RANGE    0    ${len}
#        ${counter_value}    Get From List    ${list}    ${id}
#        LOG    ${counter_value}
#        Exit Loop Based On Flag    ${counter_value}    ${flag}
#    END
#    Run Keyword And Ignore Error  SSH.Disconnect
#    [Return]    ${counter_value}
#
#Exit Loop Based On Flag
#    [Arguments]    ${counter_value}    ${flag}=prach
#    Run Keyword If    '${flag}' == 'prach'
#    ...    Exit For Loop If    '${counter_value}'>'0'
#    ...    ELSE    Exit For Loop If    '${counter_value}'=='0'
#
#Prepare TL And Suite Setup
#    Suite Setup Copy WTS Config Files From Local    ${CURDIR}/config/
#    Suite Setup Update GNB    swconfig_param=${RD}    scf_file=${SCF_BASIC}    iphy_file=${IPHY_BASIC}
