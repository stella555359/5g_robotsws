# @Time    : 2024/3/6 10:57
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @Group   : NSB MN RAN RD VRF HAZ3 5
# @File    : CB009508_common_keywords.robot
# @Software: PyCharm
# @Doc     : This is common robot keywords template
*** Settings ***
Documentation
...    Feature CB009508

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot

*** Keywords ***
CB009508 Precondition Delta Json
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/03/07 09:58
    ${cur_scf}    COAM Download scf from cluster    ${TS_LOG_PATH_BASE}

    generate_add_json_base_delete_json_and_cur_scf    ${cur_scf}    ${REMOVE_RU1_3_13_DELTA}    ${CREATE_RU1_3_13_DELTA}
    generate_add_json_base_delete_json_and_cur_scf    ${cur_scf}    ${REMOVE_RU3_DELTA}    ${CREATE_RU3_DELTA}
    generate_add_json_base_delete_json_and_cur_scf    ${cur_scf}    ${REMOVE_RU1_DELTA}    ${CREATE_RU1_DELTA}
    modify_delta_json    ${CREATE_RU3_DELTA}    ${MODIFY_RU3_NO_RU1_13_DELTA}    ${CREATE_RU3_NO_RU1_13_DELTA}

    generate_add_json_base_delete_json_and_cur_scf    ${cur_scf}    ${REMOVE_ABIO_ABIP_RU113_DELTA}    ${CREATE_ABIO_ABIP_RU113_DELTA}

    generate_delta_jsons_from_3_scf    ${cur_scf}    ${COMMON_110_SCF}    ${NO_RU3_SCF}
    ...    ${REMOVE_RU3_DELTA_110}    ${NO_USE_DELTA}

    generate_delta_jsons_from_3_scf    ${cur_scf}    ${NO_RU3_CELL_SCF}    ${NO_RU3_SCF}
    ...    ${NO_USE_DELTA}    ${CREATE_RU3_NO_CELL_DELTA_110}

    generate_delta_jsons_from_3_scf    ${cur_scf}    ${COMMON_110_SCF_PMCCP}    ${NO_RU3_CELL_SCF_PMCCP}
    ...    ${NO_USE_DELTA}    ${CREATE_RU3_CELL_DELTA_110}
    #generate_add_json_base_delete_json_and_cur_scf    ${cur_scf}    ${REMOVE_BB13_RU12_DELTA}    ${CREATE_BB13_RU12_DELTA}


CB009508 Precondition Common Delete
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/03/06 11:21
    [Arguments]    ${delta_json}    ${rus_index}
    coam.perform_delta_recommissioning    delta_file=${delta_json}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=GNB_OAM
    Wait Until Keyword Succeeds    15min    15s    Verify BTS 5G Cells Status Is Normal State
    Log to console    checkruispoweroff
    FOR    ${index}    IN    @{rus_index}
        Perform RU Power Off    ru_index=${index}
    END
    Wait Until Keyword Succeeds    15min    20s    Verify BTS 5G Cells Status Is Normal State

    coam.reset_site    connection=GNB_OAM
    Wait Until Keyword Succeeds    15min    20s    Verify BTS 5G Cells Status Is Normal State

Control BBMOD Power Switch
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    power_status=0 --- power on
    ...    power_status=1 --- power off
    [Arguments]    ${power_status}    ${slot}
    Connect To BTS Csn Via Lmp
    ${contents}    Run Keyword If    '${power_status}'=='0'    csn.Execute
    ...    echo 0 > /dev/ddal/power/slot_id_0${slot}/board_pwr_shutdown    connection=ASIK Master    ELSE
    ...    csn.Execute    echo 1 > /dev/ddal/power/slot_id_0${slot}/board_pwr_shutdown    connection=ASIK Master
    [Teardown]  Run Keyword And Ignore Error    csn.disconnect    connection=ASIK Master

Verify Case106 Cell History Status Normal
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/03/21 22:40
    ${cells_status}    get_cells_history_status
    ${cells_name}    Get Dictionary Keys    ${cells_status}
    ${i_a_list}    Create List    Idle    Active
    ${a_list}    Create List    Active
    Log to console    step2
    Lists Should Be Equal    ${cells_status["NRCELL-25"]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-26"]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-27"]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-28"]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-29"]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-13"]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-14"]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-15"]}    ${a_list}

