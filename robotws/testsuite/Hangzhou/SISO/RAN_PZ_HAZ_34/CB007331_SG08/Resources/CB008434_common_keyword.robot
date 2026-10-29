*** Settings ***
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/OAM_KPI_61a_SiSo_Auto_BTS_site_reset.robot
Library    ../lib/CB007331.py

Documentation
...    author: jiangjing lin
...    contact: jiangjing.lin@nokia-sbell.com
...    Group: HGZ_SG8

*** Variables ***
${MAX_LOOP}    20
${PA_CALL_VALUE}    ${15}
${physCellId}    944
${tl_id}    17
@{cell_ids}    1    2
@{nr_cell_1}    ${1}
@{nr_cell_2}    ${2}

*** Keywords ***
CB008434_Super cell Setup and delete
    [Arguments]    ${duration}=${30}    ${tput_from}=self_define
    log to console    import 1supercell_6subcells scf
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    Commission SCF Accorfing configuration    config_name=1supercell_6subcells
    run keyword and ignore error    Selenium Logout And Close Browser
    log to console    Set PA value for call on supercell 1_subcell 3<-->RU3_ANTL1_to_ANTL4
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU3_1_4}    value=${PA_CALL_VALUE}
    log to console    make peak call on supercell 1_subcell 3
    data_transfer_common    tput_self_define=${tput_cells}    cell_id=${nr_cell_1}    duration=${duration}    tput_from=${tput_from}
    log to console    Set PA value for call on supercell 1_subcell 5<-->RU2_ANTL5_to_ANTL8
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU3_1_4}    value=${127}
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU2_5_8}    value=${PA_CALL_VALUE}
    log to console    make peak call on supercell 1_subcell 5
    data_transfer_common    tput_self_define=${tput_cells}    cell_id=${nr_cell_1}    duration=${duration}    tput_from=${tput_from}
    log to console    import 1_normal_cell scf
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    Commission SCF Accorfing configuration    config_name=1_normal_cell
    log to console    make peak call on normal cell1
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU2_5_8}    value=${127}
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU1_1_4}    value=${PA_CALL_VALUE}
    data_transfer_common    tput_self_define=${tput_cells}    cell_id=${nr_cell_1}    duration=${duration}    tput_from=${tput_from}
    [Teardown]    run keyword and ignore error    Selenium Logout And Close Browser

CB008434_Common_SiSo_State Management_Sub-cell failure in super cell configuration
    [Arguments]    ${duration}=${30}    ${tput_from}=self_define
    log to console    import 1supercell_6subcells scf
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    Commission SCF Accorfing configuration    config_name=1supercell_6subcells
    log to console    power off ru1
    Perform RU Power Off    ru_index=${1}
    Wait Until Keyword Succeeds    10min    1min    RU Should Be Power Off    ru_index=${1}
    log to console    check fault 7116 reported on RU1
    Wait until keyword succeeds    5min    20sec    Expect Fault Should Present    alarmId=7116    faultId=10
    ...    source=[TL${tl_id}_TDD_CPRI] MRBTS-${mrbtsID}/EQM_R-1/APEQM_R-1/RMOD_R-1
    log to console    Set PA value for call on supercell 1_subcell 3<-->RU3_ANTL1_to_ANTL4
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU3_1_4}    value=${PA_CALL_VALUE}
    log to console    make call on supercell 1_subcell 3
    data_transfer_common    tput_self_define=${tput_cells}    cell_id=${nr_cell_1}    duration=${duration}    tput_from=${tput_from}
    log to console    Set PA value for call on supercell 1_subcell 5<-->RU2_ANTL5_to_ANTL8
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU3_1_4}    value=${127}
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU2_5_8}    value=${PA_CALL_VALUE}
    log to console    make call on supercell 1_subcell 5
    data_transfer_common    tput_self_define=${tput_cells}    cell_id=${nr_cell_1}    duration=${duration}    tput_from=${tput_from}
    log to console    power off ru2
    Perform RU Power Off    ru_index=${2}
    Wait Until Keyword Succeeds    10min    1min    RU Should Be Power Off    ru_index=${2}
    log to console    check fault 7116 reported on RU2
    Wait until keyword succeeds    5min    20sec    Expect Fault Should Present    alarmId=7116    faultId=10
    ...    source=[TL${tl_id}_TDD_CPRI] MRBTS-${mrbtsID}/EQM_R-1/APEQM_R-1/RMOD_R-2
    log to console    Set PA value for call on supercell 1_subcell 3<-->RU3_ANTL1_to_ANTL4
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU2_5_8}    value=${127}
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU3_1_4}    value=${PA_CALL_VALUE}
    log to console    make call on supercell 1_subcell 3
    data_transfer_common    tput_self_define=${tput_cells}    cell_id=${nr_cell_1}    duration=${duration}    tput_from=${tput_from}
    log to console    power off ru3
    Perform RU Power Off    ru_index=${3}
    Wait Until Keyword Succeeds    10min    1min    RU Should Be Power Off    ru_index=${3}
    log to console    check fault 7116 reported on RU3
    Wait until keyword succeeds    5min    20sec    Expect Fault Should Present    alarmId=7116    faultId=10
    ...    source=[TL${tl_id}_TDD_CPRI] MRBTS-${mrbtsID}/EQM_R-1/APEQM_R-1/RMOD_R-3
    ${ru_index_list}  Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        log to console    power on ru${ru_index}
        Perform RU Power On    ru_index=${ru_index}    model=${tl.gnbs[0].dus[0].rus[${ru_index}-1].pdu_port.pdu.vendor}
        Wait Until Keyword Succeeds    10min    1min    RU Should Be Online    ru_index=${ru_index}
        log to console    check fault 7116 disappeared on ru${ru_index}
        Expect Fault Should Absent    faultId=10    source=[TL${tl_id}_TDD_CPRI] MRBTS-${mrbtsID}/EQM_R-1/APEQM_R-1/RMOD_R-${ru_index}
    END
    Wait Until Keyword Succeeds    10 min    20 sec    Verify all cells should be onair
    log to console    Set PA value for call on supercell 1_subcell 2<-->ANTL1_to_ANTL4
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU3_1_4}    value=${127}
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU2_1_4}    value=${PA_CALL_VALUE}
    log to console    make call on supercell 1_subcell 2
    data_transfer_common    tput_self_define=${tput_cells}    cell_id=${nr_cell_1}    duration=${duration}    tput_from=${tput_from}
    log to console    Set PA value for call on supercell 1_subcell 4<-->RU1_ANTL5_to_ANTL8
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU2_1_4}    value=${127}
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU1_5_8}    value=${PA_CALL_VALUE}
    log to console    make call on supercell 1_subcell 4
    data_transfer_common    tput_self_define=${tput_cells}    cell_id=${nr_cell_1}    duration=${duration}    tput_from=${tput_from}
    log to console    Set PA value for call on supercell 1_subcell 6<-->RU3_ANTL5_to_ANTL8
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU1_5_8}    value=${127}
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU3_5_8}    value=${PA_CALL_VALUE}
    log to console    make call on supercell 1_subcell 6
    data_transfer_common    tput_self_define=${tput_cells}    cell_id=${nr_cell_1}    duration=${duration}    tput_from=${tput_from}
    [Teardown]    Run Keywords    Run keyword and ignore error    PonwerOn all Rus    ru_index_list=${ru_index_list}
    ...    AND    Run keyword and ignore error    Selenium Logout And Close Browser

