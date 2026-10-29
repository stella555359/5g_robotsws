*** Settings ***
Documentation
...    Author:
...    Email address:
...    Maintainer:

Library             python/iphy_xml_modify.py
Library             python/vran_operate.py
Library             python/tak_airphone/    WITH NAME    tak_ap
Library             python/tak_xml/    WITH NAME    tak_xml
############# ET Airphone ##########
Library             ute_wtssim
Library             ute_fsmaccess
*** Variables ***
${AP_DL_THRESHOLD}    175
${NSA_UE_ID_START}    101
${SAVE_EGATE_AFTER_DOWN}    ${TRUE}
&{AP}                ip=192.168.200.1    username=toor4nsn    password=oZPS0POrRieRtu
&{AP_ASIK}           ip=192.168.200.1    username=toor4nsn    password=oZPS0POrRieRtu    connection=APAsik
&{AP_ABIL_1}         ip=192.168.253.85    username=toor4nsn    password=oZPS0POrRieRtu    connection=APAbil_1
&{AP_ABIL_0}         ip=192.168.253.84    username=toor4nsn    password=oZPS0POrRieRtu    connection=APAbil_0
${need_sib_check}    ${TRUE}
*** Keywords ***
Airphone Change Iphy Xml
    [Documentation]    Author: He winnie
    ...                Contact: winnie.he@nokia-sbell.com
    [Arguments]    ${iphy_xml_path}
    change_iphy_rru_version    iphy_xml_path=${iphy_xml_path}

_airphone get airphone software version
    [Documentation]    Author: He winnie
    ...                Contact: winnie.he@nokia-sbell.com
    ...   This keyword is to get airphone software version
    ...    Example:
    ...    | Get Airphone Software Version | |
    ...    | ${AP_version}= | Get Airphone Software Version |
    ute_fsmaccess.Setup Wts Fsm Access
    ${cmd}=    Set Variable    ls /ffs/run/TargetBD_5G_*.xml
    ${targetbd_file}=    ute_fsmaccess.Execute Command On Wts    ${cmd}
    ${tmp1}=    String.Fetch From Right    ${targetbd_file}    TargetBD_
    ${AP_version}=    String.Fetch From Left    ${tmp1}    .xml
    Log    AP Software Version: ${AP_version}      console=${True}
    Set Suite Metadata    AP Version    ${AP_version}
    [Teardown]    ute_fsmaccess.Teardown Wts Fsm Access
    [Return]    ${AP_version}

_airphone get WTS version
    [Documentation]    Author: He winnie
    ...                Contact: winnie.he@nokia-sbell.com
    ...    This keyword is to get WTS version including below 1 suite variable.
    ...    | Suite variable | Example | Description |
    ...    | ${WTS_VERSION} | 4.0.13303 | WTS version |
    ...    Example:
    ...    | Get WTS Version | |
    ...    | ${wts_version}= | Get WTS Version |
    ${rc}    ${output}    OperatingSystem.Run And Return Rc And Output    ls -la /opt/wts/latest
    @{split_list}    String.Split String    ${output}    /
    Set Global Variable    ${WTS_VERSION}    ${split_list[-1]}
    Set Suite Metadata    WTS Version    ${WTS_VERSION}
    Log    WTS Version: ${WTS_VERSION}      console=${True}
    [Return]    ${WTS_VERSION}

Airphone Edaemon Egate Setup
    [Documentation]    Author: He winnie
    ...                Contact: winnie.he@nokia-sbell.com
    [Arguments]    ${edaemon_port}=22222    ${egate_port}=20000
    ...     ${save_egate}=${SAVE_EGATE_AFTER_DOWN}    ${alias}=default
    tak_ap.airphone_setup    edaemon_port=${edaemon_port}    egate_port=${egate_port}
    ...    alias=${alias}
    ute_wtssim.setup_egate    egate_port=${egate_port}    alias=${alias}
    ...    save_egate=${save_egate}
    _airphone get airphone software version
    _airphone get WTS version

Airphone Cfg Configuration
    [Documentation]    Author: He winnie
    ...                Contact: winnie.he@nokia-sbell.com
    ...    This keyword is to kill Running WTS Binaries If Any, Configure ETH3, Retrieve Files And Configure WTS
    [Arguments]    ${wts_cfg_name}=wts.cfg
    ...            ${reload}=${True}
    ...            ${cell_type}=sa
    ...            ${timeout}=900
    tak_ap.airphone_start_wtssim_with_cfg_file    cfg_file=${wts_cfg_name}
    ...    reload=${reload}
    Run Keyword If    '${cell_type}' == 'nsa' and '${reload}' == '${True}'    _wait_sim_state_until_active_and_setup_x2_connection
    ...               timeout=${timeout}
    Run Keyword If    '${cell_type}' == 'sansa' and '${reload}' == '${True}'  _wait_until_sib1_received_and_setup_x2_connection    timeout=${timeout}
    Run Keyword If    '${cell_type}' == 'sa' and '${reload}' == '${True}'    _wait_until_sib1_received_for_all_cells    timeout=${timeout}

Get Airphone Software Version
    [Documentation]    Author: He winnie
    ...                Contact: winnie.he@nokia-sbell.com
    ...    This keyword is to get airphone software version
    ...    Example:
    ...    | Get Airphone Software Version | |
    ...    | ${AP_version}= | Get Airphone Software Version |
    ute_fsmaccess.Setup Wts Fsm Access
    ${cmd}=    Set Variable    ls /ffs/run/TargetBD_5G_*.xml
    ${targetbd_file}=    ute_fsmaccess.Execute Command On Wts    ${cmd}
    ${tmp1}=    String.Fetch From Right    ${targetbd_file}    TargetBD_
    ${AP_version}=    String.Fetch From Left    ${tmp1}    .xml
    Log    AP Software Version: ${AP_version}      console=${True}
    Set Suite Metadata    AP Version    ${AP_version}
    [Teardown]    ute_fsmaccess.Teardown Wts Fsm Access
    [Return]    ${AP_version}

Get WTS Version
    [Documentation]    Author: He winnie
    ...                Contact: winnie.he@nokia-sbell.com
    ...    This keyword is to get WTS version including below 1 suite variable.
    ...    | Suite variable | Example | Description |
    ...    | ${WTS_VERSION} | 4.0.13303 | WTS version |
    ...    Example:
    ...    | Get WTS Version | |
    ...    | ${wts_version}= | Get WTS Version |
    ${rc}    ${output}    OperatingSystem.Run And Return Rc And Output    ls -la /opt/wts/latest
    @{split_list}    String.Split String    ${output}    /
    Set Global Variable    ${WTS_VERSION}    ${split_list[-1]}
    Set Suite Metadata    WTS Version    ${WTS_VERSION}
    Log    WTS Version: ${WTS_VERSION}      console=${True}
    [Return]    ${WTS_VERSION}

