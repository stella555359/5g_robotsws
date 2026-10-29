*** Settings ***
Documentation
...   Author: Liu Renhui, Du Ning
...   Contact: renhui-david.liu@nokia-sbell.com, ning.du@nokia-sbell.com
...   Description: This is the module test case

Resource          ../Module.robot
Resource          ../../../../RRM/RAN_PZ_HAZ_1/Resources/Classical/RRM_MultiBTS_Common_Resource.robot

# Suite Setup       Common MultiBTS Suite Setup For RRM
# Test Setup        Common MultiBTS Test Setup For RRM    other_method=Return From Keyword
# Test Teardown     Common MultiBTS Test Teardown For RRM
# Suite Teardown    Common MutliBTS Suite Teardown For RRM


Resource          ../Log_Analysis.robot
Resource          ../Log_Collection.robot


Force Tags        RAN_VRF_HAZ1

Test Timeout      60 minutes

*** Variables ***
#&{dcap_info}    host=10.69.9.51    port=443    username=dcapuser    password=Nokia1234!
${wireshark_path}        /home/ute/tshark/wireshark/Wireshark_20240527005249.pcap
@{field_names_1}         frame.time_epoch
&{analysis_dict_1}       filter_conditions=x2ap && nr-rrc.bandNR    output_field_names=${field_names_1}

@{field_names_2}         nr-rrc.bandNR     sctp.chunk_flags
&{analysis_dict_2}       filter_conditions=x2ap && nr-rrc.bandNR    output_field_names=${field_names_2}
&{analysis_dict_3}       filter_conditions=x2ap && nr-rrc.bandNR
&{analysis_dict_4}       filter_conditions=x2ap && nr-rrc.bandNR12345678

# bip
# SBTS24R2_ENB_9999_240220_000019
${bip_path}                  /home/ute/tshark/bip/BTS-3388_10.69.68.210_20240409_101531_BIP.zip

@{bip_field_names_1}         UlData_prachReceiveReqSubcell_t.prachPrbOffset    3gpp.slot
@{condition_1}    UlData_prachReceiveReqSubcell_t.prachPrbOffset    <    10    # 9
@{condition_2}    3gpp.slot    >    0     # 4
#@{conditions_1}    and    ${condition_1}    ${condition_2}
@{conditions_1}    and    ${condition_1}
#@{stat_condition_1}     max        UlData_prachReceiveReqSubcell_t.prachPrbOffset    <    10
@{stat_condition_1}     max        UlData_prachReceiveReqSubcell_t.prachPrbOffset    >    10
@{stat_condition_2}     average    3gpp.slot    <    10
#@{stat_conditions_1}    and        ${stat_condition_1}    ${stat_condition_2}
@{stat_conditions_1}    and        ${stat_condition_1}
&{bip_check_rules_1}         basic_rules=${conditions_1}     statistics_rules=${stat_conditions_1}
&{analysis_dict_bip_1}       filter_conditions=UlData_prachReceiveReqSubcell_t.prachPrbOffset
...    output_field_names=${bip_field_names_1}    check_rules=${bip_check_rules_1}

# tti classical
${tti_path}      /home/ute/tshark/tti/BTS-3388_10.69.68.210_20240625_184822_TTI.zip
@{tti_condition_1}    startSymbol    >    10    # 3, 13
@{tti_condition_2}    numOfPrb    >    50     # 4
@{tti_conditions_1}    and    ${tti_condition_1}    ${tti_condition_2}
@{tti_stat_condition_1}     average    startSymbol    >    0
@{tti_stat_condition_2}     max        numOfPrb       >    200
@{tti_stat_conditions_1}    and        ${tti_stat_condition_1}    ${tti_stat_condition_2}
&{tti_check_rules_1}         basic_rules=${tti_conditions_1}     statistics_rules=${tti_stat_conditions_1}
&{tti_analysis_dict_1}       check_rules=${tti_check_rules_1}

# tti cloudran
${tti_cloud_path}    /home/ute/tshark/tti/cloudran/dcap1718851522.2514632.zip
@{tti_cloud_condition_1}    dlFdSchedData.rrmDlBufBasedDowngradedMcs    >    10
@{tti_cloud_condition_2}    dlFdSchedData.rrmDlUsedMcs    >    10
@{tti_cloud_conditions_1}    and    ${tti_cloud_condition_1}    ${tti_cloud_condition_2}
@{tti_cloud_stat_condition_1}     average    dlFdSchedData.rrmDlBufBasedDowngradedMcs    >    5
@{tti_cloud_stat_condition_2}     max        dlFdSchedData.rrmDlUsedMcs    >    200
@{tti_cloud_stat_conditions_1}    and        ${tti_cloud_stat_condition_1}    ${tti_cloud_stat_condition_2}
&{tti_cloud_check_rules_1}         basic_rules=${tti_cloud_conditions_1}     statistics_rules=${tti_cloud_stat_conditions_1}
&{tti_cloud_analysis_dict_1}       check_rules=${tti_cloud_check_rules_1}

