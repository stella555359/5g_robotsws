*** Settings ***
Documentation
...    author: Marcin Szlapa
...    contact: marcin.szlapa@nokia.com
...    Description: Test Cases for CB005833-D

Resource    taf/rfrl/bts/robot/gnb.robot
Resource    taf/rfrl/bts/robot/logs_collecting.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables   ./resources/variables.py
Library     ./resources/CB005833_keywords.py
Library     testsuite.Krakow.resources.alarm.Alarm

Test Timeout  24 hours

Suite Setup         Suite Setup
Suite Teardown      Suite Teardown
Test Setup          Run Keyword And Ignore Error     Common Preconditions
Test Teardown       Run Keyword And Ignore Error     Common Postconditions

*** Variables ***
${global_bts_id} =           ${tl.gnbs[0].global_bts_id}
${bbmod_addr_dn_param_abbr}  firstGwIPv4AddrDN
${bbmod_addr_dn_param_name}  First Gateway IPv4 Address Distinguished Name
${bbmod_ip_param_abbr}       localIpAddr
${bbmod_ip_param_name}       Local IPv4 address
@{sfp_lanes}
...  MRBTS-${tl.gnbs[0].global_bts_id}/EQM-1/APEQM-1/CABINET-1/BBMOD-1/SFP-1/LANE-1
...  MRBTS-${tl.gnbs[0].global_bts_id}/EQM-1/APEQM-1/CABINET-1/BBMOD-1/SFP-2/LANE-1
${bfd_1_down_egress_alarm}      BFD-1 down in egress
${bfd_1_down_ingress_alarm}     BFD-1 down in ingress
${bfd_2_down_ingress_alarm}     BFD-2 down in ingress
${bfd_dist_name}                MRBTS-${tl.gnbs[0].global_bts_id}/TNLSVC-1/TNL-2/IPAPP-1/BFD-1
@{additional_allowed_alarms} =  BFD-1 down in ingress  BFD-2 down in ingress
...                             BFD-1 down in egress   BFD-2 down in egress
...                             Unit synchronization failed
...                             BTS Reset Cause

*** Test Cases ***
CB005833-D_01_Resiliency of M-Plane communication between RU and gNB_DU_sBTS in P2P deployment with internal DHCP server.
    Perform commissioning on gNB to onAir state
    ...  prefix_tag=CB005833_04
    Repeat Keyword     3 times
    ...  Lock and unlock SFP LANE and check alarms       ${sfp_lanes[0]}  ${bfd_1_down_ingress_alarm}
    Lock and unlock SFP LANE and check alarms            ${sfp_lanes[1]}  ${bfd_2_down_ingress_alarm}
    Lock and unlock multiple SFP LANES and check alarms  ${sfp_lanes}
    ${cell_blocked_alarm}=  Create list  Cell blocked
    ${allowed_alarms_list}=    Combine Lists    ${allowed_alarms}    ${cell_blocked_alarm}
    gnb_alarm.Start watching alarms    allowed_alarms=${allowed_alarms_list}
    Lock All Cells
    Unlock All Cells
    gnb_alarm.Stop watching alarms

#CB005833-D_04_.*BFD down ingress.* and .*BFD down egress.* alarms
#    Perform commissioning on gNB to onAir state
#    ...  prefix_tag=CB005833_04
#    Get BBMOD IP
#    Block Incoming BFD Packets And Check Alarms
#    Block Outgoing BFD Packets And Check Alarms
#    Unblock Outgoing and Incoming BFD Packets And Check Alarms
#
#CB005833-D_10_eCPRI M plane Resilience configuration and activation. RU is connected to two different BBMOD via P2P link.
#    Perform commissioning on gNB to onAir state
#    ...  prefix_tag=CB005833_01
#    Perform Delta Commissioning On gNB    ${delta_tc_10}
#    Wait for site to be onair
#    Wait Until Keyword Succeeds  3 min  30 sec  Verify Cell Statuses
#    ...                                                 operational_state=enabled
#    ...                                                 procedural_status=configured
#    ...                                                 availability_status=online
#    ...                                                 administrative_state=unlocked
#    Verify Trigger State

