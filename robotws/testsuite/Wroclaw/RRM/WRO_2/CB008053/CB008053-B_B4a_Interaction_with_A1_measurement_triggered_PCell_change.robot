*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00
...    CLOUD_5G_I_BOO_AP_LOO

Documentation    :copyright: Nokia
...              :authors: Andrzej Stachowiak
...              :contact: andrzej.stachowiak@nokia.com

Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Resource     ../keywords/messaging.robot
Resource     ../keywords/L3_Call.robot
Resource     ../keywords/traffic.robot
Resource    ../keywords/tshark_verifying.robot
Resource     CB008053_keywords.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/ute_report.robot
Library      ta5g_tshark
Library      ta5g_testline_management
Library      ta5g_iphy
Library      ta5g_egate
Library      ta5g_pm_counters
Library      taf.ul.ettf.setups
Variables    ta5g_global_var

Suite Setup    Run Keywords    Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy_CB008053.xml
...            AND             With Gnb Configuration    commissioning=${SCFC}
...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
...            AND             Start Default Logging
...            AND             Check Radios Availability
...            AND             Reach Onair    lua_cfg=${BASIC_SETUP}

Suite Teardown    Run Keywords   Stop Default Processes And Gather Logs And Compress Logs


*** Variables ***
${SCFC}=              CB008053-B_B4_2.xml
${BASIC_SETUP}=       ${CURDIR}/config/basic_setup.cfg
${UE_ID}=   3
${Trigger_CA_Meas_ID}=    1
${Handover_Meas_Id}=    2
${CA_Veryfication_Message}=
...   nr-rrc.measObjectId == 3 &&
...   nr-rrc.ssbFrequency == 529950 &&
...   nr-rrc.measObjectId == 4 &&
...   nr-rrc.ssbFrequency == 623328 &&
...   nr-rrc.measObjectId == 2 &&
...   nr-rrc.freqBandIndicatorNR == 41 &&
...   nr-rrc.ssbFrequency == 501150 &&
...   nr-rrc.ssbFrequency == 529950 &&
...   nr-rrc.freqBandIndicatorNR == 41 &&
...   nr-rrc.ssbFrequency == 623328 &&
...   nr-rrc.freqBandIndicatorNR == 77 &&
...   nr-rrc.reportConfigToRemoveList == 1 &&
...   nr-rrc.ReportConfigId == 1
${PCell_Switch_Veryfication_Message}=
...   nr-rrc.csi_ReportConfigToReleaseList == 4 &&
...   nr-rrc.CSI_ReportConfigId == 0 &&
...   nr-rrc.CSI_ReportConfigId == 13 &&
...   nr-rrc.CSI_ReportConfigId == 14 &&
...   nr-rrc.CSI_ReportConfigId == 15 &&
...   nr-rrc.sCellToReleaseList == 3 &&
...   nr-rrc.SCellIndex == 1 &&
...   nr-rrc.SCellIndex == 2 &&
...   nr-rrc.SCellIndex == 3 &&
...   nr-rrc.ssbFrequency == 501150 &&
...   nr-rrc.freqBandIndicatorNR == 41



*** Test Cases ***
CB008053-B_B4a_Interaction_with_A1_measurement_triggered_PCell_change
    Register UE To gNB    UE_Id=${UE_ID}
    Trigger CA With A1 Measurement    UE_Id=${UE_ID}    Meas_Id=${Trigger_CA_Meas_ID}
    Perform Pcell Switch    UE_Id=${UE_ID}    Meas_Id=${Handover_Meas_Id}
    Verify CA Configuration    CA_Veryfication_Message=${CA_Veryfication_Message}
    Verify PCell Switch Veryfication   PCell_Switch_Veryfication_Message=${PCell_Switch_Veryfication_Message}
    [Teardown]    Add Scout Data Info To Testcase
