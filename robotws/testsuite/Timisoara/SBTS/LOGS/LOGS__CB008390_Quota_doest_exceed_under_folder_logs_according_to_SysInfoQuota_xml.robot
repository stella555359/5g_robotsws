*** Settings ***
Library     ute_syslog
Library     taf.sbts.oam.coam.admin  WITH NAME  coam
Resource    ../resources/verdicts.robot
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot

*** Variables ***
${SNAPSHOT_TIMEOUT}      600

*** Keywords ***
TC__LOGS__CB008390_Quota_doest_exceed_under_folder_logs_according_to_SysInfoQuota_xml

    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-25593
    ...  ******************
    ...  Author: Jakub Kokoszka
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 2023-06-21 - TAT-25593 - Initial Creation
    ...  ******************
    ...  Basic information
    ...  *****************
    ...  Test case to check if Quota doest exceed under folder logs according to SysInfoQuota.xml
    ...  check if record AASYSINFO_FS_OVERLOAD_IND_MSG exist in syslog
    ...  *******************
    ...  Test case flowchart:
    ...  http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/
    ...  LOGS__CB008390_Quota_doest_exceed_under_folder_logs_according_to_SysInfoQuota_xml.png
    ...  *******************

    Set Tags   LOGS    AUTHOR-jakub.kokoszka@nokia.com
    ...    MAINTAINER-jakub.kokoszka@nokia.com    GROUP_IN_CHARGE-WRO_6_Vrf    PHASE-CRT    SW-SBTS23R4

    Step 0: Preconditions
    Step 1: Collect Snapshot
    Step 2: Check Syslog File


Step 0: Preconditions
    [Documentation]
    ...  In this test step test start syslog and waiting 20min

    Log  \nStep 0: Preconditions  console=${True}
    Run    mkdir ${BTS_Files}/syslog
    Run    mkdir ${BTS_Files}/snapshot
    Log    Syslog start    console=${True}
    ute_syslog.Start Syslog    log_dir=${BTS_Files}/syslog    log_name=syslog    ip=${SMOD1["UDP_IP"]}  ports=@{UDP ports}
    Log    Sleeping 20m...    console=${True}
    Sleep    20m

Step 1: Collect Snapshot
    [Documentation]
    ...  In this test step test collect snapshot and stop syslog

    Log  \nStep 1: Collect snapshot    console=${True}
    ${snapshot_status}    Run Keyword And Return Status
    ...    coam.Collect Snapshot    ${BTS_Files}/snapshot/snapshot.zip
    ...    coverage=Full  timeout=${SNAPSHOT_TIMEOUT}
    Run Keyword If    ${snapshot_status}
    ...    Log    Collecting snapshot via admin succeeded    console=${True}
    ...    ELSE
    ...    verdicts.Set Test Failed  TC failed - Collecting snapshot using admin has failed.  ${True}
    Log    Syslog stop    console=${True}
    ute_syslog.Collect syslog results    destination=${BTS_Files}/syslog


Step 2: Check Syslog File
    [Documentation]
    ...  In this test step test check if AASYSINFO_FS_OVERLOAD_IND_MSG exist in syslog

    Log  \nStep 2: Check syslog file    console=${True}
    ${AASYSINFO_FS_OVERLOAD_IND_MSG_prints}    Run    grep 'AASYSINFO_FS_OVERLOAD_IND_MSG' ${BTS_Files}/syslog/syslog
    ${isEmpty}  Get length  ${AASYSINFO_FS_OVERLOAD_IND_MSG_prints}
    Run Keyword If  ${isEmpty}!=0    Run Keywords
    ...   Log    Snapshot path: ${BTS_Files}/snapshot/snapshot.zip
    ...   AND    Log   Syslog path: ${BTS_Files}/syslog/syslog
    ...   AND    verdicts.Set Test Failed  AASYSINFO_FS_OVERLOAD_IND_MSG_prints available.    ${True}
    ...   ELSE   Log   AASYSINFO_FS_OVERLOAD_IND_MSG_prints doesn't exist   console=true


TC Setup
    Common Test Setup    syslog_launch=${False}

TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Common Test Teardown
