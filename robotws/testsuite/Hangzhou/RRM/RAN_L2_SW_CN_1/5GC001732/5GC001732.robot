*** Settings ***
Documentation    ...
#Resource    ./5GC001732_resource.robot
#Resource    ./../CUDU_L2/common_setup_teardown.robot
#Library           ./../CUDU_L2/scripts/python/ttitrace_data_parser.py
#Library           ./../CUDU_L2/scripts/python/get_csv_data.py
#Library           ./../CUDU_L2/scripts/python/streaming_ttitrace_analyzer.py
#Suite Setup        Run Keywords    Prepare QT LOLO Enviroment for CB001732
#...                AND           Common Suite Setup 2
#Test Teardown      Common Test Teardown 2
#Suite Teardown     Common Suite Teardown 2
#Force Tags        CLOUD_5G_I_LO_AP_LO_NSA_FS_ECPRI_MMWV_TDD    SBTS00    SBTS23R4
#...                RAN_5G    RAN_5G_TDD    CRT
#*** Variables ***
#${SCF_PATH}          ${CURDIR}/config/SCF
#${DELTA_JSON_A05}    ${CURDIR}/config/SCF/Delta_A_05.xml
#${DELTA_JSON_A08}    ${CURDIR}/config/SCF/Delta_A_08.xml
#${LOCAL_WTS_DIR}      ${CURDIR}/config/WTS/
#${WTS_DIR}            /opt/iphy/latest
#${WTS_CFG_A05}       5GC001732_basic_setup.cfg
#${SWCONFIG_PARAM}        0x3F007C=1024
#@{LOG_NAME_LIST}      btslog    snapshot
#${dl_tp_set}    175
#${ul_tp_set}    175
#${Egatelog_path}    ${CURDIR}
#${PDU_ID}                         1
#${TRF_ID}                         1
#@{COLUMN_NAME}      3gpp.sfn    3gpp.slot
#
#*** Test Cases ***
#5GC001732-ET-A005_UCI_multiplexed_OneUe_FR2_coderate_0.35_bestSSB_1
#    [Documentation]
#    ...    Precondition:
#    ...        TDD cell with NSA call with pucchF2MaxCodeRate=0.35
#    ...        UeCapaCsiReportWithoutPmi enabled and maxNumberNonGroupBeamReporting=n1 in UE capability
#    ...        csiReportPeriodicity =slots160 and basicBeamSet=beamSetAbf_32A
#    ...    Test Steps:
#    ...      Step1:Setup NSA call and send ULDL traffic.
#    ...    Check points:
#    ...      CP1:Check TPUT.
#    ...      CP2:Check no DTXCRC in TTITRACE.
#    ...      CP3:Check UCI bits bundled together as 20bits.
#    [Tags]     Owner_lading    case_A_05
#    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG_A05}
#    ...        AND    Suite Setup Update GNB    swconfig_param=${SWCONFIG_PARAM}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Common Test Setup 2
#    Delta_Commission and Setup Cells    ${DELTA_JSON_A05}
#    #Step1
#    NSA UE attach and Send ULDL Traffic    11    1
#    #CP1
#    NSA UE Check Throughput    11    50    10
#    #CP2
#    Collect TTITrace and check DTXCRC    1    5
#    #CP3
#    Check UCI bits right for Case A05 by A2A
#
#5GC001732-ET-A008_Verify_SSB_beam_change_of_One_User_via_FR2_in_NSA_when_1732_feature_enabled
#    [Documentation]
#    ...    Precondition:
#    ...        TDD cell with NSA call with pucchF2MaxCodeRate=0.25.
#    ...        maxNumberNonGroupBeamReporting=n2 in UE capability.
#    ...        csiReportPeriodicity =slots320 and basicBeamSet=beamSetAbf_32B.
#    ...        Set UE Beamforming Profile And Activate for beam change
#    ...    Test Steps:
#    ...      Step1:Setup NSA call and send ULDL traffic.
#    ...      Step2:Trigger beam change
#    ...    Check points:
#    ...      CP1:Check TPUT
#    ...      CP2:Check no DTXCRC in TTITRACE.
#    ...      CP3:Check UCI bits bundled together as 29bits.
#    ...      CP4:Check UCI bits bundled together as 29bits,TPUT is OK and no DTXCRC in TTITRACE.
#
#    [Tags]     Owner_lading    case_A_08    CIT    CDRT
#    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG_A05}
#    ...        AND    Suite Setup Update GNB    swconfig_param=${SWCONFIG_PARAM}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Common Test Setup 2
#    #Precondition
#    Delta_Commission and Setup Cells    ${DELTA_JSON_A08}
#    Set UE Beamforming Profile And Activate
#    #Step1
#    NSA UE attach and Send ULDL Traffic    12    1
#    #CP1&CP2&CP3
#    NSA UE Check Throughput    12    50    10
#    Collect TTITrace and check DTXCRC    1    5
#    Check UCI bits right for Case A08 by A2A    1
#    #Step2&CP4
#    Trigger Beam Change and Check After Beam Change
#
#
#*** Keywords ***
#Prepare QT LOLO Enviroment for CB001732
#    Set Suite Variable    ${Trigger_sucess_flag}    ${False}
#    FOR    ${index}    IN RANGE    1    5
#        Log To Console    ===============Trigger Time: ${index}==============
#        ${res}    Run Keyword And Return Status    Prepare QT LOLO Enviroment    TDD_NSA
#        ${Trigger_sucess_flag}=    Set Variable If    '${res}'=='True'    ${True}
#        Exit For Loop If    '${res}'=='True'
#        Sleep    600s    reason=Wait for TL resetup
#    END
#    Should Be True    "${Trigger_sucess_flag}"=="${True}"