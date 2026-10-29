*** Settings ***
Documentation  This suite contains KWs used by ONAP TCs

Library  python_resources/PM/ONAP_keywords.py
Resource  ca_SBTS_general.robot


*** Variables ***
${GET_CURRENT_PM_COMMAND}  ls -l /data/onapusers/measurements | tail -n 1
${PANO_PATH}  /home/ute/pano
${PANO_LOGS_PATH}  /home/ute/.local/pano/logs


*** Keywords ***
ONAP 5GC001556 Test Setup
    [Documentation]  This keywords is setting variables and opens connections for TCs from 5GC001556 feature.
    ...  Variables that need to be set before calling this keyword:
    ...  - robot suite variables: ${VM_WITH_PANO_IP}, ${VM_WITH_PANO_USR}, ${VM_WITH_PANO_PASSWD}

    Log  \nONAP 5GC001556 Test Setup  console=true
    Turn ON Pano And Check If Is Connected  ${VM_WITH_PANO_IP}  ${VM_WITH_PANO_USR}  ${VM_WITH_PANO_PASSWD}
    ${original_bts_name}  Get Bts Name
    Set Test Variable  ${ORIGINAL_BTS_NAME}
    ${nrbts_id}  Admin Get NRBTS ID
    Set Test Variable  ${NRBTS_ID}
    ${nr_cell_number}  Get NR Cell Number
    Set Test Variable  ${NR_CELL_NUMBER}
    ${mplane_ip}  Admin Get MPLANE IP
    Set Test Variable  ${MPLANE_IP}
    Set IPIF Interface
    Prepare Json IPv4
    Connect BTS To ONAP
    Remove Files  MRBTS*.xml
    Remove Files  MRBTS*.gz
    Log  End of ONAP 5GC001556 Test Setup  console=true


ONAP 5GC001556 Test Teardown
    [Documentation]  This keywords closes connections for TCs from 5GC001556 feature.
    ...  Variables that need to be set before calling this keyword:
    ...  - test variable: ${ORIGINAL_BTS_NAME}
    ...  - robot suite variables: ${VM_WITH_PANO_IP}, ${VM_WITH_PANO_USR}, ${VM_WITH_PANO_PASSWD}

    Log  \nONAP 5GC001556 Test Teardown  console=true
    Change BTS Name  ${ORIGINAL_BTS_NAME}
    Remove ONAP From SCF
    Turn OFF Pano And Check If Is Disconnected  ${VM_WITH_PANO_IP}  ${VM_WITH_PANO_USR}  ${VM_WITH_PANO_PASSWD}
    Remove Cell Name
    Log  End of ONAP 5GC001556 Test Teardown  console=true


ONAP 5GC001104 Test Setup
    [Documentation]  This keywords is setting variables and opens connections for TCs from 5GC001104 feature.
    ...  Variables that need to be set before calling this keyword:
    ...  - robot suite variables: ${VM_WITH_PANO_IP}, ${VM_WITH_PANO_USR}, ${VM_WITH_PANO_PASSWD}

    Log  \nONAP 5GC001104 Test Setup  console=true
    Turn ON Pano And Check If Is Connected  ${VM_WITH_PANO_IP}  ${VM_WITH_PANO_USR}  ${VM_WITH_PANO_PASSWD}
    ${nrbts_id}  Admin Get NRBTS ID
    Set Test Variable  ${NRBTS_ID}
    Set IPIF Interface
    Prepare Json IPv4
    Connect BTS To ONAP
    Remove Files  MRBTS*.xml
    Remove Files  MRBTS*.gz
    Log  End of ONAP 5GC001104 Test Setup  console=true


ONAP 5GC001104 Test Teardown
    [Documentation]  This keywords closes connections for TCs from 5GC001104 feature.
    ...  Variables that need to be set before calling this keyword:
    ...  - robot suite variables: ${VM_WITH_PANO_IP}, ${VM_WITH_PANO_USR}, ${VM_WITH_PANO_PASSWD}

    Log  \nONAP 5GC001104 Test Teardown  console=true
    Remove ONAP From SCF
    Turn OFF Pano And Check If Is Disconnected  ${VM_WITH_PANO_IP}  ${VM_WITH_PANO_USR}  ${VM_WITH_PANO_PASSWD}
    Log  End of ONAP 5GC001104 Test Teardown  console=true


