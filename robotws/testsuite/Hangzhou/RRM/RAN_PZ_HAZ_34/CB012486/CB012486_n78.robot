*** Settings ***
Documentation
...  author: Yang Di
...  contact: di.yang@nokia-sbell.com
...  squad group: VRF_HAZ3_5
...  Feature CB012486 in SBTS24R3 program

Resource             ${CURDIR}/Resource/CB012486_Keyword.robot

Suite Setup          CB012486 Suite Setup  SCF_path=${N78_SCF}
Suite Teardown       CB012486 Suite Teardown
Test Setup           CB012486 Test Case Setup
Test Teardown        CB012486 Test Case Teardown

*** Variables ***

*** Test Cases *** 
CB012486_SR_031_Single UE peak under single CELL for C-band of N78
    [Documentation]    Purpose of this case is to validate the DL+UL SU peak throughpout, (enable 256QAM, FDM,
    ...  Frame schedule enhance feature, GMC + Radio Performance configuraiton needs to be used),
    ...  benchmark with legacy radio/protocol perfromance
    [Tags]  C_band
    Peak throughput on different bandwidth  cell_id=1  direction=both

CB012486_SR_032_Single UE peak under single CELL for 3.45G-band of N78
    [Documentation]    Purpose of this case is to validate the DL+UL SU peak throughpout, (enable 256QAM, FDM,
    ...  Frame schedule enhance feature, GMC + Radio Performance configuraiton needs to be used),
    ...  benchmark with legacy radio/protocol perfromance
    [Tags]  DoD_band
    Peak throughput on different bandwidth  cell_id=2  direction=both