CB008434_Super_Cell_Reconfiguration
    [Arguments]    ${duration}=${30}
    log to console    import 1supercell_6subcells scf
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    ${SCF_upload}    Replace String    ${Golden_SCF_Path}    .xml    _1supercell_6subcells.xml
    COAM Commission with scf file    scf_file_path=${SCF_upload}    timeout=${600}
    Run keyword and ignore error    Selenium Logout And Close Browser
#    log to console    Set PA value for call on supercell 1_subcell 1<-->RU1_ANTL1_to_ANTL4
#    Set PA Value For Pointed Port    PA_Port_List=${PA_RU1_1_4}    value=${PA_CALL_VALUE}
#    log to console    make call on supercell 1_subcell 1
#    data_transfer_common    tput_self_define=${tput_cells}    cell_id=${nr_cell_1}    duration=${duration}
#    ...    target_avg_percent=${0.3}    min_percent=${0.2}    tput_from=self_define
#    log to console    Set PA value for call on supercell 1_subcell 2<-->RU2_ANTL1_to_ANTL4
#    Set PA Value For Pointed Port    PA_Port_List=${PA_RU1_1_4}    value=${127}
#    Set PA Value For Pointed Port    PA_Port_List=${PA_RU2_1_4}    value=${PA_CALL_VALUE}
#    log to console    make call on supercell 1_subcell 2
#    data_transfer_common    tput_self_define=${tput_cells}    cell_id=${nr_cell_1}    duration=${duration}
#    ...    target_avg_percent=${0.3}    min_percent=${0.2}    tput_from=self_define
#    log to console    Set PA value for call on supercell 1_subcell 3<-->RU3_ANTL1_to_ANTL4
#    Set PA Value For Pointed Port    PA_Port_List=${PA_RU2_1_4}    value=${127}
#    Set PA Value For Pointed Port    PA_Port_List=${PA_RU3_1_4}    value=${PA_CALL_VALUE}
#    log to console    make call on supercell 1_subcell 3
#    data_transfer_common    tput_self_define=${tput_cells}    cell_id=${nr_cell_1}    duration=${duration}
#    ...    target_avg_percent=${0.3}    min_percent=${0.2}    tput_from=self_define
#    log to console    Set PA value for call on supercell 1_subcell 4<-->RU1_ANTL5_to_ANTL8
#    Set PA Value For Pointed Port    PA_Port_List=${PA_RU3_1_4}    value=${127}
#    Set PA Value For Pointed Port    PA_Port_List=${PA_RU1_5_8}    value=${PA_CALL_VALUE}
#    log to console    make call on supercell 1_subcell 4
#    data_transfer_common    tput_self_define=${tput_cells}    cell_id=${nr_cell_1}    duration=${duration}
#    ...    target_avg_percent=${0.3}    min_percent=${0.2}    tput_from=self_define
#    log to console    Set PA value for call on supercell 1_subcell 5<-->RU2_ANTL5_to_ANTL8
#    Set PA Value For Pointed Port    PA_Port_List=${PA_RU1_5_8}    value=${127}
#    Set PA Value For Pointed Port    PA_Port_List=${PA_RU2_5_8}    value=${PA_CALL_VALUE}
#    log to console    make call on supercell 1_subcell 5
#    data_transfer_common    tput_self_define=${tput_cells}    cell_id=${nr_cell_1}    duration=${duration}
#    ...    target_avg_percent=${0.3}    min_percent=${0.2}    tput_from=self_define
#    log to console    Set PA value for call on supercell 1_subcell 6<-->RU3_ANTL5_to_ANTL8
#    Set PA Value For Pointed Port    PA_Port_List=${PA_RU2_5_8}    value=${127}
#    Set PA Value For Pointed Port    PA_Port_List=${PA_RU3_5_8}    value=${PA_CALL_VALUE}
#    log to console    make call on supercell 1_subcell 6
#    data_transfer_common    tput_self_define=${tput_cells}    cell_id=${nr_cell_1}    duration=${duration}
#    ...    target_avg_percent=${0.3}    min_percent=${0.2}    tput_from=self_define
    log to console    select 2 supercells to make call
    ${cells_selected}   get_subcells_by_random    cell_count_all=${6}    cell_count_select=${2}
    FOR    ${cell_select}    IN    @{cells_selected}
        select_subcell_to_make_call    subcell_id=${cell_select}    duration=${duration}
    END
    log to console    change 1supercell_6subcells to 1supercell_3subcells_and_3_normal_cells normal cells
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    Modify 1supercell&6subcells to 1supercell&3subcells and 3_normal_cells
    Wait Until Keyword Succeeds    10 min    20 sec    Verify all cells should be onair
    Run keyword and ignore error    Selenium Logout And Close Browser