Get RU Type
    [Arguments]    ${iphy_file}=${EMPTY}
    [Documentation]    Author: He winnie
    ...                Contact: winnie.he@nokia-sbell.com
    ...    this keyword is used to Get RU Type, AEQA,AAHF,AHLOA etc.
    ...    Example:
    ...    | ${RU_TYPE} | Get RU Type | |
    ...    | ${RU_TYPE} | Get RU Type | iphy.xml |
    ute_fsmaccess.Setup Wts Fsm Access
    ${online_cmd}=    Set Variable    cat /ffs/run/simmode/iphy.xml|grep -Eo "<cardName>.*</cardName>"|grep -Eo "[[:upper:]]{4,5}"|head -1
    ${local_cmd}=    Set Variable    cat ${iphy_file}|grep -Eo "<cardName>.*</cardName>"|grep -Eo "[[:upper:]]{4,5}"|head -1
    ${RU_TYPE}=    Run Keyword If    '${iphy_file}'=='${EMPTY}'    ute_fsmaccess.Execute Command On Wts    ${online_cmd}
    ...    ELSE    OperatingSystem.Run    ${local_cmd}
    ${RU_TYPE}=    String.Replace String Using Regexp    ${RU_TYPE}    \x00    ${EMPTY}
    Log    RRU Type is ${RU_TYPE}    console=${True}
    [Teardown]    ute_fsmaccess.Teardown Wts Fsm Access
    [Return]    ${RU_TYPE}

Backup Iphy Xml File
    [Arguments]    ${log_dir}    ${backup_name}=iphy.xml
    [Documentation]    Author: He winnie
    ...                Contact: winnie.he@nokia-sbell.com
    ...    This keyword is to back up SCF file
    ...    | Input Parameters | Man. | Description |
    ...    | ${log_dir} | Yes | the folder directory to store the scf file |
    ...    | ${backup_name} | No | the saved iphy.xml file name. default:iphy.xml |
    ...    Examples:
    ...    | Backup Iphy Xml File | /tmp |
    ${remote_path}=    Set Variable    /ffs/run/simmode/iphy.xml
    ${local_path}=    Set Variable    ${log_dir}/${backup_name}
    ${cp_cmd}=    Set Variable    sshpass -p ${AP_ASIK.password} scp ${AP_ASIK.username}@${AP_ASIK.ip}:${remote_path} ${local_path}
    OperatingSystem.Run    ${cp_cmd}

Backup AP Swconfig File
    [Arguments]    ${log_dir}    ${backup_name}=ap_swconfig.txt
    [Documentation]    Author: He winnie
    ...                Contact: winnie.he@nokia-sbell.com
    ...    This keyword is to back up airphone swconfig file
    ...    | Input Parameters | Man. | Description |
    ...    | ${log_dir} | Yes | the folder directory to store the swconfig file |
    ...    | ${backup_name} | No | the saved swconfig file name. default:ap_swconfig.xml |
    ...    Examples:
    ...    | Backup AP Swconfig File | /tmp |
    ${remote_path}=    Set Variable    /ffs/run/swconfig.txt
    ${local_path}=    Set Variable    ${log_dir}/${backup_name}
    ${cp_cmd}=    Set Variable    sshpass -p ${AP_ASIK.password} scp ${AP_ASIK.username}@${AP_ASIK.ip}:${remote_path} ${local_path}
    OperatingSystem.Run    ${cp_cmd}

_sim_state_is_active
    [Documentation]    Author: He winnie
    ...    Contact: winnie.he@nokia-sbell.com
    ...    This keyword is used to check if sim state is active
    [Arguments]    ${alias}=default
    ${sim_state}=    tak_ap.Airphone Get Sim State    ${alias}
    ${state}=    String.Convert To Lowercase    ${sim_state}
    Should Be Equal    ${state}    active

_wait_sim_state_until_active_and_setup_x2_connection
    [Arguments]    ${alias}=default    ${timeout}=180
    [Documentation]    Author: He winnie
    ...                Contact: winnie.he@nokia-sbell.com
    ...    This keyword is used to wait sim state active until timeout happened, then setup x2 connection
    ...    | Input Parameters | Man. | Description |
    ...    | ${timeout} | No | wait timeout, default is 180 |
    ...    Examples:
    ...    | Wait Sim State Until Active | 180 |
    Log To Console    ...wait sim state active and setup x2 connection...
    Wait Until Keyword Succeeds     ${timeout}     15     _sim_state_is_active
    ...    alias=${alias}
    Airphone Setup X2 Connection    timeout=${timeout}
    ...    alias=${alias}

_wait_until_sib1_received_and_setup_x2_connection
    [Arguments]    ${alias}=default    ${timeout}=200
    [Documentation]    Author: He winnie
    ...                Contact: winnie.he@nokia-sbell.com
    ...    This keyword is used to wait sib1 message for all cells then setup x2 connection
    Log To Console    ...wait sib1 message for all cells then setup x2 connection...
    ${start_time}=    Get Time    epoch
    tak_ap.Airphone Get Enb Id    alias=${alias}
    _wait_until_sib1_received_for_all_cells    alias=${alias}    timeout=${timeout}
    ${end_time}=    Get Time    epoch
    ${used_time}=    Evaluate    ${end_time}-${start_time}
    ${timeout_1}=    Evaluate    ${timeout}-${used_time}
    Airphone Setup X2 Connection    timeout=${timeout_1}
    ...    alias=${alias}

Get Active Gnb ID
    [Arguments]    ${alias}=default
    ${gnb_id}    tak_ap.airphone_get_gnb_id    alias=${alias}
    Should Be True    '${gnb_id}'!='${None}'
    [Return]    ${gnb_id}

_remove the igonre cell id
    [Arguments]    ${all_cell_id_list}
    [Documentation]    Author: He winnie
    ...     it will use the global variable list: Ignore_Cell_Id_For_Sib
    ${ignore_cells_val}    Get Variable Value    ${Ignore_Cell_Id_For_Sib}
    ...    ${None}
    Return From Keyword If    "${ignore_cells_val}"=="${None}"
    ...    ${all_cell_id_list}
    ${ignore_cells}    Split String    ${ignore_cells_val}
    ${checked_cells}    Create List
    FOR    ${cell_id}    IN    @{all_cell_id_list}
        ${exist}    Count Values In List    ${ignore_cells}    ${cell_id}
        Run Keyword If    ${exist}==0
        ...    Append To List    ${checked_cells}    ${cell_id}
    END
    [Return]    ${checked_cells}

