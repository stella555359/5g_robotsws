*** Settings ***

Documentation    Keywords for snapshot collection

Library     DateTime
Library     OperatingSystem

Library     taf.collectors.snapshot      WITH NAME   snapshot
Library     taf.sbts.oam.coam.admin      WITH NAME   admin
Library     python/testline_information.py

Resource    testline.robot
Resource    connect.robot
Resource    coam_ulm.robot

*** Variables ***
${TIMEOUT_MAKE_SNAPSHOT}    900


*** Keywords ***
Get Snapshot From BTS
    [Documentation]
    ...     Gets snapshot from BTS using admin API.
    ...
    ...     *Note* Only for classical gNB, time varies based on how much time BTS is up!
    ...
    ...     | alias      | AdminConnection object or if used, string name alias |
    ...     | timeout    | Time to wait for positive procedure result |
    ...     | target_dir | base directory to store the snapshot to |
    ...
    ...     *Returns*   path to snapshot file
    ...
    [Arguments]   ${target_dir}=${OUTPUT_DIR}   ${alias}=cOAM   ${timeout}=${TIMEOUT_MAKE_SNAPSHOT}
    ${status}   ${sw_version}   Run Keyword And Ignore Error   coam_ulm.Get Software Version   alias=${alias}
    ${sw_id}             Set Variable If   '${status}'=='PASS'   ${sw_version}   Unknow
    ${timestamp}         DateTime.Get Current Date   result_format=%Y%m%d-%H%M%S
    ${snapshot_path}     Set Variable   ${target_dir}/Snapshot_${sw_id}_${timestamp}.zip
    admin.Get Snapshot   target_file_name=${snapshot_path}   timeout=${timeout}   connection=${alias}
    RETURN   ${snapshot_path}


Collect IM Snapshot From GNB
    [Documentation]
    ...     Gets IMS snapshot from BTS using admin API.
    ...
    ...     | timeout    | timeout in seconds |
    ...     | target_dir | base directory to store the snapshot to |
    ...     | node_id    | Id/Number of node |
    ...     | node_type  | type of node to connect to, default gnb |
    ...
    ...     *Returns*   path to snapshot file
    ...
    [Arguments]   ${target_dir}=${None}   ${node_id}=${0}   ${timeout}=${60}  ${node_type}=gnb
    ${admin_connection}  connect.Setup OAM HTTP Session   node_id=${node_id}   node_type=${node_type}

    IF   '${target_dir}'=='None'
        ${target_dir}     testline.Get Testcase Log Directory
    END
    ${snapshot_path}=  Set Variable  ${target_dir}/IMS_Snapshot.ims2
    admin.Collect IM Snapshot  target_file_name=${snapshot_path}  timeout=${timeout}  connection=${admin_connection}
    File Should Exist    ${snapshot_path}
    RETURN  ${snapshot_path}


Collect Snapshot From GNB
    [Documentation]
    ...     Collect snapshot from gnb using TAF snapshot collector.
    ...
    ...     | target_dir | directory to save snapshot |
    ...     | gnb_id     | Id/Number of gNB |
    ...     | timeout    | operation timeout in seconds |
    ...
    ...
    ...     *Returns*   path to snapshot file
    ...
    [Arguments]   ${target_dir}=${None}   ${gnb_id}=${0}   ${timeout}=${1800}
    IF   '${target_dir}'=='None'
        ${target_dir}     testline.Get Testcase Log Directory
    END

    ${webservice_coam}=   Get Webservice For Collector   ${tl}   ${gnb_id}
    snapshot.Create SBTS Snapshot Collector
    ...   name=gnb-${gnb_id}-classical-snapshot
    ...   webservice=${webservice_coam}
    ...   coverage=Full
    ...   force=0
    ...   timeout=${timeout}

    snapshot.Setup Collectors
    ...    names=gnb-${gnb_id}-classical-snapshot
    snapshot.Set Suite Alias   gnb-${gnb_id}-classical-snapshot

    Wait Until Keyword Succeeds   ${timeout}   1min   snapshot.Collect Collectors
    ...                           names=gnb-${gnb_id}-classical-snapshot
    ...                           target_dir=${target_dir}

    snapshot.Teardown Collectors   names=gnb-${gnb_id}-classical-snapshot

    RETURN   ${target_dir}/gnb-${gnb_id}-classical-snapshot/snapshot.zip


Get Snapshot For Node
    [Documentation]
    ...     Collect snapshot from gnb/enb using admin API.
    ...
    ...     *Note*  Only for classical deployments!
    ...
    ...     | node_id    | Id of gNB/eNB |
    ...     | node_type  | Type of node (gnb|enb) |
    ...     | target_dir | *optional* directory to store the snapshot (default: ${OUTPUT_DIR}) |
    ...
    ...     *Returns*   path to snapshot file
    ...
    [Arguments]   ${node_type}=gnb   ${node_id}=${0}   ${target_dir}=${OUTPUT_DIR}
    ${node}  Set Variable   ${node_type}_${node_id}
    Log  Node for snapshot is ${node}   console=${P_console}
    ${oam_alias}  connect.Setup OAM HTTP Session   node_id=${node_id}   node_type=${node_type}
    ${status}  ${sw_version}   Run Keyword And Ignore Error   coam_ulm.Get Software Version   alias=${oam_alias}
    ${sw_id}             Set Variable If   '${status}'=='PASS'   ${sw_version}   Unknown
    ${timestamp}         DateTime.Get Current Date    result_format=%Y%m%d-%H%M%S
    ${snapshot_path}     Set Variable   ${target_dir}/Snapshot_${node}_${sw_id}_${timestamp}.zip
    admin.Get Snapshot   target_file_name=${snapshot_path}   timeout=${TIMEOUT_MAKE_SNAPSHOT}   connection=${oam_alias}
    RETURN     ${snapshot_path}

