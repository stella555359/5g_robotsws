*** Settings ***
Documentation
...    Author: Wu Guoliang
...    Contact: guoliang.wu@nokia-sbell.com
...    this file is for CB010411.
...    Please do not modify the file without notification to author

Suite Setup    Common Suite Setup For AIC
Suite Teardown     Custom Suite Teardown For AIC

Force Tags
...      CRT             #Tag Item
...      RAN_PZ_HAZ_1             #Competence Area
...      RAN_PZ_HAZ1_SG03_ST_RRM  #Organization
...      TA_LEVEL_22              #Detailed Automation Level[TA_LEVEL_20，TA_LEVEL_21， TA_LEVEL_22]

Test Timeout    600 minutes

Resource          ../../Resources/Cloud/AIC_Common_Resource.robot
Resource          ../../T02/Common_Case/common_resource_new.robot

*** Variables ***
${TESTLINE_NAME}             7-5-UTE5GAIC018T004
${DEFAULT_SCF_PATH}         ${CURDIR}/../../../../../../commissionings/RRM/SRAN_5G/7-5-UTE5GAIC018T004
&{dcap_info}    host=127.0.0.1    port=9443    username=${None}    password=${None}
${tti_path}      /home/ute/tshark/tti/
@{tti_condition_1}    dlFdSchedData.SLIV    ==    57
@{basic_rules}    or    ${tti_condition_1}
&{tti_check_rules_1}         basic_rules=${basic_rules}
&{tti_analysis_dict_1}       check_rules=${tti_check_rules_1}
@{tti_analysis_dict}     ${tti_analysis_dict_1}

*** Test Cases ***
5GC000920case1DLOpenLoop4x4Rank4
    [Tags]    QC_32476    MN_RAN    RAN_VRF
    [Timeout]    30min
    [Documentation]
    ...    Author: guoliang.wu@nokia-sbell.com
    ...    Notice: Only on branch
    ...    history change: <date>,<who>,<what and how>
    ...    08.04.2023,guoliang.wu@nokia-sbell.com, draft
    [Setup]    Common Case Precondition
    Prepare PA
    Prepare And Attach UE For Qualcomm    ue_index=0
    Start DL Call For UE    ue_index=0    ue_type=qualcomm
    ${dict_argument}   Create Dictionary   dcap_server=${dcap_info}
    Log Collection    start    tti    product_type=vdu    bts_index=${0}    cudu_index=${0}    dict_argument=${dict_argument}
    sleep    4s    reason=Waiting For TTI capture
    ${local_file_path}    Log Collection    stop_and_download    tti    product_type=vdu    bts_index=${0}    cudu_index=${0}
    Log To Console    \nTTI log of VDU: ${local_file_path}
#    ${result}=    Log Analysis    check    tti    ${local_file_path}    ${tti_analysis_dict}
#    Log To Console    \nAnalyze log: ${result}
#    Should Be True    ${result[0][0]}
    wait until keyword succeeds   30min  30s   Check DU Counter For Rank4 Is Used
    [Teardown]    Common Case Postcondition For 5GC000920

*** Keywords ***
Common Case Precondition
    log to console    Case Precondition
    Common Test Setup For AIC
    ${NEW_PLAN_NAME}   Get Test Case Name
    Set Test Variable  ${NEW_PLAN_NAME}

Common Case Postcondition
    log to console    Case Postcondition
    Common Test Teardown For AIC
    vDU Login By Rest
    Run Keyword And Ignore Error  plan_name=${NEW_PLAN_NAME}
    Run Keyword And Ignore Error  svdu.Delete Plan  plan_name=${NEW_PLAN_NAME}
    Run Keyword And Ignore Error  vDU Logout By Rest

    Run Keyword And Ignore Error    Detach UE0
    Run Keyword And Ignore Error    wireshark.stop_wireshark_log    pod_name=${pod_name}    namespace=${ns}
    ...                                                             conn=${conn}    timeout=${timeout}
#    Run Keyword And Ignore Error    Stop L1hi Bip Log

Common Case Postcondition For 5GC001301
    Run Keyword And Ignore Error    Stop DL Call For UE0
    Run Keyword And Ignore Error    Stop UL Call For UE0
    Common Case Postcondition

Common Case Postcondition For 5GC001473
    Run Keyword And Ignore Error    Stop DL Call For UE0
    #Run Keyword And Ignore Error    Prepare PA
    #Online Change chBw To 100MHz
    #wait until keyword succeeds   10min  30s   Check All Cells On Air In vCU
    Common Case Postcondition

