*** Settings ***
Documentation
...    Author: winnie he
...    Email address: winnie.he@nokia-sbell.com
...    Maintainer: winnie.he@nokia-sbell.com

Resource          ../Common/Airphone.robot

*** Keywords ***
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
    Log    ${alias} is not used
    Airphone Set Iphy Ip
    Run Keyword If    '${iphy_path}' != '${None}'    change_iphy_rru_version    ${iphy_path}
    Run Keyword If    '${gnb_swconfig_local_path}' != '${None}'    Airphone Replace Swconfig    local_path=${gnb_swconfig_local_path}
    ...            remote_path=/ffs/run/swconfig.txt
    ...            alias=asib
    ...            gnb_hostname=${tl.gnbs[${index}].dus[${du_index}].airscale.common_units[0].lmp_connection.addr}
    ...            gnb_username=${tl.gnbs[${index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...            gnb_password=${tl.gnbs[${index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    Run Keyword If    '${ap_swconfig_local_path}' != '${None}'    Airphone Replace Swconfig    local_path=${ap_swconfig_local_path}
    ...            remote_path=/ffs/run/swconfig.txt
    ...            alias=asib
    ...            gnb_hostname=192.168.200.129
    ...            gnb_username=${tl.gnbs[${index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...            gnb_password=${tl.gnbs[${index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    Run Keyword If    '${scf_file_path}' != '${None}'
    ...    Airphone Modify vlanId and Commissioning Full SCF    scf_file_path=${scf_file_path}
    ...    expected_status=${expected_status}
    ...    index=${index}
    ${local_wts_dir}    Run Keyword If   '${local_wts_dir}'=='${None}'
    ...    Set Variable    /opt/iphy/latest/basic_setup.cfg
    ...    ELSE     Set Variable    ${local_wts_dir}
    Airphone Cfg Configuration    wts_cfg_name=${local_wts_dir}
    ...    cell_type=${call_type}
    Sleep    30s
    Wait Until Keyword Succeeds    4x    30s     Verify bts and all cell status should be onair

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
    Run Keyword And Ignore Error    Modify vLanid by SCF    index=${index}
    ...                     new_value=${tl.gnbs[${index}].cu.x2c.vlan_id}
    ...                     dist_name=MRBTS-1/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-1
    ...                     parameter=vlanId
    ...                     scf_file=${scf_file_path}
    Run Keyword And Ignore Error    Modify vLanid by SCF    index=${index}
    ...                     new_value=${tl.test_pc.default_ssh_connection_details.addr}
    ...                     dist_name=MRBTS-1/MNL-1/TCEADM-1/TCE-1
    ...                     parameter=tceIpAddress
    ...                     scf_file=${scf_file_path}
    Airphone Commissioning Full SCF    scf_file=${scf_file_path}
    ...    expected_status=${expected_status}

Airphone Verify bts and all cell status should be onair
    [Arguments]    ${connection}=COAM    ${bts_type}=SA
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                Verify all the LTE and 5G cells status should be correct.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${connection} | No | The alias for this connection, default is COAM |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | Airphone Verify bts and all cell status should be onair |  |
    ...    | Airphone Verify bts and all cell status should be onair | connection=coam_conn |
    ...
    Log    ${bts_type} is not used
    COAM_Admin.Login
    ${bts_status}    coam.get_bts_statuses    timeout=20    connection=${connection}
    ${status}    Set Variable    ${bts_status['proceduralState']}
    Should Contain    ${status}    OnAir
    Run Keyword If    '${call_type}'=='NSA'    Run Keyword    Verify LTE cells should be onair  and  Verify 5G cells should be onair
    ...         ELSE IF    '${call_type}'=='SA'    Run Keyword    Verify 5G cells should be onair
    [Teardown]    Run Keyword And Ignore Error    COAM_Admin.Logout

Airphone Verify bts status
    [Arguments]    ${connection}=COAM    ${call_type}=SA    ${expected_status}=OnAir
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                Verify bts status should be correct.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${connection} | No | The alias for this connection, default is COAM |
    ...    | ${expected_status} | No | set expected bts status after upload SCF|
    ...    | ${call_type} | No | which call you want to use |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | Airphone Verify bts status | connection=COAM | expected_status=OnAir |
    ...
    COAM_Admin.Login
    ${bts_status}    coam.get_bts_statuses    timeout=20    connection=${connection}
    ${status}    Set Variable    ${bts_status['proceduralState']}
    Should Contain    ${status}    ${expected_status}
    [Teardown]    Run Keyword And Ignore Error    COAM_Admin.Logout

Airphone Commissioning Full SCF
    [Arguments]    ${scf_file}    ${timeout}=${600}    ${connection}=COAM    ${call_type}=SA    ${expected_status}=Configured
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
    ...    |  Airphone Commissioning Full SCF  |  scf_file=${CURDIR}/ ../{SUITE_NAME}/full_scf.xml  |
    ...
    Wait Until Keyword Succeeds    3x    1min    COAM_Admin.Login
    coam.perform_commissioning    scf_file=${scf_file}
    ...                           skip_parameter_relation_errors=True
    ...                           should_activate=${true}
    ...                           timeout=${timeout}
    ...                           connection=${connection}
    Wait Until Keyword Succeeds    30 min    10 sec    Airphone Verify bts status    call_type=${call_type}
    ...                                                                             expected_status=${expected_status}
    Wait Until RRU Configured    timeout=10 min
    [Teardown]    Run Keyword And Ignore Error    COAM_Admin.Logout

