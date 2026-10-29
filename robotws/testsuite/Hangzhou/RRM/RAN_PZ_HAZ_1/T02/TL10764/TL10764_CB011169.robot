*** Settings ***
Documentation
...    Author: Zou Shuang
...    Contact: shuang.zou@nokia-sbell.com
...    this file is for CB010411.
...    Please do not modify the file without notification to author


Suite Setup    Common Suite Setup For AIC
Suite Teardown     Custom Suite Teardown For AIC

Force Tags
...      CRT             #Tag Item
...      RAN_PZ_HAZ_1             #Competence Area
...      RAN_PZ_HAZ1_T02_ST_RRM   #Organization
...      TA_LEVEL_22              #Detailed Automation Level[TA_LEVEL_20，TA_LEVEL_21， TA_LEVEL_22]

Test Timeout    60 minutes

Resource          ../../Resources/Cloud/AIC_Common_Resource.robot

*** Variables ***
${TESTLINE_NAME}             7_5_UTE5GAIC015T005

*** Test Cases ***
CB011169_23_CNI74711_03_Successful NSA inter-Frequency intra-gNB handover between TDD & FDD with both intra-Frequency and inter-Frequency enabled
    [Tags]    CB011169    4.0    RAN_PZ_HAZ_1
    [Documentation]
    ...    Author: shuang.zou@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    22.03.2022, shuang.zou@nokia-sbell.com, draft
    [Setup]    Common Case Precondition
    [Timeout]    1h
    Change PA to NR1CELL
    Prepare And Attach UE For Qualcomm    ue_index=0
    Change PA to NR2CELL
    wait until keyword succeeds   30min  30s   Check CU Counter Update For HO
    [Teardown]    Case Postcondition

*** Keywords ***

Common Case Precondition
    log to console    Case Precondition
    Common Test Setup For AIC
    ${NEW_PLAN_NAME}   Get Test Case Name
    Set Test Variable  ${NEW_PLAN_NAME}

Case Postcondition
    log to console    Case Postcondition
    vDU Login By Rest
    Common Test Teardown For AIC
    Run Keyword And Ignore Error    vDU Logout By Rest

Prepare And Attach UE For Qualcomm
    [Arguments]    ${ue_index}=${0}    ${capabilities}=REAL_QUALCOMM_UE
    set test variable    ${ue_type}    qualcomm
    Log to Console    \n***Prepare UE***
    ute_ue.Require Ue    ue_alias=UE_${ue_index}    capabilities=${capabilities}
    Detach UE    ue_index=${ue_index}    ue_type=qualcomm
    UE Attach    ${ue_type}    ue_index=${ue_index}    verify_attach=True
    [Return]     ${ue_type}

Detach UE
    [Arguments]    ${ue_index}=${0}    ${ue_type}=${ue_${ue_index}_type}
    UE Detach    ${ue_type}    ue_index=${ue_index}
    sleep    60s    reason=wait detach UE Successfully


Start Call For UE
    [Arguments]    ${ue_index}=${0}        ${direction}=dl
    Start traffic    ue_type=${ue_${ue_index}_type}    ue_index=${ue_index}    direction=${direction}    dt_index=${ue_index}
	...              throughput=110M    duration=${600}
	sleep    5s    reason=wait call sucessfully

Stop DL Call for UE0
    Log To Console    \nStop the DL TPUT
    Stop traffic    ${ue_${ue_index}_type}    ue_index=${0}    direction=dl

Stop UL Call for UE0
    Log To Console    \nStop the UL TPUT
    Stop traffic    ${ue_${ue_index}_type}    ue_index=${0}    direction=ul

Get DL Tput By K8s Log
    [Arguments]    ${duration}=${3600}
    Download K8s Log from vDU    duration=${duration}
    ${ave_dl_tput}    ${max_dl_tput}    ${min_dl_tput}    k8s.get_dl_tput_from_k8s_log    ${local_file_path}
    Log To Console    \nAve DL TPUT is: ${ave_dl_tput}
    Log To Console    Max DL TPUT is: ${max_dl_tput}
    Log To Console    Min DL TPUT is: ${min_dl_tput}
    Set Test Variable    ${ave_dl_tput}

