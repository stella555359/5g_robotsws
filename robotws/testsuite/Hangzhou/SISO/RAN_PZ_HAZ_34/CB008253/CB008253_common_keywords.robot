# @Time    : 2022/11/8 17:06
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : CB008253_common_keywords.robot
# @Software: PyCharm
*** Settings ***
Documentation    This is CB008253 common robot keywords
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot
Library     taf.hw.optical_switch    WITH NAME    fiberswitch
Library     parse_scf_to_json.py

*** Keywords ***
CB008253 Generate Delta Json Precondition
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ${scf_file}    COAM Download scf from cluster    ${TS_LOG_PATH_BASE}
    generate_ru_delta_json    ${scf_file}    ${MRBTS_ID}    ${CURDIR}

Initialize Configuration Via Disconnect Optical Switch
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${cross_port_setting}    ${delta_file}    ${timeout}=600    ${connection}=GNB_OAM
    coam.perform_delta_recommissioning    delta_file=${delta_file}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=${timeout}    connection=${connection}
    Set Optical Switch Channels And Verify Status    cross_port_setting=${cross_port_setting}
    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
    coam.reset_site    connection=${connection}
    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online

Initialize Configuration Via Disconnect Optical Switch And Disconnect BB
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${cross_port_setting}    ${delta_file}    ${slot}    ${timeout}=600    ${connection}=GNB_OAM
    coam.perform_delta_recommissioning    delta_file=${delta_file}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=${timeout}    connection=${connection}
    Control BBMOD Power Switch    power_status=1    slot=${slot}
    Set Optical Switch Channels And Verify Status    cross_port_setting=${cross_port_setting}
    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
    coam.reset_site    connection=${connection}
    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online

Initialize Configuration Via Delete RU Configuration And Disconnect BB
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${sfp_distname}    ${delta_file}    ${slot}    ${timeout}=600    ${connection}=GNB_OAM
    Control BBMOD Power Switch    power_status=1    slot=${slot}
    Disconnect RU From BBMOD Via SFP    ru_sfp_distname=${sfp_distname}
    coam.perform_delta_recommissioning    delta_file=${delta_file}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=${timeout}    connection=${connection}
    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online
    coam.reset_site    connection=${connection}
    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online

Do Delta Commission And Add RU Then Verify Cells Status
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${sfp_distname}    ${delta_file}    ${slot}=2    ${timeout}=600
    coam.perform_delta_recommissioning    delta_file=${delta_file}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=${timeout}    connection=${connection}
    Control BBMOD Power Switch    power_status=0    slot=${slot}
    Disconnect RU From BBMOD Via SFP    ru_sfp_distname=${sfp_distname}
    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online

Control BBMOD Power Switch
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    power_status=0 --- power on
    ...    power_status=1 --- power off
    [Arguments]    ${power_status}    ${slot}
    Connect To BTS Csn Via Lmp
    ${contents}    Run Keyword If    '${power_status}'=='0'    csn.Execute
    ...    echo 0 > /dev/ddal/power/slot_id_0${slot}/board_pwr_shutdown    connection=ASIK Master    ELSE
    ...    csn.Execute    echo 1 > /dev/ddal/power/slot_id_0${slot}/board_pwr_shutdown    connection=ASIK Master
    [Teardown]  Run Keyword And Ignore Error    csn.disconnect    connection=ASIK Master


Connect RU To BBMOD Via SFP
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${ru_sfp_distname}
    Modify Parameter On BTS With Activate    dist_name=${ru_sfp_distname}    parameter=administrativeState
    ...    value=Unlocked

Disconnect RU From BBMOD Via SFP
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${ru_sfp_distname}
    Modify Parameter On BTS With Activate    dist_name=${ru_sfp_distname}    parameter=administrativeState
    ...    value=Locked

Set Optical Switch Channels And Verify Status
    [Arguments]  ${cross_port_setting}
    ...    ${vendor}=${tl.optical_switches[0].__class__.__name__}
    ...    ${model}=${tl.optical_switches[0].model}
    ...    ${addr}=${tl.optical_switches[0].addr}
    ...    ${port}=4001
    fiberswitch.setup_optical_switch    optical_switch=${vendor}    alias=switch1    model=${model}    addr=${addr}   port=${port}
    fiberswitch.get_optical_switch_channels    optical_switch_device=switch1
    fiberswitch.set_optical_switch_channels    settings=${cross_port_setting}    optical_switch_device=switch1
    sleep      2s
    fiberswitch.get_optical_switch_channels    optical_switch_device=switch1
    [Teardown]    fiberswitch.teardown     optical_switch_device=switch1
