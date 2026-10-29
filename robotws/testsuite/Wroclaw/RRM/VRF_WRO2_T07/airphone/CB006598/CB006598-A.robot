*** Settings ***
Force Tags    CONFIGURED    CRT    PY310    RAN_5G    RAN_5G_TDD    SBTS00    CLOUD_5G_I_LO_AP_LO    NoResUsage    RF50
...           SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC

Documentation
...      == COPYRIGHT ==
...         Nokia Networks
...
...      == INTRODUCTION ==
...         This feature introduces the support of 3GPP Rel-16 SIB2 Parameters for UE measurement relaxation for UE Power Saving.
...         Operator can enable the functionality and set the related parameters accordingly.
...         gNB will broadcast such parameters in SIB2, so that UEs which support this functionality may improve battery duration when in idle mode.
...         The feature can be activated/deactivated by Operator configurable flag.
...
...      == TEST SET NAME ==
...         CB006598 - UE Power Saving: RRM Measurements relaxation in idle
...
...      == TESTING SPLIT ==
...         CB006598-A - UE Power Saving: RRM Measurements relaxation in idle
...
...      == CONTACTS ==
...         :copyright: Nokia
...         :authors: Anna Roskosz
...         :maintainer: Anna Szymandera-Bialek
...         :contact: anna.szymandera-bialek@nokia.com
...
...      == REFERENCES ==
...         CB006598 CFAM
...
...      == HISTORY ==
...         [12.01.2023] - TC Create
...         [08.02.2023] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=877558)

Resource    CB006598_Keywords_And_Variables.robot

Suite Setup    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...            AND             Reach OnAir    lua_cfg=${CURDIR}/config/egate_2c_TDD_SANSA.lua    cell_type=TDD
...            AND             Get Scfc File   output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...            AND             Find Scfc and Send Delta Commissioning    scfc_filename=delta_6598.json
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Suite Teardown    Run Keywords    Roll Delta Back
...                               initial_scf_filename=${OUTPUT_DIR}/initial_commissioning.xml
...                               delta_scf_filename=delta_6598.json
...               AND             Stop Default Processes And Gather Logs And Compress Logs

Test Setup    Start Default Logging    output_dirpath=${OUTPUT_DIR}/CB006598_A_5

Test Teardown    Run Keywords    Add Scout External Execution ID To Reporting Portal
...              AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/CB006598_A_5