Get UL Tput By K8s Log
    [Arguments]    ${duration}=${3600}
    Download K8s Log from vDU    duration=${duration}
    ${ave_ul_tput}    ${max_ul_tput}    ${min_ul_tput}    k8s.get_ul_tput_from_k8s_log    ${local_file_path}
    Log To Console    \nAve UL TPUT is: ${ave_ul_tput}
    Log To Console    Max UL TPUT is: ${max_ul_tput}
    Log To Console    Min UL TPUT is: ${min_ul_tput}
    Set Test Variable    ${ave_ul_tput}

Get DL and UL Tput By K8s Log
    [Arguments]    ${duration}=${3600}
    Download K8s Log from vDU    duration=${duration}
    ${ave_ul_tput}    ${max_ul_tput}    ${min_ul_tput}    k8s.get_ul_tput_from_k8s_log    ${local_file_path}
    Log To Console    \nAve UL TPUT is: ${ave_ul_tput}
    Log To Console    Max UL TPUT is: ${max_ul_tput}
    Log To Console    Min UL TPUT is: ${min_ul_tput}
    Set Test Variable    ${ave_ul_tput}
    ${ave_dl_tput}    ${max_dl_tput}    ${min_dl_tput}    k8s.get_dl_tput_from_k8s_log    ${local_file_path}
    Log To Console    \nAve DL TPUT is: ${ave_dl_tput}
    Log To Console    Max DL TPUT is: ${max_dl_tput}
    Log To Console    Min DL TPUT is: ${min_dl_tput}
    Set Test Variable    ${ave_dl_tput}

Download K8s Log from vDU
    [Arguments]    ${duration}=${3600}
    ${pod_name}=    set variable    l2rt
    ${local_file_path}    Collect And Download K8s Log In vDU    gnb_index=${0}    vdu_index=${0}    container_name=l2rt
    ...                                    pod_name=${pod_name}   timeout=${10}    duration=${duration}
    Set Test Variable    ${local_file_path}

Check DL Tput By K8s Log
    [Arguments]    ${required_ave_dl_tput}=5M
    ${required}    Get Tput from string  ${required_ave_dl_tput}
    should be true  ${ave_dl_tput}>=${required}

Check UL Tput By K8s Log
    [Arguments]    ${required_ave_ul_tput}=5M
    ${required}    Get Tput from string  ${required_ave_ul_tput}
    should be true  ${ave_ul_tput}>=${required}

Get Tput from string
    [Arguments]    ${str}
    ${lst}    Get Regexp Matches    ${str}    (\\d+)\\w+   1
    ${tput}    Convert To Integer  @{lst}[0]
    [Return]    ${tput}

Show Tput report
    ${ul}    Get Tput from string  ${ul_tput}
    ${dl}    Get Tput from string  ${dl_tput}
    ${ul_rate}  Evaluate  ${ave_ul_tput} / ${ul} *100
    ${dl_rate}  Evaluate  ${ave_dl_tput} / ${dl} *100
    ${ul_rounded}  convert to number  ${ul_rate}  2
    ${dl_rounded}  convert to number  ${dl_rate}  2
    Log To Console    \n iperf UL TPUT is: ${ul} \nAve UL TPUT is: ${ave_ul_tput} \nUL TPUT Rate is: ${${ul_rounded}}\%
    Log To Console    \n iperf DL TPUT is: ${dl} \nAve DL TPUT is: ${ave_dl_tput} \nDL TPUT Rate is: ${${dl_rounded}}\%

