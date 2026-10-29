*** Settings ***
Documentation
...    Author: guoliang.wu@nokia-sbell.com

Suite Setup    Common Suite Setup For AIC
#Suite Teardown    Common Suite Teardown For AIC

Force Tags
...      CRT             #Tag Item
...      VRF_HAZ1             #Competence Area
...      TA_LEVEL_22              #Detailed Automation Level[TA_LEVEL_20，TA_LEVEL_21， TA_LEVEL_22]

Test Timeout    600 minutes

Resource          ../../Resources/Cloud/AIC_Common_Resource.robot
Resource          ../Common_Case/common_resource.robot
Resource          ../../../../resources/RAN_PZ_HAZ_1/Module/Module.robot

*** Test Cases ***
CB012219_10_Verification of A2 measurement based on UE attach
    [Tags]    QC_60521    MN_RAN    RAN_VRF
    [Documentation]
    ...    Author: guoliang.wu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    [Setup]    Case Precondition
    Modify PA FDDCell
    Modify PA TDDCell
    Prepare And Attach UE For Qualcomm    ue_index=0
    Start DL Call For UE    ue_index=0    ue_type=qualcomm
    Modify PA Signal
    wait until keyword succeeds   30min  30s   Check CU Counter Update For CB012219
    [Teardown]    Case Postcondition

*** Keywords ***
Parameter Updated In vCU For CB012219_CB011074
    @{para_list}          Create List    actMeasProfileCa
    @{mo_list_vdu}        Create List    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
    @{value_list_true}    Create List    SA
    ${out}                Parameter Operation    operation=parameter_update    product_type=vcu
    ...                                          para_list=@{para_list}    value_list=@{value_list_true}    mo_list=@{mo_list_vdu}
    Log To Console        VCU paramter update result: ${out}

Parameter Disable In vCU For CB012219_CB011074
    @{para_list}          Create List    actMeasProfileCa
    @{mo_list_vdu}        Create List    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
    @{value_list_true}    Create List    deactivated
    ${out}                Parameter Operation    operation=parameter_update    product_type=vcu
    ...                                          para_list=@{para_list}    value_list=@{value_list_true}    mo_list=@{mo_list_vdu}
    Log To Console        VCU paramter update result: ${out}

Prepare And Attach UE For Qualcomm
    [Arguments]    ${ue_index}=${0}    ${capabilities}=REAL_QUALCOMM_UE
    set test variable    ${ue_type}    qualcomm
    Log to Console    \n***Prepare UE***
    ute_ue.Require Ue    ue_alias=UE_${ue_index}    capabilities=${capabilities}
    Detach UE    ue_index=${ue_index}    ue_type=qualcomm
    UE Attach    ${ue_type}    ue_index=${ue_index}    verify_attach=True
    [Return]     ${ue_type}

Start DL Call For UE
    [Arguments]    ${ue_index}=${0}     ${ue_type}=${ue_${ue_index}_type}    ${direction}=dl
    Start traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=${direction}    dt_index=${ue_index}
    ...              throughput=500M    duration=${600}
    sleep    5s    reason=wait call sucessfully

Case Precondition
    log to console    Case Precondition
    Common Test Setup For AIC

Case Postcondition
    log to console    Case Postcondition
    vDU Login By Rest
    Common Test Teardown For AIC
    Run Keyword And Ignore Error    vDU Logout By Rest

Start Counter For CB011074_21
    ${rule}    Catenate
    ...         Distname: MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-3/NRMIAF-1;
    ...         Counter: M55187C00001;
    ...         Counter rule: max(M55187C00001)>0;
    ${rule_list}    Create List    ${rule}
    Log To Console    \nThe rule list is: ${rule_list}
    Counter Operation    operation=start_collect_counter    product_type=vcu    bts_index=0
    ...                                                     counter_rule=${rule_list}

Start Counter For CB011074_22
    ${rule}    Catenate
    ...         Distname: MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-3/NRMIAF-1;
    ...         Counter: M55187C00001;
    ...         Counter rule: latest(M55187C00001)=0;
    ${rule_list}    Create List    ${rule}
    Log To Console    \nThe rule list is: ${rule_list}
    Counter Operation    operation=start_collect_counter    product_type=vcu    bts_index=0
    ...                                                     counter_rule=${rule_list}

Collect And Check Counter
    ${result}    Counter Operation    operation=collect_counter_and_check_rule    product_type=vcu
    ...                               bts_index=0    cudu_index=0
    Log To Console    \nCounter Rule Collect and Check Result is: ${result}

Modify PA Signal
    ${source_pa_port_list}     Create List     14
    ${source_pa_value_list}    Create List     10    50
    &{source}    Create Dictionary    att_index=${0}    pa_port=${source_pa_port_list}
    ...                               pa_value=${source_pa_value_list}    step=${1}
    PA Operation    source=&{source}    target=none

Detach UE
    [Arguments]    ${ue_index}=${0}    ${ue_type}=${ue_${ue_index}_type}
    UE Detach    ${ue_type}    ue_index=${ue_index}
    sleep    60s    reason=wait detach UE Successfully

Check CU Counter Update For CB012219
    ${value_14}=   Check Counter For vCU    counter_id=M55187C00001
    ...                                              measurement_id=55187
    ...                                              dimension_dist_name=MRBTS-10764/NRBTS-10764/NRCELL-3/NRMIAF-1
    ...                                              expected_value=0
    ...                                              get_number=2

Start Counter For CB011074_10
    ${rule}    Catenate
    ...         Distname: MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-3/NRMIAF-1/MIAF;
    ...         Counter: M55187C00001;
    ...         Counter rule: max(M55187C00001)>0;
    ${rule_list}    Create List    ${rule}
    Log To Console    \nThe rule list is: ${rule_list}
    Counter Operation    operation=start_collect_counter    product_type=vcu    bts_index=0
    ...                                                     counter_rule=${rule_list}

Modify PA FDDCell
    ${source_pa_port_list}     Create List     14
    ${source_pa_value_list}    Create List     0    10
    &{source}    Create Dictionary    att_index=${0}    pa_port=${source_pa_port_list}
    ...                               pa_value=${source_pa_value_list}    step=${1}
    PA Operation    source=&{source}    target=none

Modify PA TDDCell
    ${source_pa_port_list}     Create List     5    6    7    8
    ${source_pa_value_list}    Create List     50    40
    &{source}    Create Dictionary    att_index=${0}    pa_port=${source_pa_port_list}
    ...                               pa_value=${source_pa_value_list}    step=${5}
    PA Operation    source=&{source}    target=none

Stop Call For UE
    [Arguments]    ${ue_index}=${0}
    Log to Console    \n***Prepare to Stop a Call..***
    Stop traffic    ue_type=${ue_${ue_index}_type}    ue_index=${ue_index}    direction=dl
    sleep    5s    reason=wait call stoped
    Log to Console    \n***Call stoped..***