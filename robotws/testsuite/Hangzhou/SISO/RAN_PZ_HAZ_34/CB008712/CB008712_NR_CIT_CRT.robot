*** Settings ***
Suite Setup           Run Keywords    robot_common_operations.Common Suite Setup  AND  SISO 8712_NR Suite Setup
Suite Teardown        Run Keywords    robot_common_operations.Common Suite Teardown  AND  SISO 8712_NR Suite Teardown
Test Timeout         600 min

Documentation
...    Author:Frank Luo
...    contact:frank.s.luo@nokia-sbell.com
...    squad group:SG_01
...    Feature CB008445 in 5G22R4 program

Force Tags            5G_RAN    5G_RAN_TDD    STATE_SW_UPLOADED  SBTS00  CLOUD_5G_CLASSICAL_SA_ASIML_ABINB1_ABIQB2B3_AWHNA_3xAWHQ_AWPTD

Resource  Resource/CB008712_Resource.robot

*** Test Cases ***
[1]CB008712_NR_Verify_the switch between non-contiguous and contiguous CA_with_channelSpacing_Update_grantId_change
    [Documentation]   No L3Call
    [Tags]   Trunk_CRT    New_add
    [Timeout]
    [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    SetUp NR_Case
    [Teardown]    Run Keywords    Teardown NR_Case  AND  robot_common_operations.Common Case Teardown
    CommonCase062.NR_Verify_the switch between non-contiguous and contiguous CA_with_channelSpacing_Update_grantId_change
    ...   BaseSCF2CC=${CFGFILE_PATH}/${TL_BASE_SCF_NR_2CC_40MHz_100MHz_spacing0}

###NR_2CC
[1]General_SiSo_Commissioning_BTS_Template_Commissioning_2CC_40MHz+100MHz
    [Documentation]   No L3Call
    [Tags]   Trunk_CIT    23R2_CRT
    [Timeout]
    [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    SetUp NR_Case
    [Teardown]    Run Keywords    Teardown NR_Case  AND  robot_common_operations.Common Case Teardown
    COAM_Admin.commission  scf_file=${CFGFILE_PATH}/${TL_BASE_SCF_NR_2CC_40MHz_100MHz}
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=nr
    CommonCase053.General_SiSo_Commissioning_BTS_Template_Commissioning

[1][1.0] General_SiSo_RF_alarms_without_recovery
    [Documentation]   No L3Call
    [Tags]   Trunk_CIT    23R2_CRT
    [Timeout]
    [Setup]    Run Keywords    robot_common_operations.Common Case Setup    allowed_faults_ids=6830,6828,6833,6823,6829,6831,6827
    ...                        AND    SetUp NR_Case
    [Teardown]    Run Keywords    Teardown NR_Case  AND  robot_common_operations.Common Case Teardown
    AlarmWatchdog.add_allow_alarms    fault_id=4752
    AlarmWatchdog.add_allow_alarms    fault_id=1937
    AlarmWatchdog.add_allow_alarms    fault_id=1938
    AlarmWatchdog.add_allow_alarms    fault_id=1901
    AlarmWatchdog.add_allow_alarms    fault_id=6826
    COAM_Admin.commission  scf_file=${CFGFILE_PATH}/${TL_BASE_SCF_NR_2CC_40MHz_100MHz}
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=nr
    CommonCase023.General_SiSo_RF_alarms_without_recovery
    AlarmWatchdog.remove_allow_alarms    fault_id=4752
    AlarmWatchdog.remove_allow_alarms    fault_id=1937
    AlarmWatchdog.remove_allow_alarms    fault_id=1938
    AlarmWatchdog.remove_allow_alarms    fault_id=1901
    AlarmWatchdog.remove_allow_alarms    fault_id=6826

[1][2.1] General_SiSo_RF_alarms_with_recovery
    [Documentation]   No L3Call
    [Tags]   Trunk_CIT    23R2_CRT
    [Timeout]
    [Setup]    Run Keywords    robot_common_operations.Common Case Setup    allowed_faults_ids=6830,6828,6833,6823,6829,6831,6827
    ...                        AND    SetUp NR_Case
    [Teardown]    Teardown NR_Case
    AlarmWatchdog.add_allow_alarms    fault_id=4752
    AlarmWatchdog.add_allow_alarms    fault_id=1937
    AlarmWatchdog.add_allow_alarms    fault_id=1938
    AlarmWatchdog.add_allow_alarms    fault_id=1901
    AlarmWatchdog.add_allow_alarms    fault_id=6826
    COAM_Admin.commission  scf_file=${CFGFILE_PATH}/${TL_BASE_SCF_NR_2CC_40MHz_100MHz}
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=nr
    COAM_Admin.BackupSCF    file_name=BackUP_${TL_BASE_SCF_NR_2CC_40MHz_100MHz}
    CommonCase022.General_SiSo_RF_alarms_with_recovery
    AlarmWatchdog.remove_allow_alarms    fault_id=4752
    AlarmWatchdog.remove_allow_alarms    fault_id=1937
    AlarmWatchdog.remove_allow_alarms    fault_id=1938
    AlarmWatchdog.remove_allow_alarms    fault_id=1901
    AlarmWatchdog.remove_allow_alarms    fault_id=6826

[1][2.0] General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
    [Documentation]   No L3Call
    [Tags]
    [Timeout]
    [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    SetUp NR_Case
    [Teardown]    Run Keywords    Teardown NR_Case  AND  robot_common_operations.Common Case Teardown
    COAM_Admin.commission  scf_file=${CFGFILE_PATH}/${TL_BASE_SCF_NR_2CC_40MHz_100MHz}
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=nr
    CommonCase060.General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot

[1][2.0] General_SiSo_Cell_block_and_unblock
    [Documentation]   Do L3Call, UE attach cell1
    [Tags]   Trunk_CRT    23R2_CRT
    [Timeout]
    [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    SetUp NR_Case
    [Teardown]    Run Keywords    Teardown NR_Case  AND  robot_common_operations.Common Case Teardown
    COAM_Admin.commission  scf_file=${CFGFILE_PATH}/${TL_BASE_SCF_NR_2CC_40MHz_100MHz}
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=nr
    CommonCase008.Manual_SiSo_SM_LTE_Cell_block_unblock

[1]General_SiSo_E2E_system_setup_with_data_transfer_conducted_2CC_20MHz+40MHz
    [Documentation]    Do L3Call, UE attach cell1
    [Tags]    Trunk_CRT    23R2_CRT
    [Timeout]  60min
    [Setup]    Run Keywords    robot_common_operations.Common Case Setup
        ...                        allowed_faults_ids=6823,6824,6825,6826,6827,6828,6829,6830,6831,6832,6833
        ...                        AND    SetUp NR_Case
    [Teardown]    Run Keywords    Teardown NR_Case
    COAM_Admin.commission  scf_file=${CFGFILE_PATH}/${TL_BASE_SCF_NR_2CC_20MHz_40MHz}
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=nr
    COAM_Admin.BackupSCF    file_name=BackUP_${TL_BASE_SCF_NR_2CC_20MHz_40MHz}
    MultiUE.L3Call    UECFG=${TLCommonConfig_8712['MultiUECFG']}

[1]General_SiSo_RU_module_reset_from_GUI
    [Documentation]   Do L3Call, UE attach cell2
    [Tags]   Trunk_CRT    23R2_CRT
    [Timeout]
    [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    SetUp NR_Case
    [Teardown]    Run Keywords    Teardown NR_Case  AND  robot_common_operations.Common Case Teardown
    COAM_Admin.commission  scf_file=${CFGFILE_PATH}/${TL_BASE_SCF_NR_2CC_20MHz_40MHz_Cell2}
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=nr
    CommonCase005.General_SiSo_RU_module_reset_from_GUI

[1]CB008712_NR_check_maxEirp_limitation_with_desiredPmax_and_maxGrantPwrRed
    [Documentation]    This case has 3 aims:
     ...    1: the CBSD Cell startup status when pMax exceeds lower limit of HW limitation
     ...    2: the CBSD Cell startup status when pMax exceeds upper limit of HW limitation
     ...    3: the CBSD Cell can’t startup normally when calculated maxEirp is out of FCC limitation
     ...    Note1: the power of AWPQY/AWPQZ limitation is 6dBm~24dBm.
     ...    Note2: AWPQY/AWPQZ is category A CBSD, FCC limitation is -137 ~ 20 dBm/MHz
     ...    Case Steps:
     ...      Precondition: BTS is onair with cell1_20MHz and cell2_20MHz,
     ...                    supportedSpectrumV2 set 3550-3570 and 3680-3700,
     ...                    desiredPmax = 20dBm, antennaGain = 0dBi, maxGrantPwrRed = 0dB
     ...    Step1: change desiredPmax = 5dBm of cell1 and cells, active SCF
     ...      checkpoint: pMax exceeds lower limit of HW limitation,
     ...                  fault 6828 will raise, cell1 and cell2 state are disable
     ...    Step2: change desiredPmax = 25dBm of cell1 and cells, active SCF
     ...      checkpoint: pMax exceeds upper limit of HW limitation,
     ...                  fault 6828 will raise, cell1 and cell2 state are disable
     ...    Step3: change desiredPmax = 20dBm, antennaGain = 8dBi, active SCF
     ...      checkpoint: calculated maxEirp is out of FCC limitation,
     ...                  fault 6828 will raise, cell1 and cell2 state are disable
     ...    Step4: change maxGrantPwrRed = 5dB of cell1 and cells, active SCF
     ...      checkpoint: pMax not exceeds HW limitation and calculated maxEirp not exceeds FCC limitation,
     ...                  fault 6828 will be cleared, cell1 and cell2 state are enable, pMax of cell1 and cells is 18.9dBm
    [Tags]    Trunk_CRT    23R2_CRT
    [Timeout]  60min
    [Setup]    Run Keywords    robot_common_operations.Common Case Setup
        ...                        allowed_faults_ids=6823,6824,6825,6826,6827,6828,6829,6830,6831,6832,6833
        ...                        AND    SetUp NR_Case
    [Teardown]    Teardown NR_Case
    log to console    Precondition: BTS is onair with cell1_20MHz and cell2_20MHz
    COAM_Admin.commission  scf_file=${CFGFILE_PATH}/${TL_BASE_SCF_NR_2CC_20MHz_20MHz}
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=nr
    COAM_Admin.BackupSCF    file_name=BackUP_${TL_BASE_SCF_NR_2CC_20MHz_20MHz}
    CBRSCase01.NR_check_maxEirp_limitation_with_desiredPmax_and_maxGrantPwrRed

[1][3.0] General_SiSo_Online_Cell_Addition_Deletion
    [Documentation]   Do L3Call
    [Tags]    Trunk_CRT    New_add
    [Timeout]  60min
    [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    SetUp NR_Case
    [Teardown]    Run Keywords    Teardown NR_Case  AND  robot_common_operations.Common Case Teardown
    COAM_Admin.commission  scf_file=${CFGFILE_PATH}/${TL_BASE_SCF_NR_2CC_40MHz_40MHz}
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=nr
    COAM_Admin.BackupSCF    file_name=BackUP_${TL_BASE_SCF_NR_2CC_40MHz_40MHz}
    KW.General_SiSo_Online_Cell_addition_deletion_CBRS_NR

###NR_1CC
[1]General_SiSo_Commissioning_BTS_Template_Commissioning_1CC_20MHz
    [Documentation]    No L3Call
    [Tags]    Trunk_CIT    23R2_CRT
    [Timeout]  60min
    [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    SetUp NR_Case
    [Teardown]    Run Keywords    Teardown NR_Case  AND  robot_common_operations.Common Case Teardown
    COAM_Admin.commission  scf_file=${CFGFILE_PATH}/${TL_BASE_SCF}
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=nr
    COAM_Admin.BackupSCF    file_name=BackUP_${TL_BASE_SCF}
    CommonCase053.General_SiSo_Commissioning_BTS_Template_Commissioning

[1][1.0] General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module
    [Documentation]   No L3Call
    [Tags]    Trunk_CIT    23R2_CRT
    [Timeout]
    [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    SetUp NR_Case
    [Teardown]    Run Keywords    Teardown NR_Case  AND  robot_common_operations.Common Case Teardown
    COAM_Admin.commission  scf_file=${CFGFILE_PATH}/${TL_BASE_SCF}
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=nr
    CommonCase014.General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module

[1]General_SiSo_E2E_system_setup_with_data_transfer_conducted_20MHz
    [Documentation]    Do L3Call
    [Tags]    Trunk_CRT    23R2_CRT
    [Timeout]  60min
    [Setup]    Run Keywords    robot_common_operations.Common Case Setup
        ...                        allowed_faults_ids=6823,6824,6825,6826,6827,6828,6829,6830,6831,6832,6833
        ...                        AND    SetUp NR_Case
    [Teardown]    Teardown NR_Case
    COAM_Admin.commission  scf_file=${CFGFILE_PATH}/${TL_BASE_SCF_NR_8712}
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=nr
    MultiUE.L3Call    UECFG=${TLCommonConfig_8712['MultiUECFG']}

[1][1.0] Manual_SiSo_SM_BTS_Site_Reset
    [Documentation]    Do L3Call
    [Tags]    Trunk_CRT    23R2_CRT
    [Timeout]  60min
    [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    SetUp NR_Case
    [Teardown]    Run Keywords    Teardown NR_Case  AND  robot_common_operations.Common Case Teardown
    COAM_Admin.commission  scf_file=${CFGFILE_PATH}/${TL_BASE_SCF}
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=nr
    CommonCase002.Manual_SiSo_SM_BTS_Site_Reset

[1]CB008712_SR_D_02_attach_prachConfig_A2_40MHz
    [Documentation]    Do L3Call
    ...    New framestructure:DL-6,UL-4
    [Tags]    Trunk_CRT    23R2_CRT
    [Timeout]  60min
    [Setup]    Run Keywords    robot_common_operations.Common Case Setup
        ...                        allowed_faults_ids=6823,6824,6825,6826,6827,6828,6829,6830,6831,6832,6833
        ...                        AND    SetUp NR_Case
    [Teardown]    Teardown NR_Case
    COAM_Admin.commission  scf_file=${CFGFILE_PATH}/${TL_BASE_SCF_NR_9218_A2_40MHz}
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=nr
    COAM_Admin.BackupSCF    file_name=BackUP_${TL_BASE_SCF_NR_9218_A2_40MHz}
    CommonCase002.Manual_SiSo_SM_BTS_Site_Reset

*** Keywords ***
SISO 8712_NR Suite Setup
    UTECloud.ForceAdaptCommissionFiles
    TestSuite.Start
    set suite variable      ${SAVE LOG DIRECTORY}    ${LOG_PATH}
    set suite variable      ${UPDATE_FILE_PATH}      ${LOG_PATH}
    set suite variable      ${SUITE_LOG_PATH}        ${LOG_PATH}
    set suite variable      ${CASE_LOG_PATH}         ${LOG_PATH}

#    ${StreamTarget}      ${version_Target}      Basic.GetStreamAndVersion
#    set suite variable    ${TARGETSW}    ${version_Target}
#    set suite variable    ${TargetStream}     ${StreamTarget}
#    set suite variable    ${OldCommissionSCF}    ${CFGFILE_PATH}/${TL_BASE_SCF}
    COAM_WebEM.Login
    ${version}    wait until keyword succeeds    2min    15s    selenium_coam.check_current_software_version
    ${Active_SW_version}    string.split string    string=${version}[Active]
    set suite variable    ${Active_SW_version}
    ${SW1}    string.split string    string=${version}[Active]    separator=_
    ${Active_SwVersion111}     convert to string    ${SW1}[-5]
    set suite variable    ${Active_SwVersion111}
    COAM_WebEM.Logout
    ${is_lte}    set variable if  "${CASE_INPUT_SISO["SISOCommon"]["cell_type"]}"=="lte"    true    false
    ${TL_BASE_SCF}    set variable if    "${is_lte}"=="true"    ${TL_BASE_SCF_LTE}    ${TL_BASE_SCF_NR}
    ${TL_BASE_SCF}    set suite variable    ${TL_BASE_SCF}
    gNB.FormatBTSID    lte=${is_lte}
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl

SetUp NR_Case
    Run Keyword And Ignore error    KW.RestartSAS_UTE
    Run Keyword And Ignore error   BtsLog.StartBTSlogCollection
    Run Keyword And Ignore error    MultiUE.PrepareUE    UECFG=${TLCommonConfig_8712['MultiUECFG']}

Teardown NR_Case
    robot_common_operations.Common Case Teardown
    Run Keyword And Ignore error    BtsLog.StopBTSlogCollectionandGetlog
    Run Keyword And Ignore error    KW.GetSASLog_UTE
    Run Keyword If  '${TEST STATUS}' == 'FAIL'    Run Keyword And Ignore error    gNB.CollectSnapshot
    ...    ELSE    Run Keyword And Ignore error    gNB.CollectIMS2
    Run Keyword And Ignore Error    CI_interface.Common Case Teardown

SISO 8712_NR Suite Teardown
    COAM_Admin.commission  scf_file=${CFGFILE_PATH}/${Active_SwVersion111}_SCF_SBTS00_NRFinal.xml
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=nr
