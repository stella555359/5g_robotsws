*** Settings ***
Documentation
...    Author: Yang mengli
...    Email address: mengli.yang@nokia-sbell.com
...    Maintainer: Yang mengli
...    Email address: mengli.yang@nokia-sbell.com
...    Common KWs related to Airphone.
...    All the bugs/new keyword needs/improvement should be raised in Jira and assign to the Maintainer.
...    Jira link: https://jiradc.ext.net.nokia.com/projects/PZ1HAZTA/issues
...    Guidelines for user: https://confluence.ext.net.nokia.com/display/SRANPRODHZHTA/10.+Module+of+Airphone+Operation
...    Examples: https://wrgitlab.int.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Hangzhou/resources/RAN_PZ_HAZ_1/Module/Module_Test


Library             DateTime
Library             OperatingSystem
Library             ute_wtssim
Library             ute_fsmaccess
Library             ./module_utils/module_utils.py
Library             ./airphone_worker/iphy_modify.py    WITH NAME    iphy_modify
Library             ./airphone_worker/vran_operate.py
Library             ./airphone_worker/tak_airphone/                  WITH NAME    tak_ap
Library             ./airphone_worker/tak_xml_module/                  WITH NAME    tak_xml_module
Library             ./airphone_worker/sw_update_local.py/                  WITH NAME    local_ap_update
Library             taf.gnb.oam.coam.cu     WITH NAME    coam_cu
Library             taf.gnb.oam.coam.vdu    WITH NAME    coam_vdu
Library             taf.sbts.oam.coam.admin               WITH NAME    coam
Library             taf.config.scf                        WITH NAME    scf
Library             Collections
Library             taf.transport.ssh                     WITH NAME    ssh

*** Variables ***
${SAVE_EGATE_AFTER_DOWN}    ${TRUE}
${UTE_RESERVATION_CONTEXT_JSON}    /opt/ute/reservation.context.json
&{AP_ASIK}           ip=192.168.200.1    username=toor4nsn    password=oZPS0POrRieRtu    connection=APAsik


*** Keywords ***
Module Setup Ap Env
    [Arguments]    ${operation}    ${product_type}    ${tag}=${None}    ${customer}=RJIO
    ${dire}    setup_module_directory    module_name=Airphone_Operation
    Set Test Variable    ${AP_LOG_DIRECTORY}    ${dire}
    Module Get TestLine Name From UTE Cloud
    Run Keyword If    "${product_type}"=="vdu" or "${product_type}"=="vdu_other" or "${product_type}"=="vcu"
    ...                                                           Module Get TL Config    ${TESTLINE_NAME}
    Log to Console    \n******config ip******\n
    _Module Config Iphy Ip
    Log to Console    \n******backup config******\n
    Run Keyword If    "${product_type}"=="gnb"    Run Keywords    Module Backup Scf For Classical    AND
    ...                                                           Module Backup Gnb Swconfig File    AND
    ...                                                           Module Backup AP Swconfig File    AND
    ...                                                           Module Backup Iphy Xml File    AND
    ...                                                           Module Backup WTS Config File
    ...    ELSE IF    "${product_type}"=="vdu" or "${product_type}"=="vdu_other" or "${product_type}"=="vcu"    Run Keywords
        ...                                                      Module vDU Backup SCF From Test Line    AND
        ...                                                      Module vCU Backup SCF From Test Line    AND
        ...                                                      Module Backup AP Swconfig File    AND
        ...                                                      Module Backup Iphy Xml File    AND
        ...                                                      Module Backup WTS Config File
    Log to Console    \n******config env******\n
    @{operation_list}    Split String    ${operation}    _
    ${operational_type}=    Convert To Lowercase     ${operation_list[-1]}
    Run Keyword If    "${tag}"=="None"    Module Airphone Config Default Cfg    tag=${tag}    customer=${customer}
    ...                                                                         call_type=${operational_type}
    ...    ELSE IF    "${tag}"!="None"    Module Config Iphy Swconfig And Scf    tag=${tag}
           ...                                                          customer=${customer}
           ...                                                                   product_type=${product_type}
           ...                                                                   operational_type=${operational_type}
    Log to Console    \n******check onair******\n
    Run Keyword If    "${product_type}"=="gnb"        Airphone Verify BTS Status For Classic
    ...    ELSE IF    "${product_type}"=="vdu" or "${product_type}"=="vdu_other" or "${product_type}"=="vcu"
    ...                                             Module vDU Check All Cells Status Should Be Onair


Module Config Iphy Swconfig And Scf
    [Arguments]    ${tag}    ${product_type}    ${operational_type}    ${customer}
    ${all_config_file_dic}    _Get All Config File path    tag=${tag}
    Set Variable    ${all_config_file_dic}
    Log to Console    \n******config iphy******\n
    ${iphy_file_path_exist}    Run Keyword And Return Status    OperatingSystem.File Should Exist    ${all_config_file_dic['iphy']}
    Run Keyword If    "${product_type}"=="gnb"    _Module Config Iphy For Classic    iphy_file_path_exist=${iphy_file_path_exist}
    ...                                                                              iphy_path=${all_config_file_dic['iphy']}
    ...    ELSE IF    "${product_type}"=="vdu" or "${product_type}"=="vdu_other" or "${product_type}"=="vcu"    _Module Config Iphy For Cloud
    ...                                                                            iphy_file_path_exist=${iphy_file_path_exist}
    ...                                                                            iphy_path=${all_config_file_dic['iphy']}
    ...                                                                            product_type=${product_type}
    Log to Console    \n******config airphone swconfig******\n
    ${Swconfig_AP_file_path_exist}    Run Keyword And Return Status    OperatingSystem.File Should Exist    ${all_config_file_dic['Swconfig_AP']}
    Run Keyword If    ${Swconfig_AP_file_path_exist}    AP Replace Swconfig    local_path=${all_config_file_dic['Swconfig_AP']}
    ...            remote_path=/ffs/run/swconfig.txt
    ...            gnb_hostname=192.168.200.129
    ...            product_type=${product_type}
    Log to Console    \n******config scf******\n
    Run Keyword If    "${product_type}"=="gnb"    Load SCF and Swconfig For Classic    all_config_file_dic=${all_config_file_dic}
    ...    ELSE IF    "${product_type}"=="vdu" or "${product_type}"=="vdu_other" or "${product_type}"=="vcu"    Load SCF For Cloud
    ...                                                                               all_config_file_dic=${all_config_file_dic}
    ...                                                                               product_type=${product_type}
    Log to Console    \n******config wts******\n
    Module Airphone Config Cfg    call_type=${operational_type}    tag=${tag}    customer=${customer}

_Get All Config File path
    [Arguments]    ${tag}    ${gnb_index}=${0}
    ${current_dir}    ${robotcase_name}    Split Path    ${suite_source}
    ${file_path}    Join Path    ${current_dir}    APCFG
    ${scf_file_list}    Create List
    ${swconfig_file_list}    Create List
    ${du_scf_file_list}    Create List
    ${vcu_file_list}    Create List
    ${all_config_file_dic}    Create Dictionary
    ${gnb_length}    Get Length    ${tl.gnbs}
    ${du_length}    Get Length    ${tl.gnbs[${gnb_index}].dus}
    FOR    ${gnb_index}    IN RANGE   ${gnb_length}
        ${scf_file_path}    Join Path    ${file_path}    SCFC_Gnb${gnb_index}_${tag}.xml
        ${swconfig_file_path}    Join Path    ${file_path}    Swconfig_Gnb${gnb_index}_${tag}.txt
        ${vcu_file_path}    Join Path    ${file_path}    SCFC_vCU${gnb_index}_${tag}.xml
        Append To List    ${scf_file_list}    ${scf_file_path}
        Append To List    ${swconfig_file_list}    ${swconfig_file_path}
        Append To List    ${vcu_file_list}    ${vcu_file_path}
    END
    FOR    ${du_index}    IN RANGE   ${du_length}
        ${du_scf_file_path}    Join Path    ${file_path}    SCFC_vDU${du_index}_${tag}.xml
        Append To List    ${du_scf_file_list}    ${du_scf_file_path}
    END
    ${apswconfig_file_path}    Join Path    ${file_path}    Swconfig_AP_${tag}.txt
    ${wts_cfg_file_path}    Join Path    ${file_path}    wts_${tag}.cfg
    ${wts_lua_file_path}    Join Path    ${file_path}    wts_${tag}.lua
    ${iphy_file_path}    Join Path    ${file_path}    iphy_${tag}.xml
    Set To Dictionary    ${all_config_file_dic}    SCFC_Gnb=${scf_file_list}
    ...                                            Swconfig_Gnb=${swconfig_file_list}
    ...                                            SCFC_vCU=${vcu_file_list}
    ...                                            SCFC_vDU=${du_scf_file_list}
    ...                                            Swconfig_AP=${apswconfig_file_path}
    ...                                            wts_cfg=${wts_cfg_file_path}
    ...                                            wts_lua=${wts_lua_file_path}
    ...                                            iphy=${iphy_file_path}
    [Return]    ${all_config_file_dic}

################################ classic part #################################
_Module Config Iphy For Classic
    [Arguments]    ${iphy_file_path_exist}    ${iphy_path}
    Run Keyword If    ${iphy_file_path_exist}    iphy_modify.change_iphy_ru_version    ${iphy_path}

Load SCF and Swconfig For Classic
    [Arguments]    ${all_config_file_dic}
    ${SCFC_Gnb_length}    Get Length    ${all_config_file_dic['SCFC_Gnb']}
    FOR    ${gnb_index}    IN RANGE   ${SCFC_Gnb_length}
           ${swconfig_file_path_exist}    Run Keyword And Return Status    OperatingSystem.File Should Exist
           ...                                                                            ${all_config_file_dic['Swconfig_Gnb'][${gnb_index}]}
           Run Keyword If    ${swconfig_file_path_exist}    AP Replace Swconfig
           ...                                local_path=${all_config_file_dic['Swconfig_Gnb'][${gnb_index}]}
           ...                                remote_path=/ffs/run/swconfig.txt
           ...                                gnb_index=${gnb_index}
           ...                                gnb_hostname=${tl.gnbs[${gnb_index}].cu.backhaul_site_oam_ip}
    END
    FOR    ${gnb_index}    IN RANGE   ${SCFC_Gnb_length}
           ${SCFC_Gnb_file_path_exist}    Run Keyword And Return Status    OperatingSystem.File Should Exist
           ...                                                                            ${all_config_file_dic['SCFC_Gnb'][${gnb_index}]}
           Run Keyword If    ${SCFC_Gnb_file_path_exist}    Airphone Modify vlanId and Commissioning Full SCF For Classic
           ...                                                              scf_file_path=${all_config_file_dic['SCFC_Gnb'][${gnb_index}]}
           ...                                                              index=${gnb_index}
    END
    Log to Console    \n******check RU status******\n
    FOR    ${gnb_index}    IN RANGE   ${SCFC_Gnb_length}
            Airphone Confirm RRU Configured    timeout=10 min    bts_index=${gnb_index}
    END


Airphone Modify vlanId and Commissioning Full SCF For Classic
    [Arguments]    ${scf_file_path}=${None}    ${bts_index}=0
    ...            ${expected_status}=Commissioned    ${index}=0
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                This KW is used to Airphone Modify vlanId and Commissioning Full SCF For Classic.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${scf_file_path} | Yes | The scf file full path and name. E.g. testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/HAZ3/TL_Airphone/config/scf.xml |
    ...    | ${expected_status} | No | set expected bts status after upload SCF|
    ...    | ${index} | No | The index is set which gnb you want to use |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    |  Airphone Modify vlanId and Commissioning Full SCF For Classic  |  scf_file_path=${scf_file_path} |
    ...                                                    expected_status=${expected_status} | index=${index} |
    log    ${bts_index} is not used
    ${bts_index}    Evaluate    ${index}+${1}
    ${bts_distname_index}   set variable if  '${index}'=='0'    ${bts_index}    ${index}
    Run Keyword And Ignore Error    Module Modify vLanid by SCF    index=${index}
    ...                     new_value=${tl.gnbs[${index}].cu.x2c.vlan_id}
    ...                     dist_name=MRBTS-${bts_distname_index}/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-1
    ...                     parameter=vlanId
    ...                     scf_file=${scf_file_path}
    Airphone Commissioning Full SCF For Classic    scf_file=${scf_file_path}    bts_index=${index}

