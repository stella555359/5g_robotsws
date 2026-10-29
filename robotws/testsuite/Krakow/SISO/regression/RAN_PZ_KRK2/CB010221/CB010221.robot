*** Settings ***
Documentation
...   Testsuite for regression testing of feature CB010221
...   author: Maciej Russek, maciej.russek@nokia.com
...   maintainer: Maciej Russek, maciej.russek@nokia.com

Library     taf.sbts.oam.coam.admin
Resource    testsuite/Krakow/SISO/regression/RAN_PZ_KRK2/CB013048/resources/CB013048_resources.robot
Library     resources/helpers.py
Variables   resources/deltas/CB010221_delta.py

Suite Setup       Custom suite setup
Suite Teardown    CB010221 Suite teardown
Test Setup        CB010221 Test setup
Test Teardown     CB010221 Test teardown

*** Variables ***
${PRIORITY_1_PORT}     None
${PRIORITY_2_PORT}     None
${SW_DOWNLOAD_PATH}    /home/ute/.ute-ca/cache/bts
${SW_UPDATE_BUILD}     None

*** Test Cases ***
[1][1.0] CB010221-C3 Activate resiliency by configuring a ToP Master #2
    Get port numbers from TOPP object and verify initial sync source link

[1][1.0] CB010221-C6 Recovery from failure of current best ToP Master with available second-best ToP Master
    Trigger and verify sync source link change
    Trigger and verify change to initial sync source link

[1][2.0] General_SiSo_Auto_Automatic_RAT_SW_upgrade
    [Setup]    CB010221 Software upgrade test setup
    Perform software upgrade and verify sync source link
    [Teardown]    CB010221 Software upgrade test teardown

*** Keywords ***
Lock LANE
    Perform configuration parameter recommissioning on gNB
    ...    dist_name=MRBTS-76119/EQM-1/APEQM-1/CABINET-1/BBMOD-2/SFP-1/LANE-1
    ...    param_name=administrativeState
    ...    param_value=Locked
    ...    timeout=300

Unlock LANE
    Perform configuration parameter recommissioning on gNB
    ...    dist_name=MRBTS-76119/EQM-1/APEQM-1/CABINET-1/BBMOD-2/SFP-1/LANE-1
    ...    param_name=administrativeState
    ...    param_value=Unlocked
    ...    timeout=300
    Sleep    10s    Wait for apply changes

Verify alarm 'No connection to unit' is active on gNB
    Verify alarm is active on gNB    fault_name=No connection to unit
    ...                              fault_id=10
    ...                              alarm_id=7116
    ...                              severity=Critical

Verify alarm 'No connection to unit' is not active on gNB
    Verify alarm is not active on gNB    fault_name=No connection to unit
    ...                                  fault_id=10
    ...                                  alarm_id=7116
    ...                                  severity=Critical

Verify ASIRMOD sync link
    [Arguments]    ${bts_host}    ${password}    ${asirmod_port}
    Setup admin
    ...    bts_host=${bts_host}
    ...    password=${password}
    ${sfp_links_data}    Get SFP links    action=getLinksWithParameters
    ${cablink_distname}    Get CABLINK distname by port name    sfp_links_data=${sfp_links_data}
    ...                                                         port_name=${asirmod_port}
    ${cablink_parameters}    Get parameters for      class_name=CABLINK
    ...                                              id_num=${cablink_distname}
    Verify link synchronization    cablink_data=${cablink_parameters}
    [Teardown]    Teardown admin

Get port number priority from TOPP
    Setup admin
    ${topp_data}    Get parameter by distname    dist_name=MRBTS-76119/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1
    ${port_priority}    Get port number priority from TOPP data    topp_data=${topp_data}
    Set suite variable    ${PRIORITY_1_PORT}    OPT_IF${port_priority[1]}
    Set suite variable    ${PRIORITY_2_PORT}    OPT_IF${port_priority[2]}
    Teardown admin

Get port numbers from TOPP object and verify initial sync source link
    Get port number priority from TOPP
    Wait until keyword succeeds    700 sec
    ...                            30 sec
    ...                            Verify ASIRMOD sync link
    ...                            bts_host=192.168.255.129
    ...                            password=nemuuser
    ...                            asirmod_port=${PRIORITY_1_PORT}

