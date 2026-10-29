*** Settings ***
Documentation
...    Author:          Mateusz Matusik, mateusz.matusik@nokia.com
...    Maintainer:      Mateusz Matusik, mateusz.matusik@nokia.com

Library      CB010788_keywords.py    WITH NAME    keywords
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Library      taf.rfrl.csv4all.resources.utilities.utilities                WITH NAME    csv4all_utilities
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py


*** Variables ***
@{ADDITIONAL_ALARMS_DURING_PREP}    WiFi Configuration Issue
...                                 Failure detected on assigned antennas
...                                 Spurious reset
...                                 Autonomous reset triggered by unknown
...                                 BTS Reset Cause
...                                 RAT Service Outage

*** Keywords ***
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
    ...                                                  should_5G_neighbour_be_changed=${False}
    ...                                                  increase_time_for_checking_bbmod=600
    ...                                                  increase_timeout_for_update_sw=1800
    ...                                                  increase_time_for_checking_radios=2137
    ...                                                  increase_time_for_checking_cells=700
    ...                                                  swconfig_from_path=/tmp/custom_swconfig.txt
    ...                                                  list_of_additional_allowed_alarms=${ADDITIONAL_ALARMS_DURING_PREP}
    ...                                                  prefix_tag=${scfc_prefix}

Custom Set Suite UUF Variables
    Run Keyword And Ignore Error
    ...    Log    CM_EXECUTION_ID: %{CM_EXECUTION_ID}\nCM_ARTIFACTS: %{CM_ARTIFACTS}\nCM_TAGS: %{CM_TAGS}
    ${TARGET_SW}=    Run Keyword If  '${TARGET_SW}'=='${None}'
    ...                     csv4all_utilities.Get Target SW
    ...                 ELSE
    ...                     Set Variable  ${TARGET_SW}
    Set Suite Variable    $TARGET_SW
    ${SOURCE_SW}=    Run Keyword If  '${SOURCE_SW}'=='${None}'
    ...                     Try set SOURCE_SW
    ...                 ELSE
    ...                     Set Variable  ${SOURCE_SW}
    Set Suite Variable    $SOURCE_SW

    &{NODE1}    Create Dictionary    testline_object=${tl.gnbs[0]}
    ...                              source_sw=${SOURCE_SW}
    ...                              target_sw=${TARGET_SW}
    ...                              custom_allowed_alarms=${CUSTOM_ALARMS}
    Set Suite Variable    $NODE1

    @{NODES}    Create List    ${NODE1}
    Set Suite Variable    $NODES

    Log    5G_SOURCE_SW: ${SOURCE_SW}\n5G_TARGET_SW: ${TARGET_SW}
    Log    NODES: ${NODES}
