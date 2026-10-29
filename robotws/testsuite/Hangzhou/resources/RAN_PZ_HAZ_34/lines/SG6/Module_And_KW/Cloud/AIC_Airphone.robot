*** Settings ***
Documentation
...    Author: winnie he
...    Email address: winnie.he@nokia-sbell.com
...    Maintainer: winnie.he@nokia-sbell.com

Resource          ../Common/Airphone.robot


*** Keywords ***
List Contain No None Value
    [Arguments]    ${list}
    FOR    ${v}    IN    @{list}
        Return From Keyword If    '${v}'!='${None}'    ${True}
    END
    [Return]    ${False}

Get TL Config
    [Arguments]    ${filename}=${None}
    log    ${filename} is not used
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

AIC Configure TL VM ETH IP
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

Change Vlan Id In Iphy xml
    [Documentation]    This keyword is used to vRan iphy.xml modify.
    ...    | Input Parameters | Man. | Description |
    ...    | ${targe_iphy_path} | Yes | the target iphy.xml which need to be modified |
    ...
    ...    Examples:
    ...    | Change Vlan Id In Iphy xml | ${CURDIR}/iphy.xml |
    [Arguments]    ${targe_iphy_path}
    Backup Iphy Xml File    ${TEST_LOG_DIRECTORY}    source_iphy.xml
    ${vlan_id}    tak_xml.read xml    ${TEST_LOG_DIRECTORY}/source_iphy.xml
    ...    text|//preferredVlanId
    ...    return_type=list
    ${uni_id}    evaluate    len(list(set(${vlan_id})))==1
    should be true    ${uni_id}    ${True}
    ${status}    ${msg}     Run Keyword And Ignore Error    OperatingSystem.File Should Exist     ${targe_iphy_path}
    ${base_xml}     Set Variable If    '${status}'=='PASS'    ${targe_iphy_path}
    ...    ${TEST_LOG_DIRECTORY}/source_iphy.xml
    tak_xml.modify xml    ${base_xml}     ${targe_iphy_path}    text|${vlan_id[0]}|//preferredVlanId

