*** Settings ***
Documentation     author: Venkatesh
...               contact: venkatesh.1.venkatesh@nokia.com
...               Description: Dynamic uplink data split mode. Based on the UL NR radio quality. UL user data for
...               NSA option 3x SCG split bearer can be reconfigured between the following modes.
...               1. uplink NR only transmission
...               2. uplink LTE only transmission
...               3. uplink LTE + NR transmission

Resource    ./5GC001200_Keywords.robot
Force Tags    PY310    RF50

Suite Setup       Suite Setup
Suite Teardown    Suite Teardown

*** Test Cases ***
Verification of UL data path reconfiguraton from NR Only to LTE Only upon detection of bad UL channel quality in NR
    [Setup]    Test Setup    primary_path=NR
    Attach to Default UE
    Perform SGNB Addition For Bearer
    Wait After Sgnb Addition
    Start Uplink Traffic
    Wait After Starting Traffic
    Store Packets Sent Before UL NR Bad Quality Detection
    Validate Packets Sent in MCG Should Be Zero Before LTE Switch
    Activate Forced DTX and PHR Override Testmode
    Validate UL Primary path switches to LTE
    Wait After UL Switches to LTE
    Store Packets Sent After UL Switches to LTE
    Verify UL Data Transmission on LTE    primary_path=NR
    Release 5G Bearer    release_cause=MISC_CauseMisc_unspecified
    [Teardown]    Test Teardown

Verification of UL data path reconfiguration from NR+LTE to LTE Only upon detection of bad UL channel quality in NR
    [Setup]    Test Setup    primary_path=NR+LTE    data_split_threshold=b800
    Attach to Default UE
    Perform SGNB Addition For Bearer
    Wait After Sgnb Addition
    Start Uplink Traffic towards NR
    Start Uplink Traffic towarss LTE
    Wait After Starting Traffic
    Store Packets Sent Before UL NR Bad Quality Detection
    Validate Packets Sent in MCG and SCG Should Not Be Zero Before LTE Switch
    Activate Forced DTX and PHR Override Testmode
    Validate UL Primary path switches to LTE
    Wait After UL Switches to LTE
    Store Packets Sent After UL Switches to LTE
    Verify UL Data Transmission on LTE    primary_path=NR+LTE
    Release 5G Bearer    release_cause=MISC_CauseMisc_unspecified
    [Teardown]    Test Teardown

*** Keywords ***
Activate Forced DTX and PHR Override Testmode
    Activate PHR Override Test Mode
    Activate Forced DTX Test Mode
    Wait After Activating Test Mode

Wait After Activating Test Mode
    Sleep    ${WAIT_TIME_FOR_TESTMODE}

Wait After UL Switches to LTE
    Sleep    ${WAIT_TIME_AFTER_UL_SWITCH}

Wait After Starting Traffic
    Sleep    ${WAIT_AFTER_TRAFFIC}
