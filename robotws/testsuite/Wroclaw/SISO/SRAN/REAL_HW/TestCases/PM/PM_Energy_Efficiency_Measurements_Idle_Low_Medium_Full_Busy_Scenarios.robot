*** Settings ***
Documentation
  ...  AUTHOR-kamil.adamowski@nokia.com  MAINTAINER-kamil.adamowski@nokia.com
  ...
  ...  *****************
  ...  Basic information
  ...  *****************
  ...
  ...  This testcase is using the original implementation located at path:
  ...  taf/rfrl/procedures/SISO/test_models/etsi/resources/Test_Model.robot,
  ...  which is developed by Tomasz Krol.
  ...
  ...
  ...  Step 1: Run Energy Efficiency Measurement Procedure
  ...
  ...  ******************
  ...  History of changes
  ...  ******************
  ...  - 22.10.2025 - Initial creation
  ...  - 13.11.2025 - Added report for configuration ID


Resource  taf/rfrl/procedures/SISO/test_models/etsi/resources/Test_Model.robot
Library      taf.sw.reporting_portal
Library      taf.rfrl.common_resources.reporting_portal.ref_configuration_id


*** Variables ***
${SKIP_ABIA_CELLS}  False          # parameter as workaround for ABIA, that not support TM1_1_ETSI, default False
${REFERENCE_CONFIGURATION_ID}    sample_referance_id     #ID if the test line

*** Keywords ***
TC__PM_Energy_Efficiency_Measurements_Idle_Low_Medium_Full_Busy_Scenarios
  Set Tags  AUTHOR-kamil.adamowski@nokia.com  MAINTAINER-kamil.adamowski@nokia.com
  Common Test Setup
  ${bts_id}  Get From Dictionary  ${CFG}  primary_node_bts_id
  Step 1: Report ID
  Step 2: ETSI  ${bts_id}
  [Teardown]  Common Test Teardown

Step 1: Report ID
    Logging With Timestamp
    ...  message=Step 1: Report Configuration ID of the TestLine ${REFERENCE_CONFIGURATION_ID}
    ...  style=STEP
    ...  frame=${TRUE}

    Report Reference Configuration ID

Step 2: ETSI
    [Arguments]  ${bts_id}
    Logging With Timestamp
    ...  message=Step 2: ETSI - Run Energy Efficiency Measurement Procedure
    ...  style=STEP
    ...  frame=${TRUE}
    Run Energy Efficiency Measurement Procedure    connection=${bts_id}    skip_if_tm_not_started_on_lte=${SKIP_ABIA_CELLS}