Setup Ap Env
    [Arguments]    ${local_wts_dir}
    ...            ${iphy_path}=${None}
    ...            ${scf_file_path}=${None}
    ...            ${gnb_swconfig_local_path}=${None}
    ...            ${ap_swconfig_local_path}=${None}
    ...            ${call_type}=sa
    ...            ${alias}=First_ASIB
    ...            ${index}=0
    ...            ${du_index}=0
    ...            ${expected_status}=Commissioned
    Log    ${gnb_swconfig_local_path} and ${alias} is not used.
    Run Keyword If    Not "_DC" in "${TestLine_type}"    AIC Configure TL VM ETH IP
    Get TL Config     ${TESTLINE_NAME}
    Run Keyword If    '${iphy_path}' != '${None}'
    ...    Run Keyword And Ignore Error    Change Vlan Id In Iphy xml    ${iphy_path}
    ${du_hosting_index}    Evaluate    ${du_index}+1
    Run Keyword If    '${iphy_path}' != '${None}'    change_iphy_rru_version    ${iphy_path}
    ...    enb_ip=${tl.cloud_hostings[${du_hosting_index}].master_node.ssh_connection_details.addr}
    ...    enb_user=${tl.cloud_hostings[${du_hosting_index}].master_node.ssh_connection_details.username}
    ...    enb_pwd=${tl.cloud_hostings[${du_hosting_index}].master_node.ssh_connection_details.password}
    Run Keyword If    '${ap_swconfig_local_path}' != '${None}'    Airphone Replace Swconfig    local_path=${ap_swconfig_local_path}
    ...            remote_path=/ffs/run/swconfig.txt
    ...            alias=asib
    ...            gnb_hostname=192.168.200.129
    ...            gnb_username=${tl.gnbs[${index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...            gnb_password=${tl.gnbs[${index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ${has_valid_vdus_scf}    List Contain No None Value    ${scf_file_path}[vDU]
    Run Keyword Unless    '${has_valid_vdus_scf}'=='${False}' and '${scf_file_path}[vCU]' == '${None}'
    ...    Airphone Modify vlanId and Commissioning Full SCF    scf_file_path=${scf_file_path}
    ...        expected_status=${expected_status}
    ...        index=${index}

    ${local_wts_dir}    Run Keyword If   '${local_wts_dir}'=='${None}'
    ...    Set Variable    /opt/iphy/latest/basic_setup.cfg
    ...    ELSE     Set Variable    ${local_wts_dir}
    Airphone Cfg Configuration    wts_cfg_name=${local_wts_dir}
    ...    cell_type=${call_type}    timeout=2000
    wait until keyword succeeds    10 min    30 sec    Check All Cells On Air In Multiple vCU
    wait until keyword succeeds    10 min    30 sec    vDU Check All Cells Status Should Be Onair
    Airphone Setup X2 Connection    20    1    2

Get Host Name
    ${rc}    ${output}    OperatingSystem.Run And Return Rc And Output    hostname
    [Return]    ${output}

check ping is enabled
    [Arguments]   ${ip}    ${timeout}=60s
    [Documentation]    check unit can be pingable after reset, power off/on and so on
    ...    | Input Parameters | Man. | Description |
    ...    | ${ip} | Yes | host ip which need ping |
    ...    | ${timeout} | No | timeout, default is 60s |
    ...    Examples:
    ...    | check ping is enabled| 192.168.255.1 |
    ${ping}=    run process    ping -c 3 ${ip}    timeout=${timeout}    shell=True
    should contain    ${ping.stdout}    3 received

Airphone Modify vlanId and Commissioning Full SCF
    [Arguments]    ${scf_file_path}=${None}
    ...            ${expected_status}=Commissioned    ${index}=0
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
    Run Keyword If    '${scf_file_path}[vCU]'!='${None}'
    ...    vCU Full Commssion By Rest    path_of_commission_file=${scf_file_path}[vCU]
    ...    plan_name=ap_init
    FOR    ${i}    ${scf_path}    IN ENUMERATE    @{scf_file_path['vDU']}
        Continue For Loop If     '${scf_path}'=='${None}'
        ${scf_path}    Run Keyword If    "_DC" in "${TESTLINE_TYPE}"
        ...    Change VDU TLconfig In Scf    ${VDU_RANNIC1_SERIAL_NUMBER}    ${VDU_RANNIC1_PRODUCT_CODE}
        ...    ${scf_path}
        ...    ELSE    Modify vLanid For One vDU    index=${index}
        ...    du_index=${i}
        ...    parameter=vlanId
        ...    scf_file=${scf_path}
        vDU Update Full SCF By Rest    scf_path=${scf_path}
    END
    Reboot AP Via Ssh
    Wait Until Keyword Succeeds    10 min    10 sec     Verify RMODs availability status is 'on line'   gnb_index=${index}
    Wait until keyword succeeds    10 min  10 sec    F1 link should be available

Verify RMODs availability status is 'on line'
    [Arguments]    ${vdu_index}=0    ${gnb_index}=0
    vDU Login By Rest    vdu_index=${vdu_index}    gnb_index=${gnb_index}    alias=vdu_admin
    ${rmods_statuses}    vdu.Get RMODs status    vdu_connection=vdu_admin
    FOR    ${status}    IN    @{rmods_statuses}
        Dictionary should contain item    ${status}    availability_status    on line    msg=RMOD status is not \'on line\':${\n}${status}
    END
    [Teardown]  vDU Logout By Rest    vdu_index=${vdu_index}    alias=vdu_admin

check ping is disabled
    [Arguments]   ${ip}    ${timeout}=60s
    [Documentation]    check unit cannot be pingable after reset, power off/on and so on
    ...    | Input Parameters | Man. | Description |
    ...    | ${ip} | Yes | host ip which need ping |
    ...    | ${timeout} | No | timeout, default is 60s |
    ...    Examples:
    ...    | check ping is disabled | 192.168.255.1 |
    ${ping}=    run process    ping -c 3 ${ip}    timeout=${timeout}    shell=True
    should contain    ${ping.stdout}    100% packet loss

Reboot AP Via Ssh
    Log To Console    -------- Reboot AP via ssh --------
    OperatingSystem.Run And Return Rc And Output
    ...    sshpass -p ${AP_ASIK.password} ssh ${AP_ASIK.username}@${AP_ASIK.ip} 'reboot'
    Wait Until Keyword Succeeds    240s    5s    check ping is disabled    ${AP_ASIK.ip}
    Wait Until Keyword Succeeds    240s    5s    check ping is enabled    ${AP_ASIK.ip}

F1 link should be available
    Login To vCU By Rest    alias=cu_admin
    ${du_state}    cu.get_du_state    connection=cu_admin
    Should be equal    ${du_state}[f1_link_status][available]    ${1}
    Log to console    CU: F1 link is available
    [Teardown]    Logout To vCU By Rest    connection=cu_admin

Modify vLanid For One vDU
    [Arguments]    ${index}=0
    ...            ${du_index}=0
    ...            ${parameter}=vlanId
    ...            ${scf_file}=${None}
    [Documentation]    Author: He winnie
    ...                Contact: winnie.he@nokia-sbell.com
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
    [Return]    ${scf_file}
