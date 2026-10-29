*** Settings ***
Documentation
...   Author: Qin Zhixia
...   Contact: zhixia.qin@nokia-sbell.com
...   Description: The purpose of this test is to Check CNI129090

Suite Setup       Common Suite Setup For AIC
Suite Teardown    Common Suite Teardown For AIC
Test Setup        Common Test Setup For AIC
Test Teardown     Common Test Teardown For AIC
Force Tags
...                CA_RAN_PZ_HAZ_1
...                RAN_PZ_HAZ1_SG02_ST_RRM
...                TA_LEVEL_22
...                CRT
...                TRUNK


Test Timeout    180 minutes

Resource          ../../../Resources/Cloud/AIC_Common_Resource.robot

*** Variables ***
&{dcap_info}    host=127.0.0.1    port=9443    username=${None}    password=${None}
*** Test Cases ***
[TC05]CNI129090_CR_TC05_DL_IQ_Data_Capture_MSG2_Failure_single_UE
    [Tags]    QC_XXX       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    1. This user scenario to test L1-IQ can be saved while msg2 not scheduled.
    ...    2. Preconditions :
    ...       System is up and running.
    ...       gNB is up and running with SA.
    ...    3. Test Case Steps:
    ...       step1. update the RD parameters
    ...       step2. UE attached to SA with Rach Failure
    ...    4. Expert Result:
    ...       a. UE attaced failed
    ...       b. DL-IQ can be saved while msg2 not scheduled.
    [Setup]    Case Precondition For Cloud
    Airphone Operation    edaemon_egate_setup  vdu  tag=cloud
    Log Collection    start    bip    product_type=vdu    bts_index=${0}    cudu_index=${0}
    Introduce msg3 rach failure
    UE Register with Rach Failure   ue_id=1
    [Teardown]   TC05 Teardown

*** Keywords ***
Case Precondition For Cloud
    log to console    Case Precondition
    Case Precondition   operation=env_setup_sa  tag=cloud
    start_dcap_controller_common
    OperatingSystem.Run     DCAP_Basic_controller start

Case Precondition
    [Arguments]   ${operation}=env_setup_sa   ${tag}=cloud
    Airphone Operation  edaemon_egate_setup  vdu  tag=${tag}
    Airphone Operation  ${operation}  vdu  tag=${tag}

Introduce msg3 rach failure
    [Arguments]    ${ue_id}=1   ${missed_ra_resp_num}=10
	${cont_testmode}		Set Variable		cont_res_testmode_nr profile_id=1 missed_ra_resp=${missed_ra_resp_num}
	${ue_testmode}		Set Variable	ue_testmode_set_nr id=${ue_id} testmode=contention_resolution action=activate profile_id=1
	ute_wtssim.Execute Egate Command    ${cont_testmode}    timeout=60s
	ute_wtssim.Execute Egate Command    ${ue_testmode}    timeout=60s

UE Register with Rach Failure
    [Arguments]    ${ue_id}=1  ${gnb_id}=2  ${cell_id}=3   ${pass_regexp}=T300 expiration
    Airphone Execute Egate Command    cmd=ue_change_location id=${ue_id} enb=${gnb_id} cell=${cell_id}
    Airphone Execute Egate Command    cmd=ue_register id=${ue_id}    pass_regexp=${pass_regexp}

Introduce exit test mode
    [Arguments]    ${ue_id}=1
	${ue_testmode}		Set Variable	ue_testmode_set_nr id=${ue_id} testmode=contention_resolution action=deactivate profile_id=1
	${cont_testmode}    Set Variable    cont_res_testmode_nr profile_id=1 delete=true
	ute_wtssim.Execute Egate Command    ${ue_testmode}    timeout=60s
	ute_wtssim.Execute Egate Command    ${cont_testmode}    timeout=60s

UE Deregister From gNB
    [Arguments]    ${ue_id}=1
    Airphone Execute Egate Command   cmd=ue_deregister id=${ue_id} ue_deregister_type=switch_off

TC05 Teardown
    sleep   10s
    ${local_file_path}    Log Collection    stop_and_download    bip    product_type=vdu
    Introduce exit test mode
    UE Deregister From gNB    ue_id=1