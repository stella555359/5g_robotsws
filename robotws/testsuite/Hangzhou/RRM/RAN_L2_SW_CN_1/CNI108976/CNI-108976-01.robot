*** Settings ***
Documentation    ...
#Documentation
#Resource    ./../CUDU_L2/common_setup_teardown.robot
#Resource    ./../CUDU_L2/common_SA_ue_command.robot
#Resource    ./../CUDU_L2/common_admin.robot
#Test Teardown    Common Test Teardown 2
#Suite Teardown    Common Suite Teardown 2
#Force Tags         CLOUD_5G_I_LPQ_AP_LOO    SBTS00    Pz4_12
#...                RAN_5G    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD    CRT
#
#*** Variables ***
#${UE1_ID}               1
#${UE2_ID}               2
#${PDU_ID}              1
#${Egatelog_path}       ${CURDIR}
#${LOCAL_WTS_DIR}       ${CURDIR}/config
#${SCF_DIR}             ${CURDIR}/config
#${IPHY_01}            ${LOCAL_WTS_DIR}/iphy_108976.xml
#${SCF_01}             ${SCF_DIR}/SCF_CNI-108976-01.xml
#${WTS_CFG_01}         basic_setup_108976.cfg
#${RD}                 0x4B000F=1;0x590072=1;0x580876=35;0x580877=30
#${force_reboot}        ${True}
#@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}
#
#*** Test Cases ***
#CNI-108976-01_Verify_new_UL_SINR_metric_used_for_TP_switch_procedure_with_CNI-108976_enabled
#    [Documentation]
#    ...    Precondition:
#    ...      Single FDD SA cell is up and running.
#    ...      Feature 5G000545 is active (NRCELL.actUlDftSOfdm=true)
#    ...      NRCELL.ulTransPrecodeCtl MOC: default values for all parameters
#    ...      CNI-108976 is enabled (MRBTS/NRBTS/NRCELL/ulTransPreEnhSinrMetric= false)
#    ...    Test Steps:
#    ...      Step1: UE1 attached to cell
#    ...      Step2: Start full DL and UL traffic..
#    ...      Step3: Adjust SINR to make UE1 switch to TP on.
#    ...      Step4: Adjust SINR to make UE1 switch to TP off.
#    ...      Step5: Change ulTransPreEnhSinrMetric to true.
#    ...      Step6: UE2 attached to cell.
#    ...      Step7: Sart full DL and UL traffic.
#    ...      Step8: Adjust SINR to make UE2 switch to TP on.
#    ...      Step9: Adjust SINR to make UE2 switch to TP off.
#    ...    Check point:
#    ...      1. In step2, all UE PUSCH transmissions are with Transform Precoder Disabled (CP OFDM).
#    ...      2. In step3, old UL SINR metric is used,TP on
#    ...      3. In step4, old UL SINR metric is used,TP off
#    ...      4. In step5, NIDD modified successfully, BTS locked unlocked automatically, UE1 detached.
#    ...      5. In step7, all UE PUSCH transmissions are with Transform Precoder Disabled (CP OFDM) for UE2.
#    [Tags]    case_01    TA_suqian
#    [Setup]    Run Keywords    Set Test Variable    ${WTS_CFG}    ${WTS_CFG_01}
#    ...        AND    Suite Setup Update GNB    force_reboot=${force_reboot}    scf_file=${SCF_01}    iphy_file=${IPHY_01}
#    ...               swconfig_param=${RD}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Suite Setup Start WTS And Check OnAir    log=${False}
#    ...        AND    Common Test Setup 2
#    #step1 and checkpoint1
#    SA Single UE Attach    ${UE1_ID}
#    #step2
#    Sleep    2s    reason=Wait for log
#    Start SA UE Big UL Traffic Internal    ${UE1_ID}    150
#    Start SA UE Big DL Traffic Internal    1    mbps=150
#    Sleep    10s    #sleep for stable traffic
#    #step3
#    Send Commond To Trigger UE Lower Sinr    1    130
#    Start Ttitrace With Streaming Mode
#    Active Lower Sinr    1
#    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/0
#    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/0
#    Start Ttitrace With Streaming Mode
#    Send Commond To Trigger UE Lower Sinr    1    30
#    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/1
#    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/1
#    #step5
#    Online Change One Para With Admin    MRBTS-1/NRBTS-1/NRCELL-3    actUlTransPreEnhSinrMetric    true
#    Sleep    3s    reason=Wait for cell setup
#    SA Single UE Attach    ${UE2_ID}
#    Sleep    2s    reason=Wait for log
#    Start SA UE Big UL Traffic Internal    ${UE2_ID}    150
#    Start SA UE Big DL Traffic Internal    2    mbps=150
#    Sleep    10s    #sleep for stable traffic
#    Send Commond To Trigger UE Lower Sinr    2    130
#    Start Ttitrace With Streaming Mode
#    Active Lower Sinr    2
#    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/2
#    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/2
#    Start Ttitrace With Streaming Mode
#    Send Commond To Trigger UE Lower Sinr    2    100
#    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/3
#    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/3
#    CUDU_L2 Check Rate    ulHarqRxData.dtx    ["NON_DTX","DTX"]    ["DTX"]    0    0.1
#    CUDU_L2 Check Rate    ulHarqRxData.dtx    ["NON_DTX","DTX"]    ["DTX"]    1    0.1
#    CUDU_L2 Check Rate    ulHarqRxData.dtx    ["NON_DTX","DTX"]    ["DTX"]    2    0.1
#    CUDU_L2 Check Rate    ulHarqRxData.dtx    ["NON_DTX","DTX"]    ["DTX"]    3    0.1
#    Check TTI Use SINR Metric    99    0    1
#    Check TTI Use SINR Metric    99    1    1
#    Check TTI Use SINR Metric    34    2    1
#    Check TTI Use SINR Metric    29    3    1
#    SA 5G Detach    ue_id=2
#
#*** Keywords ***
#Send Commond To Trigger UE Lower Sinr
#    [Arguments]    ${ue_id}=1    ${pathloss}=130
#    Execute Egate Command    cmd=ul_sinr_testmode_nr profile_id=1 pathloss=${pathloss}
#    sleep    10s    #sleep for sinr stable
#
#Active Lower Sinr
#    [Arguments]    ${ue_id}=1
#    Execute Egate Command    cmd=ue_testmode_set_nr id=${ue_id} testmode=ul_sinr profile_id=1 action=activate scell=0
#    sleep    10s    #sleep for sinr stable
#
#Check TTI Use SINR Metric
#    [Arguments]    ${metric}=99    ${log_id}=0    ${count}=1
#    ${value}    Read Csv Columns    ${TEST_LOG_DIRECTORY}/ttitrace/${log_id}/output_ul.csv    rnti    filter=ulFdSchedData.tpHystCounter=${metric}
#    ${list}     Evaluate      list(set(${value}))
#    ${new}    Create List
#    :FOR   ${value}    IN     @{list}
#    \     Run Keyword If     '${value}'!='0' and '${value}'!='65535'   Append To List    ${new}   ${value}
#    Log     ${new}
#    ${len}    Get Length    ${new}
#    Should Be True  ${len}==${count}
