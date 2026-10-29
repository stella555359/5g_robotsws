*** Settings ***
Documentation     author: Jerry Wu
...               contact: jerry.wu@nokia-sbell.com
...               squad group: VRF HAZ3 2
...               feature: CB012512-A
#Suite Setup       SISO Coam Suite Setup With Specify SCF    scf_suffix=_CB012512_A_EC1
Suite Setup       SISO Coam Suite Setup
Suite Teardown    Run Keyword And Ignore Error     SISO Coam Suite Teardown
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB012512/Resource/CB012512_resource.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Loop_Collect_Snapshot.robot

*** Variables ***
${TS_CASE_LOG_PATH}    /home/ute
${if_commissioning}    True


*** Test Cases ***
General_SiSo_Commissioning_BTS_Template_Commissioning_A_EC1
    [Documentation]    Modify bbmodBoardConfigType parameter and restore
    [Tags]    AQHC    PARAM_MODIFY    bbmodBoardConfigType
    [Setup]    SISO Coam Test Setup
    ${A_EC1_SCF_Path}    Replace String    ${Golden_SCF_Path}    .xml    _CB012512_A_EC1.xml
    ${nrcell_id}    set variable    16
    ${cell_add_info}    Create Dictionary    nrcell_id=${nrcell_id}   cellgrp_id=16    lcrid=16
    ${nr_alarm_1868_list}    Create List    mrbts-${mrbtsId}/nrbts-${nrbtsId}/nrcell-${nrcell_id}
    ${nr_alarm_count}    Get Length    ${nr_alarm_1868_list}
    # step 1: add NRCELL-16 check FID 1868 should reported on NRCELL-11 and other cells onair
    CB012512 Online Cell Addition    cell_add_info=${cell_add_info}    copy_scf_path=${A_EC1_SCF_Path}
    wait until keyword succeeds    10min    10s    Check FID1868 On Expected Cells And Other Cells On Air
    ...    nr_alarm_1868_list=${nr_alarm_1868_list}    nr_alarm_count=${nr_alarm_count}
    # step 2: delete NRCELL-16 check FID 1868 should clear and all cells on air
    CB012512 Online Cell deletion    deletion_cell=${nrcell_id}
    Wait Until Keyword Succeeds    20min   15s    verify all cells should be onair
    Wait until keyword succeeds    5min    10s    Expect Fault Should Absent    faultId=1868
    # step 3: commission D_EC1_Result SCF, check have FID 1868 on 1 NR cell
    Commission SCF And Check FID 1868    SCF_Path=${A_EC1_SCF_Path}    nr_alarm_count=${nr_alarm_count}
    # step 4: delete one cell, perform sitereset, check have FID 1868 should absent
	CB012512 Online Cell deletion    deletion_cell=${nrcell_id}
    Perform BTS Site Reset And Check FID 1868
    [Teardown]    SISO Coam Test Teardown