#    log to console    Set PA value for call on supercell 1_subcell 1<-->RU1_ANTL1_to_ANTL4
#    Set PA Value For Pointed Port    PA_Port_List=${PA_RU3_5_8}    value=${127}
#    Set PA Value For Pointed Port    PA_Port_List=${PA_RU1_1_4}    value=${PA_CALL_VALUE}
#    log to console    make call on supercell 1_subcell 1
#    data_transfer_common    tput_self_define=${tput_cells}    cell_id=${nr_cell_1}    duration=${duration}
#    ...    target_avg_percent=${0.3}    min_percent=${0.2}    tput_from=self_define
#    log to console    Set PA value for call on supercell 1_subcell 2<-->RU2_ANTL1_to_ANTL4
#    Set PA Value For Pointed Port    PA_Port_List=${PA_RU1_1_4}    value=${127}
#    Set PA Value For Pointed Port    PA_Port_List=${PA_RU2_1_4}    value=${PA_CALL_VALUE}
#    log to console    make call on supercell 1_subcell 2
#    data_transfer_common    tput_self_define=${tput_cells}    cell_id=${nr_cell_1}    duration=${duration}
#    ...    target_avg_percent=${0.3}    min_percent=${0.2}    tput_from=self_define
#    log to console    Set PA value for call on supercell 1_subcell 3<-->RU3_ANTL1_to_ANTL4
#    Set PA Value For Pointed Port    PA_Port_List=${PA_RU2_1_4}    value=${127}
#    Set PA Value For Pointed Port    PA_Port_List=${PA_RU3_1_4}    value=${PA_CALL_VALUE}
#    log to console    make call on supercell 1_subcell 3
#    data_transfer_common    tput_self_define=${tput_cells}    cell_id=${nr_cell_1}    duration=${duration}
#    ...    target_avg_percent=${0.3}    min_percent=${0.2}    tput_from=self_define
    log to console    select 2 supercells to make call
    ${cells_selected}   get_subcells_by_random    cell_count_all=${3}    cell_count_select=${2}
    FOR    ${cell_select}    IN    @{cells_selected}
        select_subcell_to_make_call    subcell_id=${cell_select}    duration=${duration}
    END
    log to console    change 1supercell_3subcells_and_3_normal_cells normal cells to 1supercell_3subcells_and_1supercell_3subcells
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    Modify 1supercell&3subcells and 3_normal_cells to 1supercell&3subcells and 1supercell&3subcells
    Wait Until Keyword Succeeds    10 min    20 sec    Verify all cells should be onair
    Run keyword and ignore error    Selenium Logout And Close Browser
#    log to console    import 1supercell_3subcells_and_1supercell_3subcells scf
#    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
#    Commission SCF Accorfing configuration    config_name=1supercell_3subcells_and_1supercell_3subcells
#    Run keyword and ignore error    Selenium Logout And Close Browser
#    log to console    Set PA value for call on supercell 1_subcell 1<-->RU1_ANTL1_to_ANTL4
#    Set PA Value For Pointed Port    PA_Port_List=${PA_RU3_1_4}    value=${127}
#    Set PA Value For Pointed Port    PA_Port_List=${PA_RU1_1_4}    value=${PA_CALL_VALUE}
#    log to console    make call on supercell 1_subcell 1
#    data_transfer_common    tput_self_define=${tput_cells}    cell_id=${nr_cell_1}    duration=${duration}    tput_from=${tput_from}
#    log to console    Set PA value for call on supercell 1_subcell 2<-->RU2_ANTL1_to_ANTL4
#    Set PA Value For Pointed Port    PA_Port_List=${PA_RU1_1_4}    value=${127}
#    Set PA Value For Pointed Port    PA_Port_List=${PA_RU2_1_4}    value=${PA_CALL_VALUE}
#    log to console    make call on supercell 1_subcell 2
#    data_transfer_common    tput_self_define=${tput_cells}    cell_id=${nr_cell_1}    duration=${duration}    tput_from=${tput_from}
#    log to console    Set PA value for call on supercell1_subcell 3<-->RU3_ANTL1_to_ANTL4
#    Set PA Value For Pointed Port    PA_Port_List=${PA_RU2_1_4}    value=${127}
#    Set PA Value For Pointed Port    PA_Port_List=${PA_RU3_1_4}    value=${PA_CALL_VALUE}
#    log to console    make call on supercell 1_subcell 3
#    data_transfer_common    tput_self_define=${tput_cells}    cell_id=${nr_cell_1}    duration=${duration}    tput_from=${tput_from}
#    log to console    Set PA value for call on supercell 2_subcell 1<-->RU1_ANTL5_to_ANTL8
#    Set PA Value For Pointed Port    PA_Port_List=${PA_RU3_1_4}    value=${127}
#    Set PA Value For Pointed Port    PA_Port_List=${PA_RU1_5_8}    value=${PA_CALL_VALUE}
#    log to console    make call on supercell 2_subcell 1
#    data_transfer_common    tput_self_define=${tput_cells}    cell_id=${nr_cell_2}    duration=${duration}    tput_from=${tput_from}
#    log to console    Set PA value for call on supercell 2_subcell 2<-->connect to RU2_ANTL5_to_ANTL8
#    Set PA Value For Pointed Port    PA_Port_List=${PA_RU1_5_8}    value=${127}
#    Set PA Value For Pointed Port    PA_Port_List=${PA_RU2_5_8}    value=${PA_CALL_VALUE}
#    log to console    make call on supercell 2_subcell 2
#    data_transfer_common    tput_self_define=${tput_cells}    cell_id=${nr_cell_2}    duration=${duration}    tput_from=${tput_from}
#    log to console    Set PA value for call on supercell 3_subcell 3<-->connect to RU3_ANTL5_to_ANTL8
#    Set PA Value For Pointed Port    PA_Port_List=${PA_RU2_5_8}    value=${127}
#    Set PA Value For Pointed Port    PA_Port_List=${PA_RU3_5_8}    value=${PA_CALL_VALUE}
#    log to console    make call on supercell 2_subcell 3
#    data_transfer_common    tput_self_define=${tput_cells}    cell_id=${nr_cell_2}    duration=${duration}    tput_from=${tput_from}
    log to console    change 1supercell_3subcells_and_1supercell_3subcells to 1supercell_2subcells_and_1supercell_4subcells
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    Modify 1supercell&3subcells and 1supercell&3subcells to 1supercell&2subcells and 1supercell&4subcells
    Wait Until Keyword Succeeds    10 min    20 sec    Verify all cells should be onair
    [Teardown]    Run keyword and ignore error    Selenium Logout And Close Browser


