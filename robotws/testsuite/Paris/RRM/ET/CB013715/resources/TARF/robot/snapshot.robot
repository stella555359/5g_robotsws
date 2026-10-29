*** Settings ***

Documentation    Keywords for snapshot collection

Library     DateTime
Library     OperatingSystem

Library     taf.collectors.snapshot      WITH NAME   snapshot
Library     taf.sbts.oam.coam.admin      WITH NAME   admin

Resource    TARF-Keywords.robot
Resource    connect.robot

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
    ${status}   ${sw_version}   Run Keyword And Ignore Error   Fetch common OAM SW version
    ${sw_id}             Set Variable If   '${status}'=='PASS'   ${sw_version}   Unknow
    ${timestamp}         DateTime.Get Current Date   result_format=%Y%m%d-%H%M%S
    ${snapshot_path}     Set Variable   ${target_dir}/Snapshot_${sw_id}_${timestamp}.zip
    admin.get_snapshot   target_file_name=${snapshot_path}   timeout=${timeout}   connection=${alias}
    [Return]   ${snapshot_path}


Collect IM Snapshot from gNB
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
    ${admin_connection}  connect.Setup OAM http session   node_id=${node_id}   node_type=${node_type}
    ${target_dir}   Run Keyword If   '${target_dir}'=='None'   testcase-Keywords.Get Testcase Log Directory
    ...   ELSE      Set Variable   ${target_dir}
    ${snapshot_path}=  Set Variable  ${target_dir}/IMS_Snapshot.ims2
    admin.collect_im_snapshot  target_file_name=${snapshot_path}  timeout=${timeout}  connection=${admin_connection}
    File Should Exist    ${snapshot_path}
    [Return]  ${snapshot_path}


Collect snapshot from gNB
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
    [Arguments]   ${target_dir}=${None}   ${gnb_id}=${0}   ${du_id}=${0}   ${timeout}=${1800}
    BuiltIn.log     du_id = ${du_id}
    ${target_dir}   Run Keyword If   '${target_dir}'=='None'   testcase-Keywords.Get Testcase Log Directory
    ...   ELSE      Set Variable   ${target_dir}

    ${snapshot_name}   Get gNB snapshot name   ${gnb_id}   classical
    Create Snapshot Collector for classical   ${snapshot_name}   timeout=${timeout}   gnb_id=${gnb_id}

    ${collector_names}   Create collectors names   deployment_type=classical
    Wait Until Keyword Succeeds   ${timeout}   1min   snapshot.collect_collectors
    ...                           names=${collector_names}
    ...                           target_dir=${target_dir}

    snapshot.teardown_collectors   names=${collector_names}
    [Return]   ${target_dir}/${snapshot_name}/snapshot.zip


Create collectors names
    [Arguments]   ${deployment_type}
    ${collector_names}   Set Variable If   '${deployment_type}'=='classical'   ${P_SNAPSHOT_NAME_COAM}   ${P_SNAPSHOT_NAME_CU},${P_SNAPSHOT_NAME_DU}
    [Return]   ${collector_names}


Create Snapshot Collector for classical
    [Arguments]   ${snapshot_name}   ${timeout}   ${gnb_id}
    ${P_SNAPSHOT_NAME_COAM}   Set Variable   ${snapshot_name}

    ${webservice_coam}=   Get Webservice For Collector   ${tl}   ${gnb_id}
    snapshot.create_sbts_snapshot_collector
    ...   name=${P_SNAPSHOT_NAME_COAM}
    ...   webservice=${webservice_coam}
    ...   coverage=Full
    ...   force=0
    ...   timeout=${timeout}
    snapshot.setup_collectors
    ...    names=${P_SNAPSHOT_NAME_COAM}
    snapshot.set_suite_alias   ${P_SNAPSHOT_NAME_COAM}
    Set Suite Variable         ${P_SNAPSHOT_NAME_COAM}


