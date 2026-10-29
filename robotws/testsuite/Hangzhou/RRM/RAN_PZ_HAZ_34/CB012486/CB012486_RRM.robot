*** Settings ***
Documentation
...  author: Yang Di
...  contact: di.yang@nokia-sbell.com
...  squad group: VRF_HAZ3_5
...  Feature CB012486 in SBTS24R3 program

Resource             ${CURDIR}/Resource/CB012486_Keyword.robot

Suite Setup          CB012486 Suite Setup
Suite Teardown       CB012486 Suite Teardown
Test Setup           CB012486 Test Case Setup
Test Teardown        CB012486 Test Case Teardown


*** Test Cases ***
CB012486_SR_028_DL_SU_peak_throughpout_with_Radio_Perfromance_feature_on_on_C_band
    [Documentation]    Purpose of this case is to validate the DL+UL SU peak throughpout, (enable 256QAM, FDM,
    ...  Frame schedule enhance feature, GMC + Radio Performance configuraiton needs to be used),
    ...  benchmark with legacy radio/protocol perfromance
    [Tags]  C_band
    Peak throughput on different bandwidth  cell_id=1  direction=both

CB012486_SR_028_DL_SU_peak_throughpout_with_Radio_Perfromance_feature_on_on_DoD_band
    [Documentation]    Purpose of this case is to validate the DL+UL SU peak throughpout, (enable 256QAM, FDM,
    ...  Frame schedule enhance feature, GMC + Radio Performance configuraiton needs to be used),
    ...  benchmark with legacy radio/protocol perfromance
    [Tags]  DoD_band
    Peak throughput on different bandwidth  cell_id=4  direction=both  10M_true=true