select_subcell_to_make_call
    [Arguments]    ${subcell_id}    ${duration}
    ${PA_Port_List}    get_pa_port_list_by_subcell_id    subcell_id=${subcell_id}
    Set PA Value For Pointed Port    PA_Port_List=${PA_Port_List}    value=${PA_CALL_VALUE}
    data_transfer_common    tput_self_define=${tput_cells}    cell_id=${nr_cell_1}    duration=${duration}
    ...    target_avg_percent=${0.3}    min_percent=${0.2}    tput_from=self_define
    Set PA Value For Pointed Port    PA_Port_List=${PA_Port_List}    value=${127}


Manual_SiSo_SM_RF_Module_lock_unlock
    [Arguments]    ${tput_self_define}    ${duration}=${30}    ${ue_index}=0
    ${tput_self_define}    get_self_define_tput_by_release    tput_info=${tput_self_define}
    log to console    import 1supercell_6subcells scf
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    ${SCF_upload}    Replace String    ${Golden_SCF_Path}    .xml    _1supercell_6subcells.xml
    COAM Commission with scf file    scf_file_path=${SCF_upload}    timeout=${600}
    Wait Until Keyword Succeeds    10 min    20 sec    Verify all cells should be onair
    Run keyword and ignore error    Selenium Logout And Close Browser
    log to console    lock ru1
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    selenium_coam.lock_ru    ru_index=${1}
    Run keyword and ignore error    Selenium Logout And Close Browser
    sleep  15
    wait until keyword succeeds    5min    20sec    RU Should Be Locked    ru_index=${1}
    log to console    Set PA value for call on supercell 1_subcell 3<-->RU3_ANTL1_to_ANTL4
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU3_1_4}    value=${PA_CALL_VALUE}
    log to console    make call on supercell 1_subcell 3
    data_transfer_common    tput_self_define=${tput_self_define}    cell_id=${nr_cell_1}    duration=${duration}
    ...    target_avg_percent=${0.3}    min_percent=${0.2}
    log to console    unlock ru1
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    selenium_coam.unlock_ru    ru_index=${1}
    Run keyword and ignore error    Selenium Logout And Close Browser
    sleep  15
    wait until keyword succeeds    10min    20sec    RU Should Be Unlocked    ru_index=${1}
    log to console    Set PA value for call on supercell 1_subcell 1<-->RU1_ANTL1_to_ANTL4
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU3_1_4}    value=${127}
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU1_1_4}    value=${PA_CALL_VALUE}
    log to console    make call on supercell 1_subcell 1
    ${tput_info}    set variable    ${tput_self_define[${nr_cell_1}[0]]}
    make_call    tput_info=${tput_info}    ue_index=${ue_index}
    log to console    lock ru2
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    selenium_coam.lock_ru    ru_index=${2}
    Run keyword and ignore error    Selenium Logout And Close Browser
    sleep  15
    wait until keyword succeeds    5min    20sec    RU Should Be Locked    ru_index=${2}
    ${tput_log}    power_ue.Collect Tput    ue_type=nokia_fastmile    duration=${duration}    check_source=Aasyslog
    log to console    check call on supercell 1_subcell 1 still not droped
    check_tput_for_each_cell    tput_info=${tput_self_define}    cell_id=${nr_cell_1}[0]    ue_index=${ue_index}
    ...    target_avg_percent=${0.3}    min_percent=${0.2}    tput_log=${tput_log}
    run keyword and ignore error    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}
    log to console    lock ru3
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    selenium_coam.lock_ru    ru_index=${3}
    Run keyword and ignore error    Selenium Logout And Close Browser
    sleep  15
    wait until keyword succeeds    5min    20sec    RU Should Be Locked    ru_index=${3}
    log to console    lock ru1
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    selenium_coam.lock_ru    ru_index=${1}
    Run keyword and ignore error    Selenium Logout And Close Browser
    sleep  15
    wait until keyword succeeds    5min    20sec    RU Should Be Locked    ru_index=${1}
    ${ru_index_list}  Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        log to console    unlock ru${ru_index}
        Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
        selenium_coam.unlock_ru    ru_index=${ru_index}
        Run keyword and ignore error    Selenium Logout And Close Browser
    END
    sleep  15
    FOR  ${ru_index}  IN  @{ru_index_list}
        wait until keyword succeeds    10min    20sec    RU Should Be Unlocked    ru_index=${ru_index}
    END
    Wait Until Keyword Succeeds    10 min    20 sec    Verify all cells should be onair
    log to console    make call on supercell 1_subcell 1
    data_transfer_common    tput_self_define=${tput_cells}    cell_id=${nr_cell_1}    duration=${duration}
    ...    target_avg_percent=${0.3}    min_percent=${0.2}
    log to console    Set PA value for call on supercell 1_subcell 4<-->RU1_ANTL5_to_ANTL8
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU1_1_4}    value=${127}
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU1_5_8}    value=${PA_CALL_VALUE}
    log to console    make call on supercell 1_subcell 4
    data_transfer_common    tput_self_define=${tput_cells}    cell_id=${nr_cell_1}    duration=${duration}
    ...    target_avg_percent=${0.3}    min_percent=${0.2}
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    [Teardown]  Run Keywords    Run keyword and ignore error    Unlock rus    ru_index_list=${ru_index_list}
    ...    AND    Run keyword and ignore error    Selenium Logout And Close Browser
    ...    AND    run keyword and ignore error    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}

