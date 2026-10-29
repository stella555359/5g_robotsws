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
Resource          ../Common_Case/common_resource_new.robot

*** Variables ***
&{dcap_info}    host=10.56.198.42    port=9443    username=utfuser    password=utfadmin!

*** Test Cases ***
CB006139_AA_07_Stepwise_SCellAddition_after_BadRLQ
    [Tags]    CRT    MN_RAN    RAN_VRF
    [Documentation]
    ...    Author: guoliang.wu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    [Setup]    Case Precondition
    Open DCAP
    ${webem_info}    Get WebEM Info    ne_type=vcu
    ${vcu_profile}    Create List    flowTracerVcu
    ${vcu_trace_id}    Start Capture Log By Dcap    webem_info=${webem_info}    vcu_custom_profile=${vcu_profile}
    Modify PA FDDCellToGood
    Prepare And Attach UE For Qualcomm    ue_index=0
    Modify PA TDDSCell
    Start DL Call For UE    ue_index=0    ue_type=qualcomm
    sleep    10s
    Modify PA TDD2SCellToBad
    sleep    10s
    Modify PA TDD2CellToGood
    Start DL Call For UE    ue_index=0    ue_type=qualcomm
    sleep    10s
    Stop Trace In DCAP    btsip=${webem_info['host']}
    ${trace_file_path}    Get Trace Log    btsip=${webem_info['host']}
#    Test Decoded Emil Log To Csv File    local_file_path=${local_file_path}
    [Teardown]    Case Postcondition

*** Keywords ***
Start DL Call For UE
    [Arguments]    ${ue_index}=${0}     ${ue_type}=${ue_${ue_index}_type}    ${direction}=dl
    Start traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=${direction}    dt_index=${ue_index}
    ...              throughput=1200M    duration=${10}
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

Modify PA FDDCell
    ${source_pa_port_list}     Create List     14
    ${source_pa_value_list}    Create List     0    10
    &{source}    Create Dictionary    att_index=${0}    pa_port=${source_pa_port_list}
    ...                               pa_value=${source_pa_value_list}    step=${1}
    PA Operation    source=&{source}    target=none

Modify PA TDDPCell
    ${source_pa_port_list}     Create List     5    6    7    8
    ${source_pa_value_list}    Create List     0    10
    &{source}    Create Dictionary    att_index=${0}    pa_port=${source_pa_port_list}
    ...                               pa_value=${source_pa_value_list}    step=${5}
    PA Operation    source=&{source}    target=none

Modify PA TDDSCell
    ${source_pa_port_list}     Create List     1    2    3    4    5    6    7    8
    ${source_pa_value_list}    Create List     40    20
    &{source}    Create Dictionary    att_index=${0}    pa_port=${source_pa_port_list}
    ...                               pa_value=${source_pa_value_list}    step=${5}
    PA Operation    source=&{source}    target=none

Modify PA TDD2SCellToBad
    ${source_pa_port_list}     Create List     1    2    3    4    5    6    7    8
    ${source_pa_value_list}    Create List     20    120
    &{source}    Create Dictionary    att_index=${0}    pa_port=${source_pa_port_list}
    ...                               pa_value=${source_pa_value_list}    step=${5}
    PA Operation    source=&{source}    target=none

Modify PA FDDCellToGood
    ${source_pa_port_list}     Create List     13
    ${source_pa_value_list}    Create List     40    10
    &{source}    Create Dictionary    att_index=${0}    pa_port=${source_pa_port_list}
    ...                               pa_value=${source_pa_value_list}    step=${5}
    PA Operation    source=&{source}    target=none


Modify PA TDD2CellToGood
    ${source_pa_port_list}     Create List     1    2    3    4    5    6    7    8
    ${source_pa_value_list}    Create List     50    10
    &{source}    Create Dictionary    att_index=${0}    pa_port=${source_pa_port_list}
    ...                               pa_value=${source_pa_value_list}    step=${5}
    PA Operation    source=&{source}    target=none

Stop Call For UE
    [Arguments]    ${ue_index}=${0}
    Log to Console    \n***Prepare to Stop a Call..***
    Stop traffic    ue_type=${ue_${ue_index}_type}    ue_index=${ue_index}    direction=dl
    sleep    5s    reason=wait call stoped
    Log to Console    \n***Call stoped..***

