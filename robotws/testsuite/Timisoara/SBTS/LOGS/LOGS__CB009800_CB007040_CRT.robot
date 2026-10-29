*** Settings ***
Documentation  CB009800

Library     XML    use_lxml=${TRUE}
Library     taf.sbts.oam.coam.admin  WITH NAME  coam
Library     taf.ul.verify_snapshot   WITH NAME  snapshot
Library     SeleniumLibrary
Library     DateTime
Library     hran_file_operations
Library     OperatingSystem
Resource    ../resources/verdicts.robot
Resource    ../resources/bts_states.robot
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot
Resource    ../resources/ping_utils.robot
Resource    ../resources/BTS_log_level.robot

*** Variables ***
${SNAPSHOT_COLLECTION_TIMEOUT}  1200
${RESET_DATE}
${BLACKBOX_INFO}
${MATCHES}
${check_blackbox_date}
${G_bts_host}                   192.168.255.129
${G_bts_user}                   toor4nsn
${G_bts_passwd}                 oZPS0POrRieRtu

*** Keywords ***
TC__LOGS__CB009800_CB007040_CRT
    [Documentation]
    ...  *******************
    ...  Author: Andrei Maria
    ...  ******************
    ...  Basic information
    ...  *****************
    ...  This user scenario describes execution of (remotely triggered) NE (SBTS) power reset with prior snapshot collection.
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 2025-09-11 - TC created.
    ...  *******************


    Set Tags    CA-LOGS    OWNER-andrei.maria@nokia.com    MAINTAINER-andrei.maria@nokia.com
    ...    GROUP_IN_CHARGE-TSR1_7_Vrf    PHASE-CRT

    Step 0: Preconditions
    Step 1: Perform BTS power reset with snapshot collection
    Step 2: Check If Snapshot Is Collected
    Step 3: Check If BTS power reset was performed
    Step 4: Check If Snapshot Is On LSS


Step 0: Preconditions
    [Documentation]
    ...  In this step needed test variables are declared

    Log  \nPreconditions  console=${True}
    Set Test Variable  ${TRBLCADM_MO_ADDED}  ${False}
    ${bts_id}  bts_states.Get BTS ID
    Set Test Variable  ${BTS_ID}  ${bts_id}
    ${SW}  coam.Get Sw Version
    ${snapshot_name}  Set Variable  Snapshot_MRBTS-${bts_id}_*_${SW}_*
    Set Test Variable  ${snapshot_name}
    Set Snapshot Destination To  LSS
    Create Trblcadm Mo

Step 1: Perform BTS power reset with snapshot collection
    Log  \nStep 1: Perform BTS power reset with snapshot collection  console=${True}
    BTS_log_level.WebEM Login
#    BTS_log_level.Change Screen Lock Timeout
    Open BTS Power Reset
    Wait Until Element Is Clicked  xpath=//label[text()="Power reset with snapshot collection"]
    Capture Page Screenshot
    Wait Until Element Is Clicked  xpath=//span[contains(text(),'Execute')]
    Capture Page Screenshot
    Log  Power reset will be done.  console=${True}
    ${RESET_DATE}      DateTime.get current date  time_zone=UTC
    set test variable  ${RESET_DATE}
    Log  Power Reset trigger timestamp: ${RESET_DATE}
    Wait Until Element Is Clicked  xpath:/html/body/div[2]/div/div[3]/ot-footer/p-button[1]/button/span  120
    Capture Page Screenshot

Step 2: Check If Snapshot Is Collected
    Log  \nStep 2: Check If Snapshot Is Collected  console=${True}
    ${snapshot_triggering_status}  Query Infomodel  check //TECHREP_L-*/SNAPSHOT-* is [originator=Internal,stateInfo.usageState=Active]
    ...  timeout=60  allow_negative_result=True
    Run Keyword If  ${snapshot_triggering_status}
    ...  Log  Snapshot was triggered by Power Reset.  console=${True}
    ...  ELSE  verdicts.Set Test Failed  Snapshot was not triggered by Power Reset.  ${TRUE}

    Log  Wait max ${SNAPSHOT_COLLECTION_TIMEOUT} seconds for snapshot to collect.  console=${True}
    ${snapshot_collection_status}  Query Infomodel  none //TECHREP_L-*/SNAPSHOT-* is [originator=Internal]
    ...  timeout=${SNAPSHOT_COLLECTION_TIMEOUT}  allow_negative_result=True
    Run Keyword If  ${snapshot_collection_status}
    ...  Log  Snapshot collection finished.  console=${True}
    ...  ELSE  verdicts.Set Test Failed  Snapshot collection not finished in ${SNAPSHOT_COLLECTION_TIMEOUT} seconds.  ${TRUE}

