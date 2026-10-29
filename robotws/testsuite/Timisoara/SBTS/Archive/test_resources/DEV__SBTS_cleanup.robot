*** Settings ***
Resource    ../../common_resources/ca_CIT_general.robot


*** Variables ***
${CLEANUP_SMOD2}  ${TRUE}  # set parameter if cleanup should also happen on secondary core


*** Keywords ***
TC__DEV__SBTS_cleanup
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-23148
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...
    ...  Test case to remove any snapshot files on either partition of the SBTS.
    ...  It can also remove the files from a secondary core if it exists.
    ...  This TC is mostly meant for cleanup, and does not test actual functionality or features.
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 26.05.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23148 - TC creation
    ...
    ...
    Perform SBTS Cleanup  ${SMOD1["IP"]}  ${SMOD1["USERNAME"]}  ${SMOD1["PASSWORD"]}
    Run Keyword If  ${CLEANUP_SMOD2} and ${SMOD2_exists}
    ...  Perform SBTS Cleanup  ${SMOD2["IP"]}  ${SMOD2["USERNAME"]}  ${SMOD2["PASSWORD"]}


Perform SBTS Cleanup
    [Arguments]  ${ip}  ${username}  ${password}
    SSHLibrary.Open Connection  ${ip}
    SSHLibrary.Login  ${username}  ${password}

    ${stdout}  Execute Command  rm -v /ffs/run/trs_data/db/*snapshot*
    Log  ${stdout}  console=${TRUE}

    ${stdout}  Execute Command  rm -v /ffs/stb/trs_data/db/*snapshot*
    Log  ${stdout}  console=${TRUE}

    SSHLibrary.Close Connection


TC Setup
    Common Test Setup  admin_launch=${FALSE}  syslog_launch=${FALSE}  infomodel_launch=${FALSE}
    ...  btssm_launch=${FALSE}


TC Teardown
    Common Test Teardown  collect_snapshot=never
