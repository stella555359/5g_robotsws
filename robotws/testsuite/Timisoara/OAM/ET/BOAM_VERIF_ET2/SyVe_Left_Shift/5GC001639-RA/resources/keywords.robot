*** Settings ***
Documentation
...    Author: pawel.knychala@nokia.com
...    Maintainer: irina.tanasoiu@nokia.com
...    Description: 5gNB snapshot collecting

Library    String
Library    BuiltIn
Library    OperatingSystem
Library    Collections
Library    taf.sbts.oam.coam.admin   WITH NAME   admin_cli
Library    XML  lxml=True
Library    SSHLibrary    WITH NAME    ssh_lib
Library    taf.transport.ssh   WITH NAME   csn

Resource    ../../resources/selenium.robot

*** Variables ***
${LSS_addr}                     10.5.25.105
${LSS_username}                 coam
${LSS_password}                 zO&n1W*ktp7

${Delta_for_LSS}=              ${CURDIR}/../resources/Delta_for_LSS.json


*** Keywords ***
01_Snapshot_collection_in_WebEM
    [Documentation]
    ...  Collects Snapshot from WebEm

    Log To Console   Download Snapshot
    Get Snapshot    /home/ute/snapshot/snapshot.zip    Full
    Check If File Is Not Empty    /home/ute/snapshot/snapshot.zip
    Delete Snapshot

02_Snapshot_content
    [Documentation]
    ...  Check Snapshot content

    Log To Console  Check Snapshot content
    Get Snapshot    /home/ute/snapshot/snapshot_full.zip    Full
    Get Snapshot    /home/ute/snapshot/snapshot_minor.zip    Minor
    Delete Snapshot

03_Declaration_of_the_default_external_server
    [Documentation]
    ...  Declare default LSS external snapshot

    Log To Console  Declare external LSS server
    Log To Console  Test merged with 04_Triggering_snapshot_to_external_server regression optimization
#    Remove TRBLCADM Object
#    Create TRBLCADM Object
#    Change Parameter    ${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1    diagSnapDestination    update    lss
#    Perform lssConfig complex parameter activation    10.5.25.105    22

04_Triggering_snapshot_to_external_server
    [Documentation]
    ...  Declare default LSS external snapshot and Gets external snapshot and sends it to lss server

    Log To Console   Download Snapshot
    Get Snapshot    /home/ute/snapshot/snapshot.zip    Full
    Log To Console   Configure LSS in WebEm
    Configure LSS in WebEM
    Perform comissioning for LSS
    Log To Console  Declare external LSS server
    Perform lssConfig complex parameter activation  10.5.25.105  22
    csn.connect to    ${LSS_addr}    ${LSS_username}    ${LSS_password}    alias=LSS
    Log To Console  Get External Snapshot
    Get External Snapshot    Full    5min
    Wait until keyword succeeds    6 x    10 s    Check for existence of remote snapshot    10.5.25.105    coam    zO&n1W*ktp7    /opt/coam
    Remove external snapshot    /opt/coam

05_Snapshot_Summary_File
    [Documentation]
    ...  Check summary file

    Log To Console   Check summary file
    Get Snapshot    /home/ute/snapshot/snapshot.zip    Full
    Extract Snapshot   snapshot_path=/home/ute/snapshot/snapshot.zip   extract_directory=/home/ute/snapshot/snapshot_summary
    Check For Summary File    /home/ute/snapshot/snapshot_summary
    Check If File Is Not Empty    /home/ute/snapshot/snapshot_summary/snapshot_file_list.txt
    Delete Snapshot

Delete Snapshot
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
    admin_cli.collect scf   target_file_name=/home/ute/scf.xml
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
    Run Keyword And Ignore Error  admin_cli.perform_object_recommissioning    dist_name=${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
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
    ${NP_path}=  Get Current NP Path
    ${lss_dict}=
    ...                admin_cli.get_parameters
    ...                dist_name=${NP_path}/SCF-1/MRBTS_A-1/MNL_A-1/MNLENT_A-1/TRBLCADM_A-1
    ...                pattern=lss
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

Get Current NP Path Left
    ${currentNP}        ADMIN Get Parameter
    ...    dist_name=/MRBTS-1/RAT-1/BTS_L-1/BTS_CONF-1
    ...    parameter=currentNp
    ...    timeout=300
    ${NP_path}  Set variable  &{currentNP}[currentNp]
    [Return]  ${NP_path}


Get Current NP Path Right
    ${currentNP}        ADMIN Get Parameter
    ...    dist_name=/MRBTS-1/RAT-1/BTS_L-4/BTS_CONF-1
    ...    parameter=currentNp
    ...    timeout=300
    ${NP_path}  Set variable  &{currentNP}[currentNp]
    [Return]  ${NP_path}


Get Current NP Path
    ${NP_Path}=  Run Keyword If     '${OUT_ADMIN_SMOD_POSITION}' == 'left'
    ...            Get Current NP Path Left
    ...   ELSE IF     '${OUT_ADMIN_SMOD_POSITION}' == 'right'
    ...            Get Current NP Path Right
    [Return]  ${NP_Path}

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

Perform comissioning for LSS
    ADMIN Perform Delta Recommissioning                 delta_file=${Delta_for_LSS}
    ...                                                 skip_parameter_relation_errors=True
    Sleep  30s


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
#    Wait Until Element Is Visible
#    ...    locator=//span[contains(text(),"Save succeeded")]
    #Close Browser
    Sleep  20s
    SELENIUM Teardown Enviroment