*** Test Cases ***
CB006598-A_5 NIDD parameter combRelaxedMeasCond and highPrioMeasRelax online change
    [Documentation]
    ...    == DESCRIPTION ==
    ...  This test verifies that online modification of NRBTS/NRSYSINFO_PROFILE.combRelaxedMeasCond  is taken into account.
    ...  After setting combineRelaxedMeasCondition and highPrioMeasRelax to true gNB should broadcast
    ...  combineRelaxedMeasCondition-r16 and highPriorityMeasRelax-r16 IEs in SIB2.
    ...
    ...    == Precondition: ==
    ...    - gNB2 classical - real hardware - ASIL + ABIO
    ...    - NR cell is up and connected to AMF1
    ...    - AMF1 simulated
    ...    - UE_1 - Airphone simulator configured for SA mode
    ...    - gNB2 up and running with two SA cells
    ...    - NRCELL-1.actUeRelaxedMeasSA = true
    ...    - NRBTS-1.NRSYSINFO_PROFILE-1 = {
    ...      - highPrioMeasRelax = false
    ...      - combRelaxedMeasCond = false
    ...      - cellEdgeEvaluation = {
    ...        - sSearchThreshP = 15
    ...        - sSearchThreshQ = 1
    ...        }
    ...      - lowMobilityEvaluation = {
    ...        - sSearchDeltaP = dB9
    ...        - tSearchDeltaP = s120
    ...        }
    ...      }
    ...
    ...    == Postconditions ==
    ...     - SIB2 is broadcasted without combineRelaxedMeasCondition-r16 and highPriorityMeasRelax-r16 IEs.
    ...
    ...    == TESTING TOOLS ==
    ...      AirPhone, EPCSIM, UTE
    ...
    ...    == TEST ENVIRONMENT ==
    ...     - gNB classicBTS in SA mode
    ...     - HARDWARE ID:  gNB(ASIL + ABIO) with two simulated AEQE radio modules
    ...
    ...    == REQUIREMENTS COVERAGE ==
    ...      REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_19116, 5G_RAN_USR_RRM_19146
    ...
    ...    == REQUIRED LOGS ==
    ...      NR-RRC
    ...
    ...    == REFERENCES ==
    ...       Related CFAM US:
    ...       -  User scenario CB006598#3 NIDD parameter lowMobilityEvaluation online change
    ...       -  User scenario CB006598#1 CB006598 feature activation
    ...
    ...    == HISTORY ==
    ...       [11.05.2022] - TC Create
    ...       [08.02.2023] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=877558)

    Start Pcaps Collection For Test Subcase     output_dirpath=${OUTPUT_DIR}/CB006598_A_5   subcase_name=CB006598_A_5_1
    Block Single Cell    cell_id=1
    Unblock Single Cell    cell_id=1
    Verify Uu Messages For Subcase    packet_filter=${SIB_2_WITHOUT_MEAS_COND_RELAX}   subcase_name=CB006598_A_5_1    relation_symbol= >=
    Verify Uu Messages For Subcase    packet_filter=${SIB_2_WITHOUT_MEAS_COND_RELAX} && nr-rrc.s_SearchDeltaP_r16 == 2
    ...                               subcase_name=CB006598_A_5_1    relation_symbol= >=
    Verify Uu Messages For Subcase    packet_filter=${SIB_2_WITHOUT_MEAS_COND_RELAX} && nr-rrc.t_SearchDeltaP_r16 == 5
    ...                               subcase_name=CB006598_A_5_1    relation_symbol= >=
    Verify Uu Messages For Subcase    packet_filter=${SIB_2_WITHOUT_MEAS_COND_RELAX} && nr-rrc.s_SearchThresholdP_r16 == 15
    ...                               subcase_name=CB006598_A_5_1    relation_symbol= >=
    Verify Uu Messages For Subcase    packet_filter=${SIB_2_WITHOUT_MEAS_COND_RELAX} && nr-rrc.s_SearchThresholdQ_r16 == 1
    ...                               subcase_name=CB006598_A_5_1    relation_symbol= >=
    Stop Pcaps Collection For Test Subcase
    Start Pcaps Collection For Test Subcase     output_dirpath=${OUTPUT_DIR}/CB006598_A_5   subcase_name=CB006598_A_5_2
    Perform Parameter Commissioning    parameter=combRelaxedMeasCond    value=true    dist_name=MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1
    Verify Uu Messages For Subcase    packet_filter=${SIB_2_WITH_MEAS_COND_WITHOUT_RELAX}
    ...                               subcase_name=CB006598_A_5_2    relation_symbol= >=
    Verify Uu Messages For Subcase    packet_filter=${SIB_2_WITH_MEAS_COND_WITHOUT_RELAX} && nr-rrc.s_SearchDeltaP_r16 == 2
    ...                               subcase_name=CB006598_A_5_2    relation_symbol= >=
    Verify Uu Messages For Subcase    packet_filter=${SIB_2_WITH_MEAS_COND_WITHOUT_RELAX} && nr-rrc.t_SearchDeltaP_r16 == 5
    ...                               subcase_name=CB006598_A_5_2    relation_symbol= >=
    Verify Uu Messages For Subcase    packet_filter=${SIB_2_WITH_MEAS_COND_WITHOUT_RELAX} && nr-rrc.s_SearchThresholdP_r16 == 15
    ...                               subcase_name=CB006598_A_5_2    relation_symbol= >=
    Verify Uu Messages For Subcase    packet_filter=${SIB_2_WITH_MEAS_COND_WITHOUT_RELAX} && nr-rrc.s_SearchThresholdQ_r16 == 1
    ...                               subcase_name=CB006598_A_5_2    relation_symbol= >=
    Stop Pcaps Collection For Test Subcase
    Start Pcaps Collection For Test Subcase     output_dirpath=${OUTPUT_DIR}/CB006598_A_5   subcase_name=CB006598_A_5_3
    Perform Parameter Commissioning    parameter=highPrioMeasRelax    value=true    dist_name=MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1
    Verify Uu Messages For Subcase    packet_filter=${SIB_2_WITH_MEAS_COND_RELAX}
    ...                               subcase_name=CB006598_A_5_3    relation_symbol= >=
    Verify Uu Messages For Subcase    packet_filter=${SIB_2_WITH_MEAS_COND_RELAX} && nr-rrc.s_SearchDeltaP_r16 == 2
    ...                               subcase_name=CB006598_A_5_3    relation_symbol= >=
    Verify Uu Messages For Subcase    packet_filter=${SIB_2_WITH_MEAS_COND_RELAX} && nr-rrc.t_SearchDeltaP_r16 == 5
    ...                               subcase_name=CB006598_A_5_3    relation_symbol= >=
    Verify Uu Messages For Subcase    packet_filter=${SIB_2_WITH_MEAS_COND_RELAX} && nr-rrc.s_SearchThresholdP_r16 == 15
    ...                               subcase_name=CB006598_A_5_3    relation_symbol= >=
    Verify Uu Messages For Subcase    packet_filter=${SIB_2_WITH_MEAS_COND_RELAX} && nr-rrc.s_SearchThresholdQ_r16 == 1
    ...                               subcase_name=CB006598_A_5_3    relation_symbol= >=
    Stop Pcaps Collection For Test Subcase
    Start Pcaps Collection For Test Subcase     output_dirpath=${OUTPUT_DIR}/CB006598_A_5   subcase_name=CB006598_A_5_4
    Perform Parameter Commissioning    parameter=highPrioMeasRelax    value=false    dist_name=MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1
    Verify Uu Messages For Subcase    packet_filter=${SIB_2_WITH_MEAS_COND_WITHOUT_RELAX}
    ...                               subcase_name=CB006598_A_5_4    relation_symbol= >=
    Verify Uu Messages For Subcase    packet_filter=${SIB_2_WITH_MEAS_COND_WITHOUT_RELAX} && nr-rrc.s_SearchDeltaP_r16 == 2
    ...                               subcase_name=CB006598_A_5_4    relation_symbol= >=
    Verify Uu Messages For Subcase    packet_filter=${SIB_2_WITH_MEAS_COND_WITHOUT_RELAX} && nr-rrc.t_SearchDeltaP_r16 == 5
    ...                               subcase_name=CB006598_A_5_4    relation_symbol= >=
    Verify Uu Messages For Subcase    packet_filter=${SIB_2_WITH_MEAS_COND_WITHOUT_RELAX} && nr-rrc.s_SearchThresholdP_r16 == 15
    ...                               subcase_name=CB006598_A_5_4    relation_symbol= >=
    Verify Uu Messages For Subcase    packet_filter=${SIB_2_WITH_MEAS_COND_WITHOUT_RELAX} && nr-rrc.s_SearchThresholdQ_r16 == 1
    ...                               subcase_name=CB006598_A_5_4    relation_symbol= >=
    Stop Pcaps Collection For Test Subcase
    Start Pcaps Collection For Test Subcase     output_dirpath=${OUTPUT_DIR}/CB006598_A_5   subcase_name=CB006598_A_5_5
    Perform Parameter Commissioning    parameter=combRelaxedMeasCond    value=false    dist_name=MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1
    Verify Uu Messages For Subcase    packet_filter=${SIB_2_WITHOUT_MEAS_COND_RELAX}
    ...                               subcase_name=CB006598_A_5_5    relation_symbol= >=
    Verify Uu Messages For Subcase    packet_filter=${SIB_2_WITHOUT_MEAS_COND_RELAX} && nr-rrc.s_SearchDeltaP_r16 == 2
    ...                               subcase_name=CB006598_A_5_5    relation_symbol= >=
    Verify Uu Messages For Subcase    packet_filter=${SIB_2_WITHOUT_MEAS_COND_RELAX} && nr-rrc.t_SearchDeltaP_r16 == 5
    ...                               subcase_name=CB006598_A_5_5    relation_symbol= >=
    Verify Uu Messages For Subcase    packet_filter=${SIB_2_WITHOUT_MEAS_COND_RELAX} && nr-rrc.s_SearchThresholdP_r16 == 15
    ...                               subcase_name=CB006598_A_5_5    relation_symbol= >=
    Verify Uu Messages For Subcase    packet_filter=${SIB_2_WITHOUT_MEAS_COND_RELAX} && nr-rrc.s_SearchThresholdQ_r16 == 1
    ...                               subcase_name=CB006598_A_5_5    relation_symbol= >=
    Stop Pcaps Collection For Test Subcase
