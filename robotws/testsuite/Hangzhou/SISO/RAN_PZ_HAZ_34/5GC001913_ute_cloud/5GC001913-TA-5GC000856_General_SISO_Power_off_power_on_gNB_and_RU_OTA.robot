# # #*** Settings ***
# # #Documentation
# # #...               author: Steven Liu
# # #...               contact: steven.liu@nokia-sbell.com
# # #...               squad group: MMW_SG_04
# # #Force Tags        5G_SISO    5GC001913    CRT_20B    CRT_TRUNK
# # #...    PY36
# # #Suite Setup       Suite Setup
# # #Suite Teardown    Suite Teardown
# # #Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_2/resources/common_pre_post_condition.robot
# # #Resource          taf/rfrl/bts/robot/recovery_gnb.robot
# # ##Resource          ../common/made_siso_common.robot
# # #Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# # #Resource          resources/trans_comm.robot
# # #Library           taf.pdu    WITH NAME    pdu
# # #
# # #*** Variables ***
# # #${pb_status}   on
# # #${bbu_powerstation_model}   HBTE
# # #${ru_powerstation_model}   HBTE
# # #
# # #*** Test Cases ***
# # #[1][1.0] 5GC001913-TA-5GC000856_General_SISO_Power_off_power on_gNB_and_RU_OTA
# # #    [Tags]     5G_SISO    5GC001913    CRT_20B    CRT_TRUNK   CRT_21B     5GC000856     5GC000959    5GC001591
# # #    [Setup]
# # #    Step1:Login and check
# # #    Step2:PB off
# # #    Step3:PB on
# # #    [Teardown]    CI_interface.Common Case Teardown
# # #
# # #*** Keywords ***
# # #
# # #Step1:Login and check
# # #    Log To Console     Check BTS Should Be Normal
# # #    Rest Login DU
# # #    Wait Until BTS Should Be Normal
# # #
# # #Step2:PB off
# # #    PB execution       pb_ip=${tl.pdus[0].addr}  pb_port=${tl.pdus[0].port_numbers[0]}   action=off
# # #    PB execution       pb_ip=${tl.pdus[1].addr}  pb_port=${tl.pdus[1].port_numbers[0]}   action=off
# # #    Sleep              10s
# # #
# # #Step3:PB on
# # #    PB execution       pb_ip=${tl.pdus[0].addr}  pb_port=${tl.pdus[0].port_numbers[0]}   action=on
# # #    PB execution       pb_ip=${tl.pdus[1].addr}  pb_port=${tl.pdus[1].port_numbers[0]}   action=on
# # #    Log To Console     Check BTS Should Be Normal
# # #    Wait Until Keyword Succeeds     10min    30s   Rest Login DU
# # #    Wait Until BTS Should Be Normal
# # #
# # #PB execution
# # #    [Arguments]        ${pb_ip}   ${pb_port}   ${action}
# # #    pdu.setup_pdu      model=${bbu_powerstation_model}   host=${pb_ip}   alias=BBU
# # #    Run Keyword        pdu.power_${action}   port=${pb_port}   pdu_device=BBU
# # #    Set Suite Variable   ${pb_status}   ${action}
# # #
# # #Suite Setup
# # #    TRANS Common Setup
# # #
# # #Suite Teardown
# # #    TRANS Common Teardown