Trigger and verify sync source link change
    gnb_alarm.Allow alarm    No connection to unit
    Lock LANE
    Wait until keyword succeeds    60 sec
    ...                            10 sec
    ...                            Verify alarm 'No connection to unit' is active on gNB
    Verify ASIRMOD sync link    bts_host=10.84.164.117
    ...                         password=Usernemu.12
    ...                         asirmod_port=${PRIORITY_2_PORT}

Trigger and verify change to initial sync source link
    Unlock LANE
    Wait until keyword succeeds    60 sec
    ...                            10 sec
    ...                            Verify alarm 'No connection to unit' is not active on gNB
    Wait until keyword succeeds    700 sec
    ...                            30 sec
    ...                            Verify ASIRMOD sync link
    ...                            bts_host=192.168.255.129
    ...                            password=nemuuser
    ...                            asirmod_port=${PRIORITY_1_PORT}
    gnb_alarm.Disallow alarm    No connection to unit

CB010221 Test setup
    Common preconditions with watching alarms    verify_mandatory_scf_params=${False}

CB010221 Software upgrade test setup
    Run keyword if    "${SW_UPDATE_BUILD}"=="None"
    ...               Fail
    ...               SW_UPDATE_BUILD is not set, failing test
    Common preconditions with watching alarms    verify_mandatory_scf_params=${False}
    gnb_alarm.Allow alarm    Suspicious unit detection
    gnb_alarm.Allow alarm    No X2 link available
    Set MCC 001 and wait until gNB is ready for software update

CB010221 Software upgrade test teardown
    gnb_alarm.Disallow alarm    Suspicious unit detection
    gnb_alarm.Disallow alarm    No X2 link available
    gnbbbu.Disconnect
    Common postconditions with watching alarms

CB010221 Test teardown
    gnbbbu.Disconnect
    Common postconditions with watching alarms

CB010221 Suite teardown
    gnbbbu.Disconnect
    ${sw_release}    Get release name
    log to console    ${sw_release}
    Perform full commissioning on gNB
    ...    scf_file=testsuite/Krakow/SISO/regression/RAN_PZ_KRK2/CB010221/resources/scf/${sw_release}/SCF_MCC_001.xml
    Common suite teardown

Perform software upgrade and verify sync source link
    Download package and perform software update
    Wait until keyword succeeds    900 sec
    ...                            30 sec
    ...                            Verify ASIRMOD sync link
    ...                            bts_host=192.168.255.129
    ...                            password=nemuuser
    ...                            asirmod_port=${PRIORITY_1_PORT}
    Set MCC 404 and wait until gNB is onAir
    Wait until keyword succeeds    900 sec
    ...                            30 sec
    ...                            Verify ASIRMOD sync link
    ...                            bts_host=192.168.255.129
    ...                            password=nemuuser
    ...                            asirmod_port=${PRIORITY_1_PORT}

Set MCC 001 and wait until gNB is ready for software update
    Log to console    Delta commisioning MCC 001 to perform software upgrade
    ${delta_status}    Set MCC parameter by delta commissioning    delta=${delta_mcc_001}
    Run keyword if    ${delta_status}==${False}
    ...               Fail
    ...               Delta commissioning to MCC 001 failed
    Wait until keyword succeeds    360 sec
    ...                            10 sec
    ...                            Verify alarm 'Suspicious unit detection' is active on gNB
    Verify all cells are disabled

Download package and perform software update
    ${sw_package_dir}    Download SW package    sw_version=${SW_UPDATE_BUILD}
    ...                                         target_dir=${SW_DOWNLOAD_PATH}
    Log to console    Start software upgrade to ${SW_UPDATE_BUILD}
    gnbswupdate.Update software    sw_package_dir=${sw_package_dir}
    ...                            timeout=1200
    Sleep    180s    Wait for SW to apply
    Log to console    Software upgrade done

Set MCC 404 and wait until gNB is onAir
    Log to console    Delta commisioning MCC 404 after software upgrade
    ${delta_status}    Set MCC parameter by delta commissioning    delta=${delta_mcc_404}
    Run keyword if    ${delta_status}==${False}
    ...               Fail
    ...               Delta commissioning to MCC 404 failed
    Wait until keyword succeeds    360 sec
    ...                            10 sec
    ...                            gnbcell.Verify All Cells are OnAir