Module Modify vLanid by SCF
    [Arguments]    ${index}=0
    ...            ${new_value}=${tl.gnbs[${index}].cu.x2c.vlan_id}
    ...            ${dist_name}=MRBTS-1/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-1
    ...            ${parameter}=vlanId
    ...            ${scf_file}=${None}
    scf.load_scf  file_path=${scf_file}
    ${before_value}=  scf.Get_Value_From_Scf   dist_name=${dist_name}   p_name=${parameter}
    Run Keyword If    '${before_value}' != '${new_value}'    scf.modify_scf_element  value=${new_value}
    ...                                                                              dist_name=${dist_name}
    ...                                                                              p_name=${parameter}
    ${after_value}=  scf.Get_Value_From_Scf   dist_name=${dist_name}   p_name=${parameter}
    scf.save_scf  file_path=${scf_file}

Airphone Commissioning Full SCF For Classic
    [Arguments]    ${scf_file}    ${bts_index}    ${timeout}=${600}
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                This KW is used to commission full scf to sbts. And check onair status.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${scf_file} | Yes | The scf file full path and name. E.g. testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/HAZ3/TL_Airphone/config/scf.xml |
    ...    | ${expected_status} | No | set expected bts status after upload SCF|
    ...    | ${timeout} | No |  The time out of commission, default is 600s |
    ...    | ${call_type} | No | which call you want to use |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    |  Airphone Commissioning Full SCF For Classic  |  scf_file=${CURDIR}/ ../{SUITE_NAME}/full_scf.xml  |
    ...
    Wait Until Keyword Succeeds    3x    1min    _Module Sbts Login    bts_index=${bts_index}
    coam.perform_commissioning    scf_file=${scf_file}
    ...                           skip_parameter_relation_errors=True
    ...                           should_activate=${true}
    ...                           timeout=${timeout}
    ...                           connection=COAM
    Wait Until Keyword Succeeds    30 min    10 sec    Airphone Verify BTS Status For Classic
    ...                                         expected_status=Commissioned,Configured,OnAir,IntegratedToRan
#    Airphone Confirm RRU Configured    timeout=10 min    bts_index=${bts_index}
    [Teardown]    Run Keyword And Ignore Error    _Module Sbts Logout

Airphone Confirm RRU Configured
    [Arguments]    ${bts_index}    ${connection}=COAM    ${timeout}=200
    [Documentation]    This keyword is used to wait rru configured
    Log To Console    ...wait rru configured...
    Wait Until Keyword Succeeds    3x    1min    _Module Sbts Login    bts_index=${bts_index}
    ${bts_hw_info}    coam.get_bts_info   connection=${connection}
    ${rru_list}    Set Variable    ${bts_hw_info['radioModules']['rmod']}
    ${rru_list_len}    Get Length    ${rru_list}
    FOR    ${rru_id}    IN RANGE   ${rru_list_len}
        Wait Until Keyword Succeeds    ${timeout}    5
        ...    _Airphone Verify RRU Is Configured    ${rru_id}    ${connection}
    END
    [Teardown]    Run Keyword And Ignore Error    _Module Sbts Logout

_Airphone Verify RRU Is Configured
    [Arguments]    ${rru_id}    ${connection}=COAM
    ${bts_hw_info}    coam.get_bts_info   connection=${connection}
    Should Be Equal    ${bts_hw_info['radioModules']['rmod'][${rru_id}]['status']['proceduralStatus']}    configured

Module Backup Scf For Classical
    [Arguments]    ${local_dir}=${AP_LOG_DIRECTORY}
    ${gnb_length}    Get Length    ${tl.gnbs}
    FOR    ${bts_index}    IN RANGE    ${gnb_length}
        Wait Until Keyword Succeeds    3x    1min    _Module Sbts Login    bts_index=${bts_index}
        coam.get_current_scf_file    local_dir_path=${local_dir}    file_name=gnb_${bts_index}_scf.xml    connection=COAM    timeout=80
        Run Keyword And Ignore Error    _Module Sbts Logout
    END
    [Teardown]    Run Keyword And Ignore Error    _Module Sbts Logout

Airphone Verify BTS Status For Classic
    [Arguments]    ${expected_status}=OnAir
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                Verify bts status should be correct.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${connection} | No | The alias for this connection, default is COAM |
    ...    | ${expected_status} | No | set expected bts status after upload SCF|
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | Airphone Verify bts status | connection=COAM | expected_status=OnAir |
    ...
    _Module Sbts Login
    ${bts_status}    coam.get_bts_statuses    timeout=20    connection=COAM
    ${status}    Set Variable    ${bts_status['proceduralState']}
    Should Contain    ${expected_status}    ${status}
    [Teardown]    Run Keyword And Ignore Error    _Module Sbts Logout

_Module Sbts Login
    [Arguments]    ${bts_index}=${0}    ${bts_port}=${443}    ${alias}=COAM
    coam.connect_to
    ...    bts_host=${tl.gnbs[${bts_index}].cu.backhaul_site_oam_ip}
    ...    bts_port=${bts_port}
    ...    username=${tl.gnbs[${bts_index}].cu.oam_http_connection_details.username}
    ...    password=${tl.gnbs[${bts_index}].cu.oam_http_connection_details.password}
    ...    use_ssl=${True}
    ...    update_interval=${5000}
    ...    admin_api_log_dir=${AP_LOG_DIRECTORY}
    ...    name=${alias}

_Module Sbts Logout
    [Arguments]    ${connection}=COAM
    coam.teardown    connection=${connection}

################################ cloud part #################################
_Module Config Iphy For Cloud
    [Arguments]    ${iphy_path}    ${iphy_file_path_exist}    ${product_type}    ${du_index}=0
    @{product_type_list}    Split String    ${product_type}    _
    ${product_type_dc}=    Convert To Lowercase     ${product_type_list[-1]}
    Run Keyword If    '${product_type}'=='vdu' or '${product_type}'=='vcu'    Module AIC Configure TL VM ETH IP
    Run Keyword If    '${iphy_file_path_exist}' != 'False' and '${product_type_dc}'=='dc_other'    _Module Change Vlan Id In Iphy xml
    ...                                                                                         targe_iphy_path=${iphy_path}
    ${du_hosting_index}    Evaluate    ${du_index}+1
    Run Keyword If    '${iphy_file_path_exist}' != 'False'    iphy_modify.change_iphy_rru_version_aic    iphy_xml_path=${iphy_path}
    ...    enb_ip=${tl.cloud_hostings[${du_hosting_index}].master_node.ssh_connection_details.addr}
    ...    enb_user=${tl.cloud_hostings[${du_hosting_index}].master_node.ssh_connection_details.username}
    ...    enb_pwd=${tl.cloud_hostings[${du_hosting_index}].master_node.ssh_connection_details.password}
    ...    du_namespace=${tl.cloud_hostings[${du_hosting_index}].namespace}
    ...    log_path=${AP_LOG_DIRECTORY}

_Module Change Vlan Id In Iphy xml
    [Arguments]    ${targe_iphy_path}
    ${vlan_id}    tak_xml_module.ap_module_read_xml    ${AP_LOG_DIRECTORY}/source_iphy.xml
    ...    text|//preferredVlanId
    ...    return_type=list
    ${uni_id}    evaluate    len(list(set(${vlan_id})))==1
    Run Keyword And Ignore Error    should be true    ${uni_id}    ${True}
    ${status}    ${msg}     Run Keyword And Ignore Error    File Should Exist     ${targe_iphy_path}
    ${base_xml}     Set Variable If    '${status}'=='PASS'    ${targe_iphy_path}
    ...    ${AP_LOG_DIRECTORY}/source_iphy.xml
    Run Keyword And Ignore Error    tak_xml_module.ap_module_modify_xml    ${base_xml}     ${targe_iphy_path}
    ...                                                                     text|${vlan_id[0]}|//preferredVlanId

Module Backup Iphy Xml File
    [Arguments]    ${log_dir}=${AP_LOG_DIRECTORY}    ${backup_name}=iphy_backup.xml
    ${remote_path}=    Set Variable    /ffs/run/simmode/iphy.xml
    ${local_path}=    Set Variable    ${log_dir}/${backup_name}
    ${cp_cmd}=    Set Variable    sshpass -p ${AP_ASIK.password} scp ${AP_ASIK.username}@${AP_ASIK.ip}:${remote_path} ${local_path}
    OperatingSystem.Run    ${cp_cmd}

Module Backup AP Swconfig File
    [Arguments]    ${log_dir}=${AP_LOG_DIRECTORY}    ${backup_name}=ap_swconfig_backup.txt
    ${remote_path}=    Set Variable    /ffs/run/swconfig.txt
    ${local_path}=    Set Variable    ${log_dir}/${backup_name}
    ${cp_cmd}=    Set Variable    sshpass -p ${AP_ASIK.password} scp ${AP_ASIK.username}@${AP_ASIK.ip}:${remote_path} ${local_path}
    OperatingSystem.Run    ${cp_cmd}

Module Backup Gnb Swconfig File
    [Arguments]    ${log_dir}=${AP_LOG_DIRECTORY}
    ${remote_path}=    Set Variable    /ffs/run/swconfig.txt
    ${gnb_length}    Get Length    ${tl.gnbs}
    FOR   ${gnb_index}    IN RANGE    ${gnb_length}
        Set Test Variable    ${gnb_hostname}   ${tl.gnbs[${gnb_index}].dus[${0}].airscale.common_units[0].lmp_connection.addr}
        Set Test Variable    ${gnb_username}   ${tl.gnbs[${gnb_index}].dus[${0}].airscale.common_units[0].lmp_connection.username}
        Set Test Variable    ${gnb_password}   ${tl.gnbs[${gnb_index}].dus[${0}].airscale.common_units[0].lmp_connection.password}
        ${local_path}=    Set Variable    ${log_dir}/${gnb_index}_swconfig_backup.txt
        ssh.Connect To    hostname=${gnb_hostname}    username=${gnb_username}    password=${gnb_password}    alias=asib
        ${cp_cmd}=    Set Variable    sshpass -p ${gnb_password} scp toor4nsn@192.168.255.129:${remote_path} ${local_path}
        OperatingSystem.Run    ${cp_cmd}
        ssh.disconnect    connection=asib
    END
    [Teardown]    Run Keyword And Ignore Error    ssh.disconnect    connection=asib

Module vDU Backup SCF From Test Line
    [Arguments]    ${scf_file_name}=vDU_scf_backup.xml    ${vdu_index}=0
    log to console  *** Backup SCF From Test Line Before Case Excution ***
    Module vDU Login By Rest    vdu_index=${vdu_index}
    Create directory    ${AP_LOG_DIRECTORY}/backup_vdu_scf
    ${vDU_SCF_file}=    Set Variable      ${AP_LOG_DIRECTORY}/backup_vdu_scf
    ${backup_scf_file}=    coam_vdu.get_current_plan_file    local_dir_path=${vDU_SCF_file}    filename=${scf_file_name}
    ...                                                include_runtime_data=${False}    vdu_connection=vdu
    [Return]    ${backup_scf_file}
    [Teardown]    Module vDU Logout By Rest

