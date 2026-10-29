*** Settings ***
Force Tags    CRT    RAN_5G    RAN_5G_TDD    SBTS00    SBTS22R4    SBTS23R1
    ...    CLOUD_5G_I_LO_AP_LO    VARIANT_SA+NSA_FS_ECPRI_MMWV_TDD

Documentation    :copyright: Nokia
...              :authors: Andrzej Stachowiak
...              :contact: andrzej.stachowiak@nokia.com


Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     CB007517_keywords.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/ute_report.robot
Library      ta5g_tshark
Library      ta5g_testline_management
Library      ta5g_iphy
Library      ta5g_egate
Library      ta5g_pm_counters
Variables    ta5g_global_var


Suite Setup    Run Keywords    Find Scfc And Fix And Send Full Commissioning
...    Full_SCF_CB007517-A_B7.xml
...            AND             Start Vm Ethernet Interfaces
...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
...            AND             Start Default Logging
...            AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_1c_1UE_1_simulated_enb.lua
...            AND             Check Radios Availability

Suite Teardown    Run Keywords   Stop Vm Ethernet Interfaces
...            AND             Stop Default Processes And Gather Logs And Compress Logs


*** Variables ***
${SgNBAdditionRequest}=    x2ap.SgNBAdditionRequest_element
${SgNBReconfigurationComplete}=    x2ap.SgNBReconfigurationComplete_element
${A2 Measurement Report}=
...    (nr-rrc.measId==1)&&
...    (nr-rrc.measurementReport_element)
${SgNBModificationRequired}=
...    (nr-rrc.reportConfigToAddModList == 3)&&
#A1
...    (nr-rrc.eventId == 0)&&
#A3
...    (nr-rrc.eventId == 2)&&
#A5
...    (nr-rrc.eventId == 4)&&
...    (nr-rrc.measIdToRemoveList == 2)


*** Test Cases ***
CB007517-A_FR2_A4_MR_For_Mobility_Removed_When_A3_A5_MR_For_FR2_Is_Configured_In_The_UE_On_An_Call_On_FR2_PSCell_Following_Receipt_Of_A2_MR_Report
    Attach UE To Simulated eNB
    SgNB Addition
    Send A2 Measurement Report
    Verify SgNBAdditionRequest    ${SgNBAdditionRequest}
    Verify SgNBReconfigurationComplete    ${SgNBReconfigurationComplete}
    Verify A2 Measurement Report    ${A2 Measurement Report}
    Verify SgNBModificationRequired    ${SgNBModificationRequired}
    [Teardown]    Add Scout Data Info To Testcase
