*** Settings ***

Documentation   This is a Robot Test Suite for feature 5GC000707 'InterRat HO LTE' testing
...             This feature has 3 subfeatures itemized from A to E which support the full chain of InterRat Handover LTE.
...             Link to Test Strategy: https://nokia.sharepoint.com/:w:/r/sites/MN5GSCProductization/Shared%20Documents/General/
...                                    5G%26SC%20Collaborator/5GC000600%E2%80%935GC000799/5GC000707/5GC000707_Feature_Test_Strategy.docx
...                                    ?d=w5d3c577623544040aa955e7c98eeb3b4&csf=1&web=1&e=Et8mkt
...             Team: 'MN RAN RD VRF ULM 4'
...             Email: 'OU_MN_RAN_RD_VRF_ULM_4_53245007@internal.nsn.com'
#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
Resource        5GC000707_Keywords.robot

Suite Setup     Prepare TL for 5GC000707
Suite Teardown  Sqd65 Common Teardown

Test Setup      Perform Preconditions of Test Scenario
Test Teardown   Perform Postconditions of Test Scenario


*** Test Cases ***

5GC000707_A_TC01_Verify_successful_configuration_of_IRAT_HO_parameters_from_WebGUI
    [Documentation]  The purpose of this TC is to verify successful configuration of IRAT HO parameters from WebGUI
    [Tags]    TC01
    @{scf_verification_list}=  Create List
    ...                        ${actInterRatHoSA}  ${a1MeashoEnabledSA}  ${a2MeashoEnabledSA}  ${b2MeashoEnabled}
    ${log_dir}=       Get Testcase Log Directory
    ${scf_file}=      Get SCF from gNB       target_dir=${log_dir}
    scf.load_scf      ${scf_file}
    FOR  ${param}  IN  @{scf_verification_list}
         ${scf_value}=  scf.get_value_from_scf  dist_name=${param['dist_name']}   p_name=${param['p_name']}
         Should be Equal   ${scf_value}  ${param['value']}  ignore_case=True
    END

5GC000707_A_TC04_Verify_A2_measurement_configuration_on_target_cell_after_successful_intra-frequency_Intra-DU_Intra-gNB_handover_triggered_by_A3
    [Documentation]  The purpose of this TC is to verify that A2 measurement configuration on target cell
    ...              after successful intra-frequency Intra-DU Intra-gNB handover triggered by A3
    ...              meas cfg value verification missing (egate_console.log)
    [Tags]    TC04  CRT
    ${ue_id}=    Set Variable                    51
    Register UE                                  ue_id=${ue_id}  cell_id=4
    Intra-frequency Intra-DU Intra-gNB Handover  ue_id=${ue_id}  phycell_id=52
    Verify Measurement is configured             ue_id=${ue_id}  event=A2
    UE Deregister                                ue_id=${ue_id}


5GC000707_A_TC13_Verify_successful_addition_of_B2_A1_removal_of_A2_after_MR_A2_received_and_removal_of_B2_A1_addition_of_A2_after_MR_A1_received
    [Documentation]  The purpose of this TC is to verify successful addition of B2, A1 and removal of A2 after MR A2 received
    ...              and removal of B2, A1, and addition of A2 after MR A1 received while a2MeashoEnabled=a1MeashoEnabled=rsrp
    ...              meas cfg value verification missing (egate_console.log)
    [Tags]    TC13  CRT
    ${ue_id}=    Set Variable                    51
    Register UE                                  ue_id=${ue_id}  cell_id=3
    Serving becomes worse than threshold         ue_id=${ue_id}
    Sleep   1
    Serving becomes better than threshold        ue_id=${ue_id}
    Verify PM Counters                           tc=A_13  dn_suffix=3
    UE Deregister                                ue_id=${ue_id}

5GC000707_A_TC25_Verify_gNB_ignores_Measurement_Report_A1_if_servCellId_in_received_measurement_report_not_equal_to_index_of_primary_cell
    [Documentation]  The purpose of this TC is to verify that gNB ignores Measurement Report A1,
    ...              if servCellId in received measurement report not equal to index of primary cell
    [Tags]    TC25  CRT
    ${ue_id}=    Set Variable                    51
    Register UE                                  ue_id=${ue_id}  cell_id=3
    Serving becomes worse than threshold         ue_id=${ue_id}
    A1 Measurement Report with wrong servCellId  ue_id=${ue_id}
    Verify Measurement is configured             ue_id=${ue_id}  event=A1
    Verify Measurement is configured             ue_id=${ue_id}  event=B2
    Verify PM Counters                           tc=A_25  dn_suffix=3
    UE Deregister                                ue_id=${ue_id}

5GC000707_A_No_InterRAT_HO_if_not_supported_by_UE-NR-Capability
    [Documentation]  The purpose of this TC is to verify, that, if the preconditions for interRat HO are NOT supported by UE,
    ...              interRat HO is NOT triggered by gNB, respectivly the required UE measurements events (in  this case: A2) are not setup by gNB
    ...              additional TC regarding customer PRONTO 02125057: [5G_KIC]Inter-RAT HO is triggered for UE not thought to be capable
    ...              (-> CNI-76790-ULMB-NUS01_L3_ET_1)
    [Tags]    CNI-76790  CRT
    ${ue_id}=    Set Variable                    51
    Register UE                                  ue_id=${ue_id}  cell_id=3
    Verify Measurement is configured             ue_id=${ue_id}  event=A2
    UE Deregister                                ue_id=${ue_id}
    Apply Config according CNI                   ue_id=${ue_id}
    Register UE                                  ue_id=${ue_id}  cell_id=3
    Verify Measurement is absent                 ue_id=${ue_id}  event=A2
    UE Deregister                                ue_id=${ue_id}
