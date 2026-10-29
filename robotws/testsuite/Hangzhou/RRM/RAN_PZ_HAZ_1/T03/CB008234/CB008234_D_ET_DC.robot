*** Settings ***
Documentation
...   author: Dacheng Zhang
...   contact: dacheng.zhang@nokia-sbell.com
...   Description: This is CB008234-SR ET -D CRT cases (Tester: Zhang Dacheng(NSB))

# Resource           ../Resources/common_resource.robot
# Resource           ../../Resources/Classical/RRM_MultiBTS_Common_Resource.robot
# Resource           ../../Resources/Classical/RRM_Common_Resource.robot
# Resource           ../../Resources/Common/Airphone.robot
# Suite Setup        Common MultiBTS Suite Setup For RRM
# Test Setup         Common MultiBTS Test Setup For RRM
# Test Teardown      Run Keywords    Common MultiBTS Test Teardown For RRM    AND
# ...                Run Keyword And Ignore Error    Get SCF Internal Id By Scout    no_ute=${False}
# Suite Teardown     Common MutliBTS Suite Teardown For RRM
# Force Tags         CRT/CIT/CDRT     #Tag Item
# # ...              PY39
# ...                RAN_5G                    #Product [RAN_5G]
# ...                SBTS00           # it is for auto trigger by ute cloud with the release
# ...                RAN_PZ_HAZ_1             #Competence Area
# ...                RAN_PZ_HAZ1_SG07_ST_RRM  #Organization
# ...                TA_LEVEL_22              #Detailed Automation Level[TA_LEVEL_20, TA_LEVEL_21, TA_LEVEL_22]

# Test Timeout       60 minutes

# *** Variables ***
# #reduce global paramter as possilbe and automatically got from gNB or __init__

# &{fault_4334}            faultId=${4334}
# &{fault_4293}            faultId=${4293}
# @{Ohter_Allow_Alarms}    &{fault_4334}    &{fault_4293}
# ${DEBUG_MODE}          ${TRUE}
# ${REMOTE_MODE}       ${TRUE}
# ${PATH}              /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_L2_SW_CN_3/5GC001729/config/SBTS24R2

# *** Test Cases ***
# CB008234_D_AMBR limitation handling when CB006457 ARP based QoS profiling is enabled
#     [Documentation]
#     ...    author: Dacheng Zhang
#     ...    Description:
#     ...    Based on CB006457 theory, when it is activated, new schedulweight is equal
#     ...    to schedulweight * schedulingWeightSF, others are same as CB008234-A#B4/CB008234-B#B4.
#     ...    Pre-condition:
#     ...    CB008234 is enabled (NRBTS.actDlAmbr = 'SA' and NRBTS.actUlAmbr = 'SA')
#     ...    NRBTS.actNonGbrServiceDiff = true: Enable non-GBR service differentiation(5GC000776/5GC001926)
#     ...    NRBTS.NRCELL.actNbrForNonGbrBearers = false: Disable Nominal bitrate (CB008227)
#     ...    NRBTS.actArpBasedQosScaling = true: Enable ARP based QoS scaling: (CB006457)
#     [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim_D_CB006457
#     ...    base_path=${CURDIR}/Airphone
#     ${rule1}    Catenate
#     ...    Distname: MRBTS-1/NRBTS-1;
#     ...    Counter: M55319C12009,M55319C12006;
#     ...    Counter rule: max(M55319C12009)/max(M55319C12006)>7.8;
#     ${rule2}    Catenate
#     ...    Distname: MRBTS-1/NRBTS-1;
#     ...    Counter: M55319C12009,M55319C12006;
#     ...    Counter rule: max(M55319C12009)/max(M55319C12006)<8.2;
#     # The ratio of peak throughput of 5QI-9 and 5QI-6 should be 8:1
#     ${rule_list}    Create List    ${rule1}    ${rule2}
#     Counter Operation    operation=start_collect_counter
#     ...    product_type=gnb
#     ...    counter_rule=${rule_list}
#     Log To Console      ${\n}============= Set 5QI-9 and 5QI-6 are setup with ICS. =============${\n}
#     Airphone.Airphone Execute Egate Command    cmd=smf_param id\=1 additional_qosflows_to_activate\=12
#     ...    pass_regexp=${None}
#     sleep    3s
#     Log To Console      ${\n}============= Modify 5QI-9 ARP to 2. =============${\n}
#     Airphone.Airphone Execute Egate Command    cmd=qosflow_modify qos_flow\=15 priority\=2
#     ...    pass_regexp=${None}
#     sleep    3s
#     Log To Console      ${\n}============= Start to Attach 1st UE =============${\n}
#     Airphone.Airphone Execute Egate Command    cmd=ue_register id\=1
#     ...    pass_regexp=${None}
#     sleep    3s
#     Airphone.Airphone Execute Egate Command    cmd=set_pdu_param ue\=1 pdu\=1 trf_type\=internal
#     ...    pass_regexp=${None}
#     sleep    3s
#     Airphone.Airphone Execute Egate Command    cmd=ue_pdu_session_setup pdu\=1 ue\=1 nwslice\=1 gw\=1
#     ...    pass_regexp=${None}
#     sleep    5s
#     Log To Console      ${\n}============= Start traffic on 5QI-9 and 5QI-6 =============${\n}
#     Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=dl mbps\=20
#     ...    pass_regexp=${None}
#     sleep    3s
#     Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=1 qfi\=2 dir\=dl mbps\=20
#     ...    pass_regexp=${None}
#     Log To Console      ${\n}============= Wait for throughput counter generation =============${\n}
#     Sleep    10 min    reason=wait for counter ready
#     Log To Console      ${\n}============= Check throughput =============${\n}
#     Counter Check 5QI9 and 5QI6