_wait_until_sib1_received_for_all_cells
    [Arguments]    ${alias}=default    ${timeout}=200
    [Documentation]    Author: He winnie
    ...                Contact: winnie.he@nokia-sbell.com
    ...    This keyword is used to wait sib1 message for all cells
    Log To Console    ...wait sib1 message for all cells...
    ${start_time_1}=    Get Time    epoch
    Wait Until Keyword Succeeds     ${timeout}     15     _sim_state_is_active
    ...    ${alias}
    ${end_time_1}=    Get Time    epoch
    ${used_time_1}=    Evaluate    ${end_time_1}-${start_time_1}
    ${timeout_1}=    Evaluate    ${timeout}-${used_time_1}
    ${gnb_id}    Wait Until Keyword Succeeds     60    15
    ...    Get Active Gnb ID    alias=${alias}
    ${gnb_id}    Run Keyword If    '${gnb_id}'=='${None}'    Run Keywords
    ...    Sleep    60s    AND    tak_ap.airphone_get_gnb_id    alias=${alias}
    ${cell_id_list}=    tak_ap.Airphone Get Cell Id List    alias=${alias}
    ${used_time_2}=    Set Variable    0
    ${cell_id_list}    _remove the igonre cell id    ${cell_id_list}
    FOR    ${cell_id}    IN    @{cell_id_list}
        ${timeout_2}=    Evaluate    ${timeout_1}-${used_time_2}
        ${start_time_2}=    Get Time    epoch
        Run Keyword If    ${need_sib_check}
        ...    tak_ap.airphone_wait_until_sib1_received     cell_id=${cell_id}   timeout=${timeout_2}
        ${end_time_2}=    Get Time    epoch
        ${used_time_2}=    Evaluate    ${end_time_2}-${start_time_2}
    END

Modify vLanid by SCF
    [Arguments]    ${index}=0
    ...            ${new_value}=${tl.gnbs[${index}].cu.x2c.vlan_id}
    ...            ${dist_name}=MRBTS-1/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-1
    ...            ${parameter}=vlanId
    ...            ${scf_file}=${None}
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                This KW is used to Modify vLanid by SCF.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${scf_file} | Yes | The scf file full path and name. E.g. testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/HAZ3/TL_Airphone/config/scf.xml |
    ...    | ${new_value} | No | set expected value |
    ...    | ${dist_name} | No |  set the distname of parameter that you want to modify |
    ...    | ${parameter} | No |  set the parameter name that you want to modify |
    ...    | ${index} | No | The index is set which gnb you want to use |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    |  Modify vLanid by SCF | ${index} | scf_file=${scf_file} |
    ...
    scf.load_scf  file_path=${scf_file}
    ${before_value}=  scf.Get_Value_From_Scf   dist_name=${dist_name}   p_name=${parameter}
    Run Keyword If    '${before_value}' != '${new_value}'    scf.modify_scf_element  value=${new_value}
    ...                                                                              dist_name=${dist_name}
    ...                                                                              p_name=${parameter}
    ${after_value}=  scf.Get_Value_From_Scf   dist_name=${dist_name}   p_name=${parameter}
    scf.save_scf  file_path=${scf_file}

Airphone Common Setup
    [Arguments]    ${local_wts_dir}=${None}
    ...    ${iphy_path}=${None}
    ...    ${scf_file_path}=${None}
    ...    ${gnb_swconfig_local_path}=${None}
    ...    ${ap_swconfig_local_path}=${None}
    ...    ${call_type}=sa
    ...    ${alias}=First_ASIB
    ...    ${gnb_index}=0
    ...    ${du_index}=0
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                This keyword is used for Airphone common setup.
    Log    ${gnb_index} is not used
    ${timestamp}=    DateTime.Get Current Date    result_format=%Y%m%d%H%M%S
    ${tc_name}=    Replace String    ${TEST_NAME}    ${SPACE}    _
    ${case_log_path}    Join path    ${SUITE_LOG_DIRECTORY}    ${tc_name}_${timestamp}
    Set Suite Variable    ${TEST_LOG_DIRECTORY}    ${case_log_path}
    Create directory    ${TEST_LOG_DIRECTORY}
    Airphone Edaemon Egate Setup
    Setup Ap Env    local_wts_dir=${local_wts_dir}
    ...    iphy_path=${iphy_path}
    ...    scf_file_path=${scf_file_path}
    ...    gnb_swconfig_local_path=${gnb_swconfig_local_path}
    ...    ap_swconfig_local_path=${ap_swconfig_local_path}
    ...    call_type=${call_type}
    ...    alias=${alias}
    ...    du_index=${du_index}

Airphone Common Teardown
    [Documentation]    Author: He winnie
    ...                Contact: winnie.he@nokia-sbell.com
    [Arguments]    ${alias}=default
    tak_ap.airphone_collect_edaemon_log_files    alias=${alias}
    tak_ap.airphone_collect_egate_log_files     alias=${alias}
    Airphone Edaemon Egate Teardown     alias=${alias}

Airphone Edaemon Egate Teardown
    [Documentation]    Author: He winnie
    ...                Contact: winnie.he@nokia-sbell.com
    [Arguments]    ${alias}=default
    Run Keyword And Ignore Error    tak_ap.airphone_teardown    alias=${alias}
    Run Keyword And Ignore Error    ute_wtssim.teardown_egate    alias=${alias}
    OperatingSystem.Run    sudo pkill edaemon
    OperatingSystem.Run    sudo pkill egate
    OperatingSystem.Run    sudo pkill 22222
    OperatingSystem.Run    sudo pkill 20000

Airphone Attach
    [Documentation]    Author: He winnie
    ...                Contact: winnie.he@nokia-sbell.com
    ...                call_type can be LTE or NSA or SA
    [Arguments]    ${ue_id}=1    ${call_type}=SA
    ...    ${gnb_id}=${None}    ${cell_id}=${None}    ${bearer_id}=${None}
    ...    ${pdu_id}=1    ${profile_id}=1
    ${call_type}    Convert To Upper Case    ${call_type}
    Run keyword If    '${call_type}'=='NSA'   Should be True
    ...     '${gnb_id}'!='${None}' and '${cell_id}'!='${None}' and '${bearer_id}'!='${None}'
    Log To Console    start ${call_type} attach...
    ${output}     Run keyword If    '${call_type}'=='LTE'
    ...    Run Keyword    _airphone.${call_type} Attach
    ...    ue_id=${ue_id}    profile_id=${profile_id}
    ...    ELSE IF    '${call_type}'=='NSA'
    ...    Run Keyword    _airphone.${call_type} Attach
    ...    ue_id=${ue_id}    gnb_id=${gnb_id}
    ...    cell_id=${cell_id}    bearer_id=${bearer_id}
    ...    profile_id=${profile_id}
    ...    ELSE IF    '${call_type}'=='SA'
    ...    Run Keywords    _airphone.${call_type} Attach    ue_id=${ue_id}
    ...    AND
    ...    airphone SA 5G PDU Session Setup    ue_id=${ue_id}    pdu_id=${pdu_id}
    Log To Console    ${output}
    Log To Console    ${call_type}_attach_is_ok
    Sleep    3s    reason=wait ${call_type} attach is stable

