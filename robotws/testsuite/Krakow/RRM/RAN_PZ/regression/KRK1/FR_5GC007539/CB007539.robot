*** Settings ***
Documentation
...   author: Bartlomiej Trybuch
...   contact: bartlomiej.trybuch@nokia.com
...   Tests for feature CB007539

Library       DateTime
Library       taf.ue    WITH NAME    ue
Library       taf.rfrl.procedures.resources.python.sleeping_cell_detector    WITH NAME    scd
Library       resources/rach_verifier.py     WITH NAME   rach
Library       resources/bip_operations.py
Resource      taf/rfrl/bts/robot/gnb.robot
Resource      taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource      ../../../resources/collect_logs.robot
Variables     taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables     resources/delta.py


Suite Setup     Common Suite Setup With OnAir Test Line Preparation
...               swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
Suite Teardown  Common Suite Teardown

Test Setup      Test setup
Test Teardown   Test teardown

*** Variables ***
${table}        175:8,1:9,19,29,39,49,59,69,79
${file_name}    BIP_175

*** Test Cases ***
5GC001300_AC_59_Call setup with frame structure 1127 prach config index 175
    Set prachConfigIndex to 175 on DU
    Start BIP on PC    ${file_name}
    Attach Ue   UE    timeout=70
    Wait Till BIP Collection Finished
    Detach Ue   UE
    Download BIP to VM      ${file_name}   ${OUTPUT DIR}
    Set Pcap File Permission     ${OUTPUT DIR}/${file_name}.pcap
    Convert Pcap To Csv For PrachReceiveReq
    rach.Check Prach Received Messages  ${OUTPUT DIR}/${file_name}_PrachReceiveReq.csv     ${table}         175

*** Keywords ***
Test setup
    [Arguments]   ${capabilities}=REAL_ANDROID_UE
    [Documentation]     Preparing for test includes reserving UE, Cell and setting up expected cell id during attach
    ...     :param capabilities: capabilities used to request UE of correct type
    Log to console      \n---SETUP STARTED---\n
    Common Preconditions With Watching Alarms
    Set Up BIP on ASOE
    ue.Require Ue       UE              capabilities=${capabilities}
    Log to console      \n---SETUP FINISHED---\n

Test teardown
    log to console      \n---TEARDOWN STARTED---\n
    Common Postconditions With Watching Alarms
    Run keyword and ignore error        Detach Ue   UE
    Revert changes to prachConfigIndex
    log to console      \n---TEARDOWN FINISHED---\n

Set prachConfigIndex to ${prach_nr} on DU
    [Documentation]     This keyword is applying appropriate prach configuration on gNB
    ...     :param prach_nr: used to construct name of variable holding configuration
    ...                      variables are defined in resources/delta.py file in this feature
    ${value}  catenate      SEPARATOR=      delta_      ${prach_nr}
    Perform Delta Commissioning On gNB      delta=${${value}}
    Wait until keyword succeeds     300 sec     15 sec   Verify gNB is onAir

Revert changes to prachConfigIndex
    Perform Delta Commissioning On gNB    delta=${delta_default}
    Wait until keyword succeeds     300 sec     15 sec   Verify gNB is onAir
