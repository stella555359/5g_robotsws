*** Settings ***
#Suite Setup          Common case cbrs Suite Setup
#Suite Teardown       CBRS Suite Teardown
#Test Setup           Common case cbrs Test Setup
#Test Teardown        common case cbrs Test Teardown
#
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
#Resource    resources/CBRS_common_case_keywords_SG8.robot

Documentation
...    Author:wangqingqing
...    contact:qingqing.wang@nokia-sbell.com
...    squad group:SG_08
...    Cases removed by civen.chen due to using removed interface from taf.gnb.oam.coam.cu/vdu

#Force Tags    SBTS00
#...   PY36
#
#*** Variables ***
#
#*** Test Cases ***
#[1]General_SISO_BB_Lock_Unlock_SG08
#    [Tags]    CRT_TRUNK
#    start SAS server    config_name=${common_case_conf}
#    Wait until keyword succeeds    8min    30s    verify all cells should be onair
#    Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=GNB_OAM
#    General_SISO_BB_Lock_Unlock_SG08    tput_self_define=${tput_define_cbrs_common}    Max_loop=${50}    target_avg_percent=0.98
#    ...    min_percent=0.85    cell_id=${cell_id_common}    duration=${120}
#
#[1]General_SISO_BB_Lock_Unlock_With_Call_SG08
#    [Tags]    CRT_TRUNK
#    start SAS server    config_name=${common_case_conf}
#    Wait until keyword succeeds    8min    30s    verify all cells should be onair
#    Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=GNB_OAM
#    General_SISO_BB_Lock_Unlock_With_Call_SG08    tput_self_define=${tput_define_cbrs_common}    Max_loop=${10}    target_avg_percent=0.98
#    ...    min_percent=0.85    cell_id=${cell_id_common}    duration=${120}
#
#[1]General_SISO_BB_Reset_SG08
#    [Tags]    CRT_TRUNK
#    start SAS server    config_name=${common_case_conf}
#    Wait until keyword succeeds    8min    30s    verify all cells should be onair
#    Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=GNB_OAM
#    General_SISO_BB_Reset_SG08    tput_self_define=${tput_define_cbrs_common}    Max_loop=${50}    target_avg_percent=0.98
#    ...    min_percent=0.85    cell_id=${cell_id_common}    duration=${120}
#
#[1]General_SISO_BB_Reset_With_Call_SG08
#    [Tags]    CRT_TRUNK
#    start SAS server    config_name=${common_case_conf}
#    Wait until keyword succeeds    8min    30s    verify all cells should be onair
#    Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=GNB_OAM
#    General_SISO_BB_Reset_With_Call_SG08    tput_self_define=${tput_define_cbrs_common}    Max_loop=${10}    target_avg_percent=0.98
#    ...    min_percent=0.85    cell_id=${cell_id_common}    duration=${120}
#
#[1]General_SISO_Cell_Block_Unblock_SG08
#    [Tags]    CRT_TRUNK
#    start SAS server    config_name=${common_case_conf}
#    Wait until keyword succeeds    8min    30s    verify all cells should be onair
#    Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=GNB_OAM
#    General_SISO_Cell_Block_Unblock_SG08    tput_self_define=${tput_define_cbrs_common}    Max_loop=${50}    target_avg_percent=0.98
#    ...    min_percent=0.85    cell_id=${cell_id_common}    duration=${120}
#
#[1]General_SISO_Cell_Block_Unblock_With_Call_SG08
#    [Tags]    CRT_TRUNK
#    start SAS server    config_name=${common_case_conf}
#    Wait until keyword succeeds    8min    30s    verify all cells should be onair
#    Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=GNB_OAM
#    General_SISO_Cell_Block_Unblock_With_Call_SG08    tput_self_define=${tput_define_cbrs_common}    Max_loop=${10}    target_avg_percent=0.98
#    ...    min_percent=0.85    cell_id=${cell_id_common}    duration=${120}
#
#[1]General_SISO_Cell_Lock_Unlock_SG08
#    [Tags]    CRT_TRUNK
#    start SAS server    config_name=${common_case_conf}
#    Wait until keyword succeeds    8min    30s    verify all cells should be onair
#    Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=GNB_OAM
#    General_SISO_Cell_Lock_Unlock_SG08    tput_self_define=${tput_define_cbrs_common}    Max_loop=${50}    target_avg_percent=0.98
#    ...    min_percent=0.85    cell_id=${cell_id_common}    duration=${120}
#
#[1]General_SISO_Cell_Lock_Unlock_With_Call_SG08
#    [Tags]    CRT_TRUNK
#    start SAS server    config_name=${common_case_conf}
#    Wait until keyword succeeds    8min    30s    verify all cells should be onair
#    Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=GNB_OAM
#    General_SISO_Cell_Lock_Unlock_With_Call_SG08    tput_self_define=${tput_define_cbrs_common}    Max_loop=${10}    target_avg_percent=0.98
#    ...    min_percent=0.85    cell_id=${cell_id_common}    duration=${120}
#
#[1]General_SISO_NR_Cell_Online_delete_add_SG08
#    [Tags]    CRT_TRUNK
#    start SAS server    config_name=${common_case_conf}
#    Wait until keyword succeeds    8min    30s    verify all cells should be onair
#    Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=GNB_OAM
#    General_SISO_NR_Cell_Online_delete_add_SG08    tput_self_define=${tput_define_cbrs_common}    Max_loop=${50}    target_avg_percent=0.98
#    ...    addition_deletion_list=${delete_cell}    min_percent=0.85    cell_id=${cell_id_common}    duration=${120}
#
#[1]General_SISO_NR_Cell_Online_delete_add_With_Call_SG08
#    [Tags]    CRT_TRUNK
#    start SAS server    config_name=${common_case_conf}
#    Wait until keyword succeeds    8min    30s    verify all cells should be onair
#    Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=GNB_OAM
#    General_SISO_NR_Cell_Online_delete_add_With_Call_SG08    tput_self_define=${tput_define_cbrs_common}    Max_loop=${10}    target_avg_percent=0.98
#    ...    addition_deletion_list=${delete_cell}    min_percent=0.85    cell_id=${cell_id_common}    duration=${120}
#
#[1]General_SISO_Site_Reset_SG08
#    [Tags]    CRT_TRUNK
#    start SAS server    config_name=${common_case_conf}
#    Wait until keyword succeeds    8min    30s    verify all cells should be onair
#    Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=GNB_OAM
#    General_SISO_Site_Reset_SG08    tput_self_define=${tput_define_cbrs_common}    Max_loop=${50}    target_avg_percent=0.98
#    ...    min_percent=0.85    cell_id=${cell_id_common}    duration=${120}
#
#[1]General_SISO_Site_Reset_With_Call_SG08
#    [Tags]    CRT_TRUNK
#    start SAS server    config_name=${common_case_conf}
#    Wait until keyword succeeds    8min    30s    verify all cells should be onair
#    Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=GNB_OAM
#    General_SISO_Site_Reset_With_Call_SG08    tput_self_define=${tput_define_cbrs_common}    Max_loop=${10}    target_avg_percent=0.98
#    ...    min_percent=0.85    cell_id=${cell_id_common}    duration=${120}
#
#[1]General_SISO_RU_Reset_SG08
#    [Tags]    CRT_TRUNK
#    start SAS server    config_name=${common_case_conf}
#    Wait until keyword succeeds    8min    30s    verify all cells should be onair
#    Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=GNB_OAM
#    General_SISO_RU_Reset_SG08    tput_self_define=${tput_define_cbrs_common}    Max_loop=${50}    target_avg_percent=0.98
#    ...    min_percent=0.85    cell_id=${cell_id_common}    duration=${120}
#
#[1]General_SISO_RU_Reset_With_Call_SG08
#    [Tags]    CRT_TRUNK
#    start SAS server    config_name=${common_case_conf}
#    Wait until keyword succeeds    8min    30s    verify all cells should be onair
#    Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=GNB_OAM
#    General_SISO_RU_Reset_With_Call_SG08    tput_self_define=${tput_define_cbrs_common}    Max_loop=${10}    target_avg_percent=0.98
#    ...    min_percent=0.85    cell_id=${cell_id_common}    duration=${120}
#
#[1]General_SISO_RAT_Reset_SG08
#    [Tags]    CRT_TRUNK
#    start SAS server    config_name=${common_case_conf}
#    Wait until keyword succeeds    8min    30s    verify all cells should be onair
#    Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=GNB_OAM
#    General_SISO_RAT_Reset_SG08    tput_self_define=${tput_define_cbrs_common}    Max_loop=${50}    target_avg_percent=0.98
#    ...    min_percent=0.85    cell_id=${cell_id_common}    duration=${120}
#
#[1]General_SISO_RAT_Reset_With_Call_SG08
#    [Tags]    CRT_TRUNK
#    start SAS server    config_name=${common_case_conf}
#    Wait until keyword succeeds    8min    30s    verify all cells should be onair
#    Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=GNB_OAM
#    General_SISO_RAT_Reset_With_Call_SG08    tput_self_define=${tput_define_cbrs_common}    Max_loop=${10}    target_avg_percent=0.98
#    ...    min_percent=0.85    cell_id=${cell_id_common}    duration=${120}
#
#[1]General_SISO_RU_Lock_Unlock_loop_SG08
#    [Tags]    CRT_TRUNK
#    start SAS server    config_name=${common_case_conf}
#    Wait until keyword succeeds    8min    30s    verify all cells should be onair
#    Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=GNB_OAM
#    General_SISO_RU_Lock_Unlock_loop_SG08    tput_self_define=${tput_define_cbrs_common}    Max_loop=${50}    target_avg_percent=0.98
#    ...    min_percent=0.85    cell_id=${cell_id_common}    duration=${120}
#
#[1]General_SISO_RU_Lock_Unlock_loop_With_Call_SG08
#    [Tags]    CRT_TRUNK
#    start SAS server    config_name=${common_case_conf}
#    Wait until keyword succeeds    8min    30s    verify all cells should be onair
#    Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=GNB_OAM
#    General_SISO_RU_Lock_Unlock_loop_With_Call_SG08    tput_self_define=${tput_define_cbrs_common}    Max_loop=${10}    target_avg_percent=0.98
#    ...    min_percent=0.85    cell_id=${cell_id_common}    duration=${120}
#
#[1]General_SISO_RAT_Block_Unblock_SG08
#    [Tags]    CRT_TRUNK
#    start SAS server    config_name=${common_case_conf}
#    Wait until keyword succeeds    8min    30s    verify all cells should be onair
#    Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=GNB_OAM
#    General_SISO_RAT_Block_Unblock_SG08    tput_self_define=${tput_define_cbrs_common}    Max_loop=${50}    target_avg_percent=0.98
#    ...    min_percent=0.85    cell_id=${cell_id_common}    duration=${120}
#
#[1]General_SISO_RAT_Block_Unblock_With_Call_SG08
#    [Tags]    CRT_TRUNK
#    start SAS server    config_name=${common_case_conf}
#    Wait until keyword succeeds    8min    30s    verify all cells should be onair
#    Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=GNB_OAM
#    General_SISO_RAT_Block_Unblock_With_Call_SG08    tput_self_define=${tput_define_cbrs_common}    Max_loop=${10}    target_avg_percent=0.98
#    ...    min_percent=0.85    cell_id=${cell_id_common}    duration=${120}
#
#[1]General_SISO_RU_Power_Reset_SG08
#    [Tags]    CRT_TRUNK
#    start SAS server    config_name=${common_case_conf}
#    Wait until keyword succeeds    8min    30s    verify all cells should be onair
#    Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=GNB_OAM
#    General_SISO_RU_Power_Reset_SG08    tput_self_define=${tput_define_cbrs_common}    Max_loop=${50}    target_avg_percent=0.98
#    ...    min_percent=0.85    cell_id=${cell_id_common}    duration=${120}
#
#[1]General_SISO_RU_Power_Reset_With_Call_SG08
#    [Tags]    CRT_TRUNK
#    start SAS server    config_name=${common_case_conf}
#    Wait until keyword succeeds    8min    30s    verify all cells should be onair
#    Wait until keyword succeeds    5min    30s    Verify all lte cells should be onair    connection=GNB_OAM
#    General_SISO_RU_Power_Reset_With_Call_SG08    tput_self_define=${tput_define_cbrs_common}    Max_loop=${10}    target_avg_percent=0.98
#    ...    min_percent=0.85    cell_id=${cell_id_common}    duration=${120}
#
#*** Keywords ***
