*** Settings ***
Documentation
...   Author: xiaowei.1.chen@nokia-sbell.com
...   Contact: xiaowei.1.chen@nokia-sbell.com
...   Description: This user scenario describes

Suite Setup       Common Suite Setup For AIC
Suite Teardown    Common Suite Teardown For AIC

Test Timeout    120 minutes

Resource          ../../../Resources/Cloud/AIC_Common_Resource.robot
Resource          ../../../T01/Resources/RRM2_RRM_Resource.robot

Library     ute_wtssim
Library     String
Library     OperatingSystem
Library     Collections
Library     ta5g_ue_measurements
Library     taf.config.wts        WITH NAME    wts_conf

*** Variables ***
${Setup_5QI5_Success}
...    Setup QosFlow with QFI:1 5QI:5
${TL10760_wts}    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T01/New_Feature_TA/CB013550/APCFG/wts_cloud.cfg
*** Test Cases ***

Case_Precondition
    Run Keyword And Ignore Error   Scout_cli start
    Prepare Netrc On VM
    Case Precondition
    sleep    10min

[1]CB013550-A-CR-Measurements for counting the UL Air interface mute rate during a VoNR call in BIN1
    [Tags]    QC_145640       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...   Description: This user scenario is for creating measurements for counting the UL Air interface mute rate during a VoNR call
    [Setup]
#    Airphone Operation    edaemon_egate_setup     gnb tag=cloud
    Modify actVonrPmCount to true
    UE Deregister From gNB      ue_id=2
    Start Collect Mutli Counter For UL BIN1
    UE Register And PDU Session Setup   ue_id=2    cell_id=3      pass_regexp=${Setup_5QI5_Success}
    UE Modify new PDU    ue_id=2
    Start UL mute for BIN1
    UE Deregister From gNB      ue_id=2
    Stop Collect Mutli Counter

    Modify actVonrPmCount to false
    sleep   10s
    Start Collect Mutli Counter For UL De-active feature
    UE Register And PDU Session Setup   ue_id=2    cell_id=3      pass_regexp=${Setup_5QI5_Success}
    UE Modify new PDU    ue_id=2
    Start UL mute for BIN1
    Stop Collect Mutli Counter
    UE Deregister From gNB      ue_id=2

    Modify actVonrPmCount to true
[1]CB013550-B-CR-Measurements for counting the DL Backhaul interface mute rate during a VoNR call in BIN1
    [Tags]    QC_145641       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...   Description: This user scenario is for creating measurements for counting the DL Backhaul interface mute rate during a VoNR call.
    [Setup]
#    Airphone Operation    edaemon_egate_setup     gnb tag=cloud
    UE Deregister From gNB      ue_id=2
    Start Collect Mutli Counter For DL BIN1
    UE Register And PDU Session Setup   ue_id=2    cell_id=3      pass_regexp=${Setup_5QI5_Success}
    UE Modify new PDU    ue_id=2
    Start DL mute for BIN1
    UE Deregister From gNB      ue_id=2
    Stop Collect Mutli Counter

    Modify actVonrPmCount to false

    Start Collect Mutli Counter For DL De-active feature
    UE Register And PDU Session Setup   ue_id=2    cell_id=3      pass_regexp=${Setup_5QI5_Success}
    UE Modify new PDU    ue_id=2
    Start DL mute for BIN1
    Stop Collect Mutli Counter
    UE Deregister From gNB      ue_id=2

    Modify actVonrPmCount to true

[1]CB013550-C-CR-Measurements for counting the DL Air interface mute rate during a VoNR call in BIN20
    [Tags]    QC_145642       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...   Description: This user scenario is for creating measurements for counting the UL Air interface mute rate during a VoNR call
    [Setup]
#    Airphone Operation    edaemon_egate_setup     gnb tag=cloud
    UE Deregister From gNB      ue_id=2
    Start Collect Mutli Counter For DL BIN20 For C
    UE Register And PDU Session Setup   ue_id=2    cell_id=3      pass_regexp=${Setup_5QI5_Success}
    UE Modify new PDU    ue_id=2
    Start DL mute for BIN20 For C
    UE Deregister From gNB      ue_id=2
    Stop Collect Mutli Counter For vdu

