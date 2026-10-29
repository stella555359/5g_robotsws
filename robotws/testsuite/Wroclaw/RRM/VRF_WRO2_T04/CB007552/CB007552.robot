*** Settings ***
Documentation
...     Author: Tomasz Mozola
...     Contact: tomasz.mozola@nokia.com

Resource    resources/CB007552_keywords.robot
Resource    ../CB008697/resources/keywords.robot

*** Keywords ***
CB007552-E_13_NSA_MUE_HO-FDD-TDD_CA_SCell_selection_UE1_PC1_Sbwp_SC1_Lbwp_UE2_PC2_Lbwp_SC2_Lbwp
    [Documentation]   Test checking mulitiple BWP for SA/NSA mode, UE is supported for Large BWP 30MHz FDD with CA
    ...               during call Ue should select large BWP dedicated profile.
    Set att environment
    Start tracing on SMOD
    ute_ue.Require UE       UE_1     capabilities=UE_1
    ute_ue.Attach UE        UE_1
    Verify 5G SA Attach
    ${log_path}    Stop tracing and download logs from SMOD
    Set att environment      cell_105_value=0
    ${avg_tput}    Start CA full Buffer DL Traffic    dt_name=DL_2CC       tput=900Mbits/sec    UE_NAME=UE_1
    Compare with expected traffic     ${avg_tput}     expected_tput=800    deviation=15%
    Check CA status
    Verify expected Large Pcell BWP for SA
    [Teardown]   Env teardown
