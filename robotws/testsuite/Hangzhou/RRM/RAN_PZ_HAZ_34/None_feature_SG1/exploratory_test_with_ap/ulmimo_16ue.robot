*** Settings ***
Force Tags    PY36
Documentation
...    Author:
...    Contact:
...    squad
...    Feature

Suite Setup         Setup Suite    ${CFGFILE_PATH}/Trunk_4AEQE_23R2_IWK_ulmimo_16UE_oldbwp.xml
Suite Teardown     Teardown Suite
Resource          ./Resource/wts_airphone_resources.robot

*** Variables ***
${WTS_CFG}              AAA_WTS1.lua
${WTS_CFG1}              AAA_WTS2.lua
*** Test Cases ***
register_multiue_degregister_parallel
    [Documentation]
    [Tags]    CIT_TRUNK  CRT_TRUNK  CRT_22R2
    [Setup]    Setup Case  wts_cfg=${WTS_CFG}
    [Teardown]  Teardown Case
    TC.register_multiue_degregister_parallel

register_multiue_with_pdu_check_traffic_parallel
    [Documentation]
    [Tags]    CIT_TRUNK  CRT_TRUNK  CRT_22R2
    [Setup]    Setup Case  wts_cfg=${WTS_CFG}
    [Teardown]  Teardown Case
    TC.register_multiue_with_pdu_check_traffic_parallel

trigger_overload_with_concurent_ues
    [Documentation]
    [Tags]    CIT_TRUNK  CRT_TRUNK  CRT_22R2
    [Setup]    Setup Case  wts_cfg=${WTS_CFG}
    [Teardown]  Teardown Case
    TC.trigger_overload_with_concurent_ues

trigger_A1_A2_meas_with_concurent_ues
    [Documentation]
    [Tags]    CIT_TRUNK  CRT_TRUNK  CRT_22R2
    [Setup]    Setup Case  wts_cfg=${WTS_CFG1}
    [Teardown]  Teardown Case
    TC.trigger_A1_A2_meas_with_concurent_ues
trigger_A1_meas_to_setup_2CC_CA
    [Documentation]
    [Tags]    CIT_TRUNK  CRT_TRUNK  CRT_22R2
    [Setup]    Setup Case  wts_cfg=${WTS_CFG1}
    [Teardown]  Teardown Case
    TC.trigger_A1_meas_to_setup_2CC_CA

attach_detach_for_loop_with_specify_parameter
    [Documentation]
    [Tags]    CIT_TRUNK  CRT_TRUNK  CRT_22R2
    [Setup]    Setup Case  wts_cfg=${WTS_CFG1}
    [Teardown]  Teardown Case
    TC.attach_detach_for_loop_with_specify_parameter