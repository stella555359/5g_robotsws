*** Settings ***
Documentation
...    Author: Guo Qianqian
...    Contact: qianqian.guo@nokia-sbell.com
...    this file is for CB007292 case10 of 25R1.
...    Please do not modify the file without notification to author

Suite Setup    Run keywords    Common Suite Setup For AIC
...            AND    Config network For Local Env_250
Suite Teardown    Common Suite Teardown For AIC

Force Tags
...      CRT             #Tag Item
...      RAN_PZ_HAZ_1             #Competence Area
...      RAN_PZ_HAZ1_SG03_ST_RRM  #Organization
...      TA_LEVEL_22              #Detailed Automation Level[TA_LEVEL_20，TA_LEVEL_21， TA_LEVEL_22]

Test Timeout    600 minutes

Resource          ../../Resources/Cloud/AIC_Common_Resource.robot
Resource          ../../T02/Common_Case/common_resource_new.robot




*** Test Cases ***
Upgrade_airphone_and_wts_build
    [Tags]    upgrade_airphone
    Config Iphy Ip For Local Env_250
    [Teardown]    Case Postcondition

[1.0] CB007292-C_EC1_Emergency_call_AC_failure_without_5QI5_or_5QI1
    [Tags]    CB007292    CRT    RAN_PZ_HAZ_1    CLOUD_5GC_dRNIC_1vDU_P_AP_LO_DC
    [Documentation]
    ...    Author: qianqian.guo@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    [Setup]    Case Precondition
    Start Counter For CB007292_T10
    Log to Console		\n Start wireshark capture for CP traffic\n
    Collect Wireshark Log    log_type=wireshark_cp    product_type=vcu    bts_index=${0}
#	Enter Egate
    Log to Console		\n Registering UE1\n
    Send AP Command    cmd=ue_register id=1
    ...                pass_regexp=UE now in NG RM Registered state
    ...                timeout=100s
    Log to Console		\n UE1 Trigger emergency call on 5QI-2\n
    Send AP Command    cmd=smf_param additional_qosflows_to_activate=2 id=1
    ...                pass_regexp=${None}
    ...                timeout=100s
    Send AP Command    cmd=ue_pdu_session_setup pdu=1 ue=1 nwslice=1 gw=1 request_type=initial-emergency-request
    ...                pass_regexp=UE-1 PDU SESSION ID-1 setup/reestablishment complete
    ...                timeout=100s
    Log to Console		\n Registering UE5\n
    Send AP Command    cmd=ue_register id=5
    ...                pass_regexp=UE now in NG RM Registered state
    ...                timeout=100s
    Log to Console		\n UE5 Trigger emergency call on 5QI-2\n
    Send AP Command    cmd=smf_param additional_qosflows_to_activate=2 id=1
    ...                pass_regexp=${None}
    ...                timeout=100s
    Send AP Command    cmd=ue_pdu_session_setup pdu=2 ue=5 nwslice=1 gw=5 request_type=initial-emergency-request
    ...                pass_regexp=Initial Context Setup Failure from GNB-2 with cause RAN radio resources not available
    ...                timeout=100s
    Log to Console		\n Stop wireshark capture for CP traffic\n
    ${local_file_path}    Stop And Download Wireshark Log    log_type=wireshark_cp    product_type=vcu    bts_index=${0}
    sleep    10min
    Log to Console		\n check CU counter update for M55125C05503(NNGCC_UE_CTXT_STP_FAIL_EC_SENT)\n
    Collect And Check Counter    product_type=vcu    bts_index=${0}    cudu_index=0
    [Teardown]    Case Postcondition

*** Keywords ***

Case Precondition
    Case Precondition For AP    tag=CB007292_T10    product_type=vdu    operation=env_setup_sa
    Log To Console  \n===Case Precondition Finished===

Case Postcondition
    Case Postcondition For AP
    Log To Console  \n===Case Postcondition Finished===

Start Counter For CB007292_T10
    ${rule}    Catenate
#        ...         Distname: MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1;
		...         Distname: MRBTS-11073/NRBTS-11073/NRCELL-1;
        ...         Counter: M55125C05503;
        ...         Counter rule: max(M55125C05503)==1;
    ${rule_list}    Create List    ${rule}
    Start Counter    rule_list=${rule_list}    product_type=vcu    bts_index=0

Enter Egate
	Airphone Operation    operation=edaemon_egate_setup
	...                   product_type=${None}
	...                   traffic_info_dic=${None}
	...                   tag=${None}
	...                   cmd=${None}
	...                   pass_regexp=${None}
	...                   timeout=100s