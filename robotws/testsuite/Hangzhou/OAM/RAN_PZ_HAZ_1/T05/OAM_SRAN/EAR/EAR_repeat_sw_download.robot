*** Settings ***
Documentation     [PURPOSE]
Suite Setup       hran_frame_sbts.suite setup
Suite Teardown    hran_frame_sbts.suite teardown
Force Tags        SBTS00    QCD_MN_RAN  QCP_RAN_VRF
Resource          Case_Resource/Robustness_Repeated_software_download.robot
*** Variables ***
${target_release}    SBTS00


*** Test Cases ***
EAR_repeat_sw_download
    [Tags]    QC_xxx     rep
    [Setup]    common test setup
    TC__Robustness_repeat_software_download
    [Teardown]    common test teardown