CB005833-D_11_BFD configuration, activation and deactivation at Capacity card
    Perform commissioning on gNB to onAir state
    ...  prefix_tag=CB005833_04
    ${parameters}=  get BFD parameters  dist_name=${bfd_dist_name}  parameters=${bfd_parameters}
    Perform Delta Commissioning And Verify Parameters Change  ${bfd_delta}
    ${bfd_delta_2}=  restore_bfd_parameters  ${parameters}
    Perform Delta Commissioning And Verify Parameters Change  ${bfd_delta_2}

*** Keywords ***
Verify alarm is not active on gNB
    [Arguments]    ${fault_name}  ${timeout}=180
    ${status}=    run keyword and return status
    ...   Wait Until Alarm Is Active On Gnb  ${fault_name}  timeout=${timeout}
    should not be true  ${status}

Lock and unlock SFP LANE and check alarms
    [Arguments]    ${sfp_lane_dist_name}  ${fault_name}
    Lock SFP LANE    ${sfp_lane_dist_name}
    Wait Until Alarm Is Active On Gnb    ${fault_name}  timeout=180
    Verify Default Allowed Alarms on gNB
    sleep  10
    Unlock SFP LANE    ${sfp_lane_dist_name}
    Wait Until Alarm Is Not Active On Gnb    ${fault_name}
    Verify Default Allowed Alarms on gNB
    Wait Until Keyword Succeeds  3 min  30 sec  Verify Cell Statuses
    ...                                                 operational_state=enabled
    ...                                                 procedural_status=configured
    ...                                                 availability_status=online
    ...                                                 administrative_state=unlocked

Lock and unlock multiple SFP LANES and check alarms
    [Arguments]    ${sfp_lane_dist_name_list}
    Append To List  ${additional_allowed_alarms}    No connection to unit
    Lock multiple SFP LANES    ${sfp_lane_dist_name_list}
    Wait Until Alarm Is Active On Gnb   No connection to unit
    Verify Default Allowed Alarms on gNB
    Unlock multiple SFP LANES    ${sfp_lane_dist_name_list}
    Wait Until Alarm Is Not Active On Gnb    No connection to unit
    Verify Default Allowed Alarms on gNB
    Wait Until Keyword Succeeds  3 min  30 sec  Verify Cell Statuses
    ...                                                 operational_state=enabled
    ...                                                 procedural_status=configured
    ...                                                 availability_status=online
    ...                                                 administrative_state=unlocked

Get BBMOD IP
    ${bbmod_ip} =  Get BBMOD IP Address
    ...  dist_name=MRBTS-${global_bts_id}/MNL-1/MNLENT-1/MPLANEFHNW-1
    ...  bbmod_dn_param_name=${bbmod_addr_dn_param_abbr}
    ...  bbmod_param_name=${bbmod_ip_param_abbr}
    Set Suite Variable  ${bbmod_ip}

Get BBMOD IP via GUI
    ${bbmod_addr_dn} =  Get gNB Parameter Value via GUI
    ...  dist_name=MRBTS-${global_bts_id}/MNL-1/MNLENT-1/MPLANEFHNW-1
    ...  param_name=${bbmod_addr_dn_param_name}  param_abbr=${bbmod_addr_dn_param_abbr}
    ${bbmod_ip} =  Get gNB Parameter Value via GUI
    ...  dist_name=${bbmod_addr_dn}
    ...  param_name=${bbmod_ip_param_name}  param_abbr=${bbmod_ip_param_abbr}
    Set Suite Variable  ${bbmod_ip}

