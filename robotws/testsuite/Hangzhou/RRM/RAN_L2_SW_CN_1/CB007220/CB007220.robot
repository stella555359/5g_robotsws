*** Settings ***
Documentation    ...
#Library            taf.transport.ssh    WITH NAME    csn
#Resource           ./../CUDU_L2/common_setup_teardown.robot
#Resource           ./../CB006137/CB006137_resource.robot
#Suite Setup        Common Suite Setup
#Test Setup         Common Test Setup 2
#Test Teardown      Common Test Teardown 2
#Suite Teardown     Common Suite Teardown 2
#Force Tags         CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    SBTS00    SBTS23R1    SBTS22R4    CN1_SQ
#...                RAN_5G    RAN_5G_TDD    CRT    CN1_SG09_SM3
#
#*** Variables ***
#${UE_ID}                    11
#${UE_ID_SA}                 1
#${PROFILE_ID}               1
#${GNB_ID}                   2
#${CELL_ID}                  1
#${BEARER_ID}                2
#${Egatelog_path}            ${CURDIR}
#${SCF_DIR}                  ${CURDIR}/config
#${LOCAL_IPHY_DIR}           ${CURDIR}/config
#${LOCAL_WTS_DIR}            ${CURDIR}/config
#${WTS_DIR}                  /opt/iphy/latest
#${WTS_CFG}                  basic_setup.cfg
#${7220_SCF}                 SCF_7220.xml
#${iphy}                     iphy_2T.xml
#${A10_rd_flag}              0x590004=4;0x5900a8=1;0x58057C=0xFFFFFFFF
#${A12_rd_flag}              0x590004=4;0x5900a8=1;0x58057C=0xFFFFFFFF;0x580431=0
#${C08_rd_flag}              0x590004=4;0x5900a8=1;0x58057C=0xFFFFFFFF;0x580431=1;0x5900D4=2;0x580385=0;0x580422=1;0x580384=0x2;0x58041e=0x0;
#...                         0x58041f=0x28;0x580420=0x28
#${dl_tp_set}                100
#@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}
#
#*** Test Cases ***
#CB007220-ET-A012-Verify A CSI with zeropadding from single UE without UE capability limitation without UL traffic on NSA call during HO process
#    [Documentation]
#    ...   Precondition:  2200 + A-CSI enabling + FS1208
#    ...   RD parameter ${A12_rd_flag} is already set in 'Common Suite Setup', will no be set in 'Setup TL for Case'
#    ...   Test Steps:
#    ...   # Step1: UE attach to NSA cell50
#    ...   # Step2: Start DL traffic
#    ...   # Step3: Trigger intra_freq_intra_gnb HO process from cell50 to cell51
#    ...   # Step4: Check A-CSI from egate log
#    ...   # Step5: Chek A-CSI from TtiTrace
#    ...   Check point
#    ...   rd parameter:0x590004=4          # rdDlMimoLayerCapabilityRadParam
#    ...                0x5900a8=1          # N1N2=2x2
#    ...                0x58057C=0xFFFFFFFF # for ACSI logging
#    ...                0x580431=0          # rdUciOnly
#    [Tags]     caseA012    Manual_krihu    TA_krihu
#    [Setup]    Setup TL For Case
#    Start UTE WTS And Check Cell Setup    ${WTS_CFG}
#    # Step1: UE attach to NSA cell50
#    Attach NSA UE
#    # Step2: Start DL traffic
#    NSA Start DL Traffic and Get Throughput
#    # Step3: Check A-CSI from egate log
#    Check ACSI Info From Egate Log
#    # Step4: Trigger intra_freq_intra_gnb HO process from cell50 to cell51
#    Capture And Decode TTitrace During HO Process    A012
#    # Step5: Chek A-CSI from TtiTrace
#    Check ACSI From TTI    ttitrace_A012.ini    ${TEST_LOG_DIRECTORY}/ttitrace/A012
#
#CB007220-ET-A010-Verify A CSI reporting with zero-padding from single UE with UE capability limitation without UL traffic with DRX enabled on NSA
#    [Documentation]
#    ...   Precondition:  2200 + A-CSI enabling + FS1070 + DRX enabling
#    ...   Test Steps:
#    ...   # Step1: UE attach to NSA cell50
#    ...   # Step2: Start DL traffic
#    ...   # Step3: Check A-CSI from egate log
#    ...   # Step4: Chek A-CSI from TtiTrace
#    ...   Check point
#    ...   rd parameter:0x590004=4          # rdDlMimoLayerCapabilityRadParam
#    ...                0x5900a8=1          # N1N2=2x2
#    ...                0x58057C=0xFFFFFFFF # for ACSI logging
#    [Tags]     caseA010    Manual_AnneY    TA_AnneY
#    [Setup]    Setup TL For Case    ${A10_rd_flag}
#    ${json_file}=    Change Delta XML File To Delta Json File    ${SCF_DIR}/Delta_A010.xml
#    Delta Commission With SCF File    ${json_file}
#    Reboot TL And Check Configured
#    Start UTE WTS And Check Cell Setup    ${WTS_CFG}
#    # Step1: UE attach to NSA cell50
#    Attach NSA UE
#    # Step2: Start DL traffic
#    NSA Start DL Traffic and Get Throughput
#    # Step3: Check A-CSI from egate log
#    Check ACSI Info From Egate Log
#    # Step4: Chek A-CSI from TtiTrace
#    Capture And Decode TTitrace    A010
#    Check ACSI From TTI    ttitrace_A010.ini    ${TEST_LOG_DIRECTORY}/ttitrace/A010
#
#CB007220-ET-C008-Verify A Periodic CSI reporting with UCIOnly and DynamiicOffset = enableFull from SingleUE on SA call
#    [Documentation]
#    ...   Precondition:  2200 + A-CSI enabling + FS1116
#    ...   Test Steps:
#    ...   # Step1: UE attach to SA cell50
#    ...   # Step2: Start low DL traffic
#    ...   # Step3: Check A-CSI from egate log
#    ...   # Step4: Start CQI change with AP testmode
#    ...   # Step5: Chek A-CSI from TtiTrace
#    ...   Check point
#    ...   rd parameter:0x590004=4          # rdDlMimoLayerCapabilityRadParam00
#    ...                0x5900a8=1          # N1N2=2x2
#    ...                0x58057C=0xFFFFFFFF # for ACSI logging
#    ...                0x580431=1          # rdUciOnly is default true
#    ...                0x5900D4=2          # rdEnableDynamicBetaOffsets is default enableFull
#    ...                0x580385=0          # rdEnableBetaOffsetOptimistic is default false
#    ...                0x580422=1          #rdACsiCheckDlLoad
#    ...                0x580384=0x2        #rdBetaOffsetModeratePayloadSizeThr
#    ...                0x58041e=0x0        #rdACsiCqiDeltaThreshold
#    ...                0x58041f=0x28       #rdAcsiCqiJitterTimer
#    ...                0x580420=0x28       #rdAcsiHighThroughputJitterTimer
#    [Tags]     caseC008    Manual_faxia    TA_faxia
#    [Setup]    Setup TL For Case    ${C08_rd_flag}
#    ${json_file}=    Change Delta XML File To Delta Json File    ${SCF_DIR}/Delta_C008.xml
#    Delta Commission With SCF File    ${json_file}
#    Reboot TL And Check Configured
#    Start UTE WTS And Check Cell Setup for SA    ${WTS_CFG}
#    # Step1: UE attach to SA cell50
#    Attach SA UE
#    # Step2: Start low DL traffic
#    SA Start DL Traffic and Get Throughput
#    # Step3: Check A-CSI from egate log
#    Check ACSI Info From Egate Log
#    # Step4: Start CQI change with AP testmode
#    Capture And Decode TTitrace afte CQI change    C008
#    # Step5: Chek A-CSI from TtiTrace
#    Check ACSI From TTI    ttitrace_C008.ini    ${TEST_LOG_DIRECTORY}/ttitrace/C008
#
#*** Keywords ***
#Common Suite Setup
#    Suite Setup Update GNB    log=${False}
#    OperatingSystem.Run    cp ${local_wts_dir}/${WTS_CFG} ${WTS_DIR}
#    Wait Until Keyword Succeeds    5s    1s    OperatingSystem.File Should Exist    ${WTS_DIR}/${WTS_CFG}
#    Modify UTE SCTP Timeout
#    Modify AP SCTP Timeout
#    Configure UTE ETH3
#    Modify IPHY File And Send to Airphone    ${LOCAL_IPHY_DIR}/${iphy}
#    Add RD Parameters To GNB Swconfig File        ${A12_rd_flag}
#    Full Commission With SCF File    ${7220_SCF}
#    Sleep    120s    wait testline can reboot stable.
#    Reboot TL And Check Configured
#
#Capture And Decode TTitrace
#    [Arguments]    ${logpath}
#    Start Ttitrace With Streaming Mode
#    Sleep    3s    reason=Wait for log collection...
#    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/${logpath}
#    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/${logpath}
#
#Capture And Decode TTitrace afte CQI change
#    [Arguments]    ${logpath}
#    Start Ttitrace With Streaming Mode
#    Sleep    3s    reason=Wait for log collection start...
#    Change CQI For UCIonly SA
#    Sleep    3s    reason=Wait for log collection end...
#    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/${logpath}
#    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/${logpath}
#
#Capture And Decode TTitrace During HO Process
#    [Arguments]    ${logpath}
#    Start Ttitrace With Streaming Mode
#    Sleep    2s    reason=Wait for log collection...
#    Triggered HO Process
#    Sleep    2s    reason=Wait for log collection...
#    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/${logpath}
#    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/${logpath}
#
#Check ACSI From TTI
#    [Arguments]    ${ini_name}    ${csv_file_path}
#    A2A_Check_CSV_Table    ${CURDIR}/A2A/${ini_name}    output_ul.csv    ${csv_file_path}
#
#Check ACSI Info From Egate Log
#    Log To Console    \nStart check A-CSI info from egate log.\n
#    ${reportQuantity}    Set Variable    reportQuantity cri-RI-LI-PMI-CQI
#    ${config_id}         Set Variable    reportConfigId 1
#    ${trigger_size}      Set Variable    reportTriggerSize 1
#    ${Config_Type}       Set Variable    reportConfigType aperiodic
#    ${check_rst1}    Run    cat /opt/wts/latest/egate_console.log.001|grep -i "${reportQuantity}"|wc -l
#    ${check_rst2}    Run    cat /opt/wts/latest/egate_console.log.001|grep -i "${config_id}"|wc -l
#    ${check_rst3}    Run    cat /opt/wts/latest/egate_console.log.001|grep -i "${trigger_size}"|wc -l
#    ${check_rst4}    Run    cat /opt/wts/latest/egate_console.log.001|grep -i "${Config_Type}"|wc -l
#    Should Be True    ${check_rst1}>=2
#    Should Be True    ${check_rst2}>=2
#    Should Be True    ${check_rst3}>=1
#    Should Be True    ${check_rst4}>=1
#
#Attach NSA UE
#    [Arguments]    ${UE_ID}=11
#    NSA LTE Attach    ue_id=${UE_ID}    profile_id=1
#    NSA 5G Attach    ue_id=${UE_ID}    gnb_id=2    cell_id=1    bearer_id=2
#
#NSA Start DL Traffic and Get Throughput
#    [Arguments]    ${UE_ID}=11    ${dl_tp_set}=500    ${dl_tp_threshold}=450
#    NSA Start DL Traffic    ue_id=${UE_ID}    bearer_id=2    mbps=${dl_tp_set}    trf_id=1
#    Wait Until Keyword Succeeds    3min    5s    NSA UE Check DL Throughput    ${UE_ID}    ${dl_tp_threshold}
#
#NSA UE Check DL Throughput
#    [Arguments]    ${UE_ID}=11    ${dl_tp_threshold}=90
#    ${dl_tp}=    NSA Get UE Average Traffic    ue_id=${UE_ID}    bearer_id=2    dir=dl
#    ${ul_tp}=    NSA Get UE Average Traffic    ue_id=${UE_ID}    bearer_id=2    dir=ul
#    log    DL Troughput is ${dl_tp}    console=True
#    log    UL Troughput is ${ul_tp}    console=True
#    ${tp_delta}    Evaluate    ${dl_tp}-${dl_tp_threshold}
#    Should Be True    ${tp_delta}>=0    Throughtput is not in the accetable range
#    Log To Console    The TPUT is bigger than target: ${dl_tp_threshold}M \n
#
#Triggered HO Process
#    ${command}    Set Variable    ue_measurement_send_nr id\=${UE_ID} meas_id=1 event=A3 srsrp_nr=10 phycell_id=51 nrsrp_nr=40
#    ute_wtssim.Execute Egate Command And Wait For Data
#    ...    cmd=${command}
#    ...    pass_regexp=reported successful RA
#    ...    timeout=3min
#
#Setup TL For Case
#    [Arguments]    ${swconfig_rd_flag}=${EMPTY}
#    Verify Coam Site Is Ready
#    Create Test Directory
#    Run Keyword If    "${swconfig_rd_flag}"!="${EMPTY}"    Add RD Parameters To GNB Swconfig File        ${swconfig_rd_flag}
#    Start GNB AP Syslog    ${TEST_LOG_DIRECTORY}
#
#Attach SA UE
#    [Arguments]    ${UE_ID}=1
#    SA 5G Attach    ue_id=${UE_ID_SA}
#    SA Set Traffic Type To Internal    ue_id=${UE_ID_SA}   pdu_id=1
#    SA 5G PDU Session Setup    ue_id=${UE_ID_SA}
#
#SA Start DL Traffic and Get Throughput
#    [Arguments]    ${UE_ID}=1    ${dl_tp_set}=5    ${dl_tp_threshold}=4
#    SA Start DL Traffic Internal  ue_id=${UE_ID_SA}   pdu_id=1    mbps=5    trf_id=1
#    SA Check UE Cell TPut On Target   ue_id=${UE_ID_SA}   pdu_id=1  dir=dl    target_tput=${dl_tp_threshold}    qfi=1
#
#Start UTE WTS And Check Cell Setup for SA
#    [Documentation]    This keyword is to kill Running WTS Binaries,start edaemon, egate and clean log files.
#    [Arguments]    ${local_wts_cfg}    ${enb_id}=1    ${target_id}=2
#    Log To Console    \nStarting WTS...
#    Run Keyword And Ignore Error    Stop Edaemon Egate
#    ute_wtssim.Setup Edaemon    edaemon_port=22222    tool_dir=${WTS_DIR}    alias=edaemon
#    ute_wtssim.Start Edaemon Process    alias=edaemon
#    ute_wtssim.Setup Egate    egate_port=20000    tool_dir=${WTS_DIR}    save_egate=${True}
#    ute_wtssim.Start Egate Process
#    OperatingSystem.Run    sudo rm -rf ${WTS_DIR}/*.log*
#    ute_wtssim.Execute Egate Command    cfg file\=${WTS_DIR}/${local_wts_cfg}
#    ...    pass_regexp=SystemInformationBlockType4-NR updated    timeout=5min
#    Check All Cells Received SIB2
#    Verify Cell Setup
#
#Change CQI For UCIonly SA
#    Log To Console    Change CQI ...
#    ${prepare_1}    Set Variable
#    ...    csi_override_testmode_nr profile_id=2 cqi=15 cqi_mode=oneway cqi_min=4 cqi_max=15 cqi_step=-1 cqi_period=32
#    ${prepare_2}    Set Variable
#    ...    ue_testmode_set_nr id=1 testmode=csi_override profile_id=2 action=activate
#    ute_wtssim.Execute Egate Command    ${prepare_1}
#    ute_wtssim.Execute Egate Command    ${prepare_2}
