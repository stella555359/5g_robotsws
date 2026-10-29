*** Settings ***
Documentation
...   Testsuite for regression testing of feature CB009499
...   author: Arkadiusz Gurgul, arkadiusz.gurgul@nokia.com
...   maintainer: Arkadiusz Gurgul, arkadiusz.gurgul@nokia.com

Resource    taf/rfrl/procedures/SISO/General_SiSo_Auto_Cell_Block_Unblock.robot
Resource    taf/rfrl/procedures/SISO/General_SiSo_Auto_Radio_Module_Lock_Unlock.robot
Resource    ./resources/CB009499_Resources.robot


Suite Setup       Common suite setup with onAir Test Line preparation
...               swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
...               increase_time_for_checking_cells=600
...               increase_timeout_for_update_sw=1800
...               list_of_additional_allowed_alarms=Wifi Enabled Alarm
...               prefix_tag=CB009499
Suite Teardown    Common suite teardown
Test Setup        CB009499 Test Setup
Test Teardown     Common postconditions

*** Test Cases ***
[1][1.0] CB009499-SR-I_Common_SiSo_State Management_RF_Lock_and_Unlock
    [Documentation]   TC performed on Configuration#9 Baseband cell set type CB009499-I:
    ...               Half ASOF with NR ecpri TDD supercell and half ASOF with LTE eCPRI TDD supercells.
    ...               Shared FH and inter-Loki IQ forwarding.
    General_SiSo_Auto_Radio_Module_Lock_Unlock
    Prepare Ue
    L3 Call NR    680 Mbits/sec    47.2 Mbits/sec    0
    L3 Call LTE    73.4 Mbits/sec    7.2 Mbits/sec    10

*** Keywords ***
CB009499 Test Setup
    Set global variable    ${L3_CALL_STATUS}    ${True}
    Common preconditions