Set Attenuation Value
    [Arguments]    ${pa_port}    ${pa_value}    ${wait_sleep}=0.5s
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                This keyword is to set values of attenuation which connect to RU.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${pa_port} | No | pa_port which is provided by user, which port you need to change |
    ...    | ${pa_value} | No | What value do you need to set |
    ...
    ...    | Return Value | Description |
    ...    | NA | NA |
    ...
    ...    Example
    ...    | Set Attenuation Value | ${pa_port} | ${pa_value} |
    ...
    Log to Console    ${wait_sleep} is not used
    ${port_length}    Get Length    ${pa_port}
    FOR    ${index}    IN RANGE    ${port_length}
        ${port}    Convert To Integer     ${pa_port[${index}]}
        ${pa_value}    Convert To Integer     ${pa_value}
        Wait Until Keyword Succeeds    5 min    5 sec    attenuator.set_attenuation
        ...    port=${port}    value=${pa_value}
        Check Attenuation Value is updated
        ...    port=${port}    value=${pa_value}
#        sleep    ${wait_sleep}
    END

Open DCAP
    OperatingSystem.Run    DCAP_Basic_controller start

Start Capture Log By Dcap
    [Arguments]    ${webem_info}=${None}   ${vdu_custom_profile}=${None}   ${vcu_custom_profile}=${None}
    Connect To DCAP    ${tl.test_pcs[0].default_ssh_connection_details.addr}    9443    ${None}    ${None}    dcapv3
    ...    ${TRUE}    dcap-master
    Make Sure BTS Integrated In DCAP    bts_dic=${webem_info}

    ${trace_id}    Run Keyword If   '''${vdu_custom_profile}'''!='''${None}'''
    ...         Start Trace In DCAP    ${webem_info}    vdu_custom_profile=${vdu_custom_profile}
    ...  ELSE IF  '''${vcu_custom_profile}'''!='''${None}'''
    ...         Start Trace In DCAP    ${webem_info}    vcu_custom_profile=${vcu_custom_profile}
    Log To Console     Trace Collection start on DCAP
    [Return]    ${trace_id}

Get Trace Log
    [Arguments]    ${btsip}
    ${trace_file_path}    Download Trace File    btsip=${btsip}
    @{zip_file_name}    OperatingSystem.List Files In Directory    ${trace_file_path}    *.zip
    ${zip_file_path}    Set Variable    ${trace_file_path}/${zip_file_name[0]}
    ${target_dir}=    Join Path  ${trace_file_path}  unzip-files
    ${log_file_paths}    Extract log from trace file    tti_archive=${zip_file_path}    directory=${target_dir}    postfix=.5gm
    [Return]    ${log_file_paths}

Get WebEM Info
    [Arguments]    ${ne_type}=vdu   ${gnb_index}=0    ${vdu_index}=0
    ${oam_httpaddr}    Set Variable If    '${ne_type.upper()}'=='VDU'
    ...                 ${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.addr}
    ...                                   '${ne_type.upper()}'=='VCU'
    ...                 ${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}

    ${oam_web_ip}    set variable if    ':' in '''${oam_httpaddr}'''   [${oam_httpaddr}]    ${oam_httpaddr}
    &{webem_info}=    create dictionary    host=${oam_web_ip}    username=Nemuadmin    password=Nokia@123    port=443
    [return]    ${webem_info}

Stop Trace In DCAP
    [Arguments]    ${btsip}    ${trace_id}=None
    [Documentation]    Used to stop trace under DCAP.
    ...    Author: Liu Renhui
    ...    Contact: renhui-david.liu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | btsip | yes | bts ip address |
    ...    | trace_id | no | dcap trace id |
    ...    Example
    ...    | Stop Trace In DCAP | gnb_index=${0} | vdu_index=${0} | timeout=${10}
    ...
    dcap.stop_trace_in_dcap    ${btsip}    trace_id=${trace_id}

Prepare And Attach UE For Qualcomm
    [Arguments]    ${ue_index}=${0}    ${capabilities}=REAL_QUALCOMM_UE
    set test variable    ${ue_type}    qualcomm
    Log to Console    \n***Prepare UE***
    ute_ue.Require Ue    ue_alias=UE_${ue_index}    capabilities=${capabilities}
    Detach UE    ue_index=${ue_index}    ue_type=qualcomm
    UE Attach    ${ue_type}    ue_index=${ue_index}    verify_attach=True
    [Return]     ${ue_type}