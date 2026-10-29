*** Settings ***
Documentation
...  TC for verification of site power reset


Resource    ../../../../resources/hran_frame_sbts_siso.robot
Resource    ../../../../resources/ca_siso_hran.robot
Resource    ../../../../resources/ca_4G_RRM_carrier_aggregation.robot

*** Variables ***
${RESTORE_TIMEOUT}=                 10        #Time need to restor BTS after reset, default value 10 min


*** Keywords ***
TC__STATE__Site_reset
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-4062
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...
    ...  Step 1: SBTS Site reset
    ...  Checking if all cells operationalState and availabilityStatus are Enabled and Online respectively,
    ...  if not Fail test. Also checking all modules operationalState if it is Enabled, other Fail Test.
    ...  In case of active alarm detection, snapshot will be collected. SBTS reset timeout 10 min.
    ...
    ...  Step 2: SBTS is restored
    ...  Checking all cells and module like in step 1 with timeout, after that if are incorrect
    ...  test fail, otherwise test pass. If occurred active alarms snapshot is collected.
    ...
    ...  NOTE. If test used with OBSAI RUs (dual link), fault 1811 Warning can appear. Please adjust accordingly your TS allowed faults.
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
    ...  - 30.08.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21764 - [CNI-61110] STATE TCs alignment
    ...  - 01-09-2022 - https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-12197 - migration hran_ta to robotws
    ...  - 10.11.2022 - Removing library hran_ims
    ...  - 26.11.2024 - Adding documentation extension regarding fault 1811 - https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-48966
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...
    ...  http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/TAT-4062.png#
    ...


    Set Tags    CA-STATE    OWNER-grzegorz.gulaj@nokia.com    AUTHOR-michal.kwasniewicz@nokia.com
    ...    MAINTAINER-daniel.bartkowiak@nokia.com    GROUP_IN_CHARGE-WRO_8_Vrf    PHASE-CIT    SW-SBTS17    SW-SBTS18
    ...    SW-SBTS19    FEATURE-RP001498_RP000923    FEATURE-RP001621_RP000923    FEATURE-RP001486_RP000923
    ...    FEATURE-RP0001145_RP000923

    Step 1: SBTS Site reset
    Step 2: SBTS is restored

Step 1: SBTS Site reset
    log    \nStep 1: SBTS Site reset    console=yes
    Siso Check Unexpected Alarms
    log    BTS is reset now.    console=yes
    admin.Reset Site    timeout=600    connection=default

Step 2: SBTS is restored
    log    Step 2: SBTS is restored\nCheck states after reset\nWait ${RESTORE_TIMEOUT} mins for the states to be as expected  console=yes
    Wait Until Keyword Succeeds    ${RESTORE_TIMEOUT} min    15 s
    ...  Admin Check All Required State

Admin Check All Required State
    Run Keyword If    ${SCF_COUNT_LTE}   Run Keywords
    ...    admin.Assert Every    LNCEL    ${STATES_ONAIR_LG}  search_for_iot_cells=${True}  connection=default
    ...    AND
    ...    admin.Assert No  LNCEL  ${DEGRADED_CELL_REGEX}  search_for_iot_cells=${True}  connection=default
    ...    AND
    ...    Check Number Of Cells    LNCEL    ${SCF_COUNT_LTE}
    Run Keyword If    ${SCF_COUNT_GSM}   Run Keywords
    ...    admin.Assert Every    GNCEL    ${STATES_ONAIR_LG}    connection=default
    ...    AND
    ...    admin.Assert No  GNCEL  ${DEGRADED_CELL_REGEX}    connection=default
    ...    AND
    ...    Check Number Of Cells    GNCEL    ${SCF_COUNT_GSM}
    Run Keyword If    ${SCF_COUNT_WCDMA}   Run Keywords
    ...    admin.Assert Every    WNCEL    ${STATES_ONAIR_WCDMA}    connection=default
    ...    AND
    ...    admin.Assert No  WNCEL  ${DEGRADED_CELL_REGEX}    connection=default
    ...    AND
    ...    Check Number Of Cells    WNCEL    ${SCF_COUNT_WCDMA}
    Run Keyword If    ${SCF_COUNT_NR}   Run Keywords
    ...    admin.Assert Every    NRCEL    ${STATES_ONAIR_LG}    connection=default
    ...    AND
    ...    admin.Assert No  NRCEL  ${DEGRADED_CELL_REGEX}    connection=default
    ...    AND
    ...    Check Number Of Cells    NRCEL    ${SCF_COUNT_NR}
    admin.Assert Every    RMOD    ${STATES_ONAIR_RMOD}    connection=default
    admin.Assert No  RMOD  ${DEGRADED_CELL_REGEX}    connection=default
    admin.Assert Every    SMOD    ${STATES_ONAIR_SMOD}    connection=default
    admin.Assert No  SMOD  ${DEGRADED_CELL_REGEX}    connection=default

Check Number Of Cells
    [Arguments]  ${technology}  ${expected_cells_number}
    ${id_list}=  admin.Get Ids For All  ${technology}  search_for_iot_cells=${True}  connection=default
    ${admin_cells_num}=  Get Length  ${id_list}
    Should Be Equal As Integers  ${expected_cells_number}  ${admin_cells_num}
    ...  Admin see different cells number than expected! Expected: ${expected_cells_number} is not equal admin cells num: ${admin_cells_num}.

TC Setup
    Common Test Setup

TC Teardown
    Common Test Teardown
