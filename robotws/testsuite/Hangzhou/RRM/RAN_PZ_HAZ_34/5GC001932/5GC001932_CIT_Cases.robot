*** Settings ***
Documentation     author: Liu Tiffany Zhang Haijun
...               contact: tiffany.liu@nokia-sbell.com haijun.zhang@nokia-sbell.com
Suite Setup       Run Keywords    robot_common_operations.Common Suite Setup    AND   TestSuite.Init
Suite Teardown    Run Keywords    robot_common_operations.Common Suite Teardown    AND   TestSuite.Destroy
Force Tags        RAN_5G  RAN_5G_TDD   STATE_SW_UPLOADED  SBTS00  SBTS22R2  SBTS24R3  SBTS24R2  SBTS25R1
...    CLOUD_5G_CLASSICAL_FULLRACK_QC_SA_ASIKL_ABILB1_AHPE-ASIKR_ABILB4_AEHC    PY36
Resource          ../5GC001932/Resources/5GC001932_Resources.robot
Resource              ../5GC000829/Resources/5GC000829-Resource.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot

*** Test Cases ***
#[1][1.0] 5GC001932_001_SiSo_ALD_HW_inventory_ALD_HW_properties_retrieval_and_visualization
#    [Tags]            CRT_21A       CRT_21B
#    [Setup]           KW.CaseInit
#    [Teardown]        KW.CaseDestroy
#    [Timeout]         180 minutes
#    TC.5GC001932_001_SiSo_ALD_HW_inventory_ALD_HW_properties_retrieval_and_visualization

[1][1.0] 5GC001932_003_SiSo_ALD_Configuration_Management_RAE_reading_beamforming_weight_factors
    [Tags]           CIT_TRUNK     CRT_20B     CRT_21A       CRT_21B   CIT
    [Setup]           Run Keywords    robot_common_operations.Common Case Setup    AND   KW.CaseInit
    [Teardown]        Run Keywords    robot_common_operations.Common Case Teardown   AND   KW.CaseDestroy
    [Timeout]         180 minutes
    TC.5GC001932_003_SiSo_ALD_Configuration_Management_RAE_reading_beamforming_weight_factors

[1][1.0] 5GC001932_008_SiSo_ALD_FM_Antenna_Line_Device_faulty_notification_recovery_action_indication_and_visualization
    [Tags]            CRT_TRUNK    CRT_20B     CRT_21A       CRT_21B    CRT_UTE
    [Setup]           Run Keywords    robot_common_operations.Common Case Setup    AND   KW.CaseInit
    [Teardown]        Run Keywords    robot_common_operations.Common Case Teardown   AND   KW.CaseDestroy
    [Timeout]         180 minutes
    TC.5GC001932_008_SiSo_ALD_FM_Antenna_Line_Device_faulty_notification_recovery_action_indication_and_visualization

[1] 5GC000829_A_022_SA_Call_on_SecondaryCore_in_dual-core_gNB
    [Documentation]   Verify SA call attach/detach on secondary core cell(s) in dual-core BTS.
    [Tags]  CRT_21A    CRT_22R1    CRT_22R2    CIT_TRUNK    CIT
    [Setup]  Run Keywords    robot_common_operations.Common Case Setup    AND   KW.CaseSetup
    [Teardown]  Run Keywords    robot_common_operations.Common Case Teardown   AND   KW.CaseTeardownOf5GC000829_A_022
    [Timeout]  60 minutes
    TC.5GC000829_A_022_L3callOnSecondaryCore

*** Keywords ***
TestSuite.Init
    Setup My Suite
    KW.829Setup Suite
TestSuite.Destroy
    TestSuilt.Destroy
