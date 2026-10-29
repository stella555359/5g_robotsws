*** Setting ***
Documentation         author: Zhang Wenjin
...                           Luo Frank
...                           Cai Wenjuan
...                           Li Yajie
...                           Gao Ge
...                   contact: wenjin.zhang@nokia-sbell.com
...                   squard group: SG_01
...                   feature: 5GC000829
Suite Setup           Setup Suite
Suite Teardown        Teardown Suite
Force Tags        RAN_5G  RAN_5G_TDD   STATE_SW_UPLOADED  SBTS00  SBTS22R2
...    CLOUD_5G_CLASSICAL_FULLRACK_QC_SA_ASIKL_ABILB1_AHPE-ASIKR_ABILB4_AEHC    PY36
Resource              ../5GC000829/Resources/5GC000829-Resource.robot

*** Test Cases ***
#[1] 5GC000829_A_018_Troubleshooting_Snapshot_in_dual-core_gNB
#    [Documentation]  Main test Steps:
#     ...             Step 1:Check cell on air.
#     ...             Step 2:Login WebEM, collect snapshot.
#     ...             Step 3:UnZip snapshot and check snapshot_file_list file include checkpoint.
#    [Tags]  CRT_21A
#    [Setup]  KW.CaseSetup
#    [Teardown]  KW.CaseTeardownOf5GC000829_A_018
#    [Timeout]  30 minutes
#    TC.5GC000829_A_018_Troubleshooting_Snapshot_in_dual-core_gNB

[1] 5GC000829_A_005_Sync_UI_in_dual-core_gNB
    [Documentation]   Verify WebEM supports synchronization status UI for primary core and secondary core separately in dual-core gNB.
    [Tags]  CRT_21A    CRT_21B    CRT_22R1    CRT_22R2
    [Setup]  KW.CaseSetup
    [Teardown]  KW.CaseTeardown
    [Timeout]  30 minutes
    TC.Sync_UI_in_dual-core_gNB

[1] 5GC000829_A_006_HW_inventory_retrieval_in_dual-core_gNB
    [Documentation]  Verify HW management procedures for dual-core gNB are handled in the same way as single-core gNB
    [Tags]  CRT_21A    CRT_21B    CRT_22R1    CRT_22R2
    [Setup]  KW.CaseSetup
    [Teardown]  KW.CaseTeardown
    [Timeout]  30 minutes
    TC.HWInventoryRetrievalInDualCore

[1] 5GC000829_A_101_Secondary_core_failure_escalate_to_Site_Reset
    [Documentation]  Prerequisites:
    ...    dual-core on air.
    ...    Test steps:
    ...    1) Trigger primary core SW fallback to previous passive SW version.
    ...    2) Check fault management handling after primary core fallback completed.
    ...    3) Manual SW update secondary core with the version same as running on primary core via WebEM.
    ...    4) Recover test environment by manual SW update dual-core gNB to other SW version.
    [Tags]  CRT_TRUNK    CRT_UTE    101
    [Setup]  KW.CaseSetup
    [Teardown]  KW.CaseTeardown
    [Timeout]  120 minutes
    TC.CB007310_A_101_Secondary_core_failure_escalate_to_Site_Reset

[1] 5GC000829_A_103_SWM_Primary_core_SW_fallback
    [Documentation]  Prerequisites:
    ...    dual-core on air.
    ...    Test steps:
    ...    1) Trigger primary core SW fallback to previous passive SW version.
    ...    2) Check fault management handling after primary core fallback completed.
    ...    3) Manual SW update secondary core with the version same as running on primary core via WebEM.
    ...    4) Recover test environment by manual SW update dual-core gNB to other SW version.
    [Tags]  CRT_TRUNK    CRT_UTE    103   105
    [Setup]  KW.CaseSetup
    [Teardown]  KW.CaseTeardown
    [Timeout]  210 minutes
    TC.5GC000829_A_103_SWM_Primary_core_SW_fallback

[1] 5GC000829_A_104_SWM_Secondary_core_SW_fallback
    [Documentation]  Prerequisites:
    ...    dual-core on air.
    ...    Test steps:
    ...    1) Trigger primary core SW fallback to previous passive SW version.
    ...    2) Check fault management handling after primary core fallback completed.
    ...    3) Manual SW update secondary core with the version same as running on primary core via WebEM.
    ...    4) Recover test environment by manual SW update dual-core gNB to other SW version.
    [Tags]  CRT_TRUNK    CRT_UTE    104    105
    [Setup]  KW.CaseSetup
    [Teardown]  KW.CaseTeardown
    [Timeout]  120 minutes
    TC.CB007310_A_104_SWM_Secondary_core_SW_fallback

