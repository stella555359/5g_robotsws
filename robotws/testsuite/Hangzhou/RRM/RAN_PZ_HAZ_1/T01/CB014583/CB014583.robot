*** Settings ***
Documentation
...   Author: jinying.guo@nokia.com
...   Contact: jinying.guo@nokia.com
...   Description: This user scenario describes

Library     ute_wtssim
Library     String
Library     OperatingSystem
Library     Collections
Library     ta5g_ue_measurements
Library     taf.config.wts        WITH NAME    wts_conf

Suite Setup    Common Suite Setup For AIC
Suite Teardown    Common Suite Teardown For AIC

Test Timeout    120 minutes

Resource          ../../Resources/Cloud/AIC_Common_Resource.robot


*** Variables ***
#${14583_cell1_distname}    MRBTS-1/NRBTS-1/NRCELL-1/NNGCC
${14583_cell1_distname}    MRBTS-1/NRBTS-1/NRCELL-1
${target_counter}     M55125C09536,M55125C09537
${target_counter_rule}     max(M55125C09536)==2 and max(M55125C09537)==1

${TL10872_wts}    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T01/CB014583/APCFG/wts_cloud.cfg

*** Test Cases ***
CB014583-CR-05 SA Retainability AMF initiated in session QosFlow Release due to Radionetwork
    [Tags]    QC_239178    QCD_MN_RAN      QCP_RAN_VRF
    [Setup]    Run Keywords    Case Precondition
#    Airphone Operation    edaemon_egate_setup     gnb tag=cloud
    Start Collect Counter    ${14583_cell1_distname}    ${target_counter}    ${target_counter_rule}
    UE Deregister From gNB      ue_id=1
    NG_Flow_Rel_AMF_NGGENRSN
    sleep  50s
    Stop Collect Counter and verify PM counters
#    sleep    360s
    [Teardown]    Case Postcondition

*** Keywords ***
UE Deregister From gNB
    [Arguments]    ${ue_id}=1
    Airphone Execute Egate Command   cmd=ue_deregister id=${ue_id} ue_deregister_type=switch_off
    sleep   5

Start Collect Counter
    [Arguments]    ${distname}    ${counter}    ${counter_rule}
    ${rule1}    Catenate
    ...         Distname: ${distname};
    ...         Counter: ${counter};
    ...         Counter rule: ${counter_rule};
    ${rule_list}    Create List    ${rule1}
    Log To Console    \nThe rule list is: ${rule_list}
    Counter Operation    operation=start_collect_counter    product_type=vcu    bts_index=0    counter_rule=${rule_list}
    ...                  wait_for_next_counter_generate=${true}

Start Collect Wireshark For Cloud
    Log Collection    start    wireshark_cp    product_type=vcu    bts_index=${0}    cudu_index=${0}
    Log Collection    start    wireshark_cp    product_type=vdu    bts_index=${0}    cudu_index=${0}

Start Collect syslog
    [Arguments]    ${product_type}=vcu
    ${local_file_path}    Log Collection    start    syslog    product_type=${product_type}    bts_index=${0}    cudu_index=${0}
    Log To Console        \nSyslog log of VCU: ${local_file_path}

Stop Collect Counter and verify PM counters
    Log To Console     \nStart to stop collect counter and verify PM counters
    ${result}    Counter Operation    operation=collect_counter_and_check_rule    product_type=vcu    bts_index=0    cudu_index=0
    Log To Console    \nCounter Rule Collect and Check Result is: ${result}



_Set Iphy Ip
  [Documentation]  Distinguish general or multi cpif deployment
  Log To Console  \n===configure IPs on PC ===
#  OperatingSystem.Run  sudo ip addr add 10.0.2.121/24 dev eth4  #compatible with other team's lua
#  OperatingSystem.Run  sudo ip addr add 10.0.2.1/24 dev eth4  #already configured in AiC TL
  _Set Iphy X2 Ip Eth3 General
  Log  proxy server ip is 10.0.2.80  console=yes
  Log  10.0.2.90~93 is configured for more proxy servers  console=yes
  FOR  ${number}  IN RANGE  90  94
    OperatingSystem.Run  sudo ip addr add 10.0.2.${number}/24 dev eth4
  END
  _Set Iphy Ng Ip Eth7 General
  _Set Iphy Xn Ip Eth8 General
  OperatingSystem.Run  ip addr show eth3
  OperatingSystem.Run  ip addr show eth4
  OperatingSystem.Run  ip addr show eth7
  OperatingSystem.Run  ip addr show eth8


