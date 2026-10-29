*** Settings ***
Documentation    ...
#Resource          ../CUDU_L2_AIC/common_aic_setup_teardown.robot
#Force Tags        CLOUD_5GC_dR2.0_1vDU_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CRT    RAN_5G    RAN_5G_TDD    FR1    Owner_zhachen
#...               vDUCNF_0.300    master_vDU
#Suite Setup       Run Keywords    Common Suite Setup
#...               AND    Update Aic GNB    VCU_SCFC_PATH=${2534_VCU_SCFC_PATH}
#...                      VDU_SCFC_PATH=${2534_VDU_SCFC_PATH}
#...               AND    Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#...               AND    Start WTS And Check OnAir
#Suite Teardown    AiC Common Suite Teardown
#
#*** Variables ***
#${LOCAL_WTS_DIR}         ${CURDIR}/config
#${GNB_INDEX}             0
#${IPHY_PATH}             ./config/iphy.xml
#${wts_dir}               /opt/iphy/latest
#${WTS_CFG}               ${CURDIR}/config/basic_setup_hz.cfg
#${2534_VCU_SCFC_PATH}    ./config/2534_vcu_scfc.xml
#${2534_VDU_SCFC_PATH}    ./config/2534_vdu_scfc.xml
#${1736_VCU_SCFC_PATH}    ./config/1736_vcu_scfc.xml
#${1736_VDU_SCFC_PATH}    ./config/1736_vdu_scfc.xml
#${1304_VCU_SCFC_PATH}    ./config/1304_vcu_scfc.xml
#${1304_VDU_SCFC_PATH}    ./config/1304_vdu_scfc.xml
#${tarGet Counter}        1000
#
#*** Test Cases ***
#5GC002534_A003_Activate_PDSCH_at_SSBslot_20MHz_csirsTrackingPeriod_40ms
#    SA UE Attach    1
#    SA Start DL Traffic    1    100    30s    1    yes
#    SA Check Average Traffic Range 2 Percent On Target    1    dl    400
#    SA Stop Traffic    1    dl
#    SA UE Detach    1
#    [Teardown]    AiC Common Test Teardown
#
#5GC001304_B_01_UE_Attach_With_Modified_TotalNumberOfRA_Preambles_PrachConfIndex_151_1ssb
#    NSA UE Attach    11
#    NSA UE Detach    11
#    [Teardown]    AiC Common Test Teardown
#
#5GC001736-A_ET_015_DDDS_Reduction_PM_Counters_For_Cloud_NSA_TDD
#    NSA UE Attach    11
#    NSA Start DL Traffic    11    2    10    10min    1
#    ${counter_value}    VCU Get PM Counter Value    M55323C14001    MRBTS-1111/NRBTS-1111
#    ${counter_value_2}    VCU Get PM Counter Value    M55313C24001    MRBTS-1111/NRBTS-1111
#    Should Be True    "${counter_value}">="${tarGet Counter}"
#    Should Be True    "${counter_value_2}">="${tarGet Counter}"
#    NSA Check Average Traffic Range 2 Percent On Target    11    2    dl    10    scg
#    NSA Stop Traffic    11    2    dl    1
#    NSA UE Detach    11
#    [Teardown]    AiC Common Test Teardown
#
#*** Keywords ***
#Check M55313C24001 Above Zero
#    ${counter_value_2}    VCU Get PM Counter Value    M55313C24001    MRBTS-1111/NRBTS-1111
#    Should Be True    "${counter_value_2}">="1000"
#
#AiC Common Test Setup
#    [Arguments]    ${VCU_SCFC_PATH}=${EMPTY}    ${VDU_SCFC_PATH}=${EMPTY}
#    Create Test Directory
#    Run Keyword If    '${VCU_SCFC_PATH}'!='${empty}'    VCU Full Commssion    ${VCU_SCFC_PATH}
#    Run Keyword If    '${VDU_SCFC_PATH}'!='${empty}'    VDU Full Commssion    ${VDU_SCFC_PATH}
#    Run Keyword If    '${VCU_SCFC_PATH}'!='${empty}' or '${VDU_SCFC_PATH}'!='${empty}'    Process.Start Process
#    ...    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.200.129 system-module-reboot    shell=True
#    Check F1 C Link Status
#    Startup Edaemon Egate
#    Trigger X2 Link Establish
#    Check SANSA Cell Onair
#
#AiC Common Test Teardown
#    Collect VDU Container Log
#    Collect Snapshot And SosReportLog
#    Clear Env
#
#AiC Common Suite Teardown
#    Clear Env
#
#Check F1 C Link Status
#    vcu.Connect To    host=192.168.100.129    port=${EMPTY}    username=Nemuadmin
#    ...    password=nemuuser    cu_version=cuoam_21b    secure=True    alias=cu_admin
#    Wait Until Keyword Succeeds    10min    30s    Verify CU OAM F1 Setup
#    vcu.Disconnect    connection=cu_admin
#
#Verify CU OAM F1 Setup
#    [Documentation]    This keyword is used to Get the F1 link status by admin api to CU.
#    ...    author: kongshuai.fan
#    ${du_status}    vcu.Get Du State    connection=cu_admin
#    ${f1_status}    Set Variable    ${du_status['f1_link_status']}
#    ${f1_status_str}    Convert To String    ${f1_status}
#    Should Contain    ${f1_status_str}    'available': 1
#
#Startup Edaemon Egate
#    ute_wtssim.Setup Edaemon    edaemon_port=22222    tool_dir=${wts_dir}    alias=edaemon
#    ute_wtssim.Start Edaemon Process    alias=edaemon
#    ute_wtssim.Setup Egate    egate_port=20000    tool_dir=${wts_dir}
#    ute_wtssim.Start Egate Process
#    ute_wtssim.Execute Egate Command    cfg file\=${LUA_PATH}    pass_regexp=(SimMode is ready now|UEC-1 is active)
#
#Trigger X2 Link Establish
#    [Arguments]    ${enb_id}=1    ${gnb_id}=2
#    [Documentation]    This keyword is to setup X2 connection and check x2 is ok
#    Log To Console    setup X2 connection...
#    ${pattern}    Set Variable    ENB-${enb_id}: X2AP Link with GNB-${gnb_id} .* is up
#    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    enb_x2_link_up enb\=${enb_id} target\=${gnb_id}
#    ...    pass_regexp=${pattern}    timeout=1min
#    ${output}    String.Get Lines Matching Regexp    ${output}    ${pattern}    partial_match=True
#    Log To Console    \n${output}
#    Log    x2_is_ok, Sleep 30s waiting for 5G NR cell setup done
#    Sleep    30s    reason=waiting 5G NR cell setup done
#
#Check SANSA Cell Onair
#    Check Egate Log    eNB 1 cell 1: SystemInformationBlockType1 updated    1
#    Check Egate Log    eNB 1 cell 1: SystemInformationBlockType2 updated    1
#    Check Egate Log    eNB 2 cell 1: MasterInformationBlock-NR Updated    1
#    Check Egate Log    eNB 2 cell 1: SystemInformationBlockType1-NR updated    1
#    Check Egate Log    eNB 2 cell 1: SystemInformationBlockType2-NR updated    1
#    Check Egate Log    eNB 2 cell 1: SystemInformationBlockType3-NR updated    1
#
#Check Egate Log
#    [Arguments]    ${contain_msg}    ${count}=${EMPTY}
#    ute_wtssim.Execute Egate Command    sim_log_set flush
#    ute_wtssim.Collect Egate Log Files    unzip=true    subdirectory=${TEST_LOG_DIRECTORY}
#    ${ret}    Grep File    ${TEST_LOG_DIRECTORY}${/}egate_console.log    ${contain_msg}
#    ${act_count}    Get Count    ${ret}    ${contain_msg}
#    Run Keyword If    '${count}'!='${EMPTY}'    Should Be True    '${act_count}'>='${count}'
#    Run Keyword If    '${count}'=='${EMPTY}'    Should Be True    ${act_count}>0
#
#Collect VDU Container Log
#    ssh.Connect To    hostname=192.168.2.124    username=core    password=system123    alias=sshdu
#    ${cmd}    Catenate    SEPARATER=${SPACE}    kubectl logs --since=1h ute-${NAMESPACE}-oamcm-0 -c
#    ...    ctr-${NAMESPACE}-oamcm -n ${NAMESPACE} > /tmp/oamcm_journal.log
#    ssh.Execute    command=${cmd}    connection=sshdu
#    SSH.Disconnect    connection=sshdu
#    OperatingSystem.Run    scp -i /home/ute/.ssh/id_rsa core@192.168.2.124:/tmp/*journal.log ${TEST_LOG_DIRECTORY}
#
#Collect Snapshot And SosReportLog
#    Collect UTE SosReport    ${TEST_LOG_DIRECTORY}
#    VCU Collect Snapshot    ${TEST_LOG_DIRECTORY}
#    VDU Collect Snapshot    ${TEST_LOG_DIRECTORY}
#
#Collect UTE SosReport
#    [Arguments]    ${log_dir}
#    ${command}    Catenate    sed -i \'s@LOG_DIR_ON_DEVICE=.*@LOG_DIR_ON_DEVICE="/tmp/sosreport"@g\'
#    ...    ${wts_dir}/sosReport.cfg
#    OperatingSystem.Run    ${command}
#    OperatingSystem.Run    cd ${log_dir}/ && ${wts_dir}/sosReport_ASIL/sosReport_ASIL.sh -c -s > /dev/null 2>\&1
#    OperatingSystem.Run    ls ${log_dir}/SosReport*.tgz
#
#Collect VCU Snapshot
#    vcu.Connect To    host=192.168.100.129    port=443    username=Nemuadmin
#    ...    password=nemuuser    secure=True    alias=cu_admin
#    Log To Console    --> start saving vCU Snapshot log
#    vcu.Get Local Snapshot    directory=${TEST_LOG_DIRECTORY}    connection=cu_admin
#    vcu.Disconnect    connection=cu_admin
#
#Collect VDU Snapshot
#    vdu.Connect To    host=192.168.255.129    port=443    username=Nemuadmin
#    ...    password=nemuuser    secure=True    connection_name=du_admin
#    Log To Console    --> start saving vDU Snapshot log
#    vdu.Get Local Snapshot    directory=${TEST_LOG_DIRECTORY}    vdu_connection=du_admin
#    vdu.Disconnect    vdu_connection=du_admin
#
#Clear Env
#    Run Keyword And Ignore Error    SSH.Disconnect    connection=sshcu
#    Run Keyword And Ignore Error    SSH.Disconnect    connection=sshdu
#    Teardown All Aliases For Edaemon
#    Teardown All Aliases For Egate
#    Teardown All Aliases For Wts
#    Run Keyword And Ignore Error    ute_fsmaccess.Teardown All Aliases For Wts_fsmaccess
#
#NSA UE Attach
#    [Arguments]    ${ue_id}    ${gnb_id}=2    ${gnb_cell_id}=1    ${bearer_id}=2
#    NSA LTE Attach    ${ue_id}
#    NSA 5G Attach    ${ue_id}    ${gnb_id}    ${gnb_cell_id}    ${bearer_id}
#    NSA Verify If Attach Passed
#
#NSA LTE Attach
#    [Arguments]    ${ue_id}    ${profile_id}=1
#    [Documentation]    This keyword is used to simulate UE attach on LTE side during NSA L3 Call on eGate.
#    ...    Expected output is: "UE IS ACTIVE" on eGate.
#    ...    | Input Parameters | Man. | Description |
#    ...    | ue_id | Yes | ue id |
#    ...    | profile_id | Yes | profile id |
#    ...    Example:
#    ...    | NSA LTE Attach | 1 | 1 |
#    Log To Console    start LTE attach...
#    ${output}    ute_wtssim.Execute Egate Command    cmd=ue_attach id\=${ue_id}    pass_regexp=UE IS ACTIVE    timeout=30
#    Log To Console    lte_attach_is_ok
#    Sleep    3s    reason=wait LTE attach stable
#    [Return]    ${output}
#
#NSA 5G Attach
#    [Arguments]    ${ue_id}    ${gnb_id}    ${gnb_cell_id}    ${bearer_id}
#    [Documentation]    This keyword is used to simulate UE attach on 5GNR side during NSA L3 Call on eGate.
#    ...    Expected output is: "UE1: Proxy (eNB 2 Cell 2 ) reported successful RA" on eGate.
#    ...    | Input Parameters | Man. | Description |
#    ...    | ue_id | Yes | ue id |
#    ...    | gnb_id | Yes | gnb id |
#    ...    | cell_id | Yes | cell id |
#    ...    | bearer_id | Yes | bearer id |
#    ...    Example:
#    ...    | NSA 5G Attach | 1 | 2 | 2 | 2 |
#    Log To Console    start 5G attach...
#    ${output}=    ute_wtssim.Execute Egate Command    cmd=ue_dc_enb_start ue\=${ue_id} target_gnb\=2 target_cells\=1 bearer\=2 type\=split_scg
#    ...    pass_regexp=reported successful RA|Proxy reported failure    timeout=30
#    ${ret}=    Run Keyword And Return Status    Should Contain    ${output}    reported successful RA
#    Run Keyword If    "${ret}"=="${False}"    Fail    NSA 5G Attach fails!!!
#    Should Be True    ${ret}
#    Log To Console    UE_attach_is_ok
#    Sleep    3s    reason=wait 5G attach is stable
#    [Return]    ${output}
#
#NSA Verify If Attach Passed
#    [Documentation]    varify if 5G attach is passed in APL3.Log
#    Log To Console    varify if 5G attach is passed in APL3.Log...
#    ${succ_msg}    Set Variable    Sm User Ue Connection Established Ind message status OK
##    ${rc}    ${output}    OperatingSystem.Run And Return Rc And Output
##    ...    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.200.129 'cat /tmp/APL3.log | grep -a "${succ_msg}"'
##    Should Contain    ${output}    ${succ_msg}
#
#NSA Start DL Traffic
#    [Arguments]    ${ue_id}    ${bearer_id}    ${mbps}    ${time_len}    ${trf_id}=1
#    [Documentation]    This keyword is to start traffic on eGate.
#    ...    Expected output is: "UE IS ACTIVE" on eGate.
#    ...    | Input Parameters | Man. | Description |
#    ...    | ue_id | Yes | ue id |
#    ...    | bearer_id | Yes | bearer_id |
#    ...    | mbps | Yes | mbps |
#    ...    | trf_id | No | trf_id, default is 1 |
#    ...    Example:
#    ...    | NSA Start DL Traffic | 1 | 2 | 10 |
#    Log To Console    start DL traffic...
#    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${ue_id} id\=${bearer_id} dir\=dl mbps\=${mbps} trf_id\=${trf_id}
#    Sleep    ${time_len}    reason=wait DL traffic is stable
#
#NSA Start UL Traffic
#    [Arguments]    ${ue_id}    ${bearer_id}    ${mbps}    ${time_len}    ${trf_id}=1
#    [Documentation]    This keyword is to start traffic on eGate.
#    ...    Expected output is: "UE IS ACTIVE" on eGate.
#    ...    | Input Parameters | Man. | Description |
#    ...    | ue_id | Yes | ue id |
#    ...    | bearer_id | Yes | bearer_id |
#    ...    | mbps | Yes | mbps |
#    ...    | trf_id | No | trf_id, default is 1 |
#    ...    Example:
#    ...    | NSA Start UL Traffic | 1 | 2 | 10 |
#    Log To Console    start UL traffic...
#    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${ue_id} id\=${bearer_id} dir\=ul mbps\=${mbps} trf_id\=${trf_id}
#    Sleep    ${time_len}    reason=wait UL traffic is stable
#
#NSA Check Average Traffic Range 2 Percent On Target
#    [Arguments]    ${ue_id}    ${bearer_id}    ${dir}    ${tp_check_rate}    ${dc_cell_group}
#    [Documentation]    This keyword is to Check traffic on eGate.
#    ...    | Input Parameters | Man. | Description |
#    ...    | dir | Yes | Direction of Traffic |
#    ...    | tp_check_rate | Yes | Throughput Rate for traffic |
#    ...    Example:
#    ...    | NSA Check Average Traffic range 10 percent on target | 1 | 2 | ul | 10 |
#    ...    | NSA Check Average Traffic range 10 percent on target | 1 | 2 | dl | 10 |
#    ${output}    ute_wtssim.Execute Egate Command    cmd=bearer_stats ue\=${ue_id} id\=2 dir\=${dir} type\=l3 dc_cell_group\=scg
#    ...    pass_regexp=Average packet interval    timeout=10
#    OperatingSystem.Create File    /tmp/${dir}.txt    ${output}
#    ${avg}    OperatingSystem.Run    cat /tmp/${dir}.txt | grep -m 1 'Average data rate' | awk '{print $4}'
#    ${tp_delta}    Evaluate    abs(${tp_check_rate}-${avg}*0.000001)
#    ${tp_threshold}    Evaluate    ${tp_check_rate}*0.02
#    Should Be True    ${tp_delta}<=${tp_threshold}    Throughtput is not in the accetable range
#
#NSA Stop Traffic
#    [Arguments]    ${ue_id}    ${bearer_id}    ${dir}    ${trf_id}=1
#    [Documentation]    This keyword is to stop traffic on eGate.
#    ...    | Input Parameters | Man. | Description |
#    ...    | ue_id | Yes | ue id |
#    ...    | bearer_id | Yes | bearer_id |
#    ...    | dir | Yes | ul or dl |
#    ...    | trf_id | No | trf_id, default is 1 |
#    ...    Example:
#    ...    | NSA Stop Traffic | 1 | 2 | dl |
#    Log To Console    stop ${dir} traffic...\n
#    ute_wtssim.Execute Egate Command    cmd=trf_data_stop ue\=${ue_id} id\=${bearer_id} dir\=${dir} trf_id\=${trf_id}
#
#NSA UE Detach
#    [Arguments]    ${ue_id}    ${bearer_id}=2
#    [Documentation]    This keyword is used to detach ue.
#    ute_wtssim.Execute Egate Command    cmd=ue_detach id\=${ue_id}    pass_regexp=detached
#
#SA UE Attach
#    [Arguments]    ${ue_id}
#    ute_wtssim.Execute Egate Command    cmd=set_pdu_param ue\=${ue_id} pdu\=1 trf_type\=internal
#    ute_wtssim.Execute Egate Command    cmd=ue_register id\=${ue_id}
#    ...    pass_regexp=Received REGISTRATION COMPLETE from UE with RAN UE NGAP ID
#    ute_wtssim.Execute Egate Command    cmd=ue_pdu_session_setup pdu\=1 ue\=${ue_id} nwslice\=1 gw\=1
#    ...    pass_regexp=Initial Context Setup Successful for UE with AMF UE ID
#
#SA Start DL Traffic
#    [Arguments]    ${ue_id}    ${mbps}    ${time_len}    ${trf_id}=1    ${capture_L1L2BIP}=no
#    [Documentation]    This keyword is to start traffic on eGate.
#    ...    Expected output is: "UE IS ACTIVE" on eGate.
#    ...    | Input Parameters | Man. | Description |
#    ...    | ue_id | Yes | ue id |
#    ...    | bearer_id | Yes | bearer_id |
#    ...    | mbps | Yes | mbps |
#    ...    | trf_id | No | trf_id, default is 1 |
#    ...    Example:
#    ...    | NSA Start DL Traffic | 1 | 2 | 10 |
#    Log To Console    start DL traffic...
#    ute_wtssim.Execute Egate Command
#    ...    cmd=trf_data_start ue\=${ue_id} pdu\=1 qfi\=1 dir\=dl mbps\=${mbps} trf_id\=1 protocol\=udp
#    ute_wtssim.Execute Egate Command
#    ...    cmd=trf_data_start ue\=${ue_id} pdu\=1 qfi\=1 dir\=dl mbps\=${mbps} trf_id\=2 protocol\=udp
#    ute_wtssim.Execute Egate Command
#    ...    cmd=trf_data_start ue\=${ue_id} pdu\=1 qfi\=1 dir\=dl mbps\=${mbps} trf_id\=3 protocol\=udp
#    ute_wtssim.Execute Egate Command
#    ...    cmd=trf_data_start ue\=${ue_id} pdu\=1 qfi\=1 dir\=dl mbps\=${mbps} trf_id\=4 protocol\=udp
#    Sleep    ${time_len}    reason=wait DL traffic is stable
#
#SA Start UL Traffic
#    [Arguments]    ${ue_id}    ${mbps}    ${time_len}    ${trf_id}=1
#    [Documentation]    This keyword is to start traffic on eGate.
#    ...    Expected output is: "UE IS ACTIVE" on eGate.
#    ...    | Input Parameters | Man. | Description |
#    ...    | ue_id | Yes | ue id |
#    ...    | bearer_id | Yes | bearer_id |
#    ...    | mbps | Yes | mbps |
#    ...    | trf_id | No | trf_id, default is 1 |
#    ...    Example:
#    ...    | NSA Start UL Traffic | 1 | 2 | 10 |
#    Log To Console    start UL traffic...
#    ute_wtssim.Execute Egate Command   cmd=trf_data_start ue\=${ue_id} pdu\=1 qfi\=1 dir\=ul mbps\=${mbps} trf_id\=${trf_id} protocol\=udp
#    Sleep    ${time_len}    reason=wait UL traffic is stable
#
#SA Check Average Traffic Range 2 Percent On Target
#    [Arguments]    ${ue_id}    ${dir}    ${tp_check_rate}
#    [Documentation]    This keyword is to Check traffic on eGate.
#    ...    | Input Parameters | Man. | Description |
#    ...    | dir | Yes | Direction of Traffic |
#    ...    | tp_check_rate | Yes | Throughput Rate for traffic |
#    ...    Example:
#    ...    | NSA Check Average Traffic range 10 percent on target | 1 | 2 | ul | 10 |
#    ...    | NSA Check Average Traffic range 10 percent on target | 1 | 2 | dl | 10 |
#    ${output}    ute_wtssim.Execute Egate Command    cmd=qfi_stats ue\=${ue_id} pdu\=1 qfi\=1 dir\=${dir}
#    ...    pass_regexp=Average packet interval    timeout=10
#    OperatingSystem.Create File    /tmp/${dir}.txt    ${output}
#    ${avg}    OperatingSystem.Run    cat /tmp/${dir}.txt | grep -m 1 'Average data rate' | awk '{print $4}'
#    ${tp_delta}    Evaluate    abs(${tp_check_rate}-${avg}*0.000001)
#    ${tp_threshold}    Evaluate    ${tp_check_rate}*0.02
#    Should Be True    ${tp_delta}<${tp_threshold}    Throughtput is not in the accetable range
#
#SA Stop Traffic
#    [Arguments]    ${ue_id}    ${dir}
#    [Documentation]    This keyword is to stop traffic on eGate.
#    ...    | Input Parameters | Man. | Description |
#    ...    | ue_id | Yes | ue id |
#    ...    | bearer_id | Yes | bearer_id |
#    ...    | dir | Yes | ul or dl |
#    ...    | trf_id | No | trf_id, default is 1 |
#    ...    Example:
#    ...    | NSA Stop Traffic | 1 | 2 | dl |
#    Log To Console    stop ${dir} traffic...\n
#    ute_wtssim.Execute Egate Command    cmd=trf_data_stop ue\=${ue_id} pdu\=1 qfi\=1 dir\=${dir}
#
#SA UE Detach
#    [Arguments]    ${ue_id}
#    [Documentation]    This keyword is used to detach ue.
#    ute_wtssim.Execute Egate Command    cmd=ue_pdu_session_release ue\=${ue_id} pdu\=1
#    ...    pass_regexp=RemovePduSession]::Successfully released PDU Session with ID
#    ute_wtssim.Execute Egate Command    cmd=ue_deregister id\=${ue_id} ue_deregister_type\=switch_off by\=ue
#    ...    pass_regexp=detached
#
#Obtain And Check VDU PM Counter
#    [Arguments]    ${PM_counter_id}    ${check_value}
#    ${counter_value}=    Get VDU Counter Value    counter_id=${PM_counter_id}
#    Run Keyword And Continue On Failure    Should Be True    ${counter_value}${check_value}
#
#Get VDU Counter Value
#    [Arguments]    ${PM_counter_id}
#
#VCU Get PM Counter Value
#    [Arguments]    ${counter_id}    ${dimension_dn}    ${measurement_id}=None
#    [Documentation]    This keyword is to get the latest value for a vCU counter
#    ...
#    ...    | Input Parameters | Man. | Description |
#    ...    | ${counter_id} | yes | the counter id, e.g.M55115C00002 |
#    ...    | ${dimension_dn} | yes | the dimension dist name that the counter belongs to,
#    ...    | e.g.MRBTS-1111/NRBTS-1111/NRCELL-1 |
#    ...    | ${measurement_id} | No | the measurement id, e.g.55115 ,the default value is None|
#    ...
#    ...    Examples:
#    ...    |    |    |    |
#    VCU Login
#    # ${counter_info}    vcu.Get Counter_info    counter_id=M55112C00002    measurement_id=55112
#    ${counter}    vcu.Get Counter    measurement_id=${measurement_id}    dimension_dist_name=${dimension_dn}
#    ...    counter_id=${counter_id}
#    ${counter_values}    Get From Dictionary    ${counter}    values
#    ${counter_value}    Get From Dictionary    ${counter_values[-1]}    value
#    Log To Console    The latest value for counter '${counter_id}': ${counter_value}
#    [Teardown]    Run Keyword And Ignore Error    VCU Logout
#    [Return]    ${counter_value}
