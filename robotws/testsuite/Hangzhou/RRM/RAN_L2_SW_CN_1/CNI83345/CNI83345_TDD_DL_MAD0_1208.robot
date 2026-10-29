*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    swconfig_param=${RD_PARAM}
#...               scf_file=${SCF_FILE}    iphy_file=${IPHY_FILE}
#...               AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}
#...               wts_cfg_file=${WTS_CFG_FILE}
#...               AND    Suite Setup Start WTS And Check OnAir
#Suite Teardown    Common Suite Teardown
#Test Setup        Common Test Setup
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_I_LO_AP_LO    FR1    CRT    RAN_5G     RAN_5G_TDD
#...               Owner_naliu   CN1    SBTS00    SBTS23R1    SBTS22R4
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#
#*** Variables ***
#${UE_NUMS}                      30
#${RD_PARAM}                     0x580605=0;0x5801f9=0
#${WTS_LOCAL}                    ${CURDIR}/resources/wts
#${WTS_CFG_FILE}                 basic_setup_CNI83345.cfg
#${IPHY_FILE}                    ${CURDIR}/resources/wts/iphy_CNI83345.xml
#${SCF_PATH}                     ${CURDIR}/resources/config
#${SCF_FILE}                     SCF_CNI83345.xml
#${UE_ID}                        1
#${PROFILE_ID}                   1
#${GNB_ID}                       2
#${CELL_ID}                      2
#@{LOG_NAME_LIST}                snapshot
#@{LOG_NAME_SUITE_SETUP_ASIK}
#${COUNT}                        0
#${DL_TPUT_TARGET}               400
#${UL_TPUT_TARGET}               50
#
#*** Test Cases ***
#CNI83345_01_Verify_New_OLLA_Algorithm_For_TDD_With_MADTable
#    Attach SA Single UE    1
#    Start DL Traffic For SA UE    1    175    3
#    Check SA SingleUE DL Tput    1    1    400
#    Override DL Bler
#    Check SA SingleUE DL Tput    1    1    100
#    common_Log_capture.Start Ttitrace With Streaming Mode
#    Override DL Bler Recovery
#    Check SA SingleUE DL Tput    1    1    400
#    Stop Ttitrace
#    Convert And Formated Ttitrace
#    Save Egate Log    ${output_dir}/egate/
#    run_keyword_and_continue_on_failure     ta_a2a.Check Log With Au2anlysis    ${CURDIR}${/}A2A/CNI83345_TDD${/}CNI83345_SemiStatic_1_4.ini
#    ...    i    save_log_directory=${output_dir}/ttitrace_streaming
#    run_keyword_and_continue_on_failure     ta_a2a.Check Log With Au2anlysis    ${CURDIR}${/}A2A/CNI83345_TDD${/}CNI83345_SemiStatic_1_4.ini
#    ...    p    save_log_directory=${output_dir}
#
#*** Keywords ***
#Attach SA Single UE
#    [Arguments]    ${UE_ID}=1
#    SA 5G Attach    ue_id=${UE_ID}
#    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=1
#    SA 5G PDU Session Setup    ue_id=${UE_ID}
#
#Start DL Traffic For SA UE
#    [Arguments]    ${UE_ID}=1    ${dl_tp_set}=100    ${trf_id_num}=1
#    : FOR    ${trf_id}    IN RANGE    1    ${trf_id_num}+1
#    \    SA Start DL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${dl_tp_set}    trf_id=${trf_id}
#    \    Sleep    1s
#    Sleep    3s    reason=wait T-put stable
#
#Check SA SingleUE DL Tput
#    [Arguments]    ${UE_ID}=1    ${pdu_id}=1    ${dl_tp_threshold}=5
#    ${dl_tp}=    SA Get UE Average Traffic Internal    ${UE_ID}    1    dl
#    Log    ${UE_ID} DL Troughput is ${dl_tp}    console=True
#    ${dl_tp_delta}=    Evaluate    ${dl_tp}-${dl_tp_threshold}
#    Should Be True    ${dl_tp_delta}>=0
#    Log    ${UE_ID} DL Troughput is ${dl_tp}    console=True
#
#
#Override DL Bler
#    ute_wtssim.Execute Egate Command    cmd=bler_testmode_nr profile_id=1 dl_bler=500,400,300
#    ute_wtssim.Execute Egate Command    cmd=ue_testmode_set_nr id=1 scell=0 testmode=bler profile_id=1 action=activate
#    Sleep    2s    reason=MCS Downgrade
#Override DL Bler Recovery
#    ute_wtssim.Execute Egate Command    cmd=ue_testmode_set_nr id=1 scell=0 testmode=bler profile_id=1 action=deactivate
#    Sleep    10s    reason=MCS Upgrade
#
#Convert And Formated Ttitrace
#    common_log_analyzer.Convert Ttitrace From Pcap To Excelcsv    ${output_dir}/ttitrace_streaming/
#    common_log_analyzer.Format Tti In Stream Mode    ${output_dir}/ttitrace_streaming/output_dl.csv
#    ...    ${output_dir}/ttitrace_streaming/output_dl_formated.csv
#    common_log_analyzer.Format Tti In Stream Mode    ${output_dir}/ttitrace_streaming/output_ul.csv
#    ...    ${output_dir}/ttitrace_streaming/output_ul_formated.csv
