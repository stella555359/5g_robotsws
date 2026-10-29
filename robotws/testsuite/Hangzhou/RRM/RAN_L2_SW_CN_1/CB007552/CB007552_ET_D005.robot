*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    common_Log_capture.Set CP Debug Log
#...               AND    Convert TL Mode And Suite Setup
#Suite Teardown    Common Suite Teardown
#Test Setup        Common Test Setup
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD    CRT    RAN_5G    RAN_5G_FDD    FR1    Owner_Y7LI    CN1
#...               SBTS00    SBTS23R1
#Resource          ../CUDU_L2/common_setup_teardown.robot
#
#*** Variables ***
#${UE_NUMS}                      10
#${SCF_PATH}                     ${CURDIR}/resources/config
#${RD_PARAM}                     0x590072=1;0x5900f1=1    # CP Debug
#${DELTA_FILE}                   Conf_7752-D-SANSA-FDD.xml
#${IPHY_FILE}                    ${LOCAL_WTS_DIR}/Conf_7752-D-SANSA-FDD-iphy.xml
#${UE_ID}                        1
#${PROFILE_ID}                   1
#${GNB_ID}                       2
#${CELL_ID}                      2
#${BEARER_ID}                    2
#@{LOG_NAME_LIST}                snapshot
#@{LOG_NAME_SUITE_SETUP_ASIK}    snapshot
#${COUNT}                        0
#${LOCAL_WTS_DIR}                ${CURDIR}/resources/wts
#${WTS_CFG}                      basic_setup-7552-D-SA-FDD.cfg
#${WTS_AP_XML}                   wts_ap_config_ASIK_ABIL_FDD_CPRI_cmwv_SANSA_FS.xml
#${IPHY_XML}                     ${OUTPUT_DIR}/iphy.xml
#@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}
##${RD_PARAM_22R1}             SEPARATOR=${EMPTY}    0x590000=12;0x5800BA=15;0x590072=1;0x41001b=1;0x5900f1=1;0x45005a=1;    # CP Debug
##${RD_PARAM_AP_22R1}          SEPARATOR=${EMPTY}    0x70649 = 9;0x70005 = 130
##${RD_PARAM_22R2}             SEPARATOR=${EMPTY}    0x590000=13;0x5800BA=16;0x590072=1;0x41001b=1;0x5900f1=1;0x45005a=1;    # CP Debug
##${RD_PARAM_AP_22R2}          SEPARATOR=${EMPTY}    0x70649 = 10;0x70005 = 140
##${RD_PARAM_22R3}             SEPARATOR=${EMPTY}    0x590000=14;0x5800BA=17;0x590072=1;0x41001b=1;0x5900f1=1;0x45005a=1;    # CP Debug
##${RD_PARAM_AP_22R3}          SEPARATOR=${EMPTY}    0x70649 = 11;0x70005 = 140
#
#
#
#*** Test Cases ***
#CB007552_ET_D005_Verify_Multi_Ues_With_Different_Dedicated_BWP_With_FDD_FR1_SA_Mode
#    Attach Multi SA UE    2
#    Start DLUL Single Traffic For Multi SA UE    2    85    40
#    Sleep    3s    reason=wait for traffic stable
#    Check SA MultiUE Tput    2    1    50    30
#    common_log_capture.Start Ttitrace With Streaming Mode
#    Sleep    3s    reason=get ttitrace
#    common_log_capture.Stop Ttitrace
#    common_log_analyzer.Convert Ttitrace From Pcap To Excelcsv    ${OUTPUT_DIR}/ttitrace_streaming/
#    common_log_analyzer.Format Tti In Stream Mode    ${OUTPUT_DIR}/ttitrace_streaming/output_dl.csv
#    ...    ${OUTPUT_DIR}/ttitrace_streaming/output_dl_formated.csv
#    common_log_analyzer.Format Tti In Stream Mode    ${OUTPUT_DIR}/ttitrace_streaming/output_ul.csv
#    ...    ${OUTPUT_DIR}/ttitrace_streaming/output_ul_formated.csv
#    Copy Egate Log
#    Check Log With Au2anlysis    ${CURDIR}${/}A2A/CB007552-D_MultiUE${/}CB007552-D_MultiUE.ini    i
#    ...    save_log_directory=${OUTPUT_DIR}/ttitrace_streaming
#    Check Log With Au2anlysis    ${CURDIR}${/}A2A/CB007552-D_MultiUE${/}CB007552-D_MultiUE.ini    p
#    ...    save_log_directory=${OUTPUT_DIR}
#
#*** Keywords ***
#Attach Multi SA UE
#    [Arguments]    ${max_ue_num}
#    FOR    ${UE_ID}    IN RANGE    1    ${max_ue_num}+1
#    SA 5G Attach    ue_id=${UE_ID}
#    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=1
#    SA 5G PDU Session Setup    ue_id=${UE_ID}
#    END
#
#Start DLUL Single Traffic For Multi SA UE
#    [Arguments]    ${max_ue_num}=1    ${dl_tp_set}=100    ${ul_tp_set}=50
#    FOR    ${UE_ID}    IN RANGE    1    ${max_ue_num}+1
#    SA Start DL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${dl_tp_set}    trf_id=1
#    Sleep    3s
#    SA Start UL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${ul_tp_set}    trf_id=1
#    END
#
#Check SA MultiUE Tput
#    [Arguments]    ${max_ue_num}=1    ${pdu_id}=1    ${dl_tp_threshold}=5    ${ul_tp_threshold}=5
#    FOR    ${UE_ID}    IN RANGE    1    ${max_ue_num}+1
#    ${dl_tp}=    SA Get UE Average Traffic Internal    ${UE_ID}    1    dl
#    ${ul_tp}=    SA Get UE Average Traffic Internal    ${UE_ID}    1    ul
#    Log    ${UE_ID} DL Troughput is ${dl_tp}    console=True
#    Log    ${UE_ID} UL Troughput is ${ul_tp}    console=True
#    ${dl_tp_delta}=    Evaluate    ${dl_tp}-${dl_tp_threshold}
#    ${ul_tp_delta}=    Evaluate    ${ul_tp}-${ul_tp_threshold}
#    Should Be True    ${dl_tp_delta}>=0
#    Should Be True    ${ul_tp_delta}>=0
#    Log    ${UE_ID} DL Troughput is ${dl_tp}    console=True
#    Log    ${UE_ID} UL Troughput is ${ul_tp}    console=True
#    Sleep    3s
#    END
#
#Copy Egate Log
#    OperatingSystem.Copy File    /opt/wts/latest/egate_console.log.001    ${OUTPUT_DIR}/egate/
#
#Convert TL Mode And Suite Setup
#    Suite Setup Update GNB    swconfig_param=${RD_PARAM}    iphy_file=${IPHY_FILE}     scf_file=${DELTA_FILE}
#    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    Suite Setup Start WTS And Check OnAir