Module vCU Backup SCF From Test Line
    [Arguments]    ${gnb_index}=${0}
    Module Login To vCU By Rest    gnb_index=${gnb_index}
    Create directory    ${AP_LOG_DIRECTORY}/backup_vcu_scf
    ${vCU_SCF_file}=    Set Variable      ${AP_LOG_DIRECTORY}/backup_vcu_scf/vCU_scf.xml
    ${backup_vCU_scf_file}=    coam_cu.get_current_plan_file    path=${vCU_SCF_file}    include_runtime_data=${False}
    ...                                                    timeout=120    connection=vcu
    [Return]    ${vCU_SCF_file}
    [Teardown]   Module Logout To vCU By Rest

Module Backup WTS Config File
    [Arguments]    ${log_dir}=${AP_LOG_DIRECTORY}    ${backup_name}=wts_backup.cfg
    ${remote_path}=    Set Variable    /opt/wts/latest/basic_setup.cfg
    ${local_path}=    Set Variable    ${log_dir}/${backup_name}
    ${remote_wts_file_path_exist}    Run Keyword And Return Status    OperatingSystem.File Should Exist    ${remote_path}
    ${cp_cmd}=    Set Variable    cp ${remote_path} ${local_path}
    Run Keyword If    '${remote_wts_file_path_exist}' != 'False'     OperatingSystem.Run    ${cp_cmd}


Reboot Airphone For Aic
    Run Keyword And Ignore Error  Wait For Host Ssh  192.168.200.1  timeout=180
    Run Keyword And Ignore Error    ute_fsmaccess.setup_wts_fsm_access    host=192.168.200.1    user=toor4nsn
    ...                                                                   password=oZPS0POrRieRtu    port=22
    ...                                                                   alias=sshap
    ute_fsmaccess.start_command_on_wts    cmd=ddal -s ddal_boot_set_reset_loop_count 0\n
    ...                                   alias=sshap
    Sleep    3
    ute_fsmaccess.start_command_on_wts    cmd=reboot\n
    ...                                   alias=sshap
    Run Keyword And Ignore Error  Wait For Host Ssh  192.168.200.1  timeout=180
    [Teardown]    ute_fsmaccess.Teardown Wts Fsm Access    alias=sshap


Module AIC Configure TL VM ETH IP
    Log To Console    Configure NSA VM interfaces...
    OperatingSystem.Run    sudo ip addr add 10.0.1.131/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.132/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.133/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.134/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.135/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.136/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.137/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.11.100/24 dev eth8
    OperatingSystem.Run    sudo ip addr add 10.0.1.138/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.139/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.141/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.142/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.143/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.99/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.121/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.2.99/24 dev eth4
    OperatingSystem.Run    sudo ip addr add 10.0.1.127/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.106/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.102/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.125/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.200/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.201/24 dev eth3

