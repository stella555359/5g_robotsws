*** Settings ***
Documentation    Suite description
Library           taf.transport.ssh    WITH NAME    ssh
Library           taf.sbts.oam.coam.admin                 WITH NAME   admin
#Resource          ../../../../../resources/sites/Ulm/Common/connect.robot

*** Keywords ***
perform muti object recommissioning
    [Arguments]   ${dist_name}    ${parameter}   ${operation}=create   ${skip_parameter_relation_errors}=${True}
    ...    ${should_activate}=${True}    ${connection}=GNB_OAM
    admin.perform_object_recommissioning
    ...      dist_name=${dist_name}
    ...      parameter=${parameter}
    ...      operation=${operation}
    ...      skip_parameter_relation_errors= ${skip_parameter_relation_errors}
    ...      should_activate=${should_activate}
    ...      connection=${connection}


perform muti Parameter recommissioning
    [Arguments]   ${dist_name}    ${parameter}   ${value}     ${operation}=update    ${connection}=GNB_OAM
    ...    ${skip_parameter_relation_errors}=${True}     ${should_activate}=${True}
    admin.Perform Parameter Recommissioning
    ...    dist_name=${dist_name}
    ...    parameter=${parameter}
    ...    value=${value}
    ...    operation=${operation}
    ...    skip_parameter_relation_errors=${skip_parameter_relation_errors}
    ...    should_activate=${should_activate}
    ...    connection=${connection}


Download trs tpl events log with ssh
    [Arguments]    ${remote_path}=/tmp/trs_tpl_events.log      ${local_path}=${output_dir}/trs_tpl_events.log
   ${alias_gnb_common_unit}=  Connect to gNB Common Unit   gnb_id=${0}  du_id=${0}  comu_id=${0}
    ...  alias=common_unit_extract_eqid
    ssh.download_file      remote_path=${remote_path}      local_path=${local_path}    connection=${alias_gnb_common_unit}
    ssh.disconnect    connection=${alias_gnb_common_unit}
    [Return]   ${local_path}

Connect to gNB Common Unit
    [Documentation]    :Author: Soenke Kullberg
    ...     setup ssh connection to Airscale (ASXX) and returns connection handle/alias
    ...     :param gnb_id:         Id of gnb                       [0.. ]  default=0
    ...     :param du_id:          Id of DU                        [0.. ]  default=0
    ...     :param comu_id:        Id of Common Unit               [0..1]  default=0
    ...     :param alias:       (optional) connection alias  !! should not be used
    ...     :returns alias:     alias for ssh connection to Common Unit
    ...     **Example:**
    ...     | ${asxx_alias}=   connect.Connect to gNB Common Unit    gnb_id=0  du_id=0  comu_id=0
    ...     | ssh.execute     command=uptime  connection=${asxx_alias}
    [Arguments]    ${gnb_id}=${0}  ${du_id}=${0}  ${comu_id}=${0}  ${alias}=ssh-gnb-${gnb_id}-${du_id}-${comu_id}
    ${proxy}=    Run keyword if    '${tl.test_pc.connections}'!='[]'    Connect to test pc proxy    gnb_id=${gnb_id}
    ...    ELSE    Set variable    ${None}
    ssh.Connect_to      hostname=${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units[${comu_id}].lmp_connection.addr}
    ...                 username=${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units[${comu_id}].lmp_connection.username}
    ...                 password=${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units[${comu_id}].lmp_connection.password}
    ...                 alias=${alias}
    ...                 proxy=${proxy}
    ssh.Force Reconnect    ${alias}
    [Return]    ${alias}

Connect to test pc proxy
    [Documentation]    :Author: Vasileios Papoutsis, [PRIVATE]
    ...    It is needed when there is different test_pc for each unit.
    ...    In such case "tl.test_pc.connections" is required
    [Arguments]    ${gnb_id}
    ${gnb_test_pc}=    Get Test PC for Object    ${tl.gnbs[${gnb_id}]}
    ${alias}=    Set variable    gnb-${gnb_id}-test_pc
    ssh.Connect_to      hostname=${gnb_test_pc.default_ssh_connection_details.addr}
    ...                 username=${gnb_test_pc.default_ssh_connection_details.username}
    ...                 password=${gnb_test_pc.default_ssh_connection_details.password}
    ...                 alias=${alias}
    [Return]    ${alias}


Get Test PC for Object
    [Documentation]    :Author: Vasileios Papoutsis, [PRIVATE]
    [Arguments]    ${obj}
    ${result}=    Evaluate    [test_pc for test_pc in $tl.test_pcs for obj in test_pc.connections if obj is $obj][0]
    [Return]    ${result}