CB008434_General_SiSo_Cell_block_and_unblock
    [Arguments]    ${tput_self_define}    ${duration}=${30}    ${ue_index}=0
    ${tput_self_define}    get_self_define_tput_by_release    tput_info=${tput_self_define}
    Get X2 link shutdown waiting time
    log to console    import 1supercell_2subcells_1supercell_and_4subcells scf
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    Commission SCF Accorfing configuration    config_name=1supercell_2subcells_and_1supercell_4subcells
    Run keyword and ignore error    Selenium Logout And Close Browser
    log to console    Set PA value for call on supercell 2_subcell 1<-->RU1_ANTL5_to_ANTL8
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU1_5_8}    value=${PA_CALL_VALUE}
    log to console    make call on supercell 2_subcell 1
    ${tput_info}    set variable    ${tput_self_define[${nr_cell_2}[0]]}
    make_call    tput_info=${tput_info}    ue_index=${ue_index}
    log to console    block supercell1
    ${cell_id_list}    create list    ${1}
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    Block cells and check status    block_list=${cell_id_list}    check_alarm=${False}    gnb_type=${gNb_CuType}
    Run keyword and ignore error    Selenium Logout And Close Browser
    ${tput_log}    power_ue.Collect Tput    ue_type=nokia_fastmile    duration=${duration}    check_source=Aasyslog
    log to console    check call on supercell2_subcell 1 still not droped
    check_tput_for_each_cell_for_config    cell_id=${nr_cell_2}[0]    ue_index=${ue_index}    tput_log=${tput_log}
    ...    target_avg_percent=${0.3}    min_percent=${0.2}
    run keyword and ignore error    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}
    log to console    unblock supercell1
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    UnBlock cells and check status    block_list=${cell_id_list}    check_alarm=${False}    gnb_type=${gNb_CuType}
    Run keyword and ignore error    Selenium Logout And Close Browser
    log to console    Set PA value for call on supercell 1_subcell 2<-->RU2_ANTL1_to_ANTL4
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU1_5_8}    value=${127}
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU2_1_4}    value=${PA_CALL_VALUE}
    log to console    make call on supercell 1_subcell 2
    ${tput_info}    set variable    ${tput_self_define[${nr_cell_1}[0]]}
    make_call    tput_info=${tput_info}    ue_index=${ue_index}
    log to console    block supercell 2
    ${cell_id_list}    create list    ${2}
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    Block cells and check status    block_list=${cell_id_list}    check_alarm=${False}    gnb_type=${gNb_CuType}
    Run keyword and ignore error    Selenium Logout And Close Browser
    ${tput_log}    power_ue.Collect Tput    ue_type=nokia_fastmile    duration=${duration}    check_source=Aasyslog
    log to console    check call on supercell 1_subcell 2 still not droped
    check_tput_for_each_cell_for_config    cell_id=${nr_cell_1}[0]    ue_index=${ue_index}    tput_log=${tput_log}
    ...    target_avg_percent=${0.3}    min_percent=${0.2}
    run keyword and ignore error    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}
    log to console    unblock supercell 2
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    UnBlock cells and check status    block_list=${cell_id_list}    check_alarm=${False}    gnb_type=${gNb_CuType}
    Run keyword and ignore error    Selenium Logout And Close Browser
    log to console    Set PA value for call on supercell 2_subcell 1<-->RU1_ANTL5_to_ANTL8
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU2_1_4}    value=${127}
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU1_5_8}    value=${PA_CALL_VALUE}
    log to console    make call on supercell 2_subcell 1
    data_transfer_common    tput_self_define=${tput_cells}    cell_id=${nr_cell_2}    duration=${duration}
    ...    target_avg_percent=${0.3}    min_percent=${0.2}
    log to console    Set PA value for call on supercell 2_subcell 2<-->RU2_ANTL5_to_ANTL8
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU1_5_8}    value=${127}
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU2_5_8}    value=${PA_CALL_VALUE}
    log to console    make call on supercell 2_subcell 2
    data_transfer_common    tput_self_define=${tput_cells}    cell_id=${nr_cell_2}    duration=${duration}
    ...    target_avg_percent=${0.3}    min_percent=${0.2}
    log to console    Set PA value for call on supercell 2_subcell 3<-->RU3_ANTL5_to_ANTL8
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU2_5_8}    value=${127}
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU3_5_8}    value=${PA_CALL_VALUE}
    log to console    make call on supercell supercell 2_subcell 3
    data_transfer_common    tput_self_define=${tput_cells}    cell_id=${nr_cell_2}    duration=${duration}
    ...    target_avg_percent=${0.3}    min_percent=${0.2}
    log to console    Set PA value for call on supercell 2_subcell 4<-->RU3_ANTL1_to_ANTL4
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU3_5_8}    value=${127}
    Set PA Value For Pointed Port    PA_Port_List=${PA_RU3_1_4}    value=${PA_CALL_VALUE}
    log to console    make call on supercell supercell 2_subcell 4
    data_transfer_common    tput_self_define=${tput_cells}    cell_id=${nr_cell_2}    duration=${duration}
    ...    target_avg_percent=${0.3}    min_percent=${0.2}
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    [Teardown]    Run keywords    Run Keyword And Ignore Error    UnBlock Cells and check status   block_list=${cell_ids}
    ...    check_alarm=${False}  gnb_type='${gNb_CuType}'    AND   Selenium Logout And Close Browser
    ...    AND    run keyword and ignore error    traffic_stop_and_detach_ue    ue_index_list=${ue_index_list}

