*** Settings ***
Suite Setup
Suite Teardown     Run keywords        Scf commission
Test Setup
Test Teardown
Test Timeout    1000 min

Resource    ./Resources/CB012190_Robust_Common_Keyword.robot


*** Variables ***
${testline_name}    7_5_UTE5G402T904
${scf_file}    SCF_SBTS00.xml

*** Test Cases ***
[1]CB012190_25_General_robust_testing
#[1]CB012190_check_2CC_slim_cell_49.5MHz
    [Setup]    robot_common_operations.Common Case Setup
    ${RELEASE}=   Get program version
    run keyword if    '${RELEASE}'=='24R3'    Scf commission and wait on-air    scf_name=SCF_CB012190_2CC_24R3.xml
    ...    ELSE    Scf commission and wait on-air    scf_name=SCF_CB012190_2CC.xml
    Conect to DU COAM
    Modify the normal cell to slim cell 49.5MHz    key_dl=slimRfFilterDL    key_ul=slimRfFilterUL    value=49.5MHz    cell_ID=2
    Collect snapshot logs for check soap info
    Extract Permanent from snapshot     snapshot_file=${TS_CASE_LOG_PATH}/Snapshot.zip
    Check Soap log    distName=NR10044.RX2_1_6    expected_bandwidth=49500000
    Check Soap log    distName=NR10044.RX1_1_6    expected_bandwidth=49500000
    [Teardown]    Run keywords    RUN KEYWORD AND CONTINUE ON FAILURE    COAM Logout
    ...    AND    robot_common_operations.Common Case Teardown