[1] 5GC000829_A_105_SWM_SW_fallback
    [Documentation]  Prerequisites:
    ...    dual-core on air.
    ...    Test steps:
    ...    1) Trigger primary core SW fallback to previous passive SW version.
    ...    2) Check fault management handling after primary core fallback completed.
    ...    3) Manual SW update secondary core with the version same as running on primary core via WebEM.
    ...    4) Recover test environment by manual SW update dual-core gNB to other SW version.
    [Tags]  CRT_TRUNK    CRT_UTE    105
    [Setup]  KW.CaseSetup
    [Teardown]  KW.CaseTeardown
    [Timeout]  120 minutes
    TC.CB007310_A_105

[1] 5GC000829_C_005_Fault4385_when_Secondary_core_lost_Sync_from_Primary
    [Documentation]   VThis case is to verify when secondary core lost synchronization signal from primary core,
    ...               fault4385:  EFaultId_PpsRefFromBackplaneMissingAl shall be raised by secondary core
    [Tags]  CRT_21A    CRT_TRUNK    CRT_21B    CRT_22R1    CRT_22R2    CRT_UTE
    [Setup]  KW.CaseSetup
    [Teardown]  KW.CaseTeardown
    [Timeout]  30 minutes
    TC.WhenSecondaryCoreLostSyncFromPrimaryFault4385Raise

#[1] 5GC000829_A_013_PM_without_Call_in_dual-core_gNB
#    [Documentation]  Verify PM procedures for dual-core gNB are handled in the same way as single-core gNB,
#    ...              the case just checks generic SMOD and Cell level measurements, it won't cover all measurements or detail counters.
#    [Tags]  CRT_21A    CRT_21B    CRT_22R1
#    [Setup]  KW.CaseSetup
#    [Teardown]  KW.CaseTeardown
#    [Timeout]  30 minutes
#    TC.PMWithoutCallInDualCore

[1] 5GC000829_A_010_CM_Update_for_online-modify-type_NIDD_in_dual-core_gNB
    [Documentation]  Verify CM procedures for online modify-type NIDD parameter(s)
    ...    in dual-core gNB are handled in the same way as single-core gNB.
    [Tags]  CRT_21A    CRT_TRUNK    CRT_21B    CRT_22R1    CRT_UTE
    [Setup]  KW.CaseSetupOf5GC000829_A_010
    [Teardown]  KW.CaseTeardownOf5GC000829_A_010
    [Timeout]  60 minutes
    TC.OnlineModifyTypeNIDDInDualCore

#[1] 5GC000829_A_016_FM_for_SMOD_in_dual-core_gNB
#    [Documentation]  Verify FM procedures for dual-core gNB are handled in the same way as single-core gNB,
#     ...             the case focus on SMOD alarming object and just select one or two alarm/fault for test
#    [Tags]  CRT_21A    CRT_21B    CRT_22R1
#    [Setup]  KW.CaseSetup
#    [Teardown]  KW.CaseTeardownOf5GC000829_A_016
#    [Timeout]  30 minutes
#    TC.FMForSmodInDualCore

[1] 5GC000829_A_009_Modules_Resets_in_dual-core_gNB
    [Documentation]  Verify moudles reset via WebEM for dual-core gNB are handled in the same way as single-core gNB
    [Tags]  CRT_21A    CRT_21B    CRT_22R1    CRT_22R2
    [Setup]  KW.CaseSetup
    [Teardown]  KW.CaseTeardown
    [Timeout]  120 minutes
    TC.ResetMoudlesOfDualCore

[1] 5GC000829_A_021_SA_Call_on_PrimaryCore_in_dual-core_gNB
    [Documentation]   Verify SA call attach/detach on primary core cell(s) in dual-core BTS.
    [Tags]  CRT_21A    CRT_TRUNK    CRT_21B    CRT_22R2    CRT_UTE
    [Setup]  KW.CaseSetup
    [Teardown]  KW.CaseTeardownOf5GC000829_A_021
    [Timeout]  60 minutes
    TC.L3callOnPrimaryCore

[1] 5GC000829_A_022_SA_Call_on_SecondaryCore_in_dual-core_gNB
    [Documentation]   Verify SA call attach/detach on secondary core cell(s) in dual-core BTS.
    [Tags]  CRT_21A    CRT_22R1    CRT_22R2    CIT_TRUNK
    [Setup]  KW.CaseSetup
    [Teardown]  KW.CaseTeardownOf5GC000829_A_022
    [Timeout]  60 minutes
    TC.5GC000829_A_022_L3callOnSecondaryCore

[1] 5GC000829_C_001_Secondary_core_System_Module_reboot
    [Documentation]  Main test Steps:
     ...             Step 1:SSH to Secondary core and execute "reboot".
     ...             Step 2:Check fault 4352 raised from Secondary core
     ...                    Check Cell status of Secondary core and Primary core via WebEM@MPlane.
     ...             Step 3:Wait until Secondary core reset completed, Check fault 4352 and Cell status of Secondary core again.
    [Tags]  CRT_21A    CRT_TRUNK    CRT_21B    CRT_22R1    CRT_22R2    CRT_UTE
    [Setup]  KW.CaseSetup
    [Teardown]  KW.CaseTeardown
    [Timeout]  30 minutes
    TC.5GC000829_C_001_Secondary_core_System_Module_reboot

