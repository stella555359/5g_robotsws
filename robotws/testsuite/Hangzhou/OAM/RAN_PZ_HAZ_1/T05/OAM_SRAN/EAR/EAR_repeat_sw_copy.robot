*** Settings ***
Documentation     [PURPOSE]
Suite Setup       hran_frame_sbts.suite setup
Suite Teardown    hran_frame_sbts.suite teardown
Force Tags        SBTS00    QCD_MN_RAN  QCP_RAN_VRF
Resource          Case_Resource/Robustness_Repeated_software_sync.robot
#Resource          ../CRT/SWM/SWM__SW_download_and_activation__SBTS_to_SBTS.robot
*** Variables ***
${target_release}    SBTS00

*** Test Cases ***
#SWM__SW_download_and_activation__SBTS_to_SBTS
#    [Tags]    QC_amli  robot:no-dry-run   1
#    [Setup]    run keywords    SWM__SW_download_and_activation__SBTS_to_SBTS.TC_Custom Setup
#    ...    AND    Set Library Search Order    SWM__SW_download_and_activation__SBTS_to_SBTS    hran_general
#    Log    1th
#    #To make sure update to the latest version before CRT Start
#    TC__SWM__SW_download_and_activation__SBTS_to_SBTS
#    [Teardown]    SWM__SW_download_and_activation__SBTS_to_SBTS.TC_Custom Teardown

EAR_repeat_sw_copy
    [Tags]    QC_xxx     rep
    [Setup]    common test setup
    TC__Robustness_repeat_software_sync
    [Teardown]    common test teardown