# snapshot
${snapshot_path}          /home/ute/tshark/snapshot/snapshot_gnb0/
&{snapshot_filter_conditions}      filename=MRBTS    postfix=.ims2
&{analysis_dict_snapshot_1}      filter_conditions=${snapshot_filter_conditions}

# syslog
${syslog_path}          /home/ute/tshark/syslog/syslog_gnb0/
&{syslog_filter_conditions}      line_regex=Averaged Measurements    element_regex=slotDelay\=\\d
&{analysis_dict_syslog_1}      filter_conditions=${syslog_filter_conditions}

*** Test Cases ***
# Normal cases
T01_Wireshark
    [Tags]    wireshark
    ${wireshark_argument}   Create Dictionary   wireshark_options=-i any
    ${dict_argument}   Create Dictionary   argument=${wireshark_argument}
    Log Collection    start    wireshark    product_type=gnb    bts_index=${0}    dict_argument=${dict_argument}
    sleep    10s
    ${local_file_path}    Log Collection    stop_and_download    wireshark    product_type=gnb    bts_index=${0}
    Log To Console    \nwireshark log: ${local_file_path}

    ${result}=    Log Analysis    check    wireshark    ${local_file_path}    ${analysis_dict_1}
    Log To Console    \nAnalyze log: ${result}

    ${result}=    Log Analysis    check    wireshark    ${local_file_path}    ${analysis_dict_2}
    Log To Console    \nAnalyze log: ${result}

    ${result}=    Log Analysis    check    wireshark    ${local_file_path}    ${analysis_dict_3}
    Log To Console    \nAnalyze log: ${result}

    ${result}=    Log Analysis    check    wireshark    ${local_file_path}    ${analysis_dict_4}
    Log To Console    \nAnalyze log: ${result}

    # filter
    ${result}=    Log Analysis    filter    wireshark    ${local_file_path}    ${analysis_dict_1}
    Log To Console    \nFilter log: ${result}

    ${result}=    Log Analysis    filter    wireshark    ${local_file_path}    ${analysis_dict_2}
    Log To Console    \nFilter log: ${result}

    ${result}=    Log Analysis    filter    wireshark    ${local_file_path}    ${analysis_dict_3}
    Log To Console    \nFilter log: ${result}

    ${result}=    Log Analysis    filter    wireshark    ${local_file_path}    ${analysis_dict_4}
    Log To Console    \nFilter log: ${result}

T02_Bip
    [Tags]    bip
    ${BBMOD_Index}    set variable    ${5}
    ${bip_argument}   Create Dictionary   bip_options=-c ${BBMOD_Index}
    ${dict_argument}   Create Dictionary   argument=${bip_argument}
    Log Collection    start    bip    product_type=gnb    bts_index=${0}    dict_argument=${dict_argument}
    sleep    30s
    ${local_file_path}    Log Collection    stop_and_download    bip    product_type=gnb    bts_index=${0}
    Log To Console    \nBip log: ${local_file_path}
    # check
    ${result}=    Log Analysis    check    bip    ${local_file_path}    ${analysis_dict_bip_1}
    Log To Console    \nAnalyze log: ${result}

T03_TTI_Classical
    [Tags]    tti
    ${Cell_Index}    set variable    ${2}
    ${tti_argument}   Create Dictionary   tti_options=-C ${Cell_Index}
    ${dict_argument}   Create Dictionary   argument=${tti_argument}
    Log Collection    start    tti    product_type=gnb    bts_index=${0}    dict_argument=${dict_argument}
    sleep    4s
    ${local_file_path}    Log Collection    stop_and_download    tti    product_type=gnb    bts_index=${0}
    Log To Console    \nTTI log: ${local_file_path}

    # check
    ${result}=    Log Analysis    check    tti    ${local_file_path}    ${tti_analysis_dict_1}
    Log To Console    \nAnalyze log: ${result}


T04_Snapshot
    [Tags]    snapshot
    ${local_file_path}    Log Collection    start    snapshot    product_type=gnb    bts_index=${0}
    Log To Console    \nSnapshot log: ${local_file_path}
    # check
    ${result}=    Log Analysis    check    snapshot    ${local_file_path}    ${analysis_dict_snapshot_1}
    Log To Console    \nAnalyze log: ${result}

T05_Syslog
    [Tags]    syslog
    Log Collection    start    syslog    product_type=gnb    bts_index=${0}
    sleep    20s
    ${local_file_path}    Log Collection    stop_and_download    syslog    product_type=gnb    bts_index=${0}
    Log To Console    \nSyslog log: ${local_file_path}
    # check
    ${result}=    Log Analysis    filter    syslog    ${local_file_path}    ${analysis_dict_syslog_1}
    Log To Console    \nAnalyze log: ${result}



