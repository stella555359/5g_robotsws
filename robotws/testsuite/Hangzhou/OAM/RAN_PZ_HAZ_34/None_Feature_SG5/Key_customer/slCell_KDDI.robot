*** Settings ***
Suite Setup        SISO Coam Suite Setup
Suite Teardown     SISO Coam Suite Teardown
Test Setup         #SISO Coam Test Setup
Test Teardown      #SISO Coam Test Teardown
Test Timeout       12 hours

Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource           ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource           ${BASIC_PATH_5G}/General_Stability_Test_Case.robot
Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Resource           ./resources/slCell_cases.robot
Resource           taf/rfrl/uuf4all/resources/robot/uuf_rfrl_common_keywords.robot

Documentation
...    author: annie.hu
...    contact: annie.hu@nokia-sbell.com
...    squad group: SG_05
...    Feature 'CS4.2 Sleeping Cell Case'

Force Tags      E2E_SBM    SG_05

*** Variables ***
${total_loops}                  ${1}
${if_commissioning}             True
@{CUSTOMERS_LIST}               Softbank
${REPORT_COMMENT}=              ${None}
${qc_domain}=                   MN_RAN_ST
${qc_id}=                      ${None}  # SHOULD BE DIFFERENT FOR EACH TEST CASE ACCORDING TO QC_ID OF EACH TEST
${qc_project}=                  RAN_ST
${LABEL}=                       ${None}

*** Test Cases ***
[1]E2E_TL_Cell_Block_Unblock_NR_with_OAM_KPI
    [Tags]    QC_621881    QCP_RAN_ST    QCD_MN_RAN     E2E_slCell
    [Setup]    SISO Coam Test Setup
    Log To Console    \ntotal times:${total_loops}
    Set Test case Variables
    Run Keyword And Ignore Error  uuf_rfrl_oam_kpi.Clear Kpi Results
    Set Test Variable  ${CASE_TYPE}    NRCEL_BLOCK
    Set Test Variable  ${CELL_TYPE}    NRCEL
    @{list_of_cells}=  uuf_rfrl_common.Get List Of Cells For Block Test  ${CELL_TYPE}
    ${cells_iterator}=  uuf_rfrl_common.Load List As Iterator  ${list_of_cells}
    Set Test Variable  ${CELLS_ITERATOR}  ${cells_iterator}
    slCell_keywords.Verify Test In Loop    iteration_number=${3}    should_be_reported=false
    ...    test_keyword=slCell_Cell_Block_Unblock
    #[Teardown]    SISO Coam Test Teardown

[1]E2E_TL_Cell_Lock_Unlock_NR_with_OAM_KPI
    [Tags]    E2E_slCell
    [Setup]    SISO Coam Test Setup
    Log To Console    \ntotal times:${total_loops}
    Set Test case Variables
    Run Keyword And Ignore Error  uuf_rfrl_oam_kpi.Clear Kpi Results
    Set Test Variable  ${CASE_TYPE}  NRCEL_LOCK
    Set Test Variable  ${CELL_TYPE}  NRCEL
    slCell_keywords.Verify Test In Loop    iteration_number=${3}    should_be_reported=false
    ...    test_keyword=slCell_Cell_Lock_Unlock
 #   [Teardown]    SISO Coam Test Teardown

[1]E2E_TL_RU_Reset_with_OAM_KPI
    [Tags]    QC_623694    QCP_RAN_ST    QCD_MN_RAN     E2E_slCell
    [Setup]    SISO Coam Test Setup
    Log To Console    \ntotal times:${total_loops}
    Set Test case Variables
    Run Keyword And Ignore Error  uuf_rfrl_oam_kpi.Clear Kpi Results
    Set Test Variable   ${CASE_TYPE}    RMOD_RESET
    slCell_keywords.Verify Test In Loop    iteration_number=${20}    should_be_reported=false
    ...    test_keyword=slCell_RU_Reset
    #[Teardown]    SISO Coam Test Teardown

[1]E2E_TL_Capacity_Module_Reset_with_OAM_KPI
    [Tags]    E2E_slCell
    [Setup]    SISO Coam Test Setup
    Log To Console    \ntotal times:${total_loops}
    Set Test case Variables
    Run Keyword And Ignore Error  uuf_rfrl_oam_kpi.Clear Kpi Results
    Set Test Variable  ${CASE_TYPE}  BBMOD_RESET
    slCell_keywords.Verify Test In Loop    iteration_number=${20}    should_be_reported=false
    ...    test_keyword=slCell_Capacity_Module_Reset
    #[Teardown]    SISO Coam Test Teardown

[1]E2E_TL_Delta_Commissioning_With_Site_Reset_Required_sleeping_cell_check
    [Tags]    E2E_slCell
    [Setup]    SISO Coam Test Setup
    Log To Console    \ntotal times:${total_loops}
    Set Test case Variables
    Run Keyword And Ignore Error  uuf_rfrl_oam_kpi.Clear Kpi Results
    slCell_keywords.Verify Test In Loop    iteration_number=${3}    should_be_reported=false
    ...    test_keyword=slCell_Delta_Commissioning_With_Site_Reset_Required
    [Teardown]    SISO Coam Test Teardown

[1]E2E_TL_Site_Reset_without_HWF_with_OAM_KPI
    [Tags]    E2E_slCell
    [Setup]    SISO Coam Test Setup
    Log To Console    \ntotal times:${total_loops}
    Run Keyword And Ignore Error  uuf_rfrl_oam_kpi.Clear Kpi Results
    Set Test case Variables
    ${case_type}=  Convert To String  Reset
    Set Test Variable  ${CASE_TYPE}  ${case_type}
    slCell_keywords.Verify Test In Loop    iteration_number=${20}    should_be_reported=True
    ...    test_keyword=slCell_Reset_with_HWF_deletion
    [Teardown]    Run Keywords    Recovery ENV after HWF reset    SISO Coam Test Teardown

[1]E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI
    [Tags]    E2E_slCell    SW_upgrade_rollback
    [Setup]    SISO Coam Test Setup
    ${case_type}=  Convert To String  Upgrade
    Set Test Variable  ${CASE_TYPE}  ${case_type}
    Set Test case Variables
    Run Keyword And Ignore Error  uuf_rfrl_oam_kpi.Clear Kpi Results
    Log To Console    \ntotal times:${total_loops}
    slCell_keywords.Verify Test In Loop    iteration_number=${2}    should_be_reported=True
    ...    test_keyword=slCell_SW_upgrade_rollback
    #[Teardown]    SISO Coam Test Teardown

*** Keywords ***