Unlock rus
    [Arguments]    ${ru_index_list}
    FOR    ${ru_index}    IN    ${ru_index_list}
        selenium_coam.unlock_ru    ru_index=${ru_index}
    END
    Wait Until Keyword Succeeds    10 min    20 sec    Verify all cells should be onair

Activate Supercell On WEBUI
    [Arguments]    ${nrcell_id}=1
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${nrcell_id}
    ...    filter_param=Activate super cell    new_value=true   abbr=actSuperCell
    Wait Until Keyword Succeeds   3x   10s    selenium_coam.validate_plan
    Wait Until Keyword Succeeds   3x   10s    selenium_coam.activate_plan    activate_plan_despite_errors=${True}    timeout=${180}

Deactivate Supercell On WEBUI
    [Arguments]    ${nrcell_id}=1
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${nrcell_id}
    ...    filter_param=Activate super cell    new_value=false   abbr=actSuperCell
    Wait Until Keyword Succeeds   3x   10s    selenium_coam.validate_plan
    Wait Until Keyword Succeeds   3x   10s    selenium_coam.activate_plan    activate_plan_despite_errors=${True}    timeout=${180}

Auto_BTS_site_reset_kpi
    Wait Until keyword Succeeds    3x    10s    Selenium Login And Disable Screen Lock
    OAM_KPI_61a_SiSo_Auto_BTS_site_reset
    [Teardown]   Selenium Logout And Close Browser

Get PA Port For Subcells
    ${attenuation_port_numbers}    Get PA Ports For each RU    ru_index=${0}
    ${PA_RU1_1_4}    Get values from specified List    origin_list=${attenuation_port_numbers}    index_start=${0}    index_end=${4}
    ${PA_RU1_5_8}    Get values from specified List    origin_list=${attenuation_port_numbers}    index_start=${4}    index_end=${8}
    Set Suite Variable    ${PA_RU1_1_4}
    Set Suite Variable    ${PA_RU1_5_8}
    ${attenuation_port_numbers}    Get PA Ports For each RU    ru_index=${1}
    ${PA_RU2_1_4}    Get values from specified List    origin_list=${attenuation_port_numbers}    index_start=${0}    index_end=${4}
    ${PA_RU2_5_8}    Get values from specified List    origin_list=${attenuation_port_numbers}    index_start=${4}    index_end=${8}
    Set Suite Variable    ${PA_RU2_1_4}
    Set Suite Variable    ${PA_RU2_5_8}
    ${attenuation_port_numbers}    Get PA Ports For each RU    ru_index=${2}
    ${PA_RU3_1_4}    Get values from specified List    origin_list=${attenuation_port_numbers}    index_start=${0}    index_end=${4}
    ${PA_RU3_5_8}    Get values from specified List    origin_list=${attenuation_port_numbers}    index_start=${4}    index_end=${8}
    Set Suite Variable    ${PA_RU3_1_4}
    Set Suite Variable   ${PA_RU3_5_8}

Commission SCF Accorfing configuration
    [Arguments]    ${config_name}
    ${SCF_upload}    Replace String    ${Golden_SCF_Path}    .xml    _${config_name}.xml
    Commissioning SCF And Check On Air    ${SCF_upload}
    ${is_startup_window_exist}    selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window

Modify 1 normal cell to 1supercell&6subcells
    [Arguments]    ${cell_id}=1
    log to console    Modify 1 normal cell to 1supercell&6subcells
    log to console    add channelgroup 2-6 under LCELNR-1
    FOR    ${index}    IN RANGE    2    7
        selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}
        ...    object_class_name=CHANNELGROUP    plan_to_copy_from=CURRENT_BTS_CONF-1
        ...    copy_from=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}/CHANNELGROUP-1
        ...    include_subobject=${True}   id_value=${index}    timeout=15
    END
    Wait Until Keyword Succeeds   3x   10s    selenium_coam.validate_plan
    log to console    modify ANTL for channelgroup 2-6
    Modify ANTL For ChannelGroup    channelgroup_id=2    connect_ru_id=2    ANTL_list=${antl_list_first_half}
    Modify ANTL For ChannelGroup    channelgroup_id=3    connect_ru_id=3    ANTL_list=${antl_list_first_half}
    Modify ANTL For ChannelGroup    channelgroup_id=4    connect_ru_id=1    ANTL_list=${antl_list_last_half}
    Modify ANTL For ChannelGroup    channelgroup_id=5    connect_ru_id=2    ANTL_list=${antl_list_last_half}
    Modify ANTL For ChannelGroup    channelgroup_id=6    connect_ru_id=3    ANTL_list=${antl_list_last_half}

Modify 1supercell&6subcells to 1 normal cell
    [Arguments]    ${cell_id}=1    ${nrcellgroup_id}=0
    log to console    Modify 1supercell&6subcells to 1 normal cell
    log to console    delete channelgroup 2-6 under LCELNR-1
    FOR    ${index}    IN RANGE    2    7
        selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}/CHANNELGROUP-${index}
        ...    timeout=15
        sleep    2s
    END
    log to console    set numberOfTransmittedSsBlocks to 1 beam
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELLGRP-${nrcellgroup_id}
    ...    filter_param=Number of transmitted Synchronization Signal Blocks    new_value=1 beam   abbr=numberOfTransmittedSsBlocks
    Wait Until Keyword Succeeds   3x   10s    selenium_coam.validate_plan


Modify 1supercell&3subcells to 1supercell&6subcells
    [Arguments]    ${cell_id}=1
    log to console    Modify 1supercell&3subcells to 1supercell&6subcells
    log to console    add channelgroup 4-6 under LCELNR-1
    FOR    ${index}    IN RANGE    4    7
        selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}
        ...    object_class_name=CHANNELGROUP    plan_to_copy_from=CURRENT_BTS_CONF-1
        ...    copy_from=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}/CHANNELGROUP-1
        ...    include_subobject=${True}   id_value=${index}    timeout=15
    END
    Wait Until Keyword Succeeds   3x   10s    selenium_coam.validate_plan
    log to console    modify ANTL for channelgroup 4-6
    Modify ANTL For ChannelGroup    channelgroup_id=4    connect_ru_id=1    ANTL_list=${antl_list_last_half}
    Modify ANTL For ChannelGroup    channelgroup_id=5    connect_ru_id=2    ANTL_list=${antl_list_last_half}
    Modify ANTL For ChannelGroup    channelgroup_id=6    connect_ru_id=3    ANTL_list=${antl_list_last_half}
    Wait Until Keyword Succeeds   3x   10s    selenium_coam.activate_plan    activate_plan_despite_errors=${True}    timeout=${180}

