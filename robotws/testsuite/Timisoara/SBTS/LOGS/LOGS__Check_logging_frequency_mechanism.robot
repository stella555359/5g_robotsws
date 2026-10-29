*** Settings ***
Library    taf.sbts.oam.coam.admin  WITH NAME  coam
Library    SSHLibrary
Resource    ../resources/verdicts.robot
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot

*** Variables ***


*** Keywords ***
TC__LOGS__check_logging_frequency_mechanism
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-18612
    ...
    ...  *****************
    ...  The purpose of this test case is to check if all prints related with added new packet filter rules are
    ...  redirecting as iptablesdrop log files to defined path on BTS
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 2021-12-22 - https://jira3.ext.net.nokia.com/browse/TAT-22173 - Changes done due to CNI-61110 - move to hran_frame_sbts_siso
    ...  - 2022-07-19 - https://jiradc.ext.net.nokia.com/browse/TAT-23414 - KW(placeholder) Common step trigger for
    ...                 checking sleeping cells added in TC Teardown due to BIT CS4.3 Enable Sleeping Cell
    ...  - 2023-02-06 - https://jiradc.ext.net.nokia.com/browse/TAT-24626 - adding sleep in step 3 to wait
    ...                 untill all files will be zipped and unzipped files will be removed.
    ...  ...  - 10.03.2023 - TAT-24917 - Hran_frame resource name change to ca_pm_logs_frame
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  image: https://tatools.emea.nsn-net.net/static/hran_doc/LOGS__check_logging_frequency_mechanism.jpg


    Set Tags    CA-LOGS    OWNER-tomasz.marchewka@nokia.com    AUTHOR-tomasz.marchewka@nokia.com
    ...    MAINTAINER-iuliia.taupeka@nokia.com    PHASE-CR1    SW-SBTS20    GROUP_IN_CHARGE-WRO_6_Vrf

    Step 1: Open SSH connection
    Step 2: Execute SSH commands to collect log files with dropped packets
    Step 3: Log file content check


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
    Log  \nStep 2: Execute iptables command to start listening of dropped packets  console=${True}
    SSHLibrary.Execute Command                          iptables -I INPUT -j LOG --log-prefix "IPTABLES_DROP " --log-level 4
    Sleep  150s
    ${listening_status}   Run Keyword And Return Status
    ...  SSHLibrary.Execute Command                     iptables -D INPUT -j LOG --log-prefix "IPTABLES_DROP " --log-level 4
    Run Keyword If   ${listening_status}
    ...  Log   Log files with dropped packets collected   level=INFO   console=${true}
    ...  ELSE
    ...  verdicts.Set Test Failed  TC failed - Failure of listening dropped traffic packets.  ${TRUE}

Step 3: Log file content check
    Log  \nStep 3: Log file content check  console=${True}
    Log    Sleep 120s   console=${true}
    Sleep  120s
    ${local_path}=  SSHLibrary.Get File                 /var/log/firewall*   ${BTS_Files}/
    SSHLibrary.Get File    /var/log/firewall   ${BTS_Files}/
    SSHLibrary.close connection
    ${firewall_file}=  OperatingSystem.get file         ${BTS_Files}/firewall    encoding_errors=ignore
    ${file_content}=  Run Keyword And Return Status     Should Contain     ${firewall_file}  IPTABLES_DROP
    Run Keyword If  ${file_content}
    ...     Log    Traffic prints are located in /var/log/firewall   level=INFO   console=${true}
    ...     ELSE
    ...     verdicts.Set Test Failed  TC failed - iptables log prints are not redirected to /var/log/firewall.  ${TRUE}

Test Specific Teardown
    [Documentation]  Test teardown which closing shh connection
    Log    \n----- Test teardown which closing shh connection----- \n    console=${True}
    ${ssh_connection}   SSHLibrary.Get Connections
    Run Keyword If  '${ssh_connection.index}' != 'None'  run keywords
    ...  SSHLibrary.Close All Connections
    ...  AND
    ...  log  Closing all open connections  console=${True}


TC Setup
    Common Test Setup

TC Teardown
    Run keywords
    ...    interface.Common step trigger
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Test Specific Teardown
    ...    AND    Common Test Teardown


