*** Settings ***
Documentation     author: Zhang Lusha
...               contact: lusha.zhang@nokia-sbell.com
...               squad group: VRF HAZ3 2
...               feature: CB012512-E
Suite Setup       SISO Coam Suite Setup
Suite Teardown    Run Keyword And Ignore Error     SISO Coam Suite Teardown
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB012512/Resource/CB012512_resource.robot

*** Variables ***
${TS_CASE_LOG_PATH}    /home/ute
${if_commissioning}   False


*** Test Cases ***
CB012512_E_B1_BB_cell_set_change_from_CB012512_C_to_CB012512_D
    [Setup]    SISO Coam Test Setup
    Case_CB012512_E_C2D_Online
    Case_CB012512_E_C2D_need_reset
    [Teardown]    SISO Coam Test Teardown

CB012512_E_B2_BB_cell_set_change_from_CB012512_D_to_CB012512_C
    [Setup]    SISO Coam Test Setup
    Case_CB012512_E_D2C_Online
    Case_CB012512_E_D2C_need_reset
    [Teardown]    SISO Coam Test Teardown

CB012512_E_B2_BB_cell_set_change_from_CB012512_D_to_CB012512_C_FID1868
    [Setup]    SISO Coam Test Setup
    Case_CB012512_E_D2C_FID1868
    Recovery SCF From EC case
    [Teardown]    SISO Coam Test Teardown

CB012512_E_B2_BB_cell_set_change_from_CB012512_B_to_CB012512_C
    [Setup]    SISO Coam Test Setup
    Case_CB012512_E_B2C_Online
    Case_CB012512_E_B2C_need_reset
    [Teardown]    SISO Coam Test Teardown

CB012512_E_B2_BB_cell_set_change_from_CB012512_B_to_CB012512_C_FID1868
    [Setup]    SISO Coam Test Setup
    Case_CB012512_E_B2C_FID1868
    Recovery SCF From EC case
    [Teardown]    SISO Coam Test Teardown


*** Keywords ***
Case_CB012512_E_C2D_Online
    ${Prepare_SCF_Path}=    Replace String    ${Golden_SCF_Path}    .xml    _CB012512_C2D_Case1_Prepare.xml
    ${Result_SCF_Path}=    Replace String    ${Golden_SCF_Path}    .xml    _CB012512_C2D_Case1_Result.xml
    ${add_lte_cell_5}    set variable    5
    ${add_lte_cell_6}    set variable    6
    ${deletion_nrCell}    set variable    2
    Log to console    \n Case_CB012512_E_C2D_Online checking...
    # setp 1: load Prepare_SCF_Path SCF, check onair
    Log to console    +++commission SCF:${Prepare_SCF_Path}+++
    Commissioning SCF And Check On Air      scf_path=${Prepare_SCF_Path}
    # step 2: delete 16D8U NRCELL-2 and add LTE cell 5 6
    selenium login and disable screen lock
    CB012512 Online LTE Cell Addition Steps    addition_cell=${add_lte_cell_5}    copy_scf_path=${Result_SCF_Path}    with_active=${false}
    CB012512 Online LTE Cell Addition Steps    addition_cell=${add_lte_cell_6}    copy_scf_path=${Result_SCF_Path}    with_active=${true}
    CB012512 Online Cell Deletion Steps    deletion_cell=${deletion_nrCell}    with_active=${false}
    # step 3: wait on air
    Wait Until Keyword Succeeds    20min   15s    verify all cells should be onair
    [Teardown]  Selenium Logout And Close Browser

Case_CB012512_E_C2D_need_reset
    ${Prepare_SCF_Path}=    Replace String    ${Golden_SCF_Path}    .xml    _TN_FL_CB012512_C_B1.xml
    ${Result_SCF_Path}=    Replace String    ${Golden_SCF_Path}    .xml    _CB012512_C2D_Case2_Result.xml
    ${add_lte_cell_5}    set variable    5
    ${add_lte_cell_6}    set variable    6
    ${Change_cell_list}    Create list    1    2    3    4    5    6
    Log to console    \n Case_CB012512_E_C2D_need_reset checking...
    # setp 1: load Prepare_SCF_Path SCF, check onair
    Log to console    +++commission SCF:${Prepare_SCF_Path}+++
    Commissioning SCF And Check On Air      scf_path=${Prepare_SCF_Path}
    # setp 2: change all NR TDD cells from 16D8U to 8D8U and add LTE cell 5 6
    selenium login and disable screen lock
    CB012512 Change Celltype From 16D8U To 8D8U Steps    Change_cell_list=${Change_cell_list}    with_active=${false}
    CB012512 Online LTE Cell Addition Steps    addition_cell=${add_lte_cell_5}    copy_scf_path=${Result_SCF_Path}    with_active=${false}
    CB012512 Online LTE Cell Addition Steps    addition_cell=${add_lte_cell_6}    copy_scf_path=${Result_SCF_Path}    with_active=${true}
    # step 3: wait on air
    Wait Until Keyword Succeeds    20min   15s    verify all cells should be onair
    [Teardown]  Selenium Logout And Close Browser

