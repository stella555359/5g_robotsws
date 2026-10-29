*** Setting ***
Force Tags        RAN_5G  RAN_5G_TDD   STATE_SW_UPLOADED  SBTS00  SBTS22R4  SBTS23R1
...    CLOUD_5G_CLASSICAL_FULLRACK_QC_SA_ASIBL_ABIOB1_AWHQN-ASIBR_ABINB4_AWHQX    PY36
Documentation         author: Shi Taotao
...                   contact: taotao.shi@nokia-sbell.com
...                   squard group: SG_01
...                   feature: CB007876
Suite Setup           Setup Suite
Suite Teardown        Teardown Suite
Resource              ../5GC000829/Resources/5GC000829-Resource.robot

*** Test Cases ***
[1]CB007876_A_004_Connections_to_dual-core_gNB
    [Documentation]    This case is to verify different kinds of connection to dual-core gNB,
    ...   note this case covers normal scenario,
    ...   abnormal cases such as inter-core communication down is out of the case (will be covered in exception cases).
    ...   WebEM connection via MPlane.
    ...   WebEM connection via Primary core LMP.
    ...   WebEM connection via Secondary core LMP.
    ...   SSH connection via MPlane.
    ...   SSH connection via Primary core LMP.
    ...   SSH connection via Secondary core LMP.
    ...   Note: after dual-core gNB is commissioned,
    ...   the LMP IP for primary core and secondary core would be different, one is 192.168.255.129, the other is 192.168.255.119.
    [Tags]    TA_Debug
    [Setup]  KW.CaseSetup
    [Teardown]  KW.CaseTeardown
    [Timeout]  60 minutes
    TC.ConnectionsToDualCoregNB

[1]CB007876_A_005_Sync_UI_in_dual-core_gNB
    [Documentation]   Verify WebEM supports synchronization status UI for primary core and secondary core separately in dual-core gNB.
    [Tags]    TA_Debug
    [Setup]  KW.CaseSetup
    [Teardown]  KW.CaseTeardown
    [Timeout]  30 minutes
    TC.Sync_UI_in_dual-core_gNB

[1]CB007876_A_006_HW_inventory_retrieval_in_dual-core_gNB
    [Documentation]  Verify HW management procedures for dual-core gNB are handled in the same way as single-core gNB
    [Tags]    TA_Debug
    [Setup]  KW.CaseSetup
    [Teardown]  KW.CaseTeardown
    [Timeout]  30 minutes
    TC.HWInventoryRetrievalInDualCore

[1]CB007876_A_106_Fault4385_when_Secondary_core_lost_Sync_from_Primary
    [Documentation]   This case is to verify when secondary core lost synchronization signal from primary core,
    ...               fault4385:  EFaultId_PpsRefFromBackplaneMissingAl shall be raised by secondary core
    [Tags]  TA_Debug
    [Setup]  KW.CaseSetup
    [Teardown]  KW.CaseTeardown
    [Timeout]  30 minutes
    TC.WhenSecondaryCoreLostSyncFromPrimaryFault4385Raise

[1]CB007876_A_008_Site_Reset_in_dual-core_gNB
    [Documentation]    Aim to verify site reset and BTS lock/unlock scenarios via webEM for dual-core gNB are handled
    ...               in the same way as single-core gNB.
    [Tags]     TA_Debug    CIT_TRUNK    CRT_22R1    CRT_22R2    CRT_22R3    CRT_22R4
    [Setup]  KW.CaseSetup
    [Teardown]  KW.CaseTeardown
    [Timeout]  60 minutes
    TC.SiteResetInDualCore

[1]CB007876_A_010_CM_Update_for_online-modify-type_NIDD_in_dual-core_gNB
    [Documentation]  Verify CM procedures for online modify-type NIDD parameter(s)
    ...    in dual-core gNB are handled in the same way as single-core gNB.
    [Tags]     TA_Debug
    [Setup]  KW.CaseSetupOf5GC000829_A_010
    [Teardown]  KW.CaseTeardownOf5GC000829_A_010
    [Timeout]  30 minutes
    TC.OnlineModifyTypeNIDDInDualCore

[1]CB007876_A_013_PM_without_Call_in_dual-core_gNB
    [Documentation]  Verify PM procedures for dual-core gNB are handled in the same way as single-core gNB,
    ...              the case just checks generic SMOD and Cell level measurements, it won't cover all measurements or detail counters.
    [Tags]    TA_Debug
    [Setup]  KW.CaseSetup
    [Teardown]  KW.CaseTeardown
    [Timeout]  30 minutes
    TC.PMWithoutCallInDualCore

