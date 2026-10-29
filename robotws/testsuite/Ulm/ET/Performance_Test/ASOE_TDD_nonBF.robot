*** Settings ***
Documentation
...  author:  Squad 69
...  contact: I_MN_RAN_SW_ULM_ET_AP_PET_GMS
...  Description:   Test Cases for TDD 1 Cell 100 UEs Performance Test

Resource   ./resources/performance_egate.robot
Resource   ./resources/performance_info.robot
Resource   ./resources/performance_keywords.robot
Resource   ./resources/performance_test_setup.robot
Resource   ./resources/performance_log_collection.robot

Force Tags    CLOUD_5G_O_E_AP_LO

Suite Setup       performance_test_setup.Suite Setup For Performance Test
...                                                   SCF_ENABLE_BEAMFORMING=true    # convert this to BF testcase when enabled
...                                                   SCF_CONFIGURE_SRS=true
...                                                   ENABLE_SRS_INFO=true
...                                                   SCF_SET_VAR_NRCELL_actUlSrsBm=true
...                                                   SCF_SET_VAR_NRCELL_actDlSrsBm=true
Suite Teardown    performance_test_setup.Suite Teardown For Performance Test
Test Setup        performance_test_setup.Test Case Setup For Performance Test
Test Teardown     performance_test_setup.Test Case Teardown For Performance Test


*** Test Cases ***
tdd_1Cell_100Ues_DL_ASOE
    [Documentation]
    ...    Performance Test for TDD ASOE configuration with 100 UEs attached to 1 Cell and running DL traffic simultaneously
    [Tags]    DL
    [Setup]    performance_test_setup.Test Case Setup For Performance Test    ENABLE_MARVIN=true
    performance_egate.Run Sansa Configuration Script

    IF    "${TP.HALT_EXECUTION_ON_AIR}"=="true"
        Pass Execution    \n\n**********\n\nExecution Halts On Air\n\n**********\n\n
    END
    performance_egate.Run Test Script    entry=PET_1208FF_nonBF_100UE_DL

    performance_log_collection.Wait And Collect One Measurement Cycle    label=default_traffic

    performance_verification.Verify Total Number Of Active UEs    expected=100
    wts_verification.Verify Number Of Active UEs In Cells    100    1
    performance_info.Check UE TP    dir=dl
    performance_verification.Verify TP With Counters TDD    dir=dl
    performance_info.Print TTI PM Counters


tdd_1Cell_100Ues_UL_ASOE
    [Documentation]
    ...    Performance Test for TDD ASOE configuration with 100 UEs attached to 1 Cell and running UL traffic simultaneously
    [Tags]    UL
    performance_egate.Run Sansa Configuration Script

    IF    "${TP.HALT_EXECUTION_ON_AIR}"=="true"
        Pass Execution    \n\n**********\n\nExecution Halts On Air\n\n**********\n\n
    END
    performance_egate.Run Test Script    entry=PET_1208FF_nonBF_100UE_UL

    performance_log_collection.Wait And Collect One Measurement Cycle    label=default_traffic

    performance_verification.Verify Total Number Of Active UEs    expected=100
    wts_verification.Verify Number Of Active UEs In Cells    100    1
    performance_info.Check UE TP    dir=ul
    performance_verification.Verify TP With Counters TDD    dir=ul
    performance_info.Print TTI PM Counters