Custom Suite Teardown For AIC
    Common Suite Teardown For AIC
    ${cmd}=    Set Variable    find ${SUITE_LOG_DIRECTORY} -type f -size +50M ! -name "*.xml" ! -name "*.html"
    ${result}    Run Process    ${cmd}    shell=True
    log to console    ${result.stdout}

    ${cmd_new}=    Set Variable    ${cmd} -exec rm -f {} \\;
    ${result}    Run Process    ${cmd_new}    shell=True
    log to console    ${result.stdout}
    log to console    ${result.stderr}
    log to console    ${result.rc}

Prepare PA
    ${attenuation_channels}     Get Attenuation port    RU_id=0    du_id=0
    ${initial_att_values}    Get Initial Attenuation Values    RU_id=0    vendor=HBTE    du_id=0
    &{channels_to_modify}    create dictionary   ${attenuation_channels[8]}=15    ${attenuation_channels[9]}=15
    Modify Attenuation Value    ${channels_to_modify}    RU_id=0    du_id=0
    sleep    10s
    Log to console    PA Attenuation Changed.

Start L1 Bip Log
    [Arguments]    ${gnb_index}=${0}    ${vdu_index}=${0}
    ...            ${pod_prefix}=po-cran1    ${container_prefix}=ctr-cran1
    ...            ${timeout}=${10}
    ${is_rannic}    Check if vDU Use Rannic
    ${container_to_capture_L1_bip}=   Run Keyword If    '${is_rannic}'=='True'
    ...               set variable    l2rt
    ...       ELSE    set variable    l1hi
    ${port_name}=   Run Keyword If    '${is_rannic}'=='True'
    ...               set variable    l1up
    ...       ELSE    set variable    l1bipl1
    ${pod_to_capture_L1_bip}=    set variable    l2rt
    Set Test Variable    ${is_rannic}
    Set Test Variable    ${pod_to_capture_L1_bip}
    Set Test Variable    ${container_to_capture_L1_bip}
    Start Bip Log    gnb_index=${gnb_index}    vdu_index=${vdu_index}
    ...              container_name=${container_to_capture_L1_bip}
    ...              pod_name=${pod_to_capture_L1_bip}    pod_prefix=${pod_prefix}
    ...              container_prefix=${container_prefix}    port_name=${port_name}
    ...              timeout=${timeout}

Stop L1 Bip Log And Download To K8s Master
    [Arguments]    ${gnb_index}=${0}    ${vdu_index}=${0}
    ...            ${pod_prefix}=po-cran1    ${container_prefix}=ctr-cran1    ${timeout}=${10}
    ${l1_bip_local_file_path}=    Stop Bip Log And Download To K8s Master
    ...    gnb_index=${gnb_index}    vdu_index=${vdu_index}
    ...    container_name=${container_to_capture_L1_bip}    pod_name=${pod_to_capture_L1_bip}
    ...    pod_prefix=${pod_prefix}    container_prefix=${container_prefix}
    ...    timeout=${timeout}
    [Return]   ${l1_bip_local_file_path}

############################## CB008124 ##############################
Online Set VCU Parameters For HO
    ${mo_dn1}   Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ${value_actRedirect}    Set Variable    true
    &{param_actRedirect}    create dictionary    oactInterRatHoFromEutraToSA=true    nonContentRachAcFullConfigHo=true
    ...                                          tNgRelocExecDeltL=5000
    @{updated_actRedirect}    Create List    ${param_actRedirect}
    vCU Online modify Simple Parameters Via Rest With Compare    parameter_name=actRedirect
    ...                                                   updated_paras_dict=${updated_actRedirect}
    ...                                                   compare_value=${value_actRedirect}
    ...                                                   mo_dn=${mo_dn1}

