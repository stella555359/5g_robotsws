*** Settings ***
Documentation    ...
Suite Teardown    Common Suite Teardown 2
Test Teardown     Common Test Teardown 2
Force Tags        CLOUD_5G_I_LO_AP_LO
...               SBTS00    SBTS24R3    Pz4_12    CB008927   RAN_5G    RAN_5G_TDD    #CRT
Resource          ./../CUDU_L2/common_setup_teardown.robot
Resource          ./Resources/CNI129095_resource.robot
Resource          ./../CB008236/Resources/CB008236_resource.robot
Resource          ./../CUDU_L2/common_setup_teardown.robot
Resource          ./../CUDU_L2/common_log_capture.robot
Resource          ./../CUDU_L2/common_log_analyzer.robot
Resource          ./../5GC001808/AirPhone_common_resource_UTE_CR.robot
Resource          ./../5GC001817/keywords_1817_common_AP.robot
Library           ./../CB008236/Resources/CB008236_resource.py

*** Variables ***
${SCF_PATH}          ${CURDIR}/Config
${MSG5_SCF}          SCF_1.xml
${MSG5_IPHY}         ${WTS_LOCAL}/iphy.xml
${MSG5_WTS_CFG}      basic_setup.cfg
${WTS_LOCAL}         ${CURDIR}/Resources/wts
${RD}                0x580839=1;0x580345=1;0x58090b=1
${ttiPath}          ttitrace
${filter}          uldata_puschreceivereq&&3gpp.rnti!=65535
@{column_name}     UlData_puschReceiveReqGrant_t.mcsTable   DlData_DciInfoL1sw.dciSize   UlData_UePuschReceiveRespPs_t.dtx
                     ...    DlData_DciInfoL1sw.rachStatus   UlData_puschReceiveReqGrant_t.rachStatus   UlData_puschReceiveReqGrant_t.harqProcessIndex
${bip_csv}           bip_gnb.csv
@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}

*** Test Cases ***
CNI129095_msg5_retranmission
    #[Setup]    Run Keywords    Wait Until Keyword Succeeds    300sec    15sec    Verify BTS Is Configured
    #...    AND    Suite Setup Start WTS And Check OnAir
    #...    AND    Common Test Setup
    [Setup]    Prepare TL w gNB_xml '${MSG5_SCF}' AP_xml '${MSG5_IPHY}' AP_cfg'${MSG5_WTS_CFG}'
    SA MSG5 Retransmission mode  1
    #Start capture Ttitrace
    Start bip
    Run Keyword And Ignore Error    SA 5G Attach  1
    Stop bip
    Convert BIP To CSV By MCShark    ${TEST_LOG_DIRECTORY}/Gnb_BIP/5GBipL2L1_filtering_off.pcap
    ...     ${TEST_LOG_DIRECTORY}/Gnb_BIP/${bip_csv}    ${filter}    ${column_name}
    A2A_Check_CSV_Table    ${CURDIR}/Resources/msg5.ini    ${TEST_LOG_DIRECTORY}/Gnb_BIP/${bip_csv}     ${TEST_LOG_DIRECTORY}/Gnb_BIP/
    #Stop capture Ttitrace and convert to Excelcsv to log dir '${ttiPath}'


*** Keywords ***
SA MSG5 Retransmission mode
    [Arguments]    ${ue_id}
    Log To Console    \active MSG5_RETRANSMISSION
    ${prepare_1}    Set Variable
    ...    cont_res_testmode_nr profile_id=6 msg5_dtx=255
    ute_wtssim.Execute Egate Command    ${prepare_1}
    ${prepare_2}    Set Variable
    ...    ue_testmode_set_nr id=${ue_id} testmode=contention_resolution profile_id=6 action=activate
    ute_wtssim.Execute Egate Command    ${prepare_2}

Start capture Ttitrace
    common_Log_capture.Start Ttitrace With Streaming Mode

Start bip
    Start Gnb BIP Log

Stop bip
    Stop Gnb BIP Log    ${TEST_LOG_DIRECTORY}/Gnb_BIP

Stop capture Ttitrace and convert to Excelcsv to log dir '${log_dir}'
#   Sleep    5s    wait for a while.
    common_Log_capture.Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/${log_dir}
    common_Log_analyzer.Convert Ttitrace From Pcap To Excelcsv    ${TEST_LOG_DIRECTORY}/${log_dir}