Step 3: Check If BTS power reset was performed
    Log  \nStep 3: Check if Power Reset was successfully performed  console=${True}
    ping_utils.Wait For Target IP To Be Unreachable   192.168.255.129   10
    ping_utils.Wait For Target IP To Be Reachable   192.168.255.129   10
    Wait Until Keyword Succeeds   20m   30s   pm_logs_general.Check All Modules And All Cells Working States
    Log  All modules reached working state  console=yes
    bts_states.Check Active Alarms
    ${BLACKBOX_INFO}       set variable    'power reset'
    Get File from SMOD1    /ffs/run/logs/lifetimedata/blackbox_reset
    Analyze blackbox log file

Step 4: Check If Snapshot Is On LSS
    [Documentation]
    ...  In KW test login to lss server and check if snapshot is present
    ...  if yes zip directory to snapshot.zip file after that download zip file to local disk
    Log  \nStep 4: Chceck if snapshot is on LSS  console=${True}

    ${lss_sever_ip}  Set Variable  10.5.20.200
    ${lss_server_pass}  Set Variable  zO&n1W*ktp7!
    ${lss_server_user}  Set Variable  coam

    Log  Open SSH Connection to lss server  console=${true}
    SSHLibrary.Open Connection                          ${lss_sever_ip}
    ${ssh_status}  Run Keyword And Return Status
    ...  SSHLibrary.Login                               ${lss_server_user}    ${lss_server_pass}
    Run Keyword If  ${ssh_status}
    ...  Log  Opening SSH session to lss server succeeded   console=${true}
    ...  ELSE
    ...  verdicts.Set Test Failed  TC failed - Open SSH connection to lss server failure.  ${TRUE}
    Sleep    3s

    ${snapshot_location_on_lss}  SSHLibrary.Execute Command  find / -type d -name "${snapshot_name}" -cmin -15 2>/dev/null
    ${snapshot_file_name_on_lss}    Fetch From Right    ${snapshot_location_on_lss}    /
    ${isEmpty}  Get length  ${snapshot_location_on_lss}
    Log  ${isEmpty}
    Run Keyword If  ${isEmpty}==0
    ...  verdicts.Set Test Failed  snapshot was`t found on lss server.  ${TRUE}
    ...  ELSE  Log  Snapshot was found on lss server.   console=${true}
    Sleep  3s
    SSHLibrary.Execute Command  zip -r ${snapshot_name}.zip ${snapshot_location_on_lss}
    Sleep  60s
    Run  sshpass -p '${lss_server_pass}' scp ${lss_server_user}@${lss_sever_ip}:/home/coam/${snapshot_name}.zip ${BTS_Files}
    Sleep  60s
    SSHLibrary.Execute Command  rm -r /home/coam/${snapshot_file_name_on_lss}
    Log  ${snapshot_file_name_on_lss} was removed from LSS server
    Sleep  1s
    SSHLibrary.Execute Command  rm /home/coam/${snapshot_name}.zip
    Log  ${snapshot_name}.zip was removed from LSS server
    ${path_to_snapshot_from_lss}  Set Variable  ${BTS_Files}/${snapshot_name}.zip
    OperatingSystem.File Should Exist  ${BTS_Files}/${snapshot_name}.zip
    Log  Snapshot was downloaded to local disk   console=${true}
    Set Test Variable  ${path_to_snapshot_from_lss}
    Validate Snapshot from LSS
    SSHLibrary.Close Connection

Open BTS Power Reset
    [Documentation]  This keyword is used to Open BTS Power Reset.

    Click Element  //*[@id="main-view"]/div/div[1]/div/product-bar/otx-product-bar/div/div[1]/div[1]/ot-compact-drawer/button/span[1]
    Capture Page Screenshot
    Click Element  //span[contains(text(),'Procedures')]
    Capture Page Screenshot
    Click Element  //span[contains(text(),'Power Reset')]
    Capture Page Screenshot
    Click Element  //span[contains(text(),'BTS Power Reset')]
    Capture Page Screenshot

Create Trblcadm Mo
    coam.Get Current Scf File   ${BTS_Files}  scf.xml  export_type=configuration
    ${SCF}  Parse Xml  ${BTS_Files}/scf.xml
    Set Test Variable  ${SCF}
    ${trblcadm_element}  Evaluate Xpath  ${SCF}  //managedObject[contains(@class, 'TRBLCADM')]
    ${delta_id}  Set Variable  fault
    coam.Create Delta  ${delta_id}
    ${mnlent_element}  Evaluate Xpath  ${SCF}  //managedObject[contains(@class, 'MNLENT')]
    ${MNLENT_DISTNAME}  XML.Get Element Attribute  ${mnlent_element[0]}  distName
    Set Test Variable  ${MNLENT_DISTNAME}
    Log  Adding TRBLCADM managed object to configuration  console=${True}
    coam.Append Managed Object To Delta  ${MNLENT_DISTNAME}/TRBLCADM-1  update  ${delta_id}
    coam.Append Parameter Update To Delta  ${MNLENT_DISTNAME}/TRBLCADM-1  diagSnapDestination  lss  ${delta_id}
    Set Test Variable  ${TRBLCADM_MO_ADDED}  ${True}
    coam.Get Delta  ${delta_id}
    coam.Save Delta  ${BTS Files}/delta.json  ${delta_id}
    coam.Perform Delta Recommissioning  ${BTS Files}/delta.json  skip_parameter_relation_errors=${True}

Validate Snapshot from LSS
    Log    \nValidate Snapshot from LSS    console=${True}
    ${Found_file_dict}    snapshot.Get Data From Snapshot    ${path_to_snapshot_from_lss}
    ${path_to_xml_spec_file}  join path  ${CURDIR}  tc_variables  snapshot_spec_from_lss.xml
    snapshot.Validate Snapshot    ${Found_file_dict}    ${path_to_xml_spec_file}
    Log    Validation success   console=${True}

Wait Until Element Is Clicked
    [Documentation]
    ...  This KW waits for Click Element KW to succeeds.
    [Arguments]  ${xpath}  ${retry_timeout}=30s  ${retry_interval}=5s

    Wait Until Keyword Succeeds  ${retry_timeout}  ${retry_interval}
    ...  Click Element  ${xpath}

Get File from SMOD1
    [Arguments]    ${file_path}
    [Documentation]
    ...    In this KW file is downloaded to BTS files from the path on BTS given in Argument.
    Log    Collecting ${file_path}    console=${True}
    ${exit_code}    ${output}=    Run And Return Rc And Output
    ...    sshpass -p '${G_bts_passwd}' scp -r ${G_bts_user}@${G_bts_host}:${file_path} ${BTS Files}
    Run Keyword If    ${exit_code}!=0
    ...    verdicts.Set Test Restriction  Could not get ${file_path}. File may not exist.


Analyze blackbox log file
    [Documentation]
    ...  Keyword used to analyze blackbox log. It is checked if date and text info in last line of the blackbox log file is correct.
    ...  If date or test message inside blackbox log is not correct, test case fails.

    ${date_in_logs}  OperatingSystem.get file  ${BTS Files}/blackbox_reset  encoding_errors=ignore
    ${current_year}  Get Time  return year
    ${number_of_entries}  get lines containing string  ${date_in_logs}  ${current_year}-
    ${last_line}  get line  ${number_of_entries}  -1
    set test variable  ${last_line}
    Log    Last line from blackbox file: ${last_line}    console=${True}

    FOR  ${i}  IN RANGE  1  40
        Check Date
        exit for loop if  '${check_blackbox_date[0]}'=='PASS'
    END

    ${check_blackbox_info}  run keyword and ignore error  should contain  ${last_line}  ${BLACKBOX_INFO}
    run keyword unless
    ...  '${check_blackbox_info[0]}'=='PASS' and '${check_blackbox_date[0]}'=='PASS'  fail  blackbox info ${last_line} incorrect  console=yes

Check Date
    ${reset_date_mod}  replace string  ${RESET_DATE}  ${space}  T
    ${reset_date_mod}  get substring  ${reset_date_mod}  0  16
    ${check_blackbox_date}  run keyword and ignore error  should contain  ${last_line}  ${reset_date_mod}
    ${RESET_DATE}  DateTime.add time to date  ${RESET_DATE}  00:01:00.000
    set test variable  ${RESET_DATE}
    set test variable  ${check_blackbox_date}

TC Setup
    Common Test Setup

TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Common Test Teardown


