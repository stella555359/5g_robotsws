*** Settings ***
Force Tags    CONFIGURED    CRT    RAN_5G    RAN_5G_TDD    SBTS00    SBTS25R1
    ...    CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE

Documentation    :copyright: Nokia
...              :authors: Mikolaj Kasian
...              :maintainer: 'Mikolaj Kasian'
...              :contact: mikolaj.kasian@nokia.com

Resource     taf/ul/ettf/main.robot

Library      ute_fsmaccess
Library      ute_tshark
Variables    taf/ul/ettf/logging/policies.py

Library      taf.ul.ettf.logging
Library      taf.ul.ettf.setups
Resource     ../keywords/messaging.robot
Resource     ../keywords/logging.robot
Resource     feature_keywords.robot
Library      ta5g_throughput
Library      testsuite/Wroclaw/RRM/WRO_2/resources/common_functions.py
Library      ute_wtssim
Library      ta5g_commissioning

Suite Setup     Run Keywords    Log To Console    Setup is going with Full Commissioning
...            AND              Configure simulated interfaces
...            AND              Enable C-Plane Debug Logs    with_reboot=${FALSE}
...            AND              Find Scfc And Fix And Send Full Commissioning    scfc_filename=${SCFC_WITH_FEATURE_PRECONDITION}
...            AND              Wait For Testline Icmp Echo Replies And Ssh Services
...            AND              With Simulator Configuration    config=${BASIC_SETUP}
...            AND              Verify X2 link Status    is_available=True
...            AND              Enable Tshark Verification


*** Variables ***
${LOGS_COMPRESSION}=                  ${True}
${LOGGING_POLICY}=                    FULL_POLICY
${BASIC_SETUP}=                       ${CURDIR}/config/egate_2_TDD_2_FDD_cells.cfg
${SCFC_WITH_FEATURE_PRECONDITION}=    full_scfc_CB008933_preconditions.xml

*** Test Cases ***
CB008933_A_Support_NRPMQAP_profiles_initial_configuration_in_L2_HI__L2_LO__L2_PS__C_plane
    [Setup]    Wait For Next Full Pm Interval

    Steps 1-2: Attach UE1 in NSA mode
    Steps 3: Start UL and DL traffic for UE1
    Steps 4: Trigger UE1 DC Release due to SgNB user inactivity timer
    Steps 5: Trigger SqNB Addition procedure for UE1
    Steps 6: Trigger UE1 DC Release due to MeNB user inactivity timer
    Steps 7: Trigger SqNB Addition procedure for UE1
    Steps 8: Trigger DC Release Due To Transport Resource Unavailable
    Steps 9: Detach UE1

    Steps 10: Register UE2 in SA mode
    Steps 11: Start UL and DL traffic for UE2
    Steps 12: Stop traffic and release UE2
    Steps 13: Verify Pm Counters Are Increased In Specific NRPMQAP