# CB008234_D_AMBR limitation handling during intra-gNB Reestablishment
#     [Documentation]
#     ...    author: Dacheng Zhang
#     ...    Description:
#     ...    UE AMBR (DL&UL) which is provided from AMF shall be enforced by gNB after intra-gNB Reestablishment
#     [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim_A_EC_RJO
#     ...    base_path=${CURDIR}/Airphone
#     ${rule1}    Catenate
#     ...    Distname: MRBTS-1/NRBTS-1;
#     ...    Counter: M55319C12009;
#     ...    Counter rule: max(M55319C12009)>185000;
#     ${rule2}    Catenate
#     ...    Distname: MRBTS-1/NRBTS-1;
#     ...    Counter: M55319C16009;
#     ...    Counter rule: max(M55319C16009)>185000;
#     ${rule_list}    Create List    ${rule1}    ${rule2}
#     Counter Operation    operation=start_collect_counter
#     ...    product_type=gnb
#     ...    counter_rule=${rule_list}
#     Log To Console      ${\n}============= Set Initial DL/UL UE-AMBR as 5Mbps/5Mbps =============${\n}
#     Airphone.Airphone Execute Egate Command
#     ...    cmd=amf_ue_param ue\=3 ue_ambr_ul\=5:Mbps ue_ambr_dl\=5:Mbps
#     ...    pass_regexp=${None}
#     sleep    3s
#     Log To Console      ${\n}============= Start to Attach 1st UE =============${\n}
#     Airphone.Airphone Execute Egate Command    cmd=ue_register id\=3
#     ...    pass_regexp=${None}
#     sleep    3s
#     Airphone.Airphone Execute Egate Command    cmd=set_pdu_param ue\=3 pdu\=1 trf_type\=internal
#     ...    pass_regexp=${None}
#     sleep    3s
#     Airphone.Airphone Execute Egate Command    cmd=ue_pdu_session_setup pdu\=1 ue\=3 nwslice\=1 gw\=1
#     ...    pass_regexp=${None}
#     sleep    5s
#     Log To Console      ${\n}============= Start DL/UL traffic on 5QI-9 =============${\n}
#     Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=3 pdu\=1 qfi\=1 dir\=dl mbps\=10
#     ...    pass_regexp=${None}
#     sleep    3s
#     Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=3 pdu\=1 qfi\=1 dir\=ul mbps\=10
#     ...    pass_regexp=${None}
#     sleep    3s
#     Log To Console      ${\n}============= Trigger intra-gNB Re-establishment =============${\n}
#     Airphone.Airphone Execute Egate Command
#     ...    cmd=ue_rrc_reestablish id\=3 gnb\=2 cell\=5 cause\=reconfigurationFailure
#     ...    pass_regexp=NR RRC Reestablishment sucessfully completed
#     Log To Console      ${\n}============= Re-establishment is completed. =============${\n}
#     Sleep    10 min    reason=wait for counter ready
#     Log To Console      ${\n}============= Check throughput =============${\n}
#     Counter Check 5QI9
#     Log To Console      ${\n}============= Check is done. Case is passed. =============${\n}

