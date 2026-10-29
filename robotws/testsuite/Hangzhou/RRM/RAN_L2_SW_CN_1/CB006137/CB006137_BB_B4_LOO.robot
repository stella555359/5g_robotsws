*** Settings ***
Documentation    ...
#Resource           ./CB006137_resource.robot
#Resource           ./resources/CB006137_BB_resource.robot
#Resource           ./../CUDU_L2/common_setup_teardown.robot
#Suite Setup        CB006137_BB_resource.Common Suite Setup 2
#Test Teardown      Run Keywords    Send Swconfig for GNB    ${gnb_swconfig}
#...                AND    Common Test Teardown 2
#Suite Teardown     Common Suite Teardown 2
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    CRT    RAN_5G_TDD    RAN_5G
#...               SBTS00    CN1_SG09_SM1    CB006137
#
#*** Variables ***
#${SCF_PATH}                 ${CURDIR}/config/SCF
#${LOCAL_WTS_DIR}            ${CURDIR}/config/WTS/
#${WTS_DIR}                  /opt/iphy/latest
#${6137_BB039_SCF}           ${SCF_PATH}/CB006137_BB039_LOO.xml
#${6137_BB042_SCF}           ${SCF_PATH}/CB006137_BB042_LOO.xml
#${6137_BB040_SCF}           ${SCF_PATH}/CB006137_BB040_LOO.xml
#${6137_BB047_SCF}           ${SCF_PATH}/CB006137_BB047_LOO.xml
#${IPHY_2F_2T}               ${CURDIR}/config/WTS/iphy_2F_2T_LOO.xml
#${IPHY_2F_2T_BB042}         ${CURDIR}/config/WTS/iphy_2F_2T_BB042_LOO.xml
#${IPHY_2F_2T_LOO_B047}      ${CURDIR}/config/WTS/iphy_2F_2T_LOO_B047.xml
#${IPHY_B043}               ${CURDIR}/config/WTS/iphy_B043.xml
#${6137_BB043_SCF}           ${SCF_PATH}/CB006137_BB043.xml
#${SWCONFIG_PARAM_BB039}     0x58057F=16;0x580641=1;0x4B000F=1;0x58057a=3
#${SWCONFIG_BB042}           0x58057F=16;0x580641=1;0x4B000F=1;0x58057a=3;0x590105=1
#${SWCONFIG_PARAM_BB043}     0x3F007C=1024
#${SWCONFIG_PARAM_AP}        0x70690=1;
#${WTS_CFG_BB039}            CB006137_BB039_LOO.cfg
#${WTS_CFG_BB042}            CB006137_BB042_LOO.cfg
#${WTS_CFG_BB040}            CB006137_BB040.cfg
#${WTS_CFG_BB047}            CB006137_BB047.cfg
#${WTS_CFG_BB043}            CB006137_BB043.cfg
#${WTS_AP_XML}               airphone.xml
#${gnb_swconfig}             /home/ute/.ute-ca/executions/1/configs/topology_configs/SANSA_FS_ECPRI_CMWV_FDD+TDD/swconfig_gnb.txt
#${UE_ID}                    1
#${4CC_2F2T_SCELL}           ('1', '50', '71'), ('2', '60', '77'), ('3', '61', '41')
#${4CC_2F2T_SCELL_B043}      ('1', '50', '71'), ('2', '60', '78'), ('3', '61', '78')
#&{GNB_ASIK}                 ip=192.168.255.1    username=toor4nsn    password=oZPS0POrRieRtu    connection=GnbAsik
#
#
#*** Test Cases ***
#CB006137-ET-BB039_UL_CA_with_dynamic_power_sharing_and_SRS_enable
#    [Tags]     caseBB039    haiyliu    Owner_haiyliu
#    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG_BB039}
#    ...        AND    Suite Setup Update GNB    scf_file=${6137_BB039_SCF}    iphy_file=${IPHY_2F_2T}    swconfig_param=${SWCONFIG_PARAM_BB039}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Start UTE WTS And Check Cell Setup    ${wts_cfg}    enb_id=1    target_id=2
#    ...        AND    Common Test Setup 2
#    L3 Call And Check
#    #Trigger Low PHR And Check    3    0    ${UE_ID}
#    #Recover Default PHR And Check    3    0    ${UE_ID}
#    SA Stop Data Traffic Internal    ${UE_ID}    pdu_id=1
#    SA 5G Detach    ${UE_ID}
#
##CB006137-ET-BB042_UL_CA_call_with_SRS_based_DL_beamforming_using_UE_specific_CSI-RS
##    [Tags]     caseBB042    Owner_lilidong
##    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG_BB042}
##    ...        AND    Suite Setup Update GNB    scf_file=${6137_BB042_SCF}    iphy_file=${IPHY_2F_2T_BB042}    swconfig_param=${SWCONFIG_BB042}
##    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
##    ...        AND    Start UTE WTS And Check Cell Setup    ${wts_cfg}    enb_id=1    target_id=2
##    ...        AND    Common Test Setup 2
##    L3 Call and Traffic
##    Capture And Decode TTitrace    log_id=1
##    Start Gnb BIP Log
##    Sleep    1s    reason=Wait for traffic stable
##    Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY}/BIP/1
##    Common Checkpoints For B4    ${TEST_LOG_DIRECTORY}/ttitrace/1    BIP/1    52    ttitrace_12Symbols.ini
#    #Check PatternID From Wirshark    /BIP/1    61
#    #${savepoint1} =  Capture savepoint  alias=${GNB_SYSLOG.alias}
#    #Simulate Bad Rlq To Trigger Scell Suspend And Check BB042
#    #Start Ttitrace With Streaming Mode
#    #Recover PHR For BB042
#    #Wait For Message In Syslog File    regexp=scell rlq turn to good    timeout=80    alias=${GNB_SYSLOG.alias}
#    #Collect from savepoint    savepoint=${savepoint1}    destination_file=${TEST_LOG_DIRECTORY}/syslog1    alias=${GNB_SYSLOG.alias}
#    #Sleep    2s    reason=Wait for log
#    #Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/3
#    #Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/3
#    #Capture BIP Log    BIP/3    3
#    #Checkpoings After Recover PHR For BB042
##    SA Stop Data Traffic Internal    ${UE_ID}    pdu_id=1
##    SA 5G Detach    ${UE_ID}
#
##CB006137-ET-BB040_UL_CA_call__with_SRS__enable_with_frame_structure_5GC001208
##    [Tags]     caseBB040    YueRong    Owner_YueRong
##    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG_BB040}
###    ...        AND    Send L1ByPTestModeConfiguration File To Airphone    ${L1BYPTESTMODECONFIG_PATH}
##    ...        AND    Suite Setup Update GNB    scf_file=${6137_BB040_SCF}    iphy_file=${IPHY_2F_2T}    swconfig_param=${SWCONFIG_PARAM_BB039}
##    ...    swconfig_param_AP=${SWCONFIG_PARAM_AP}
##    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
##    ...        AND    Start UTE WTS And Check Cell Setup    ${wts_cfg}    enb_id=1    target_id=2
##    ...        AND    Common Test Setup 2
##    L3 Call and Traffic     dl_tput=0    ul_tput=200    check_dl_tput=0
##    Capture And Decode TTItrace    log_id=1
##    Start Gnb BIP Log
##    Sleep    1s
##    Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY}/BIP/1
##    Check UL DTXCRC Rate    ${TEST_LOG_DIRECTORY}/ttitrace/1
##    Check DL DTXNACK Rate    ${TEST_LOG_DIRECTORY}/ttitrace/1
##    Check Srsreceivereq With A2A_B40    BIP/1
##    Check overlap Symbols From Wirshark    /BIP/1    52    12
##    SA Stop Data Traffic Internal    ${UE_ID}    pdu_id=1
##    SA 5G Detach    ${UE_ID}
#
##CB006137-ET-BB047_Cell_specific_CSI-RS_for_UL_CA_call_with_dynamic_power_sharing
##    [Tags]     caseBB047
##    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG_BB047}
###    ...        AND    Send L1ByPTestModeConfiguration File To Airphone    ${L1BYPTESTMODECONFIG_PATH}
##    ...        AND    Suite Setup Update GNB    scf_file=${6137_BB047_SCF}    iphy_file=${IPHY_2F_2T_LOO_B047}
##    ...    swconfig_param=${SWCONFIG_PARAM_BB039}    swconfig_param_AP=${SWCONFIG_PARAM_AP}
##    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
##    ...        AND    Start UTE WTS And Check Cell Setup    ${wts_cfg}    enb_id=1    target_id=2
##    ...        AND    Common Test Setup 2
##    L3 Call and Traffic
##    Check For BB047
##    SA Stop Data Traffic Internal    ${UE_ID}    pdu_id=1
##    SA 5G Detach    ${UE_ID}
#
##CB006137-ET-BB043_UL_CA_call_with_SRS_based_DL_beamforming_using_cell_specific_CSI-RS
##    [Tags]     caseBB043     Owner_lading
##    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG_BB043}
###    ...        AND    Send L1ByPTestModeConfiguration File To Airphone    ${L1BYPTESTMODECONFIG_PATH}
##    ...        AND    Suite Setup Update GNB    scf_file=${6137_BB043_SCF}    iphy_file=${IPHY_B043}    swconfig_param=${SWCONFIG_PARAM_BB043}
##    ...    swconfig_param_AP=${SWCONFIG_PARAM_AP}
##    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
##    ...        AND    Start UTE WTS And Check Cell Setup    ${wts_cfg}    enb_id=1    target_id=2
##    ...        AND    Common Test Setup 2
##    L3 Call and Traffic For 43
##    Start Gnb BIP Log
##    Sleep    2s
##    Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY}/BIP/1
##    Capture And Decode TTItrace
##    SA Stop Data Traffic Internal    ${UE_ID}    pdu_id=1
##    SA 5G Detach    ${UE_ID}
##    Check UL DTXCRC Rate    ${TEST_LOG_DIRECTORY}/ttitrace/1
##    Check DL DTXNACK Rate    ${TEST_LOG_DIRECTORY}/ttitrace/1
##    Check PatternID From Wirshark for BB043    BIP/1    61    1762,1843,0,0
##    Check Srsreceivereq With A2A    BIP/1    ttitrace_srsreceivereqBB043.ini
##    Check overlap Symbols With A2A    BIP/1    52    ttitrace_13Symbols_BB043.ini
##    Convert BIP To CSV By MCShark For UL Scheduled Slots    BIP/1    52
##    Check Pcell Ul Scheduled On All Slots
##    Convert BIP To CSV By MCShark For UL Scheduled Slots    BIP/1    61
##    Check Scell Ul Scheduled On Overlap Slots
##    Check Fail Ratio Of CsiReport    ${TEST_LOG_DIRECTORY}/ttitrace/1
#
#*** Keywords ***
#Common Checkpoints For B4
#    [Arguments]    ${tti_log_path}    ${bip_log_path}    ${phycell_id}    ${csv_file}
#    Check UL DTXCRC Rate    ${tti_log_path}
#    Check DL DTXNACK Rate    ${tti_log_path}
#    Check Srsreceivereq With A2A    ${bip_log_path}
#    Check overlap Symbols With A2A    ${bip_log_path}    ${phycell_id}    ${csv_file}
#
#Check Scell Rlq For BB042
#    [Arguments]    ${tti_log_path}
#    #[Arguments]    ${syslog_name}    ${tti_log_path}
#    #${bad_rlq}    Set Variable    scell rlq turn to bad
#    #${good_rlq}    Set Variable    scell rlq turn to good
#    #${rst_bad}    Run    cat ${TEST_LOG_DIRECTORY}/${syslog_name}|grep -i "${bad_rlq}"|wc -l
#    #${rst_good}    Run    cat ${TEST_LOG_DIRECTORY}/${syslog_name}|grep -i "${good_rlq}"|wc -l
#    #Should Be True    ${rst_bad} == 1
#    #Should Be True    ${rst_good} == 1
#
#    ${pCellBuffer}=    TTITRACEANALYZER.FiLter Source Column Return Other    ${tti_log_path}/output_ul.csv
#    ...    bufferSplitForFr1UlCa.bufferSplitTrigger    ["12.0"]    include    bufferSplitForFr1UlCa.pCellBufferSplitRslt    yes
#    ${sCellBuffer}=    TTITRACEANALYZER.FiLter Source Column Return Other    ${tti_log_path}/output_ul.csv
#    ...    bufferSplitForFr1UlCa.bufferSplitTrigger    ["12.0"]    include    bufferSplitForFr1UlCa.sCellBufferSplitRslt    yes
#    ${rate}    Evaluate    float(${pCellBuffer[-1]})/(${sCellBuffer[-1]})
#    Log To Console    \n rate is ${rate}\n
#    Should Be True    ${rate}<9.1
#    Should Be True    ${rate}>8.9
#
#Simulate Bad Rlq To Trigger Scell Suspend And Check BB042
#    Trigger PHR To GNB    profile_id=1    phr_start=3     ue_id=1    cell_id=0
#    Trigger PHR To GNB    profile_id=2    phr_start=9     ue_id=1    cell_id=3
#    Trigger BLER To GNB    ue_id=1    cell_id=3
#    sleep   10s    reason=Wait for Traffic decrease
#    Capture And Decode TTitrace    log_id=2
#    Capture BIP Log    BIP/2
#    Common Checkpoints For B4    ${TEST_LOG_DIRECTORY}/ttitrace/2    BIP/2    52    ttitrace_12Symbols.ini
#
#Recover PHR For BB042
#    Trigger PHR To GNB    profile_id=1    phr_start=38    ue_id=1    cell_id=0
#    Trigger PHR To GNB    profile_id=2    phr_start=38    ue_id=1    cell_id=3
#    Send Action To GNB    ue_id=1    testmode=bler    action=deactivate    profile_id=30    scell=3
#
#Checkpoings After Recover PHR For BB042
#    #Check UL TP On Target    ${UE_ID}    0    3    90
#    #Check DL TP On Target    ${UE_ID}    0    1-3    550
#    Common Checkpoints For B4    ${TEST_LOG_DIRECTORY}/ttitrace/3    BIP/3    52    ttitrace_12Symbols.ini
#    Check PatternID From Wirshark    /BIP/3    61
#    #Check Scell Rlq For BB042    syslog1    ${TEST_LOG_DIRECTORY}/ttitrace/3
#
#L3 Call and Traffic For 43
#    [Arguments]    ${ue_Id}=${UE_ID}    ${scell_info}=${4CC_2F2T_SCELL_B043}    ${dl_tput}=400    ${ul_tput}=160
#    SA Attach    ${UE_ID}
#    Scell Addition Triggered By A1 Event    ${UE_ID}    1    120
#    Get And Check Scell Infos    ${scell_info}
#    Start SA UL Big Traffic Internal    ${ue_Id}    ${ul_tput}
#    Start SA DL Big Traffic Internal    ${ue_Id}    ${dl_tput}
#    Sleep    10s    reason=Wait for logs
#    Check UL TP On Target    ${UE_ID}    0    3    69
#    Check DL TP On Target    ${UE_ID}    0    1-3    300
#