Module Get TL Config
    [Arguments]    ${filename}=${None}
    Log    ${filename} is not used
    ${variables}=    Get variables
    Set suite variable    ${VLAN_IDS}    ${tl.gnbs[0].dus[0].fhuc_vlans}
    Set suite variable    ${NAMESPACE_CU}    ${tl.cloud_hostings[0].namespace}
    Set suite variable    ${NAMESPACE_VDU}    ${tl.cloud_hostings[1].namespace}
    Set Suite Variable    &{MASTER_CU}
    ...    hostname=${tl.cloud_hostings[0].master_node.ssh_connection_details.addr}
    ...    username=${tl.cloud_hostings[0].master_node.ssh_connection_details.username}
    ...    password=${tl.cloud_hostings[0].master_node.ssh_connection_details.password}
    ...    alias=cu_master
    Set Suite Variable    &{MASTER_VDU}
    ...    hostname=${tl.cloud_hostings[1].master_node.ssh_connection_details.addr}
    ...    username=${tl.cloud_hostings[1].master_node.ssh_connection_details.username}
    ...    password=${tl.cloud_hostings[1].master_node.ssh_connection_details.password}
    ...    alias=vdu_master
    Set Suite Variable    &{OAM_CU}
    ...    host=${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ...    port=${tl.gnbs[0].cu.oam_http_connection_details.port}
    ...    username=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...    password=${tl.gnbs[0].cu.oam_http_connection_details.password}
    ...    secure=${True}
    ...    alias=cu_admin
    Set Suite Variable  &{OAM_VDU}
    ...    host=${tl.gnbs[0].dus[0].oam_http_connection_details.addr}
    ...    port=${tl.gnbs[0].dus[0].oam_http_connection_details.port}
    ...    username=${tl.gnbs[0].dus[0].oam_http_connection_details.username}
    ...    password=${tl.gnbs[0].dus[0].oam_http_connection_details.password}
    ...    secure=${True}
    ...    connection_name=vdu_admin
	Run Keyword And Ignore Error    set suite variable
    ...    ${VDU_RANNIC1_SERIAL_NUMBER}  ${tl.gnbs[${0}].dus[${0}].rannics[${0}].serial_number}
    Run Keyword And Ignore Error    set suite variable
    ...    ${VDU_RANNIC1_PRODUCT_CODE}  ${tl.gnbs[${0}].dus[${0}].rannics[${0}].product_code}
    Set Suite Variable    &{AP_ASIK}
    ...                      ip=192.168.200.1
    ...                      username=toor4nsn
    ...                      password=oZPS0POrRieRtu
    ...                      connection=APAsik
    Set Suite Variable    ${TESTLINE_TYPE}     ${tl.tl_cloud_topology}


Module Get TestLine Name From UTE Cloud
    [Documentation]    This kw is used to get tl name
    ${status}    ${TestLine_Name}    Run Keyword And Ignore Error    get variable value    ${CONFIGURATION}
    ...    ${variablefile}
    ${key_list}    Create List    CM_RESOURCES    0    properties    name
    ${TestLine_Name}    Run Keyword If    '${status}'=='FAIL'
    ...    Module Get Info From UTE Reservation File    key_list=${key_list}
    ...    ELSE    Set Variable    ${TestLine_Name}
    Log to Console    \n***TestLine Name ${testline_name}***
    ${TestLine_Name_List}    Split String    ${TestLine_Name}    .
    Set Suite Variable    ${TESTLINE_NAME}    ${TestLine_Name_List[-1]}
    [Return]    ${TestLine_Name}

Module Get Info From UTE Reservation File
    [Arguments]    ${key_list}    ${file_path}=${UTE_RESERVATION_CONTEXT_JSON}
    ${context}    OperatingSystem.Get File    ${file_path}
    &{context_dict}    json.Loads    ${context}
    ${dict}    Set Variable    ${context_dict}
    FOR    ${k}    IN    @{key_list}
        ${k_convert}    Run Keyword If    ${k.isdigit()}
        ...    Convert To Integer    ${k}
        ...    ELSE    Set Variable    ${k}
        ${dict}    Run Keyword If    ${k.isdigit()}
        ...    Set Variable    ${dict}[${k_convert}]
        ...    ELSE    Collections.Get From Dictionary    ${dict}    ${k_convert}
    END
    [Return]    ${dict}

Load SCF For Cloud
    [Arguments]    ${all_config_file_dic}    ${product_type}
    ${SCFC_vCU_length}    Get Length    ${all_config_file_dic['SCFC_vCU']}
    FOR    ${vCU_index}    IN RANGE   ${SCFC_vCU_length}
           ${SCFC_vCU_file_path_exist}    Run Keyword And Return Status    OperatingSystem.File Should Exist
           ...                                                                            ${all_config_file_dic['SCFC_vCU'][${vCU_index}]}
           Set Variable    ${SCFC_vCU_file_path_exist}
           Run Keyword If    ${SCFC_vCU_file_path_exist}   Run Keywords    Module vCU Full Commssion By Rest
           ...                                                                  scf_path=${all_config_file_dic['SCFC_vCU'][${vCU_index}]}
           ...                                                                  gnb_index=${vCU_index}
           ...                                                      AND    Airphone Modify vlanId and Commissioning Full SCF For AIC
           ...                                                                  all_config_file_dic=${all_config_file_dic}
           ...                                                                  product_type=${product_type}
           ...                                                                  gnb_index=${vCU_index}
    END
    Log To Console    \nCase Result: SCFC_vCU_file_path_exist=${SCFC_vCU_file_path_exist}


Airphone Modify vlanId and Commissioning Full SCF For AIC
    [Arguments]    ${all_config_file_dic}    ${product_type}    ${gnb_index}=${0}
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                This KW is used to Airphone Modify vlanId and Commissioning Full SCF.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${scf_file_path} | Yes | The scf file full path and name. E.g. testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/HAZ3/TL_Airphone/config/scf.xml |
    ...    | ${expected_status} | No | set expected bts status after upload SCF|
    ...    | ${index} | No | The index is set which gnb you want to use |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    |  Airphone Modify vlanId and Commissioning Full SCF  |  scf_file_path=${scf_file_path} | expected_status=${expected_status} |
    ...                                                         | index=${index} ../{SUITE_NAME}/full_scf.xml  |
    ${SCFC_vDU_length}    Get Length    ${all_config_file_dic['SCFC_vDU']}
    @{product_type_list}    Split String    ${product_type}    _
    ${product_type_dc}=    Convert To Lowercase     ${product_type_list[-1]}
    FOR    ${du_index}    IN RANGE   ${SCFC_vDU_length}
           ${SCFC_vDU_file_path_exist}    Run Keyword And Return Status    OperatingSystem.File Should Exist
           ...                                                                            ${all_config_file_dic['SCFC_vDU'][${du_index}]}
           Continue For Loop If     '${SCFC_vDU_file_path_exist}'=='False'
           Run Keyword If    '${product_type}'=='vdu' or '${product_type}'=='vcu'
           ...      Airphone Modify ProdCodePlanned And SerialNumberPlanned In vDU with ignore error
           ...                                             scf_file=${all_config_file_dic['SCFC_vDU'][${du_index}]}
           ...                                             product_type=${product_type}
           ...                                             du_index=${du_index}
           ...    ELSE IF       '${product_type_dc}'=='other'    Airphone Modify vLanid For One vDU    index=${gnb_index}
           ...                                                         du_index=${du_index}
           ...                                                         parameter=vlanId
           ...                                                         scf_file=${all_config_file_dic['SCFC_vDU'][${du_index}]}
           Module vDU Update Full SCF By Rest    scf_path=${all_config_file_dic['SCFC_vDU'][${du_index}]}
           ...                                   vdu_index=${du_index}
           Reboot Airphone For Aic
#           Wait Until Keyword Succeeds    20 min    10 sec     Airphone Verify RU State For Truck Roll    gnb_index=${gnb_index}
           Wait Until Keyword Succeeds    30 min    60 sec     Airphone Verify RU State For Truck Roll    du_index=${du_index}
           Wait until keyword succeeds    10 min  10 sec    Airphone Confirmed F1 link should be available
    END

Airphone Modify ProdCodePlanned And SerialNumberPlanned In vDU with ignore error
    [Arguments]    ${product_type}=vdu
    ...            ${du_index}=0
    ...            ${scf_file}=${None}
    Run Keyword And Ignore Error    Airphone Modify ProdCodePlanned And SerialNumberPlanned In vDU
    ...            product_type=${product_type}
    ...            du_index=${du_index}
    ...            scf_file=${scf_file}

Module vDU Update Full SCF By Rest
    [Arguments]    ${scf_path}   ${vdu_index}=0
    log to console    \n*** start send commission on vdu ***
    Module vDU Login By Rest    ${vdu_index}
     ${res}    coam_vdu.perform_commissioning  scf_file=${scf_path}   timeout=1000     wait_for_completion=${True}
     ...                                       vdu_connection=vdu
     ${result}    coam_vdu.get_status_of_perform_commissioning     operation_id=${res["id"]}    vdu_connection=vdu
    [Return]     ${result["status"]}
    [Teardown]    Module vDU Logout By Rest

Module vCU Full Commssion By Rest
    [Arguments]    ${scf_path}    ${gnb_index}=0
    log to console    \n*** start send commission on vCU ***
    Module Login To vCU By Rest    gnb_index=${gnb_index}
    ${res}    coam_cu.perform_commissioning    scf_file=${scf_path}   timeout=1000    wait_for_completion=${True}
    ...                                        connection=vcu
    ${result}    coam_cu.get_status_of_perform_commissioning     operation_id=${res["id"]}    connection=vcu
    [Return]     ${result["status"]}
    [Teardown]   run keyword and ignore error    Module Logout To vCU By Rest

Airphone Verify RU State For Truck Roll

   [Arguments]    ${du_index}=${0}
   Module Verify All RU Status In vDU    vdu_index=${du_index}
#    ${du_number}    Get vDU Number    gnb_index=${gnb_index}
#    FOR    ${i}    IN RANGE    ${du_number}
#        Module Verify All RU Status In vDU    vdu_index=${i}
#    END


Module Verify All RU Status In vDU
   [Arguments]      ${vdu_index}=${0}
    Module vDU Login By Rest    vdu_index=${vdu_index}
    ${ru_info}=  coam_vdu.get_rmods_status    vdu_connection=vdu
    FOR    ${ru_info}    IN    @{ru_info}
        ${administrative_state}=    Convert To Lowercase   ${ru_info["administrative_state"]}
        ${operational_state}=    Convert To Lowercase     ${ru_info["operational_state"]}
        Should Be Equal    ${administrative_state}    unlocked
        Should Be Equal    ${operational_state}    enabled
    END
   [Teardown]   Run Keyword And Ignore Error    Module vDU Logout By Rest

Module Login To vCU By Rest
   [Arguments]   ${gnb_index}=0   ${alias}=vcu
    ${host}    set variable  ${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    run keyword and ignore error    Module Logout To vCU By Rest
    coam_cu.connect to    host=${host}
    ...    port=${EMPTY}
    ...    username=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    password=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ...    secure=${True}
    ...    alias=${alias}
    [Return]  ${alias}

Module Logout To vCU By Rest
    [Arguments]    ${connection}=vcu
    coam_cu.disconnect    connection=${connection}

Airphone Confirmed F1 link should be available
    Module Login To vCU By Rest    alias=cu_admin
    ${du_state}    coam_cu.get_du_state    connection=cu_admin
#    Should be equal    ${du_state}[f1_link_status][available]    ${1}
    ${is_available}    Evaluate    ${du_state}[f1_link_status][available] >= 1
    Should Be True    ${is_available}
    Log to console    CU: F1 link is available
    [Teardown]    Module Logout To vCU By Rest    connection=cu_admin

Airphone Modify ProdCodePlanned And SerialNumberPlanned In vDU
    [Arguments]    ${product_type}=vdu
    ...            ${index}=0
    ...            ${du_index}=0
    ...            ${scf_file}=${None}
    ${MRBTS_ID}   set variable if  '${product_type}'=='gnb'    ${tl.gnbs[${index}].instance_id}    ${tl.gnbs[${index}].dus[${du_index}].instance_id}
    scf.load_scf  file_path=${scf_file}
    ${pcode_new_value}     Set Variable    ${tl.gnbs[${index}].dus[${du_index}].rannics[${0}].product_code}
    ${sn_new_value}     Set Variable    ${tl.gnbs[${index}].dus[${du_index}].rannics[${0}].serial_number}
    ${vlan_value}     Set Variable    ${tl.ues[${index}].preferred_vlans[${du_index}].preferred_vlan_id}

#    ${pcode_before_value}    scf.Get_Value_From_Scf   dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RNICMOD-1
#    ...                                             p_name=prodCodePlanned
#    ${sn_before_value}  scf.Get_Value_From_Scf   dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RNICMOD-1
#    ...                                             p_name=serialNumberPlanned
    ${dist_name_pattern}    set variable    EQM-1/APEQM-1/RNICMOD-1
    ${all_distnames}    scf.get_all_dist_names_by_pattern   ${dist_name_pattern}
    ${target_distname}=    Evaluate
    ...    [dn for dn in ${all_distnames} if re.match(r"MRBTS-(\\d+)/EQM-1/APEQM-1/RNICMOD-1$", dn)]    modules=re
    run keyword and ignore error    scf.modify_scf_element  value=${pcode_new_value}
    ...    dist_name=${target_distname}[0]
    ...    p_name=prodCodePlanned
    run keyword and ignore error    scf.modify_scf_element  value=${sn_new_value}
    ...    dist_name=${target_distname}[0]
    ...    p_name=serialNumberPlanned
    ${dist_vlan_pattern}    set variable    MNL-1/MNLENT-1/MPLANEFHNW-1
    ${all_distnames_for_vlan}    scf.get_all_dist_names_by_pattern   ${dist_vlan_pattern}
    ${target_vlan_distname}=    Evaluate
    ...    [dn for dn in ${all_distnames_for_vlan} if re.match(r"MRBTS-(\\d+)/MNL-1/MNLENT-1/MPLANEFHNW-1$", dn)]    modules=re
    run keyword and ignore error    scf.modify_scf_element  value=${vlan_value}
    ...    dist_name=${target_vlan_distname}[0]
    ...    p_name=vlanId
    scf.save_scf  file_path=${scf_file}

Airphone Modify vLanid For One vDU
    [Arguments]    ${index}=0
    ...            ${du_index}=0
    ...            ${parameter}=vlanId
    ...            ${scf_file}=${None}
    scf.load_scf  file_path=${scf_file}
    ${dist_names}    scf.get_all_dist_names_of_specific_class    mo_class=com.nokia.srbts.mnl:LCELNR
    FOR    ${i}    ${dist_name}    IN ENUMERATE    @{dist_names}
       ${new_value}     Set Variable    ${tl.gnbs[${index}].dus[${du_index}].fhuc_vlans[${i}]}
        ${before_value}  scf.Get_Value_From_Scf   dist_name=${dist_name}   p_name=${parameter}
        Run Keyword If    '${before_value}' != '${new_value}'    scf.modify_scf_element  value=${new_value}
        ...    dist_name=${dist_name}
        ...    p_name=${parameter}
        ${after_value}   scf.Get_Value_From_Scf   dist_name=${dist_name}   p_name=${parameter}
        Log to Console    change vlan id from ${before_value} to ${after_value}
    END
    scf.save_scf  file_path=${scf_file}

Airphone Modify TNL-1 In vDU
    [Arguments]    ${scf_file}=${None}
    scf.load_scf  file_path=${scf_file}
    ${before_value}  scf.Get_Value_From_Scf   dist_name=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPRT-1
    ...                                       p_name=destIpAddr
    ...                                       list_name=staticRoutes
    ${cmd}=    Catenate    sudo ifconfig eth0 | grep -w inet | awk '{ print $2}'
    ${new_value}    OperatingSystem.Run    ${cmd}
#    ${new_value}    Set Variable     ${tl.test_pc.default_ssh_connection_details.addr}
    Run Keyword If    '${before_value}' != '${new_value}'    scf.modify_scf_element  value=${new_value}
    ...                 dist_name=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPRT-1
    ...                 p_name=destIpAddr
    ...                 list_name=staticRoutes
    ${after_value}   scf.Get_Value_From_Scf   dist_name=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPRT-1
    ...                                       p_name=destIpAddr
    ...                                       list_name=staticRoutes
    Log to Console    change TNL-1 Address from ${before_value} to ${after_value}
    scf.save_scf  file_path=${scf_file}


Module Update Staged Plan Parameter
    [Arguments]  ${plan_id}   ${mo_dn}   ${updated_paras_dict}  ${operation}=replace  ${mo_uuid}=${None}  ${timeout}=30
    ${timeout}   convert to integer  ${timeout}
    ${out}  coam_vdu.update_vdu_parameter_of_staged_plan   plan_id=${plan_id}  mo_dn=${mo_dn}
     ...    updated_paras_dict=${updated_paras_dict}   operation=${operation}   mo_uuid=${mo_uuid}  timeout=${timeout}
     ...    vdu_connection=vdu
    ${action_id}  set variable  ${out["action_id"]}
    ${rtn}   wait until keyword succeeds  20   2   _Module Update Staged Plan Parameter Should Be Expected
     ...   plan_id=${plan_id}   action_id=${action_id}   expected_status=success
    [Return]  ${out}

_Module Update Staged Plan Parameter Should Be Expected
    [Arguments]   ${plan_id}   ${action_id}   ${expected_status}
    ${out}   coam_vdu.get_update_paras_action_status_of_staged_plan      plan_id=${plan_id}  action_id=${action_id}
     ...    vdu_connection=vdu
    Should Be True  "${out["status"]}"=="${expected_status}"
    [Return]  ${out}

Module vDU Check All Cells Status Should Be Onair For All DUs
    [Arguments]    ${gnb_index}=${0}
    ${du_number}    Get vDU Number    gnb_index=${gnb_index}
    FOR    ${i}    IN RANGE    ${du_number}
        Module vDU Check All Cells Status Should Be Onair    vdu_index=${i}    gnb_index=${gnb_index}
    END

Module vDU Login By Rest
    [Arguments]    ${vdu_index}=0    ${gnb_index}=0    ${alias}=vdu
    ${oam_httpaddr}    set variable    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.addr}
    ${oam_web_ip}    set variable if    ':' in '''${oam_httpaddr}'''   [${oam_httpaddr}]    ${oam_httpaddr}
    Run keyword and ignore error    Module vDU Logout By Rest
    coam_vdu.connect to
    ...  host=${oam_web_ip}
    ...  port=${EMPTY}
    ...  username=${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.username}
    ...  password=${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.password}
    ...  secure=True
    ...  connection_name=${alias}

Module vDU Logout By Rest
    [Arguments]    ${alias}=vdu
    coam_vdu.disconnect    ${alias}

Module vDU Check All Cells Status Should Be Onair
    [Arguments]    ${vdu_index}=0    ${gnb_index}=0
    [Documentation]    vDU Verify Cells Status Should Be Onair With Expected Cell Number
    ...    Author: mengli yang
    ...    Contact: mengli.yang@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | vdu_index | No. | specify which vdu needs to be check if the testline configed multi vdus |
    ...    | gnb_index | No. | specify which vdu needs to be check if the testline configed multi vdus |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | vDU Verify Cells Status Should Be Onair With Expected Cell Number |
    ...
    ${cell_number}    Module Get VDU Cell Number From SCF    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    Module vDU Login By Rest    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    ${vdu_cells_summary}=    coam_vdu.get_vdu_cells_summary    vdu_connection=vdu
    Should Be Equal As Numbers    ${vdu_cells_summary['basic_cells_summary']['operational_state']['disabled']}    0
    Should Be Equal As Numbers    ${vdu_cells_summary['basic_cells_summary']['administrative_state']['locked']}    0
#    Should Be Equal As Numbers    ${vdu_cells_summary['basic_cells_summary']['administrative_state']['shutting_down']}  0
#    ${on_line}    set variable    ${vdu_cells_summary['availability_status']['on_line']}
#    should be true    ${on_line}==${cell_number}
    [Teardown]  Module vDU Logout By Rest

Module Get VDU Cell Number From SCF
    [Arguments]  ${vdu_index}=0   ${gnb_index}=0
    [Documentation]   Get VCU Cell Number From SCF
    ...    Author: mengli yang
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index | no | gnb index to indicate which gnb will be used, default is 0  |
    ...
    ...    | Return Value | Description |
    ...    | ${cell_number} | return cell number |
    ...
    ...    Example
    ...    | ${cell_number} | Get VCU Cell Number From TestLine |
    ...
    Module vDU Login By Rest    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    Create directory    ${AP_LOG_DIRECTORY}/scf
    ${tmp_scf_file}    coam_vdu.get_current_plan_file    local_dir_path=${AP_LOG_DIRECTORY}/scf   filename=scf.xml
    ...                                              include_runtime_data=${False}
    ...                                              vdu_connection=vdu
    ${scf_content}    OperatingSystem.Get File    ${tmp_scf_file}
    ${result}    Get Regexp Matches    ${scf_content}    .*NRCELL"\\s+distName="MRBTS-(\\d+)/NRBTS-(\\d+)/NRCELL-(\\d+)"\\s+.*   3
    ${cell_number}    Set Variable    ${result.__len__()}
    [Return]   ${cell_number}
    [Teardown]   run keyword and ignore error  Module vDU Logout By Rest   vdu_index=${vdu_index}

################################ wts iphy apswconfig part #################################
Airphone Replace Swconfig For Gnb and AP
    [Arguments]    ${tag}
    ${all_config_file_dic}    _Get All Config File path    tag=${tag}
    Set Variable    ${all_config_file_dic}
    ${SCFC_Gnb_length}    Get Length    ${all_config_file_dic['SCFC_Gnb']}
    FOR    ${gnb_index}    IN RANGE   ${SCFC_Gnb_length}
           ${swconfig_file_path_exist}    Run Keyword And Return Status    OperatingSystem.File Should Exist
           ...                                                          ${all_config_file_dic['Swconfig_Gnb'][${gnb_index}]}
           Run Keyword If    ${swconfig_file_path_exist}    AP Replace Swconfig
           ...                                local_path=${all_config_file_dic['Swconfig_Gnb'][${gnb_index}]}
           ...                                remote_path=/ffs/run/swconfig.txt
           ...                                gnb_index=${gnb_index}
           ...                                gnb_hostname=${tl.gnbs[${gnb_index}].cu.backhaul_site_oam_ip}
    END
    Log to Console    \n******config airphone swconfig******\n
    ${Swconfig_AP_file_path_exist}    Run Keyword And Return Status    OperatingSystem.File Should Exist    ${all_config_file_dic['Swconfig_AP']}
    Run Keyword If    ${Swconfig_AP_file_path_exist}    AP Replace Swconfig    local_path=${all_config_file_dic['Swconfig_AP']}
    ...            remote_path=/ffs/run/swconfig.txt
    ...            gnb_hostname=192.168.200.129


AP Replace Swconfig
    [Arguments]    ${local_path}=/home/ute/swconfig/swconfig.txt    ${remote_path}=/ffs/run/swconfig.txt    ${gnb_index}=0
    ...            ${gnb_hostname}=${tl.gnbs[${gnb_index}].cu.backhaul_site_oam_ip}
    ...            ${product_type}=gnb
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
    Run Keyword If    "${product_type}"=="vdu" or "${product_type}"=="vdu_other" or "${product_type}"=="vcu"    run keywords
    ...        set test variable    ${gnb_username}   toor4nsn    AND
    ...        set test variable    ${gnb_password}   oZPS0POrRieRtu
    ...    ELSE IF    "${product_type}"=="gnb"    run keywords
    ...    set test variable    ${gnb_username}   ${tl.gnbs[${gnb_index}].dus[${0}].airscale.common_units[0].lmp_connection.username}    AND
    ...    set test variable    ${gnb_password}   ${tl.gnbs[${gnb_index}].dus[${0}].airscale.common_units[0].lmp_connection.password}
#    Run Keyword If    "${gnb_index}" > '0'    _Module Setup Other GNB    bts_index=${gnb_index}
#    ...                                                                  local_path=${local_path}
#    ...                                                                  remote_path=${remote_path}
    ssh.Connect To    hostname=${gnb_hostname}    username=${gnb_username}
    ...                                                         password=${gnb_password}    alias=gnb_${gnb_index}
    ssh.upload_file    local_path=${local_path}    remote_path=${remote_path}
    ...                                                           connection=gnb_${gnb_index}
    ${cmd}=    Catenate    cd /ffs/run/ && crasign swconfig.txt
    ssh.execute    command=${cmd}    connection=gnb_${gnb_index}
    [Teardown]    ssh.disconnect    connection=gnb_${gnb_index}

_module_wait_sim_state_until_active_and_setup_x2_connection
    [Arguments]    ${alias}=default    ${timeout}=180     ${enb_id}=${None}    ${gnb_id}=${None}
    Log To Console    ...wait sim state active and setup x2 connection...
    Wait Until Keyword Succeeds     ${timeout}     15     _Module_sim_state_is_active
    ...    alias=${alias}
    tak_ap.airphone_setup_x2_connection    timeout=${timeout}
    ...                                    enb_id=${enb_id}
    ...                                    gnb_id=${gnb_id}
    ...                                    alias=${alias}


_module_wait_until_sib1_received_and_setup_x2_connection
    [Arguments]    ${tag}    ${customer}    ${alias}=default    ${timeout}=200
    ...            ${enb_id}=${None}    ${gnb_id}=${None}
    Log To Console    ...wait sib1 message for all cells then setup x2 connection...
    ${start_time}=    Get Time    epoch
    tak_ap.Airphone Get Enb Id    alias=${alias}
    _module_wait_until_sib1_received_for_all_cells    tag=${tag}    customer=${customer}
    ...                             alias=${alias}    timeout=${timeout}
    ${end_time}=    Get Time    epoch
    ${used_time}=    Evaluate    ${end_time}-${start_time}
    ${timeout_1}=    Evaluate    ${timeout}-${used_time}
    tak_ap.airphone_setup_x2_connection    timeout=${timeout}
    ...                                    enb_id=${enb_id}
    ...                                    gnb_id=${gnb_id}
    ...                                    alias=${alias}

_module_wait_until_sib1_received_for_all_cells
    [Arguments]    ${tag}    ${customer}    ${alias}=default    ${timeout}=600
    Log To Console    ...wait sib1 message for all cells...
    ${start_time_1}=    Get Time    epoch
    Wait Until Keyword Succeeds     ${timeout}     15     _Module_sim_state_is_active
    ...    ${alias}
    ${end_time_1}=    Get Time    epoch
    ${used_time_1}=    Evaluate    ${end_time_1}-${start_time_1}
    ${timeout_1}=    Evaluate    ${timeout}-${used_time_1}
    ${gnb_id}    Wait Until Keyword Succeeds    6x    10s    tak_ap.airphone_get_gnb_id    alias=${alias}
    ${cell_id_list}    Run Keyword If   '${customer}'=='${None}'    tak_ap.Airphone Get Cell Id List    alias=${alias}
    ...    ELSE IF    '${customer}'!='${None}'    _get_cell_id_list_for_customer    tag=${tag}    customer=${customer}
    ${used_time_2}=    Set Variable    0
    FOR    ${cell_id}    IN    @{cell_id_list}
        ${timeout_2}=    Evaluate    ${timeout_1}-${used_time_2}
        ${start_time_2}=    Get Time    epoch
        Sleep    10s
        Wait Until Keyword Succeeds    6x    30s     tak_ap.airphone_wait_until_sib1_received     cell_id=${cell_id}   timeout=${timeout_2}
        ${end_time_2}=    Get Time    epoch
        ${used_time_2}=    Evaluate    ${end_time_2}-${start_time_2}
    END

_get_cell_id_list_for_customer
    [Arguments]    ${tag}    ${customer}
    @{customer_list}    Split String    ${customer}    _
    ${cell_id_list}    Run Keyword If   '${customer_list[0]}'=='RJIO' or '${customer_list[0]}'=='TMO'   Get cell list for Customer
    ...                                                                                    tag=${tag}
    ...                                                                                    customer=${customer}
    [Return]    ${cell_id_list}

_Module_sim_state_is_active
    [Arguments]    ${alias}=default
    ${sim_state}=    Airphone Get Sim State    ${alias}
    ${state}=    String.Convert To Lowercase    ${sim_state}
    Should Be Equal    ${state}    active

_Cfg Configuration
    [Arguments]    ${tag}=RJIO
    ...            ${customer}=RJIO
    ...            ${wts_cfg_name}=wts.cfg
    ...            ${reload}=${True}
    ...            ${call_type}=sa
    ...            ${timeout}=600
    OperatingSystem.Run    sudo chown -R ute:ute /opt/wts
    tak_ap.airphone_start_wtssim_with_cfg_file    cfg_file=${wts_cfg_name}
    ...    reload=${reload}
    Run Keyword If    '${call_type}' == 'nsa' and '${reload}' == '${True}'    _module_wait_sim_state_until_active_and_setup_x2_connection
    ...               timeout=${timeout}
    Run Keyword If    '${call_type}' == 'sansa' and '${reload}' == '${True}'  _module_wait_until_sib1_received_and_setup_x2_connection
    ...                                                                        tag=${tag}    customer=${customer}    timeout=${timeout}
    Run Keyword If    '${call_type}' == 'sa' and '${reload}' == '${True}'    _module_wait_until_sib1_received_for_all_cells    tag=${tag}
    ...                                                                       customer=${customer}
    ...                                                                       timeout=${timeout}


Module Airphone Config Default Cfg
    [Arguments]    ${tag}    ${customer}    ${call_type}    ${wts_cfg_name}=/opt/wts/latest/basic_setup.cfg
    ${default_wts_cfg_file_path_exist}    Run Keyword And Return Status    OperatingSystem.File Should Exist    ${wts_cfg_name}
    Run Keyword If    "${default_wts_cfg_file_path_exist}"=="True"    _Cfg Configuration    tag=${tag}
    ...                                                                                     customer=${customer}
    ...                                                                                     wts_cfg_name=${wts_cfg_name}
    ...                                                                                     call_type=${call_type}
    ...    ELSE IF    "${default_wts_cfg_file_path_exist}"=="False"    fail    msg=cfg file can't be found in /opt/wts/latest/basic_setup.cfg

Module Airphone Config Cfg
    [Arguments]    ${call_type}    ${tag}    ${customer}=${None}
    ${all_config_file_dic}    _Get All Config File path    tag=${tag}
    Set Variable    ${all_config_file_dic}
    ${wts_cfg_file_path_exist}    Run Keyword And Return Status    OperatingSystem.File Should Exist    ${all_config_file_dic['wts_cfg']}
    ${wts_lua_file_path_exist}    Run Keyword And Return Status    OperatingSystem.File Should Exist    ${all_config_file_dic['wts_lua']}
    Run Keyword If    "${wts_cfg_file_path_exist}"=="True" and "${wts_lua_file_path_exist}"=="True"        _Cfg Configuration
    ...                                                          tag=${tag}
    ...                                                          customer=${customer}
    ...                                                          wts_cfg_name=${all_config_file_dic['wts_lua']}
    ...                                                          call_type=${call_type}
    ...    ELSE IF     "${wts_cfg_file_path_exist}"=="True" and "${wts_lua_file_path_exist}"=="False"    _Cfg Configuration
    ...                                                          tag=${tag}
    ...                                                          customer=${customer}
    ...                                                          wts_cfg_name=${all_config_file_dic['wts_cfg']}
    ...                                                          call_type=${call_type}
    ...    ELSE IF     "${wts_cfg_file_path_exist}"=="False" and "${wts_lua_file_path_exist}"=="True"    _Cfg Configuration
    ...                                                          tag=${tag}
    ...                                                          customer=${customer}
    ...                                                          wts_cfg_name=${all_config_file_dic['wts_lua']}
    ...                                                          call_type=${call_type}
    ...    ELSE IF     "${wts_cfg_file_path_exist}"=="False" and "${wts_lua_file_path_exist}"=="False"    Module Airphone Config Default Cfg
    ...                                                                 tag=${tag}
    ...                                                                 customer=${customer}
    ...                                                                 call_type=${call_type}

_Module Config Iphy Ip
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
    OperatingSystem.Run  sudo ip addr add 10.0.1.200/24 dev eth3
    OperatingSystem.Run  sudo ip addr add 10.0.1.201/24 dev eth3
    OperatingSystem.Run  ip addr show eth3
    OperatingSystem.Run  ip addr show eth4

_Module Config Iphy Ip For NSA
    FOR  ${number}  IN RANGE    121    131
        OperatingSystem.Run  sudo ip addr del 10.0.1.${number}/24 dev eth3
    END
    FOR  ${number}  IN RANGE    153    156
        OperatingSystem.Run  sudo ip addr del 10.0.1.${number}/24 dev eth3
    END
    FOR  ${number}  IN RANGE    9    16
        OperatingSystem.Run  sudo ip addr del 10.0.1.${number}/24 dev eth3
    END
    FOR  ${number}  IN RANGE    99    110
        OperatingSystem.Run  sudo ip addr del 10.0.1.${number}/24 dev eth3
    END
    log to console    Set Eth4 Ip
    FOR  ${number}  IN RANGE    94    101
        OperatingSystem.Run  sudo ip addr del 10.0.2.${number}/24 dev eth4
    END
    log to console    Set Eth7 Ip
    FOR  ${number}  IN RANGE  2  10
        OperatingSystem.Run  sudo ip addr add 10.0.11.${number}/24 dev eth7
    END
    FOR  ${number}  IN RANGE  11  31
        OperatingSystem.Run  sudo ip addr add 10.0.11.${number}/24 dev eth7
    END
    log to console    Set Eth8 Ip
    FOR  ${number}  IN RANGE  11  31
        OperatingSystem.Run  sudo ip addr add 10.0.12.${number}/24 dev eth8
    END
    OperatingSystem.Run  sudo ip addr del 10.0.11.100/24 dev eth8

Airphone Config Iphy Ip and Modify Iphy File
    [Arguments]    ${iphy_path}
    _Module Config Iphy Ip
    Run Keyword If    '${iphy_path}' != '${None}'    iphy_modify.change_iphy_ru_version    ${iphy_path}

Module Airphone Edaemon Egate Setup
    [Arguments]    ${edaemon_port}=22222    ${egate_port}=20000
    ...     ${save_egate}=${SAVE_EGATE_AFTER_DOWN}    ${alias}=default
    tak_ap.airphone_setup    edaemon_port=${edaemon_port}    egate_port=${egate_port}
    ...    alias=${alias}    save_egate=${save_egate}
    ute_wtssim.setup_egate    egate_port=${egate_port}    alias=${alias}
    ...    save_egate=${save_egate}
    _get ap software version
    _get wts version from config file

Module Airphone Edaemon Egate Teardown
    [Arguments]    ${alias}=default
    Run Keyword And Ignore Error    airphone_teardown    alias=${alias}
    Run Keyword And Ignore Error    ute_wtssim.teardown_egate    alias=${alias}
    OperatingSystem.Run    sudo pkill edaemon
    OperatingSystem.Run    sudo pkill egate
    OperatingSystem.Run    sudo pkill 22222
    OperatingSystem.Run    sudo pkill 20000

_get ap software version
    ute_fsmaccess.Setup Wts Fsm Access
    ${cmd}=    Set Variable    ls /ffs/run/TargetBD_5G_*.xml
    ${targetbd_file}=    ute_fsmaccess.Execute Command On Wts    ${cmd}
    ${tmp1}=    String.Fetch From Right    ${targetbd_file}    TargetBD_
    ${AP_version}=    String.Fetch From Left    ${tmp1}    .xml
    Log    AP Software Version: ${AP_version}      console=${True}
    Set Suite Metadata    AP Version    ${AP_version}
    [Teardown]    ute_fsmaccess.Teardown Wts Fsm Access
    [Return]    ${AP_version}

_get wts version from config file
    ${rc}    ${output}    OperatingSystem.Run And Return Rc And Output    ls -la /opt/wts/latest
    @{split_list}    String.Split String    ${output}    /
    Set Global Variable    ${WTS_VERSION}    ${split_list[-1]}
    Set Suite Metadata    WTS Version    ${WTS_VERSION}
    Log    WTS Version: ${WTS_VERSION}      console=${True}
    [Return]    ${WTS_VERSION}

_Module Setup Other GNB
    [Arguments]    ${bts_index}
    set suite variable  ${GNB_PC_IP}  ${tl.test_pcs[${bts_index}].default_ssh_connection_details.addr}
    log to console  GNB_PC_IP=${GNB_PC_IP}
    ute_fsmaccess.Setup Enb Fsm Access  remote_host=${GNB_PC_IP}  alias=gnb_${bts_index}
    _Module Config Iphy Ip
    [Teardown]    Teardown Enb Fsm Access    alias=gnb_${bts_index}

################################ traffic part #################################
Module AP Attach
    [Arguments]    ${traffic_info_dic}
    ${call_type}    Set Variable    ${traffic_info_dic['call_type']}
    ${ue_id}    Set Variable    ${traffic_info_dic['ue_id']}
    ${pdu_id}    Set Variable    ${traffic_info_dic['pdu_id']}
    ${profile_id}    Set Variable    ${traffic_info_dic['profile_id']}
    ${gnb_id}    Set Variable    ${traffic_info_dic['gnb_id']}
    ${cell_id}    Set Variable    ${traffic_info_dic['cell_id']}
    ${bearer_id}    Set Variable    ${traffic_info_dic['bearer_id']}
    ${call_type}    Convert To Upper Case    ${call_type}
    _AP Attach    call_type=${call_type}    ue_id=${ue_id}    pdu_id=${pdu_id}    profile_id=${profile_id}
    ...           gnb_id=${gnb_id}    cell_id=${cell_id}    bearer_id=${bearer_id}

_AP Attach
    [Arguments]    ${call_type}    ${ue_id}    ${pdu_id}    ${profile_id}    ${gnb_id}    ${cell_id}    ${bearer_id}
    Run keyword If    '${call_type}'=='NSA'   Should be True
    ...     '${gnb_id}'!='${None}' and '${cell_id}'!='${None}' and '${bearer_id}'!='${None}'
    Log To Console    start ${call_type} attach...
    ${output}     Run keyword If    '${call_type}'=='LTE'
    ...    Run Keyword    _${call_type} Attach
    ...    ue_id=${ue_id}    profile_id=${profile_id}
    ...    ELSE IF    '${call_type}'=='NSA'
    ...    Run Keyword    _${call_type} Attach
    ...    ue_id=${ue_id}    gnb_id=${gnb_id}
    ...    cell_id=${cell_id}    bearer_id=${bearer_id}
    ...    profile_id=${profile_id}
    ...    ELSE IF    '${call_type}'=='SA'
    ...    Run Keywords    _${call_type} Attach    ue_id=${ue_id}
    ...    AND
    ...    _AP SA PDU Session Setup    ue_id=${ue_id}    pdu_id=${pdu_id}
    Log To Console    ${output}
    Log To Console    ${call_type}_attach_is_ok
    Sleep    5s    reason=wait ${call_type} attach is stable

Check UE State
    [Arguments]    ${ue_id}=1    ${pass_regexp}=state
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=ue_disp id=${ue_id}    pass_regexp=${pass_regexp}    timeout=60
    ${match}    String.Get Lines Matching Regexp    ${output}    ACTIVE    partial_match=${true}
    ${result}    Split String    ${match}    ${SPACE}
    ${ue_state}    Set Variable    false
    FOR    ${i}    ${item}    IN ENUMERATE    @{result}
        ${ue_state}    Set Variable If    '${item}' == 'ACTIVE'    true    false
        Exit For Loop If    '${item}' == 'ACTIVE'
    END
    [Return]    ${ue_state}


_LTE Attach
    [Arguments]    ${ue_id}    ${profile_id}=1
    Log    ${profile_id} is not used
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=ue_attach id\=${ue_id}    pass_regexp=UE IS ACTIVE    timeout=60
    [Return]    ${output}

_NSA Attach
    [Arguments]    ${ue_id}    ${gnb_id}    ${cell_id}    ${bearer_id}    ${profile_id}=1
    _LTE Attach    ue_id=${ue_id}    profile_id=${profile_id}
    _5G Attach    ue_id=${ue_id}    gnb_id=${gnb_id}    cell_id=${cell_id}
    ...    bearer_id=${bearer_id}

_5G Attach
    [Arguments]    ${ue_id}    ${gnb_id}    ${cell_id}    ${bearer_id}
    ${output}=    ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=ue_dc_enb_start ue\=${ue_id} target_gnb\=${gnb_id} target_cells\=${cell_id} bearer\=${bearer_id} type\=split_scg
    ...    pass_regexp=reported successful RA|Proxy reported failure    timeout=60
    ${ret}=    Run Keyword And Return Status    Should Contain    ${output}    reported successful RA
    Run Keyword If    "${ret}"=="${False}"    Fail    NSA 5G Attach fails!!!
    [Return]    ${output}

_SA Attach
    [Arguments]    ${ue_id}
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=ue_register id=${ue_id}    pass_regexp=Received REGISTRATION COMPLETE from UE with RAN UE NGAP ID    timeout=60s
    ${ret}=    Run Keyword And Return Status    Should Contain    ${output}    REGISTRATION COMPLETE
    Run Keyword If    "${ret}"=="${False}"    Fail    SA 5G Attach fails!!!
    ${output1}    String.Get Lines Matching Regexp    ${output}    REGISTRATION COMPLETE    partial_match=${true}
    Should Match Regexp    ${output}    Initial UE Message .*Success
    [Return]    ${output}

_AP SA PDU Session Setup
    [Arguments]    ${ue_id}=${1}    ${pdu_id}=${1}    ${trf_type}=internal    ${pass_regexp}=Initial Context Setup Successful
    ute_wtssim.Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=${trf_type}
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=ue_pdu_session_setup pdu=${pdu_id} ue=${ue_id} nwslice\=1 gw\=${ue_id}
    ...    pass_regexp=${pass_regexp}
    ...    timeout=3minutes
    ${output}    String.Get Lines Matching Regexp    ${output}
    ...    Initial Context Setup Successful    partial_match=${true}
    Log To Console    ${output}
    [Return]    ${output}

Module AP Detach
    [Arguments]    ${traffic_info_dic}
    ${call_type}    Set Variable    ${traffic_info_dic['call_type']}
    ${ue_id}    Set Variable    ${traffic_info_dic['ue_id']}
    ${call_type}    Convert To Upper Case    ${call_type}
    Run Keyword If    '${call_type}'=='NSA'
    ...    ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=ue_detach id\=${ue_id}    pass_regexp=detached
    ...    timeout=3minutes
    ...    ELSE
    ...    ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=ue_deregister id\=${ue_id} ue_deregister_type\=switch_off
    ...    pass_regexp=UE Context Release Complete
    ...    timeout=3minutes

Module AP Start Traffic
    [Arguments]    ${traffic_info_dic}
    ${call_type}    Set Variable    ${traffic_info_dic['call_type']}
    ${ue_id}    Set Variable    ${traffic_info_dic['ue_id']}
    ${bearer_id}    Set Variable    ${traffic_info_dic['bearer_id']}
    ${dir}    Set Variable    ${traffic_info_dic['dir']}
    ${pdu_id}    Set Variable    ${traffic_info_dic['pdu_id']}
    ${time_len}    Set Variable    ${traffic_info_dic['time_len']}
    ${trf_id}    Set Variable    ${traffic_info_dic['trf_id']}
    ${qfi_id}    Set Variable    ${traffic_info_dic['qfi_id']}
    ${time}    Set Variable    ${traffic_info_dic['time']}
    ${profile_id}    Set Variable    ${traffic_info_dic['profile_id']}
    ${gnb_id}    Set Variable    ${traffic_info_dic['gnb_id']}
    ${cell_id}    Set Variable    ${traffic_info_dic['cell_id']}
    ${type}    Set Variable    ${traffic_info_dic['type']}
    ${protocol}    Set Variable    ${traffic_info_dic['protocol']}
    Run Keyword If    '${dir}'=='dl'     Set Test Variable    ${mbps}    ${traffic_info_dic['mbps_dl']}
    ...    ELSE IF    '${dir}'=='ul'     Set Test Variable    ${mbps}    ${traffic_info_dic['mbps_ul']}
    ...    ELSE IF    '${dir}'=='uldl' or '${dir}'=='dlul'    Run Keywords
    ...                 Set Test Variable    ${mbps_dl}    ${traffic_info_dic['mbps_dl']}    AND
    ...                 Set Test Variable    ${mbps_ul}    ${traffic_info_dic['mbps_ul']}
    ${call_type}    Convert To Upper Case    ${call_type}
    ${ue_state}    Check UE State
    Run Keyword If    "${ue_state}"=="false"    _AP Attach    call_type=${call_type}    ue_id=${ue_id}    pdu_id=${pdu_id}    profile_id=${profile_id}
    ...           gnb_id=${gnb_id}    cell_id=${cell_id}    bearer_id=${bearer_id}
    ${Tput_dict}    Run Keyword If    '${dir}'=='dl' or '${dir}'=='ul'    Module Start DL or UL Traffic
    ...                               mbps=${mbps}    ue_id=${ue_id}    bearer_id=${bearer_id}
    ...                               trf_id=${trf_id}    qfi_id=${qfi_id}    type=${type}
    ...                               during=${time}    call_type=${call_type}    pdu_id=${pdu_id}    dir=${dir}
    ...                               protocol=${protocol}
    ...     ELSE IF    '${dir}'=='uldl' or '${dir}'=='dlul'    _Module Start DLUL Traffic    ue_id=${ue_id}
        ...            mbps_dl=${mbps_dl}
        ...            mbps_ul=${mbps_ul}
        ...            bearer_id=${bearer_id}
        ...            trf_id=${trf_id}
        ...            during=${time}
        ...            call_type=${call_type}
        ...            qfi_id=${qfi_id}
        ...            pdu_id=${pdu_id}
        ...            type=${type}
        ...            protocol=${protocol}
    Set Test Variable    ${Tput_dict}
    [Return]    ${Tput_dict}


Module Start DL or UL Traffic
    [Arguments]    ${mbps}    ${ue_id}    ${bearer_id}    ${type}    ${trf_id}=1    ${qfi_id}=1
    ...    ${during}=9999    ${call_type}=NSA    ${pdu_id}=1    ${dir}=dl    ${protocol}=udp
    &{Tput_dict}=    Create dictionary
    ${tputvalue_unit}    Run Keyword If    'm' in '${mbps}'    Set Variable    m
    ...    ELSE IF    'k' in '${mbps}'
    ...    Set Variable    k
    ...    ELSE    Set Variable    m
    ${tput_value}    Get Regexp Matches    ${mbps}    \\d+
    ${dir_upper}    Convert To Upper Case    ${dir}
    Run Keyword     _Module Start ${dir_upper} Traffic
    ...    ue_id=${ue_id}    bearer_id=${bearer_id}    tput_value=${tput_value}[0]
    ...    trf_id=${trf_id}
    ...    unit=${tputvalue_unit}
    ...    during=${during}
    ...    call_type=${call_type}
    ...    qfi_id=${qfi_id}
    ...    pdu_id=${pdu_id}
    ...    type=${type}
    ...    protocol=${protocol}
    Sleep    10s    reason=wait ${dir_upper} traffic is stable
    ${dir}    Convert To Lowercase    ${dir}
    ${max_tput}    ${ave_tput}    ${min_tput}    Module AP Get Average Throughput    ue_id=${ue_id}   bearer_id=${bearer_id}
    ...                                                  qfi=${qfi_id}    dir=${dir}    trf_id=${trf_id}    type=${type}
    ...                                                  call_type=${call_type}    pdu_id=${pdu_id}
    Set to Dictionary    ${Tput_dict}    ${dir}_max_tput    ${max_tput}
    Set to Dictionary    ${Tput_dict}    ${dir}_ave_tput    ${ave_tput}
    Set to Dictionary    ${Tput_dict}    ${dir}_min_tput    ${min_tput}
    [Return]     ${Tput_dict}

_get traffic cmd
    [Arguments]     ${ue_id}=1    ${bearer_id}=2    ${dir}=dl    ${pdu_id}=1
    ...    ${trf_id}=1    ${mbps}=5    ${qfi_id}=1    ${call_type}=SA    ${protocol}=udp
    ${NSA_traffic_cmd}   Catenate    trf_data_start ue=${ue_id} id=${bearer_id} dir=${dir} mbps=${mbps} trf_id=${trf_id} protocol=${protocol}
    ${SA_traffic_cmd}  Catenate   trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=${dir} mbps=${mbps} trf_id=${trf_id} protocol=${protocol}
    ${traffic_cmd}   set variable if  '${call_type}'=='NSA'    ${NSA_traffic_cmd}    ${SA_traffic_cmd}
    [Return]    ${traffic_cmd}

_Module Start DLUL Traffic
    [Arguments]    ${mbps_dl}    ${mbps_ul}    ${ue_id}    ${bearer_id}    ${type}    ${trf_id}=1    ${qfi_id}=1
    ...             ${during}=9999    ${call_type}=NSA    ${pdu_id}=1     ${protocol}=udp
    &{Tput_dict}=    Create dictionary
    ${tputvalue_unit_dl}    Run Keyword If    'm' in '${mbps_dl}'    Set Variable    m
    ...    ELSE IF    'k' in '${mbps_dl}'
    ...    Set Variable    k
    ...    ELSE    Set Variable    m
    ${tput_value_dl}    Get Regexp Matches    ${mbps_dl}    \\d+
    ${tput_value_ul}    Get Regexp Matches    ${mbps_ul}    \\d+
    _Module Start UL Traffic    ue_id=${ue_id}    pdu_id=${pdu_id}    qfi_id=${qfi_id}
    ...                        type=${type}    tput_value=${tput_value_ul}[0]    during=${during}    bearer_id=${bearer_id}    trf_id=${trf_id}
    ...                        call_type=${call_type}    protocol=${protocol}
    _Module Start DL Traffic    ue_id=${ue_id}    bearer_id=${bearer_id}    tput_value=${tput_value_dl}[0]
    ...                         trf_id=${trf_id}    qfi_id=${qfi_id}    unit=${tputvalue_unit_dl}    type=${type}
    ...                         during=${during}    call_type=${call_type}    pdu_id=${pdu_id}    protocol=${protocol}
    Sleep    10s    reason=wait traffic is stable
    ${max_tput_ul}    ${ave_tput_ul}    ${min_tput_ul}    Module AP Get Average Throughput    ue_id=${ue_id}   bearer_id=${bearer_id}
    ...                                                  qfi=${qfi_id}    dir=ul    trf_id=${trf_id}    type=${type}
    ...                                                  call_type=${call_type}    pdu_id=${pdu_id}
    ${max_tput_dl}    ${ave_tput_dl}    ${min_tput_dl}    Module AP Get Average Throughput    ue_id=${ue_id}   bearer_id=${bearer_id}
    ...                                                  qfi=${qfi_id}    dir=dl    trf_id=${trf_id}    type=${type}
    ...                                                  call_type=${call_type}    pdu_id=${pdu_id}
    Set to Dictionary    ${Tput_dict}    ul_max_tput    ${max_tput_ul}
    Set to Dictionary    ${Tput_dict}    ul_ave_tput    ${ave_tput_ul}
    Set to Dictionary    ${Tput_dict}    ul_min_tput    ${min_tput_ul}
    Set to Dictionary    ${Tput_dict}    dl_max_tput    ${max_tput_dl}
    Set to Dictionary    ${Tput_dict}    dl_ave_tput    ${ave_tput_dl}
    Set to Dictionary    ${Tput_dict}    dl_min_tput    ${min_tput_dl}
    [Return]     ${Tput_dict}



_Module Start DL Traffic
    [Arguments]    ${ue_id}    ${bearer_id}    ${tput_value}    ${type}    ${trf_id}=1    ${qfi_id}=1
    ...    ${unit}=m    ${during}=9999    ${call_type}=NSA    ${pdu_id}=1    ${protocol}=udp
    Log    ${type} is not used
    ${dl_times}    Run Keyword if    '${unit}'=='m'     Evaluate    int(${tput_value}/${175})
    ...    ELSE    Set Variable     ${0}
    FOR    ${t_time}    IN RANGE    1    ${dl_times}+1
        ${tmp_trf_id}    Evaluate    int(${trf_id})+${t_time}-1
        ${cmd}     _get traffic cmd    ue_id=${ue_id}
        ...     bearer_id=${bearer_id}
        ...     dir=dl
        ...     pdu_id=${pdu_id}
        ...     trf_id=${tmp_trf_id}
        ...     mbps=175
        ...     qfi_id=${qfi_id}
        ...     call_type=${call_type}
        ...     protocol=${protocol}
        ute_wtssim.Execute Egate Command And Wait For Data
        ...    cmd=${cmd} seconds\=${during}
        ...    pass_regexp=Internal traffic Receiver on Ue
        ...    timeout=60
        Log To Console    \nUE${ue_id} Start DL 175M Traffic for trf_id=${tmp_trf_id}
    END
    ${last_tput_value}    Evaluate    ${tput_value}%${175}
    ${last_trf_id}    Evaluate    ${trf_id}+${dl_times}
    ${cmd}     _get traffic cmd    ue_id=${ue_id}
        ...     bearer_id=${bearer_id}
        ...     dir=dl
        ...     pdu_id=${pdu_id}
        ...     trf_id=${last_trf_id}
        ...     mbps=${last_tput_value}
        ...     qfi_id=${qfi_id}
        ...     call_type=${call_type}
        ...     protocol=${protocol}
    Run Keyword If    '${last_tput_value}'!='0'    ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=${cmd} seconds\=${during}
    ...    pass_regexp=Internal traffic Receiver on Ue
    ...    timeout=60
    Run Keyword If    '${last_tput_value}'!='0'    Log To Console
    ...    \nUE${ue_id} Start DL ${last_tput_value}${unit} Traffic for trf_id=${last_trf_id}

_Module Start UL Traffic
    [Arguments]    ${ue_id}    ${pdu_id}    ${qfi_id}    ${type}    ${bearer_id}    ${trf_id}    ${call_type}
    ...            ${dir}=ul    ${tput_value}=1    ${during}=100    ${protocol}=udp    &{kwargs}
    Log To Console    start UL traffic...
    Log    ${type} and ${bearer_id} and ${trf_id} and ${call_type} is not used
    ${cmd}    Catenate    ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=${dir} mbps=${tput_value} protocol=${protocol}
    ute_wtssim.Execute Egate Command And Wait For Data
        ...    cmd=trf_data_start ${cmd} seconds\=${during}
        ...    pass_regexp=Internal traffic Receiver on Ue
        ...    timeout=60

Module AP Stop Traffic
    [Arguments]    ${traffic_info_dic}
    ${ue_id}    Set Variable    ${traffic_info_dic['ue_id']}
    ${bearer_id}    Set Variable    ${traffic_info_dic['bearer_id']}
    ${dir}    Set Variable    ${traffic_info_dic['dir']}
    ${trf_id}    Set Variable    ${traffic_info_dic['trf_id']}
    Log To Console    stop ${dir} traffic...\n
    ${dir}    set variable if    '${dir}'=='dlul' or '${dir}'=='uldl'   bi    ${dir}
    Run Keyword If    '${dir}'=='bi'    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_stop ue\=${ue_id} id\=${bearer_id} dir\=${dir}
    ...    ELSE    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_stop ue\=${ue_id} id\=${bearer_id} dir\=${dir} trf_id\=${trf_id}

Module AP Get Average Throughput
    [Arguments]    ${ue_id}=1    ${bearer_id}=2    ${qfi}=1    ${dir}=dl
    ...            ${trf_id}=2    ${type}=l3    ${call_type}=SA    ${pdu_id}=1
    ${dir}   set variable if  '${dir}'=='dlul' or '${dir}'=='uldl'    bi    ${dir}
    ${NSA_cmd}    Catenate    bearer_stats ue\=${ue_id} id\=${bearer_id} dir\=${dir} trf_id\=${trf_id} type\=${type}
    ${SA_cmd}    Catenate    bearer_stats ue\=${ue_id} pdu\=${pdu_id} qfi\=${qfi} dir\=${dir} dc_cell_group=all
    ${cmd}   set variable if  '${call_type}'=='NSA'    ${NSA_cmd}    ${SA_cmd}
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    cmd=${cmd}
    ...                                                                pass_regexp=Maximum packet interval
    ${match}   ${max_tput}=   Should Match Regexp   ${output}   Maximum data rate +(\\d+) .+\\r
    ${match}   ${ave_tput}=   Should Match Regexp   ${output}   Average data rate +(\\d+) .+\\r
    ${match}   ${min_tput}=   Should Match Regexp   ${output}   Minimum data rate +(\\d+) .+\\r
    ${max_tput}    Evaluate    ${max_tput}/1000/1000
    ${max_tput} =    Convert To Integer    ${max_tput}
    ${ave_tput}    Evaluate    ${ave_tput}/1000/1000
    ${ave_tput} =    Convert To Integer    ${ave_tput}
    ${min_tput}    Evaluate    ${min_tput}/1000/1000
    ${min_tput} =    Convert To Integer    ${min_tput}
    [Return]    ${max_tput}    ${ave_tput}    ${min_tput}

Check Traffic Tput
    [Arguments]    ${traffic_info_dic}
    ${call_type}    Set Variable    ${traffic_info_dic['call_type']}
    ${ue_id}    Set Variable    ${traffic_info_dic['ue_id']}
    ${bearer_id}    Set Variable    ${traffic_info_dic['bearer_id']}
    ${dir}    Set Variable    ${traffic_info_dic['dir']}
    ${pdu_id}    Set Variable    ${traffic_info_dic['pdu_id']}
    ${time_len}    Set Variable    ${traffic_info_dic['time_len']}
    ${trf_id}    Set Variable    ${traffic_info_dic['trf_id']}
    ${qfi_id}    Set Variable    ${traffic_info_dic['qfi_id']}
    ${time}    Set Variable    ${traffic_info_dic['time']}
    ${profile_id}    Set Variable    ${traffic_info_dic['profile_id']}
    ${gnb_id}    Set Variable    ${traffic_info_dic['gnb_id']}
    ${cell_id}    Set Variable    ${traffic_info_dic['cell_id']}
    ${type}    Set Variable    ${traffic_info_dic['type']}
    ${protocol}    Set Variable    ${traffic_info_dic['protocol']}
    Run Keyword If    '${dir}'=='dl'     Set Test Variable    ${mbps}    ${traffic_info_dic['mbps_dl']}
    ...    ELSE IF    '${dir}'=='ul'     Set Test Variable    ${mbps}    ${traffic_info_dic['mbps_ul']}
    ...    ELSE IF    '${dir}'=='uldl' or '${dir}'=='dlul'    Run Keywords
    ...                 Set Test Variable    ${mbps_dl}    ${traffic_info_dic['mbps_dl']}    AND
    ...                 Set Test Variable    ${mbps_ul}    ${traffic_info_dic['mbps_ul']}
    ${call_type}    Convert To Upper Case    ${call_type}
    ${Tput_dict}    Run Keyword If   '${dir}'=='dl' or '${dir}'=='ul'    Get DL Or UL Traffic Tput    ue_id=${ue_id}   bearer_id=${bearer_id}
    ...                                                  qfi_id=${qfi_id}    dir=${dir}    trf_id=${trf_id}    type=${type}
    ...                                                  call_type=${call_type}    pdu_id=${pdu_id}
    ...    ELSE IF    '${dir}'=='uldl' or '${dir}'=='dlul'    Get DL And UL Traffic Tput    ue_id=${ue_id}   bearer_id=${bearer_id}
    ...                                                  qfi_id=${qfi_id}    trf_id=${trf_id}    type=${type}
    ...                                                  call_type=${call_type}    pdu_id=${pdu_id}
    [Return]     ${Tput_dict}

Get DL Or UL Traffic Tput
    [Arguments]      ${ue_id}=1    ${bearer_id}=2    ${qfi_id}=1    ${dir}=dl
    ...              ${trf_id}=2    ${type}=l3    ${call_type}=SA    ${pdu_id}=1
    ${max_tput}    ${ave_tput}    ${min_tput}    Module AP Get Average Throughput    ue_id=${ue_id}   bearer_id=${bearer_id}
    ...                                                  qfi=${qfi_id}    dir=${dir}    trf_id=${trf_id}    type=${type}
    ...                                                  call_type=${call_type}    pdu_id=${pdu_id}
    Set to Dictionary    ${Tput_dict}    ${dir}_max_tput    ${max_tput}
    Set to Dictionary    ${Tput_dict}    ${dir}_ave_tput    ${ave_tput}
    Set to Dictionary    ${Tput_dict}    ${dir}_min_tput    ${min_tput}
    [Return]     ${Tput_dict}

Get DL And UL Traffic Tput
    [Arguments]      ${ue_id}=1    ${bearer_id}=2    ${qfi_id}=1
    ...              ${trf_id}=2    ${type}=l3    ${call_type}=SA    ${pdu_id}=1
    ${max_tput_ul}    ${ave_tput_ul}    ${min_tput_ul}    Module AP Get Average Throughput    ue_id=${ue_id}   bearer_id=${bearer_id}
    ...                                                  qfi=${qfi_id}    dir=ul    trf_id=${trf_id}    type=${type}
    ...                                                  call_type=${call_type}    pdu_id=${pdu_id}
    ${max_tput_dl}    ${ave_tput_dl}    ${min_tput_dl}    Module AP Get Average Throughput    ue_id=${ue_id}   bearer_id=${bearer_id}
    ...                                                  qfi=${qfi_id}    dir=dl    trf_id=${trf_id}    type=${type}
    ...                                                  call_type=${call_type}    pdu_id=${pdu_id}
    Set to Dictionary    ${Tput_dict}    ul_max_tput    ${max_tput_ul}
    Set to Dictionary    ${Tput_dict}    ul_ave_tput    ${ave_tput_ul}
    Set to Dictionary    ${Tput_dict}    ul_min_tput    ${min_tput_ul}
    Set to Dictionary    ${Tput_dict}    dl_max_tput    ${max_tput_dl}
    Set to Dictionary    ${Tput_dict}    dl_ave_tput    ${ave_tput_dl}
    Set to Dictionary    ${Tput_dict}    dl_min_tput    ${min_tput_dl}
    [Return]     ${Tput_dict}



Module Send AP Common Command
    [Arguments]    ${cmd}    ${pass_regexp}
    ${output}    Run Keyword If    '${pass_regexp}' != '${None}'    ute_wtssim.Execute Egate Command And Wait For Data
    ...          cmd=${cmd}    pass_regexp=${pass_regexp}    timeout=3minutes
    ...    ELSE    ute_wtssim.Execute Egate Command    cmd=${cmd}
    [Return]    ${output}

Module Collect AP Logs
    ${dire}    setup_module_directory    module_name=Airphone_Operation
    Set Test Variable    ${AP_LOG_DIRECTORY}    ${dire}
    airphone_collect_egate_log_files      ${AP_LOG_DIRECTORY}   unzip=TRUE
    Run Keyword And Ignore Error    Module Collect SOS Log


Module Collect SOS Log
    ${output}    OperatingSystem.Run    cd /opt/wts/latest/ && /bin/bash sosReport_ASIK_ASIL.sh -c -s
    ${match}    String.Get Lines Matching Regexp    ${output}    SosReport    partial_match=${true}
    ${sos_file_name}    Split String    ${match.split()[1].split(',')[-1]}    /
    OperatingSystem.Run    cp /opt/wts/latest/${sos_file_name[-1]} ${AP_LOG_DIRECTORY}


Module Local AP Upgrade
    [Arguments]    ${eth_config_path}    ${ap_build}=${None}
    [Documentation]    This kw is used for upgrade local ap
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
     ...    | Input Parameters | Man. | Description |
    ...    | eth_config_path | input eth config file path|
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Module Local AP Upgrade |
    ...
    ${ap_build_name}    Run Keyword If    '${ap_build}'!='None'    Set Variable    ${ap_build}
    ...    ELSE IF    '${ap_build}'=='None'    Module Get AP Build Name From UTE Cloud
    local_ap_update.sw_update    ap_build=${ap_build_name}
    Config Eth Interface    eth_config_path=${eth_config_path}

Module Get AP Build Name From UTE Cloud
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
    ...    | Get AP Build Name From UTE Cloud |
    ...
    ${key_list}    Create List    CM_ARTIFACTS    4    name
    ${ap_build_Name}    Module Get Info From UTE Reservation File    key_list=${key_list}
    Set Variable    ${ap_build_Name}
    Log to Console    \n***AP build Name ${ap_build_Name}***
    ${ap_build_Name_list}    Split String    ${ap_build_Name}    _
    Set Suite Variable    ${AP_BUILD_NAME}    ${ap_build_Name_list[-1]}
    [Return]    ${AP_BUILD_NAME}

Config Eth Interface
    [Arguments]    ${eth_config_path}
    ${context}    OperatingSystem.Get File    ${eth_config_path}
    ${eth_list}    json.Loads    ${context}
    ${eth_list_lenth}    Get Length    ${eth_list}
    FOR   ${index}    IN RANGE    ${eth_list_lenth}
        OperatingSystem.Run    ${eth_list[${index}]}
    END

Get RJIO Cell Id
    [Arguments]    ${tag}=${None}    ${customer}=${None}
    ${remove_cell_list}    Create List
    @{customer_list}    Split String    ${customer}    _   1
    ${default_iphy}    join path    /home/ute/.ute-ca/executions/1/configs/topology_configs/node_1    ${customer_list[-1]}/iphy.xml
    Log to Console    \n******config iphy******\n
    ${result}    Run Keyword If    '${tag}'!='None'   Get Iphy File    tag=${tag}
    ...          ELSE IF    '${tag}'=='None'    iphy_modify.get_mplane_only_and_cell_value    xml_file=${default_iphy}
    FOR    ${item}    IN    @{result}
        ${parts}    Split String    ${item}    .
        ${cell_id}    Set Variable    ${parts[-1]}
        Append To List    ${remove_cell_list}    ${cell_id}
    END
    [Return]    ${remove_cell_list}

Get Iphy File
    [Arguments]    ${tag}=${None}
    ${all_config_file_dic}    _Get All Config File path    tag=${tag}
    Set Variable    ${all_config_file_dic}
    ${iphy_file_path_exist}    Run Keyword And Return Status    OperatingSystem.File Should Exist    ${all_config_file_dic['iphy']}
    ${result}    Run Keyword If   ${iphy_file_path_exist}    iphy_modify.get_mplane_only_and_cell_value    xml_file=${all_config_file_dic['iphy']}
    ...    ELSE IF    "${iphy_file_path_exist}" == "false"    Fail    iphy file not exist
    [Return]    ${result}

Get cell list for Customer
    [Arguments]    ${tag}    ${customer}    ${alias}=default
    ${cell_id_list}=    tak_ap.Airphone Get Cell Id List    alias=${alias}
    ${remove_cell_list}   Get RJIO Cell Id    tag=${tag}    customer=${customer}
    FOR    ${item}    IN    @{remove_cell_list}
        Remove Values From List    ${cell_id_list}    ${item}
    END
    [Return]    ${cell_id_list}
