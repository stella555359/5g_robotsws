*** Settings ***
Documentation     author: Zhang Lusha
...               contact: lusha.zhang@nokia-sbell.com
...               squad group: MN_RAN_RD_VRF_HAZ3_02
...               feature: CB010578-E US#9 config E1
Suite Setup       SISO Coam Suite Setup With Specify SCF    scf_suffix=_E1
Suite Teardown    Run Keyword And Ignore Error     SISO Coam Suite Teardown

Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB010578-E/Resource/CB010578_resource.robot
Force Tags    5G_RAN    5G_RAN_TDD    RAN_5G    RAN_5G_TDD    SBTS00      STATE_SW_UPLOADED

*** Variables ***
${base_path}    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G
${TS_CASE_LOG_PATH}    /home/ute
# ${if_commissioning}   False
# ${save_snapshot}   False
${ultp}    50
${dltp}    300
${ue_type}    ${tl.ues[0].capabilities[1]}

*** Test Cases ***
[4][2.0] General_SiSo_Commissioning_BTS_Template_Commissioning
    [Tags]    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    General_SiSo_Commissioning_BTS_Template_Commissioning
    [Teardown]    SISO Coam Test Teardown

[2][2.0] Manual_SiSo_SM_BTS_Site_Reset
    [Setup]    SISO Coam Test Setup
    General_SiSo_Auto_BTS_site_reset
    #UES attach and detach check
    [Teardown]    SISO Coam Test Teardown

[2][2.0] General_SiSo_RU_module_reset_from_GUI
    [Tags]    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    General_SiSo_RF_module_reset_from_GUI_CB010578
    #UES attach and detach check
    [Teardown]    SISO Coam Test Teardown

[2][2.0] Manual_SiSo_SM_RF_Module_lock_unlock
    [Tags]    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    E2E_SiSo_RU_lock_and_unlock_gNB    with_call=False
    #UES attach and detach check
    [Teardown]    SISO Coam Test Teardown

[2][2.1] General_SiSo_Cell_block_and_unblock
    [Tags]    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    General_SiSo_Cell_block_and_unblock_for_CB010578_US9
    [Teardown]    Run Keyword And Ignore Error    SISO Coam Test Teardown

[1][3.1] General_SiSo_Online_Cell_Addition_Deletion
    [Tags]    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    Online Cell addition deletion    addition_deletion_cell=1
    #UES attach and detach check
    [Teardown]    SISO Coam Test Teardown

[3][2.0] General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
    [Setup]    SISO Coam Test Setup
    General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot_CB010578_OBSAI
    General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot_CB010578    exclude_RU_index=${5}
    [Teardown]    SISO Coam Test Teardown

[3][1.0] General_SiSo_E2E_system_setup_with_data_transfer_for_configuration_feature_testing
    [Tags]    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    Run Keyword And Ignore Error    US9 UE TP
    [Teardown]    SISO Coam Test Teardown

[1][1.0] Manual_SiSo_REC_Radio_Module_power_reset
    [Tags]    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    Run Keyword And Ignore Error    General_SiSo_RF_module_power_reset
    #UES attach and detach check
    [Teardown]    SISO Coam Test Teardown

[5][2.0] General_SiSo_BTS_startup_with_delayed_RF_link_setup
    [Tags]    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    log to console    General_SiSo_BTS_startup_with_RF_delayed_startup_US9
    General_SiSo_BTS_startup_with_RF_delayed_startup_US9
    [Teardown]    SISO Coam Test Teardown

*** Keywords ***
collect snapshot
    [Arguments]    ${gnb_index}=0
    #robot_common_operations.Common Suite Teardown
    #log to console    \n***SISO Coam Suite Teardown***
    ${connection}    set variable if    ${gnb_index}==0    GNB_OAM    GNB_OAM_${gnb_index}
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    ...    connection=${connection}    gnb_index=${gnb_index}
    Save Coam Snapshot    target_dir=${SAVE LOG DIRECTORY}    connection=${connection}
    COAM Teardown gnb connections    connection=${connection}
    Run Keyword And Ignore Error    process.Terminate All Processes    kill=True

US9 UE TP
    ${pci_list}    Create List    ${21}    ${2}    ${22}    ${11}    ${23}    ${12}    ${1}
    ${list_of_cell_ids}    Create List    ${608731143}    ${608731138}    ${608731144}    ${608731140}    ${608731145}    ${608731141}    ${608731137}
    ${ultarget_throughput}    Create List    ${70}    ${120}    ${70}    ${90}    ${70}    ${90}    ${120}
    ${dltarget_throughput}    Create List    ${120}    ${1400}    ${60}    ${200}    ${60}    ${200}    ${860}
    FOR  ${i}  IN RANGE  7
        Step1:Prepare UE    ue_index=${i}
        log to console    UE${i+1}prepared
    END
    FOR  ${i}  IN RANGE  7
        Step2:UE Attach    ue_index=${i}    pci=${pci_list}[${i}]
        log to console    UE${i+1}attached
    END

    FOR  ${i}  IN RANGE  7
        Start Traffic and Check TP    list_of_cell_ids= ${list_of_cell_ids}[${i}]     ue_index=${i}
        ...    ultarget_throughput=${ultarget_throughput}[${i}]    dltarget_throughput=${dltarget_throughput}[${i}]
        log to console    ${list_of_cell_ids}[${i}]
    END

    FOR  ${i}  IN RANGE  7
        SigSpark_UE detach    ue_index=${i}
        log to console    UE${i+1}detached
    END