_airphone.LTE Attach
    [Documentation]    Author: He winnie
    ...                Contact: winnie.he@nokia-sbell.com
    [Arguments]    ${ue_id}    ${profile_id}=1
    Log    ${profile_id} is not used
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=ue_attach id\=${ue_id}    pass_regexp=UE IS ACTIVE    timeout=60
    [Return]    ${output}

_airphone.5G Attach
    [Documentation]    Author: He winnie
    ...                Contact: winnie.he@nokia-sbell.com
    [Arguments]    ${ue_id}    ${gnb_id}    ${cell_id}    ${bearer_id}
    ${output}=    ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=ue_dc_enb_start ue\=${ue_id} target_gnb\=${gnb_id} target_cells\=${cell_id} bearer\=${bearer_id} type\=split_scg
    ...    pass_regexp=reported successful RA|Proxy reported failure    timeout=60
    ${ret}=    Run Keyword And Return Status    Should Contain    ${output}    reported successful RA
    Run Keyword If    "${ret}"=="${False}"    Fail    NSA 5G Attach fails!!!
    [Return]    ${output}

_airphone.NSA Attach
    [Documentation]    Author: He winnie
    ...                Contact: winnie.he@nokia-sbell.com
    [Arguments]    ${ue_id}    ${gnb_id}    ${cell_id}    ${bearer_id}    ${profile_id}=1
    _airphone.LTE Attach    ue_id=${ue_id}    profile_id=${profile_id}
    _airphone.5G Attach    ue_id=${ue_id}    gnb_id=${gnb_id}    cell_id=${cell_id}
    ...    bearer_id=${bearer_id}

_airphone.SA Attach
    [Documentation]    Author: He winnie
    ...                Contact: winnie.he@nokia-sbell.com
    [Arguments]    ${ue_id}
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=ue_register id=${ue_id}    pass_regexp=Received REGISTRATION COMPLETE from UE with RAN UE NGAP ID    timeout=60s
    ${ret}=    Run Keyword And Return Status    Should Contain    ${output}    REGISTRATION COMPLETE
    Run Keyword If    "${ret}"=="${False}"    Fail    SA 5G Attach fails!!!
    ${output1}    String.Get Lines Matching Regexp    ${output}    REGISTRATION COMPLETE    partial_match=${true}
    Should Match Regexp    ${output}    Initial UE Message .*Success
    [Return]    ${output}

Airphone SA 5G PDU Session Setup
    [Documentation]    Author: Yang mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    [Arguments]    ${ue_id}=${1}    ${pdu_id}=${1}    ${trf_type}=internal    ${pass_regexp}=setup/reestablishment complete
    ute_wtssim.Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=${trf_type}
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=ue_pdu_session_setup pdu=${pdu_id} ue=${ue_id} nwslice\=1 gw\=${ue_id}
    ...    pass_regexp=${pass_regexp}
    ...    timeout=3minutes
    ${output}    String.Get Lines Matching Regexp    ${output}
    ...    Initial Context Setup Successful    partial_match=${true}
    Log To Console    ${output}
    [Return]    ${output}


Airphone Detach
    [Documentation]    Author: He winnie
    ...                Contact: winnie.he@nokia-sbell.com
    ...                This keyword is used to detach ue.
    [Arguments]    ${ue_id}    ${call_type}
    Run Keyword If    '${call_type}'=='NSA'
    ...    ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=ue_detach id\=${ue_id}    pass_regexp=detached
    ...    timeout=3minutes
    ...    ELSE
    ...    ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=ue_deregister id\=${ue_id} ue_deregister_type\=switch_off
    ...    pass_regexp=UE Context Release Complete
    ...    timeout=3minutes

Airphone Start Traffic1
    [Arguments]    ${ue_id}=1    ${bearer_id}=2    ${dir}=dl    ${pdu_id}=1    ${time_len}=5s
    ...            ${trf_id}=1    ${mbps}=5    ${qfi_id}=1    ${call_type}=SA    ${pass_regexp}=Internal traffic Receiver on Ue
    ${NSA_traffic_cmd}   Catenate    trf_data_start ue=${ue_id} id=${bearer_id} dir=${dir} mbps=${mbps} trf_id=${trf_id}
    ${SA_traffic_cmd}    Catenate    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=${dir} mbps=${mbps}
    ${traffic_cmd}   set variable if  '${call_type}'=='NSA'    ${NSA_traffic_cmd}    ${SA_traffic_cmd}
    ute_wtssim.Execute Egate Command And Wait For Data    cmd=${traffic_cmd}
    ...                                                   pass_regexp=${pass_regexp}
    Sleep    ${time_len}    reason=wait traffic is stable


Airphone Start Traffic
    [Documentation]    Author: He winnie
    ...                Contact: winnie.he@nokia-sbell.com
    [Arguments]    ${ue_id}=1    ${bearer_id}=2    ${dir}=dl
    ...     ${pdu_id}=1    ${time_len}=5s
    ...     ${trf_id}=1    ${mbps}=176m
    ...     ${qfi_id}=1    ${call_type}=SA
    ...     ${time}=999
    ${tputvalue_unit}    Run Keyword If    'm' in '${mbps}'    Set Variable    m
    ...    ELSE IF    'k' in '${mbps}'
    ...    Set Variable    k
    ...    ELSE    Set Variable    m
    ${tput_value}    Get Regexp Matches    ${mbps}    \\d+
    ${dir_lower}    Convert To Lower Case    ${dir}
    Run Keyword     _airphone.Start Traffic
    ...    ue_id=${ue_id}    bearer_id=${bearer_id}    tput_value=${tput_value}[0]
    ...    trf_id=${trf_id}
    ...    unit=${tputvalue_unit}
    ...    during=${time}
    ...    call_type=${call_type}
    ...    qfi_id=${qfi_id}
    ...    pdu_id=${pdu_id}
    ...    dir=${dir_lower}
    Sleep    ${time_len}    reason=wait ${dir_lower} traffic is stable

_airphone.get traffic cmd
    [Documentation]    Author: He winnie
    ...                Contact: winnie.he@nokia-sbell.com
    [Arguments]     ${ue_id}=1    ${bearer_id}=2    ${dir}=dl    ${pdu_id}=1
    ...    ${trf_id}=1    ${mbps}=5    ${qfi_id}=1    ${call_type}=SA
    ${NSA_traffic_cmd}   Catenate    trf_data_start ue=${ue_id} id=${bearer_id} dir=${dir} mbps=${mbps} trf_id=${trf_id}
    ${SA_traffic_cmd}    Catenate    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=${dir} mbps=${mbps} trf_id=${trf_id}
    ${traffic_cmd}   set variable if  '${call_type}'=='NSA'    ${NSA_traffic_cmd}    ${SA_traffic_cmd}
    [Return]    ${traffic_cmd}

