# @Time    : 2025/1/22 10:57
# @Author  : Echo.1.Xu
# @Email   : echo.xu@nokia-sbell.com
# @Group   : NSB MN RAN RD VRF HAZ3 5
# @File    : CB009514_common_keywords.robot
# @Software: PyCharm
# @Doc     : This is common robot keywords template
*** Settings ***
Documentation
...    Feature CB009514

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot

*** Keywords ***
CB009514 Precondition Delta Json
    [Documentation]    Author: echo.xu@nokia-sbell.com
    ...    Init Define: 2025/01/22
    ${cur_scf}    COAM Download scf from cluster    ${TS_LOG_PATH_BASE}

#    generate_delta_jsons_from_3_scf    ${cur_scf}    ${COMMON_SCF}    ${NO_RU13_SCF}
#    ...    ${REMOVE_RU13_AND_CELL}    ${CREATE_RU13_AND_CELL}
    generate_add_json_base_delete_json_and_cur_scf    ${cur_scf}    ${REMOVE_RU13_AND_CELL}    ${CREATE_RU13_AND_CELL}

CB009514 Precondition Common Delete
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

Verify Cell expect 72e History Status Normal
    [Documentation]    Author: echo.xu@nokia-sbell.com
    ...    Init Define: 2025/1/23 11:21
    ${cells_status}    get_cells_history_status
    ${cells_name}    Get Dictionary Keys    ${cells_status}
    ${a_i_a_list}    Create List    Active    Idle    Active
    ${i_a_list}    Create List    Idle    Active
    ${a_list}    Create List    Active
    Lists Should Be Equal    ${cells_status["NRCELL-2"]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-25"]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-26"]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-27"]}    ${a_list}
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

Verify Cell History Status Normal For Case103_STEP3
    [Documentation]    Author: echo.xu@nokia-sbell.com
    ...    Init Define: 2025/1/23 11:21
    ${cells_status}    get_cells_history_status
    ${cells_name}    Get Dictionary Keys    ${cells_status}
    ${a_i_a_list}    Create List    Active    Idle    Active
    ${i_a_list}    Create List    Idle    Active
    ${a_list}    Create List    Active
    ${i_list}    Create List    Idle
    Lists Should Be Equal    ${cells_status["NRCELL-2"]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-3"]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-4"]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-5"]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-21"]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-22"]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-23"]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-25"]}    ${i_a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-26"]}    ${i_a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-27"]}    ${i_a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-28"]}    ${i_a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-29"]}    ${i_a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-31"]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-32"]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-33"]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-302"]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-312"]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-303"]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-313"]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-41"]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-42"]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-43"]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-51"]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-61"]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-13"]}    ${i_list}

Verify Cell History Status Normal For Case103_STEP4
    [Documentation]    Author: echo.xu@nokia-sbell.com
    ...    Init Define: 2025/1/23 11:21
    ${cells_status}    get_cells_history_status
    ${cells_name}    Get Dictionary Keys    ${cells_status}
    ${a_i_a_list}    Create List    Active    Idle    Active
    ${i_a_list}    Create List    Idle    Active
    ${a_list}    Create List    Active
    ${i_list}    Create List    Idle
    Lists Should Be Equal    ${cells_status["NRCELL-2"]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-3"]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-4"]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-5"]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-21"]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-22"]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-23"]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-25"]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-26"]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-27"]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-28"][-2:]}    ${i_a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-29"][-2:]}    ${i_a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-31"]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-32"]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-33"]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-302"]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-312"]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-303"]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-313"]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-41"]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-42"]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-43"]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-51"]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-61"]}    ${a_list}
    Lists Should Be Equal    ${cells_status["NRCELL-13"]}    ${i_a_list}

Power On For Restore RU
    [Documentation]    Author: echo.xu@nokia-sbell.com
    ...    Init Define: 2025/01/23
    [Arguments]    @{RU_INDEX_2RU}
    Log To Console    Restore ALL RU
    Connect to gnb coam via ssl
    FOR    ${index}    IN    @{RU_INDEX_2RU}
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

Set PA for RU-13 CALL
    Log to console    Set PA for RU13 CALL
    gnb_classical_hangzhou.Get Initial Attenuation Values For RU    vendor=HBTE
    ${channels_to_modify}    create dictionary    5=127    6=127
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=&{channels_to_modify}    RU_id=0
    ${channels_to_modify}    create dictionary    3=127    4=127
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=&{channels_to_modify}    RU_id=1
    ${channels_to_modify}    create dictionary    9=127    10=127    11=127    12=127
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=&{channels_to_modify}    RU_id=2
    ${channels_to_modify}    create dictionary    1=127    2=127
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=&{channels_to_modify}    RU_id=6
    ${channels_to_modify}    create dictionary    7=0    8=0
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=&{channels_to_modify}    RU_id=12