Create Snapshot Collector for AiC CU
    [Arguments]   ${snapshot_name}   ${gnb_id}=${0}   ${timeout}=${1800}
    ${P_SNAPSHOT_NAME_CU}   Set Variable   ${snapshot_name}_cu

    ${webservice_cu}   Get Webservice for Collector   ${tl}   ${gnb_id}
    Set To Dictionary    ${webservice_cu}   secure=${True}   login_disabled=False  password=Nokia@123

    snapshot.create_coam_cu_snapshot_collector
    ...   name=${P_SNAPSHOT_NAME_CU}
    ...   webservice=${webservice_cu}
    ...   request_timeout=60.0
    ...   operation_timeout=${timeout}
    snapshot.setup_collectors
    ...   names=${P_SNAPSHOT_NAME_CU}
    snapshot.set_suite_alias   ${P_SNAPSHOT_NAME_CU}
    Set Suite Variable         ${P_SNAPSHOT_NAME_CU}


Create Snapshot Collector for AiC DU
    [Arguments]   ${snapshot_name}   ${gnb_id}=${0}   ${du_id}=${0}   ${timeout}=${1800}
    ${P_SNAPSHOT_NAME_DU}   Set Variable   ${snapshot_name}_du_${du_id}

    ${webservice_du}   Get Webservice for Collector   tl=${tl}   gnb_id=${gnb_id}   du_id=${du_id}
    Set To Dictionary    ${webservice_du}   secure=${True}   login_disabled=False

    snapshot.create_coam_vdu_snapshot_collector
    ...   name=${P_SNAPSHOT_NAME_DU}
    ...   webservice=${webservice_du}
    ...   request_timeout=60.0
    ...   operation_timeout=${timeout}
    snapshot.setup_collectors   names=${P_SNAPSHOT_NAME_DU}
    snapshot.set_suite_alias    ${P_SNAPSHOT_NAME_DU}
    Set Suite Variable          ${P_SNAPSHOT_NAME_DU}

Create Snapshot collectors for AiC
    [Arguments]   ${snapshot_name}   ${gnb_id}   ${du_id}   ${timeout}
    Create Snapshot Collector for AiC DU   snapshot_name=${snapshot_name}   gnb_id= ${gnb_id}   du_id=${du_id}   timeout=${timeout}
    Create Snapshot Collector for AiC CU   snapshot_name=${snapshot_name}   gnb_id= ${gnb_id}   timeout=${timeout}


Get snapshot for node
    [Documentation]
    ...     Collect snapshot from gnb/enb using admin API.
    ...
    ...     *Note*  Only for classical deployments!
    ...
    ...     | node_id   | Id of gNB/eNB |
    ...     | node_type | Type of node (gnb|enb) |
    ...
    ...     *Returns*   path to snapshot file
    ...
    [Arguments]   ${node_type}=gnb   ${node_id}=${0}   ${target_dir}=${OUTPUT_DIR}
    ${node}  Set Variable   ${node_type}_${node_id}
    BuiltIn.Log  Node for snapshot is ${node}   console=${P_console}
    ${oam_alias}  connect.Setup OAM http session   node_id=${node_id}   node_type=${node_type}
    ${status}  ${sw_version}   Run Keyword And Ignore Error    Fetch common OAM SW version
    ${sw_id}             Set Variable If   '${status}'=='PASS'   ${sw_version}   Unknown
    ${timestamp}         DateTime.Get Current Date    result_format=%Y%m%d-%H%M%S
    ${snapshot_path}     Set Variable   ${target_dir}/Snapshot_${node}_${sw_id}_${timestamp}.zip
    admin.get_snapshot   target_file_name=${snapshot_path}   timeout=${TIMEOUT_MAKE_SNAPSHOT}   connection=${oam_alias}
    [Return]     ${snapshot_path}


#### PRIVATE ####

Get gNB snapshot name
    [Documentation]
    ...     Generate snapshot name from arguments.
    ...
    ...     *Scope* Internal
    ...
    [Arguments]   ${gnb_id}   ${deployment_type}
    ${snapshot_name}   Set Variable   gnb-${gnb_id}-${deployment_type}-snapshot
    [Return]   ${snapshot_name}


Compress AiC CU and DU Snapshot
    [Documentation]
    ...     Compresses CU and DU Snapshot into a single file
    ...
    ...     *Scope* Internal
    ...
    [Arguments]   ${target_dir}   ${snapshot_name}
    OperatingSystem.Create Directory   ${target_dir}/${snapshot_name}
    OperatingSystem.Run   zip -rm ${target_dir}/${snapshot_name}/snapshot.zip ${target_dir}/${snapshot_name}
