*** Settings ***
Documentation
...    Author: charlotte.wu@nokia-sbell.com
...    Maintainer: charlotte.wu@nokia-sbell.com
...    Description: 5gNB snapshot collecting
...    Team in charge: I_NSB_MN_5GSC_MMW_SC_PZ_HZ_02_GMS
...    QualityCenter: tds://5g.mn_5g.qc12-prod.int.net.nokia.com/qcbin/TestLabModule-000000003649890581?EntityType=ITestSet&EntityID=71308

Library    String
Library    BuiltIn
Library    OperatingSystem
Library    Collections
Library    taf.sbts.oam.coam.admin   WITH NAME   admin_cli
Library    XML  lxml=True
Library    taf.transport.ssh  WITH NAME  ssh

*** Keywords ***
Delete
    [Documentation]
   	...  Removes directory
    run  rm -rf /home/ute/snapshot

Get Snapshot
    [Documentation]
    ...  Initiates snapshot collecting and downloads it
    [Arguments]    ${name}
    ...            ${coverage1}
    Wait Until Keyword Succeeds    5x    5 minutes    Initiate Snapshot Collection  NAME=${name}  COVERAGE=${coverage1}

Get External Snapshot
    [Documentation]
    ...  Initiates snapshot collecting and sends it to remote LSS server
    [Arguments]    ${coverage}
    ...            ${timeout}
    admin_cli.get_remote_snapshot    coverage=${coverage}    timeout=${timeout}    connection=GNB_OAM

Extract Snapshot
    [Documentation]
    ...  Extracts snapshot.zip to directory
    [Arguments]    ${snapshot_path}
    ...            ${extract_directory}
    Run    unzip ${snapshot_path} -d ${extract_directory}

Check For Summary File
    [Documentation]
    ...  Checks for snapshot file list
    [Arguments]    ${extract_directory}
    OperatingSystem.File Should Exist    ${extract_directory}/snapshot_file_list.txt

Check If File Is Not Empty
    [Documentation]
    ...  Checks if file is not empty
    [Arguments]    ${filename}
    File Should Not Be Empty    ${filename}

Initiate Snapshot Collection
    [Documentation]
    ...  Initiate snapshot collection, wait for max 15 minutes for it to collect and download
    [Arguments]    ${NAME}
    ...            ${COVERAGE}
    admin_cli.get_snapshot    target_file_name=${NAME}
    ...                       coverage=${COVERAGE}
	...                       connection=GNB_OAM
    ...                       timeout=${600}

Set mrbtsId variable
    admin_cli.collect scf   target_file_name=/home/ute/scf.xml    connection=GNB_OAM
    ${XML}=   Parse XML   /home/ute/scf.xml
    ${mrbtsId_element}=   Get Element   ${XML}   .//managedObject[@class="com.nokia.du.5g:MRBTS"]
    set global variable   ${mrbtsId}   ${mrbtsId_element.attrib['distName']}

Remove TRBLCADM Object
    [Documentation]
    ...    to remove TRBLCADM object with required parameters
    @{list}=    create list
    Run Keyword And Ignore Error  admin_cli.perform_object_recommissioning
    ...                                  parameter=${list}
    ...                                  dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                                  operation=delete
    ...                                  skip_parameter_relation_errors=${True}
    ...                                  should_activate=${True}
	...                                  connection=GNB_OAM

Create TRBLCADM Object
    [Documentation]
    ...    to create TRBLCADM object with required parameters
    ${dict1}=    create dictionary    parameterName=actCoreDumpFileCollection
    ...          operation=update
    ...          value=${true}
    ${dict2}=    create dictionary    parameterName=actInternalTrace
    ...          operation=update
    ...          value=${true}
    ${dict3}=    create dictionary    parameterName=actRemoteSyslogTransmission
    ...          operation=update
    ...          value=${false}
    ${dict4}=    create dictionary    parameterName=snapshotUploadDelayForFault6450
    ...          operation=update
    ...          value=1
    @{parameter_list}=    create list    ${dict1}    ${dict2}    ${dict3}    ${dict4}
    Run Keyword And Ignore Error  admin_cli.perform_object_recommissioning    dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                                         parameter=@{parameter_list}
    ...                                         operation=create
    ...                                         skip_parameter_relation_errors=${True}
    ...                                         should_activate=${True}
    ...                                         connection=GNB_OAM

Change Parameter
    [Documentation]
    ...  gets parameter value and changes it
    [Arguments]    ${dist_name}    ${parameter}    ${operation}    ${value}
    admin_cli.perform_parameter_recommissioning   ${dist_name}
    ...                                           ${parameter}
    ...                                           ${operation}
    ...                                           ${value}
    ...                                           skip_parameter_relation_errors=${True}
    ...                                           should_activate=${True}
    ...                                           connection=GNB_OAM

Perform lssConfig complex parameter activation
    [Arguments]    ${lssIPaddress}
    ...            ${lssPortNo}
    ${list_param_to_change}=    Create Dictionary    lssIPaddress    1.0.0.0
    Set To Dictionary    ${list_param_to_change}    lssIPaddress=${lssIPaddress}
    ...                                             lssPortNo=${lssPortNo}
    @{list}=    create list    ${list_param_to_change}
    admin_cli.perform_parameter_recommissioning    dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                                            parameter=lssConfig
    ...                                            operation=update
    ...                                            value=@{list}
    ...                                            skip_parameter_relation_errors=skip
    ...                                            connection=GNB_OAM

Perform faultSnapshotTriggers complex parameter activation
    [Arguments]    ${faultNumber}
	...            ${triggerType}
	${faultNumberInt}=    Convert To Integer    ${faultNumber}
    ${fault_dict_list}=
    ...                admin_cli.get_parameters
    ...                dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/MNL_CONF_M-1/MNLENT_CONF_M-1/TRBLCADM_CONF_M-1
    ...                pattern=faultSnapshot
    ...                connection=GNB_OAM
    ${list_parameters}=    Get From Dictionary    ${fault_dict_list['faultSnapshotTriggers'][0]}
    ...                                           faultNumber
    ${list_param_to_change}=    Create Dictionary    faultNumber    0
    Set To Dictionary    ${list_param_to_change}    faultNumber=${faultNumberInt}
    ...                                             triggerType=${triggerType}
    @{list}=    create list    ${list_param_to_change}
    admin_cli.perform_parameter_recommissioning    dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                                            parameter=faultSnapshotTriggers
    ...                                            operation=update
    ...                                            value=@{list}
    ...                                            skip_parameter_relation_errors=skip
    ...                                            connection=GNB_OAM

Check for existence of remote snapshot
    [Arguments]    ${dir}
    ${FileList}=    ssh.execute    command=ls ${dir}    connection=DCAP-conn
    log    ${FileList}
    Should Match    ${FileList}    Snapshot_${mrbtsId}*

Remove external snapshot
    [Arguments]    ${dir}
    ssh.execute    command=rm -rf ${dir}/Snapshot_*    connection=DCAP-conn

Connect to remote server
    [Arguments]    ${host}
    ...            ${user}
    ...            ${pass}
    ssh.connect_to    hostname=${host}    username=${user}    password=${pass}    alias=DCAP-conn

Disconnect to remote server
    ssh.disconnect    connection=DCAP-conn