_airphone.Start Traffic
    [Documentation]    Author: He winnie
    ...                Contact: winnie.he@nokia-sbell.com
    ...    this keyword is to start big dl udp traffic which more than 175.
    [Arguments]    ${ue_id}    ${bearer_id}    ${tput_value}    ${trf_id}=1    ${qfi_id}=1
    ...    ${unit}=m    ${during}=9999    ${call_type}=NSA    ${pdu_id}=1    ${dir}=dl
    ${times}    Run Keyword if    '${unit}'=='m'     Evaluate    int(${tput_value}/${175})
    ...    ELSE    Set Variable     ${0}
    FOR    ${t_time}    IN RANGE    1    ${times}+1
        ${tmp_trf_id}    Evaluate    int(${trf_id})+${t_time}-1
        ${cmd}     _airphone.get traffic cmd    ue_id=${ue_id}
        ...     bearer_id=${bearer_id}
        ...     dir=${dir}
        ...     pdu_id=${pdu_id}
        ...     trf_id=${tmp_trf_id}
        ...     mbps=175
        ...     qfi_id=${qfi_id}
        ...     call_type=${call_type}
        ute_wtssim.Execute Egate Command And Wait For Data
        ...    cmd=${cmd} seconds\=${during}
        ...    pass_regexp=Internal traffic Receiver on Ue
        ...    timeout=60
        Log To Console    \nUE${ue_id} Start DL 175M Traffic for trf_id=${tmp_trf_id}
    END
    ${last_tput_value}    Evaluate    ${tput_value}%${175}
    ${last_trf_id}    Evaluate    ${trf_id}+${times}
    ${cmd}     _airphone.get traffic cmd    ue_id=${ue_id}
        ...     bearer_id=${bearer_id}
        ...     dir=${dir}
        ...     pdu_id=${pdu_id}
        ...     trf_id=${last_trf_id}
        ...     mbps=${last_tput_value}
        ...     qfi_id=${qfi_id}
        ...     call_type=${call_type}
    Run Keyword If    '${last_tput_value}'!='0'    ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=${cmd} seconds\=${during}
    ...    pass_regexp=Internal traffic Receiver on Ue
    ...    timeout=60
    Run Keyword If    '${last_tput_value}'!='0'    Log To Console
    ...    \nUE${ue_id} Start ${dir} ${last_tput_value}${unit} Traffic for trf_id=${last_trf_id}

Airphone Stop Traffic
    [Arguments]    ${ue_id}=1    ${pdu_id}=all   ${dir}=bi    ${trf_id}=1
    [Documentation]    Author: He winnie
    ...                Contact: winnie.he@nokia-sbell.com
    ...    This keyword is to stop traffic on eGate.
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    | bearer_id | Yes | bearer_id |
    ...    | dir | Yes | ul or dl, default is bi |
    ...    | trf_id | No | trf_id, default is 1 |
    ...    Example:
    ...    | NSA Stop Traffic | 1 | 2 | dl |
    Log To Console    stop ${dir} traffic...\n
    Run Keyword If    '${dir}'=='bi'    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_stop ue\=${ue_id} pdu\=${pdu_id} dir\=${dir}
    ...    ELSE    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_stop ue\=${ue_id} pdu\=${pdu_id} dir\=${dir} trf_id\=${trf_id}

Airphone Get Average Throughput
    [Arguments]    ${ue_id}=1    ${bearer_id}=2    ${qfi}=1    ${dir}=dl
    ...            ${trf_id}=2    ${type}=l3    ${call_type}=SA    ${pdu_id}=1
    [Documentation]    This keyword is to get the average tput from egate
    ...    | Input Parameters | Man. | Description |
    ...    | ${ue_id} | Yes | ue id |
    ...    | ${bearer_id} | Yes | bearer id for the UE |
    ...    | ${dir} | Yes | dl/ul |
    ...
    ...    Examples:
    ...    | NSA Get Avg Tput | 1 | 2 | dl |
    ...
    ${NSA_cmd}    Catenate    bearer_stats ue\=${ue_id} id\=${bearer_id} dir\=${dir} trf_id\=${trf_id} type\=${type}
    ${SA_cmd}    Catenate    bearer_stats ue\=${ue_id} pdu\=${pdu_id} qfi\=${qfi} dir\=${dir} dc_cell_group=all
    ${cmd}   set variable if  '${call_type}'=='NSA'    ${NSA_cmd}    ${SA_cmd}
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    cmd=${cmd}
    ...                                                                pass_regexp=Average packet interval
#    ${arg_tput_list}    String.Get Regexp Matches    ${output}    Average data rate\\s+\\d+\\s+\\((?P<tput>\\d+\\.\\d+)\\s+M\\)    tput
    ${match}   ${dataRate}=   Should Match Regexp   ${output}   Average data rate +(\\d+) .+\\r
    [Return]    ${dataRate}


Airphone Get Detail Throughput For Per Scell
    [Arguments]    ${ue_id}=1    ${scell_index}=0    ${unit}=M
    [Documentation]    This keyword is to get the average tput from egate
    ...    | Input Parameters | Man. | Description |
    ...    | ${ue_id} | Yes | ue id |
    ...    | ${scell_index} | Yes | scell_index |
    ...    return   Minimum_tput    Maximum_tput    Average_tput
    ...    Examples:
    ...    ========================================================================
    ...    CellIndex    Current        Minimum        Maximum        Average
    ...    -------------------------------------------------------------------------
    ...    CellIndex-0  0 Kbps         0 Mbps         0 Mbps         0 Mbps
    ...    -------------------------------------------------------------------------
    ...    | Airphone Get Detail Throughput For Per Scell | 1 | 0 |
    ...
    Log    ${unit} is not used
    ${cmd}    Catenate    ue_stats_nr id\=${ue_id} type=pdsch scell=${scell_index}
    ${output}    ute_wtssim.execute_egate_command_and_wait_for_data    cmd=${cmd}
    ...         pass_regexp=EGATE>
    ${pattern}    Catenate    CellIndex-${scell_index}\\s+(?P<value1>\\d+(\\.\\d+)?)
    ...    Mbps\\s+(?P<value2>\\d+(\\.\\d+)?) Mbps\\s+(?P<value3>\\d+(\\.\\d+)?) Mbps\\s+(?P<value4>\\d+(\\.\\d+)?) Mbps
    ${match}    String.Get Regexp Matches    ${output}    ${pattern}
    ${tput}    String.Get Regexp Matches    ${match}[0]    (?P<value>\\d+(\\.\\d+)?) Mbps    value
    [Return]    ${tput}[1]    ${tput}[2]    ${tput}[3]