Case_CB012512_E_D2C_Online
    ${Prepare_SCF_Path}=    Replace String    ${Golden_SCF_Path}    .xml    _TN_FL_CB012512_D_B1.xml
    ${Result_SCF_Path}=    Replace String    ${Golden_SCF_Path}    .xml    _CB012512_D2C_Case1_Result.xml
    ${del_nr_Cell}    set variable    6
    ${del_lte_Cell_4}    set variable    4
    ${del_lte_Cell_6}    set variable    6
    ${nrcell_id}    set variable    12
    ${cell_add_info}    Create Dictionary    nrcell_id=${nrcell_id}   cellgrp_id=6    lcrid=12
    ${Change_cell_list}    Create list    1    2    3
    Log to console    \n Case_CB012512_E_D2C_Online checking...
    # setp 1: load Prepare_SCF_Path SCF, check onair
    Log to console    +++commission SCF:${Prepare_SCF_Path}+++
    Commissioning SCF And Check On Air      scf_path=${Prepare_SCF_Path}
    # step 2: delete lte cell 6, 4D4U NRCELL 6, add 16D8U NRCELL 12
    selenium login and disable screen lock
    CB012512 Online LTE Cell Deletion Steps    deletion_cell=${del_lte_Cell_4}    with_active=${false}
    CB012512 Online LTE Cell Deletion Steps    deletion_cell=${del_lte_Cell_6}    with_active=${false}
    CB012512 Online Cell Addition Steps    cell_add_info=${cell_add_info}    copy_scf_path=${Result_SCF_Path}    with_active=${false}
    CB012512 Online Cell Deletion Steps    deletion_cell=${del_nr_Cell}    with_active=${true}
    # step 3: wait on air
    Wait Until Keyword Succeeds    20min   15s    verify all cells should be onair
    [Teardown]  selenium logout and close browser

Case_CB012512_E_D2C_need_reset
    ${Prepare_SCF_Path}=    Replace String    ${Golden_SCF_Path}    .xml    _TN_FL_CB012512_D_B1.xml
    ${Result_SCF_Path}=    Replace String    ${Golden_SCF_Path}    .xml    _CB012512_D2C_Case2_Result.xml
    ${del_lte_cell_4}    set variable    4
    ${del_lte_cell_6}    set variable    6
    ${Change_cell_list}    Create list    1    2    3
    Log to console    \n Case_CB012512_E_D2C_need_reset checking...
    # setp 1: load Prepare_SCF_Path SCF, check onair
    Log to console    +++commission SCF:${Prepare_SCF_Path}+++
    Commissioning SCF And Check On Air      scf_path=${Prepare_SCF_Path}
    # step 2: delete LTE FDD CELL 4 6, change 8D8U NR CELL to 16D8U
    selenium login and disable screen lock
    CB012512 Online LTE Cell Deletion Steps    deletion_cell=${del_lte_cell_4}    with_active=${false}
    CB012512 Online LTE Cell Deletion Steps    deletion_cell=${del_lte_cell_6}    with_active=${false}
    CB012512 Change Celltype From 8D8U To 16D8U Steps
    ...    Change_cell_list=${Change_cell_list}    copy_scf_path=${Result_SCF_Path}    with_active=${true}
    # step 3: wait on air
    Wait Until Keyword Succeeds    20min   15s    verify all cells should be onair
    [Teardown]  Selenium Logout And Close Browser

