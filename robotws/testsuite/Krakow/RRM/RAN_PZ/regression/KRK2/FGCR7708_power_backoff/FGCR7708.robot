*** Settings ***
Force Tags    PY36

Documentation
...   Testsuite for regression testing of feature FGCR7708 Power Backoff
...   author:     Patryk Lamch, patryk.lamch@nokia.com
...               Piotr Wajda, piotr.wajda@nokia.com
...               Maciej Russek, maciej.russek@nokia.com
...   maintainer: Maciej Russek, maciej.russek@nokia.com

Resource    taf/rfrl/bts/robot/gnb.robot
Resource    taf/rfrl/bts/robot/logs_collecting.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables   ./resources/deltas.py

Suite Setup       Run Keywords
...               Common Suite Setup With OnAir Test Line Preparation
...               swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
...               AND    FGCR7708 Suite Setup

Test Setup        Common preconditions with watching alarms
Test Teardown     Common postconditions with watching alarms

*** Variables ***
${expected_alarm}   Power level not supported

*** Test Case ***
[1][2.0] Power backoff when pMax for cells too high
    Verify That Too Much pMax On NRCELLs Will Trigger Alarm    scf_path=${scf_conf1}
    ...                                                        pMax_delta=${delta_conf1}
    ...                                                        pMax_delta_backup=${delta_conf1_backup}
    ...                                                        alarm_occurrences=4
    Verify That Too Much pMax On NRCELLs Will Trigger Alarm    scf_path=${scf_conf2}
    ...                                                        pMax_delta=${delta_conf2}
    ...                                                        pMax_delta_backup=${delta_conf2_backup}
    ...                                                        alarm_occurrences=5

*** Keywords ***
Verify That Too Much pMax On NRCELLs Will Trigger Alarm
    [Arguments]  ${scf_path}  ${pMax_delta}  ${pMax_delta_backup}  ${alarm_occurrences}
    gnb_alarm.Allow Alarm    ${expected_alarm}
    Perform Full Commissioning On gNB   scf_file=${scf_path}
    Wait For Site To Be Onair
    Perform Delta Commissioning On gNB    delta=${pMax_delta}
    Sleep  10s
    Verify Active Alarm Occurrences On gNB    fault_name=${expected_alarm}    occurrences=${alarm_occurrences}
    Perform Delta Commissioning On gNB    delta=${pMax_delta_backup}
    Sleep  10s
    Verify Alarm Is Not Active On gNB    fault_name=${expected_alarm}
    gnb_alarm.Disallow Alarm    ${expected_alarm}
    Wait For Site To Be Onair

Set SCF Variables
    [Arguments]  ${release}
    Set Suite Variable  ${scf_conf1}  ${CURDIR}/resources/${release}/conf1_4cc.xml
    Set Suite Variable  ${scf_conf2}  ${CURDIR}/resources/${release}/conf2_5cc.xml

FGCR7708 Suite Setup
    ${release_name}  Get gNB SW Release Name
    Run Keyword If  '${release_name}' == 'SBTS22R1'
    ...  Set SCF Variables  release=22R1
    ...  ELSE
    ...  Set SCF Variables  release=22R2_22R3_22R4_23R1
