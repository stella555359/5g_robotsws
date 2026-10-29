*** Settings ***
Documentation
...   author: Marcin Szlapa, Pawel Marszalek
...   contact: marcin.szlapa@nokia.com, pawel.marszalek@nokia.com

Resource    taf/rfrl/bts/robot/gnb.robot
Resource    taf/rfrl/procedures/SISO/test_models/etsi/resources/Test_Model.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py

*** Keywords ***
Energy_Efficiency_Measurements
    [Arguments]    ${config}    ${load_levels}
    Set Global Variable    ${EE_KPI_TARGETS}    ${kpi_targets["${config}"]}
    gnbbbu.connect
    Run Energy Efficiency Measurement Procedure
    ...                                                 connection=REST_GNB0_DU0
    ...                                                 load_levels=${load_levels}
    Wait Until Keyword Succeeds  900 sec  10 sec  gnbcell.Verify All Cells are OnAir

Test Setup With Commissioning
    [Arguments]    ${prefix_tag}
    Perform Full Commissioning and Wait for onAir    prefix_tag=${prefix_tag}
    Common Preconditions With Watching Alarms