Airphone 5G PDU Session Modify
    [Arguments]    ${ue_id}    ${pdu_id}=1    ${pass_regexp}=Added QosFlow with QFI
    [Documentation]        Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                This keyword is used to simulate PDU session modify on 5GNR side.
    ...    Expected output is: " Initial Context Setup Successful " on eGate.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    Example:
    ...    | Airphone 5G PDU Session Modify | 1 |
    Log To Console    start 5G PDU Session Modify...
    ${command}    Set Variable    ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=2 by=amf
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...          cmd=${command}    pass_regexp=${pass_regexp}    timeout=3minutes
    ${output}    String.Get Lines Matching Regexp    ${output}    Initial Context Setup Successful    partial_match=${true}
    Log To Console    ${output}

Airphone Send Measurement NR
    [Arguments]    ${ue_id}=1    ${meas_id}=1    ${phycell_id}=381    ${event}=A3    ${srsrp_nr}=11   ${nrsrp_nr}=30
    ...            ${cmd_regexp}=Inter-eNB handover from EXT_ENB-2.1 to ENB-3.1
    ...            ${confirm_regexp}=3.1
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...    This keyword is used to Send Measurement NR.
    ...    | Input Parameters | Man. | Description |
    ...    | ${cmd_regexp} | Yes | verify if the output is correct |
    ...
    ...    Examples:
    ...    | Airphone Send Measurement NR | cmd_regexp=Inter-eNB handover from EXT_ENB-2.1 to ENB-3.1 |
    ...
    Log     ${confirm_regexp} is not used
    Log To Console    start Send Measurement NR...
    ${nr_cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event} srsrp_nr=${srsrp_nr} phycell_id=${phycell_id}
    ...                      nrsrp_nr=${nrsrp_nr}
    ${ret1}=    ute_wtssim.Execute Egate Command And Wait For Data    cmd=${nr_cmd}    pass_regexp=${cmd_regexp}

Airphone Get Measurement ID
    ${meas_cfg}    ute_wtssim.Execute Egate Command And Wait For Data    ue_meas_cfg_disp id=${ue_id} meas_obj_type=nr
    Log To Console    ${meas_cfg}
    [Return]    ${meas_cfg}

Airphone Gnb Xn Handover Preparation
    [Arguments]    ${ue_id}=1    ${action}=delayed_rsp    ${wait_time}=v5s
    [Documentation]        Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                This keyword is used to Airphone Gnb Xn Handover Preparation.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    Example:
    ...    | Airphone Gnb Xn Handover Preparation | 1 |
    ${ho_cmd}    Catenate    gnb_xn_handover_preparation_param id=${ue_id} action=${action} time_to_wait=${wait_time}
    ute_wtssim.Execute Egate Command     ${ho_cmd}

Airphone NR RRC Reconf
    [Arguments]    ${ue_id}=1    ${if_contains}=report_cgi    ${action}=send_nas_pdu_session_modify
    ...            ${other_parameters}=anr_cgi_delay=100ms qosflows_to_add=2
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...    This keyword is used to copy cfg and xml files from local path.
    ...    | Input Parameters | Man. | Description |
    ...    | ${local_wts_dir} | Yes | where cfg and xml files can be found |
    ...
    ...    Examples:
    ...    | Airphone NR RRC Reconf | other_parameters=anr_cgi_delay=100ms qosflows_to_add=2 |
    ...
    ${rlf_cmd}    Catenate
    ...    ue_nr_rrc_reconf_param id=${ue_id} if_contains=${if_contains} action=${action}    ${other_parameters}
    ute_wtssim.Execute Egate Command And Wait For Data    ${rlf_cmd}

Airphone Execute Egate Command
    [Arguments]    ${cmd}    ${timeout}=60
    ...    ${pass_regexp}=${None}
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...    This keyword is used to Execute Egate Command.
    ...    | Input Parameters | Man. | Description |
    ...    | ${cmd} | Yes | where cfg and xml files can be found |
    ...
    ...    Examples:
    ...    | *** Variables *** |
    ...    | Airphone Execute Egate Command | local_dir=${LOCAL_WTS_DIR} |
    ...
    tak_ap.airphone_execute_egate_command   ${cmd}    timeout=${timeout}
    ...    pass_regexp=${pass_regexp}

Airphone Replace Swconfig
    [Arguments]    ${local_path}=/home/ute/swconfig/swconfig.txt    ${remote_path}=/ffs/run/swconfig.txt    ${alias}=asib
    ...            ${gnb_hostname}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.addr}
    ...            ${gnb_username}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...            ${gnb_password}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                The kw is used to replace and crasign the swconfig file to control board /ffs/run.
    ...                But will NOT reboot the BTS, if you need to take this affect, please reboot BTS after this KW.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${local_path} | Yes | The swconfig.txt file full path and file name. E.g. /home/ute/swconfig/swconfig.txt |
    ...    | ${remote_path} | No | The control board swconfig path, default is /ffs/run/swconfig.txt |
    ...    | ${alias} | No | The connection to the control board ASIB, default is asib |
    ...    | ${gnb_hostname} | No | Set gnb ip address, you can set the address of real gnb or airphone |
    ...    | ${gnb_username} | No | Set gnb username, default is toor4nsn |
    ...    | ${gnb_password} | No | Set gnb password, default is oZPS0POrRieRtu |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | ReplaceSwconfig | local_path=home/ute/swconfig/swconfig.txt |
    ...
    ${gnb_hostname}    Run Keyword If    "${gnb_hostname}"=="192.168.255.1"
    ...    Set Variable    192.168.255.129
    ...    ELSE
    ...    Set Variable    ${gnb_hostname}
    csn.Connect To    hostname=${gnb_hostname}    username=${gnb_username}    password=${gnb_password}    alias=${alias}
    ssh.upload_file    local_path=${local_path}    remote_path=${remote_path}    connection=${alias}
    ${cmd}=    Catenate    cd /ffs/run/ && crasign swconfig.txt
    ssh.execute    command=${cmd}    connection=${alias}
    Run Keyword If    '${alias}'=='asib'    ssh.disconnect    connection=${alias}

Send IPHY XML To Airphone
    [Arguments]    ${iphy_path}    ${ap_username}=toor4nsn    ${ap_ip}=192.168.200.129
    [Documentation]    This keyword is to send target iphy.xml to Airphone /ffs/run/simmode/
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${iphy_path} | Yes | iphy.xml located, eg:/home/ute/iphy.xml |
    ...
    ...    Examples:
    ...    | Send IPHY XML To Airphone | /home/ute/iphy.xml |
    ...
#    ${rc}    OperatingSystem.Run And Return Rc
#    ...    sshpass -p ${AP_ASIK.password} scp ${iphy_path} ${ap_username}@${AP_ASIK.ip}:/ffs/run/simmode/
    ${rc}    OperatingSystem.Run And Return Rc
    ...    scp ${iphy_path} ${ap_username}@${ap_ip}:/rom/simmode/
    Should Be Equal As Integers    ${rc}    0