Online Set VDU Parameters For HO
    Log To Console    \nActive HO
    ${mo_dn}   Set Variable    MRBTS-${MRBTS_ID_vDU}/NRBTS-${NRBTS_ID}
    &{parameter_dict}    Create Dictionary   actInterRatHoFromEutraToSA=true    nonContentRachAcFullConfigHo=true
    ...                                      t304=ms2000
    &{parameter_dict1}    Judge Whether The Parameter Needs To Be Modified    mo_dn=${mo_dn}
    ...                                                                      mo_parameter_dict=&{parameter_dict}
    vDU Login By Rest
    Run Keyword If  &{parameter_dict1} != &{Empty}
    ...             VDU Online Modify Parameters By Delta Plan REST    mo_dn=${mo_dn}
	...                                          updated_paras_list=${parameter_dict}
	...                                          operation=replace
	...                                          activate=${True}
    ...                                          force_reset=${False}
    ...                                          auto_lock_cells=${False}
    ...                                          wait_vdu_up=${False}
    vDU Logout By Rest

Change PA to NR1CELL
    [Arguments]    ${PA_Value_NR}=0
    Log To Console    ${PA_Value_NR}
    ${attenuation_channels}     Get Attenuation port    RU_id=0    du_id=0
    ${initial_att_values}    Get Initial Attenuation Values    RU_id=0    vendor=HBTE    du_id=0
    &{channels_to_modify}    create dictionary   ${attenuation_channels[0]}=127
    ...                                          ${attenuation_channels[1]}=127
    ...                                          ${attenuation_channels[2]}=127
    ...                                          ${attenuation_channels[3]}=127
    Modify Attenuation Value    ${channels_to_modify}    RU_id=0    du_id=0
    sleep    1s
    Log to console    NR2 Attenuation Changed.
    ${attenuation_channels}     Get Attenuation port    RU_id=3    du_id=0
    ${initial_att_values}    Get Initial Attenuation Values    RU_id=3    vendor=HBTE    du_id=0
    &{channels_to_modify}    create dictionary   ${attenuation_channels[0]}=0
    Modify Attenuation Value    ${channels_to_modify}    RU_id=3    du_id=0
    sleep    1s
    Log to console    lte cell Attenuation Changed.
    ${attenuation_channels}     Get Attenuation port    RU_id=2    du_id=0
    ${initial_att_values}    Get Initial Attenuation Values    RU_id=2    vendor=HBTE    du_id=0
    &{channels_to_modify}    create dictionary   ${attenuation_channels[0]}=40
    Modify Attenuation Value    ${channels_to_modify}    RU_id=2    du_id=0
    sleep    1s
    Log to console    NR1 cell Attenuation Changed.

Change PA to NR2CELL
    [Arguments]    ${PA_Value_NR}=40
    ${attenuation_channels}     Get Attenuation port    RU_id=0    du_id=0
    ${initial_att_values}    Get Initial Attenuation Values    RU_id=0    vendor=HBTE    du_id=0
    &{channels_to_modify}    create dictionary   ${attenuation_channels[0]}=${PA_Value_NR}
    ...                                          ${attenuation_channels[1]}=${PA_Value_NR}
    ...                                          ${attenuation_channels[2]}=${PA_Value_NR}
    ...                                          ${attenuation_channels[3]}=${PA_Value_NR}
    Modify Attenuation Value    ${channels_to_modify}    RU_id=0    du_id=0
    sleep    1s
    Log to console    NR2 Attenuation Changed.
    FOR   ${PA_Value2}   IN RANGE   40   80   3
        ${attenuation_channels}     Get Attenuation port    RU_id=2    du_id=0
        ${initial_att_values}    Get Initial Attenuation Values    RU_id=2    vendor=HBTE    du_id=0
        &{channels_to_modify}    create dictionary   ${attenuation_channels[0]}=${PA_Value2}
        Modify Attenuation Value    ${channels_to_modify}    RU_id=2    du_id=0
        sleep    2s
    END

Check CU Counter Update For HO
   ${value_14}=   Check Counter For vCU    counter_id=M55151C00001
    ...                                              measurement_id=55151
    ...                                              dimension_dist_name=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-3
    ...                                              expected_value=0
    ...                                              get_number=5