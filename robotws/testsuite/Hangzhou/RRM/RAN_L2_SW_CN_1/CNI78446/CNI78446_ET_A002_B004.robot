*** Settings ***
Documentation    ...
#Suite Setup        Suite Setup Update GNB
#Suite Teardown     Common Suite Teardown
#Force Tags         CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD    CRT    RAN_5G    CNI78446    RAN_5G_FDD    FR1
#...                CN1    SBTS00
#Resource           ../CUDU_L2/common_setup_teardown.robot
#
#*** Variables ***
#${UE_ID}                        1
#@{LOG_NAME_LIST}                snapshot
#@{LOG_NAME_SUITE_SETUP_ASIK}    snapshot
#${SCF_PATH}                     ${CURDIR}/resources/config
#${LOCAL_WTS_DIR}                ${CURDIR}/resources/wts
##A002
#${Full_SCF_A002}                ${SCF_PATH}/SCF_CN78446_A002.xml
##${DELTA_FILE}                   ${SCF_PATH}/Delta_CNI78446-SANSA-FDD.json
#${IPHY_A002}                    ${SCF_PATH}/Conf_CNI78446-A-FDD-iphy.xml
#${WTS_CFG_A002}                 basic_setup_CNI78446_A002.cfg
##B004
#${RD_PARAM}                     0x590072=1;0x5900f1=1    # CP Debug
#${DELTA_FILE}                   ${SCF_PATH}/Conf_78446-B-SANSA-FDD-SCF.xml
#${IPHY_FILE}                    ${SCF_PATH}/Conf_78446-B-SANSA-FDD-iphy.xml
#${WTS_CFG_B004}                 basic_setup-78446-B-SA-FDD.cfg
#${DL_TPUT_TARGET}               400
#${UL_TPUT_TARGET}               50
#
#*** Test Cases ***
#CNI78446_ET_A002_Verify_MultiUe_2BWPs_UEConnect_UseInitialBwp_FDD_FR1_SA
#    [Tags]    Owner_j8shen
#    [Setup]    Run Keywords    Test Setup Update GNB    scf_file=${Full_SCF_A002}    iphy_file=${IPHY_A002}
#    ...       AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${LOCAL_WTS_DIR}    wts_cfg_file=${WTS_CFG_A002}
#    ...       AND    Suite Setup Start WTS And Check OnAir
#    Attach Multi SA UE    2
#    Start DLUL Single Traffic For Multi SA UE    2    85    40
#    Check SA MultiUE Tput    2    1    50    30
#    Run Keyword And Ignore Error    Start And Convert Ttitrace
#    Copy Egate Log
#    Run Keyword And Ignore Error    Check Log With Au2anlysis    ${CURDIR}${/}A2A/CNI78446-A-02${/}CNI78446_A_MultiUE.ini    i
#    ...    save_log_directory=${TEST_LOG_DIRECTORY}${/}ttitrace_streaming
#    Run Keyword And Ignore Error    Check Log With Au2anlysis    ${CURDIR}${/}A2A/CNI78446-A-02${/}CNI78446_A_MultiUE.ini    p
#    ...    save_log_directory=${TEST_LOG_DIRECTORY}
#    [Teardown]    Test Teardown Recover Env    scf_file=${scf_test_bak_file}    iphy_file=${IPHY_TEST_BAK_FILE}
#
#CNI78446_ET_B004_UE_Reestablishment_With_Large_BWP_UseInitialBwp_FDD_FR1_SA
#    [Tags]    Owner_y7li
#    [Setup]    Run Keywords    Test Setup Update GNB    swconfig_param=${RD_PARAM}    scf_file=${DELTA_FILE}    iphy_file=${IPHY_FILE}
#    ...       AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${LOCAL_WTS_DIR}    wts_cfg_file=${WTS_CFG_B004}
#    ...       AND    Suite Setup Start WTS And Check OnAir
#    Attach Multi SA UE    2
#    Start DLUL Single Traffic For Multi SA UE    2    85    40
#    Sleep    3s    reason=wait for traffic stable
#    Triger UE1 Reestablishment
#    Start DLUL Traffic For SA UE    1    85    40
#    Check SA MultiUE Tput    2    1    50    30
#    common_Log_capture.Start Ttitrace With Streaming Mode
#    Sleep    3s    reason=Collect Tttitrace
#    Stop Ttitrace
#    common_log_analyzer.Convert Ttitrace From Pcap To Excelcsv    ${output_dir}/ttitrace_streaming/
#    common_log_analyzer.Format Tti In Stream Mode    ${output_dir}/ttitrace_streaming/output_dl.csv
#    ...    ${output_dir}/ttitrace_streaming/output_dl_formated.csv
#    common_log_analyzer.Format Tti In Stream Mode    ${output_dir}/ttitrace_streaming/output_ul.csv
#    ...    ${output_dir}/ttitrace_streaming/output_ul_formated.csv
#    Save Egate Log    ${output_dir}/egate/
#    ta_a2a.Check Log With Au2anlysis    ${CURDIR}${/}A2A/CNI78446-B_MultiUE${/}CNI78446-B_MultiUE.ini
#    ...    i    save_log_directory=${output_dir}/ttitrace_streaming
#    ta_a2a.Check Log With Au2anlysis    ${CURDIR}${/}A2A/CNI78446-B_MultiUE${/}CNI78446-B_MultiUE.ini
#    ...    p    save_log_directory=${output_dir}
#    [Teardown]    Test Teardown Recover Env    scf_file=${scf_test_bak_file}    iphy_file=${IPHY_TEST_BAK_FILE}
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
#    Sleep    3s    reason=wait for DL traffic stable
#    SA Start UL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${ul_tp_set}    trf_id=1
#    END
#    Sleep    5s    reason=wait for UL traffic stable
#
#Start DLUL Traffic For SA UE
#    [Arguments]    ${UE_ID}=1    ${dl_tp_set}=100    ${ul_tp_set}=50
#    SA Start DL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${dl_tp_set}    trf_id=1
#    Sleep    1s
#    SA Start UL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${ul_tp_set}    trf_id=1
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
#Start And Convert Ttitrace
#    Common_log_capture.Start Ttitrace With Streaming Mode
#    Sleep    3s    reason=get ttitrace
#    common_log_capture.Stop Ttitrace     log_dir=${TEST_LOG_DIRECTORY}${/}ttitrace_streaming/
#    common_log_analyzer.Convert Ttitrace From Pcap To Excelcsv    ${TEST_LOG_DIRECTORY}${/}ttitrace_streaming/
#    common_log_analyzer.Format Tti In Stream Mode    ${TEST_LOG_DIRECTORY}${/}ttitrace_streaming/output_dl.csv
#    ...    ${TEST_LOG_DIRECTORY}${/}ttitrace_streaming/output_dl_formated.csv
#    common_log_analyzer.Format Tti In Stream Mode    ${output_dir}${/}/ttitrace_streaming/output_ul.csv
#    ...    ${TEST_LOG_DIRECTORY}${/}ttitrace_streaming/output_ul_formated.csv
#
#Copy Egate Log
#    OperatingSystem.Copy File    /opt/iphy/latest/egate_console.log    ${TEST_LOG_DIRECTORY}${/}egate/
#
#Triger UE1 Reestablishment
#    ute_wtssim.Execute Egate Command    cmd=ue_rrc_reestablish id=1 gnb=2 cell=1 cause=otherFailure
#    Log    ue_rrc_reestablish id=1 gnb=2 cell=1 cause=otherFailure    console=True
#    Sleep    3s    reason=wait for ue covery
#
#Convert TL Mode And Suite Setup
#    Test Setup Update GNB    swconfig_param=${RD_PARAM}    scf_file=${DELTA_FILE}    iphy_file=${IPHY_FILE}
#    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    Suite Setup Start WTS And Check OnAir
