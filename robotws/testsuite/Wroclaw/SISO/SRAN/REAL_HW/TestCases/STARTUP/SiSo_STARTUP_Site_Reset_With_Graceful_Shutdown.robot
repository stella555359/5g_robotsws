*** Settings ***
Documentation
...  AUTHOR-daniel.bartkowiak@nokia.com  MAINTAINER-daniel.bartkowiak@nokia.com
...  [CASE LINK]: https://rep-portal.ext.net.nokia.com/details/qc-case/3959451/
...
...  *****************
...  Basic information
...  *****************
...
...  Step 1 Site reset
...  Site reset procedure is executed with enabled graceful shutdown - dedicated timeout is set.
...
...  Step 2 BTS availability
...  Checking all cells, modules and faults. After that if are incorrect test fail, otherwise test pass.
...  KPI1a, KPI1b, KPI1c are gathered and varificated on user demand
...
...  possible variables available to set by user:
...  ${CONFIGURATION_STARTUP_TIMEOUT}  ( seconds )-   startup site reset time defined for tested configuration,
...  if not provided default value from varaibles file will be use, - seconds
...  ${CUSTOM_EXPECTED_SITE_RESET_TIME}  ( seconds ) -  expected value for startup kpi1c,
...  if not provided testcase will not use startup value as verdict
...  ${CUSTOM_KPI_CALCULATION}  -  (${True} or ${False}) - user can disable kpi calculation
...
...  Disclaimer: Exceptionaly in this TC there is imported other twin-like testcase 'SiSo_STARTUP_Site_Reset.robot'
...  for reusage purposes. If any corrections needed consider verification in both TCs.
...
...  NOTE. If test used with OBSAI RUs (dual link), fault 1811 Warning can appear. Please adjust accordingly your TS allowed faults.
...
...  ******************
...  History of changes
...  ******************
...  - 07.05.2024 - Initial creation
...  - 16.10.2024 - Correction according Graceful Cell Shutdown - https://jiradc.ext.net.nokia.com/browse/FCA_VRF_SISO-12347
...  - 26.11.2024 - Adding documentation extension regarding fault 1811 - https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-48966

Resource  ./SiSo_STARTUP_Site_Reset.robot

*** Variables ***
${CONFIGURATION_STARTUP_TIMEOUT}
#${CUSTOM_EXPECTED_SITE_RESET_TIME}
${CUSTOM_KPI_CALCULATION}=  ${TRUE}

*** Keywords ***

Automated_SiSo_BTS_Startup_Multiple_Site_Reset_With_Graceful_Shutdown
    Set Tags  AUTHOR-daniel.bartkowiak@nokia.com  MAINTAINER-daniel.bartkowiak@nokia.com
    Common Test Setup
    Logging With Timestamp
    ...  message=Site Reset TC for every node on list : @{CFG.active_bts_list} will be executed
    ...  style=ONGOING
    FOR  ${bts}  IN  @{CFG.active_bts_list}
      Step 1 Site reset  bts=${bts}  graceful=${TRUE}
      Step 2 BTS availability  bts=${bts}
    END
    [Teardown]  Common Test Teardown