*** Keywords ***
Case Precondition

    Airphone Operation    operation=local_ap_upgrade    product_type=${None}
    ...               eth_config_path=/home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T01/New_Feature_TA/CB013550/ap_tl10760.json
    ...               ap_build=${None}
    OperatingSystem.Run    cp ${TL10760_wts} /opt/wts/latest/basic_setup.cfg

    Airphone Operation    operation=edaemon_egate_setup
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=100s
    Airphone Operation    operation=env_setup_sa
    ...                   product_type=vdu
    ...                   traffic_info_dic=${None}
    ...                   tag=cloud
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=12000s
#    [Teardown]    Airphone Operation    operation=edaemon_egate_teardown    product_type=${None}    traffic_info_dic=${None}
#    ...                                 tag=${None}    cmd=${None}    pass_regexp=${None}    timeout=100s

UE Register And PDU Session Setup
    [Arguments]    ${ue_id}=2  ${gnb_id}=2  ${cell_id}=3   ${pass_regexp}=QoS Routing Table
    ${cmd}    catenate    amf_ue_ics_param id=1 core_network_assistance_info=on ue_identity_index_value=${ue_id} ue_specific_drx=64
    ...    periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=200
    Airphone Execute Egate Command    cmd=ue_change_location id=${ue_id} enb=${gnb_id} cell=${cell_id}
    Airphone Execute Egate Command    cmd=${cmd}
    Airphone Execute Egate Command    cmd=ue_register id=${ue_id}    pass_regexp=UE now in NG RM Register
    Airphone Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Airphone Execute Egate Command    cmd=ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=1    pass_regexp=${pass_regexp}
    sleep    5s

UE Modify new PDU
    [Arguments]    ${ue_id}=2    ${pdu}=1   ${qosflows_to_add}=2   ${pass_regexp}=QoS Routing Table
    Airphone Execute Egate Command
    ...    cmd=ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_add=${qosflows_to_add} by=amf    pass_regexp=${pass_regexp}
    sleep    5s

Start UL mute for BIN1
    [Arguments]    ${ue_id}=2   ${pdu}=1
    ${cmd}    catenate    trf_data_start ue=${ue_id} pdu=${pdu} qfi=2 dir=ul trf_id=1 rtp_codec=custom rtp_send_silence_period=500
    ...    period_ms=500 burst=1 rtp_sn_skip_count=9 rtp_sn_skip_packet_count_interval=1 rtp_sn_skip_num_cycles=10
    Airphone Execute Egate Command     cmd=${cmd}
    sleep   10s

Start DL mute for BIN1
    [Arguments]    ${ue_id}=2   ${pdu}=1
    ${cmd1}    catenate    trf_data_start ue=${ue_id} pdu=${pdu} qfi=2 dir=dl trf_id=1 rtp_codec=custom rtp_send_silence_period=500
    ...    period_ms=500 burst=1 rtp_sn_skip_count=9 rtp_sn_skip_packet_count_interval=1 rtp_sn_skip_num_cycles=10
    ${cmd2}    catenate    trf_data_start ue=${ue_id} pdu=${pdu} qfi=2 dir=ul trf_id=1 rtp_codec=custom rtp_send_silence_period=500
    ...    period_ms=500 burst=1
    Airphone Execute Egate Command     cmd=${cmd2}
    sleep   5s
    Airphone Execute Egate Command     cmd=${cmd1}
    sleep   10s
Start DL mute for BIN20 For C
    [Arguments]    ${ue_id}=2   ${pdu}=1

    Airphone Execute Egate Command     trf_data_start ue=${ue_id} pdu=${pdu} qfi=2 dir=dl kbps=500
    sleep   5s
    ${cmd}    catenate    bler_testmode_nr profile_id=1 vonr_lcid=5 num_vonr_mac_sdus_to_drop=150
    ...    arg_mute_duration_in_slots=2460
    Airphone Execute Egate Command     cmd=${cmd}
    sleep   5s
    Airphone Execute Egate Command     ue_testmode_set_nr id=2 profile_id=1 testmode=bler scell=0 action=activate
    sleep   60s
    Airphone Execute Egate Command     ue_testmode_set_nr id=2 profile_id=1 testmode=bler scell=0 action=deactivate
    sleep   5s

Start Collect Wireshark For Cloud
    Log Collection    start    wireshark_cp    product_type=vcu    bts_index=${0}    cudu_index=${0}
    Log Collection    start    wireshark_cp    product_type=vdu    bts_index=${0}    cudu_index=${0}

