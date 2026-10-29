*** Settings ***
Documentation     author: Zhang Lusha
...               contact: lusha.zhang@nokia-sbell.com
...               squad group: MN_RAN_RD_VRF_HAZ3_02
...               feature: CB010578-E US#8 config E8
Suite Setup       SISO Coam Suite Setup With Specify SCF    scf_suffix=_E8
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
#${SAVE LOG DIRECTORY}    /home/ute/CMY/log/snapshots/
${ue_type}    ${tl.ues[0].capabilities[1]}

*** Test Cases ***
[2][1.0] General_SiSo_Auto_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
    [Setup]    SISO Coam Test Setup
    General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot_CB010578_OBSAI
    General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot_CB010578    exclude_RU_index=${3}
    [Teardown]    SISO Coam Test Teardown

[1][2.0] Manual_SiSo_SM_RF_Module_lock_unlock
    [Tags]    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    E2E_SiSo_RU_lock_and_unlock_gNB    with_call=False
    [Teardown]    SISO Coam Test Teardown

[1][2.0] Manual_SiSo_SM_BTS_Block_Site
    [Tags]    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    Log To Console    Info: Ready to do BTS Block Site
    Selenium Login And Disable Screen Lock
    Manual_SiSo_SM_BTS_Block_Site.Manual_SiSo_SM_BTS_Block_Site
    Run Keyword And Ignore Error    Selenium Logout And Close Browser
    [Teardown]    SISO Coam Test Teardown

[3][2.0] General_SiSo_Commissioning_BTS_Template_Commissioning
    [Tags]    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    General_SiSo_Commissioning_BTS_Template_Commissioning
    [Teardown]    SISO Coam Test Teardown

[1][2.0] Manual_SiSo_SM_BTS_Site_Reset
    [Tags]    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    General_SiSo_Auto_BTS_site_reset
    [Teardown]    SISO Coam Test Teardown

[1][2.1] General_SiSo_Cell_block_and_unblock
    [Tags]    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    #General_SiSo_Cell_block_and_unblock_for_CB010578
    General_SiSo_Cell_block_and_unblock    with_call=${False}
    [Teardown]    Run Keyword And Ignore Error    SISO Coam Test Teardown

[4][2.0] General_SiSo_BTS_startup_with_delayed_RF_link_setup
    [Tags]    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    General_SiSo_BTS_startup_with_RF_delayed_startup
    [Teardown]    SISO Coam Test Teardown

*** Keywords ***
UES attach and detach check US8
    ${pci_list}    Create List    ${2}    ${11}    ${12}    ${1}
    ${list_of_cell_ids}    Create List    ${608731138}    ${608731140}    ${608731141}    ${608731137}

    FOR  ${i}  IN RANGE  4
        Step1:Prepare UE    ue_index=${i}
        log to console    UE${i+1}prepared
    END
    FOR  ${i}  IN RANGE  4
        Step2:UE Attach    ue_index=${i}    pci=${pci_list}[${i}]
        log to console    UE${i+1}attached
    END

    FOR  ${i}  IN RANGE  4
        SigSpark_UE detach    ue_index=${i}
        log to console    UE${i+1}detached
    END