_Set Iphy X2 Ip Eth3 General
  Log  10.0.1.10,10.0.1.210,10.0.1.60 is reserved for real gNB2-X2c/X2u/S1-u within AiC deployment
  Log  10.0.1.131~137 is reserved for sim-MME/SGW/eNB-1
  Log  10.0.1.138~152 is configured for you to set more sim-(MME/sGW/eNB-x2/gNB-x2)  console=yes
  _Set Eth3 Ip

_Set Eth3 Ip
  FOR  ${number}  IN RANGE  131  153
    OperatingSystem.Run  sudo ip addr add 10.0.1.${number}/24 dev eth3
  END

_Set Iphy Ng Ip Eth7 General
  Log  AMF ip is 10.0.11.1  console=yes
  Log  10.0.11.10,10.0.11.210 is reserved for real gNB2-NG-c/u within AiC deployment
  Log  10.0.11.2~9 is configured for you to set more AMFs  console=yes
  Log  10.0.11.11~30 is configured for you to set more sim-GNB-NGc/u  console=yes
  _Set Eth7 Ip

_Set Eth7 Ip
  FOR  ${number}  IN RANGE  2  10
    OperatingSystem.Run  sudo ip addr add 10.0.11.${number}/24 dev eth7
  END
  FOR  ${number}  IN RANGE  11  31
    OperatingSystem.Run  sudo ip addr add 10.0.11.${number}/24 dev eth7
  END

_Set Iphy Xn Ip Eth8 General
  Log  10.0.12.10,10.0.12.210 is reserved for real gNB2-Xnc/Xnu within AiC deployment
  Log  10.0.12.1~9 is pre-reserved
  Log  10.0.12.11~30 is configured for you to set more sim-GNB-Xnc/u  console=yes
  _Set Eth8 Ip

_Set Eth8 Ip
  FOR  ${number}  IN RANGE  11  31
    OperatingSystem.Run  sudo ip addr add 10.0.12.${number}/24 dev eth8
  END

Case Precondition
    Airphone Operation    operation=edaemon_egate_teardown    product_type=${None}    traffic_info_dic=${None}
    ...                   tag=${None}    cmd=${None}    pass_regexp=${None}    timeout=100s
    Airphone Operation    operation=edaemon_egate_setup
    ...                   product_type=${None}
    ...                   traffic_info_dic=${None}
    ...                   tag=${None}
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=100s
#    OperatingSystem.Run    sudo iptables -F
#    OperatingSystem.Run    sudo ip addr add 10.0.11.2/32 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.11.1/32 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.12.11/32 dev eth3
    _Set Iphy Ip
    Airphone Operation    operation=env_setup_sa
    ...                   product_type=vdu
    ...                   traffic_info_dic=${None}
    ...                   tag=cloud
    ...                   cmd=${None}
    ...                   pass_regexp=${None}
    ...                   timeout=12000s

Case Postcondition
    log to console    Case Postcondition
    OperatingSystem.Run    sudo ip addr del 10.0.11.2/32 dev eth3
    OperatingSystem.Run    sudo ip addr del 10.0.11.1/32 dev eth3
    OperatingSystem.Run    sudo ip addr del 10.0.12.11/32 dev eth3
    Airphone Operation    operation=edaemon_egate_teardown    product_type=${None}    traffic_info_dic=${None}
    ...                   tag=${None}    cmd=${None}    pass_regexp=${None}    timeout=100s


NG_Flow_Rel_AMF_NGGENRSN
    [Arguments]    ${ue_id}=1    ${pass_regexp}=QoS Routing Table    ${ue_gw}=1
    Airphone Execute Egate Command    cmd=ue_register id=${ue_id}
    sleep    2s
    Airphone Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    sleep    1s
    ${cmd}    Catenate   ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${ue_gw}
    Airphone Execute Egate Command    cmd=${cmd}    pass_regexp=${pass_regexp}
    sleep    5s
    Airphone Execute Egate Command   cmd=ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=3 by=amf
    ${cmd_trf}    Catenate   trf_data_start ue=${ue_id} pdu=1 qfi=3 mbps=1 dir=dl trf_id=1
    Airphone Execute Egate Command    cmd=${cmd_trf}
    ${cmd_amf}    Catenate   amf_ue_pdu_release_param id=1 ue=${ue_id} cause=RN_release_due_to_ngran_generated_reason
    Airphone Execute Egate Command    cmd=${cmd_amf}
    ${cmd_pdu}    Catenate   ue_pdu_session_release ue=1 pdu=1 by=amf
    Airphone Execute Egate Command    cmd=${cmd_pdu}
    ${cmd_ue}    Catenate   ue_deregister id=1 ue_deregister_type=switch_off
    Airphone Execute Egate Command    cmd=${cmd_ue}

