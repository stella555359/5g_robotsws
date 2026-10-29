*** Settings ***
Library    taf.sbts.oam.coam.admin  WITH NAME  coam
Library    taf.ul.verify_snapshot   WITH NAME  snapshot
Library    SSHLibrary
Library    OperatingSystem
Resource    ../resources/verdicts.robot
Resource    ../resources/unpacking.robot
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot

*** Variables ***
${SNAPSHOT_TIMEOUT}      900                      #timeout for collect snapshot via Admin (in sec)
${DOCUMENTATION_PATH}  /home/ute/btsauto/snapshot_documentation  # Path to snapshot documentation archive directory.

*** Keywords ***
TC__LOGS__Collecting_of_new_logfile_with_the_BTS_snapshot
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-18613
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  The purpose of this test case is to check if all prints related with added new packet filter rule are
	...  in snapshot content
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 2020-04-11 - https://jira3.ext.net.nokia.com/browse/TAT-19935 - add: Download <SW>_snapshot_documentation.tgz file
    ...  - 2020-12-22 - https://jira3.ext.net.nokia.com/browse/TAT-20685 - change path to doc file. (Iuliia Taupeka)
    ...  - 2021-12-22 - TAT-22173 - Changes done due to CNI-61110 - move to hran_frame_sbts_siso
    ...  - 2022-07-19 - https://jiradc.ext.net.nokia.com/browse/TAT-23414 - KW(placeholder) Common step trigger for
    ...                 checking sleeping cells added in TC Teardown due to BIT CS4.3 Enable Sleeping Cell
    ...  - 10.03.2023 - TAT-24917 - Hran_frame resource name change to ca_pm_logs_frame
    ...  - 2023-03-24 - https://jiradc.ext.net.nokia.com/browse/TAT-25033 - update new link for download the <SW>_snapshot_documentation.tgz file
    ...  - 2023-04-24 - TAT-25131 - hran_snapshot analysis refactoring to taf.ul.verify_snapshot UL usage
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  image: https://tatools.emea.nsn-net.net/static/hran_doc/LOGS__Collecting_of_new_logfile_with_the_BTS_snapshot.jpg


    Set Tags    CA-LOGS    OWNER-tomasz.marchewka@nokia.com    AUTHOR-tomasz.marchewka@nokia.com
    ...    MAINTAINER-iuliia.taupeka@nokia.com    PHASE-CR1    SW-SBTS20    GROUP_IN_CHARGE-WRO_6_Vrf

    Step 0: Check and untar snapshot documentation archive
    Step 1: Open SSH connection
    Step 2: Execute SSH commands to collect log files with dropped packets
    Step 3: Log file content check
    Step 4: Collect Snapshot
    Step 5: Verify content of new log files
    Step 6: Check content of snapshot documentation archive


Step 0: Check and untar snapshot documentation archive

    Log  \nStep 0: Check and untar snapshot documentation archive

    Log    \n Get Active Sw Version  console=${true}
    coam.Setup Admin    bts_host=192.168.255.129   bts_port=443    use_ssl=True    alias=new_logfile
    ${SW}  coam.Get Sw Version
    Log    Active Sw Version: ${SW}  console=${true}
    @{SW_splited}    Split String    ${SW}    _
    ${BRANCH}=    Remove String Using Regexp  ${SW_splited[0]}  SBTS
    ${SW_00}=    Replace String Using Regexp  ${SW}  ${BRANCH}  00
    OperatingSystem.Run  mkdir -p ${DOCUMENTATION_PATH}
    Log  Download <SW>_snapshot_documentation.tgz file  console=${true}
    Run Keyword If  ${SW_splited[2]}==9999
    ...  OperatingSystem.Run
    ...  cd ${DOCUMENTATION_PATH} ; wget ${BUILD_PATH}/SBTS00/${SW_00}/${SW_00}_snapshot_documentation.tgz
    ...  ELSE
    ...  OperatingSystem.Run  cd ${DOCUMENTATION_PATH} ; wget ${BUILD_PATH}/SBTS${BRANCH}/${SW}/${SW}_snapshot_documentation.tgz
    Sleep  30

    ${FILES_IN_DIRECTORY}  OperatingSystem.List Files In Directory  ${DOCUMENTATION_PATH}
    Set Test Variable  ${FILES_IN_DIRECTORY}
    ${FILES_IN_DIRECTORY_QTY}  Get Length  ${FILES_IN_DIRECTORY}
    Set Test Variable  ${FILES_IN_DIRECTORY_QTY}
    FOR  ${i}  IN RANGE  0  ${FILES_IN_DIRECTORY_QTY}
        ${documentation_file_name}=   Run Keyword And Ignore Error   Should Match Regexp   ${FILES_IN_DIRECTORY[${i}]}  .*snapshot_documentation.tgz
        Run Keyword If  '${documentation_file_name[0]}'=='PASS'
        ...  Log  Documentation file .*snapshot_documentation.tgz is present under ${DOCUMENTATION_PATH} directory  level=INFO  console=${true}
        ...  ELSE
        ...  Run Keyword If  '${documentation_file_name[0]}'=='FAIL'
        ...  verdicts.Set Test Failed
        ...  TC failed - Documentation file .*snapshot_documentation.tgz is not present under ${DOCUMENTATION_PATH} directory.  ${TRUE}
    END

    unpacking.Unpack Archive Content To Directory  ${DOCUMENTATION_PATH}/${documentation_file_name[1]}  ${DOCUMENTATION_PATH}/extracted