Verify Case107 Cell History Status Normal
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/03/20 21:16
    ${cells_status}    get_cells_history_status
    ${cells_name}    Get Dictionary Keys    ${cells_status}
    ${a_i_a_list}    Create List    Active    Idle    Active
    ${i_a_list}    Create List    Idle    Active
    ${a_list}    Create List    Active
    Lists Should Be Equal    ${cells_status["NRCELL-2"][-1:]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-25"][-2:]}    ${i_a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-26"][-2:]}    ${i_a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-27"][-2:]}    ${i_a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-28"][-2:]}    ${i_a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-29"][-2:]}    ${i_a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-3"][-1:]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-4"][-1:]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-5"][-1:]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-51"][-1:]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-61"][-1:]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-21"][-1:]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-31"][-1:]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-41"][-1:]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-22"][-1:]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-32"][-1:]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-42"][-1:]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-23"][-1:]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-33"][-1:]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-43"][-1:]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-302"][-1:]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-312"][-1:]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-303"][-1:]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-13"][-3:]}    ${a_i_a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-14"][-3:]}    ${a_i_a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-15"][-3:]}    ${a_i_a_list}

Verify CB008253 Case301 Cell History Status Normal
    [Documentation]    Author: echo.xu@nokia-sbell.com
    ...    Init Define: 2025/02/19 22:40
    ${cells_status}    get_cells_history_status
    ${cells_name}    Get Dictionary Keys    ${cells_status}
    ${a_i_a_list}    Create List    Active    Idle    Active
    ${i_a_list}    Create List    Idle    Active
    ${a_list}    Create List    Active
    Lists Should Be Equal    ${cells_status["NRCELL-2"]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-25"]}    ${i_a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-26"]}    ${i_a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-27"]}    ${i_a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-28"]}    ${i_a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-29"]}    ${i_a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-3"]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-4"]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-5"]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-51"]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-61"]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-21"]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-31"]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-41"]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-22"]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-32"]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-42"]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-23"]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-33"]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-43"]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-302"]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-312"]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-303"]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-313"]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-13"]}    ${a_i_a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-14"]}    ${a_i_a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-15"]}    ${a_i_a_list}

Verify original Cell History Status Normal
    [Documentation]    Author: echo.xu@nokia-sbell.com
    ...    Init Define: 2025/02/19 22:40
    ${cells_status}    get_cells_history_status
    ${cells_name}    Get Dictionary Keys    ${cells_status}
    ${a_list}    Create List    Active
    Log to console    check original cell mapped to RMOD2/5/6/7/8/9/11/12
    Lists Should Be Equal    ${cells_status["NRCELL-2"]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-3"]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-51"]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-61"]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-21"]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-22"]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-23"]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-31"]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-32"]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-33"]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-41"]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-42"]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-43"]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-302"]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-303"]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-312"]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-313"]}    ${a_list}

Power on all RU
    Log to console    power on all ru
    Connect to gnb coam via ssl
    FOR    ${index}    IN    @{RU_INDEX_1313}
        Perform RU Power On    ru_index=${index}
    END

Restore PA
    Log to console    restor all RU
    gnb_classical_hangzhou.Get Initial Attenuation Values For RU    vendor=HBTE
    ${channels_to_modify}    create dictionary    5=0    6=0
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=&{channels_to_modify}    RU_id=0
    ${channels_to_modify}    create dictionary    3=0    4=0
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=&{channels_to_modify}    RU_id=1
    ${channels_to_modify}    create dictionary    9=0    10=0    11=0    12=0
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=&{channels_to_modify}    RU_id=2
    ${channels_to_modify}    create dictionary    1=0    2=0
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=&{channels_to_modify}    RU_id=6
    ${channels_to_modify}    create dictionary    7=0    8=0
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=&{channels_to_modify}    RU_id=12

Set PA for AZQS call
    Log to console    modify RU PA, keep only AZQS
    gnb_classical_hangzhou.Get Initial Attenuation Values For RU    vendor=HBTE
    ${channels_to_modify}    create dictionary    5=0    6=0
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=&{channels_to_modify}    RU_id=0
    ${channels_to_modify}    create dictionary    3=127    4=127
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=&{channels_to_modify}    RU_id=1
    ${channels_to_modify}    create dictionary    9=127    10=127    11=127    12=127
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=&{channels_to_modify}    RU_id=2
    ${channels_to_modify}    create dictionary    1=127    2=127
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=&{channels_to_modify}    RU_id=6
    ${channels_to_modify}    create dictionary    7=127    8=127
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=&{channels_to_modify}    RU_id=12