*** Settings ***
Documentation
...   Test suite for regression testing of feature CB009766
...   author: Mateusz Bugaj, Daniel Kulaga, Pawel Grabania
...   contact: mateusz.bugaj@nokia.com, daniel.kulaga@nokia.com, pawel.grabania@nokia.com

Library      taf.rfrl.utilities.test_config
Resource     taf/rfrl/procedures/SISO/General_SiSo_Cell_block_and_unblock.robot
#Resource     taf/rfrl/procedures/SISO/General_SiSo_HWPTA_Collect_RFSW_Logs_From_RU_Into_BTS_Snapshot.robot
Resource     taf/rfrl/bts/robot/gnb.robot
Resource     taf/rfrl/ue/robot/REAL_UE.robot
Resource     ./resources/common_keywords.robot

Library      Collections
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables    ./resources/common_variables.py
Variables    ./resources/additional_variables.py
Variables    ./resources/call_procedure/call_tmp_vars.py

Suite Setup       Common Suite Setup With OnAir Test Line Preparation
...               swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
...               increase_timeout_for_update_sw=3600
...               prefix_tag=B1
Suite Teardown    Common Suite Teardown

*** Variables ***
${capabilities}    REAL_UE

@{cell_list_B1_dss_all}     LNCEL-1_B1      LNCEL-2_B1      LNCEL-3_B1      LNCEL-4_B1
...                         LNCEL-5_B1      LNCEL-6_B1      LNCEL-7_B1      NRCELL-12_B1
...                         NRCELL-21_B1    NRCELL-22_B1    NRCELL-31_B1    NRCELL-32_B1

*** Test Cases ***
CB009766_B1_Manual_SiSo_CALL_L3_data_call
    [Setup]    Actions before test With Checking Configuration and Changing It If Needed     config_name=B1
    ...       alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[L3_call]    prefix_tag=B1
    Call to selected cells      cell_list=${cell_list_B1_dss_all}
    ...                                   duration=240s       deviation=5%
    [Teardown]    Actions after test

#CB009766_B1_General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
#    [Setup]    Actions before test With Checking Configuration and Changing It If Needed     config_name=B1
#    ...       alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[Snapshot]    prefix_tag=B1
#    Verify snapshot
#    [Teardown]    Actions after test
