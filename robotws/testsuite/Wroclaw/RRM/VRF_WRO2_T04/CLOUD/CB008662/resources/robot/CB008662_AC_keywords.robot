*** Settings ***
Documentation     [SUITE PURPOSE]  TCs and KWs of CB008662 step AC
...
...               Test Case Scenario author   : yann.ah.herve@nokia.com
...               Test Case Scenario contact  : yann.ah.herve@nokia.com
...               Test Case automation author : yann.ah.herve@nokia.com
...               Test Case automation contact: yann.ah.herve@nokia.com
...               Creation Date               : 26-September-2022
...               Last Modified by            : vincent.boulet@nokia.com
...               Modification:
...                       26-September-2022   | Creation
...                       10-October-2023     | Move to LO_LO topology (replace bit error TM with legacy UL SINR TM)
...                                           | and remove ABIL dependency (ABIL no more available)
...                       22-February-2023    | martial.hummel@nokia.com
...                       17-May-2024         | Parity testing to introduce dRNIC RINLINE2 CLOUD_5GC_dRNIC_1vDU_P_AP_LO_DC
...     6.02.25 - CloudRan TCs copied from NPS to WRO_2_4 (regression takeover), whole resources replaced

Resource                        testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/cloud/tti_aic/tti_aic.robot
Resource                         testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/SWENG/KPIs.robot
Library                          ../python/CB008662_CheckTTITraceDL.py

*** Variables ***
${UL_trace_duration}             10
${UL_troughput}                  50

${TputVolMargin}                 5
${CONSTRAINTS_FILE_VDU}          testsuite/Wroclaw/RRM/VRF_WRO2_T04/CLOUD/CB008662/config/CB008662_AC_06_Constraints_VDU.csv
${MaxAdaptiveReTxErrorRatio}     5

${cell_noise_level}                             -710
${sinr_target}                                  -210
${MRBTS_ID_DU}    1
${NRBTS_ID_DU}    1

*** Keywords ***
CB008662_TC_AC_06_UL_HARQ_Retrans_When_above target_Min_50_Target_90
    [Documentation]                 This test aims at checking retransmission configuration when number of
    ...                             requested REs is below the ones needed for initial transmission,
    ...                             but they are not available.
    ...                             targetPctResourceReservedMcsUls set to 95 % to exceed number of PRB available
    ...                             inside PRACH slots.
    ...                             This test case also cover UL counters check ([1]CB008662_AB_06_Check_UL_64QAM_Counters_MCS_31)
    ${ue}           Copy Dictionary      ${BASIC_UE_SA}
    Set To Dictionary                                    ${ue}    ue              3    #SA FDD id corresponding to target cell#
    Set To Dictionary                                    ${ue}    target_gnb      2
    Set To Dictionary                                    ${ue}    target_cells    52
    Set To Dictionary                                    ${ue}    pdu             3
    Log To Console              ===> current_ue_setting is ${ue}

    Execute Egate Command    cmd=ul_cell_noise_testmode_nr profile_id=1 noise_pusch=${cell_noise_level}

    Execute Egate Command
    ...    cmd=cell_testmode_set_nr cell_id=${ue.target_cells} gnb=${ue.target_gnb} testmode=ul_cell_noise profile_id=1 action=activate

    Execute Egate Command    cmd=ul_sinr_testmode_nr profile_id=1 sinr_target_pusch=${sinr_target}


    Log To Console     === SA Register UE ${ue.ue} on cell ${ue.target_cells} ===
    Wait Until Keyword Succeeds    2x    100ms   Attach UE And Establish PDU Session    ue_id=${ue.ue}    cell_id=${None}
    ...  pdu_id=${ue.pdu}    gw_id=3

    ${timeStartTraffic}             Get Current Date
    Log To Console              === Start packets sending at ${timeStartTraffic}

    Execute Egate Command    cmd=trf_data_start ue=${ue.ue} pdu=${ue.pdu} qfi=1 dir=ul trf_id=1 mbps=50
    Sleep    20
    # Enable UL SINR test mode
    Log To Console                       === Decreasing SINR to add UL BLER
    Execute Egate Command    cmd=ue_testmode_set_nr id=${ue.ue} testmode=ul_sinr profile_id=1 action=activate
    Sleep    5

    ${zoi}                          ZOI Start    pmAvailDelay=80

    Log To Console              === Start TTI traces capture
    Start Collecting Tti    nr_cells=52

    Sleep    ${UL_trace_duration}

    ${TTIpcap}    stop_collecting_tti

    Log To Console              === Convert TTItrace to json
    ${TTIjson}                      convert_tti_to_json        input_file_path=${TTIpcap}

    Log To Console              === Check retransmission PRB and adaptive MCS in TTI trace
    ${checksResults}                Run Keyword and continue on failure    checkAdaptiveFDDUL     jsonPathName=${TTIjson}

    Log To Console              === Starting collecting PM
    ZOI Wait End                    zoi=${zoi}

    Remove Directory    ${OUTPUT_DIR}/counters_vdu_1    recursive=${TRUE}
    ${pm_path}    Get Latest Unpacked Full Pm Counters File    vdu=1

    Execute Egate Command    cmd=ue_testmode_set_nr id=${ue.ue} testmode=bler profile_id=1 action=deactivate

    ${timeStopTraffic}              Get Current Date
    Log To Console              === Stop packets sending and detach UE at ${timeStopTraffic}
    Stop DL and UL traffic on PDU for UE    ${ue.ue}

    Deregister UE  ue_id=${ue.ue}

    Log To Console    Error percentage is ${checksResults}[ErrorRatio] % < ${MaxAdaptiveReTxErrorRatio}
    Log To Console    Reserved MCS detected: ${checksResults}[reservedMcsDetected]
    Log To Console    Unexpected MCS detected: ${checksResults}[unexpectedMcsDetected]
    Log To Console    Unexpected PRB detected: ${checksResults}[unexpectedPRBDetected]

    Should Be True                  ${checksResults}[ErrorRatio] < ${MaxAdaptiveReTxErrorRatio}

    ${currentConstraintsFile}    Set Variable    ${CONSTRAINTS_FILE_VDU}
    KPI Evaluate    pmFile=${pm_path}    constraintsFile=${currentConstraintsFile}    failOnError=${True}
    [Teardown]    Run Keyword And Ignore Error    Deregister UE  ue_id=${ue.ue}

Deregister UE
    [Arguments]    ${ue_id}
    Execute Egate Command    cmd=ue_deregister id=${ue_id} ue_deregister_type=switch_off
