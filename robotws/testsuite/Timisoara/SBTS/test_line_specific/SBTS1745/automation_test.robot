*** Settings ***
Documentation  This is a suite for CRT SBTS10745
Force Tags  QCD_MN_RAN  QCP_RAN_VRF  SBTS00  SRAN  CLOUD_SRAN_NLWG_10745_ASIB_ABIA_ABIN_ABIO_AZNB_AEHC_FXDB  STATE_SKIP_AGENT
Library  XML  use_lxml=True

Resource  ../../WebEM/test_resources/WebEM__Admin_CLI_Radio_Reset.robot
Resource  ../../WebEM/test_resources/WebEM__Admin_CLI_getRmodMeasurementsById.robot
Resource  ../../WebEM/test_resources/WebEM__Mobile_Simplified_Site_View_Performing_Operations_on_Selected_Units.robot


*** Variables ***
${SCF_ID}  01
${HW_LOCATION_CODE}  Timisoara
${COLLECT_SNAPSHOT_FLAG}  always


*** Test Cases ***
WebEM__Admin_CLI_Radio_Reset
    [Tags]  QC_162567
    [Timeout]  14400
    [Setup]  Run Keywords
    ...  No Operation

    ...  AND  WebEM__Admin_CLI_Radio_Reset.TC Setup
    ...  AND  Modify Resource Search Order  WebEM__Admin_CLI_Radio_Reset
    TC__WebEM__Admin_CLI_Radio_Reset
    [Teardown]  Run Keywords  WebEM__Admin_CLI_Radio_Reset.TC Teardown
    ...  AND  Restore Resource Search Order


WebEM__Admin_CLI_getRmodMeasurementsById
    [Tags]  QC_162564
    [Timeout]  14400
    [Setup]  Run Keywords
    ...  No Operation

    ...  AND  WebEM__Admin_CLI_getRmodMeasurementsById.TC Setup
    ...  AND  Modify Resource Search Order  WebEM__Admin_CLI_getRmodMeasurementsById
    TC__WebEM__Admin_CLI_getRmodMeasurementsById
    [Teardown]  Run Keywords  WebEM__Admin_CLI_getRmodMeasurementsById.TC Teardown
    ...  AND  Restore Resource Search Order


WebEM__Mobile_Simplified_Site_View_Performing_Operations_on_Selected_Units
    [Tags]  QC_166229
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    WebEM__Mobile_Simplified_Site_View_Performing_Operations_on_Selected_Units.TC Setup
    ...    AND    Modify Resource Search Order    WebEM__Mobile_Simplified_Site_View_Performing_Operations_on_Selected_Units
    TC__WebEM__Mobile_Simplified_Site_View_Performing_Operations_on_Selected_Units
    [Teardown]    Run Keywords    WebEM__Mobile_Simplified_Site_View_Performing_Operations_on_Selected_Units.TC Teardown
    ...    AND    Restore Resource Search Order

