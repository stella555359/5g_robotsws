*** Settings ***
Documentation     Author: qianqian.ren@nokia-sbell.com...
...               QC case full name:
...               CB014094-SR-B_06_Thor_Online_modification_all_parameters_with_5GC001116

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown
Test Setup        Common Test Setup
Test Teardown     Common Test Teardown
Force Tags        CLOUD_5G_I_MP_AP_LOOO    AP    CRT    SBTS00    SBTS00    RAN_5G_TDD    RAN_5G    owner_qiaren
Test Timeout      90 minutes
Resource          ../../resources/KISS/robot/common_resource.robot
Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
Resource          ../../resources/sg11/internal_resource/robot/internal_capture_log.robot

*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/config/
${SCFC_NAME}          CB014094_C_01_SCFC.xml
${AIRPHONE_NAME}      IPHY_CB014094_C_01.xml
${WTS_NAME}           wts_CB014094_C_01.lua
${JSON_FILE}          Delta_CB014094_B_03.json

@{LOG_NAME_LIST}      gnb_snapshot    sosreport    egatelog\
${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id=1 mode=fixed init_quad_pos=3 init_sub_quad_pos=3 step=5 trigger_puxch_update=0
                   ...    multi_path_config=0 test_type=UL_MIMO
${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id=2 mode=fixed init_quad_pos=1 init_sub_quad_pos=1 step=5 trigger_puxch_update=0
                   ...    multi_path_config=0 test_type=UL_MIMO
${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id=3 mode=fixed init_quad_pos=2 init_sub_quad_pos=3 step=5 trigger_puxch_update=0
                   ...    multi_path_config=0 test_type=UL_MIMO
${PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id=4 mode=fixed init_quad_pos=0 init_sub_quad_pos=1 step=5 trigger_puxch_update=0
                   ...    multi_path_config=0 test_type=UL_MIMO
${BETAEC}    13
${XEC}    14
${PARA_LIST}    wbSrsConfigProhibitTimer=100;wbSrsReleaseProhibitTimer=800;enableSbSrsVolatilityCheck=true;sortingMetric=WBSRSPOWER;maxWbSbSwitch=15
*** Test Cases ***
CB014094-SR-B_03_Loki_Online_modification_all_parameters_with_5GC001208
    Step1:Test Prepare For Onair
    Step2:5UE Attach and check
    Step3:OnLine Change and check agagin
    Step4:Detach ues

*** Keywords ***
Step1:Test Prepare For Onair
    Start Collect GNB and AP Syslog in 'Step1_before_onair' File
    ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
    change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
    Add RD For CPRT Debug Log
    ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
    copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
    Modify TL VM And AP SCTP Configuration
    Get and Update BSR File    par_of_bsr_name=BSR_AEHC_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
    Get and Update BSR File    par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
    Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
    [Teardown]    Stop Collect GNB and AP Syslog in 'Step1_before_onair' File

Step2:5UE Attach and check
    Start capture gnb and ap syslog in 'Step2' file
    Attach 5 SA UE
    ues send dl data
    Wait Throughput Timer    3
    get and check dl thp by egate
    ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2
    Start GNB Ttitrace With Streaming Mode
    Wait Throughput Timer    2
    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
    Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}${/}tti
    A2A Check SRSBF    Step2
    [Teardown]    Stop capture gnb and ap syslog in 'Step2' file

Step3:OnLine Change and check agagin
    Start capture gnb and ap syslog in 'Step3' file
    ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
    airphone_cleanup_egate_console_log
    Online Recommissioning With Delta Json File    ${CONFIG_DIR_PATH}${/}${JSON_FILE}
    Wait Throughput Timer    10
    airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/online_change   unzip=TRUE
    ${sys_log_dir}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3${/}syslog_Step3${/}Step3_gnb*
    ${rc}    ${output}=    OperatingSystem.Run And Return Rc And Output    cp ${sys_log_dir} ${CURDIR}/gnb_sys_log.log
    Check Syslog For Cell Reconfig    ${CURDIR}/gnb_sys_log.log
    get and check dl thp by egate
    ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3
    Start GNB Ttitrace With Streaming Mode
    Wait Throughput Timer    2
    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
    Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}${/}tti
    A2A Check SRSBF    Step3
    Stop capture gnb and ap syslog in 'Step3' file


Step4:Detach ues
    Detach '5'UE


Attach 5 SA UE
     FOR    ${i}    IN RANGE    1    6
       airphone_cleanup_egate_console_log
       Airphone SA Attach    ue_id=${i}
       Wait '2S' for stable running
       Airphone Set Traffic Type    ue_id=${i}    pdu_id=1    type=internal
       Wait '2S' for stable running
       Airphone Pdu Session Setup    ue_id=${i}   pdu_id=1   nwslice_id=1
       Wait '2S' for stable running
       airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_${i}   unzip=TRUE
       ${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}/All/egate_UE_${i}/egate_console.log   crnti: (\\d+)
       run keyword if    ${i}==1    Set test Variable    ${ue1_rnti}    ${rnti_list[0]}
       run keyword if    ${i}==2    Set test Variable    ${ue2_rnti}    ${rnti_list[0]}
       run keyword if    ${i}==3    Set test Variable    ${ue3_rnti}    ${rnti_list[0]}
       run keyword if    ${i}==4    Set test Variable    ${ue4_rnti}    ${rnti_list[0]}
       run keyword if    ${i}==5    Set test Variable    ${ue5_rnti}    ${rnti_list[0]}
     END


ues send dl data
    FOR    ${u}    IN RANGE     1    6
         Airphone SA Start Data Traffic    ${u}    DL    175M    trf_id=1    pdu_id=1    duration=${7200}
    END

get and check dl thp by egate
    FOR    ${u}    IN RANGE     1    6
        ${ue_dl_tput}=    Airphone Get Throughput On Specific Scell    ${u}    0    pdsch    current
        Log To Console    ue${u} thp is ${ue_dl_tput}
        should be true    ${ue_dl_tput}>100000
    END


A2A Check SRSBF
    [Arguments]    ${step}
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/14094_SR_B_03.ini    log_need_to_check=i
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/${step}/

Add RD For CPRT Debug Log
    Add GNB swconfig    0x1003F:1
    Add GNB swconfig    0x590072:1    #CPRT debug log

Check Syslog For Cell Reconfig
    [Arguments]    ${log_path}    ${Paramters}=${PARA_LIST}
    ${content}    OperatingSystem.Get File    ${log_path}
    ${para_item}    String.Split String    ${Paramters}    ;
    FOR     ${item}    IN    @{para_item}
        Continue For Loop If    '${item}'=='${EMPTY}'
        ${param}    ${value}    String.Split String    ${item}    =    1
        ${pattern}    Set Variable    CellReconfiguration.*?"${param}":\s*["]?${value}
        ${match_list}     Get Regexp Matches    ${content}    ${pattern}
        ${check_rst}    Get Length    ${match_list}
        Should Be True    ${check_rst}>=1
    END

Add GNB swconfig
    [Arguments]    @{Rdparameter}
    Backup Swconfig    ${CURDIR}    gnb_swconfig.txt
    setup_txt    src_file=${CURDIR}/gnb_swconfig.txt    save_path=${CURDIR}/gnb_swconfig_modify.txt
    FOR    ${parameter}    IN    @{Rdparameter}
        ${key}    ${value}    Split String    ${parameter}    :
        run keyword and ignore error    delete txt node    ${key}
        add txt node    ${parameter}
    END
    teardown txt
    GNB Upload Swconfig    ${CURDIR}/gnb_swconfig_modify.txt
