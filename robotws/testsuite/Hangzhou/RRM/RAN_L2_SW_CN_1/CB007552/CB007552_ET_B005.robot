*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Set CP Debug Log
#...               AND    Suite Setup Update GNB    swconfig_param=${RD_PARAM}    iphy_file=${IPHY_FILE}     scf_file=${DELTA_FILE}
#...               AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#...               AND    Suite Setup Start WTS And Check OnAir
#Suite Teardown    Common Suite Teardown
#Test Setup        Common Test Setup
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    FR1    CRT    RAN_5G    RAN_5G_TDD    Owner_y7li    CN1
#...               SBTS00    SBTS23R1    SBTS22R4
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#
#*** Variables ***
#${RD_PARAM}                     0x590072=1;0x41001b=1;0x5900f1=1    # CP Debug
#${SCF_PATH}                     ${CURDIR}/resources/config
#${DELTA_FILE}                   Delta_TDD_CB007552_B_SANSA_LO.json
#${DELTA_REC_FILE}               Delta_TDD_CB007552_B_SANSA_KL_rec.json
#${UE_ID}                        1
#${PROFILE_ID}                   1
#${GNB_ID}                       2
#${CELL_ID}                      2
#${BEARER_ID}                    2
#@{LOG_NAME_LIST}                snapshot    btsLog
#@{LOG_NAME_SUITE_SETUP_ASIK}    snapshot
#${COUNT}                        0
#${LOCAL_WTS_DIR}                ${CURDIR}/resources/wts
#${WTS_CFG}                      basic_setup-7552-B-SA-TDD.cfg
#${WTS_AP_XML}                   wts_ap_config_ASIK_ABIL_TDD_CPRI_cmwv_SANSA_FS.xml
#${DL_TPUT_TARGET}               400
#${UL_TPUT_TARGET}               50
#${IPHY_FILE}                    ${CURDIR}/resources/wts/Conf_7752-B-SANSA-TDD-iphy.xml
#@{DL UDP Port}                  7070    7072    7074    7076    7078    7080    7082    7084
#@{UL UDP Port}                  7071    7073    7075    7077    7079    7081    7083    7085
#
#*** Test Cases ***
#CB007552_ET_B005_Verify_Multi_Ues_With_Different_Dedicated_BWP_With_TDD_FR1_SA_Mode
#    Attach SA MultiUE And Start DLUL Traffic    1    2    100    20
#    Attach 2 SA UE And Start DL UL Traffic For Dedicated Bearer
#    Check Mullti UE DL Avg Traffic Internal For Dedicated Bearer With QFI    1    2    1    1    50
#    Check Mullti UE DL Avg Traffic Internal For Dedicated Bearer With QFI    3    4    1    2    50
#    Check Mullti UE UL Avg Traffic Internal For Dedicated Bearer With QFI    1    2    1    1    3
#    Check Mullti UE UL Avg Traffic Internal For Dedicated Bearer With QFI    3    4    1    2    6
#    common_Log_capture.Start Ttitrace With Streaming Mode
#    Sleep    2s    reason=capture ttitrace
#    common_Log_capture.Stop Ttitrace
#    common_Log_analyzer.Convert Ttitrace From Pcap To Excelcsv    ${OUTPUT_DIR}/ttitrace_streaming/
#    Format Tti In Stream Mode    ${OUTPUT_DIR}/ttitrace_streaming/output_dl.csv    ${OUTPUT_DIR}/ttitrace_streaming/output_dl_formated.csv
#    Format Tti In Stream Mode    ${OUTPUT_DIR}/ttitrace_streaming/output_ul.csv    ${OUTPUT_DIR}/ttitrace_streaming/output_ul_formated.csv
#    Save Egate Log    ${output_dir}/egate/
#    ta_a2a.Check Log With Au2anlysis    ${CURDIR}${/}A2A/CB007552-B_MultiUE${/}CB007552-B_MultiUE_SmallBWP.ini
#    ...    i    save_log_directory=${output_dir}/ttitrace_streaming
#    ta_a2a.Check Log With Au2anlysis    ${CURDIR}${/}A2A/CB007552-B_MultiUE${/}CB007552-B_MultiUE_SmallBWP.ini
#    ...    p    save_log_directory=${output_dir}
#
#*** Keywords ***
#Attach SA MultiUE
#    [Arguments]    ${UE_ID_start}=1    ${UE_ID_end}=1
#    : FOR    ${UE_ID}    IN RANGE    ${UE_ID_start}    ${UE_ID_end}+1
#    \    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=1
#    \    SA 5G Attach    ue_id=${UE_ID}
#    \    SA 5G PDU Session Setup    ue_id=${UE_ID}
#
#Attach SA MultiUE And Start DLUL Traffic
#    [Arguments]    ${UE_ID_start}=1    ${UE_ID_end}=1    ${dl_tp_set}=175    ${ul_tp_set}=175
#    : FOR    ${UE_ID}    IN RANGE    ${UE_ID_start}    ${UE_ID_end}+1
#    \    SA 5G Attach    ue_id=${UE_ID}
#    \    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=1
#    \    SA 5G PDU Session Setup    ue_id=${UE_ID}
#    \    Sleep    1s    reason=wait for APH execution
#    \    SA Start DL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${dl_tp_set}    trf_id=1
#    \    Sleep    1s    reason=wait for APH execution
#    \    SA Start UL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${ul_tp_set}    trf_id=1
#
#Attach 2 SA UE And Start DL UL Traffic For Dedicated Bearer
#    Attach SA MultiUE    3    4
#    Add Dedicated Bearer For SA Multi UE    3    4    1    5
#    Start DL Traffic For Dedicated Bearer Of MultiUE    3    4    1    2    175
#    Start UL Traffic For Dedicated Bearer Of MultiUE    3    4    1    2    175
#    Sleep    5s    reason=wait for traffic stable
#
#Add Dedicated Bearer For SA Multi UE
#    [Arguments]    ${UE_ID_start}=1    ${UE_ID_end}=1    ${pdu_id}=1    ${qosflows_to_add}=2
#    : FOR    ${UE_ID}    IN RANGE    ${UE_ID_start}    ${UE_ID_end}+1
#    \    ute_wtssim.Execute Egate Command    cmd=ue_pdu_session_modify ue\=${UE_ID} pdu\=${pdu_id} qosflows_to_add\=${qosflows_to_add} by\=amf
#    \    Sleep    1s    reason=wait for APH execution
#    \    Log    Dedicated Bearer establshed
#
#Start DL Traffic For Dedicated Bearer Of MultiUE
#    [Arguments]    ${UE_ID_start}=1    ${UE_ID_end}=1    ${pdu_id}=1    ${qfi}=2    ${dl_tp_set}=175
#    : FOR    ${UE_ID}    IN RANGE    ${UE_ID_start}    ${UE_ID_end}+1
#    \    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${ue_id} pdu\=${pdu_id} qfi\=${qfi} dir=dl mbps\=${dl_tp_set} trf_id\=1
#    \    Sleep    1s    reason=wait for traffic stable
#
#Start UL Traffic For Dedicated Bearer Of MultiUE
#    [Arguments]    ${UE_ID_start}=1    ${UE_ID_end}=1    ${pdu_id}=1    ${qfi}=2    ${ul_tp_set}=175
#    : FOR    ${UE_ID}    IN RANGE    ${UE_ID_start}    ${UE_ID_end}+1
#    \    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${ue_id} pdu\=${pdu_id} qfi\=${qfi} dir=ul mbps\=${ul_tp_set} trf_id\=1
#    \    Sleep    1s    reason=wait for traffic stable
#
#Check SA UE Average Traffic Internal For Dedi Bearer With QFI
#    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${dir}=dl    ${qfi}=1
#    ${output}    ute_wtssim.Execute Egate Command    cmd=bearer_stats ue\=${ue_id} pdu\=${pdu_id} qfi\=${qfi} dir\=${dir}
#    ...    pass_regexp=Average packet interval    timeout=150
#    OperatingSystem.Create File    /tmp/${dir}.txt    ${output}
#    ${avg}    OperatingSystem.Run    cat /tmp/${dir}.txt | grep -m 1 'Average data rate' | awk '{print $4}'
#    ${tp_delta}    Evaluate    ${avg}*0.000001
#    [Return]    ${tp_delta}
#
#Check Mullti UE DL Avg Traffic Internal For Dedicated Bearer With QFI
#    [Arguments]    ${UE_ID_start}=1    ${UE_ID_end}=1    ${pdu_id}=1    ${qfi}=1    ${dl_tp_threshold}=5
#    : FOR    ${UE_ID}    IN RANGE    ${UE_ID_start}    ${UE_ID_end}+1
#    \    ${dl_tp}=    Check SA UE Average Traffic Internal For Dedi Bearer With QFI    ue_id=${UE_ID}    pdu_id=${pdu_id}    dir=dl    qfi=${qfi}
#    \    Log    ${UE_ID}_${qfi} DL Troughput is ${dl_tp}    console=True
#    \    ${dl_tp_delta}=    Evaluate    ${dl_tp}-${dl_tp_threshold}
#    \    Run Keyword And Continue On Failure    Should Be True    ${dl_tp_delta}>=0
#
#Check Mullti UE UL Avg Traffic Internal For Dedicated Bearer With QFI
#    [Arguments]    ${UE_ID_start}=1    ${UE_ID_end}=1    ${pdu_id}=1    ${qfi}=1    ${ul_tp_threshold}=5
#    : FOR    ${UE_ID}    IN RANGE    ${UE_ID_start}    ${UE_ID_end}+1
#    \    ${ul_tp}=    Check SA UE Average Traffic Internal For Dedi Bearer With QFI    ue_id=${UE_ID}    pdu_id=${pdu_id}    dir=ul    qfi=${qfi}
#    \    Log    ${UE_ID}_${qfi} UL Troughput is ${ul_tp}    console=True
#    \    ${ul_tp_delta}=    Evaluate    ${ul_tp}-${ul_tp_threshold}
#    \    Run Keyword And Continue On Failure    Should Be True    ${ul_tp_delta}>=0
