*** Settings ***
Force Tags    CONFIGURED    CRT    RAN_5G_TDD    SBTS00
    ...    CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE

Documentation    :copyright: Nokia

Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     CB008696_keywords.robot
Resource     testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Resource     ../../VRF_WRO2_T04/resources/ute_report.robot
Library      ta5g_tshark
Library      ta5g_testline_management
Library      ta5g_ue_mobility
Library      ta5g_iphy
Library      ta5g_egate
Library      ta5g_pm_counters
Library      taf.ul.ettf.setups
Variables    ta5g_global_var


*** Variables ***
${REBOOT}=    ${True}  # Switch to true to reboot before 1st test iteration, useful when running multiple tests on the same testline
${LOGS_COMPRESSION}=    ${True}
${LOGGING_POLICY}=    FULL_POLICY  # Can be set to FULL_POLICY_WITH_EMIL to capture Emil logs during retests
${RRC Reconfiguration With A4 Before Data Traffic}=
...    (nr-rrc.measId == 1)&&
...    (nr-rrc.c1 == 0)&&
...    (nr-rrc.reportConfigToAddModList == 1)&&
...    (nr-rrc.a4_Threshold == 0)&&
...    (nr-rrc.measTriggerQuantity.rsrp == 2)&&
...    (nr-rrc.eventId == 3)&&
...    (nr-rrc.freqBandIndicatorNR == 258)&&
...    (nr-rrc.ssbFrequency == 2043749)
${RRC Reconfiguration With A4 After Data Traffic}=
...    (nr-rrc.measId == 2)&&
...    (nr-rrc.c1 == 0)&&
...    (nr-rrc.reportConfigToAddModList == 1)&&
...    (nr-rrc.a4_Threshold == 0)&&
...    (nr-rrc.measTriggerQuantity.rsrp == 2)&&
...    (nr-rrc.eventId == 3)&&
...    (nr-rrc.freqBandIndicatorNR == 258)&&
...    (nr-rrc.ssbFrequency == 2043749)
${E1AP Bearer Context Inactivity Notification With Field Active}=
...    e1ap.uE_Activity == 0
${RRC Reconfiguration With Deconfigured A4 During Data Traffic}=
...    (nr-rrc.measIdToRemoveList == 1)&&
...    (nr-rrc.measObjectToRemoveList == 1)&&
...    (nr-rrc.reportConfigToRemoveList == 1)
${A4 Measurement Report}=
...    (nr-rrc.criticalExtensions == 0)&&
...    (nr-rrc.measId == 2)&&
...    (nr-rrc.measResultNeighCells == 0)
${E1AP Bearer Context Inactivity Notification With Field Inactive}=
...    e1ap.uE_Activity == 1
${RRC Release}=    nr-rrc.rrcRelease_element
${RRC Release EUTRA}=
...    (nr-rrc.c1 == 2)&&
...    (nr-rrc.cellReselectionPriority == 7)&&
...    (nr-rrc.carrierFreq == 900)&&
...    (nr-rrc.cellReselectionPriority == 6)&&
...    (nr-rrc.carrierFreq == 1575)&&
...    (nr-rrc.cellReselectionPriority == 5)&&
...    (nr-rrc.carrierFreq == 300)&&
...    (nr-rrc.t320 == 1)
${RRC Release NR}=
...    (nr-rrc.c1 == 2)&&
...    (nr-rrc.carrierFreq == 636576)&&
...    (nr-rrc.cellReselectionPriority == 4)&&
...    (nr-rrc.t320 == 1)
${RRC Release Reselection Priority}=
...    (nr-rrc.c1 == 2)&&
...    (nr-rrc.carrierFreq == 300)&&
...    (nr-rrc.carrierFreq == 147500)&&
...    (nr-rrc.carrierFreq == 636576)&&
...    (nr-rrc.cellReselectionPriority == 7)&&
...    (nr-rrc.t320 == 2)

*** Test Cases ***
CB008696-A_UE_candidate_percentage_check_is_not_passed

    [Documentation]    :copyright: Nokia
    ...                :authors: Mateusz Kuropka
    ...                :contact: mateusz.kuropka@nokia.com

    [Setup]    Run Keywords    Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy_CB008696_B.xml
    ...            AND             With Gnb Configuration       commissioning=full_scfc_CB008696.xml
    ...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
    ...            AND             Start Default Logging
    ...            AND             With Simulator Configuration    config=${CURDIR}/config/egate_2c_1ue.lua

    Get Next Unpacked Full Pm Counters File
    Set Internal Traffic Type To UE
    Register UE To gNB
    Wait For The UE To Be Inactive    ${12}
    Verify RRC Release Message Occured    ${RRC Release}
    Verify Reselection Priority    ${RRC Release Reselection Priority}
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File
    Verify Any Counters In File
        ...    M55124C00001    +1       NRRCC_RRC_RELEASE_SENT
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    file_path=${pm_counter_file}

    [Teardown]    Run Keywords   Stop Default Logging
                   ...     Add Scout Data Info To Testcase

CB008696_B_Data_Traffic_During_Waiting_For_A4_Measurements_With_Mobility_Profiles

    [Documentation]    :copyright: Nokia
    ...                :authors: Aleksandra Vesely
    ...                :contact: aleksandra.vesely@nokia.com

    [Setup]    Run Keywords    Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy_CB008696_B.xml
    ...            AND             With Gnb Configuration    commissioning=full_scfc_CB008696_mobility_profile_with_a4_meas.xml
    ...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
    ...            AND             Start Default Logging
    ...            AND             With Simulator Configuration    config=${CURDIR}/config/egate_2c_1ue_mobility_profile.lua

    Get Next Unpacked Full Pm Counters File
    Set Internal Traffic Type To UE
    Register UE To gNB
    Wait For The UE To Be Inactive    ${12}
    Verify RRC Reconfiguration    ${RRC Reconfiguration With A4 Before Data Traffic}
    Start Data Traffic During A4 Supervision Timer Duration
    UE Is RRC Connected, Verify E1AP Bearer Context Inactivity Notification With Field Active
    ...    ${E1AP Bearer Context Inactivity Notification With Field Active}
    A4 Measurement Is Deconfigured, Verify RRC Reconfiguration
    Stop Data Traffic
    Wait For The UE To Be Inactive And Send UE Measurement Report
    ...    ue_id=2
    ...    meas_id=2
    Verify RRC Reconfiguration    ${RRC Reconfiguration With A4 After Data Traffic}
    Verify Measurement Report Sent By Ue With A4    ${A4 Measurement Report}
    Verify E1AP Bearer Context Inactivity Notification With Field Inactive
    ...    ${E1AP Bearer Context Inactivity Notification With Field Inactive}
    Verify RRC Release Message Occured    ${RRC Release}
    Verify EUTRA Reselection Priority    ${RRC Release EUTRA}
    Verify NR Reselection Priority    ${RRC Release NR}
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File
    Verify Any Counters In File
        ...    M55157C00033    +1       NRMOP_SA_PROFILE_SELECTED_01
        ...    M55124C07502    +1       NRRCC_A4_MEAS_IMM_REC
        ...    M55124C07501    +1       NRRCC_RRC_RELEASE_IMM_ENDC_LTE
        ...    M55124C00001    +1       NRRCC_RRC_RELEASE_SENT
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    file_path=${pm_counter_file}

    [Teardown]    Run Keywords   Stop Default Logging