Block Incoming BFD Packets And Check Alarms
    Block Incoming BFD Packets
    ...  bbmod_ip=${bbmod_ip}
    Wait Until Alarm Is Active On Gnb
    ...  fault_name=${bfd_1_down_egress_alarm}
    Perform Configuration Parameter Recommissioning On gNB
    ...  dist_name=MRBTS-${global_bts_id}/TNLSVC-1/TNL-2/IPAPP-1/BFD-1
    ...  param_name=bfdAdminUp
    ...  param_value=false
    ...  skip_parameter_relation_errors=${true}
    Wait Until Alarm Is Not Active On Gnb
    ...  fault_name=${bfd_1_down_egress_alarm}
    Perform Configuration Parameter Recommissioning On gNB
    ...  dist_name=MRBTS-${global_bts_id}/TNLSVC-1/TNL-2/IPAPP-1/BFD-1
    ...  param_name=bfdAdminUp
    ...  param_value=true
    ...  skip_parameter_relation_errors=${true}
    Wait Until Alarm Is Active On Gnb
    ...  fault_name=${bfd_1_down_egress_alarm}
        Perform Configuration Parameter Recommissioning On gNB
    ...  dist_name=MRBTS-${global_bts_id}/TNLSVC-1/TNL-2/IPAPP-1/BFD-1
    ...  param_name=bfdActivation
    ...  param_value=false
    ...  skip_parameter_relation_errors=${true}
    Wait Until Alarm Is Not Active On Gnb
    ...  fault_name=${bfd_1_down_egress_alarm}
    Perform Configuration Parameter Recommissioning On gNB
    ...  dist_name=MRBTS-${global_bts_id}/TNLSVC-1/TNL-2/IPAPP-1/BFD-1
    ...  param_name=bfdActivation
    ...  param_value=true
    ...  skip_parameter_relation_errors=${true}
    Wait Until Alarm Is Active On Gnb
    ...  fault_name=${bfd_1_down_egress_alarm}

Block Outgoing BFD Packets And Check Alarms
    Block Outgoing BFD Packets
    ...  bbmod_ip=${bbmod_ip}
    Wait Until Alarm Is Not Active On Gnb
    ...  fault_name=${bfd_1_down_egress_alarm}
    Wait Until Alarm Is Active On Gnb
    ...  fault_name=${bfd_1_down_ingress_alarm}
    Perform Configuration Parameter Recommissioning On gNB
    ...  dist_name=MRBTS-${global_bts_id}/TNLSVC-1/TNL-2/IPAPP-1/BFD-1
    ...  param_name=bfdAdminUp
    ...  param_value=false
    ...  skip_parameter_relation_errors=${true}
    Wait Until Alarm Is Not Active On Gnb
    ...  fault_name=${bfd_1_down_ingress_alarm}
    Perform Configuration Parameter Recommissioning On gNB
    ...  dist_name=MRBTS-${global_bts_id}/TNLSVC-1/TNL-2/IPAPP-1/BFD-1
    ...  param_name=bfdAdminUp
    ...  param_value=true
    ...  skip_parameter_relation_errors=${true}
    Wait Until Alarm Is Active On Gnb
    ...  fault_name=${bfd_1_down_ingress_alarm}
        Perform Configuration Parameter Recommissioning On gNB
    ...  dist_name=MRBTS-${global_bts_id}/TNLSVC-1/TNL-2/IPAPP-1/BFD-1
    ...  param_name=bfdActivation
    ...  param_value=false
    ...  skip_parameter_relation_errors=${true}
    Wait Until Alarm Is Not Active On Gnb
    ...  fault_name=${bfd_1_down_ingress_alarm}
    Perform Configuration Parameter Recommissioning On gNB
    ...  dist_name=MRBTS-${global_bts_id}/TNLSVC-1/TNL-2/IPAPP-1/BFD-1
    ...  param_name=bfdActivation
    ...  param_value=true
    ...  skip_parameter_relation_errors=${true}
    Wait Until Alarm Is Active On Gnb
    ...  fault_name=${bfd_1_down_ingress_alarm}

Unblock Outgoing and Incoming BFD Packets And Check Alarms
    Unblock Incoming BFD Packets
    ...  bbmod_ip=${bbmod_ip}
    Unblock Outgoing BFD Packets
    ...  bbmod_ip=${bbmod_ip}
    Wait Until Alarm Is Not Active On Gnb
    ...  fault_name=${bfd_1_down_egress_alarm}
    Wait Until Alarm Is Not Active On Gnb
    ...  fault_name=${bfd_1_down_ingress_alarm}

Perform Delta Commissioning And Verify Parameters Change
    [Arguments]    ${bfd_delta}     ${skip_parameter_relation_errors}=${True}
    Perform Delta Commissioning On gNB    ${bfd_delta}  ${skip_parameter_relation_errors}
    Verify_parameters_change  ${bfd_delta}

Suite Teardown
    Common Suite Teardown
    Perform Full Commissioning and Wait for onAir  prefix_tag=CB005833_04

Suite Setup
    gnbbbu.upload_swconfig    sw_config_path=commissionings/${CONFIGURATION.replace('.', '/')}/swconfig.txt
    Common Suite Setup With Commissioning  prefix_tag=CB005833_04