Modify 1supercell&6subcells to 1supercell&3subcells and 3_normal_cells
    log to console    Modify 1supercell&6subcells to 1supercell&3subcells and 3_normal_cells
    log to console    delete channelgroup 2-6 under LCELNR-1
    FOR    ${index}    IN RANGE    2    7
        selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-${index}    timeout=15
        sleep    2s
    END
    log to console    set actSuperCell to false for nrcell1
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-1
    ...    filter_param=Activate super cell    new_value=false   abbr=actSuperCell
    log to console    set numberOfTransmittedSsBlocks to 1 beam for nrcell1
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELLGRP-0
    ...    filter_param=Number of transmitted Synchronization Signal Blocks    new_value=1 beam   abbr=numberOfTransmittedSsBlocks
    Wait Until Keyword Succeeds   3x   10s    selenium_coam.validate_plan
    ${modify_params}  create list
    FOR    ${index}    IN RANGE    2    5
        ${physCellId_new}    Evaluate    ${physCellId}+${index}-1
        ${cell_id}    Evaluate    ${index}+${100}
        ${index_cellgroup}    Evaluate    ${cell_id}-${1}
        ${node_index}    Evaluate    ${index}-${1}
        log to console    add nrcell ${cell_id} under MRBTS-958/NRBTS-5958
        selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
        ...    object_class_name=NRCELL    plan_to_copy_from=CURRENT_BTS_CONF-1
        ...    copy_from=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-1
        ...    include_subobject=${True}   id_value=${cell_id}    timeout=15
        log to console    add nrcellgroup ${index_cellgroup} under MRBTS-958/NRBTS-5958
        selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
        ...    object_class_name=NRCELLGRP    plan_to_copy_from=CURRENT_BTS_CONF-1
        ...    copy_from=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELLGRP-0
        ...    include_subobject=${True}   id_value=${index_cellgroup}    timeout=15
        log to console    add LCELNR ${cell_id} under MRBTS-958/MNL-1/MNLENT-1/CELLMAPPING-1
        selenium_coam.add_object    object_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1
        ...    object_class_name=LCELNR    plan_to_copy_from=CURRENT_BTS_CONF-1
        ...    copy_from=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1
        ...    include_subobject=${True}   id_value=${cell_id}    timeout=15
        log to console    add lcrld ${cell_id}
        ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
        ...    filter_param=Local cell resource ID   p_name=lcrId    value=${cell_id}
        append to list    ${modify_params}    ${item}
        log to console    set physCellId for cell ${cell_id}
        ${item}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
        ...    filter_param=Physical cell identifier   p_name=physCellId    value=${physCellId_new}
        append to list    ${modify_params}    ${item}
        log to console    set nrCellList ${cell_id}
        selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP-${index_cellgroup}
        ...    filter_param=List of NR cells assigned to cell group    node_index=${0}    new_value=${cell_id}    abbr=nrCellList
        log to console    add refNrCellGroup ${index_cellgroup}
        selenium_coam.add_element    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1    filter_param=Reference to cell group
        ...    abbr=refNrCellGroup
        selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1
        ...    filter_param=Reference to cell group    node_index=${node_index}    new_value=${index_cellgroup}    abbr=refNrCellGroup
    END
    Modify Parameters On Webem    modify_params=${modify_params}    is_activate=${False}
    log to console    modify ANTL for LCELNR-102, LCELNR-103, and LCELNR-104
    Modify ANTL For ChannelGroup    cell_id=102    channelgroup_id=1    connect_ru_id=1    ANTL_list=${antl_list_last_half}
    Modify ANTL For ChannelGroup    cell_id=103    channelgroup_id=1    connect_ru_id=2    ANTL_list=${antl_list_last_half}
    Modify ANTL For ChannelGroup    cell_id=104    channelgroup_id=1    connect_ru_id=3    ANTL_list=${antl_list_last_half}
    log to console    undo remove channelgroup of 2-3 under LCELNR-1
    selenium_coam.undo_object_changes    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2
    selenium_coam.undo_object_changes    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-3
    log to console    set numberOfTransmittedSsBlocks to 3 beam for modify nrcell1
    log to console    set actSuperCell to true for nrcell1
    Activate Supercell On WEBUI

