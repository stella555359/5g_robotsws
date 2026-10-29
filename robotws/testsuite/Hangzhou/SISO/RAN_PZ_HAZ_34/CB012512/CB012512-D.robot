*** Settings ***
Documentation     author: Zhang Lusha
...               contact: lusha.zhang@nokia-sbell.com
...               squad group: VRF HAZ3 2
...               feature: CB012512-D
Suite Setup       SISO Coam Suite Setup With Specify SCF    scf_suffix=_TN_FL_CB012512_D_B1
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
    [Teardown]    SISO Coam Test Teardown    is_check_historyalarm=${True}

General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
    [Setup]    SISO Coam Test Setup
    General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
    [Teardown]    SISO Coam Test Teardown

General_SiSo_RU_module_reset_from_GUI
    [Setup]    SISO Coam Test Setup
    General_SiSo_RF_module_reset_from_GUI    with_call=False
    [Teardown]    SISO Coam Test Teardown

General_SiSo_Online_Cell_Addition_Deletion
    [Setup]    SISO Coam Test Setup
    Online Cell addition deletion    addition_deletion_cell=3
    [Teardown]    SISO Coam Test Teardown

Manual_SiSo_CM_Recommissioning_CB012512_D_EC1
    [Setup]    SISO Coam Test Setup
    Case_CB012512_D_EC1_FID1868_check
    [Teardown]    run keywords    SISO Coam Test Teardown    AND
    ...    run keyword if test failed    Recovery SCF From EC case


*** Keywords ***
Case_CB012512_D_EC1_FID1868_check
    [Documentation]  Author: lusha zhang
    ...    this KW is aim to check the config of CB012512-D#EC1, confirm FID 1868 report and clear
    ...    2 cases: 1.online add delete NR TDD CELL
    ...             2.commission CB012512_D_EC1 SCF and reset site
    ${D_EC1_Prepare_SCF_Path}=    Replace String    ${Golden_SCF_Path}    D_B1.xml    D_EC1_Prepare.xml
    ${D_EC1_Result_SCF_Path}=    Replace String    ${Golden_SCF_Path}    D_B1.xml    D_EC1_Result_FID1868.xml
    ${nrcell_id}    set variable    11
    ${cell_add_info}    Create Dictionary    nrcell_id=${nrcell_id}   cellgrp_id=6    lcrid=11
    ${nr_alarm_1868_list}    Create List    mrbts-${mrbtsId}/nrbts-${nrbtsId}/nrcell-${nrcell_id}
    ${nr_alarm_count}    Get Length    ${nr_alarm_1868_list}
    # setp 1: load D_EC1_Prepare SCF, check onair
    Log to console    +++commission SCF:${D_EC1_Prepare_SCF_Path}+++
    Commissioning SCF And Check On Air      scf_path=${D_EC1_Prepare_SCF_Path}
    # step 2: add NRCELL-11 check FID 1868 should reported on NRCELL-11 and other cells onair
    CB012512 Online Cell Addition    cell_add_info=${cell_add_info}    copy_scf_path=${D_EC1_Result_SCF_Path}
    wait until keyword succeeds    10min    10s    Check FID1868 On Expected Cells And Other Cells On Air
    ...    nr_alarm_1868_list=${nr_alarm_1868_list}    nr_alarm_count=${nr_alarm_count}
    # step 3: delete NRCELL-11 check FID 1868 should clear and all cells on air
    CB012512 Online Cell deletion    deletion_cell=${nrcell_id}
    Wait Until Keyword Succeeds    20min   15s    verify all cells should be onair
    Wait until keyword succeeds    5min    10s    Expect Fault Should Absent    faultId=1868
    # step 4: commission D_EC1_Result SCF, check have FID 1868 on 1 NR cell and all LTE cell OnAir
    Commission SCF And Check FID 1868    SCF_Path=${D_EC1_Result_SCF_Path}    nr_alarm_count=${nr_alarm_count}
    # step 5: perform sitereset, check have FID 1868 on 1 NR cell and all LTE cell OnAir
    Perform BTS Site Reset And Check FID 1868    nr_alarm_count=${nr_alarm_count}
    # step 6: recovery to golden SCF
    sleep     10s
    Recovery SCF From EC case
