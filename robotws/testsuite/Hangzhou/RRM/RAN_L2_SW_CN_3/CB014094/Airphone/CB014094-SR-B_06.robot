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
${SCFC_NAME}          CB014094_B_06_SCFC.xml
${AIRPHONE_NAME}      IPHY_CB014094_B_06.xml
${WTS_NAME}           wts_CB014094_B_06.cfg
${JSON_FILE}          Delta_CB014094_B_06.json

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
${PARA_LIST}    wbSrsConfigProhibitTimer=200;wbSrsReleaseProhibitTimer=1000;enableSbSrsVolatilityCheck=true;sortingMetric=WBSRSPOWER;maxWbSbSwitch=15
*** Test Cases ***
CB014094-SR-B_06_Thor_Online_modification_all_parameters_with_5GC001116
    Step1:Modify vendor file 72e and full commission for onair
    Step2:7UE Attach and check
    Step3:OnLine Change and check agagin
    Step4:Detach ues

*** Keywords ***
Step1:Modify vendor file 72e and full commission for onair
    [Arguments]    ${wait_bts_timeout}=2000    ${wait_rru_timeout}=800    ${wait_onair_timeout}=800
    Start capture gnb and ap syslog in 'before_onair' file
    ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
    Change iphy rru version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
    Add RD For CPRT Debug Log
    ${scfc_path}    Set variable    ${CONFIG_DIR_PATH}/${SCFC_NAME}
    ${cfg_path}    Set variable    ${CONFIG_DIR_PATH}/${WTS_NAME}
    ${new_scfc}    GNB_BASE.Change Vlan Id In Scfc    ${scfc_path}    ${test_log_directory()}/full_commission/
    Modify TL VM And AP SCTP Configuration
    Get and Update BSR File    par_of_bsr_name=BSR_AVQL_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00002
    Get and Update BSR File    par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_N01_COVERAGE_00392_00001
    Get and Update BSR File    par_of_bsr_name=BSR_AEHC_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
    TAF_ADMIN.Setup Admin
    ${vendor_path}    Set Variable    ${test_log_directory()}/vendor_ini.xml
    TAF_ADMIN.Download Vendor File    ${vendor_path}
    Modify Vendor betaec XML File    ${vendor_path}
    Modify Vendor xec XML File    ${vendor_path}
    #Modify Vendor 72e XML File    ${vendor_path}
    TAF_ADMIN.Set Vendor File    ${vendor_path}
    ${connission_status}    Run Keyword And Return Status    TAF_ADMIN.Perform Commissioning
    ...    bts_id=${GNB_IP}
    ...    scf_file=${new_scfc}
    ...    skip_parameter_relation_errors=True
    ...    should_activate=True
    ...    timeout=300
    Log to console    Full Commissioning is ${connission_status}
    TAF_ADMIN.teardown admin
    Wait '120s' for stable
    Run Keyword And Ignore Error    Start collect 'cellsetup' tcpdump
    ${bts_status}=    Run Keyword And Return Status    Wait Unit Bts Configured    ${wait_bts_timeout}
    ${rru_status}=    Run Keyword And Return Status    Wait Until RRU Configured    ${wait_rru_timeout}
    ${onair_status}=    Run Keyword And Return Status    Start Wts And Wait Bts Until Onair     ${cfg_path}
    ...    timeout=${wait_onair_timeout}
    Stop capture gnb and ap syslog in 'before_onair' file
    Log To Console    BTS is onAir now
    Run Keyword And Ignore Error    Stop collect 'cellsetup' tcpdump

Step2:7UE Attach and check
    Start capture gnb and ap syslog in 'Step2' file
    Attach 7 SA UE
    ues send dl data
    Wait Throughput Timer    3
    Wait Until Keyword Succeeds    50s    10s     get and check dl thp by egate
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
    Online Recommissioning With Delta Json File    ${CONFIG_DIR_PATH}${/}${JSON_FILE}
    Wait Throughput Timer    20
    ${sys_log_dir}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3${/}syslog_Step3${/}Step3_gnb*
    ${rc}    ${output}=    OperatingSystem.Run And Return Rc And Output    cp ${sys_log_dir} ${CURDIR}/gnb_sys_log.log
    #Check Syslog For Cell Reconfig    ${CURDIR}/gnb_sys_log.log
    Wait Until Keyword Succeeds    50s    10s    get and check dl thp by egate
    ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3
    Start GNB Ttitrace With Streaming Mode
    Wait Throughput Timer    2
    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
    Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}${/}tti
    A2A Check SRSBF    Step3
    Stop capture gnb and ap syslog in 'Step3' file


Step4:Detach ues
    Detach '7'UE


Attach 7 SA UE
     FOR    ${i}    IN RANGE    1    8
       airphone_cleanup_egate_console_log
       Airphone SA Attach    ue_id=${i}
       Wait '2S' for stable running
       Airphone Set Traffic Type    ue_id=${i}    pdu_id=1    type=internal
       Wait '2S' for stable running
       Airphone Pdu Session Setup    ue_id=${i}   pdu_id=1   nwslice_id=1
       Wait '2S' for stable running
       airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_${i}   unzip=TRUE
       ${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}/All/egate_UE_${i}/egate_console.log.001   crnti: (\\d+)
       run keyword if    ${i}==1    Set test Variable    ${ue1_rnti}    ${rnti_list[0]}
       run keyword if    ${i}==2    Set test Variable    ${ue2_rnti}    ${rnti_list[0]}
       run keyword if    ${i}==3    Set test Variable    ${ue3_rnti}    ${rnti_list[0]}
       run keyword if    ${i}==4    Set test Variable    ${ue4_rnti}    ${rnti_list[0]}
       run keyword if    ${i}==5    Set test Variable    ${ue5_rnti}    ${rnti_list[0]}
       run keyword if    ${i}==6    Set test Variable    ${ue6_rnti}    ${rnti_list[0]}
       run keyword if    ${i}==7    Set test Variable    ${ue7_rnti}    ${rnti_list[0]}
     END


ues send dl data
    FOR    ${u}    IN RANGE     1    8
         Airphone SA Start Data Traffic    ${u}    DL    175M    trf_id=1    pdu_id=1    duration=${7200}
    END

get and check dl thp by egate
    FOR    ${u}    IN RANGE     1    8
        ${ue_dl_tput}=    Airphone Get Throughput On Specific Scell    ${u}    0    pdsch    current
        Log To Console    ue${u} thp is ${ue_dl_tput}
        should be true    ${ue_dl_tput}>110000
    END

Modify Vendor betaec XML File
    [Arguments]    ${vendor_path}
    ${vendor_listbetaec}    Set Variable    text|${BETAEC}|//*[@name\="betaEc"]
    Modify Xml    ${vendor_path}    ${vendor_path}    ${vendor_listbetaec}

Modify Vendor xec XML File
    [Arguments]    ${vendor_path}
    ${vendor_listxec}    Set Variable    text|${XEC}|//*[@name\="xEc"]
    Modify Xml    ${vendor_path}    ${vendor_path}    ${vendor_listxec}

A2A Check SRSBF
    [Arguments]    ${step}
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/14094_SR_B_06.ini    log_need_to_check=i
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
