*** Settings ***
Documentation
...  AUTHOR-daniel.bartkowiak@nokia.com  MAINTAINER-daniel.bartkowiak@nokia.com
...  [CASE LINK]: https://rep-portal.ext.net.nokia.com/details/qc-case/3959526/
...
...  *****************
...  Basic information
...  *****************
...
...  Step 1 Baseband Module Reset
...  Perform baseband module reset with graceful shutdown from Admin API with desired procedure timeout.
...  Selected baseband module serial numbers are going to be tested.
...
...  Step 2 BTS Availability Check After Baseband Module Reset
...  Checking all cells, modules and faults. After that if are incorrect test fail, otherwise test pass.
...  KPIbbmodreset is gathered and varificated on user demand.
...
...  possible variables available to set by user:
...  'BBMOD_STARTUP_TIMEOUT'  ( seconds )-   startup site reset time defined for tested configuration,
...  if not provided default value from varaibles file will be use, - seconds
...  'CUSTOM_EXPECTED_BBMOD_RESET_TIME'  ( seconds ) -  expected value for startup kpi1c,
...  if not provided testcase will not use startup value as verdict
...  'CUSTOM_KPI_CALCULATION'  -  (${TRUE} or ${FALSE}) - user can disable kpi calculation
...  'BB_LIST' - user can select desired sn of BBMOD for testing. If not set all BBMODs are taken.
...
...  Disclaimer: Exceptionaly in this TC there is imported other twin-like testcase 'SiSo_STARTUP_Baseband_Module_Reset.robot'
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

Resource  ./SiSo_STARTUP_Baseband_Module_Reset.robot

*** Variables ***
${BBMOD_STARTUP_TIMEOUT}
#${CUSTOM_EXPECTED_BBMOD_RESET_TIME}
${CUSTOM_KPI_CALCULATION}=  ${TRUE}
@{BB_LIST}

*** Keywords ***
Automated_SiSo_BTS_Startup_Multiple_Baseband_Module_Reset_With_Graceful_Shutdown
    Set Tags  AUTHOR-daniel.bartkowiak@nokia.com  MAINTAINER-daniel.bartkowiak@nokia.com
    Common Test Setup
    ${bb_modules_dict}=  Baseband Module Reset Preconditions
    FOR  ${bb_sn}  IN  @{bb_modules_dict}
      Step 1 Baseband Module Reset  bb_dict=${bb_modules_dict['${bb_sn}']}  bb_sn=${bb_sn}  graceful=${TRUE}
      Step 2 BTS Availability Check After Baseband Module Reset  bts=${bb_modules_dict['${bb_sn}']['bb_bts']}  bb_sn=${bb_sn}
    END
    [Teardown]  Common Test Teardown
