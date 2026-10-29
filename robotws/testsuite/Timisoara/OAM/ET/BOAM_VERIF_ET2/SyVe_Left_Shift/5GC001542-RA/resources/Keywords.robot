*** Settings ***
Documentation
...    Author: szymon.swic@nokia.com, magdalena.rega@nokia.com
...    Maintainer: szymon.swic@nokia.com, magdalena.rega@nokia.com
...    Description: Trigger snapshot collection after fault
...    Team in charge: 5G_IV_7_WRO_5_SG
...    QualityCenter: tds://5g.mn_5g.qc12-prod.int.net.nokia.com/qcbin/TestLabModule-
...    000000003649890581?EntityType=ITestSet&EntityID=50132

Library    taf.sbts.oam.coam.admin   WITH NAME   admin_cli
Library    taf.transport.ssh    WITH NAME    ssh
Library    taf.config.scf       WITH NAME    scf
Library    Collections
Library    OperatingSystem
Library    XML  lxml=True
Library    PythonKeywords.py
Library    ValuesGenerator.py

Resource   ../../CommonKeywords/nrbts_states_verification/getters.robot
Resource   ../../resources/selenium.robot

*** Variables ***
${LSS_addr}                     10.5.25.105
${LSS_username}                 coam
${LSS_password}                 zO&n1W*ktp7
${BTS_metadata}=                BTS1_*_metadata.txt


*** Keywords ***
Make suite variable $ {mrbtsId} and $ {btsName}
    ${mrbtsId}    Get nrbtsId
    ${btsName}    get_this_bts_name    ${mrbtsId}

    set suite variable      ${mrbtsId}
    set suite variable      ${btsName}

Assure TRBLCADM object exists
    [Documentation]  Error on creating this object will be ignored
    set_trblcadm_object    ${mrbtsId}


