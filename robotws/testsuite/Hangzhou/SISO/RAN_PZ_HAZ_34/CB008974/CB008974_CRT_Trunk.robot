*** Settings ***
Suite Setup          8712_SISO Suite Setup
Suite Teardown       SISO Suite Teardown_Trunk
Test Setup           SISO Test Setup
Test Teardown        SISO Test Teardown
Test Timeout         600 min

Resource      Resource/CB008974_old_siso_Resource.robot


Documentation
...    Author:Frank Luo
...    contact:frank.s.luo@nokia-sbell.com
...    squad group:SG_01
...    Feature CB005845 in 5G22R2 program

Force Tags            RAN_5G    RAN_5G_TDD    STATE_SW_UPLOADED  SBTS00
...    CLOUD_5G_CLASSICAL_QC_SA_ASILL_ABINB1_2xAEQE    PY36

##*** Variables ***

*** Test Cases ***
[1][2.0] General_SiSo_RU_module_reset_from_GUI
    [Tags]    CIT_TRUNK
    TC.12_General_SiSo_RF_module_reset_from_GUI_crt
#    TestCase.Stop

[1][1.1] General_SiSo_RF_alarms_without_recovery
    [Tags]    CIT_TRUNK
    AlarmWatchdog.add_allow_alarms    fault_id=1937
    AlarmWatchdog.add_allow_alarms    fault_id=1938
    TC.22_General_SiSo_RF_alarms_without_recovery
    AlarmWatchdog.remove_allow_alarms    fault_id=1937
    AlarmWatchdog.remove_allow_alarms    fault_id=1938
#     TestCase.Stop

[1][3.0] General_SiSo_Fault_1900_EFaultId_FrConfiguringFailed
    [Tags]    CIT_TRUNK
    AlarmWatchdog.add_allow_alarms    fault_id=1900
    TC.19_General_SiSo_Fault_1900_EFaultId_FrConfiguringFailed_PMAX
    AlarmWatchdog.remove_allow_alarms    fault_id=1900
#     TestCase.Stop

####NEW####
[1][2.0] Manual_SiSo_SM_NR_RAT_reset
    [Tags]    CRT_TRUNK    Peak_Tput
    [Timeout]
    CommonCase.Manual_SiSo_SM_NR_BBMOD_reset_crt
#     TestCase.Stop

#[1][2.1] General_SiSo_Cell_block_and_unblock
#    [Tags]    CRT_TRUNK   CRT_23R3  CRT_23R2  L3CALL   1CC
#    [Timeout]  60min
#    gNB.AppendTLCaseSCFDelta          InputFile=${LOG_PATH}/CB008974_Base_SCF.xml
#    ...                    OutputFile=${LOG_PATH}/CB008974_Cell_Block_SCF.xml
#    ...                    ParameterToDelete=CB008974_PARAMS_TO_DELETE_CELL_BLOCK
#    ...                    MOsToAdd=CB008974_ADD_MOS_BASE_CELL_BLOCK
#    ...                    ParamterToModify=CB008974_PARAMS_TO_MODIFY_BASE_CELL_BLOCK
#    ...                    ListParamterToModify=CB008974_LIST_PARAMS_TO_MODIFY_BASE_CELL_BLOCK
#    ...                    ListToAdd=CB008974_LIST_TO_ADD_BASE_CELL_BLOCK
#    log to console   ${LOG_PATH}/CB008974_Cell_Block_SCF.xml
#    TC.62_Manual_SiSo_SM_LTE Cell_block_unblock_crt   scf_file=${LOG_PATH}/CB008974_Cell_Block_SCF.xml
