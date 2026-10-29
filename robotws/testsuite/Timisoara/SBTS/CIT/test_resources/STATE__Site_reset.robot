*** Settings ***
Documentation
    ...  Step 1: SBTS Site reset
    ...  Checking if all cells operationalState and availabilityStatus are Enabled and Online respectively,
    ...  if not Fail test. Also checking all modules operationalState if it is Enabled, other Fail Test.
    ...  In case of active alarm detection, snapshot will be collected. SBTS reset timeout 10 min.
    ...
    ...  Step 2: SBTS is restored
    ...  Checking all cells and module like in step 1 with timeout, after that if are incorrect
    ...  test fail, otherwise test pass. If occurred active alarms snapshot is collected.

Resource  ../../common_resources/ca_CIT_general.robot


*** Variables ***
${RESTORE_TIMEOUT}  10  # Time need to restor BTS after reset, default value 10 min


*** Keywords ***
TC__STATE__Site_reset
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-4062
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...
    ...  - 13.10.2016 - https://jira3.int.net.nokia.com/browse/TAT-4062 - Initial creation
    ...  - 13.12.2016 - https://jira3.int.net.nokia.com/browse/TAT-4906 - Added work around collecting snapshot when ADMIN API fail.
    ...  - 06.03.2017 - https://jira3.int.net.nokia.com/browse/TAT-5718 - Corrected path to snapshot
    ...  - 13.06.2017 - https://jira3.int.net.nokia.com/browse/TAT-6619
    ...  - 24.07.2107 - https://jira3.int.net.nokia.com/browse/TAT-7203
    ...  - 11.07.2017 - https://jira3.int.net.nokia.com/browse/TAT-7411
    ...  - 05.10.2017 - https://jira3.int.net.nokia.com/browse/TAT-7390 - Added KPI checking on teardown
    ...  - 15.11.2017 - https://jira3.int.net.nokia.com/browse/TAT-8250 - Migration from ute_infomodel to ADMIN Abstraction Layer Site reset
    ...  - 02.01.2018 - https://jira3.int.net.nokia.com/browse/TAT-8273 - hran_ims.robot created and moved connected keywords
    ...  - 02.10.2018 - https://jira3.int.net.nokia.com/browse/TAT-12449 - Add allowed alarams due to RP001063 delivery
    ...  - 23.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-15405 - Add restriction to TC when unexpected alarms are visible
    ...  - 03.12.2019 - https://jira3.int.net.nokia.com/browse/TAT-18397 - Adding new keyword to TC
    ...  - 31.07.2020 - https://jira3.int.net.nokia.com/browse/TAT-19808 - KPI reporting to WCTO database removed
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Add watchdog alarm monitoring
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...
    ...  http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/TAT-4062.png#
    ...

    Set Tags  CA-STATE  OWNER-grzegorz.gulaj@nokia.com  AUTHOR-michal.kwasniewicz@nokia.com  MAINTAINER-vlad.slivilescu@nokia.com
    ...  GROUP_IN_CHARGE-TIM_2_Vrf  PHASE-CIT  SW-SBTS17  SW-SBTS18  SW-SBTS19  FEATURE-RP001498_RP000923  FEATURE-RP001621_RP000923
    ...  FEATURE-RP001486_RP000923  FEATURE-RP0001145_RP000923

    Step 1: SBTS Site Reset
    Step 2: SBTS Is Restored


Step 1: SBTS Site Reset
    Log  \nStep 1: SBTS Site reset  console=true
    Admin Check All Required State
    Admin Check Active Alarms TAF  collect_snapshot=${True}
    Log  BTS is reset now.  console=true
    Reset Site  600


Step 2: SBTS Is Restored
    Log  Step 2: SBTS is restored\nCheck BTS and Cells states after reset\nWait ${RESTORE_TIMEOUT} mins for the states to be as expected  console=true
    Wait Until Keyword Succeeds  ${RESTORE_TIMEOUT} min  15 s
    ...  Admin Check All Required State
    ${list_of_active_alarms}  Admin Check Active Alarms TAF  collect_snapshot=${True}
    ${length}  Get Length  ${list_of_active_alarms}
    Run Keyword If  ${length}>0
    ...  Set Test Restriction  Active alarms exist: ${list_of_active_alarms}


TC Setup
    Common Test Setup  tc_name=STATE__Site_reset


TC Teardown
    Common Test Teardown