# CB008234_D_AMBR limitation handling when CB008124 ULCG TYPE2 is activated
#     [Documentation]
#     ...    author: Dacheng Zhang
#     ...    Description:
#     ...    ULCG is still activated when UL UE-AMBR is modified to value lower than CG activation threshold.
#     [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim_D_CB008124
#     ...    base_path=${CURDIR}/Airphone
#     ...    call_type=sa
#     ${rule1}    Catenate
#     ...    Distname: MRBTS-1/NRBTS-1;
#     ...    Counter: M55319C16009;
#     ...    Counter rule: max(M55319C16009)<450000;
#     ${rule2}    Catenate
#     ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
#     ...    Counter: M55308C00021;
#     ...    Counter rule: max(M55308C00021)>0;
#     ${rule3}    Catenate
#     ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1;
#     ...    Counter: M55308C00021,M55308C00023;
#     ...    Counter rule: max(M55308C00023)<max(M55308C00021);
#     ${rule_list}    Create List    ${rule1}    ${rule2}    ${rule3}
#     Counter Operation    operation=start_collect_counter
#     ...    product_type=gnb
#     ...    counter_rule=${rule_list}
#     Log To Console      ${\n}============= Initial UL session-AMBR is 10Mbps =============${\n}
#     Log To Console      ${\n}============= Start to Attach one UE =============${\n}
#     Airphone.Airphone Execute Egate Command    cmd=ue_register id\=1
#     ...    pass_regexp=${None}
#     sleep    3s
#     Airphone.Airphone Execute Egate Command    cmd=set_pdu_param ue\=1 pdu\=1 trf_type\=internal
#     ...    pass_regexp=${None}
#     sleep    3s
#     Airphone.Airphone Execute Egate Command    cmd=ue_pdu_session_setup pdu\=1 ue\=1 nwslice\=1 gw\=1
#     ...    pass_regexp=${None}
#     sleep    2s
#     Log To Console      ${\n}============= Start UL traffic on 5QI-9 =============${\n}
#     Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=ul mbps\=20
#     ...    pass_regexp=${None}
#     sleep    3s
#     Log To Console      ${\n}============= Wait for throughput and ULCG counter =============${\n}
#     Sleep    10 min    reason=wait for counter ready
#     Log To Console      ${\n}============= Modify UL UE AMBR to 10Kbps, lower than CG threshold =============${\n}
#     Airphone.Airphone Execute Egate Command
#     ...    cmd=amf_ue_ctx_modify_param id\=1 ue\=1 ue_ambr_ul\=10:Kbps
#     ...    pass_regexp=${None}
#     sleep    3s
#     Log To Console      ${\n}============= Trigger UE context modification request =============${\n}
#     Airphone.Airphone Execute Egate Command    cmd=ue_ctx_ng_mod id\=1
#     ...    pass_regexp=Received UE Context Modification Response
#     sleep    3s
#     Log To Console      ${\n}============= UL UE AMBR modification is done. =============${\n}
#     Log To Console      ${\n}============= Wait for throughput and ULCG counter =============${\n}
#     Sleep    5 min    reason=wait for counter ready
#     Log To Console      ${\n}============= Check throughput and ULCG counter =============${\n}
#     Counter Check 5QI9
#     Log To Console      ${\n}============= Check is done. Case is passed. =============${\n}

