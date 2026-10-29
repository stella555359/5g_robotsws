*** Settings ***
Documentation
...    author: Marcin Szlapa
...    contact: marcin.szlapa@nokia.com
...    Description: CB010214 test cases

Resource    taf/rfrl/bts/robot/gnb.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    testsuite/Krakow/SISO/regression/RAN_PZ_KRK4/CB010214/Keywords.robot
Library     taf.sbts.oam.coam.admin    WITH NAME   coam_admin
Library     ./resources/iptables.py
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables   ./resources/variables.py

Test Timeout  24 hours

Suite Setup         Common Suite Setup With OnAir Test Line Preparation
...  swconfig_from_path=commissionings/${CONFIGURATION.replace('.', '/')}/swconfig.txt
...                                increase_time_for_checking_bbmod=600
...                                increase_timeout_for_update_sw=1800
...                                increase_time_for_checking_radios=2100
...                                increase_time_for_checking_cells=700
Suite Teardown      Common Suite Teardown
Test Setup          Common Preconditions With Watching Alarms
Test Teardown       Common Postconditions With Watching Alarms

*** Variables ***
@{additional_allowed_alarms}
...  No X2 link available

*** Test Cases ***
CB010214-A_Modification_of_LABM
    Perform Configuration Parameter Recommissioning On gNB
    ...    dist_name=MRBTS-${global_bts_id}/MNL-1/MNLENT-1/SECADM-1
    ...    param_name=localAccessBlockingMode
    ...    param_value=Disabled
    ...    gnb_id=0
    ...    timeout=${180}
    # gnbbbu.Verify Configuration Parameters Values
    # ...    param_dict=${localAccessBlockingMode_disabled}
    Prepare Macro EMSSIM
    Run EMSSIM Command  ne3s_activate   bts_id=${bts_id}  get_full_data=True  alias=macroAC
    Wait Until Keyword Succeeds  30 min  30 sec  Verify NMS Status
    ...    downlinkFromNMS=notSecured
    Verify LMP is pingable
    Perform Configuration Parameter Recommissioning On gNB
    ...    dist_name=MRBTS-${global_bts_id}/MNL-1/MNLENT-1/SECADM-1
    ...    param_name=localAccessBlockingMode
    ...    param_value=PortBlockedWithBackup
    ...    gnb_id=0
    ...    timeout=${180}
    Wait Until Keyword Succeeds  30 min  10 sec  Verify LMP is not pingable
    Block NMS
    Wait Until Keyword Succeeds  30 min  30 sec  Verify NMS Status
    ...    downlinkFromNMS=notConnected
    Wait Until Keyword Succeeds  30 min  30 sec  Verify LMP is pingable
    Unblock NMS
    Wait Until Keyword Succeeds  30 min  30 sec  Verify NMS Status
    ...    downlinkFromNMS=notSecured
    Wait Until Keyword Succeeds  30 min  30 sec  Verify LMP is not pingable
    Perform Configuration Parameter Recommissioning On gNB
    ...    dist_name=MRBTS-${global_bts_id}/MNL-1/MNLENT-1/SECADM-1
    ...    param_name=localAccessBlockingMode
    ...    param_value=Disabled
    ...    gnb_id=0
    ...    timeout=${180}
    Wait Until Keyword Succeeds  30 min  30 sec  Verify LMP is pingable
    Block NMS
    Wait Until Keyword Succeeds  30 min  30 sec  Verify NMS Status
    ...    downlinkFromNMS=notConnected
    Verify LMP is pingable
    Unblock NMS
    Wait Until Keyword Succeeds  30 min  30 sec  Verify NMS Status
    ...    downlinkFromNMS=notSecured
    Verify LMP is pingable
    Run EMSSIM Command  ne3s_deactivate   bts_id=${bts_id}  get_full_data=True  alias=macroAC

CB010214-F_Modification_of_btsEMRestrictAccSession
    CB010214-F_Modification_of_btsEMRestrictAccSession

*** Keywords ***
Verify NMS Status
    [Arguments]    ${downlinkFromNMS}
    ${oam_ip_address}    taf.rfrl.utilities.tl_config.get_oam_ip_address
    coam_admin.connect_to    ${oam_ip_address}
    ${nms_state}  coam_admin.get_nms_state
    # should not be empty    ${nms_state[0]['managerInfo'][0]['managerIpAddress']}
    should be equal    ${nms_state[0]['downlinkFromNMS']}    ${downlinkFromNMS}
    [Teardown]    coam_admin.teardown

Verify LMP is pingable
    ${output}   Run       ping -c 1 -W 10 192.168.255.129
    Should contain      ${output}   1 packets transmitted, 1 received

Verify LMP is not pingable
    ${output}   Run       ping -c 1 -W 10 192.168.255.129
    Should contain      ${output}   1 packets transmitted, 0 received
