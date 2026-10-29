*** Settings ***
Documentation
...    Author: Aleksandra Radziejewska, Michal Lys, Kamil Pielka
...    Maintainer: Kamil Pielka
...    Group in charge: I_5G_PZ_MMW_KRK_7SG_TEST_GMS
...    References: doors
...    Feature Description:5GC000955

Resource    taf/rfrl/bts/robot/gnb.robot
Resource    resources/CommonKeywords_5GC000955.robot

Force Tags    STATE_SW_UPLOADED    CRT    CLOUD_5G_CLASSICAL_ASIB_ABIL_AHFIB_SFP+QSFP_ENB

Suite Setup    Run keywords    Prepare Testline    should_LTE_neighbour_be_changed=${False}
...                                                should_5G_neighbour_be_changed=${False}
...                                                increase_time_for_checking_bbmod=900
...                                                increase_timeout_for_update_sw=1800
...                                                increase_time_for_checking_radios=2100    AND
...                            Common Suite Setup

Suite Teardown    Common Suite Teardown


*** Test Cases ***
[1][1.0] 5GC000955_Lock_Unlock_SFP_BBMOD
    [Documentation]
    ...  Lock_Unlock_SFP_BBMOD via WebEM
    [Setup]    Run Keywords    Common Preconditions    AND
    ...                        Verify Setup Of All Cells    AND
    ...                        ADMIN CLI connection    AND
     ...                       Test preparation    sfpType=S
    5GC000955_Lock_Unlock_SFP_BBMOD_via_WebEM
    [Teardown]    Run Keywords    Remove all SFP objects    AND
    ...                           Verify Setup Of All Cells    AND
    ...                           ADMIN CLI disconnection    AND
    ...                           Common Postconditions

[2][1.0] 5GC000955_Lock_Unlock_SFP_BBMOD
    [Documentation]
    ...   Lock_Unlock_SFP_BBMOD via CLI
    [Tags]    RAN_5G__WITH__SBTS22R4    RAN_5G_MP__WITH__SBTS22R3
    [Setup]    Run Keywords    Common Preconditions    AND
    ...                        Verify Setup Of All Cells    AND
    ...                        ADMIN CLI connection    AND
     ...                       Test preparation    sfpType=S
    5GC000955_Lock_Unlock_SFP_BBMOD_via_CLI
    [Teardown]    Run Keywords    Remove all SFP objects    AND
    ...                           Verify Setup Of All Cells    AND
    ...                           ADMIN CLI disconnection    AND
    ...                           Common Postconditions

[1][1.0] 5GC000955_Lock_Unlock_QSFP_BBMOD
    [Documentation]
    ...  Lock_Unlock_QSFP_BBMOD via WebEM
    [Tags]    RAN_5G__WITH__SBTS22R4    RAN_5G_MP__WITH__SBTS22R3
    [Setup]    Run Keywords    Common Preconditions    AND
    ...                        Verify Setup Of All Cells    AND
    ...                        ADMIN CLI connection    AND
     ...                       Test preparation    sfpType=Q
    5GC000955_Lock_Unlock_QSFP_BBMOD_via_WebEM
    [Teardown]    Run Keywords    Remove all SFP objects    AND
    ...                           Verify Setup Of All Cells    AND
    ...                           ADMIN CLI disconnection    AND
    ...                           Common Postconditions

[2][1.0] 5GC000955_Lock_Unlock_QSFP_BBMOD
    [Documentation]
    ...  Lock_Unlock_QSFP_BBMOD via CLI
    [Setup]    Run Keywords    Common Preconditions    AND
    ...                        Verify Setup Of All Cells    AND
    ...                        ADMIN CLI connection    AND
     ...                       Test preparation    sfpType=Q
    5GC000955_Lock_Unlock_QSFP_BBMOD_via_CLI
    [Teardown]    Run Keywords    Remove all SFP objects    AND
    ...                           Verify Setup Of All Cells    AND
    ...                           ADMIN CLI disconnection    AND
    ...                           Common Postconditions

[1][1.0] 5GC000955_Parameters_check_for_transmission
    [Documentation]
    ...  Parameters_check_for_transmission via WebEM
    ...  The TC checks if “maxTransmissionRate“ parameter is invisible in CM for SFP port
    [Setup]    Run Keywords    Common Preconditions    AND
    ...                        Verify Setup Of All Cells    AND
    ...                        ADMIN CLI connection    AND
     ...                       Test preparation    sfpType=S
    5GC000955_Parameters_check_for_transmission_via_WebEM
    [Teardown]    Run Keywords    Remove all SFP objects    AND
    ...                           Verify Setup Of All Cells    AND
    ...                           ADMIN CLI disconnection    AND
    ...                           Common Postconditions

[1][2.0] 5GC000955_Configure_QSFP_lanes_in_CM_object
    [Tags]    RAN_5G__WITH__SBTS22R4    RAN_5G_MP__WITH__SBTS22R3
    [Setup]    Run Keywords    Common Preconditions    AND
    ...                        Verify Setup Of All Cells    AND
    ...                        ADMIN CLI connection    AND
     ...                       Test preparation    sfpType=Q
    5GC000955_Configure_QSFP_Lanes
    Wait Until Keyword Succeeds    180s    10s    Verify Setup Of All Cells
    [Teardown]    Run Keywords    Remove all SFP objects    AND
    ...                           Verify Setup Of All Cells    AND
    ...                           ADMIN CLI disconnection    AND
    ...                           Common Postconditions
