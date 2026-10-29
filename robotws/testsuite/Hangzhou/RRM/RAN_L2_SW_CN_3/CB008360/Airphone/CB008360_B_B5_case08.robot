# *** Settings ***
# Test Timeout    140 minutes
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    test teardown for collect titrace
# Force Tags    AP    SBTS00    RAN_5G_TDD    RAN_5G    SBTS23R1
# ...   CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_8360_B_B1a_case01_07_OP17_8DL8UL.xml
# ${AIRPHONE_NAME}    IPHY_AEQE_OP17_1CELL.xml
# ${L1BYP_XML}    L1ByP_case01_07.xml
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# ${WTS_NAME}    wts_8360_B_case1_7.cfg
# ${BIP_TAG}    srs
# ${X2_CMD}         enb_x2_link_up enb\=1 target\=2
# ${ue_id_1}    1
# ${ue_id_2}    2
# ${ue_id_3}    3
# ${ue_id_4}    4
# ${ue_id_5}    5
# ${ue_id_6}    6
# ${ue_id_7}    7
# ${ue_id_8}    8
# 
# *** Test Cases ***
# CB008360_B_B5_case08_8_rank2_Ues_with_tapering_H_15db_V_0db
#     [Documentation]
#     ...    this Robustness test case
#     prepare AirPhone and wait gNB onair
#     Prepare X2 link
#     Start capture gnb and ap syslog in 'after_onair' file
#     repeat test 6 times
# 
# 
# *** Keywords ***
# Modify Swconfig
#     Modify 8247 Swconfig
#     Add GNB swconfig    0x590103:1
#     #rdSINRusedForRank1LA(0x37C) = 1
#     Add GNB swconfig    0x58037C:1
#         #enable 8360 debug log
#     #Add GNB swconfig    0x58057a:0x4
#     #Add GNB swconfig    0x58057e:0x1047552
#     #580550:7 to enabele 8360-D
#     Add GNB swconfig    0x580550:7
#     #rdactUlMuMimoEnhance 0x58054F=1
#     Add GNB swconfig    0x58054F:1
# 
# Prepare X2 link
#     #airphone_cleanup_egate_console_log
#     airphone_execute_egate_command    ${X2_CMD}
# 
# prepare AirPhone and wait gNB onair
#     Upload airphone l1bypass to iphy
#     Modify Swconfig
#     Prepare gnb onair
# 
# Detach SA UE'${UE_ID}'
#     airphone_sa_detach    ue_id=${UE_ID}    timeout=30
# 
# 
# SA UE'${ue_id}' send '${dl_data_size}' with trf num'${dl_trf_num}' dl data and '${ul_data_size}' with trf num'${ul_trf_num'} ul data
#     SA send mutiple trf dl data    ${ue_id}    number='${ul_data_size}'   ul_data=${dl_data_size}    pdu_id=${ue_id}
#     SA send mutiple trf ul data    ${ue_id}    number='${ul_data_size}'   ul_data=${ul_data_size}    pdu_id=${ue_id}
# 
# SA send ue '${ue_id}' mutiple trf '${number}' for each '${ul_data}' UL data
#     SA send mutiple trf ul data    ${ue_id}    number=${number}   ul_data=${ul_data}    pdu_id=${ue_id}
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
# Attach one SA UE'${ue_id}'
#     Log To Console   ${\n}-----register SA UE ${ue_id} ------
#     Attach SA ue to 5g cell    SRS_Ports_PerResource2    ${ue_id}    PDU_ID=${ue_id}    GW_ID=${ue_id}
# 
# Multi UE SA Register with start ue id '${start_ue_id}' and ue num '${SA_UE_NUM}'
#     : FOR    ${ue_id}    IN RANGE    ${start_ue_id}    ${SA_UE_NUM}+1
# 
#     #\   airphone_cleanup_egate_console_log
#     \   Log To Console   ${\n}-----register SA UE ${ue_id} ------
# 
#     \    Attach SA ue to 5g cell    SRS_Ports_PerResource2    ${ue_id}    PDU_ID=${ue_id}    GW_ID=${ue_id}
#     \    SA send dl and ul data    ${ue_id}    number=3    dl_data=175M    ul_data=20M    pdu_id=${ue_id}
#     \    Wait '3s' for stabible
# 
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
# Stop ul data transfer
#     [Arguments]    ${UE_ID}
#     airphone_sa_stop_data_traffic    ue_id=${UE_ID}   pdu_id=${UE_ID}   direction=ul
# 
# Detach UE
#     [Arguments]    ${UE_ID}
#     airphone_sa_detach    ue_id=${UE_ID}    timeout=30
# 
# Block Cell
#     [Arguments]    ${phy_cell_id}    ${alias}
#     TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=${alias}
#     ${nrcel_list}=    TAF_ADMIN.Get Parameters For All    NRCEL    timeout=30    connection=${alias}
#     : FOR    ${nrcel}    IN    @{nrcel_list}
#     \    Run Keyword If    '${nrcel.physCellId}'=='${phy_cell_id}' and '${nrcel.administrativeState}'=='Unlocked'
#          ...    Run Keywords    TAF_ADMIN.lock    ${nrcel.id}    timeout=60    connection=${alias}  AND    Wait '60s' for stable
#     TAF_ADMIN.teardown    connection=${alias}
# 
# Unblock Cell
#     [Arguments]    ${phy_cell_id}    ${alias}
#     TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=${alias}
#     ${nrcel_list}=    TAF_ADMIN.Get Parameters For All    NRCEL    timeout=30    connection=${alias}
#     : FOR    ${nrcel}    IN    @{nrcel_list}
#     \    Run Keyword If    '${nrcel.physCellId}'=='${phy_cell_id}' and '${nrcel.administrativeState}'=='Locked'
#          ...    Run Keywords    TAF_ADMIN.unlock    ${nrcel.id}    timeout=60    connection=${alias}  AND    Wait '60s' for stable
#     TAF_ADMIN.teardown    connection=${alias}
# 
# repeat test ${NUM} times
#     : FOR    ${num}    IN RANGE    1    ${NUM}+1
#     \    Log To Console   ${\n}-----test NO-${num} time ------
#     \    Attach SA ue to 5g cell    t2r4_n2    ${ue_id_1}    PDU_ID=${ue_id_1}    GW_ID=${ue_id_1}
#     \    SA send ue '1' mutiple trf '1' for each '90M' UL data
# 
#     \    Attach SA ue to 5g cell    t2r4_n2    ${ue_id_2}    PDU_ID=${ue_id_2}    GW_ID=${ue_id_2}
#     \    SA send ue '2' mutiple trf '1' for each '20M' UL data
# 
#     \    Attach SA ue to 5g cell    t2r4_n2    ${ue_id_3}    PDU_ID=${ue_id_3}    GW_ID=${ue_id_3}
#     \    SA send ue '3' mutiple trf '1' for each '20M' UL data
# 
#     \    Attach SA ue to 5g cell    t2r4_n2    ${ue_id_4}    PDU_ID=${ue_id_4}    GW_ID=${ue_id_4}
#     \    SA send ue '4' mutiple trf '1' for each '20M' UL data
# 
#     \    Attach SA ue to 5g cell    t2r4_n2    ${ue_id_5}    PDU_ID=${ue_id_5}    GW_ID=${ue_id_5}
#     \    SA send ue '5' mutiple trf '1' for each '20M' UL data
# 
#     \    Attach SA ue to 5g cell    t2r4_n2    ${ue_id_6}    PDU_ID=${ue_id_6}    GW_ID=${ue_id_6}
#     \    SA send ue '6' mutiple trf '1' for each '20M' UL data
# 
#     \    Attach SA ue to 5g cell    t2r4_n2    ${ue_id_7}    PDU_ID=${ue_id_7}    GW_ID=${ue_id_7}
#     \    SA send ue '7' mutiple trf '1' for each '20M' UL data
# 
#     \    Attach SA ue to 5g cell    t2r4_n2    ${ue_id_8}    PDU_ID=${ue_id_8}    GW_ID=${ue_id_8}
#     \    SA send ue '8' mutiple trf '1' for each '20M' UL data
#     \    Wait '5s' for stable
# 
#     \    Log To Console   ${\n}-----check no tapering 8 UE's tput ------
#     \    check SA UE'1' dl tput range is '0' to '100' and ul tput range is '80' to '91'
#     \    check SA UE'2' dl tput range is '0' to '100' and ul tput range is '19' to '21'
#     \    check SA UE'3' dl tput range is '0' to '100' and ul tput range is '19' to '21'
#     \    check SA UE'4' dl tput range is '0' to '100' and ul tput range is '19' to '21'
#     \    check SA UE'5' dl tput range is '0' to '100' and ul tput range is '19' to '21'
#     \    check SA UE'6' dl tput range is '0' to '100' and ul tput range is '19' to '21'
#     \    check SA UE'7' dl tput range is '0' to '100' and ul tput range is '19' to '21'
#     \    check SA UE'8' dl tput range is '0' to '100' and ul tput range is '19' to '21'
# 
#     \    Start collect ttitrace
#     \    Wait for '3s' to stop ttitrace with name'${num}_tti1_tap_false_8ue'
#     \    Check bler and pair ratio without tapering ${num}_tti1_tap_false_8ue_ul.csv
# 
#     \    Online change actUlMuMimoTapering true
#     \    Online change ulMaxMuMimoLayer2
#     \    Online change ulMaxMuMimoLayer4
# 
#     \    Stop 8 SA UEs UL data transfer
#     \    DeRegister 8 SA UEs
#     \    Log To Console   ${\n}-----re-attach ue1，2，3，4，5，6，7，8------
# 
#     \    Attach SA ue to 5g cell    t2r4_n2    ${ue_id_1}    PDU_ID=${ue_id_1}    GW_ID=${ue_id_1}
#     \    SA send ue '1' mutiple trf '1' for each '90M' UL data
#     \    Attach SA ue to 5g cell    t2r4_n2    ${ue_id_2}    PDU_ID=${ue_id_2}    GW_ID=${ue_id_2}
#     \    SA send ue '2' mutiple trf '1' for each '20M' UL data
#     \    Attach SA ue to 5g cell    t2r4_n2    ${ue_id_3}    PDU_ID=${ue_id_3}    GW_ID=${ue_id_3}
#     \    SA send ue '3' mutiple trf '1' for each '20M' UL data
#     \    Attach SA ue to 5g cell    t2r4_n2    ${ue_id_4}    PDU_ID=${ue_id_4}    GW_ID=${ue_id_4}
#     \    SA send ue '4' mutiple trf '1' for each '20M' UL data
#     \    Attach SA ue to 5g cell    t2r4_n2    ${ue_id_5}    PDU_ID=${ue_id_5}    GW_ID=${ue_id_5}
#     \    SA send ue '5' mutiple trf '1' for each '20M' UL data
#     \    Attach SA ue to 5g cell    t2r4_n2    ${ue_id_6}    PDU_ID=${ue_id_6}    GW_ID=${ue_id_6}
#     \    SA send ue '6' mutiple trf '1' for each '20M' UL data
#     \    Attach SA ue to 5g cell    t2r4_n2    ${ue_id_7}    PDU_ID=${ue_id_7}    GW_ID=${ue_id_7}
#     \    SA send ue '7' mutiple trf '1' for each '20M' UL data
#     \    Attach SA ue to 5g cell    t2r4_n2    ${ue_id_8}    PDU_ID=${ue_id_8}    GW_ID=${ue_id_8}
#     \    SA send ue '8' mutiple trf '1' for each '20M' UL data
#     \    Wait '10s' for stable
# 
#     \    Log To Console   ${\n}-----check tapering 8 UE's tput ------
#     \    check SA UE'1' dl tput range is '0' to '100' and ul tput range is '80' to '91'
#     \    check SA UE'2' dl tput range is '0' to '100' and ul tput range is '19' to '21'
#     \    check SA UE'3' dl tput range is '0' to '100' and ul tput range is '19' to '21'
#     \    check SA UE'4' dl tput range is '0' to '100' and ul tput range is '19' to '21'
#     \    check SA UE'5' dl tput range is '0' to '100' and ul tput range is '19' to '21'
#     \    check SA UE'6' dl tput range is '0' to '100' and ul tput range is '19' to '21'
#     \    check SA UE'7' dl tput range is '0' to '100' and ul tput range is '19' to '21'
#     \    check SA UE'8' dl tput range is '0' to '100' and ul tput range is '19' to '21'
# 
#     \    Start collect ttitrace
#     \    Wait for '3s' to stop ttitrace with name'${num}_tti2_tapH15V0_8ue'
#     \    Check bler and pair ratio with tapering ${num}_tti2_tapH15V0_8ue_ul.csv
# 
#     \    Stop 8 SA UEs UL data transfer
#     \    SA send ue '1' mutiple trf '1' for each '70M' UL data
#     \    SA send ue '2' mutiple trf '1' for each '70M' UL data
#     \    SA send ue '3' mutiple trf '1' for each '70M' UL data
#     \    SA send ue '4' mutiple trf '1' for each '70M' UL data
#     \    SA send ue '5' mutiple trf '1' for each '70M' UL data
#     \    SA send ue '6' mutiple trf '1' for each '70M' UL data
#     \    SA send ue '7' mutiple trf '1' for each '70M' UL data
#     \    SA send ue '8' mutiple trf '1' for each '70M' UL data
#     \    Wait '10s' for stable
# 
#     \    Start collect ttitrace
#     \    Wait for '3s' to stop ttitrace with name'${num}_tti3_tapH15V0_8ue_fulldata'
#     \    Check bler and per slot ue num with ${num}_tti3_tapH15V0_8ue_fulldata_ul.csv
#     \    Log To Console   ${\n}-----check tapering 8 UE's full data tput ------
#     \    wait Until Keyword Succeeds    12s    4s   check SA UE'1' dl tput range is '0' to '100' and ul tput range is '31' to '40'
#     \    wait Until Keyword Succeeds    12s    4s   check SA UE'2' dl tput range is '0' to '100' and ul tput range is '31' to '40'
#     \    wait Until Keyword Succeeds    12s    4s   check SA UE'3' dl tput range is '0' to '100' and ul tput range is '31' to '40'
#     \    wait Until Keyword Succeeds    12s    4s   check SA UE'4' dl tput range is '0' to '100' and ul tput range is '31' to '40'
#     \    wait Until Keyword Succeeds    12s    4s   check SA UE'5' dl tput range is '0' to '100' and ul tput range is '31' to '40'
#     \    wait Until Keyword Succeeds    12s    4s   check SA UE'6' dl tput range is '0' to '100' and ul tput range is '31' to '40'
#     \    wait Until Keyword Succeeds    12s    4s   check SA UE'7' dl tput range is '0' to '100' and ul tput range is '31' to '40'
#     \    wait Until Keyword Succeeds    12s    4s   check SA UE'8' dl tput range is '0' to '100' and ul tput range is '31' to '40'
# 
#     \    Log To Console   ${\n}-----detach all ue1,2,3,4,5,6,7,8------
#     \    Stop 8 SA UEs UL data transfer
#     \    DeRegister 8 SA UEs
#     \    Log To Console   ${\n}-----block cell ------
#     \    Block Cell    1    gNB
#     \    Wait '10s' for stable
#     \    Log To Console   ${\n}-----unblock cell ------
#     \    Unblock Cell  1    gNB
#     \    Wait '10s' for stable
#     \    Log To Console   ${\n}-----block cell again------
#     \    Block Cell    1    gNB
#     \    Wait '10s' for stable
#     \    Log To Console   ${\n}-----unblock cell again------
#     \    Unblock Cell  1    gNB
#     \    Wait '10s' for stable
#     \    Online change actUlMuMimoTapering false
# 
# Check bler and pair ratio without tapering ${tti_tag}
#     Log To Console   ---check tti ---${\n}
#     Set test Variable    ${tti_title_tag}    ${tti_tag}
#     run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tti_B_b5_case08_without_tapering_ul.ini     i
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Check bler and pair ratio with tapering ${tti_tag}
#     Log To Console   ---check tti ---${\n}
#     Set test Variable    ${tti_title_tag}    ${tti_tag}
#     run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tti_B_b5_case08_tapering_ul.ini     i
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Check bler and per slot ue num with ${tti_tag}
#     Log To Console   ---check tti ---${\n}
#     Set test Variable    ${tti_title_tag}    ${tti_tag}
#     run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tti_B_b5_case08_fulldata_ul.ini     i
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# DeRegister ${NUM} SA UEs
#     : FOR    ${num}    IN RANGE    1    ${NUM}+1
#     \   airphone_sa_detach    ue_id=${num}    timeout=30
#     \   Wait '2s' for stabible
# 
# Stop ${NUM} SA UEs UL data transfer
#     : FOR    ${UE_ID}    IN RANGE    1    ${NUM}+1
#     \   airphone_sa_stop_data_traffic    ue_id=${UE_ID}   pdu_id=${UE_ID}   direction=ul
# 
# test teardown for collect titrace
#     run keyword and ignore error    Start collect ttitrace
#     run keyword and ignore error    Wait for '3s' to stop ttitrace with name'teardown_tti'
#     run keyword and continue on failure    Stop capture gnb and ap syslog in 'after_onair' file
#     Common Test Teardown