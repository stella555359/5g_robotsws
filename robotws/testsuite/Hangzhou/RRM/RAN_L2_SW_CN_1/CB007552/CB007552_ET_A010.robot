*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    common_log_capture.Set CP Debug Log
#...               AND    Modify Iphy Xml    ${IPHY_XML}    ${XML_PARAMS_DICT}
#...               AND    Suite Setup Update GNB    swconfig_param=${RD_PARAM}    scf_file=${DELTA_FILE}
#...               AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#...               AND    Suite Setup Start WTS And Check OnAir
#Suite Teardown    Common Suite Teardown
#Test Setup        Common Test Setup
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CRT    RAN_5G    RAN_5G_TDD    FR1    Owner_xiaothan
#...               SBTS00    SBTS23R1    SBTS22R4
#Resource          ./CB007552_Resource.robot
#
#*** Variables ***
#${RD_PARAM}                     0x590072=1;0x66001b=1;0x5900f1=1 # rdSib1ScsCarrierBandwidthSet
#${SCF_PATH}                     ${CURDIR}/resources/config
#${DELTA_FILE}                   Delta_Conf_7752-A-NSA-TDD.json
#${UE_ID}                        11
#${PROFILE_ID}                   1
#${GNB_ID}                       2
#${CELL_ID}                      1
#${BEARER_ID}                    2
#@{LOG_NAME_LIST}                snapshot
#@{LOG_NAME_SUITE_SETUP_ASIK}    snapshot
#${COUNT}                        0
#${LOCAL_WTS_DIR}                ${CURDIR}/resources/wts
#${WTS_CFG}                      basic_setup-7552-A-NSA-TDD.cfg
#${WTS_AP_XML}                   wts_ap_config_ASIK_ABIL_TDD_CPRI_cmwv_SANSA_FS.xml
#&{PARAM_DICT}                   NumberOfSubCellsDL=2    NumberOfSubCellsUL=2
#&{XML_PARAMS_DICT}              GSCN=7830
#${IPHY_XML}                     ${OUTPUT_DIR}/iphy.xml
#
#*** Test Cases ***
#CB007552_ET_A010_Verify_PM_Counters_For_Max_Ues_With_Different_Dedicated_BWP_With_TDD_FR1_NSA_Mode
#    UE Attach With NSA    11
#    UE Attach With NSA    20
#    common_log_capture.Start Ttitrace With Streaming Mode
#    Sleep    6s    reason=get ttitrace
#    common_log_capture.Stop Ttitrace
#    common_log_analyzer.Convert Ttitrace From Pcap To Excelcsv    ${OUTPUT_DIR}/ttitrace_streaming/
#    common_log_analyzer.Format Tti In Stream Mode    ${OUTPUT_DIR}/ttitrace_streaming/output_dl.csv
#    ...    ${OUTPUT_DIR}/ttitrace_streaming/output_dl_formated.csv
#    common_log_analyzer.Format Tti In Stream Mode    ${OUTPUT_DIR}/ttitrace_streaming/output_ul.csv
#    ...    ${OUTPUT_DIR}/ttitrace_streaming/output_ul_formated.csv
#    Save Egate Log    ${OUTPUT_DIR}
#    Wait Until Keyword Succeeds    20min    1min    Verify CB007552 PM Counters After Traffic
#    Report Pm Counter    M55115C02001    1    Passed
#    Report Pm Counter    M55115C02002    1    Passed
#    Report Pm Counter    M55308C29001    2000000    Passed
#    Report Pm Counter    M55308C29002    60000    Passed
#    Report Pm Counter    M55308C29003    5000000    Passed
#    Report Pm Counter    M55308C29004    100000    Passed
#
#*** Keywords ***
#Verify PM Counters Bigger Than Value
#    [Arguments]    ${counter_id}    ${threshold_value}
#    ${counter_values}    Get Latest PM Counter Value With Admin    ${counter_id}
#    Should Be True    ${counter_values} > ${threshold_value}
#
#Verify PM Counters Equal Than Value
#    [Arguments]    ${counter_id}    ${threshold_value}
#    ${counter_values}    Get Latest PM Counter Value With Admin    ${counter_id}
#    Should Be Equal    ${counter_values}    ${threshold_value}
#
#Verify CB007552 PM Counters After Traffic
#    Verify PM Counters Equal Than Value    M55115C02001    1
#    Verify PM Counters Equal Than Value    M55115C02002    1
#    #Verify PM Counters Equal Than Value    M55166C00001    1
#    #Verify PM Counters Equal Than Value    M55166C00002    1
#    #Verify PM Counters Equal Than Value    M55166C00003    1
#    #Verify PM Counters Equal Than Value    M55166C00004    1
#    Verify PM Counters Bigger Than Value    M55308C29004    100000
#    Verify PM Counters Bigger Than Value    M55308C29003    5000000
#    Verify PM Counters Bigger Than Value    M55308C29002    60000
#    Verify PM Counters Bigger Than Value    M55308C29001    2000000
#
#UE Attach With NSA
#    [Arguments]    ${ue_id}
#    NSA LTE Attach    ${ue_id}    ${PROFILE_ID}
#    NSA 5G Attach    ${ue_id}    ${GNB_ID}    ${CELL_ID}    ${BEARER_ID}
#    NSA Verify If Attach Passed
#    NSA Start DL Traffic    ${ue_id}    ${BEARER_ID}    100
#    NSA Start UL Traffic    ${ue_id}    ${BEARER_ID}    5
#    Sleep    6s    reason=wait for traffic stable