Stop Collect Wireshark For Cloud
    ${local_file_path}    Log Collection    stop_and_download    wireshark_cp    product_type=vcu    bts_index=${0}    cudu_index=${0}
    ${local_file_path}    Log Collection    stop_and_download    wireshark_cp    product_type=vdu    bts_index=${0}    cudu_index=${0}
    Log To Console        \nWireshark log of VCU: ${local_file_path}
    Log To Console        \nWireshark log of VDU: ${local_file_path}

Start Collect Mutli Counter For UL BIN1
    ${rule_list}    Create List
    ${rule1}    Catenate
    ...         Distname: MRBTS-10760/NRBTS-10760/NRCELL-3;
    ...         Counter: M55350C20023 to M55350C20032;
    ...         Counter rule:avg(M55350C20023 to M55350C20032)==0;
    append to list  ${rule_list}    ${rule1}

    ${rule2}    Catenate
    ...         Distname: MRBTS-10760/NRBTS-10760/NRCELL-3;
    ...         Counter: M55350C20022;
    ...         Counter rule:avg(M55350C20022)>=10;
    append to list  ${rule_list}    ${rule2}

    ${rule3}    Catenate
    ...         Distname:MRBTS-10760/NRBTS-10760/NRCELL-3;
    ...         Counter: M55350C20033;
    ...         Counter rule:avg(M55350C20033)>=1;
    append to list  ${rule_list}    ${rule3}
    ${rule4}    Catenate
    ...         Distname: MRBTS-10760/NRBTS-10760/NRCELL-3;
    ...         Counter: M55350C20052;
    ...         Counter rule:avg(M55350C20052)>=1;
    append to list  ${rule_list}    ${rule4}
    Counter Operation    operation=start_collect_counter    product_type=vcu
    ...                                                     bts_index=0
    ...                                                     counter_rule=${rule_list}

Start Collect Mutli Counter For UL De-active feature
    ${rule_list}    Create List
    ${rule1}    Catenate
    ...         Distname: MRBTS-10760/NRBTS-10760/NRCELL-3;
    ...         Counter: M55350C20023 to M55350C20032;
    ...         Counter rule:avg(M55350C20023 to M55350C20032)==0;
    append to list  ${rule_list}    ${rule1}

    ${rule2}    Catenate
    ...         Distname: MRBTS-10760/NRBTS-10760/NRCELL-3;
    ...         Counter: M55350C20022;
    ...         Counter rule:avg(M55350C20022)==0;
    append to list  ${rule_list}    ${rule2}

    ${rule3}    Catenate
    ...         Distname:MRBTS-10760/NRBTS-10760/NRCELL-3;
    ...         Counter: M55350C20033;
    ...         Counter rule:avg(M55350C20033)==0;
    append to list  ${rule_list}    ${rule3}
    ${rule4}    Catenate
    ...         Distname: MRBTS-10760/NRBTS-10760/NRCELL-3;
    ...         Counter: M55350C20052;
    ...         Counter rule:avg(M55350C20052)==0;
    append to list  ${rule_list}    ${rule4}
    Counter Operation    operation=start_collect_counter    product_type=vcu
    ...                                                     bts_index=0
    ...                                                     counter_rule=${rule_list}

Start Collect Mutli Counter For DL BIN1
    ${rule_list}    Create List
    ${rule1}    Catenate
    ...         Distname: MRBTS-10760/NRBTS-10760/NRCELL-3;
    ...         Counter: M55350C20035 to M55350C20044;
    ...         Counter rule:avg(M55350C20035 to M55350C20044)==0;
    append to list  ${rule_list}    ${rule1}

    ${rule2}    Catenate
    ...         Distname: MRBTS-10760/NRBTS-10760/NRCELL-3;
    ...         Counter: M55350C20034;
    ...         Counter rule:avg(M55350C20034)>=10;
    append to list  ${rule_list}    ${rule2}

    ${rule3}    Catenate
    ...         Distname:MRBTS-10760/NRBTS-10760/NRCELL-3;
    ...         Counter: M55350C20045;
    ...         Counter rule:avg(M55350C20045)>=10;
    append to list  ${rule_list}    ${rule3}
    ${rule4}    Catenate
    ...         Distname: MRBTS-10760/NRBTS-10760/NRCELL-3;
    ...         Counter: M55350C20051;
    ...         Counter rule:avg(M55350C20051)>=1;
    append to list  ${rule_list}    ${rule4}
    Counter Operation    operation=start_collect_counter    product_type=vcu
    ...                                                     bts_index=0
    ...                                                     counter_rule=${rule_list}

