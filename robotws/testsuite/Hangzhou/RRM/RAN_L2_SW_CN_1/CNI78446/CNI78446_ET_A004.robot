*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Set CP Debug Log
#...               AND    Suite Setup Update GNB    swconfig_param=${RD_PARAM}    scf_file=${DELTA_FILE}
#...               AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#...               AND    Suite Setup Start WTS And Check OnAir
#Suite Teardown    Common Suite Teardown
#Test Setup        Common Test Setup
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    FR1    CRT    RAN_5G    RAN_5G_TDD    Owner_xiaothan
#...               CN1    SBTS00    SBTS23R1    SBTS22R4    CNI78446    SBTS22R3
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#
#*** Variables ***
#${UE_NUMS}                      30
#${RD_PARAM}                     0x590072=1;0x41001b=1;0x5900f1=1    # CP Debug
#${SCF_PATH}                     ${CURDIR}/resources/config
#${DELTA_FILE}                   Delta_TDD_CNI78446_A004_SANSA_LO.json
#${DELTA_REC_FILE}               Delta_TDD_CB007552_B_SANSA_KL_Reg.json
#${UE_ID}                        1
#${PROFILE_ID}                   1
#${GNB_ID}                       2
#${CELL_ID}                      2
#${BEARER_ID}                    2
#@{LOG_NAME_LIST}                snapshot
#@{LOG_NAME_SUITE_SETUP_ASIK}    snapshot
#${COUNT}                        0
#${LOCAL_WTS_DIR}                ${CURDIR}/resources/wts
#${LOCAL_WTS_DIR}                ${CURDIR}/resources/wts
#${WTS_CFG}                      basic_setup-7552-B-SA-TDD.cfg
#${WTS_AP_XML}                   wts_ap_config_ASIK_ABIL_TDD_CPRI_cmwv_SANSA_FS.xml
#${DL_TPUT_TARGET}               400
#${UL_TPUT_TARGET}               50
#
#*** Test Cases ***
#CNI78446_ET_A004_Verify_MultiUe_2BWPs_UEConnect_UseInitialBwp_TDD_FR1_SA
#    Attach Multi UE
#    Start DLUL Traffic For SA UE    1    175    50    3
#    Start DLUL Traffic For SA UE    2    175    50    3
#    Sleep    3s    reason=wait T-put stable
#    Check SA SingleUE Tput    1    1    100    5
#    Check SA SingleUE Tput    2    1    100    5
#    common_Log_capture.Start Ttitrace With Streaming Mode
#    Sleep    3s
#    Stop Ttitrace
#    common_log_analyzer.Convert Ttitrace From Pcap To Excelcsv    ${output_dir}/ttitrace_streaming/
#    common_log_analyzer.Format Tti In Stream Mode    ${output_dir}/ttitrace_streaming/output_dl.csv
#    ...    ${output_dir}/ttitrace_streaming/output_dl_formated.csv
#    common_log_analyzer.Format Tti In Stream Mode    ${output_dir}/ttitrace_streaming/output_ul.csv
#    ...    ${output_dir}/ttitrace_streaming/output_ul_formated.csv
#    Save Egate Log    ${output_dir}/egate/
#    ta_a2a.Check Log With Au2anlysis    ${CURDIR}${/}A2A/CNI78446_A004_MultiUE${/}CNI78446_A004_MultiUE_SmallBWP.ini
#    ...    i    save_log_directory=${output_dir}/ttitrace_streaming
#    ta_a2a.Check Log With Au2anlysis    ${CURDIR}${/}A2A/CNI78446_A004_MultiUE${/}CNI78446_A004_MultiUE_SmallBWP.ini
#    ...    p    save_log_directory=${output_dir}
#
#*** Keywords ***
#Attach Multi UE
#    Attach SA Single UE    1
#    Attach SA Single UE    2
#
#Attach SA Single UE
#    [Arguments]    ${UE_ID}=1
#    SA 5G Attach    ue_id=${UE_ID}
#    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=1
#    SA 5G PDU Session Setup    ue_id=${UE_ID}
#
#Start DLUL Traffic For SA UE
#    [Arguments]    ${UE_ID}=1    ${dl_tp_set}=100    ${ul_tp_set}=50    ${trf_id_num}=1
#    FOR    ${trf_id}    IN RANGE    1    ${trf_id_num}+1
#    SA Start DL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${dl_tp_set}    trf_id=${trf_id}
#    Sleep    1s
#    END
#    SA Start UL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${ul_tp_set}    trf_id=1
#
#Check SA SingleUE Tput
#    [Arguments]    ${UE_ID}=1    ${pdu_id}=1    ${dl_tp_threshold}=5    ${ul_tp_threshold}=5
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