Airphone Get Iphy Info
    Log To Console  \n===get airphone info ===
    Setup Wts Fsm Access  fallback_prompt=#
    ${wts_sw_version}  Get Wts Sw Version
    ${AP_SW_VERSION}    Set Variable If    "${wts_sw_version.split("_")[-2].lstrip("0")}" != "${EMPTY}"
    ...    ${wts_sw_version.split("_")[-3].lstrip("0")}.${wts_sw_version.split("_")[-2].lstrip("0")}.${wts_sw_version.split("_")[-1].lstrip("0")}
    ...    ${wts_sw_version.split("_")[-3].lstrip("0")}.0.${wts_sw_version.split("_")[-1].lstrip("0")}
    log  activeIphyVersion=${AP_SW_VERSION}    level=WARN
    Set Suite Variable  ${AP_SW_VERSION}
    ${AP_BBU_TYPE}  Get Ap Bbu Type
    Run Keyword And Ignore Error  Verify GNB AP and WTS Version
    log  ap_bbu_type=${AP_BBU_TYPE}  console=True
    Set Suite Variable  ${AP_BBU_TYPE}
    ${ap_bbmod_types}  Get Ap Fsp Types
    Set Suite Variable  ${AP_BBMOD_TYPE}  ${ap_bbmod_types[0]}
    log  ap_bbmod_type=${AP_BBMOD_TYPE}  console=True

Airphone Set Iphy Ip
    Log To Console  \n===configure IPs on PC ===
    OperatingSystem.Run  sudo ip addr add 10.0.2.1/24 dev eth4
    Log  10.0.1.121~155 is configured for your use  console=yes
    FOR  ${number}  IN RANGE  121  156
        OperatingSystem.Run  sudo ip addr add 10.0.1.${number}/24 dev eth3
    END
    Log  proxy server ip is 10.0.2.80  console=yes
    Log  10.0.2.90~100 is configured for more proxy servers  console=yes
    FOR  ${number}  IN RANGE  90  101
        OperatingSystem.Run  sudo ip addr add 10.0.2.${number}/24 dev eth4
    END
    Log  AMF ip is 10.0.1.1  console=yes
    Log  10.0.1.9~15 10.0.1.100~10.0.1.109 is configured for you to set more AMFs  console=yes
    FOR  ${number}  IN RANGE  9  16
        OperatingSystem.Run  sudo ip addr add 10.0.1.${number}/24 dev eth3
    END
    FOR  ${number}  IN RANGE  100  110
        OperatingSystem.Run  sudo ip addr add 10.0.1.${number}/24 dev eth3
    END
    OperatingSystem.Run  ip addr show eth3
    OperatingSystem.Run  ip addr show eth4

Airphone Qosflow Modify
    [Arguments]     ${qos_flow}    ${pass_regexp}=${None}    &{kwargs}
    ${cmd}    Catenate    qosflow_modify qos_flow=${qos_flow}
    ${params}    Get Dictionary Keys    ${kwargs}
    FOR    ${param}    IN    @{params}
        ${cmd}    Catenate    ${cmd} ${param}=${kwargs}[${param}]
    END
    Log to Console    ${cmd}
    Airphone Execute Egate Command
    ...    cmd=${cmd}
    ...    pass_regexp=${pass_regexp}
############### AP setup For Multi BTS####################
Get Load Path For Airphone
    [Documentation]    if bts0, not post tag, other bts , add posttag BTS1
    ...   if trunk, not post tag, branch will add posttag _release
    [Arguments]    ${prefix}=GLODEN    ${posttag}=BTS0   ${release}=${RELEASE}
    ...    ${base_path}=${SCF_DIR_PATH}
    ...    ${file_suffix}=xml
    ${file_path}    Run keyword If    '${posttag}'=='BTS0'
    ...    Join Path    ${base_path}    ${prefix}.${file_suffix}
    ...    ELSE    Join Path    ${base_path}
    ...    ${prefix}_${posttag}.${file_suffix}
    ${file_path}    Run Keyword If    '${release}'=='SBTS00'
    ...    Set Variable    ${file_path}
    ...    ELSE    Join Path    ${base_path}
    ...    ${prefix}_${posttag}_${release}.${file_suffix}
    ${is_exist}    Run Keyword And Return Status    File Should Exist    path=${file_path}
    ${file_path}    Run Keyword If    '${is_exist}'=='False'
    ...    Replace String    ${file_path}    _${release}    ${EMPTY}
    ...    ELSE    Set Variable    ${file_path}
    ${file_path}    Run Keyword If    '${is_exist}'=='False' and '${posttag}'=='BTS0'
    ...    Replace String    ${file_path}    _${posttag}    ${EMPTY}
    ...    ELSE    Set Variable    ${file_path}
    [Return]    ${file_path}

Get ALL Load Path For Airphone
    [Arguments]    ${airphone_config_tag}
    ...    ${base_path}
    ...    ${gnb_index}=${0}
    ...    ${du_index}=${0}
    ...    ${release}=${RELEASE}
    ${prefix_file_suffixs}    Create List    SCFC=xml    iphy=xml
    ...    wts=lua    wts=cfg
    ...    GNB_SWCONFIG=txt    AP_SWCONFIG=txt
    ...    SCFC_CU=xml
    ${config_list}    Create Dictionary    SCFC=${None}    iphy=${None}
    ...    wts=${None}    GNB_SWCONFIG=${None}    AP_SWCONFIG=${None}
    ...    SCFC_CU=${None}
    ${du_length}    Get Length    ${tl.gnbs[${gnb_index}].dus}
    FOR    ${du_index}    IN RANGE   ${du_length}
        Append To List    ${prefix_file_suffixs}    SCFC_DU${du_index}=xml
        Set To Dictionary    ${config_list}    SCFC_DU${du_index}=${None}
    END
    FOR    ${prefix_file_suffix}     IN    @{prefix_file_suffixs}
        ${prefix}    ${file_suffix}    Split String    ${prefix_file_suffix}    =
        ${file_path}    Get Load Path For Airphone    prefix=${prefix}_${airphone_config_tag}
        ...    posttag=BTS${gnb_index}    release=${release}
        ...    base_path=${base_path}
        ...    file_suffix=${file_suffix}
        ${config_exist}    Run Keyword And Return Status
        ...    OperatingSystem.File Should Exist    ${file_path}
        ${file_path}    Set Variable If    ${config_exist}
        ...    ${file_path}    ${None}
        # Run Keyword Unless    '${prefix_file_suffix}'=='wts=cfg' and '${config_list}[wts]'!='${None}'
        Run Keyword If    '${prefix_file_suffix}'!='wts=cfg' or '${config_list}[wts]'=='${None}'
        ...    Set To Dictionary    ${config_list}    ${prefix}=${file_path}
    END
    ${vdus_scfc}    Create List
    ${scfc_list}    Run Keyword If    "vDU" in '${TESTLINE_TYPE}' or "vCU" in '${TESTLINE_TYPE}'
    ...    Create Dictionary    vCU=${config_list}[SCFC_CU]    vDU=${vdus_scfc}
    ...    ELSE   Set Variable    ${config_list}[SCFC]
    FOR    ${du_index}    IN RANGE   ${du_length}
        Run Keyword If    "vDU" in '${TESTLINE_TYPE}' or "vCU" in '${TESTLINE_TYPE}'
        ...    Append To List    ${scfc_list}[vDU]    ${config_list}[SCFC_DU${du_index}]
    END
    Set To Dictionary    ${config_list}    SCFC=${scfc_list}
    [Return]    ${scfc_list}
    ...    ${config_list}[iphy]
    ...    ${config_list}[wts]
    ...    ${config_list}[GNB_SWCONFIG]
    ...    ${config_list}[AP_SWCONFIG]

