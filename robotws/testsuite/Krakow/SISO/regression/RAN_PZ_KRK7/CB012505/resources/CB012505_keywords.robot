*** Settings ***
Documentation
...    Author:          Mateusz Matusik, mateusz.matusik@nokia.com
...    Maintainer:      Mateusz Matusik, mateusz.matusik@nokia.com

Library      CB012505_keywords.py    WITH NAME    keywords
Library      taf.rfrl.csv4all.resources.utilities.utilities                WITH NAME    csv4all_utilities
Library      taf.transport.ssh    WITH NAME    SSH
Library      json
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py


*** Variables ***
@{ADDITIONAL_ALARMS_DURING_PREP}    WiFi Configuration Issue
...                                 Failure detected on assigned antennas
...                                 Spurious reset
...                                 Autonomous reset triggered by unknown
...                                 BTS Reset Cause
...                                 RAT Service Outage
...                                 X2(gNB) link ANR establishment failure
${lock_x2link}=                     ./config/x2link_lock.json
${unlock_x2link}=                   ./config/x2link_unlock.json
${CB012505_activate}=               ./config/CB012505_activate.json
${CB012505_deactivate}=             ./config/CB012505_deactivate.json

*** Keywords ***
Test cleanup
    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Metadata to Report for All BTSs

Custom Suite Setup
    [Arguments]    ${scfc_prefix}=${False}
    @{param_list}=    Set Variable    0x450027=1 #EnableDeveloperAccount
    ...                               0x980007=1 #PR804393 Fault 61675 "WiFi Configuration Issue"
    ...                               0x1A1300=0 #Enable Firewall feature 5GC000265 [ & 5GC000325, 5GC000268]
    ...                               0x1A0020=1 #Enable SSH
    ...                               0x45005a=1
    ...                               0x1003F=2 #ERadCcs_AaSysLogInputLevel, 0=disable 1=debug 2=info 3=warning 4=error 5=vip 6=disable
    ...                               0x10040=2 #ERadCcs_AaSysLogOutputLevel
    ...                               0x10041=5 #ERadCcs_AaSysLogOutputMode, 0=none 1=all 2=udp 3=sic 4=std_output 5=local 6=remote 7=not_alid
    ...                               0x10042=0xC0A8FF7E #AaSysLogOutputAddress
    ...                               0x10043=51000 #AaSysLogUdpPort

    keywords.copy_and_modify_swconfig    ${param_list}
    ...                                  source_path=commissionings/Krakow/swconfig/default_swconfig.txt
    ...                                  target_path=/tmp/custom_swconfig.txt

    Common Suite Setup With OnAir Test Line Preparation  should_LTE_neighbour_be_changed=${False}
    ...                                                  should_5G_neighbour_be_changed=${True}
    ...                                                  increase_time_for_checking_bbmod=600
    ...                                                  increase_timeout_for_update_sw=1800
    ...                                                  increase_time_for_checking_radios=2137
    ...                                                  increase_time_for_checking_cells=700
    ...                                                  swconfig_from_path=/tmp/custom_swconfig.txt
    ...                                                  list_of_additional_allowed_alarms=${ADDITIONAL_ALARMS_DURING_PREP}
    ...                                                  prefix_tag=${scfc_prefix}

Verify that LNRELGNBCELL.nrStatus is set to available
    ${value}    gnbscf.get_parameters_by_dist_name    MRBTS-85033/LNBTS-85033/LNCEL-11/LNRELGNBCELL-255
    verify_if_parameter_is_set_to_expected_value    ${value}    nrStatus    available

Verify that LNRELGNBCELL.nrStatus is set to unavailable
    ${value}    gnbscf.get_parameters_by_dist_name    MRBTS-85033/LNBTS-85033/LNCEL-11/LNRELGNBCELL-255
    verify_if_parameter_is_set_to_expected_value    ${value}    nrStatus    unavailable

Verify that LNRELGNBCELL.sourceOfData is set to OM
    ${value}    gnbscf.get_parameters_by_dist_name    MRBTS-85033/LNBTS-85033/LNCEL-11/LNRELGNBCELL-255
    verify_if_parameter_is_set_to_expected_value    ${value}    sourceOfData    OM

Lock X2 link from gNB nieghbor side
    Log to console    Locking X2 link to gNB
    Send delta commissioning    ${lock_x2link}    1

Unlock X2 link from gNB nieghbor side
    Log to console    Unlocking X2 link to gNB
    Send delta commissioning    ${unlock_x2link}    1
    Wait for x2link to became available

Activate CB012505 feature flag
    Log to console    Enabling CB012505 feature flag
    Send delta commissioning    ${CB012505_activate}    0

Deactivate CB012505 feature flag
    Log to console    Disabling CB012505 feature flag
    Send delta commissioning    ${CB012505_deactivate}    0

Wait for x2link to became available
    Log to console    Waiting for X2 link activation
    Wait Until Keyword Succeeds    12 min    45 sec    Check if x2link is available

Send delta commissioning
    [Arguments]    ${json_delta}    ${bts_id}
    ${json}=    Adjust MRBTS ID in delta file    ${json_delta}
    gnbscf.Perform Bts Delta Commissioning    delta=${json}    bts_id=${bts_id}    timeout=${600}

Adjust MRBTS ID in delta file
    [Arguments]    ${json_file_path}
    ${json}=    Get File   ${test_dir}/${json_file_path}
    ${json}=    json.loads    ${json}
    [Return]    ${json}

Check if x2link is available
    ${value}    gnbscf.get_parameters_by_dist_name    MRBTS-85033/LNBTS-85033/LNADJGNB-1
    verify_if_parameter_is_set_to_expected_value    ${value}    x2ToGnbLinkStatus    available

Check if x2link is unavailable
    ${value}    gnbscf.get_parameters_by_dist_name    MRBTS-85033/LNBTS-85033/LNADJGNB-1
    verify_if_parameter_is_set_to_expected_value    ${value}    x2ToGnbLinkStatus    unavailable

Trigger neighbor gNB reboot via ssh
    Log to console    Triggering gNB reboot via SSH
    SSH.Connect to    ${GNB1_HOST_IP}    ${bts_username}    ${bts_password}    alias=gNB1
    SSH.send_command       command=reboot    connection=gNB1
    SSH.Disconnect    gNB1
    Wait Until Keyword Succeeds    3 min    29 sec    Check if x2link is unavailable

Perform full commissioning for gNB
    Log to console    Triggering gNB full commissioning
    gnbscf.perform_bts_full_commissioning    scf_file=${gnb1_scfc}    bts_id=1
    Wait Until Keyword Succeeds    3 min    29 sec    Check if x2link is unavailable

Trigger eNB reset
    Log to console    Triggering eNB reset
    Reset gNB