Common Case Postcondition For 5GC000869
    Run Keyword And Ignore Error    Stop DL Call For UE0
    #Run Keyword And Ignore Error    Prepare PA
    #Online Clear Case Parameter Settings
    #wait until keyword succeeds   10min  60s    Online Change chBw To 100MHz
    #wait until keyword succeeds   10min  30s   Check All Cells On Air In vCU
    Common Case Postcondition

Common Case Postcondition For 5GC000545
    Run Keyword And Ignore Error    Stop UL Call For UE0
    Run Keyword And Ignore Error    Detach UE0
    Common Case Postcondition

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
    ...              throughput=1500M    duration=${300}
    sleep    5s    reason=wait call sucessfully

Start Call For UE with Tput
    [Arguments]    ${ue_index}=${0}        ${direction}=dl    ${tput}=110M
    Start traffic    ue_type=${ue_${ue_index}_type}    ue_index=${ue_index}    direction=${direction}    dt_index=${ue_index}
	...              throughput=${tput}    duration=${600}
	sleep    5s    reason=wait call sucessfully

Stop DL Call for UE0
    Log To Console    \nStop the DL TPUT
    Stop traffic    ${ue_0_type}    ue_index=${0}    direction=dl

Stop UL Call for UE0
    Log To Console    \nStop the UL TPUT
    Stop traffic    ${ue_0_type}    ue_index=${0}    direction=ul

Detach UE0
    UE Detach    ${ue0_type}    ue_index=${0}

Prepare PA
    ${attenuation_channels}     Get Attenuation port    RU_id=0    du_id=0
    ${initial_att_values}    Get Initial Attenuation Values    RU_id=0    vendor=HBTE    du_id=0
    &{channels_to_modify}    create dictionary   ${attenuation_channels[0]}=11    ${attenuation_channels[1]}=11
    ...                                          ${attenuation_channels[2]}=11    ${attenuation_channels[3]}=11
    Modify Attenuation Value    ${channels_to_modify}    RU_id=0    du_id=0
    sleep    10s
    Log to console    PA Attenuation Changed.

Change PA Attenuation Multiple Times
    FOR   ${PA_Value}   IN RANGE   10   55   5
        ${attenuation_channels}     Get Attenuation port    RU_id=0    du_id=0
        ${initial_att_values}    Get Initial Attenuation Values    RU_id=0    vendor=HBTE    du_id=0
        &{channels_to_modify}    create dictionary   ${attenuation_channels[8]}=${PA_Value}    ${attenuation_channels[9]}=${PA_Value}
        Modify Attenuation Value    ${channels_to_modify}    RU_id=0    du_id=0
        sleep    2s
    END

Change PA For DFTSOFDMA Enable
    FOR   ${PA_Value}   IN RANGE    15    60    5
        ${attenuation_channels}     Get Attenuation port    RU_id=0    du_id=0
        ${initial_att_values}    Get Initial Attenuation Values    RU_id=0    vendor=HBTE    du_id=0
        &{channels_to_modify}    create dictionary   ${attenuation_channels[8]}=${PA_Value}    ${attenuation_channels[9]}=${PA_Value}
        Modify Attenuation Value    ${channels_to_modify}    RU_id=0    du_id=0
        sleep    2s
    END

Change PA For DFTSOFDMA Disable
    FOR   ${PA_Value}   IN RANGE    60    15    5
        ${attenuation_channels}     Get Attenuation port    RU_id=0    du_id=0
        ${initial_att_values}    Get Initial Attenuation Values    RU_id=0    vendor=HBTE    du_id=0
        &{channels_to_modify}    create dictionary   ${attenuation_channels[8]}=${PA_Value}    ${attenuation_channels[9]}=${PA_Value}
        Modify Attenuation Value    ${channels_to_modify}    RU_id=0    du_id=0
        sleep    2s
    END

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

##########    5GC000920    ##########
Check DU Counter For Rank4 Is Used
    ${du_counter_id_list}    Create List    M55301C18024
    ${du_counter_values_final_list}    Create List
    FOR    ${du_counter_id}    IN    @{du_counter_id_list}
        ${du_counter_values_final_list}    Check Counter For vDU   counter_id=${du_counter_id}
        ...                                            dimension_dn=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
        ...                                            expected_value=0
        ...                                            get_number=2
    END

Common Case Postcondition For 5GC000920
    Common Case Postcondition