Case_CB012512_E_D2C_FID1868
    ${Prepare_SCF_Path}=    Replace String    ${Golden_SCF_Path}    .xml    _TN_FL_CB012512_D_B1.xml
    ${Result_SCF_Path}=    Replace String    ${Golden_SCF_Path}    .xml    _CB012512_D2C_Case1_Result.xml
    ${del_nr_Cell}    set variable    6
    ${del_lte_Cell}    set variable    6
    ${nrcell_id}    set variable    12
    ${nr_alarm_1868_list}    Create List    mrbts-${mrbtsId}/nrbts-${nrbtsId}/nrcell-${nrcell_id}
    ${nr_alarm_count}    Get Length    ${nr_alarm_1868_list}
    ${cell_add_info}    Create Dictionary    nrcell_id=${nrcell_id}   cellgrp_id=6    lcrid=12
    Log to console    \n Case_CB012512_E_D2C_FID1868 checking...
    # setp 1: load Prepare_SCF_Path SCF, check onair
    Log to console    +++commission SCF:${Prepare_SCF_Path}+++
    Commissioning SCF And Check On Air      scf_path=${Prepare_SCF_Path}
    # step 2: delete lte cell 6, 4D4U NRCELL 6, add 16D8U NRCELL 12
    selenium login and disable screen lock
    CB012512 Online LTE Cell Deletion Steps    deletion_cell=${del_lte_Cell}    with_active=${false}
    CB012512 Online Cell Addition Steps    cell_add_info=${cell_add_info}    copy_scf_path=${Result_SCF_Path}    with_active=${false}
    CB012512 Online Cell Deletion Steps    deletion_cell=${del_nr_Cell}    with_active=${true}
    # step 3: wait FID 1868 report on new added 16D8U NRCELL 12
    wait until keyword succeeds    20min    10s    Check FID1868 On Expected Cells And Other Cells On Air
    ...    nr_alarm_1868_list=${nr_alarm_1868_list}    nr_alarm_count=${nr_alarm_count}
    [Teardown]  selenium logout and close browser

Case_CB012512_E_B2C_Online
    ${Prepare_SCF_Path}=    Replace String    ${Golden_SCF_Path}    .xml    _CB012512_B2C_Case1_Prepare.xml
    ${Result_SCF_Path}=    Replace String    ${Golden_SCF_Path}    .xml    _CB012512_B2C_Case1_Result.xml
    ${del_lte_cell_4}    set variable    4
    ${del_lte_cell_6}    set variable    6
    ${cell_add_info_4}    Create Dictionary    nrcell_id=4   cellgrp_id=3    lcrid=4
    ${cell_add_info_5}    Create Dictionary    nrcell_id=5   cellgrp_id=4    lcrid=5
    ${cell_add_info_6}    Create Dictionary    nrcell_id=6   cellgrp_id=5    lcrid=6
    ${cells_add_info}    Create List    ${cell_add_info_4}    ${cell_add_info_5}    ${cell_add_info_6}
    Log to console    \n Case_CB012512_E_B2C_Online checking...
    # setp 1: load Prepare_SCF_Path SCF, check onair
    Log to console    +++commission SCF:${Prepare_SCF_Path}+++
    Commissioning SCF And Check On Air      scf_path=${Prepare_SCF_Path}
    # step 2: delete LTE FDD CELL 4 6, add 16D8U NR CELL 4 5 6
    selenium login and disable screen lock
    CB012512 Online LTE Cell Deletion Steps    deletion_cell=${del_lte_cell_4}    with_active=${false}
    CB012512 Online LTE Cell Deletion Steps    deletion_cell=${del_lte_cell_6}    with_active=${false}
    CB012512 Online Cells Addition Steps    cells_add_info=${cells_add_info}    copy_scf_path=${Result_SCF_Path}    with_active=${true}
    # step 3: wait on air
    Wait Until Keyword Succeeds    20min   15s    verify all cells should be onair
    [Teardown]  selenium logout and close browser

