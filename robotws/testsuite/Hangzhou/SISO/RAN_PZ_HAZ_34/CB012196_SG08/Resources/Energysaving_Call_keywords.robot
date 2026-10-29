*** Settings ***
Documentation    This is for Energysaving call keywords
...              Author: zhenzhen.ren
...              Squard: HZ SG8

Library       taf.selenium.sbts    WITH NAME    selenium_coam
Library    taf.sbts.oam.coam.admin    WITH NAME    coam
Library    taf.ue    WITH NAME    taf_ue
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/operate_cell_and_check.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/BW_common_case/lib/BW_step_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/cell_addition_deletion_online.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG08_keywords_SISO_operation.robot
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common.py
Variables    ../TestData/CB012196_variables.py

*** Variables ***
@{nr_cell_1}    ${1}
@{nr_cell_2}    ${2}
@{nr_cell_3}    ${3}
@{nr_cell_4}    ${4}
@{nr_cell_5}    ${5}
@{nr_cell_6}    ${6}
@{nr_cell_7}    ${7}
@{nr_cell_8}    ${8}
@{nr_cell_9}    ${9}
@{nr_cell_10}    ${10}
@{nr_cell_11}    ${11}
@{nr_cell_12}    ${12}


*** Keywords ***
Make L3 call in cell1
    Set PA Value For Pointed Port    PA_Port_List=${A1B1_A8B8_UE0}    value=${127}
    log to console    make L3 call (peak is not needed) for cell1 under RU1
    Set PA Value For Pointed Port    PA_Port_List=${A1B1_A4B4_RU1_UE0}   value=${10}
    Set qRxLevMin For cells under ru    ru_index=${1}    value=${-25}
    Set qRxLevMin For pointed NR cell    cell_id_list=${nr_cell_1}    value_call=${-40}
    data_transfer_common    tput_self_define=${tput_detail}    cell_id=${nr_cell_1}
    ...    duration=${300}    target_avg_percent=0.5    min_percent=0.3
    Set PA Value For Pointed Port    PA_Port_List=${A1B1_A4B4_RU1_UE0}    value=${127}


Make L3 call in cell2
    Set PA Value For Pointed Port    PA_Port_List=${A1B1_A8B8_UE0}    value=${127}
    log to console    make L3 call (peak is not needed) for cell2 under RU2
    Set PA Value For Pointed Port    PA_Port_List=${A5B5_A8B8_RU2_UE0}   value=${20}
    Set qRxLevMin For cells under ru    ru_index=${2}    value=${-25}
    Set qRxLevMin For pointed NR cell    cell_id_list=${nr_cell_2}    value_call=${-40}
    data_transfer_common    tput_self_define=${tput_detail}    cell_id=${nr_cell_2}
    ...    duration=${300}    target_avg_percent=0.5    min_percent=0.3
    Set PA Value For Pointed Port    PA_Port_List=${A5B5_A8B8_RU2_UE0}    value=${127}


Make L3 call in cell3
    log to console    make L3 call (peak is not needed) for cell3 under RU3
    Set qRxLevMin For cells under ru    ru_index=${3}    value=${-25}
    Set qRxLevMin For pointed NR cell    cell_id_list=${nr_cell_3}    value_call=${-40}
    data_transfer_common    tput_self_define=${tput_detail}    cell_id=${nr_cell_3}
    ...    duration=${300}    target_avg_percent=0.5    min_percent=0.3


Set qRxLevMin For cells under ru
    [Arguments]    ${ru_index}=1    ${connection}=GNB_OAM    ${value}=${-25}
    log to console    start to set qrxlevmin
    ${cell_id_ru}    Get All Cell Id    ru_index=${ru_index}
    FOR  ${cell_id}  IN  @{cell_id_ru}
        wait until keyword succeeds    3x    30s    coam.perform_parameter_recommissioning
        ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_id}    parameter=qRxLevMin    value=${value}
        ...    operation=update    connection=${connection}
        Sleep    10s
    END


Set qRxLevMin For pointed NR cell
    [Arguments]    ${cell_id_list}    ${connection}=GNB_OAM    ${value_call}=${-40}
    log to console    start to set NR cell qrxlevmin
    FOR  ${cell_id_call}  IN  @{cell_id_list}
        wait until keyword succeeds    3x    30s    coam.perform_parameter_recommissioning
        ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_id_call}    parameter=qRxLevMin
        ...    value=${value_call}    operation=update    connection=${connection}
        sleep    10s
    END
