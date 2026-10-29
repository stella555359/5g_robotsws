*** Setting ***
Force Tags    PY36
Documentation         author: Zhang Wenjin
...                           Luo Frank
...                           Cai Wenjuan
...                           Li Yajie
...                           Gao Ge
...                   contact: wenjin.zhang@nokia-sbell.com
...                   squard group: SG_01
...                   feature: CB007310
Suite Setup           Setup Suite
Suite Teardown        Teardown Suite
#Force Tags            QCD_MN_5G    QCP_5G   SG_01
Resource              ../5GC000829/Resources/5GC000829-Resource.robot

*** Test Cases ***
TEST
    TC.SecondaryCoreRecovery
#[1] CB007310_A_005_Sync_UI_in_dual-core_gNB
#    [Documentation]   Verify WebEM supports synchronization status UI for primary core and secondary core separately in dual-core gNB.
#    [Tags]  CRT_21A    CRT_21B
#    [Setup]  KW.CaseSetup
#    [Teardown]  KW.CaseTeardown
#    [Timeout]  30 minutes
#    TC.Sync_UI_in_dual-core_gNB

[1] CB007310_A_006_HW_inventory_retrieval_in_dual-core_gNB
    [Documentation]  Verify HW management procedures for dual-core gNB are handled in the same way as single-core gNB
    [Tags]  CRT_21A    CRT_21B      CRT_22R1     CRT_22R2
    [Setup]  KW.CaseSetup
    [Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND   KW.CaseTeardown
    [Timeout]  30 minutes
    TC.HWInventoryRetrievalInDualCore

[1] CB007310_A_009_Modules_Resets_in_dual-core_gNB
    [Documentation]  Verify moudles reset via WebEM for dual-core gNB are handled in the same way as single-core gNB
    [Tags]  CRT_21A    CRT_TRUNK    CRT_21B      CRT_22R1    CRT_22R4    CRT_22R3
    [Setup]  KW.CaseSetup
    [Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND   KW.CaseTeardown
    [Timeout]  120 minutes
    TC.ResetMoudlesOfDualCore

[1][1.0] CB006615_A_009_Modules_Resets_in_dual-core_gNB
    [Tags]  CRT_UTE
    [Setup]  KW.CaseSetup
    [Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND   KW.CaseTeardown
    [Timeout]  120 minutes
    TC.ResetMoudlesOfDualCore
#[1] CB007310_A_010_CM_Update_for_online-modify-type_NIDD_in_dual-core_gNB
#    [Documentation]  Verify CM procedures for online modify-type NIDD parameter(s)
#    ...    in dual-core gNB are handled in the same way as single-core gNB.
#    [Tags]  CRT_21A    CRT_21B
#    [Setup]  KW.CaseSetupOf5GC000829_A_010
#    [Teardown]  KW.CaseTeardownOf5GC000829_A_010
#    [Timeout]  30 minutes
#    TC.OnlineModifyTypeNIDDInDualCore
#
#[1] CB007310_A_013_PM_without_Call_in_dual-core_gNB
#    [Documentation]  Verify PM procedures for dual-core gNB are handled in the same way as single-core gNB,
#    ...              the case just checks generic SMOD and Cell level measurements, it won't cover all measurements or detail counters.
#    [Tags]  CRT_21A    CRT_21B
#    [Setup]  KW.CaseSetup
#    [Teardown]  KW.CaseTeardown
#    [Timeout]  30 minutes
#    TC.PMWithoutCallInDualCore
#
#[1] CB007310_A_016_FM_for_SMOD_in_dual-core_gNB
#    [Documentation]  Verify FM procedures for dual-core gNB are handled in the same way as single-core gNB,
#     ...             the case focus on SMOD alarming object and just select one or two alarm/fault for test
#    [Tags]  CRT_21A    CRT_21B
#    [Setup]  KW.CaseSetup
#    [Teardown]  KW.CaseTeardownOf5GC000829_A_016
#    [Timeout]  30 minutes
#    TC.FMForSmodInDualCore
#
#[1] CB007310_A_022_SA_Call_on_SecondaryCore_in_dual-core_gNB
#    [Documentation]   Verify SA call attach/detach on secondary core cell(s) in dual-core BTS.
#    [Tags]  CRT_21B
#    [Setup]  KW.CaseSetup
#    [Teardown]  KW.CaseTeardownOf5GC000829_A_022
#    [Timeout]  60 minutes
#    TC.5GC000829_A_022_L3callOnSecondaryCore


#[1] 5GC0007310_A_021_SA_Call_on_PrimaryCore_in_dual-core_gNB
#    [Documentation]   Verify SA call attach/detach on primary core cell(s) in dual-core BTS.
#    [Tags]   None
#    [Setup]  KW.CaseSetup
#    [Teardown]  KW.CaseTeardownOf5GC000829_A_021
#    [Timeout]  60 minutes
#    TC.L3callOnPrimaryCore

#[1] CB007310_A_101_Secondary_core_failure_escalate_to_Site_Reset
#    [Documentation]  This case is to verify secondary core failure will escalate to site reset.
#    [Tags]  CRT_21B
#    [Setup]  KW.CaseSetup
#    [Teardown]  KW.CaseTeardown
#    [Timeout]  30 minutes
#    TC.CB007310_A_101_Secondary_core_failure_escalate_to_Site_Reset
[1]CB007310_A_201_Software_download_reject
    [Documentation]  Missing TargetDB file in SW package,SW download unsuccessfully due to get failed result from BTS.
    [Tags]  CRT_BOAM    CRT_TRUNK
    [Setup]  KW.CaseSetup
    [Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND  KW.CaseTeardown
    [Timeout]  60 minutes
    TC.CB007310_A_201_Software_download_reject

[1]CB007310_A_202_Stop_software_download
    [Documentation]  SW package download has been cancelled during the software update procedure.
    [Tags]  CRT_BOAM    CRT_TRUNK
    [Setup]  KW.CaseSetup
    [Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND   KW.CaseTeardown
    [Timeout]  60 minutes
    TC.CB007310_A_202_Stop_software_download

[1]CB007310_D_5GC000829_K_002_Remote_Migration_from_single-core_to_dual-core_gNB_left_as_primary
    [Documentation]  Prerequisites:
    ...    1) left: signle-core on air.
    ...    2) Right: uncommissioned.
    ...    Test steps:
    ...    1) commssion to left-primary dual core.
    ...    2) check all cells on both cores, all should be on air
    ...    3) Check active aclarm and alarm history, no unexpected alarms raised.
    [Tags]  CRT_21B    CRT_TRUNK        CRT_22R1      CRT_22R4    CRT_22R3
    [Setup]  KW.CaseSetup
    [Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND    KW.CaseTeardown
    [Timeout]  60 minutes
    TC.5GC000829_K_002_Remote_Migration_from_single-core_to_dual-core_gNB_left_as_primary

[1]CB007310_A_101_Secondary_core_failure_escalate_to_Site_Reset
    [Documentation]  Prerequisites:
    ...    dual-core on air.
    ...    Test steps:
    ...    1) Trigger primary core SW fallback to previous passive SW version.
    ...    2) Check fault management handling after primary core fallback completed.
    ...    3) Manual SW update secondary core with the version same as running on primary core via WebEM.
    ...    4) Recover test environment by manual SW update dual-core gNB to other SW version.
    [Tags]  CRT_TRUNK    CRT_UTE    101
    [Setup]  KW.CaseSetup
    [Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND    KW.CaseTeardown
    [Timeout]  120 minutes
    TC.CB007310_A_101_Secondary_core_failure_escalate_to_Site_Reset

[1]CB006615_A_101_Secondary_core_failure_escalate_to_Site_Reset
    [Tags]  CRT_UTE
    [Setup]  KW.CaseSetup
    [Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND   KW.CaseTeardown
    [Timeout]  120 minutes
    TC.CB007310_A_101_Secondary_core_failure_escalate_to_Site_Reset

[1]CB007876_A_104_SWM_Secondary_core_SW_fallback
    [Documentation]  Prerequisites:
    ...    dual-core on air.
    ...    Test steps:
    ...    1) Trigger primary core SW fallback to previous passive SW version.
    ...    2) Check fault management handling after primary core fallback completed.
    ...    3) Manual SW update secondary core with the version same as running on primary core via WebEM.
    ...    4) Recover test environment by manual SW update dual-core gNB to other SW version.
    [Tags]  CRT_TRUNK    CRT_UTE    104    105
    [Setup]  KW.CaseSetup
    [Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND   KW.CaseTeardown
    [Timeout]  210 minutes
    TC.CB007310_A_104_SWM_Secondary_core_SW_fallback

[1]CB007876_A_103_SWM_Primary_core_SW_fallback
    [Documentation]  Prerequisites:
    ...    dual-core on air.
    ...    Test steps:
    ...    1) Trigger primary core SW fallback to previous passive SW version.
    ...    2) Check fault management handling after primary core fallback completed.
    ...    3) Manual SW update secondary core with the version same as running on primary core via WebEM.
    ...    4) Recover test environment by manual SW update dual-core gNB to other SW version.
    [Tags]  CRT_TRUNK    CRT_UTE    103   105
    [Setup]  KW.CaseSetup
    [Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND   KW.CaseTeardown
    [Timeout]  210 minutes
    TC.5GC000829_A_103_SWM_Primary_core_SW_fallback

[1]CB007876_A_105_SWM_SW_fallback
    [Documentation]  Prerequisites:
    ...    dual-core on air.
    ...    Test steps:
    ...    1) Trigger primary core SW fallback to previous passive SW version.
    ...    2) Check fault management handling after primary core fallback completed.
    ...    3) Manual SW update secondary core with the version same as running on primary core via WebEM.
    ...    4) Recover test environment by manual SW update dual-core gNB to other SW version.
    [Tags]  CRT_TRUNK    CRT_UTE    105
    [Setup]  KW.CaseSetup
    [Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND    KW.CaseTeardown
    [Timeout]  120 minutes
    TC.CB007310_A_105

[1]CB007310_A_106_Secondary_core_Power_Reset
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
                    ...         Action=power_on   model=${tl.gnbs[0].dus[0].airscale.common_units[1].pdu_port.pdu.vendor}
                    ...         AND   robot_common_operations.Common Case Teardown    AND    KW.CaseTeardown
    [Timeout]  120 minutes
    TC.CB007310_A_106_Secondary_core_Power_Reset

[1]CB006615_A_106_Secondary_core_Power_Reset
    [Tags]  CRT_UTE
    [Setup]  KW.CaseSetup
    [Teardown]  Run Keywords    Power.OnOff  pdu_ip=${PB_ASIK_IP}    Port_Number=${PB_ASIK_PORT}
                    ...         Action=power_on   model=${tl.gnbs[0].dus[0].airscale.common_units[1].pdu_port.pdu.vendor}
                    ...         AND    KW.CaseTeardown
    [Timeout]  120 minutes
    TC.CB007310_A_106_Secondary_core_Power_Reset

*** Keywords ***
Setup Suite
    KW.SuiteSetup
#    set suite variable   ${IS_COmmon_Build}       ${CASE_INPUT_5GC000829["isCommonbuild"]}
    set suite variable   ${OAM_TYPE}    COAM
#    set suite variable   ${RIGHT_UTE_IP}   ${CASE_INPUT_5GC000829['RIGHT_UTE_IP']}
    gNB.FormatBTSID

    ${version}    Set variable        ${AF_PATH}
    run keyword if    ${version.count('SBTS')}>${0}    set suite variable    ${IS_COmmon_Build}    true
    ...    ELSE    set suite variable    ${IS_COmmon_Build}    false

    run keyword if    '${IS_COmmon_Build}'=='true'
    ...    Set Suite Variable    ${alarm_object}    Configuration alarming object
    ...    ELSE    Set Suite Variable    ${alarm_object}    Alarming object

    set suite variable    ${dist_name}   ${MRBTS_ID}/${NRBTS_ID}

#    ${info}     Basic.GetStreamInfo     vstring=${AF_PATH}
#    ${StreamInfo}    convert to string    ${info}
    Basic.CheckVariableValid   var=TLCommonConfig["MultiUECFG"]["0"]["detach_request"]    default_value=${true}
    Basic.CheckVariableValid   var=TLCommonConfig["MultiUECFG"]["0"]["power_reset"]        default_value=true
    ${res}    Run Keyword And Ignore error    gNB.GenerateTestLineSCFs
#	${res}    Run Keyword And Ignore error    gNB.Generate TL SCF
#	...                  GoldenSCF_PATH=${GoldenSCF_ON_GIT}/${info['GoldenSCF']}    TLDelta_PATH=${CFGFILE_PATH}/TLDelta_${info['StreamPrefix']}.py
#	...                  TestLineSCF_cell_num=${2}    cell_type=Both
#	...                  MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}

	Set Suite Variable    ${Dula_core_base_scf}    ${LOG_PATH}/TestLineSCF2Cell.xml

    run keyword if    '${res[0]}'=='PASS'
    ...      gNB.Commission   scf_file=${LOG_PATH}/TestLineSCF2Cell.xml
    Wait until keyword succeeds   15min   2min    COAM_VerifyOnAirViaFrontendAndBackend
    wait until keyword succeeds    20min    10s    COAM_Admin.CheckAllCellsOnair    type=both

Teardown Suite
    KW.SuiteTeardown