# CB008234_D UL UE AMBR interworking with CB008709 slice aware uplink scheduler in FDD mode
#     [Documentation]
#     ...    author: Dacheng Zhang
#     ...    Description:
#     ...    UL throughput of each UE is enforced by UL UE-AMBR and max quota of Resource group
#     [Setup]    Common MultiBTS Test Setup For RRM    airphone_config_tag=SA_TDD_2c_1gNBSim_D_CB008709
#     ...    base_path=${CURDIR}/Airphone
#     ...    call_type=sa
#     ${rule1}    Catenate
#     ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-1;
#     ...    Counter: M55910C00004;
#     ...    Counter rule: max(M55910C00004)>20 and max(M55910C00004)<35;
#     ${rule2}    Catenate
#     ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-2;
#     ...    Counter: M55910C00004;
#     ...    Counter rule: max(M55910C00004)>45 and max(M55910C00004)<55;
#     ${rule3}    Catenate
#     ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1/NRRESOURCEGROUP-3;
#     ...    Counter: M55910C00004;
#     ...    Counter rule: max(M55910C00004)>10 and max(M55910C00004)<25;
#     ${rule_list}    Create List    ${rule1}    ${rule2}    ${rule3}
#     Counter Operation    operation=start_collect_counter
#     ...    product_type=gnb
#     ...    counter_rule=${rule_list}
#     Log To Console      ${\n}============= UL session-AMBR of 1st UE is 35Mbps =============${\n}
#     Airphone.Airphone Execute Egate Command
#     ...    cmd=smf_ue_pdu_param id\=1 ue\=1 pdu\=1 session_ambr_ul\=35:Mbps
#     ...    pass_regexp=${None}
#     Log To Console      ${\n}============= Start to Attach 1st UE =============${\n}
#     Airphone.Airphone Execute Egate Command    cmd=qosflow_modify qos_flow\=15 default\=on
#     ...    pass_regexp=${None}
#     sleep    2s
#     Airphone.Airphone Execute Egate Command    cmd=ue_register id\=1
#     ...    pass_regexp=${None}
#     sleep    3s
#     Airphone.Airphone Execute Egate Command    cmd=set_pdu_param ue\=1 pdu\=1 trf_type\=internal
#     ...    pass_regexp=${None}
#     sleep    3s
#     Airphone.Airphone Execute Egate Command    cmd=ue_pdu_session_setup pdu\=1 ue\=1 nwslice\=1 gw\=1
#     ...    pass_regexp=${None}
#     sleep    2s
#     Log To Console      ${\n}============= Start Full UL traffic 1st UE =============${\n}
#     Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=ul mbps\=100
#     ...    pass_regexp=${None}
#     sleep    3s
#     Log To Console      ${\n}============= UL session-AMBR of 2nd UE is 75Mbps =============${\n}
#     Airphone.Airphone Execute Egate Command
#     ...    cmd=smf_ue_pdu_param id\=1 ue\=2 pdu\=1 session_ambr_ul\=75:Mbps
#     ...    pass_regexp=${None}
#     Log To Console      ${\n}============= Start to Attach 2nd UE =============${\n}
#     Airphone.Airphone Execute Egate Command    cmd=qosflow_modify qos_flow\=13 default\=on
#     ...    pass_regexp=${None}
#     sleep    2s
#     Airphone.Airphone Execute Egate Command    cmd=ue_register id\=2
#     ...    pass_regexp=${None}
#     sleep    3s
#     Airphone.Airphone Execute Egate Command    cmd=set_pdu_param ue\=2 pdu\=1 trf_type\=internal
#     ...    pass_regexp=${None}
#     sleep    3s
#     Airphone.Airphone Execute Egate Command    cmd=ue_pdu_session_setup pdu\=1 ue\=2 nwslice\=2 gw\=2
#     ...    pass_regexp=${None}
#     sleep    2s
#     Log To Console      ${\n}============= Start Full UL traffic 2nd UE =============${\n}
#     Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=2 pdu\=1 qfi\=1 dir\=ul mbps\=100
#     ...    pass_regexp=${None}
#     sleep    3s
#     Log To Console      ${\n}============= UL session-AMBR of 3rd UE is 15Mbps =============${\n}
#     Airphone.Airphone Execute Egate Command
#     ...    cmd=smf_ue_pdu_param id\=1 ue\=3 pdu\=1 session_ambr_ul\=15:Mbps
#     ...    pass_regexp=${None}
#     Log To Console      ${\n}============= Start to Attach 3rd UE =============${\n}
#     Airphone.Airphone Execute Egate Command    cmd=qosflow_modify qos_flow\=14 default\=on
#     ...    pass_regexp=${None}
#     sleep    2s
#     Airphone.Airphone Execute Egate Command    cmd=ue_register id\=3
#     ...    pass_regexp=${None}
#     sleep    3s
#     Airphone.Airphone Execute Egate Command    cmd=set_pdu_param ue\=3 pdu\=1 trf_type\=internal
#     ...    pass_regexp=${None}
#     sleep    3s
#     Airphone.Airphone Execute Egate Command    cmd=ue_pdu_session_setup pdu\=1 ue\=3 nwslice\=3 gw\=3
#     ...    pass_regexp=${None}
#     sleep    2s
#     Log To Console      ${\n}============= Start Full UL traffic 3rd UE =============${\n}
#     Airphone.Airphone Execute Egate Command    cmd=trf_data_start ue\=3 pdu\=1 qfi\=1 dir\=ul mbps\=100
#     ...    pass_regexp=${None}
#     Log To Console      ${\n}============= Wait for Slicing Counter =============${\n}
#     Sleep    10 min    reason=wait for counter ready
#     Log To Console      ${\n}============= Check counters =============${\n}
#     Counter Check 5QI9

# *** Keywords ***
# Counter Check 5QI9 and 5QI6
#     ${value1}    Counter Operation    operation=collect_counter_and_check_rule
#     ...    product_type=gnb
#     Log To Console    ${value1}

# Counter Check 5QI9
#     ${value1}    Counter Operation    operation=collect_counter_and_check_rule
#     ...    product_type=gnb
#     Log To Console    ${value1}
