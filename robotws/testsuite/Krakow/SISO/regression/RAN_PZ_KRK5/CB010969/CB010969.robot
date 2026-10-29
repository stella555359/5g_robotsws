*** Settings ***
Documentation
...   Test suite for regression testing of feature CB010969
...   author: Mateusz Bugaj, Daniel Kulaga, Pawel Grabania
...   contact: mateusz.bugaj@nokia.com, daniel.kulaga@nokia.com, pawel.grabania@nokia.com

Library      taf.rfrl.utilities.test_config
Resource     taf/rfrl/bts/robot/gnb.robot
Resource     ./resources/common_keywords.robot
Resource     taf/rfrl/procedures/SISO/General_SiSo_Cell_block_and_unblock.robot
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot

Library      taf.ue     WITH NAME   ue

Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables    ./resources/common_variables.py
Variables    ./resources/additional_variables.py

Force Tags    CA_VRF_KRK

Suite Setup       common_setups_and_teardowns.Common Suite Setup With OnAir Test Line Preparation
...               list_of_additional_allowed_alarms=@{CUSTOM_ALLOWED_ALARMS_DURING_TL_PREPARATION}
Suite Teardown    common_setups_and_teardowns.Common Suite Teardown

Test Setup        Custom Test Setup
Test Teardown     common_setups_and_teardowns.Common Postconditions With Restore Configuration If Test Failed

*** Variables ***
@{CellIDs}      NRCELL-1    NRCELL-5     NRCELL-2     NRCELL-6     NRCELL-3     NRCELL-7     NRCELL-4     NRCELL-8
${capabilities}      REAL_UE
${deviation}       20%
${IS_ASIR_CONFIGURATION}=   ${True}
@{CUSTOM_ALLOWED_ALARMS_DURING_TL_PREPARATION}      61673    61510    4479
&{UEPC_HPE}       host=zf03.mgt.ska-lab.nsn-rdnet.net      port=22      alias=UEPC_HPE      model=HPE
${UEPC_RESET}     ${True}

*** Test Cases ***
CB010969_Change cell power
    [Setup]    Actions before test
    Change pMax parameter and verify If Changed
    [Teardown]    Actions after test

CB010969_ASiR_WebEM_supports_configuration_reset_of_the_ASi_System_accessible_from_the_main_menu
    [Setup]    Actions before test      alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[Comm_and_Recomm]
    Configuration Reset Of The AsirWebEM
    [Teardown]    Actions after test

#CB010969_General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
#    [Setup]    Actions before test    alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[Snapshot]
#    Verify snapshot
#    [Teardown]    Actions after test

CB010969_Delete cell
    [Setup]    Actions before test
    Remove Cell And Restore Config      cell_id=6
    [Teardown]    Actions after test

CB010969_ASiR-sHUB_Discovery_with_eCPRI_link_Commissioned_success
    [Setup]    Actions before test      alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[Comm_and_Recomm]
    Discovery With eCPRI Link After Commissioning
    [Teardown]    Actions after test

CB010969_Check 4484 EFaultId_ProblemsDetectedOnAssignedAntennasAl
    [Setup]    Actions before test  alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[Fault_Trigger]
    Check Fault Id After Parameters Change      fault_id=4484
    [Teardown]    Actions after test

CB010969_Manual_SiSo_CALL_L3_data_call
    [Setup]    Actions before test  alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[L3_call]
    Power Reset UE PC    &{UEPC_HPE}
    Call to selected cells          cell_list=${CellIDs}      duration=350s       deviation=5%
    [Teardown]    Actions after test

CB010969_5G_eCPRI_ASiR-HUB_lock_unlock_via_WebEM
    [Setup]    Actions before test    alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[ASiR_HUB_lock]
    Power Reset UE PC    &{UEPC_HPE}
    Call to selected cells    cell_list=@{CellIDs}     duration=120s    deviation=${deviation}
    SISO Lock unlock all ASiR hubs
    Call to selected cells    cell_list=@{CellIDs}     duration=120s    deviation=${deviation}
    ...                       run_num=${2}
    [Teardown]    Actions after test