Step 1: Open SSH connection
    Log  \nStep 1: Open SSH Connection  console=${True}
    SSHLibrary.Open Connection                          ${SMOD1['IP']}
    ${ssh_status}  Run Keyword And Return Status
    ...  SSHLibrary.Login                               ${SMOD1['USERNAME']}    ${SMOD1['PASSWORD']}
    Run Keyword If  ${ssh_status}
    ...  Log  Opening SSH session succeeded  level=INFO   console=${true}
    ...  ELSE
    ...  verdicts.Set Test Failed  TC failed - Open SSH connection failure.  ${TRUE}


Step 2: Execute SSH commands to collect log files with dropped packets
    Log  \nStep 2: Execute SSH commands to collect log files with dropped packets  console=${True}
    SSHLibrary.Execute Command                          iptables -I INPUT -j LOG --log-prefix "IPTABLES_DROP " --log-level 4
    Sleep  150s
    ${listening_status}   Run Keyword And Return Status
    ...  SSHLibrary.Execute Command                     iptables -D INPUT -j LOG --log-prefix "IPTABLES_DROP " --log-level 4
    Sleep  60s
    Run Keyword If   ${listening_status}
    ...  Log   Log files with dropped packets are collected   level=INFO   console=${true}
    ...  ELSE
    ...  verdicts.Set Test Failed  TC failed - Failure of listening dropped traffic packets.  ${TRUE}


Step 3: Log file content check
    Log  \nStep 3: Log file content check  console=${True}
    ${local_path}=  SSHLibrary.Get File                 /var/log/firewall*   ${BTS_Files}/
    SSHLibrary.Get File    /var/log/firewall   ${BTS_Files}/
    SSHLibrary.close connection
    ${firewall_file}=  OperatingSystem.get file         ${BTS_Files}/firewall    encoding_errors=ignore
    ${file_content}=  Run Keyword And Return Status    Should Contain     ${firewall_file}   IPTABLES_DROP
    Run Keyword If   '${file_content}'=='True'
    ...  Log  Traffic prints are located in /var/log/firewall   level=INFO   console=${true}
    ...  ELSE
    ...  verdicts.Set Test Failed  TC failed - iptables log prints are not redirected to /var/log/firewall.  ${TRUE}


Step 4: Collect Snapshot
    Log  \nStep 4: Collect Snapshot  console=${True}
    ${timestamp}=  Get time
    ${timestamp}=  Replace string using regexp  ${timestamp}  (${SPACE}|:|-)  _
    ${snapshot_status}=  Run Keyword And Ignore Error  coam.Collect Snapshot   ${BTS Files}/snapshot_${timestamp}.zip  timeout=${SNAPSHOT_TIMEOUT}
    Run Keyword If   '${snapshot_status[0]}'=='PASS'
	...  Log  Collecting snapshot via admin succeeded  console=${True}
	...  ELSE
	...  verdicts.Set Test Failed  TC failed - Collecting snapshot using admin has failed.  ${TRUE}
	${path_to_snapshot}=  Set Variable  ${BTS Files}/snapshot_${timestamp}.zip
	Set Test Variable  ${path_to_snapshot}  ${BTS Files}/snapshot_${timestamp}.zip


Step 5: Verify content of new log files
    Log  \nStep 5: Verify content of new log files  console=${True}
    @{list_of_mandatory_files}=  Create List  .*(?:firewall)$   .*firewall.*[1-4]+\.(gz)$   .*(?:firewall.boot)+\.(gz)$
    ${mandatory_files}=  Create Dictionary  mandatory_file=${list_of_mandatory_files}  not_mandatory_file=${EMPTY}
    ${file_dict}  snapshot.Get Data From Snapshot  ${path_to_snapshot}
    ${snap_content}   Run Keyword And Return Status
    ...  snapshot.Validate Snapshot Using Custom Data   ${file_dict}   ${mandatory_files}
    Run Keyword If   '${snap_content}'=='True'
    ...  Log  Verification of snapshot content succeeded   level=INFO   console=${true}
    ...  ELSE
    ...  verdicts.Set Test Failed  TC failed - Log files with dropped packets are not located in snapshot.  ${TRUE}


Step 6: Check content of snapshot documentation archive
    Log  \nStep 6: Check content of snapshot documentation archive  console=${True}
    ${FILES_IN_DIRECTORY}  OperatingSystem.List Files In Directory  ${DOCUMENTATION_PATH}/extracted/psrel-sysroot/C_Platform/test_autom
    Set Test Variable  ${FILES_IN_DIRECTORY}
    ${status}=   Run Keyword And Return Status  List Should Contain Value  ${FILES_IN_DIRECTORY}  trs.txt
    Run Keyword If   ${status}==True
    ...  Log  Documentation file trs.txt is present under ${DOCUMENTATION_PATH}/extracted/psrel-sysroot/C_Platform/test_autom  console=${true}
    ...  ELSE
    ...  verdicts.Set Test Failed
    ...  TC failed - Documentation file trs.txt is not present under ${DOCUMENTATION_PATH}/extracted/psrel-sysroot/C_Platform/test_autom.  ${TRUE}


Test Specific Teardown
    Log  \nTest teardown which closing shh connection  console=${True}
    ${ssh_connection}   SSHLibrary.Get Connections
    Run Keyword If  '${ssh_connection.index}' != 'None'  run keywords
    ...  SSHLibrary.Close All Connections
    ...  AND
    ...  Log  Closing all open connections  console=${True}


TC Setup
    Common Test Setup

TC Teardown
    Run keywords
    ...    interface.Common step trigger
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Test Specific Teardown
    ...    AND    Common Test Teardown