Case_CB012512_E_B2C_need_reset
    ${Prepare_SCF_Path}=    Replace String    ${Golden_SCF_Path}    .xml    _CB012512_B2C_Case2_Prepare.xml
    ${Result_SCF_Path}=    Replace String    ${Golden_SCF_Path}    .xml    _CB012512_B2C_Case2_Result.xml
    ${smodBoardConfigType}    set variable    LTEFDD_NRTDD_1
    ${del_nr_cell_9}    set variable    9
    ${cell_add_info_4}    Create Dictionary    nrcell_id=4   cellgrp_id=4    lcrid=4
    ${cell_add_info_5}    Create Dictionary    nrcell_id=5   cellgrp_id=5    lcrid=5
    ${cell_add_info_6}    Create Dictionary    nrcell_id=6   cellgrp_id=6    lcrid=6
    ${cells_add_info}    Create List    ${cell_add_info_4}    ${cell_add_info_5}    ${cell_add_info_6}
    ${add_lte_cells}    Create List    ${1}    ${2}    ${3}    ${4}
    Log to console    \n Case_CB012512_E_B2C_need_reset checking...
    # setp 1: load Prepare_SCF_Path SCF, check onair
    Log to console    +++commission SCF:${Prepare_SCF_Path}+++
    Commissioning SCF And Check On Air      scf_path=${Prepare_SCF_Path}
    # step 2: add 16D8U NR CELL 4 5 6, delete NR FDD CELL 9, add LTE FDD 4CC, change smodBoardConfigType to LTEFDD_NRTDD_1
    selenium login and disable screen lock
    CB012512 Online Cells Addition Steps    cells_add_info=${cells_add_info}    copy_scf_path=${Result_SCF_Path}    with_active=${false}
    CB012512 Online Cell Deletion Steps    deletion_cell=${del_nr_cell_9}    with_active=${false}
    Wait Until Keyword Succeeds    3x   10s    selenium_coam.set_parameter_value
    ...    dist_name=MRBTS-${mrbtsID}/EQM-1/APEQM-1/CABINET-1/SMOD-1/BBCAP-1
    ...    filter_param=SMOD board configuration type    abbr=smodBoardConfigType    new_value=${smodBoardConfigType}
    CB012512 Online Add LNBTS    addition_cells=${add_lte_cells}    copy_scf_path=${Result_SCF_Path}    with_active=${true}
    # step 3: wait on air
    Wait Until Keyword Succeeds    20min   15s    verify all cells should be onair
    [Teardown]  Selenium Logout And Close Browser

Case_CB012512_E_B2C_FID1868
    ${Prepare_SCF_Path}=    Replace String    ${Golden_SCF_Path}    .xml    _CB012512_B2C_Case1_Prepare.xml
    ${Result_SCF_Path}=    Replace String    ${Golden_SCF_Path}    .xml    _CB012512_B2C_Case1_Result.xml
    ${del_lte_cell_6}    set variable    6
    ${add_nr_cell_4}    set variable    4
    ${add_nr_cell_5}    set variable    5
    ${add_nr_cell_6}    set variable    6
    ${cell_add_info_4}    Create Dictionary    nrcell_id=${add_nr_cell_4}   cellgrp_id=3    lcrid=4
    ${cell_add_info_5}    Create Dictionary    nrcell_id=${add_nr_cell_5}   cellgrp_id=4    lcrid=5
    ${cell_add_info_6}    Create Dictionary    nrcell_id=${add_nr_cell_6}   cellgrp_id=5    lcrid=6
    ${cells_add_info}    Create List    ${cell_add_info_4}    ${cell_add_info_5}    ${cell_add_info_6}
    ${nr_alarm_1868_list}    Create List
    ...    mrbts-${mrbtsId}/nrbts-${nrbtsId}/nrcell-${add_nr_cell_4}
    ...    mrbts-${mrbtsId}/nrbts-${nrbtsId}/nrcell-${add_nr_cell_5}
    ...    mrbts-${mrbtsId}/nrbts-${nrbtsId}/nrcell-${add_nr_cell_6}
    ${nr_alarm_count}    Get length    ${nr_alarm_1868_list}
    Log to console    \n Case_CB012512_E_B2C_FID1868 checking...
    # setp 1: load Prepare_SCF_Path SCF, check onair
    Log to console    +++commission SCF:${Prepare_SCF_Path}+++
    Commissioning SCF And Check On Air      scf_path=${Prepare_SCF_Path}
    # step 2: delete LTE FDD CELL 6, add 16D8U NR CELL 4 5 6
    selenium login and disable screen lock
    CB012512 Online LTE Cell Deletion Steps    deletion_cell=${del_lte_cell_6}    with_active=${false}
   CB012512 Online Cells Addition Steps    cells_add_info=${cells_add_info}    copy_scf_path=${Result_SCF_Path}    with_active=${true}
    # step 3: wait FID 1868
    sleep     30s
    coam wait for gnb ready and cell setup
    wait until keyword succeeds    20min    10s    Check FID1868 On Expected Cells And Other Cells On Air
    ...    nr_alarm_1868_list=${nr_alarm_1868_list}    nr_alarm_count=${nr_alarm_count}
    [Teardown]  selenium logout and close browser