ONAP CB007010 Test Setup
    [Documentation]  This keywords is setting variables and opens connections for TCs from CB007010 feature.
    ...  Variables that need to be set before calling this keyword:
    ...  - robot suite variables: ${VM_WITH_PANO_IP}, ${VM_WITH_PANO_USR}, ${VM_WITH_PANO_PASSWD}

    Log  \nONAP CB007010 Test Setup  console=true
    Turn ON Pano And Check If Is Connected  ${VM_WITH_PANO_IP}  ${VM_WITH_PANO_USR}  ${VM_WITH_PANO_PASSWD}
    Set IPIF Interface
    Prepare Json IPv4
    Connect BTS To ONAP
    Remove Files  MRBTS*.xml
    Remove Files  MRBTS*.gz
    Log  End of ONAP CB007010 Test Setup  console=true


ONAP CB007010 Test Teardown
    [Documentation]  This keywords closes connections for TCs from CB007010 feature.
    ...  Variables that need to be set before calling this keyword:
    ...  - robot suite variables: ${VM_WITH_PANO_IP}, ${VM_WITH_PANO_USR}, ${VM_WITH_PANO_PASSWD}

    Log  \nONAP CB007010 Test Teardown  console=true
    Remove ONAP From SCF
    Turn OFF Pano And Check If Is Disconnected  ${VM_WITH_PANO_IP}  ${VM_WITH_PANO_USR}  ${VM_WITH_PANO_PASSWD}
    Log  End of ONAP CB007010 Test Teardown  console=true


Turn ON Pano And Check If Is Connected
    [Documentation]  This keyword is starting pano session on VM dedicated. Two ssh connections are opened. The one with start_pano alias will stay
    ...  opened until the end of test case when pano is turned off by 'pano stop-ves' command. This keyword only close the default ssh connection.
    [Arguments]  ${pano_vm_ip}  ${pano_vm_usr}  ${pano_vm_passwd}

    ${default_connection}  SSHLibrary.Open Connection  ${pano_vm_ip}
    SSHLibrary.Login  ${pano_vm_usr}  ${pano_vm_passwd}
    ${pano_dir_exist}  Run Keyword And Return Status  SSHLibrary.Directory Should Exist  ${PANO_PATH}
    Run Keyword If  not ${pano_dir_exist}
    ...  SSHLibrary.Execute command  mkdir ${PANO_PATH}

    Set Client Configuration  prompt=$
    SSHLibrary.Write  cd ${PANO_PATH}; pano status
    Sleep  10s  Time for status to be written in console output.
    ${msg_pano_status}  SSHLibrary.Read Until Prompt
    ${pano_is_running}  Run Keyword And Return Status
    ...  Should Contain  ${msg_pano_status}  Checking VES statistics:
    Return From Keyword If  ${pano_is_running}

    Log  \nTurn ON Pano  console=true
    SSHLibrary.Open Connection  ${pano_vm_ip}  alias=start_pano
    SSHLibrary.Login  ${pano_vm_usr}  ${pano_vm_passwd}
    SSHLibrary.Write  cd ${PANO_PATH}; pano start-ves
    Sleep  10s  Time for logs to be written in console output.
    ${msg_pano_start}  SSHLibrary.Read
    Should Contain  ${msg_pano_start}  HTTP Server start...

    SSHLibrary.Switch Connection  ${default_connection}
    SSHLibrary.Write  pano status
    Sleep  10s  Time for status to be written in console output.
    ${msg_pano_status}  SSHLibrary.Read Until Prompt
    Should Contain  ${msg_pano_status}  Checking VES statistics:

    [Teardown]  SSHLibrary.Close Connection


