*** Settings ***
Documentation    ...
#Documentation
#Resource    ./../CUDU_L2/common_setup_teardown.robot
#Resource    ./../CUDU_L2/common_SA_ue_command.robot
#Resource    ./../CUDU_L2/common_admin.robot
#Test Teardown    Common Test Teardown 2
#Suite Teardown    Common Suite Teardown 2
#Force Tags        CLOUD_5G_I_LO_AP_LO    SBTS00    Pz4_12
#...                RAN_5G    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE    CRT
#
#*** Variables ***
#${UE_ID}               1
#${PDU_ID}              1
#${Egatelog_path}       ${CURDIR}
#${LOCAL_WTS_DIR}       ${CURDIR}/config
#${SCF_DIR}             ${CURDIR}/config
#${IPHY_01}            ${LOCAL_WTS_DIR}/iphy_108979.xml
#${SCF_01}             ${SCF_DIR}/SCF_CNI-108979-01.xml
#${WTS_CFG_01}         basic_setup_108979.cfg
#${RD}                  0x4B000F=1;0x590072=1
#${force_reboot}        ${True}
#@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}
#
#*** Test Cases ***
#CNI-108979-01_Verify_TP_enabled_on_target_cell_after_HO_without_dedicated_RRC_reconfiguration
#    [Documentation]
#    ...    Precondition:
#    ...      CNI-108979 is enabled (MRBTS/NRBTS/NRCELL/ulTransPreEnhHo = FALSE) at target cell.
#    ...      Feature 5G000545 is active (NRCELL.actUlDftSOfdm=true)
#    ...      NRCELL.ulTransPrecodeCtl: default values for all parameters
#    ...    Test Steps:
#    ...      Step1: Change ulTransPreEnhHo to true.
#    ...      Step2: UE attached to cell-1.
#    ...      Step3: Start full DL and UL traffic.
#    ...      Step4: Adjust SINR to make TP on.
#    ...      Step5: UE performs HO from cell-1 to cell-2.
#    ...      Step6: Adjust SINR to make TP off and TP on some times.
#    ...    Check point:
#    ...      1. In step1,online change successfully.
#    ...      2. In step4, TP on, no DTX.
#    ...      3. In step5, HO successfully, no dedicated RRC ReConfiguration procedure for TP.
#    ...      4. In step6, TP on and off normally.
#    [Tags]    case_01    TA_coliu
#    [Setup]    Run Keywords    Set Test Variable    ${WTS_CFG}    ${WTS_CFG_01}
#    ...        AND    Suite Setup Update GNB    force_reboot=${force_reboot}    scf_file=${SCF_01}    iphy_file=${IPHY_01}
#    ...               swconfig_param=${RD}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Suite Setup Start WTS And Check OnAir    log=${False}
#    ...        AND    Common Test Setup 2
#    #step1 and checkpoint1
#    Online Change One Para With Admin    MRBTS-1/NRBTS-1/NRCELL-2    actUlTransPreEnhHo     true
#    #step2 && step3
#    Attach UE And Start UL Traffic
#    #step4
#    Adjust Sinr Target Pathloss    1    130
#    Start Ttitrace With Streaming Mode
#    Sleep    2s        reason=Wait for log
#    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/0
#    #step5
#    ${savepoint0} =  Capture savepoint  alias=${GNB_SYSLOG.alias}
#    Trigger A3 Event For IntraGNB IntraFre Handover and collect TTIlog
#    Collect from savepoint  savepoint=${savepoint0}  destination_file=${TEST_LOG_DIRECTORY}/syslog0  alias=${GNB_SYSLOG.alias}
#    Check Source Cell TP State
#    #step6
#    Start Ttitrace With Streaming Mode
#    Switch TP on and off some times
#    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/2
#
#    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/0
#    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/1
#    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/2
#
#    CUDU_L2 Check Rate    ulHarqRxData.dtx    ["NON_DTX","DTX"]    ["DTX"]    0    0.1
#    CUDU_L2 Check Rate    ulHarqRxData.dtx    ["NON_DTX","DTX"]    ["DTX"]    1    0.1
#    CUDU_L2 Check Rate    ulHarqRxData.dtx    ["NON_DTX","DTX"]    ["DTX"]    2    0.1
#
#    SA 5G Detach    ue_id=1
#
#*** Keywords ***
#Attach UE And Start UL Traffic
#    [Arguments]    ${UE_ID}=1
#    SA 5G Attach    ue_id=${UE_ID}
#    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=1
#    SA 5G PDU Session Setup    ue_id=${UE_ID}
#    SA Start UL Traffic Internal    1    1    175
#
#Adjust Sinr Target Pathloss
#    [Arguments]    ${ue_id}=1    ${sinr_target_pathloss}=130
#    ute_wtssim.Execute Egate Command
#    ...    cmd=ul_sinr_testmode_nr profile_id=1 pathloss=${sinr_target_pathloss}
#    ${command}    Set Variable    ue_testmode_set_nr id\=${ue_id} testmode=ul_sinr action=activate profile_id=1
#    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
#    ...    ${command}
#    ...    pass_regexp=rrc-TransactionIdentifier \\d+,\\s+\\S+ rrcReconfigurationComplete
#    ...    timeout=3minutes
#
#Trigger A3 Event For IntraGNB IntraFre Handover and collect TTIlog
#    Start Ttitrace With Streaming Mode
#    Sleep    2s    reason=Wait for log
#    Log To Console    Trigger A3 Event For IntraGNB IntraFre Handover
#    ${pattern}    Set Variable    Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2 performed
#    ${cmd}    Catenate    ue_measurement_send_nr id=1 meas_id=1 event=A3 srsrp_nr=10 phycell_id=51 nrsrp_nr=40
#    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    ${cmd}    pass_regexp=${pattern}    timeout=2min
#    Sleep    2s    reason=Wait for log
#    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/1
#
#Switch TP on and off some times
#    FOR   ${index}   IN RANGE   5
#        ${command1}    Set Variable    ul_sinr_testmode_nr profile_id=1 pathloss=110
#        ${output1}    ute_wtssim.Execute Egate Command And Wait For Data
#        ...    ${command1}
#        ...    pass_regexp=transformPrecoder disabled,
#        ...    timeout=3minutes
#
#        ${command2}    Set Variable    ul_sinr_testmode_nr profile_id=1 pathloss=130
#        ${output2}    ute_wtssim.Execute Egate Command And Wait For Data
#        ...    ${command2}
#        ...    pass_regexp=transformPrecoder enabled,
#        ...    timeout=3minutes
#    END
#
#Check Source Cell TP State
#    [Arguments]    ${log_name}=syslog0    ${source_tpstate}=true
#    ${count}    OperatingSystem.Run    cat ${TEST_LOG_DIRECTORY}/${log_name}|grep -i '"tpStateInSourceCell":${source_tpstate}'|wc -l
#    Should Be True    ${count}!=0