Setup All Airphone Env
    [Arguments]    ${airphone_config_tag}=${None}
    ...    ${base_path}=${None}
    ...    ${call_type}=sa
    ...    ${gnb_index}=${0}
    ...    ${release}=${RELEASE}
    ${du_scf_empty_list}    Create List    ${None}
    ${emppty_vran_config}    Create Dictionary    vDU=${du_scf_empty_list}    vCU=${None}
    ${scfc_file_path}    ${iphy_file_path}    ${wts_config}    ${gnb_swconfig_local_path}
    ...    ${ap_swconfig_file_path}
    ...    Run Keyword If    '${base_path}'!='${None}'
    ...        Get ALL Load Path For Airphone   airphone_config_tag=${airphone_config_tag}
    ...        base_path=${base_path}
    ...        gnb_index=${gnb_index}
    ...        release=${release}
    ...    ELSE IF    "vDU_" in "${TESTLINE_TYPE}"
    ...        Set Variable
    ...        ${emppty_vran_config}
    ...        ${None}
    ...        /opt/iphy/latest/basic_setup.cfg
    ...        ${None}
    ...        ${None}
    ...    ELSE
    ...        Set Variable
    ...        ${None}
    ...        ${None}
    ...        /opt/iphy/latest/basic_setup.cfg
    ...        ${None}
    ...        ${None}
    Airphone Edaemon Egate Teardown
    Airphone Edaemon Egate Setup
    Setup Ap Env    local_wts_dir=${wts_config}
    ...    iphy_path=${iphy_file_path}
    ...    scf_file_path=${scfc_file_path}
    ...    gnb_swconfig_local_path=${gnb_swconfig_local_path}
    ...    ap_swconfig_local_path=${ap_swconfig_file_path}
    ...    call_type=${call_type}
    ...    alias=COAM_0
    ...    du_index=${0}

Check Iphy Alive
    ${ret}    OperatingSystem.Run    ping -c 4 192.168.200.129
    Should Not Contain    ${ret}    Unreachable

Check Iphy Offline
    ${ret}    OperatingSystem.Run    ping -c 4 192.168.200.129
    Should Contain    ${ret}    Unreachable

Reboot Iphy
    [Arguments]    ${timeout}=10 min
    OperatingSystem.Run    sshiphy
    OperatingSystem.Run    reboot
    ${ret}    OperatingSystem.Run    Ping 192.168.200.129
    Wait Until Keyword Succeeds     5 min     15
    ...    Check Iphy Offline
    Wait Until Keyword Succeeds     ${timeout}     15
    ...    Check Iphy Alive
    Log To Console    Iphy Reboot successful

Get PhysCellId With UE Id From Egate Log
    [Arguments]    ${ue_id}    ${scellindex}=${0}    ${log_path}=${TEST_LOG_DIRECTORY}
    [Documentation]    This keyword is to get physCellId from egate conscole Log according to sCellIndex.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${ue_id} | Yes | ue_id, such as 1,2,3... |
    ...    | ${scellindex} | Yes | the index for scell, such as 1,2,3... |
    ...    | ${egate_Log} | Yes | the egate console Log path |
    ...
    ...    Example:
    ...    | ${egate_Log} | Set Variable | ${CURDIR}/egate_console2.Log |
    ...    | ${physcellid_list} | Get physCellId with UE Id From Egate Log | 88 | 1 | ${egate_Log} |
    ...
    ${egate_Log}    Set Variable    ${log_path}/Airphone_Operation/egate_console.log
    ${content}    OperatingSystem.Get File    ${egate_Log}
    ${patt}    Set Variable    UeId:${ue_id},BwpId:\\d+, pcid:(?P<pcid>\\d+), scellIdx:${scellindex}
    ${physcellid}    String.Get Regexp Matches    ${content}    ${patt}    pcid
    Log To Console    Get PhysCellId is ${physcellid[-1]} for UE${ue_id}
    [Return]    ${physcellid[-1]}

Get ScellIdx With UE Id From Egate Log
    [Arguments]    ${ue_id}    ${psy_cellid}    ${log_path}=${TEST_LOG_DIRECTORY}
    [Documentation]    This keyword is to get physCellId from egate conscole Log according to sCellIndex.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${ue_id} | Yes | ue_id, such as 1,2,3... |
    ...    | ${scellindex} | Yes | the index for scell, such as 1,2,3... |
    ...    | ${egate_Log} | Yes | the egate console Log path |
    ...
    ...    Example:
    ...    | ${egate_Log} | Set Variable | ${CURDIR}/egate_console2.Log |
    ...    | ${physcellid_list} | Get physCellId with UE Id From Egate Log | 88 | 1 | ${egate_Log} |
    ...
    ${egate_Log}    Set Variable    ${log_path}/Airphone_Operation/egate_console.log
    ${content}    OperatingSystem.Get File    ${egate_Log}
    ${patt}    Set Variable    UeId:${ue_id},BwpId:\\d+, pcid:${psy_cellid}, scellIdx:(?P<scellIdx>\\d+)
    ${scellIdx}    String.Get Regexp Matches    ${content}    ${patt}    scellIdx
    Log To Console    Get PhysCellId is ${scellIdx[-1]} for UE${ue_id}
    [Return]    ${scellIdx[-1]}

Get AP Build Name From UTE Cloud
    [Documentation]    This kw is used to get ap build name
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
     ...    | Input Parameters | Man. | Description |
    ...    | NA | no | None|
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Get TestLine Name |
    ...
    ${key_list}    Create List    CM_ARTIFACTS    4    name
    ${ap_build_Name}    Get Info From UTE Reservation File    key_list=${key_list}
    Set Variable    ${ap_build_Name}
    Log to Console    \n***AP build Name ${ap_build_Name}***
    ${ap_build_Name_list}    Split String    ${ap_build_Name}    _
    Set Suite Variable    ${AP_BUILD_NAME}    ${ap_build_Name_list[-1]}
    [Return]    ${AP_BUILD_NAME}
