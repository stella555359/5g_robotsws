*** Settings ***
Force Tags    CONFIGURED    CRT    master_classicalbts_all    RAN_5G_TDD    SBTS00    CLOUD_5G_I_LO_AP_LO
    ...    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE    QC_353295    QCD_MN_RAN    QCP_RAN_ET

Documentation    :copyright: Nokia
...              :authors: Mateusz Kuropka
...              :contact: mateusz.kuropka@nokia.com

Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     CB008696_keywords.robot
Resource     testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Resource     ../../VRF_WRO2_T04/resources/ute_report.robot

Library      taf.ul.ettf.setups
Library      ta5g_tshark
Library      ta5g_testline_management
Library      ta5g_iphy
Library      ta5g_egate
Library      ta5g_pm_counters
Variables    ta5g_global_var


Suite Setup    Run Keywords    Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy_CB008696_B.xml
...            AND             With Gnb Configuration       commissioning=full_scfc_CB008696.xml
...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
...            AND             Start Default Logging
...            AND             Check Radios Availability
...            AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_2c_1ue.lua

Suite Teardown    Run Keywords   Stop Default Processes And Gather Logs And Compress Logs


*** Variables ***
${RRC Release}=    nr-rrc.rrcRelease_element
${RRC Release Reselection Priority}=
...    (nr-rrc.c1 == 2)&&
...    (nr-rrc.carrierFreq == 300)&&
...    (nr-rrc.carrierFreq == 147500)&&
...    (nr-rrc.carrierFreq == 636576)&&
...    (nr-rrc.cellReselectionPriority == 7)&&
...    (nr-rrc.t320 == 2)

*** Test Cases ***
CB008696-A_UE_candidate_percentage_check_is_not_passed
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
    [Teardown]    Add Scout Data Info To Testcase
