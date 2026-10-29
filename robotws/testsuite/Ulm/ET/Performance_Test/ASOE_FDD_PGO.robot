*** Settings ***
Documentation
...  author:  bernd.flemming@nokia.com
...  contact: I_MN_RAN_SW_ULM_ET_AP_PET_GMS
...  Description:   Test Cases for FDD Performance Test

Resource   ./resources/performance_egate.robot
Resource   ./resources/performance_info.robot
Resource   ./resources/performance_keywords.robot
Resource   ./resources/performance_test_setup.robot

Suite Setup       performance_test_setup.Suite Setup For Performance Test    ENABLE_SOS_REPORT=false
Suite Teardown    performance_test_setup.Suite Teardown For Performance Test
Test Setup        performance_test_setup.Test Case Setup For Performance Test
Test Teardown     performance_test_setup.Test Case Teardown For Performance Test    db_L2_ET_PGO_KPI


*** Test Cases ***
ASOE_FDD_6Cells_72UEsPerCell_UL_DL_knife
    [Documentation]
    ...    Performance Test with Profile Guided Optimization for FDD ASOE configuration with 72 UEs attached to all Cells
    ...    running DL only traffic simultaneously
    [Tags]    ULDL    CLOUD_5G_O_E_AP_LOOO    PGO    ASOE    FDD
    &{tc}    Create Dictionary     start_cell=1
    ...                              end_cell=6
    ...                           ue_per_cell=72
    ...                           ul_datarate=3000
    ...                           dl_datarate=12800
    ...                                  rate=kbps
    ...                         trf_direction=both
    ...                             tolerance=0.9312789351851852  # Verify_TP_with_Counters_FDD_DL=14250000
    ...                                   lua=sansa_fdd_6cell.lua
    ...                             ue_nr_cap=UE_CAP_4x4
    ...                       entry_auto_args=true
    ...                                 entry=performance_common_lua_fdd
    performance_keywords.Run Common Test    &{tc}


ASOE_FDD_6Cells_72UEsPerCell_UL_DL_BL
    [Documentation]
    ...    Performance Test with Profile Guided Optimization for FDD ASOE configuration with 72 UEs attached to all Cells
    ...    running DL only traffic simultaneously
    [Tags]    ULDL    CLOUD_5G_O_E_AP_LOOO    PGO    ASOE    FDD
    ${NUMBER_OF_CELLS}    Set Variable    6
    performance_egate.Create Lua From Template             sansa_fdd_template.lua    sansa_fdd_asoe_6cell.lua
    ...                                                    NUMBER_OF_CELLS=${NUMBER_OF_CELLS}
    ...                                                    UE_COUNT_ON_CELL=432

    performance_egate.Run Sansa Configuration Script       sansa_fdd_asoe_6cell.lua

    IF    "${TP.HALT_EXECUTION_ON_AIR}"=="true"
        Pass Execution    \n\n**********\n\nExecution Halts On Air\n\n**********\n\n
    END
    performance_egate.Wait For SIB                         start_cell=${1}    end_cell=${6}

    performance_egate.Run Test Script    entry=ASOE_FDD_6Cells_72UEsPerCell_UL_DL
    ...                                  pass_regexp=UE432: Started (Down|Up)link
    Sleep    10min                       reason=collect enough data for performance test analysis
    performance_verification.Verify Total Number Of Active UEs    expected=432
    wts_verification.Verify Number Of Active UEs In Cells    72     ${NUMBER_OF_CELLS}
    performance_info.Check UE TP                          dir=both
    performance_verification.Verify TP With Counters FDD          dir=both
    performance_info.Print TTI PM Counters
