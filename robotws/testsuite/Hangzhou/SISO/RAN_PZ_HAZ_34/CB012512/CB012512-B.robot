*** Settings ***
Documentation     author: Zhang Lusha
...               contact: lusha.zhang@nokia-sbell.com
...               squad group: VRF HAZ3 2
...               feature: CB012512-B
Suite Setup       SISO Coam Suite Setup With Specify SCF    scf_suffix=_TN_FN_CB012512_B_B1
Suite Teardown    Run Keyword And Ignore Error     SISO Coam Suite Teardown
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB012512/Resource/CB012512_resource.robot


*** Variables ***
${TS_CASE_LOG_PATH}    /home/ute
# ${if_commissioning}   False


*** Test Cases ***
General_SiSo_Commissioning_BTS_Template_Commissioning
    [Setup]    SISO Coam Test Setup
    General_SiSo_Commissioning_BTS_Template_Commissioning
    [Teardown]    SISO Coam Test Teardown

General_SiSo_Cell_block_and_unblock
    [Setup]    SISO Coam Test Setup
    sleep     2s
    log to console      CB012512-D#B1 if_commissioning is : ${if_commissioning}
    # General_SiSo_Cell_block_and_unblock    with_call=${False}
    [Teardown]    SISO Coam Test Teardown

Manual_SiSo_SM_BTS_Site_Reset
    [Setup]    SISO Coam Test Setup
    General_SiSo_Auto_BTS_site_reset
    [Teardown]    SISO Coam Test Teardown

General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
    [Setup]    SISO Coam Test Setup
    General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
    [Teardown]    SISO Coam Test Teardown

General_SiSo_RU_module_reset_from_GUI
    [Setup]    SISO Coam Test Setup
    General_SiSo_RF_module_reset_from_GUI    with_call=False
    [Teardown]    SISO Coam Test Teardown

General_SiSo_Commissioning_BTS_Template_Commissioning_B2_B3
    [Setup]    SISO Coam Test Setup
    ${B_B2_SCF_Path}=    Replace String    ${Golden_SCF_Path}     B_B1.xml    B_B2.xml
    ${B_B3_SCF_Path}=    Replace String    ${Golden_SCF_Path}    _TN_FN_CB012512_B_B1.xml    _TN_FL_CB012512_B_B3.xml
    Commissioning SCF And Check On Air      scf_path=${B_B2_SCF_Path}
    Commissioning SCF And Check On Air      scf_path=${B_B3_SCF_Path}
    [Teardown]    SISO Coam Test Teardown    is_check_historyalarm=${True}

General_SiSo_Online_Cell_Addition_Deletion_B_EC1
    [Setup]    SISO Coam Test Setup
    Case_CB012512_B_EC1_FID1868_check
    [Teardown]    run keywords    SISO Coam Test Teardown    AND
    ...    run keyword if test failed    Recovery SCF From EC case


*** Keywords ***
Case_CB012512_B_EC1_FID1868_check
    [Documentation]  Author: lusha zhang
    ...    this KW is aim to check the config of CB012512-D#EC1, confirm FID 1868 report and clear
    ...    2 cases: 1.online add delete LTE TDD CELL
    ...             2.commission CB012512_B_EC1 SCF and reset site
    ${B_EC1_Prepare_SCF_Path}=    Replace String    ${Golden_SCF_Path}    _TN_FN_CB012512_B_B1.xml    _TN_FL_CB012512_B_EC1_Prepare.xml
    ${B_EC1_Result_SCF_Path}=    Replace String    ${Golden_SCF_Path}    _TN_FN_CB012512_B_B1.xml    _TN_FL_CB012512_B_EC1_Result_FID1868.xml
    ${lte_cell_id}    set variable    4
    ${lte_alarm_1868_list}    create list    mrbts-${mrbtsId}/lnbts-${nrbtsId}/lncel-${lte_cell_id}
    ${lte_alarm_count}    Get Length    ${lte_alarm_1868_list}
    # setp 1: load D_EC1_Prepare SCF, check onair
    Log to console    +++ commission SCF:${B_EC1_Prepare_SCF_Path} +++
    Commissioning SCF And Check On Air      scf_path=${B_EC1_Prepare_SCF_Path}
    # step 2: add LNCELL-4 check FID 1868 should reported on LNCELL-4
    CB012512 Online LTE Cell addition    addition_cell=${lte_cell_id}    copy_scf_path=${B_EC1_Result_SCF_Path}
    wait until keyword succeeds    10min    10s    Check FID1868 On Expected Cells And Other Cells On Air
    ...    lte_alarm_1868_list=${lte_alarm_1868_list}    lte_alarm_count=${lte_alarm_count}
    # step 3: delete LNCELL-4 check FID 1868 should clear
    CB012512 Online LTE Cell Deletion    deletion_cell=${lte_cell_id}
    Wait Until Keyword Succeeds    20min   15s    verify all cells should be onair
    Wait until keyword succeeds    5min    10s    Expect Fault Should Absent    faultId=1868
    # step 4: commission B_EC1 SCF, check only 1 LTE cell failed by FID 1868
    Commission SCF And Check FID 1868    SCF_Path=${B_EC1_Result_SCF_Path}    lte_alarm_count=${lte_alarm_count}
    # step 5: perform sitereset, check only 1 LTE cell failed by FID 1868
    Perform BTS Site Reset And Check FID 1868    lte_alarm_count=${lte_alarm_count}
    # step 6: recovery to golden SCF
    sleep     10s
    Recovery SCF From EC case
