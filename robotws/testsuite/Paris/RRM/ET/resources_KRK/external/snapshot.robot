*** Settings ***

Documentation    Keywords for snapshot

Library     taf.sbts.oam.coam.admin      WITH NAME   coam

Resource    ./testline.robot

*** Keywords ***

Collect snapshot from gNB
    [Documentation]    :Author: Vasileios Papoutsis
    ...     Collect snapshot from gnb
    ...
    ...     :param target_dir: directory to save snapshot
    ...     :param gnb_id: (default=0) Id/Number of gNB
    ...     :param rap_list: (default=EMPTY) list of RAPs
    [Arguments]    ${target_dir}=${None}   ${gnb_id}=${0}
    ${target_dir}=    Run Keyword If    '${target_dir}'=='None'    testline.Get Testcase Log Directory
    ...    ELSE    Set Variable    ${target_dir}
    ${oam_type}=    Get OAM type
    ${snapshot_name}=    Get gNB snapshot name    ${gnb_id}    ${oam_type}
    ${webservice}=  Create Dictionary
    ...    host=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.addr}
    ...    user=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.username}
    ...    password=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.password}
    ...    port=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.port}
    Run keyword if    '${oam_type}'=='coam' or '${oam_type}'=='megazone'
    ...    coam.create_sbts_snapshot_collector
    ...    name=${snapshot_name}
    ...    webservice=${webservice}
    ...    coverage=Full
    ...    force=False
    ...    timeout=600
    ...    target_file_name=${target_dir}/${snapshot_name}.zip
    coam.setup_collectors
    ...    names=${snapshot_name}
    coam.collect_collectors
    ...    names=${snapshot_name}
    coam.teardown_collectors
    ...    names=${snapshot_name}


#### PRIVATE ####

Get gNB snapshot name
    [Documentation]     [Private]
    ...     :Author: Vasileios Papoutsis
    ...     generate snapshot name from arguments
    [Arguments]    ${gnb_id}    ${oam_type}
     ${snapshot_name}=    Set Variable    gnb-${gnb_id}-${oam_type}-snapshot
    [Return]    ${snapshot_name}
