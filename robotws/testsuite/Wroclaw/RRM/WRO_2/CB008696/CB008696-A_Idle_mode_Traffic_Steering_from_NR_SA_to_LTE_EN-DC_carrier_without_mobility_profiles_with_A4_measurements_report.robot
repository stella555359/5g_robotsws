*** Settings ***
Force Tags    CONFIGURED    CRT    master_classicalbts_all    RAN_5G_TDD
    ...    CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC

Documentation    :copyright: Nokia
...              :authors: Andrzej Stachowiak
...              :contact: andrzej.stachowiak@nokia.com

Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     CB008696_keywords.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/ute_report.robot
Library      ta5g_tshark
Library      ta5g_testline_management
Library      ta5g_iphy
Library      ta5g_egate
Library      ta5g_pm_counters
Variables    ta5g_global_var


Suite Setup    Run Keywords    Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy_CB008696_B.xml
...          AND    Find Scfc And Fix And Send Full Commissioning    full_scfc_CB008696_successful_scenario_lo_ap_lo.xml
...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
...            AND             Start Default Logging
...            AND             Check Radios Availability
...            AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_2c_1ue.lua

Suite Teardown    Run Keywords   Stop Default Processes And Gather Logs And Compress Logs


*** Variables ***
${RRC Reconfiguration}=
...    (nr-rrc.measId == 1)&&
...    (nr-rrc.c1 == 0)&&
...    (nr-rrc.reportConfigToAddModList == 1)&&
...    (nr-rrc.a4_Threshold == 0)&&
...    (nr-rrc.measTriggerQuantity.rsrp == 2)&&
...    (nr-rrc.eventId == 3)&&
...    (nr-rrc.freqBandIndicatorNR == 257)&&
...    (nr-rrc.ssbFrequency == 2079166)
${UE Meauserement Report}=
...    (nr-rrc.criticalExtensions == 0)&&
...    (nr-rrc.measId == 1)&&
...    (nr-rrc.measResultNeighCells == 0)
${AMF UE Context Release Request}=
...    (ngap.radioNetwork == 20)&&
...    (ngap.procedureCode == 42)
${AMF UE Context Release Command}=
...    (ngap.procedureCode == 41)&&
...    (ngap.radioNetwork == 20)
${NGAP: UE Context Release Complete appears}=    (ngap.id == 60)

${RRC Release}=    nr-rrc.rrcRelease_element
${RRC Release EUTRA}=
...    (nr-rrc.c1 == 2)&&
...    (nr-rrc.cellReselectionPriority == 7)&&
...    (nr-rrc.carrierFreq == 300)&&
...    (nr-rrc.t320 == 1)
${RRC Release NR}=
...    (nr-rrc.c1 == 2)&&
...    (nr-rrc.carrierFreq == 147500)&&
...    (nr-rrc.cellReselectionPriority == 6)&&
...    (nr-rrc.carrierFreq == 636576)&&
...    (nr-rrc.cellReselectionPriority == 4)&&
...    (nr-rrc.t320 == 1)


*** Test Cases ***
CB008696-A_Idle_mode_Traffic_Steering_from_NR_SA_to_LTE_EN-DC_carrier_without_mobility_profiles_with_A4_measurements_report
    Get Next Unpacked Full Pm Counters File
    Set Internal Traffic Type To UE
    Register UE To gNB
    Wait For The UE To Be Inactive And Send UE Measurement Report
    ...    ue_id=1
    ...    meas_id=1
    Verify RRC Reconfiguration    ${RRC Reconfiguration}
    Verify Measurement Report Sent By Ue With A4    ${UE Meauserement Report}
    Verify AMF UE Context Release Request For Inactive UE   ${AMF UE Context Release Request}
    Verify AMF UE Context Release Command For Inactive UE   ${AMF UE Context Release Command}
    Verify NGAP UE Context Release Complete Appears    ${NGAP: UE Context Release Complete appears}
    Verify RRC Release Message Occured    ${RRC Release}
    Verify EUTRA Reselection Priority    ${RRC Release EUTRA}
    Verify NR Reselection Priority    ${RRC Release NR}
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File
    Verify Any Counters In File
        ...    M55124C07502    +1       NRRCC_A4_MEAS_IMM_REC
        ...    M55124C07501    +1       NRRCC_RRC_RELEASE_IMM_ENDC_LTE
        ...    M55124C00001    +1       NRRCC_RRC_RELEASE_SENT
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
        ...    file_path=${pm_counter_file}
    [Teardown]    Add Scout Data Info To Testcase