#[1] 5GC000829_A_033_Recommission_to_dual-core_gNB
#    [Documentation]   Verify backplane connection can setup between primary core and secondary core, all HW can be detected
#    ...               and visible in WebEM when two cores are in uncomissioned state.
#    [Tags]  CRT_21A
#    [Setup]  KW.CaseSetup
#    [Teardown]  KW.CaseTeardown
#    [Timeout]  60 minutes
#    TC.ModuleDetectInUncommissionState

#[1] 5GC000829_C_004_Secondary_core_Recovery_reset_after_inter-core_connection_restored
#    [Documentation]    Verify secondary core autonomous reset and recovery is triggered when the inter-core management connection
#    ...                between Primary and Secondary core is restored.
#    [Tags]    CRT_21A
#    [Setup]  KW.CaseSetup
#    [Teardown]  KW.CaseTeardown
#    [Timeout]  60 minutes
#    TC.5GC000829_C_004_Secondary_core_Recovery_reset_after_inter-core_connection_restored

[1] 5GC000829_K_002_Remote_Migration_from_single-core_to_dual-core_gNB_left_as_primary
    [Documentation]  Prerequisites:
    ...    1) left: signle-core on air.
    ...    2) Right: uncommissioned.
    ...    Test steps:
    ...    1) commssion to left-primary dual core.
    ...    2) check all cells on both cores, all should be on air
    ...    3) Check active aclarm and alarm history, no unexpected alarms raised.
    [Tags]  CRT_21A
    [Setup]  KW.CaseSetup
    [Teardown]  KW.CaseTeardown
    [Timeout]  90 minutes
    TC.5GC000829_K_002_Remote_Migration_from_single-core_to_dual-core_gNB_left_as_primary

[1] 5GC000829_K_005_Remote_Migration_Exception_when_extension_module_already_commissioned
    [Documentation]  Prerequisites:
    ...    1) left: signle-core on air.
    ...    2) Right: signle-core on air.
    ...    Test steps:
    ...    1) commssion to left-primary dual core.
    ...    2) check all cells on both cores, FID 4352 raised
    ...    3) Login secondary gNB-2 WebEM via Mplane, execute "Configuration Reset"
    ...    4) FID 23 raised on Secondary SMOD,install package via Primary Mplane
    ...    5) Dual-core gNB shall be onAir. Check active aclarm and alarm history, no unexpected alarms raised.
    [Tags]
    [Setup]  KW.CaseSetupForK005
    [Teardown]  KW.CaseTeardownForK005
    [Timeout]  150 minutes
    TC.5GC000829_K_005_Remote_Migration_Exception_when_extension_module_already_commissioned

[1] Inter_Core_Communication_Broken_And_Recovery
    [Tags]
    [Setup]  KW.CaseSetup_For_InterCoreBrokenAndRecovery
    [Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND    KW.CaseTeardown
    [Timeout]  150 minutes
    TC.Inter_Core_Communication_Broken_And_Recovery

[1]CB006615_Inter_Core_Communication_Broken_And_Recovery
    [Tags]    CRT_UTE
    [Setup]  KW.CaseSetup_For_InterCoreBrokenAndRecovery
    [Teardown]  KW.CaseTeardown
    [Timeout]  150 minutes
    TC.Inter_Core_Communication_Broken_And_Recovery

[1]CB00829_A_106_Secondary_core_Power_Reset
    [Documentation]  Prerequisites:
    ...    dual-core on air.
    ...    Test steps:
    ...    1) Trigger Secondary core power off.
    ...    2) Check fault 4352 after Secondary core power off.
    ...    3) Trigger Secondary core power on.
    ...    4) check all cells online and fault.
    [Tags]  CRT_TRUNK    CRT_UTE    101
    [Setup]  KW.CaseSetup
    [Teardown]  Run Keywords    Power.OnOff  pdu_ip=${PB_ASIK_IP}    Port_Number=${PB_ASIK_PORT}
                    ...         Action=power_on   model=${model}
                    ...         AND    KW.CaseTeardown
    [Timeout]  120 minutes
    TC.CB007310_A_106_Secondary_core_Power_Reset

[1]Secondary_Core_SW_Upgrade_via_WebEM
    [Tags]  MyTest
    [Setup]  KW.CaseSetup_For_SecondaryCoreSWUpgradeViaWebEM
    [Teardown]  KW.CaseTeardown_For_SecondaryCoreSWUpgradeViaWebEM
    [Timeout]  150 minutes
    TC.Secondary_Core_SW_Upgrade_via_WebEM

[1]Secondary_Core_SW_Upgrade_from_FDSW
    [Tags]  MyTest
    [Setup]  KW.CaseSetup
    [Teardown]  KW.CaseTeardown
    [Timeout]  150 minutes
    TC.Secondary_Core_SW_Upgrade_from_FDSW

*** Keywords ***
Setup Suite
    KW.829Setup Suite

Teardown Suite
    KW.SuiteTeardown