Set snapshot destination to LSS server
	[Documentation]    create reference for lss server to send snapshot after fault trigger
    [Arguments]    ${lssIPaddress}=2.2.2.2    ${lssPortNo}=22
    ${list_param_to_change}=    Create Dictionary
        ...     lssIPaddress=${lssIPaddress}
        ...     lssPortNo=${lssPortNo}
    @{list}=    create list    ${list_param_to_change}

    admin_cli.perform_parameter_recommissioning
        ...    dist_name=MRBTS-${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
        ...    parameter=lssConfig
        ...    operation=update
        ...    value=@{list}
        ...    skip_parameter_relation_errors=skip


Add 36 Fault Triggers
	[Documentation]    add 36 faults for snapshot trigger
    @{list}=    get_fault_triggers_list    reals=${4}    fakes=${32}

    admin_cli.perform_parameter_recommissioning
        ...    dist_name=MRBTS-${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
        ...    parameter=faultSnapshotTriggers
        ...    operation=update
        ...    value=@{list}
        ...    skip_parameter_relation_errors=skip

Adding 37 Fault Triggers Should Fail
     set test variable    ${error}
        ...    *ErrorCode: 23*
     Run Keyword And Expect Error    ${error}    Adding 37 Fault Triggers

Adding 37 Fault Triggers
    ${fault_37}=    Create Dictionary
        ...     faultNumber=52
        ...     triggerType=onFaultDetection

    @{list}=    get_fault_triggers_list    reals=${4}    fakes=${32}
    Append To List    ${list}    ${fault_37}

    admin_cli.perform_parameter_recommissioning
        ...    dist_name=MRBTS-${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
        ...    parameter=faultSnapshotTriggers
        ...    operation=update
        ...    value=@{list}
        ...    skip_parameter_relation_errors=skip


Add 37 Fault Triggers
	[Documentation]    add 37 faults for snapshot trigger
    @{list}=    get_fault_triggers_list    reals=${4}    fakes=${33}

    admin_cli.perform_parameter_recommissioning
        ...    dist_name=MRBTS-${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
        ...    parameter=faultSnapshotTriggers
        ...    operation=update
        ...    value=@{list}
        ...    skip_parameter_relation_errors=skip

Adding 38 Fault Triggers Should Fail
     set test variable    ${error}
        ...    *ErrorCode: 23*
     Run Keyword And Expect Error    ${error}    Adding 38 Fault Triggers

Adding 38 Fault Triggers
    ${fault_38}=    Create Dictionary
        ...     faultNumber=59
        ...     triggerType=onFaultDetection

    @{list}=    get_fault_triggers_list    reals=${4}    fakes=${39}
    Append To List    ${list}    ${fault_38}

    admin_cli.perform_parameter_recommissioning
        ...    dist_name=MRBTS-${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
        ...    parameter=faultSnapshotTriggers
        ...    operation=update
        ...    value=@{list}
        ...    skip_parameter_relation_errors=skip

Add 20 Fault Triggers
	[Documentation]    add 20 faults for snapshot trigger
    @{list}=    get_fault_triggers_list    reals=${4}    fakes=${16}

    admin_cli.perform_parameter_recommissioning
        ...    dist_name=MRBTS-${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
        ...    parameter=faultSnapshotTriggers
        ...    operation=update
        ...    value=@{list}
        ...    skip_parameter_relation_errors=skip

Adding 21 Fault Triggers Should Fail
     set test variable    ${error}
        ...    *ErrorCode: 23*
     Run Keyword And Expect Error    ${error}    Adding 21 Fault Triggers

Adding 21 Fault Triggers
    ${fault_21}=    Create Dictionary
        ...     faultNumber=52
        ...     triggerType=onFaultDetection

    @{list}=    get_fault_triggers_list    reals=${4}    fakes=${16}
    Append To List    ${list}    ${fault_21}

    admin_cli.perform_parameter_recommissioning
        ...    dist_name=MRBTS-${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
        ...    parameter=faultSnapshotTriggers
        ...    operation=update
        ...    value=@{list}
        ...    skip_parameter_relation_errors=skip

Check There Are 20 Fault Triggers
    admin_cli.get_current_scf_file      /home/ute    scf.xml
    ${faults}=    Grep File   /home/ute/scf.xml     faultNumber
    ${result}=    is_faults_list_complete    ${faults}    expected_size=${20}

    should be true    ${result}


Commission snapshot triggering faults
    [Arguments]    @{fault_numbers_list}

    @{faults}=    get_faults_list_of_dicts    ${fault_numbers_list}

    admin_cli.perform_parameter_recommissioning
        ...    dist_name=MRBTS-${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
        ...    parameter=faultSnapshotTriggers
        ...    operation=update
        ...    value=${faults}
        ...    skip_parameter_relation_errors=skip


Check There Are 37 Fault Triggers
    admin_cli.get_current_scf_file      /home/ute    scf.xml
    ${faults}=    Grep File   /home/ute/scf.xml     faultNumber
    ${result}=    is_faults_list_complete    ${faults}    expected_size=${37}

    should be true    ${result}

Check There Are ${num} Fault Triggers
    admin_cli.get_current_scf_file      /home/ute    scf.xml
    ${faults}=    Grep File   /home/ute/scf.xml     faultNumber
    ${result}=    is_faults_list_complete    ${faults}    expected_size=${num}

    should be true    ${result}

Raise Fault 4080 To Trigger Snapshot Collect
    generate_fault_4080
    Sleep    15m    Wait for snapshot trigger

Raise Fault 4078 To Trigger Snapshot Collect
    generate_fault_4078
    Sleep    15m    Wait for snapshot trigger

Clear Triggers List
    ${sample_fault}=    Create Dictionary
        ...     faultNumber=40
        ...     triggerType=onFaultDetection
    @{faults}=    create list    ${sample_fault}

    admin_cli.perform_parameter_recommissioning
        ...    dist_name=MRBTS-${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
        ...    parameter=faultSnapshotTriggers
        ...    value=@{faults}
        ...    operation=delete
        ...    skip_parameter_relation_errors=skip

Clear fault trigger list
    ${sample_fault}=    Create Dictionary
        ...     faultNumber=61652
        ...     triggerType=onFaultDetection
    @{faults}=    create list    ${sample_fault}
    admin_cli.perform_parameter_recommissioning
        ...    dist_name=MRBTS-${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
        ...    parameter=faultSnapshotTriggers
        ...    value=@{faults}
        ...    operation=delete
        ...    skip_parameter_relation_errors=skip

Check There Are No Fault Triggers
    admin_cli.get_current_scf_file      /home/ute    scf.xml
    ${faults}=    Grep File   /home/ute/scf.xml     faultNumber
    should be empty    ${faults}

Add ${num} Fault Triggers
    @{faults}=    get_fault_triggers_list    reals=${num}

    admin_cli.perform_parameter_recommissioning
        ...    dist_name=MRBTS-${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
        ...    parameter=faultSnapshotTriggers
        ...    operation=update
        ...    value=@{faults}
        ...    skip_parameter_relation_errors=skip

#Check Collected Snapshot
#    [Arguments]    ${connection}=lssv4
#	${Snapshots}=    Get List Of Your BTS's Snapshots   ${btsName}    connection=${connection}
#    should not be empty    ${Snapshots}

#Check If There Is No Snapshot
#	${Snapshots}=    Get List Of Your BTS's Snapshots   ${btsName}
#    should be empty    ${Snapshots}
#
#Check If 5 Snapshots Have Been Collected
#	${Snapshots}=    Get List Of Your BTS's Snapshots   ${btsName}
#    ${SnapshotsCount}=    get length    ${Snapshots}
#    should be equal    ${SnapshotsCount}   ${5}
#
#Get List Of Your BTS's Snapshots
#    [Arguments]    ${btsName}   ${connection}=lssv4
#    ${FileList}=    get_directory_grep_list    'Snapshot_MRBTS.*${btsName}'    ${connection}
#    log to console    ${FileList}
#
#    [Return]    ${FileList}

#Trigger 5 times fault 61652
#    :For  ${i}  IN RANGE    0    6
#    \  ADMIN Change R&D Port Status    True
#    \  log to console  ADMIN Change R&D Port Status True ${i}
##    \   sleep  60
##    \   ADMIN Change R&D Port Status    False
##    \   sleep  60
##    \   ADMIN Change R&D Port Status  True
#    \  sleep  240
#    \  ADMIN Change R&D Port Status    False
#    \  log to console  ADMIN Change R&D Port Status False
#    \  sleep  90

Trigger 5 times fault 61652 and verify snapshot on LSS
    For  ${i}  IN RANGE    0    5
       ADMIN Change R&D Port Status    True
       log to console  ADMIN Change R&D Port Status True ${i}
       sleep  240
       ADMIN Change R&D Port Status    False
       log to console  ADMIN Change R&D Port Status False
       sleep  680
       Check if Snapshot is collected on LSS
       Wait until BTS_metadata.txt exists
       log to console  Snapshot ${i} collected
       Remove Snapshot from LSS server
    END

Trigger the 6th time fault 61652 and check if there is no snapshot on LSS
    ADMIN Change R&D Port Status    True
    log to console  ADMIN Change R&D Port Status True 6
    sleep  240
    ADMIN Change R&D Port Status    False
    log to console  ADMIN Change R&D Port Status False
    sleep  30
    Check if Snapshot is not collected on LSS
    log to console  The 6th snapshot is not collected

Check if Snapshot is not collected on LSS
    Set Suite Variable    ${snapshot_LSS}    Snapshot_MRBTS-1_${OUT_ADMIN_BTS_NAME}
    ssh.connect to    ${LSS_addr}    ${LSS_username}    ${LSS_password}    alias=LSS
    sleep    2s
    ssh.send_command    command=ls -l /opt/coam/   connection=LSS
    ${snap_exists}    ssh.read output    connection=LSS
    Should not contain  ${snap_exists}  ${snapshot_LSS}  connection=LSS
    ssh.disconnect    connection=LSS

Trigger fault 4078 and wait for snapshot to be collected on LSS
    generate_fault_4078
    sleep  300
    wait until keyword succeeds  900s  180s  Check if Snapshot is collected on LSS
    Wait until BTS_metadata.txt exists

Remove Snapshot from LSS server
    Set Suite Variable    ${snapshot_path_LSS}    /opt/coam/Snapshot_MRBTS-1_${OUT_ADMIN_BTS_NAME}*
    ssh.connect to    ${LSS_addr}    ${LSS_username}    ${LSS_password}    alias=LSS
    sleep    2s
    ssh.send_command    command=rm -rf ${snapshot_path_LSS}  connection=LSS
    ssh.disconnect    connection=LSS

Check if Snapshot is collected on LSS
    Set Suite Variable    ${snapshot_LSS}    Snapshot_MRBTS-1_${OUT_ADMIN_BTS_NAME}
    ssh.connect to    ${LSS_addr}    ${LSS_username}    ${LSS_password}    alias=LSS
    sleep    2s
    ssh.send_command    command=ls -l /opt/coam/   connection=LSS
    ${snap_exists}    ssh.read output    connection=LSS
    Should contain  ${snap_exists}  ${snapshot_LSS}  connection=LSS
    ssh.send_command    command=find ${snapshot_LSS}* | wc -l   connection=LSS
    ${snap_list}    ssh.read output    connection=LSS
    ${snap_list}    convert to integer  ${snap_list}
    should be true      ${snap_list}>=7
    ssh.disconnect    connection=LSS

Wait until BTS_metadata.txt exists
    wait until keyword succeeds  600  60  Check if BTS_metadata.txt exists

Check if BTS_metadata.txt exists
    Set Suite Variable    ${snapshot_LSS}    Snapshot_MRBTS-1_${OUT_ADMIN_BTS_NAME}
    ssh.connect to    ${LSS_addr}    ${LSS_username}    ${LSS_password}    alias=LSS
    sleep    2s
    ssh.send_command    command=find ${snapshot_LSS}*/*metadata.txt   connection=LSS
    ${snap_list}    ssh.read output    connection=LSS
    Set Suite Variable    ${BTS_metadata}    metadata.txt
    should contain  ${snap_list}  ${BTS_metadata}
    ssh.disconnect    connection=LSS


Reset and on air
    ADMIN Reset Site
    Wait Until Keyword Succeeds
    ...    900
    ...    30
    ...    ADMIN INFOMODEL Check If BTS Is OnAir

Reset and on configured
    ADMIN Reset Site
    Wait Until Keyword Succeeds
    ...    900
    ...    30
    ...    ADMIN INFOMODEL Check If BTS Is Configured

Delete
    [Documentation]
   	...  Removes directory
    run  rm -rf /home/ute/snapshot

Get Snapshot
    [Documentation]
    ...  Initiates snapshot collecting and downloads it
    [Arguments]    ${name}
    ...            ${coverage1}
    Wait Until Keyword Succeeds    5x    5 minutes    Initiate Snapshot Collection  ${name}  ${coverage1}

Get External Snapshot
    [Documentation]
    ...  Initiates snapshot collecting and sends it to remote LSS server
    [Arguments]    ${coverage}
    ...            ${timeout}
    admin_cli.get_remote_snapshot    ${coverage}    ${timeout}

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

Set mrbtsId variable
    admin_cli.get_current_scf_file      /home/ute    scf.xml
    ${XML}=   Parse XML   /home/ute/scf.xml
    ${mrbtsId_element}=   Get Element   ${XML}   //managedObject[@class="com.nokia.srbts:MRBTS"]
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
    Run Keyword And Ignore Error  admin_cli.perform_object_recommissioning
    ...                                         dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                                         parameter=@{parameter_list}
    ...                                         operation=create
    ...                                         skip_parameter_relation_errors=${True}
    ...                                         should_activate=${True}

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

Perform lssConfig complex parameter activation
    [Arguments]    ${lssIPaddress}
    ...            ${lssPortNo}
    ${lss_dict}=
    ...      admin_cli.get_parameters
    ...      dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/MNL_CONF_M-1/MNLENT_CONF_M-1/TRBLCADM_CONF_M-1
    ...      pattern=lss
    ${list_parameters}=    Get From Dictionary    ${lss_dict['lssConfig']}
    ...                                           lssIPaddress
    ${list_param_to_change}=    Create Dictionary    lssIPaddress    1.0.0.0
    Set To Dictionary    ${list_param_to_change}    lssIPaddress=${lssIPaddress}
    ...                                             lssPortNo=${lssPortNo}
    @{list}=    create list    ${list_param_to_change}
    admin_cli.perform_parameter_recommissioning    dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                                            parameter=lssConfig
    ...                                            operation=update
    ...                                            value=@{list}
    ...                                            skip_parameter_relation_errors=skip

Check for existence of remote snapshot
    [Arguments]    ${host}
    ...            ${user}
    ...            ${pass}
    ...            ${dir}
    ssh_lib.Open Connection   ${host}
    ssh_lib.Login    ${user}    ${pass}
    ${FileList}=    ssh_lib.List Directory    ${dir}
    log    ${FileList}
    Should Contain Match    ${FileList}    Snapshot_${mrbtsId}*

Remove external snapshot
    [Arguments]    ${dir}
    ssh_lib.Execute Command    rm -rf ${dir}/*${mrbtsId}*

Check if PM exist
    ${PM}  Run  cat /home/ute/snapshot/snapshot_summary/snapshot_file_list.txt | grep -i PM.BTS |wc -l
    convert to integer  ${PM}
    should be true  ${PM} > 0

Configure LSS in WebEM
    SELENIUM Prepare Enviroment
    SELENIUM Login To Web Element Manager
    Sleep   10
    Wait Until Page Contains Element    locator=//div[@aria-describedby="admin.navigationBar.diagnostic.TITLE"]
    Sleep  3s
    Click Element    locator=//div[@aria-describedby="admin.navigationBar.diagnostic.TITLE"]
    Mouse Over       locator=//span[text()="Snapshot"]
    Click Element    locator=//span[text()="LSS User Configuration"]
    SELENIUM Input Text in Visible Element
    ...    locator=//*[@id="username"]
    ...    text=${LSS_username}
    SELENIUM Input Text in Visible Element
    ...    locator=//*[@id="newPassword"]
    ...    text=${LSS_password}
    SELENIUM Input Text in Visible Element
    ...    locator=//*[@id="confirmPassword"]
    ...    text=${LSS_password}
    Sleep   3s
    Click Button    locator=//*[@id="p-tabpanel-2"]/lss-user-configuration/execution-bar/div/save-lss-button/div/p-button/button
    Wait Until Element Is Visible
    ...    locator=//span[contains(text(),"Save succeeded")]
    Close Browser
    SELENIUM Teardown Enviroment