Modify 1supercell&3subcells and 3_normal_cells to 1supercell&3subcells and 1supercell&3subcells
    log to console    Modify 1supercell&3subcells and 3_normal_cells to 1supercell&3subcells and 1supercell&3subcells
    ${release_current}    Fetch From Left    ${Active_SW_version}    _
    FOR    ${index}    IN RANGE    2    5
        ${cell_id}    Evaluate    ${index}+${100}
        ${index_cellgroup}    Evaluate    ${cell_id}-${1}
        ${node_index}    Evaluate    ${index}-${1}
        log to console    delete nrcell ${cell_id} under MRBTS-958/NRBTS-5958
        selenium_coam.remove_object    object_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}    timeout=15
        sleep    2s
        log to console    delete nrcellgrouip ${index_cellgroup} under MRBTS-958/NRBTS-5958
        selenium_coam.remove_object    object_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP-${index_cellgroup}    timeout=15
        sleep    2s
        log to console    delete refNrCellGroup for cellgroup ${node_index}
        ${node_index_tmp}    run keyword if    '${release_current}'=='SBTS00'    set variable    ${1}    ELSE
        ...    set variable    ${node_index}
        selenium_coam.remove_element    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1    filter_param=Reference to cell group
        ...    node_index=${node_index_tmp}
        log to console    delete LCELNR ${cell_id} under MRBTS-958/MNL-1/MNLENT-1/CELLMAPPING-1
        selenium_coam.remove_object    object_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}    timeout=15
        sleep    2s
    END
    Wait Until Keyword Succeeds   3x   10s    selenium_coam.validate_plan
    log to console    add nrcell2 and nrcellgroup1 under MRBTS-958/NRBTS-5958
    selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    object_class_name=NRCELL    plan_to_copy_from=CURRENT_BTS_CONF-1
    ...    copy_from=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-1
    ...    include_subobject=${True}   id_value=2    timeout=15
    selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    object_class_name=NRCELLGRP    plan_to_copy_from=CURRENT_BTS_CONF-1
    ...    copy_from=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELLGRP-0
    ...    include_subobject=${True}   id_value=1    timeout=15
    log to console    add lcrld 2
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-2
    ...    filter_param=Local cell resource ID    new_value=2   abbr=lcrId
    ${physCellId_new}    Evaluate    ${physCellId}+1
    log to console    modify physCellId to ${physCellId_new}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-2
    ...    filter_param=Physical cell identifier    new_value=${physCellId_new}    abbr=physCellId
    log to console    add nrCellList 2
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP-1
    ...    filter_param=List of NR cells assigned to cell group    node_index=${0}    new_value=2    abbr=nrCellList
    log to console    add refNrCellGroup 1
    selenium_coam.add_element    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1    filter_param=Reference to cell group
    ...    abbr=refNrCellGroup
    ${node_index_tmp}    run keyword if    '${release_current}'=='SBTS00'    set variable    ${1}    ELSE
    ...    set variable    ${4}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1
    ...    filter_param=Reference to cell group    node_index=${node_index_tmp}    new_value=1    abbr=refNrCellGroup
    log to console    add LCELNR-2 under MRBTS-958/MNL-1/MNLENT-1/CELLMAPPING-1. it is copy from LCELNR-1
    selenium_coam.add_object    object_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1
    ...    object_class_name=LCELNR    plan_to_copy_from=CURRENT_BTS_CONF-1
    ...    copy_from=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1
    ...    include_subobject=${True}   id_value=2    timeout=15
    log to console    modify antl port for channelgrpuo 1-3 under LCELNR-2
    Modify ANTL For ChannelGroup    cell_id=2    channelgroup_id=1    connect_ru_id=1    ANTL_list=${antl_list_last_half}
    Modify ANTL For ChannelGroup    cell_id=2    channelgroup_id=2    connect_ru_id=2    ANTL_list=${antl_list_last_half}
    Modify ANTL For ChannelGroup    cell_id=2    channelgroup_id=3    connect_ru_id=3    ANTL_list=${antl_list_last_half}
    Wait Until Keyword Succeeds   3x   10s    selenium_coam.validate_plan
    Wait Until Keyword Succeeds   3x   10s    selenium_coam.activate_plan    activate_plan_despite_errors=${True}    timeout=${180}


Modify 1supercell&3subcells and 1supercell&3subcells to 1supercell&2subcells and 1supercell&4subcells
    log to console    Modify 1supercell&3subcells and 1supercell&3subcells to 1supercell&2subcells and 1supercell&4subcells
    log to console    add channelgroup4 under LCELNR-2. channelgroup4 is copy from channelgroup3 of LCELNR-1
    selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2
    ...    object_class_name=CHANNELGROUP    plan_to_copy_from=CURRENT_BTS_CONF-1
    ...    copy_from=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-3
    ...    include_subobject=${True}   id_value=4    timeout=15
    log to console    delete channelgroup3 under LCELNR-1
    selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-3    timeout=15
    sleep    2s
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELLGRP-0
    ...    filter_param=Number of transmitted Synchronization Signal Blocks    new_value=2 beams   abbr=numberOfTransmittedSsBlocks
    Wait Until Keyword Succeeds   3x   10s    selenium_coam.validate_plan
    Wait Until Keyword Succeeds   3x   10s    selenium_coam.activate_plan    activate_plan_despite_errors=${True}    timeout=${180}

Modify ANTL For ChannelGroup
    [Arguments]     ${ANTL_list}    ${cell_id}=1    ${channelgroup_id}=1    ${connect_ru_id}=1
    ${modify_params}  create list
    FOR    ${index}    IN RANGE    1    9
        ${antl_index}    set variable    ${ANTL_list[${index}-1]}
        ${item}  create dictionary  filter_param=Distinguished Name of antenna line   p_name=antlDN
        ...    dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}/CHANNELGROUP-${channelgroup_id}/CHANNEL-${index}
        ...    value=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-${connect_ru_id}/ANTL-${antl_index}
        append to list    ${modify_params}    ${item}
    END
    Modify Parameters On Webem    modify_params=${modify_params}    is_activate=${False}

PonwerOn all Rus
    [Arguments]    ${ru_index_list}
    FOR  ${ru_index}  IN  @{ru_index_list}
        Perform RU Power On    ru_index=${ru_index}    model=${tl.gnbs[0].dus[0].rus[${ru_index}-1].pdu_port.pdu.vendor}
        Wait Until Keyword Succeeds    10min    1min    RU Should Be Online    ru_index=${ru_index}
    END

Set LTE PA for 40M configuration
    Set Whole Attenuator Ports    attenuator_out_ports=${PA_OUT_PORTS_LTE}    attenuator_rows=${PA_ROWS}
    Set PA Value For Pointed Port    PA_Port_List=${PA_A1B5_A2B6_A3B7_A4B8}    value=${0}

Set LTE PA for 60M configuration
    Set Whole Attenuator Ports    attenuator_out_ports=${PA_OUT_PORTS_LTE}    attenuator_rows=${PA_ROWS}
    Set PA Value For Pointed Port    PA_Port_List=${PA_A5B5_A6B6_A7B7_A8B8}    value=${0}
