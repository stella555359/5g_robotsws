*** Settings ***
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/SG2_Common_setup_teardown.robot

Documentation
...   author: Chen Tong
...   contact: tong.chen@nokia-sbell.com
...   squad group: SG_02


*** Variables ***
${DURATION}    6000

${UL_THROUGHPUT}    150Mbits/sec
${DL_THROUGHPUT}    500Mbits/sec

*** Keywords ***
CB011016 COAM update lbpsPeriod
    [Arguments]    ${lbpsPeriod}
    Connect to gnb coam via ssl
    COAM Update several parameters via rest api    parameters_to_update_via_api=${lbpsPeriod}
    COAM Teardown gnb connections

CB011016 Check BTS energySavingState
    [Arguments]    ${energySavingState}    ${timeOut}=45s
    Sleep    ${timeOut}
    ${cell_list}    coam.get_cell_list    connection=GNB_OAM
    ${cell_list}    Set Variable    ${cell_list['cells']['nr']}
    ${cell_num}    Get Length     ${cell_list}
    FOR    ${index}    IN RANGE    ${cell_num}
        ${cell_technology}    Set Variable    ${cell_list[${index}]['technology']}
        Continue For Loop If    "${cell_technology}" == "TDD"
        should be equal    ${energySavingState[${cell_list[${index}]['globalCellId']}-1]}    ${cell_list[${index}]['energySavingState']}
    END

UE Start Traffic and Check BTS energySavingState
    [Arguments]    ${energySavingState}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${1}
    ${ue_index_list}    Create List    ${1}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${1}    ui_version=M40PUI1.1
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${1}
#    ${5Grach_ed}    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${1}
#    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${1}
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${UL_THROUGHPUT}
    ...                       duration=${DURATION}    ue_index=${1}
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${DL_THROUGHPUT}
    ...                       duration=${DURATION}    ue_index=${1}
    Sleep    20s
    CB011016 Check BTS energySavingState    energySavingState=@{energySavingState}    timeOut=1min
    [Teardown]    Ue Stop DL UL Traffic and Detach    ue_index_list=${ue_index_list}

CB011016 Get PM Counter to Compare
    ${counter_value}    get_pm_counter_values    counter_id=M40003C2    connection=GNB_OAM    dic_path=${CB011016_Counter_Path[0]}
    Should Be True    ${counter_value[0]} < 2200
