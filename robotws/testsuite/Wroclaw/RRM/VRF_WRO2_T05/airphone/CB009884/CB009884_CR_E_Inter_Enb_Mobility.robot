*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC    PY311
...           CONFIGURED    NoResUsage    TOOLS_PROFILE_TTI_LEGACY

Documentation    :copyright: Nokia
...              :authors: Joachim Otto, Katarzyna Wisniewska
...              :contact: joachim.otto@nokia.com, katarzyna.wisniewska@nokia.com

Resource    CB009884_Keywords_And_Variables.robot

Suite Setup    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...            AND             Get Scfc File   output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...            AND             Start Vm Ethernet Interfaces
...            AND             Find Scfc and Send Delta Commissioning    scfc_filename=delta_9884E.json
...            AND             Check Radios Availability
...            AND             Reach OnAir    lua_cfg=${CURDIR}/config/egate_2c_tdd_2c_fdd_sansa_9884E.lua
...            AND             Establish X2 link between Enbs and Gnb
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Suite Teardown    Run Keywords  Roll Delta Back
...                             initial_scf_filename=${OUTPUT_DIR}/initial_commissioning.xml
...                             delta_scf_filename=delta_9884E.json
...               AND           Stop Default Processes And Gather Logs And Compress Logs

*** Test Cases ***
CB009884_CR_E_User_Scenario_NSA_Accessability_Counters_Number_Of_ERABs_Established_Via_SgNB_Setup_Inter_Enb_Mobility_ALTERNATE_1
    [Documentation]    This user scenario aims to verify counters for number of eRABs established via SgNB Setup inter enb mobility.
    ...                Procedure covers the handling of SgNB Addition procedure by 5GNB to support Inter MeNB handover without
    ...                SgNB Change (With change in the SCG configuration and Security Key Refresh at SgNB).
    ...                Test is preformed with 3 ues attached to the same cell 1.

    [Setup]    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

    Attach Ue To Enb    ue_id=101
    Start Gnb Addition Procedure and Generate Traffic    ue_id=101
    Perform Inter ENB HO with change in SCG    ue_id=101
    Attach Ue To Enb    ue_id=102
    Start Gnb Addition Procedure and Generate Traffic    ue_id=102
    Perform Inter ENB HO with change in SCG    ue_id=102
    Attach Ue To Enb    ue_id=103
    Start Gnb Addition Procedure and Generate Traffic    ue_id=103
    Perform Inter ENB HO with change in SCG    ue_id=103
    Wait For Next Full Pm Interval
    ${pm_counter_file_vcu}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55112C08007  +3  NX2CC_RAB_SETUP_ATT_INTRENB_HO
    ...    M55112C08008  +3  NX2CC_RAB_SETUP_ACK_INTRENB_HO
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counter_file_vcu}

    [Teardown]    Run Keywords    Deregister Ue Without Confirmation    ue_id=101-103
    ...           AND             Add Scout External Execution ID To Reporting Portal
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