[1]CB007876_A_016_FM_for_SMOD_in_dual-core_gNB
    [Documentation]  Verify FM procedures for dual-core gNB are handled in the same way as single-core gNB,
     ...             the case focus on SMOD alarming object and just select one or two alarm/fault for test
    [Tags]    TA_Debug   CRT_TRUNK    CRT_22R1    CRT_22R2    CRT_22R3    CRT_22R4
    [Setup]  KW.CaseSetup
    [Teardown]  KW.CaseTeardownOf5GC000829_A_016
    [Timeout]  30 minutes
    Conn.ConnectWithTimeout  alias=${ALIAS_ASIK}
    Conn.UploadFile    local_path=${CFGFILE_PATH}/swconfig.txt   remote_path=/ffs/run/swconfig.txt    alias=${ALIAS_ASIK}
    Conn.Execute    cmd=cd /ffs/run/ && crasign swconfig.txt && reboot   alias=${ALIAS_ASIK}
    Conn.Disconnect  alias=${ALIAS_ASIK}
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=both
    TC.FMForSmodInDualCore

[1]CB007876_A_009_Modules_Resets_in_dual-core_gNB
    [Documentation]  Verify moudles reset via WebEM for dual-core gNB are handled in the same way as single-core gNB
    [Tags]    TA_Debug
    [Setup]  KW.CaseSetup
    [Teardown]  KW.CaseTeardown
    [Timeout]  120 minutes
    TC.ResetMoudlesOfDualCore

[1]CB007876_A_018_Troubleshooting_Snapshot_in_dual-core_gNB
    [Documentation]  Main test Steps:
     ...             Step 1:Check cell on air.
     ...             Step 2:Login WebEM, collect snapshot.
     ...             Step 3:UnZip snapshot and check snapshot_file_list file include checkpoint.
    [Tags]  TA_Debug    CRT_TRUNK    CRT_22R1    CRT_22R2    CRT_22R3    CRT_22R4
    [Setup]  KW.CaseSetup
    [Teardown]  KW.CaseTeardownOf5GC000829_A_018
    [Timeout]  30 minutes
    TC.5GC000829_A_018_Troubleshooting_Snapshot_in_dual-core_gNB

[1]CB007876_A_019_Troubleshooting_BTSLog_in_dual-core_gNB
    [Documentation]  Main test Steps:
     ...             Step 1:Check cell on air.
     ...             Step 2:Collect syslogs from ute VM.
     ...             Step 3:Check syslogs include checkpoint.
    [Tags]  TA_Debug
    [Setup]  KW.CaseSetup
    [Teardown]  KW.CaseTeardown
    [Timeout]  30 minutes
    TC.5GC000829_A_019_Troubleshooting_BTSLog_in_dual-core_gNB

[1]CB007876_A_012_CM_Update_for_requiresBTSRestart-modify-type_NIDD_in_dual-core_gNB
    [Documentation]  Verify CM procedures for "BTS restart needed" modify-type NIDD parameter(s)
    ...    in dual-core gNB are handled in the same way as single-core gNB.
    [Tags]    TA_Debug
    [Setup]  KW.CaseSetup
    [Teardown]  KW.CaseTeardownOf5GC000829_A_012
    [Timeout]  60 minutes
    TC.RestartReuiredTypeNIDDUpdateInDualCore

[1]CB007876_A_017_FM_for_otherMOD_in_dual-core_gNB
    [Documentation]    Main test Steps:
    ...   1) ssh RU container
    ...   2) set rlan interface down to make the connection between system module and RU fail
    ...   3) Check fault 10 "No connection to unit" and otherMOD status
    ...   4) set rlan interface up to make the connection between system module and RU works again
    [Tags]    TA_Debug
    [Setup]    KW.CaseSetup
    [Teardown]    KW.CaseTeardown
    [Timeout]  60 minutes
    TC.5GC000829_A_017_FM_for_otherMOD_in_dual-core_gNB

[1]CB007876_A_021_SA_Call_on_PrimaryCore_in_dual-core_gNB
    [Documentation]   Verify SA call attach/detach on primary core cell(s) in dual-core BTS.
    [Tags]    TA_Debug    CRT_TRUNK    CRT_22R1    CRT_22R2    CRT_22R3    CRT_22R4
    [Setup]  KW.CaseSetup
    [Teardown]  KW.CaseTeardownOf5GC000829_A_021
    [Timeout]  60 minutes
    TC.L3callOnPrimaryCore

