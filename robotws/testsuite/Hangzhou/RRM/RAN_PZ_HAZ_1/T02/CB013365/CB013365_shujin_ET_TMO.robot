*** Settings ***
Documentation
...                 author:  shujin

Resource    ./CB013365_Resource.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Variables   ./Variables.py


Force Tags        CRT    QCD_MN_RAN    QCP_RAN_VRF    CA_RAN_PZ_HAZ_1     CLOUD_5G_I_LOO_AP_LOOO

*** Test Cases ***
Load_Configuration
    Setup_for_TMOUS  config_tag=tmous

TC04_05_CB013365_SR_A_EC1_Unsuccessful setup of SA GBR Qos flows due to GBR service feature not being activated or NRDRB_5QI is not configured
    [Tags]    CRT    TC04_05
    [Documentation]
    ...    Author: shunxin.jin@nokia-sbell.com
	...    Description: This user scenario verify the behavior of the gNB when attempting to set up GBR QoS flows with specific 5QI values,
    ...                 which fails due to the GBR service feature not being activated or related or NRDRB_5QI is not configured,
    ...                 despite the CB013365 feature being enabled
    ...    history change: <date>,<who>,<what and how>
	...                    2025.11.18,shunxin jin, initial create
	[Setup]    CB013365 Test Setup
	CB013365_Change_Parameter
    start_log_collection
	sleep    5s
	CB013365_Change_UE_Location  ue_id=1  enb_id=2  cell_id=10
	Execute Egate Command    cmd=ue_deregister id=1 ue_deregister_type=switch_off
	sleep    5s
	Execute Egate Command    cmd=qosflow_modify qos_flow=35 default=on
    Execute Egate Command    cmd=ue_register id=1
    ...                      pass_regexp=UE now in NG RM Registered state
    Execute Egate Command    cmd=ue_pdu_session_setup ue=1 pdu=1 nwslice=1 gw=1
    ...    pass_regexp=Initial Context Setup Successful
    ...    timeout=15s
    Execute Egate Command    cmd=ue_pdu_session_modify ue=1 pdu=1 qosflows_to_add=3 by=amf
    ...    pass_regexp=not-supported-5QI-value
    ...    timeout=15s
    Execute Egate Command    cmd=qosflow_modify qos_flow=8 default=on
    Execute Egate Command    cmd=ue_pdu_session_setup ue=1 pdu=2 nwslice=1 gw=2
    ...    pass_regexp=not-supported-5QI-value
    ...    timeout=15s
    Execute Egate Command    cmd=ue_deregister id=1 ue_deregister_type=switch_off
    ...    pass_regexp=UE1: detached
    ...    timeout=15s
    stop_log_collection
    [Teardown]    CB013365 Test teardown

*** Keywords ***
CB013365 Test Setup
    Setup_for_TMOUS  config_tag=tmous
    robot_common_operations.Common Case Setup

CB013365 Test teardown
    robot_common_operations.Common Case Teardown
	CI_interface.Common Case Teardown

CB013365 Suite Setup
    robot_common_operations.Common Suite Setup
	CI_interface.Common Suite Setup

CB013365_Change_Parameter
    [Arguments]    ${parameter}=actSupportAll5qiAndQci  ${value}=true    ${product_type}=gnb

    @{para_list}      Create List    ${parameter}
    @{mo_list}        Create List    MRBTS-1/NRBTS-1
    @{value_list}     Create List    ${value}
    ${out}    Parameter Operation
    ...    operation=parameter_value_check    product_type=${product_type}
    ...    para_list=@{para_list}    mo_list=@{mo_list}
    Log To Console    \nGNB Parameter Check Result: ${out}

    ${out}    Parameter Operation
    ...    operation=parameter_update    product_type=${product_type}
    ...    para_list=@{para_list}    value_list=@{value_list}    mo_list=@{mo_list}

    ${out}    Parameter Operation
    ...    operation=parameter_value_check    product_type=${product_type}
    ...    para_list=@{para_list}    mo_list=@{mo_list}
    Log To Console    \nGNB Parameter Check Result: ${out}

    BTS Operation    operation=verify    product_type=${product_type}   distname_id=NRCELL-ALL
    ...              verify_status=CELL_ONAIR    timeout=180s