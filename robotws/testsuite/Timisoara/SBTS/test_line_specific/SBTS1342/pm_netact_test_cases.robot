*** Settings ***
Force Tags    QCD_MN_RAN  QCP_RAN_ST  SRAN  CLOUD_SRAN_NLWG_10700_1ASIB_1ABIO_1ABIN_1FSMF_2FBBC_3AHFIB_1ABIA_3AHLOA  STATE_COMMISSIONED
Library       XML  use_lxml=True

Resource    ../../PM/test_resources/PM__LTE_Cell_Availability.robot
Resource    ../../PM/test_resources/PM__LTE_Intra_eNB_Handover_Extension.robot
Resource    ../../PM/test_resources/PM__LTE_Active_Users_and_Latency_Statistics_per_PMQAP_Profile.robot


*** Variables ***
${SCF_ID}                01
${HW_LOCATION_CODE}      Timisoara
${REQUEST_SCF_SCOUT}     ${TRUE}
${SCOUT_TL_NAME}         10_18_UTESRANCLOUD1700


*** Test Cases ***
[SFE]_LTE_Cell_Availability
    [Tags]     cell_avail
    [Setup]    Run Keywords    PM__LTE_Cell_Availability.TC Setup
    ...    AND    Modify Resource Search Order    PM__LTE_Cell_Availability
    ...    AND    Set Library Search Order    PM__LTE_Cell_Availability
    [Timeout]    14400
    TC__PM__LTE_Cell_Availability
    [Teardown]    Run Keywords    PM__LTE_Cell_Availability.TC Teardown
    ...    AND    Restore Resource Search Order


[SFE]_LTE_Intra_eNB_Handover_Extension
    [Tags]     enb_handover
    [Setup]    Run Keywords    PM__LTE_Intra_eNB_Handover_Extension.TC Setup
    ...    AND    Modify Resource Search Order    PM__LTE_Intra_eNB_Handover_Extension
    ...    AND    Set Library Search Order    PM__LTE_Intra_eNB_Handover_Extension
    [Timeout]    14400
    TC__PM__LTE_Intra_eNB_Handover_Extension
    [Teardown]    Run Keywords    PM__LTE_Intra_eNB_Handover_Extension.TC Teardown
    ...    AND    Restore Resource Search Order


[SFE]_LTE_Active_Users_and_Latency_Statistics_per_PMQAP_Profile
    [Tags]     pmqap_profile
    [Setup]    Run Keywords    PM__LTE_Active_Users_and_Latency_Statistics_per_PMQAP_Profile.TC Setup
    ...    AND    Modify Resource Search Order    PM__LTE_Active_Users_and_Latency_Statistics_per_PMQAP_Profile
    ...    AND    Set Library Search Order    PM__LTE_Active_Users_and_Latency_Statistics_per_PMQAP_Profile
    [Timeout]    14400
    TC__PM__LTE_Active_Users_and_Latency_Statistics_per_PMQAP_Profile
    [Teardown]    Run Keywords    PM__LTE_Active_Users_and_Latency_Statistics_per_PMQAP_Profile.TC Teardown
    ...    AND    Restore Resource Search Order

