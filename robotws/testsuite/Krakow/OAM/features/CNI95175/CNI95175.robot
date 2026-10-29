*** Settings ***
Documentation
...   contact: Jaroslaw Lezon
...   maintainer: jaroslaw.lezon@nokia.com
...
...     Description: CNI-95175 - Improve RF L3 transport layer to be resilient for short link breaks for eCPRI protocol
...     Purpose of this test suite is to validate BTS behaviour when eCPRI link is break for short period of time

Library       taf.rfrl.bts.devices.du.du_operations.GnbDuOperations    WITH NAME    gnbbbu
Library       taf.rfrl.bts.devices.du.alarm_verification.GnbAlarmVerification    WITH NAME    alarm_verification
Library       resources/OpticalSwitch.py    WITH NAME    OpticalSwitch
Resource      taf/rfrl/bts/robot/gnb.robot
Resource      taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource      taf/rfrl/ue/robot/REAL_UE.robot
Variables     taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Suite Setup       common_setups_and_teardowns.Common Suite Setup With OnAir Test Line Preparation
...               swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
Suite Teardown    common_setups_and_teardowns.Common Suite Teardown

Test Setup        Run Keywords
...               Common Preconditions With Watching Alarms
...               AND   OpticalSwitch.Setup Optical Switch Connection    optical_switch_device=${optical_switch}    alias=${switch_alias}
Test Teardown     Common Postconditions With Watching Alarms

*** Variables ***
@{additional_allowed_alarms}            BTS Reset Cause
...                                     Unit synchronization failed
${optical_switch}=                      ${tl.optical_switches[0]}
${first_opt_port_tx}=                   ${tl.gnbs[0].dus[0].rus[0].optical_switch_channels[0].channel_no}
${first_opt_port_rx}=                   ${tl.gnbs[0].dus[0].rus[0].optical_switch_channels[1].channel_no}
${second_opt_port_tx}=                  ${tl.gnbs[0].dus[0].rus[0].optical_switch_channels[2].channel_no}
${second_opt_port_rx}=                  ${tl.gnbs[0].dus[0].rus[0].optical_switch_channels[3].channel_no}
${fault_0010_name}=                     No connection to unit
${capabilities}                         REAL_UE
${ue_alias}                             UE
${bts_type}                             GNB
${reboot_ue}                            True
${timeout_reboot_ue}                    100
${COLLECT_LOGS_DURING_DATA_TRANSFER}    False
${ENABLE_RACH_OBSERVER}                 False
${link_break_interval}=                 10
${switch_alias}=                        OPT_SWITCH

*** Test Cases ***
Verify_Short_Link_Break_two_links_primaryLink
    alarm_verification.verify_alarm_is_not_active    fault_name=${fault_0010_name}
    Prepare Ue for L3 Call                           capabilities=${capabilities}
    ...                                              reboot_ue=${reboot_ue}
    ...                                              timeout_reboot_ue=${timeout_reboot_ue}
    Perform Attach and Verify UE Properly Attached   alias=${ue_alias}    bts_type=${bts_type}
    OpticalSwitch.Trigger Short Link Break           alias=OPT_SWITCH
    ...                                              port_number_tx=${first_opt_port_tx}
    ...                                              port_number_rx=${first_opt_port_rx}
    ...                                              link_break_interval=${link_break_interval}
    alarm_verification.verify_alarm_is_not_active    fault_name=${fault_0010_name}
    gnb_bbu.Wait For Site To Be Onair
    Perform Attach and Verify UE Properly Attached   alias=${ue_alias}    bts_type=${bts_type}

Verify_Short_Link_Break_two_links_secondaryLink
    alarm_verification.verify_alarm_is_not_active    fault_name=${fault_0010_name}
    Prepare Ue for L3 Call                           capabilities=${capabilities}
    ...                                              reboot_ue=${reboot_ue}
    ...                                              timeout_reboot_ue=${timeout_reboot_ue}
    Perform Attach and Verify UE Properly Attached   alias=${ue_alias}    bts_type=${bts_type}
    OpticalSwitch.Trigger Short Link Break           alias=OPT_SWITCH
    ...                                              port_number_tx=${second_opt_port_tx}
    ...                                              port_number_rx=${second_opt_port_rx}
    ...                                              link_break_interval=${link_break_interval}
    alarm_verification.verify_alarm_is_not_active    fault_name=${fault_0010_name}
    gnb_bbu.Wait For Site To Be Onair
    Perform Attach and Verify UE Properly Attached   alias=${ue_alias}    bts_type=${bts_type}
