# *** Settings ***
# Test Timeout    50 minutes
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Case Test Teardown
# Force Tags    AP    CRT    SBTS00    RAN_5G    CLOUD_5G_I_BLLL_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    SBTS23R3
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_10659_B_case39_fdd_3CC_n5_n66_n66.xml
# ${AIRPHONE_NAME}    iphy_AHCA_n5_AHFIB_n66_AHFIB_n66.xml
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# ${GNB_SWCONFIG_NAME}    gnb_swconfig.txt
# ${AP_SWCONFIG_NAME}    ap_swconfig.txt
# ${WTS_NAME}    basic_fs_sa_call_fdd_cmwv_3CC_1167_I_d.cfg
# ${BIP_TAG}    srs
# ${ue_id_1}    1
# 
# 
# *** Test Cases ***
# CB010659_B_case39_FDD_IWK_DL_CA
#     [Documentation]
#     ...    for debug SRS  and push mix ratio
#     # Prepare test
#     Prepare fdd 3cc gnb onair
#     airphone_cleanup_egate_console_log
#     Start capture gnb and ap syslog in 'after_onair' file
#     Airphone Execute Egate Command    set_pdu_param ue\=1 pdu\=1 trf_type\=internal
#     Airphone Execute Egate Command    ue_change_location id\=1 cell\=2
#     Airphone SA Attach    ue_id=1
#     Wait '10s' for stable
#     Airphone Execute Egate Command    ue_pdu_session_setup ue\=1 pdu\=1 nwslice\=1 gw\=1
#     Wait '6s' for stable
#     SA send ue '1' mutiple trf '1' for each '150M' DL data
#     SA send ue '1' mutiple trf '1' for each '90M' UL data
#     Airphone Execute Egate Command    ue_stats_nr id\=1 type\=pdsch scell\=0-2
#     run keyword and continue on failure    Verify throughput
#     run keyword and continue on failure    check SA UE'1' dl tput range is '0' to '100' and ul tput range is '77' to '91'
# 
#     run keyword and continue on failure    Start collect ttitrace
#     run keyword and continue on failure    Wait for '2s' to stop ttitrace with name'tti'
#     #Log To Console    .......start wait 600s to start SOS
#     #Wait '900s' for stabible
#     #Log To Console    .......stop SOS!!!
#     Airphone Execute Egate Command    trf_data_stop ue\=1 pdu\=1 qfi\=1 dir\=bi
# 
# 
# 
# *** Keywords ***
# Prepare test
#     Active GNB L2 feature debug traces
#     Add GNB swconfig    @{Rdparameter}
# 
# Verify throughput
#     ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=1    scell_id=0    type=pdsch    tput_type=ave
#     ${dl_throughput_scell1}    airphone_get_throughput_on_specific_scell    ue_id=1    scell_id=1    type=pdsch    tput_type=ave
#     ${dl_throughput_scell2}    airphone_get_throughput_on_specific_scell    ue_id=1    scell_id=2    type=pdsch    tput_type=ave
#     ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=1    scell_id=0    type=pusch    tput_type=ave
#     #should_be_true    ${dl_throughput_pcell}>0
#     #should_be_true    ${dl_throughput_scell1}>0
#     Log To Console   ${\n}dl_throughput_pcell: ${dl_throughput_pcell}
#     Log To Console   ${\n}dl_throughput_scell1: ${dl_throughput_scell1}
#     Log To Console   ${\n}dl_throughput_scell2: ${dl_throughput_scell2}
#     Log To Console   ${\n}ul_throughput_pcell: ${ul_throughput_pcell}
# 
# Prepare fdd 3cc gnb onair
#     Check GPS status enable
#     ${status0}    ${msg0}    Run Keyword And Ignore Error    Variable Should Exist    ${GNB_SWCONFIG_NAME}
#     ${status1}    ${msg1}    Run Keyword And Ignore Error    Variable Should Exist    ${AP_SWCONFIG_NAME}
#     Run Keyword If    '${status0}'=='PASS'    Put swconfig file to gnb    ${CONFIG_DIR_PATH}/${SW_BRANCH}/SWCONFIG/${GNB_SWCONFIG_NAME}
# #    ...    ELSE    Modify Swconfig for gnb
#     Run Keyword If    '${status1}'=='PASS'    Airphone Upload Swconfig    ${CONFIG_DIR_PATH}/${SW_BRANCH}/SWCONFIG/${AP_SWCONFIG_NAME}
#     ...    ELSE    Modify Swconfig for AP
#     Start capture gnb and ap syslog in 'before_onair' file
#     Change iphy rru version    ${CONFIG_DIR_PATH}/${SW_BRANCH}/WTS/${AIRPHONE_NAME}
#     ${scfc_path}    Set variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}/SCF/${SCFC_NAME}
# #    ${cfg_path}    Run Keyword If    '${FCT_BOARD_TYPE}' == 'ASIB'    Set variable    ${CURDIR}/../../KISS/cfg/${ABIO_CFG}
# #    ...    ELSE    Set variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}/WTS/${WTS_NAME}
#     ${cfg_path}    Set variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}/WTS/${WTS_NAME}
#     ${ret}    Evaluate Xml Xpath    ${scfc_path}    count(//*[@name\='carrierAggregationSupportList']/p)
#     ${type}    Run Keyword If    ${ret} == 1    Read Xml     ${scfc_path}    text|//*[@name\='carrierAggregationSupportList']/p
#     ...    ELSE    Get carrierAggregation value    ${ret}    ${scfc_path}
#     Configure TL VM ETH
#     Perform Full Commission 3cc FDD And Reach Onair     ${scfc_path}    ${cfg_path}    4000    False    1600    1600
#     #Run Keyword If    'Nsa' in '${type}' and 'ABIL' in ${ASP_BOARD_TYPE}   Establish enb x2 link
#     Stop capture gnb and ap syslog in 'before_onair' file
#     Log To Console    BTS is onAir now
#     Run Keyword And Ignore Error    Stop collect 'cellsetup' tcpdump
# 
# Perform Full Commission 3cc FDD And Reach Onair
#     [Arguments]     ${scfc}      ${wts_config}    ${wait_onair_timeout}    ${reset_after_commission}
#     ...             ${wait_bts_timeout}    ${wait_rru_timeout}
#     Log to console    Perform Full Commissioning And Reach Onair start.
#     ${new_scfc}    GNB_BASE.Change Vlan Id In Scfc    ${scfc}    ${test_log_directory()}/full_commission/
#     ${connission_status}    Run Keyword And Return Status    Perform Full Commission     ${new_scfc}
#     Log to console    Full Commissioning is ${connission_status}
#     Wait '100s' for stable
#     Run Keyword And Ignore Error    Start collect 'cellsetup' tcpdump
#     Run Keyword If    '${connission_status}' == 'False'    Hard reboot env
#     Run Keyword If    '${connission_status}' == 'True' and '${reset_after_commission}'=='True'     Reboot gnb and ap via ssh
#     : FOR    ${loop}    IN RANGE    3
#     \    ${bts_status}=    Run Keyword And Return Status    Wait Unit Bts Configured    ${wait_bts_timeout}
#     \    Run Keyword If    '${bts_status}' == 'False' and ${loop} < 1    Reboot gnb and ap via ssh
#     \    Continue For Loop If    '${bts_status}' == 'False' and ${loop} < 1
#     \    Run Keyword If    '${bts_status}' == 'False' and ${loop} == 1    Hard reboot env
#     \    Continue For Loop If    '${bts_status}' == 'False' and ${loop} == 1
#     \    Run Keyword If    '${bts_status}' == 'False' and ${loop} > 1    Fail
#     \    ${rru_status}=    Run Keyword And Return Status    Wait Until RRU Configured    ${wait_rru_timeout}
#     \    Run Keyword If    '${rru_status}' == 'False' and ${loop} < 1    Reboot gnb and ap via ssh
#     \    Continue For Loop If    '${rru_status}' == 'False' and ${loop} < 1
#     \    Run Keyword If    '${rru_status}' == 'False' and ${loop} == 1    Hard reboot env
#     \    Continue For Loop If    '${rru_status}' == 'False' and ${loop} == 1
#     \    Run Keyword If    '${rru_status}' == 'False' and ${loop} > 1    Fail
#     \    Wait '120s' for stable
#     \    ${onair_status}=    Run Keyword And Return Status    Start WTS And Wait BTS Until 3cc FDD Onair     ${wts_config}
#          ...    timeout=${wait_onair_timeout}
#     \    Return From Keyword If    '${onair_status}' == 'True'
#     \    Run Keyword If    '${onair_status}' == 'False' and ${loop} < 1    Reboot gnb and ap via ssh
#     \    Run Keyword If    '${onair_status}' == 'False' and ${loop} == 1    Hard reboot env
#     \    Run Keyword If    '${onair_status}' == 'False' and ${loop} > 1    Fail
# 
# Start WTS And Wait BTS Until 3cc FDD Onair
#     [Arguments]    ${cfg_file}=${None}    ${reload}=${True}    ${timeout}=1500
#     [Documentation]    This keyword is used to wait bts on air until timeout happened, default timeout is 1500 seconds.
#     ...    | Input Parameters | Man. | Description |
#     ...    | ${cfg_file} | No | wts config file, default is get from gerrit store in /opt/wts/latetst/ |
#     ...    | ${reload} | No | load lua cfg file or not, default is to load |
#     ...    | ${timeout} | No | timeout, default is 1500 |
#     ...    Examples:
#     ...    | Start Wts And Wait Bts Until Onair | /opt/wts/latest/basic_fullstack_nsa_call_tdd_cmwv.cfg |
#     Log To Console    Start WTS And Wait BTS Until Onair...
#     ${nrbts_distname}=    Run Keyword If    '${GNBCUTYPE}'=='${EMPTY}'    Get NRBTS DistName
#     Run Keyword If    '${GNBCUTYPE}'=='${EMPTY}'    Backup Scf    ${TEST_LOG_DIRECTORY()}    before_onair_scf.xml
#     Run Keyword If    '${GNBCUTYPE}'=='${EMPTY}'    Get GNB Type    ${TEST_LOG_DIRECTORY()}/before_onair_scf.xml    ${nrbts_distname}
#     ${gnb}=    String.Convert To Lowercase    ${GNBCUTYPE}
#     ${cfg_file}=    Run Keyword If    '${cfg_file}' == '${None}'    Set Variable    ${WTS_CFG_FULL_PATH}
#     ...             ELSE              Set Variable    ${cfg_file}
#     Airphone Start Wtssim With Cfg File    ${cfg_file}    ${reload}
#     wait_until_sib1_received_for_all_cells_3cc_FDD    timeout=${timeout}
#     Wait Until Keyword Succeeds    300    15    Verify BTS Is Onair
# 
# wait_until_sib1_received_for_all_cells_3cc_FDD
#     [Arguments]    ${timeout}=200
#     [Documentation]    This keyword is used to wait sib1 message for all cells
#     Log To Console    ...wait sib1 message for all cells...
#     ${start_time_1}=    Get Time    epoch
#     Wait Until Keyword Succeeds     ${timeout}     15     _sim_state_is_active
#     ${end_time_1}=    Get Time    epoch
#     ${used_time_1}=    Evaluate    ${end_time_1}-${start_time_1}
#     ${timeout_1}=    Evaluate    ${timeout}-${used_time_1}
#     Airphone Get Gnb Id
#     ${cell_id_list}=    Airphone Get Cell Id List
#     ${used_time_2}=    Set Variable    0
#     : FOR    ${cell_id}    IN    @{cell_id_list}
#     \    ${timeout_2}=    Evaluate    ${timeout_1}-${used_time_2}
#     \    ${start_time_2}=    Get Time    epoch
#     \    Airphone Wait Until Sib1 Received    cell_id=${cell_id}    timeout=${timeout_2}
#     \    ${end_time_2}=    Get Time    epoch
#     \    ${used_time_2}=    Evaluate    ${end_time_2}-${start_time_2}
# 
# Detach SA UE'${UE_ID}'
#     airphone_sa_detach    ue_id=${UE_ID}    timeout=30
# 
# Attach one NSA UE'${ue_id}'
#     #airphone_cleanup_egate_console_log
#     Log To Console   ${\n}-----Attach NSA UE ${ue_id} ------
#     Airphone Nsa Attach    ${ue_id}     profile_id=None
# 
# SA UE'${ue_id}' send '${dl_data_size}' with trf num'${dl_trf_num}' dl data and '${ul_data_size}' with trf num'${ul_trf_num'} ul data
#     SA send mutiple trf dl data    ${ue_id}    number='${dl_trf_num}'   ul_data=${dl_data_size}    pdu_id=${ue_id}
#     SA send mutiple trf ul data    ${ue_id}    number='${ul_trf_num}'   ul_data=${ul_data_size}    pdu_id=${ue_id}
# 
# SA send ue '${ue_id}' mutiple trf '${number}' for each '${ul_data}' UL data
#     SA send mutiple trf ul data    ${ue_id}    number=${number}   ul_data=${ul_data}    pdu_id=${ue_id}
#     Wait Throughput Timer    3s
# 
# SA send ue '${ue_id}' mutiple trf '${number}' for each '${dl_data}' DL data
#     SA send mutiple trf dl data    ${ue_id}    number=${number}   dl_data=${dl_data}    pdu_id=${ue_id}
#     Wait Throughput Timer    3s
# 
# NSA UE'${ue_id}' send '${dl_data_size}' with trf num'${dl_trf_num}' dl data and '${ul_data_size}' with trf num'${ul_trf_num'} ul data
#    NSA send ue '${ue_id}' mutiple trf '${dl_trf_num}' for each '${dl_data_size}' DL data
#    NSA send ue '${ue_id}' mutiple trf '${ul_trf_num}' for each '${ul_data_size}' UL data
# 
# collect ‘${tti_duration}' ttitrace with name'${tti_tag}'
#     Start collect ttitrace
#     Wait for '${tti_duration}' to stop ttitrace with name'${tti_tag}'
# 
# check SA UE'${ue_id}' dl tput range is '${dl_low_Mb}' to '${dl_high_Mb}' and ul tput range is '${ul_low_Mb}' to '${ul_high_Mb}'
#     Log To Console    ..Check throughput UE${ue_id}
#     ${dl_tput_kb}    ${ul_tput_kb}    Obtain one sa ue dl and ul throught    ${ue_id}   pdu_id= ${ue_id}
#     ${dl_tput_Mb}    evaluate    ${dl_tput_kb}/1000
#     ${ul_tput_Mb}    evaluate    ${ul_tput_kb}/1000
#     Log To Console    dl ${dl_tput_Mb}
#     Log To Console    ul ${ul_tput_Mb}
#     should be true    ${dl_tput_Mb}>=${dl_low_Mb}
#     should be true    ${dl_tput_Mb}<=${dl_high_Mb}
#     should be true    ${ul_tput_Mb}>=${ul_low_Mb}
#     should be true    ${ul_tput_Mb}<=${ul_high_Mb}
# 
# check ue ${ue_id} ${dl_tput} range is ${dl_low} to ${dl_high} ${ul_tput} range is ${ul_low} to ${ul_high}
#     log to console    start to check throughput ${ue_id}
#     should be true    ${dl_tput}>${dl_low}
#     should be true    ${dl_tput}<${dl_high}
#     should be true    ${ul_tput}>${ul_low}
#     should be true    ${ul_tput}<${ul_high}
# 
# Wait for '${time}' to stop ttitrace with name'${tti_tag}'
#     sleep   ${time}
#     ${pcap_path}    Stop GNB Ttitrace With Streaming Mode
#     Decoder Tttirace From Pcap To Csv    ${pcap_path}      ${test_log_directory()}/All/${tti_tag}
# 
# 
# Online change actUlMuMimoTapering ${tapering_switch}
#     TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     Perform online change value    MRBTS-1/NRBTS-1/NRCELL-1/NRULMUMIMO-0    actUlMuMimoTapering    ${tapering_switch}    online
#     TAF_ADMIN.teardown admin    connection=online
# 
# Online change ulMaxMuMimoLayer${maxlaynum}
#     TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     Perform online change value    MRBTS-1/NRBTS-1/NRCELL-1/NRULMUMIMO-0    ulMaxMuMimoLayer    ${maxlaynum}    online
#     TAF_ADMIN.teardown admin    connection=online
# 
# 
# Case Test Teardown
#     run keyword and continue on failure    Stop capture gnb and ap syslog in 'after_onair' file
#     Common Test Teardown