[2][1.0] 5GC000829_A_022_SA_Call_on_SecondaryCore_in_dual-core_gNB
    [Documentation]   Verify SA call attach/detach on secondary core cell(s) in dual-core BTS.
    [Tags]
    [Setup]  KW.CaseSetup
    [Teardown]  KW.CaseTeardownOf5GC000829_A_022
    [Timeout]  60 minutes
    TC.5GC000829_A_022_L3callOnSecondaryCore

[1]CB007876_A_033_Recommission_to_dual-core_gNB
    [Documentation]   Verify backplane connection can setup between primary core and secondary core, all HW can be detected
    ...               and visible in WebEM when two cores are in uncomissioned state.
    [Tags]    TA_Debug
    [Setup]  KW.CaseSetup
    [Teardown]  KW.CaseTeardown
    [Timeout]  60 minutes
    TC.ModuleDetectInUncommissionState

[1]CB007876_A_034_Recommisssion_to_two_single-core_gNB
    [Documentation]  Verify configuration reset and recommission procedures for dual-core gNB are handled in the same way as single-core gNB.
    [Tags]    TA_Debug
    [Setup]  KW.CaseSetup
    [Teardown]  KW.CaseTeardown
    [Timeout]  60 minutes
    TC.RecommissionFromDualCoreToSingleCore

[1]CB007876_A_5GC000829_K_002_Remote_Migration_from_single-core_to_dual-core_gNB_left_as_primary
    [Documentation]  Prerequisites:
    ...    1) left: signle-core on air.
    ...    2) Right: uncommissioned.
    ...    Test steps:
    ...    1) commssion to left-primary dual core.
    ...    2) check all cells on both cores, all should be on air
    ...    3) Check active aclarm and alarm history, no unexpected alarms raised.
    [Tags]    TA_Debug   CIT_TRUNK    CRT_22R1    CRT_22R2    CRT_22R3    CRT_22R4    CRT_23R2
    [Setup]  KW.CaseSetup
    [Teardown]  KW.CaseTeardown
    #[Timeout]  60 minutes
    TC.5GC000829_K_002_Remote_Migration_from_single-core_to_dual-core_gNB_left_as_primary

[1]CB006615_Remote_Migration_from_single-core_to_dual-core_gNB_left_as_primary
    [Tags]   CRT_UTE
    [Setup]  KW.CaseSetup
    [Teardown]  KW.CaseTeardown
    #[Timeout]  60 minutes
    TC.5GC000829_K_002_Remote_Migration_from_single-core_to_dual-core_gNB_left_as_primary

[1]CB007876_A_5GC000829_K_005_Remote_Migration_Exception_when_extension_module_already_commissioned
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

*** Keywords ***
Setup Suite
    KW.SuiteSetup
    set suite variable   ${OAM_TYPE}    COAM
    #set suite variable   ${RIGHT_UTE_IP}   ${CASE_INPUT_5GC000829['RIGHT_UTE_IP']}
    #set suite variable   ${IS_COmmon_Build}   ${CASE_INPUT_5GC000829['isCommonbuild']}
    gNB.FormatBTSID

    ${version}    Set variable        ${AF_PATH}
    run keyword if    ${version.count('SBTS')}>${0}    set suite variable    ${IS_COmmon_Build}    true
    ...    ELSE    set suite variable    ${IS_COmmon_Build}    false

    run keyword if    '${IS_COmmon_Build}'=='true'
    ...    Set Suite Variable    ${alarm_object}    Configuration alarming object
    ...    ELSE    Set Suite Variable    ${alarm_object}    Alarming object
    set suite variable    ${dist_name}   ${MRBTS_ID}/${NRBTS_ID}
#    run keyword if    '${testline_name}'=='7_5_UTE5G402T205' or '${testline_name}'=='7_5_UTE5G402T1112'
#	...     Set Suite Variable    ${Dula_core_base_scf}    ${CFGFILE_PATH}TestLineSCF1Cell_Both_dual.xml
#	...     ELSE    Set Suite Variable    ${Dula_core_base_scf}    ${LOG_PATH}/TestLineSCF2Cell_Both.xml
    Run Keyword And Ignore Error     gNB.GenerateTestLineSCFs
    Set Suite Variable    ${Dula_core_base_scf}      ${LOG_PATH}/TestLineSCF${TLSCF_CELL_NUMs[-1]}Cell.xml

Teardown Suite
    KW.SuiteTeardown