Start Collect Mutli Counter For DL BIN20 For C
    ${rule_list}    Create List
    ${rule1}    Catenate
    ...         Distname: MRBTS-10760/NRBTS-10760/NRCELL-3;
    ...         Counter: M55310C20006 to M55310C20024;
    ...         Counter rule:avg(M55310C20006 to M55310C20024)==0;
    append to list  ${rule_list}    ${rule1}

    ${rule2}    Catenate
    ...         Distname: MRBTS-10760/NRBTS-10760/NRCELL-3;
    ...         Counter: M55310C20026;
    ...         Counter rule:avg(M55310C20026)>=1;
    append to list  ${rule_list}    ${rule2}

    ${rule3}    Catenate
    ...         Distname:MRBTS-10760/NRBTS-10760/NRCELL-3;
    ...         Counter: M55310C20027;
    ...         Counter rule:avg(M55310C20027)>=1;
    append to list  ${rule_list}    ${rule3}
    ${rule4}    Catenate
    ...         Distname: MRBTS-10760/NRBTS-10760/NRCELL-3;
    ...         Counter: M55310C20025;
    ...         Counter rule:avg(M55310C20025)>=1;
    append to list  ${rule_list}    ${rule4}
    Counter Operation    operation=start_collect_counter    product_type=vdu
    ...                                                     bts_index=0
    ...                                                     counter_rule=${rule_list}
Start Collect Mutli Counter For DL De-active feature
    ${rule_list}    Create List
    ${rule1}    Catenate
    ...         Distname: MRBTS-10760/NRBTS-10760/NRCELL-3;
    ...         Counter: M55350C20035 to M55350C20044;
    ...         Counter rule:avg(M55350C20035 to M55350C20044)==0;
    append to list  ${rule_list}    ${rule1}

    ${rule2}    Catenate
    ...         Distname: MRBTS-10760/NRBTS-10760/NRCELL-3;
    ...         Counter: M55350C20034;
    ...         Counter rule:avg(M55350C20034)==0;
    append to list  ${rule_list}    ${rule2}

    ${rule3}    Catenate
    ...         Distname:MRBTS-10760/NRBTS-10760/NRCELL-3;
    ...         Counter: M55350C20045;
    ...         Counter rule:avg(M55350C20045)==0;
    append to list  ${rule_list}    ${rule3}
    ${rule4}    Catenate
    ...         Distname: MRBTS-10760/NRBTS-10760/NRCELL-3;
    ...         Counter: M55350C20051;
    ...         Counter rule:avg(M55350C20051)==0;
    append to list  ${rule_list}    ${rule4}
    Counter Operation    operation=start_collect_counter    product_type=vcu
    ...                                                     bts_index=0
    ...                                                     counter_rule=${rule_list}
Stop Collect Mutli Counter
    ${value1}    Counter Operation    operation=collect_counter_and_check_rule    product_type=vcu    bts_index=0    cudu_index=0

Stop Collect Mutli Counter For vdu
    ${value1}    Counter Operation    operation=collect_counter_and_check_rule    product_type=vdu    bts_index=0    cudu_index=0

Modify actVonrPmCount to false
    @{para_list}          Create List    actVonrPmCount
    @{mo_list_vdu}        Create List    MRBTS-10760/NRBTS-10760
    @{value_list_true}    Create List    false
    ${out}                Parameter Operation    operation=parameter_update    product_type=vcu
    ...                                          para_list=@{para_list}    value_list=@{value_list_true}    mo_list=@{mo_list_vdu}
    Log To Console        VCU paramter update result: ${out}
    sleep   5s

Modify actVonrPmCount to true
    @{para_list}          Create List    actVonrPmCount
    @{mo_list_vdu}        Create List    MRBTS-10760/NRBTS-10760
    @{value_list_true}    Create List    true
    ${out}                Parameter Operation    operation=parameter_update    product_type=vcu
    ...                                          para_list=@{para_list}    value_list=@{value_list_true}    mo_list=@{mo_list_vdu}
    Log To Console        VCU paramter update result: ${out}
    sleep   5s

UE Deregister From gNB
    [Arguments]    ${ue_id}=2
    Airphone Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off