Turn OFF Pano And Check If Is Disconnected
    [Documentation]  This keyword is closing all pano sessions on VM dedicated.
    [Arguments]  ${pano_vm_ip}  ${pano_vm_usr}  ${pano_vm_passwd}

    Log  \nTurn OFF Pano  console=true
    Run  sshpass -p "${pano_vm_passwd}" scp ${pano_vm_usr}@${pano_vm_ip}:${PANO_LOGS_PATH}/pano.log ${BTS_FILES}
    Run  sshpass -p "${pano_vm_passwd}" scp -r ${pano_vm_usr}@${pano_vm_ip}:${PANO_PATH}/pm/ ${BTS_FILES}/
    SSHLibrary.Open Connection  ${pano_vm_ip}
    SSHLibrary.Login  ${pano_vm_usr}  ${pano_vm_passwd}
    SSHLibrary.Execute Command  cd ${PANO_PATH}; pano stop-ves
    Sleep  10s  Time for pano server to be fully stopped.
    Set Client Configuration  prompt=$
    SSHLibrary.Write  pano status
    Sleep  10s  Time for status to be written in console output.
    ${msg_pano_status}  SSHLibrary.Read until prompt
    Should Contain  ${msg_pano_status}  Failed to get VES statistics
    SSHLibrary.Execute Command  rm -rf ${PANO_PATH}/pm/*.*
    SSHLibrary.Execute Command  rm -rf ${PANO_PATH}

    [Teardown]  SSHLibrary.Close All Connections


Change BTS Name
    [Documentation]  This keyword is changing BTS name with the given argument value.
    ...  Variables that need to be set before calling this keyword:
    ...  - test variable: ${BTS_ID}
    [Arguments]  ${bts_name}=bts@test

    Perform Parameter Recommissioning  dist_name=MRBTS-${BTS_ID}  parameter=btsName  value=${bts_name}  operation=update
    ...  skip_parameter_relation_errors=false  timeout=180


Change Cell Name
    [Documentation]  This keyword is changing NR cell name with the given argument value.
    ...  Variables that need to be set before calling this keyword:
    ...  - test variables: ${BTS_ID}, ${NRBTS_ID}, ${NR_CELL_NUMBER}
    [Arguments]  ${cell_name}=@test_cell!

    Perform Parameter Recommissioning  dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${NR_CELL_NUMBER}  parameter=cellName  value=${cell_name}
    ...  operation=update  skip_parameter_relation_errors=false  timeout=180


Get NR Cell Number
    [Documentation]  This keyword is returning the first NR cell id.

    ${nr_ids}  Get Ids For All  NRCEL
    ${nr_cell_number}  Fetch From Right  ${nr_ids}[0]  -

    [Return]  ${nr_cell_number}


Remove Cell Name
    [Documentation]  This keyword is removing the first NR cell id.
    ...  Variables that need to be set before calling this keyword:
    ...  - test variables: ${BTS_ID}, ${NRBTS_ID}, ${NR_CELL_NUMBER}

    Perform Parameter Recommissioning  dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${NR_CELL_NUMBER}  parameter=cellName  value=
    ...  operation=delete  skip_parameter_relation_errors=false  timeout=180


Check PM For Custom Bts Name
    [Documentation]  This keyword is checking PM file to contain custom_bts_name given as argument.
    [Arguments]  ${pm_xml}  ${custom_bts_name}=bts@test

    ${xml}  Parse Xml  ${pm_xml}
    ${matches_list}  Get Elements  ${xml}  //measEntity[@userLabel="${custom_bts_name}"]
    ${length}  Get Length  ${matches_list}
    Should Not Be Equal As Numbers  ${length}  0  PM XML file doesn't contain custom BTS name: ${custom_bts_name}.


Check PM For Custom Cell Name
    [Documentation]  This keyword is checking PM file to contain custom_cell_name given as argument.
    [Arguments]  ${pm_xml}  ${custom_cell_name}=@test_cell!

    ${xml}  Parse Xml  ${pm_xml}
    ${matches_list}  Get Elements  ${xml}  //*[contains(@measObjLdn, '${custom_cell_name}')]
    ${length}  Get Length  ${matches_list}
    Should Not Be Equal As Numbers  ${length}  0  PM XML file doesn't contain custom cell name: ${custom_cell_name}.


Turn On Files Enrichment
    [Documentation]  This keyword is changing act3gppXmlEnrichment parameter value based on is_true given argument.
    ...  Variables that need to be set before calling this keyword:
    ...  - test variable: ${BTS_ID}
    [Arguments]  ${is_true}

    Perform Parameter Recommissioning  dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMCADM-1  parameter=act3gppXmlEnrichment  value=${is_true}
    ...  operation=update  skip_parameter_relation_errors=false  timeout=180


Remove Enrichment Parameter
    [Documentation]  This keyword is removing act3gppXmlEnrichment parameter.
    ...  Variables that need to be set before calling this keyword:
    ...  - test variable: ${BTS_ID}

    Perform Parameter Recommissioning  dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMCADM-1  parameter=act3gppXmlEnrichment  operation=delete  value=
    ...  skip_parameter_relation_errors=false  timeout=180


SCF Get Enrichment Status
    [Documentation]  This keyword returns act3gppXmlEnrichment value from SCF.
    [Arguments]  ${scf_file}

    ${out_scf_enrich}  Evaluate Xpath  source=${scf_file}  expression=string(//p[@name='act3gppXmlEnrichment']/text())

    [Return]  ${out_scf_enrich}


SFTP Download PM And Extract
    [Documentation]  This keyword is downloading PM files by SFTP on VM.
    [Arguments]  ${pm_to_download}

    Get PM By SFTP  ${pm_to_download}
    UNZIP PM On VM  ${pm_to_download}


Get PM By SFTP
    [Documentation]  This keyword is saving zip with PM files on VM.
    [Arguments]  ${pm_to_download}

    ONAP_keywords.Check Sftp For Pms  ${MPLANE_IP}  ${pm_to_download}


UNZIP PM On VM
    [Documentation]  This keyword is sending unzip command for PM archive.
    [Arguments]  ${pm_to_unzip}

    Run  gzip -dk ./${pm_to_unzip}


Wait Until New PM Is Available On BTS
    [Documentation]  This keyword Succeeds if there is a new PM file generated on BTS during 5min interval.
    ...  Variables that need to be set before calling this keyword:
    ...  - test variable: ${GET_CURRENT_PM_COMMAND}

    ssh.Connect To  ${OAM_BTS_IP}  ${OAM_BTS_USER}  ${OAM_BTS_PASSWORD}
    ${pm_out}  ssh.Execute  command=${GET_CURRENT_PM_COMMAND}  timeout=10s
    ssh.Disconnect
    ${latest_pm_on_bts}  ONAP_keywords.Get Pms Bts  ${pm_out}
    Should Not Be Empty  ${latest_pm_on_bts}
    Set Test Variable  ${FIRST_PM}  ${latest_pm_on_bts}
    Wait Until Keyword Succeeds  6min  5sec
    ...  Compare Last Two PMs On BTS


Compare Last Two PMs On BTS
    [Documentation]  This keyword is comparing the last two PM files from BTS.
    ...  Variables that need to be set before calling this keyword:
    ...  - test variables: ${FIRST_PM}, ${LATEST_PM_ON_BTS}

    Set Latest PM From BTS
    Should Not Be Equal  ${FIRST_PM}  ${LATEST_PM_ON_BTS}


Set Latest PM From BTS
    [Documentation]  Sets Suite Variable that holds whole name of the latest PM file on
    ...  BTS:/data/onapusers/measurements.
    ...  Variables that need to be set before calling this keyword:
    ...  - test variables: ${GET_CURRENT_PM_COMMAND}, ${LATEST_PM_ON_BTS}

    ssh.Connect To  ${OAM_BTS_IP}  ${OAM_BTS_USER}  ${OAM_BTS_PASSWORD}
    ${pm_out}  ssh.Execute  command=${GET_CURRENT_PM_COMMAND}  timeout=10s
    ${latest_pm_on_bts}  ONAP_keywords.Get Pms Bts  ${pm_out}
    Should Not Be Empty  ${latest_pm_on_bts}
    Set Test Variable  ${LATEST_PM_ON_BTS}

    [Teardown]  ssh.Disconnect


Remove ONAP From SCF
    [Documentation]  This keyword is removing ONAP object from SBTS.
    ...  Variables that need to be set before calling this keyword:
    ...  - test variables: ${BTS_ID}, ${COMMISSIONING_PATH}
    ...  - robot suite variable: ${TL_REPO_PATH}

    coam.Perform Commissioning  ${BTS_ID}  ${COMMISSIONING_PATH}  skip_parameter_relation_errors=True  timeout=900
    Wait Until Keyword Succeeds  20m  30s
    ...  Admin Check All Required State
    Remove File  ${TL_REPO_PATH}/ready_delta.json


Prepare Json IPv4
    [Documentation]  This keyword creates ready_delta.json file used for establishing ONAP connection.
    ...  Variables that need to be set before calling this keyword:
    ...  - test variables: ${BTS_ID}, ${INITIAL_IPIF}
    ...  - robot suite variables: ${TL_REPO_PATH}, ${VM_WITH_PANO_IP}, ${VES_PORT}

    ${base_delta}  Set Variable  ${TL_REPO_PATH}/deltaIPv4.json
    ${output_delta}  Set Variable  ${TL_REPO_PATH}/ready_delta.json
    Create File  ${output_delta}
    ONAP_keywords.Edit Json  ${base_delta}  ${output_delta}  ${BTS_ID}  ${INITIAL_IPIF}  ${VM_WITH_PANO_IP}  ${VES_PORT}


Connect BTS To ONAP
    [Documentation]  This keyword opens ONAP connection by creating MPLANEONAP object on SBTS.
    ...  Variables that need to be set before calling this keyword:
    ...  - robot suite variable: ${TL_REPO_PATH}

    ${mplane_onap_obj}  coam.Get Managed Objects  MPLANEONAP_R
    ${onap_ongoing}  Run Keyword And Return Status
    ...  Should Be Equal As Strings  ${mplane_onap_obj}[0][parameters][pnfRegistationStatus]  ongoing
    Return From Keyword If  ${onap_ongoing}

    Log  Connect BTS to ONAP  console=true
    Perform Delta Recommissioning  delta_file=${TL_REPO_PATH}/ready_delta.json  skip_parameter_relation_errors=${True}  timeout=900
    Wait Until Keyword Succeeds  20m  30s
    ...  Admin Check All Required State


Check Pano.Log For Latest PM
    [Documentation]  Succeeds if the newest PM file from BTS is visible in the file pano.log
    ...  Variables that need to be set before calling this keyword:
    ...  - test variables: ${BTS_ID}, ${LATEST_PM_ON_BTS}
    ...  - robot suite variables: ${TL_REPO_PATH}, ${VM_WITH_PANO_IP}, ${VM_WITH_PANO_USR}, ${VM_WITH_PANO_PASSWD}

    Log  Waiting Until New PM Is Available on BTS  console=true
    Wait Until New PM Is Available On BTS
    Log  Geting Latest PM from BTS  console=true
    Set Latest PM From BTS

    SSHLibrary.Open Connection  ${VM_WITH_PANO_IP}
    SSHLibrary.Login  ${VM_WITH_PANO_USR}  ${VM_WITH_PANO_PASSWD}
    Sleep  2s
    ${pano_log}  SSHLibrary.Execute Command  cat ${PANO_LOGS_PATH}/pano.log | grep MRBTS-${BTS_ID}
    SSHLibrary.Close Connection

    Should Not Contain  ${pano_log}  unexpected EOF while looking for matching
    Should Contain  ${pano_log}  ${LATEST_PM_ON_BTS}
