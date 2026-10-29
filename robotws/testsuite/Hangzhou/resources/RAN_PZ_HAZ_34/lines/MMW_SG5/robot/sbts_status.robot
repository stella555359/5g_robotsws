# @Time    : 2022/3/3 11:00
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : selenium_sbts.robot
# @Software: PyCharm
*** Settings ***
Documentation    This is common sbts status keywords
Library    taf.sbts.oam.coam.admin    WITH NAME    coam
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot

*** Keywords ***
Verify BTS OnAir Ready For L3call
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/08/14 11:18
    [Arguments]    ${wait_time}=10min    ${interval_time}=30s
    Wait Until Keyword Succeeds    ${wait_time}    ${interval_time}    Verify BTS All Cells Status Is Normal State
    ${gnb_type}    Get gNbType SA or NSA via rest api
    Run Keyword If    '${gnb_type}'=='NSA'
    ...    Wait Until Keyword Succeeds    ${wait_time}    ${interval_time}    COAM Check X2 link status from GNB

Verify gNB Is OnAir
    [Arguments]     ${connection}=GNB_OAM
    ${status}    taf.sbts.oam.coam.admin.get_bts_statuses    connection=${connection}
    Collections.Dictionary Should Contain Item    ${status}    proceduralState    OnAir
    ...   msg=proceduralState: ${status}[proceduralState]
    LOG TO CONSOLE    ${SPACE*2}gNB is OnAir.
    Sleep    1s

###    BB Status    ###
Verify BTS Single BB Status Is Normal
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/03/11 22:04
    [Arguments]    ${serial_number}    ${administrative_state}=Unlocked    ${operational_state}=enabled
    ...    ${procedural_status}=configured    ${usage_state}=Active    ${connection}=GNB_OAM
    ${hw_info}    coam.get_detected_hw_info    connection=${connection}
    @{list_BBs}    Set variable    ${hw_info['basebandModules']}
    FOR    ${bb_info}    IN    @{list_BBs}
        Continue For Loop If    '${bb_info['serialNumber']}'!='${serial_number}'
        Verify BTS Single BB Status    ${bb_info['status']}    ${administrative_state}    ${operational_state}
        ...    ${procedural_status}    ${usage_state}
    END

Verify BTS Single BB Status
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/03/11 22:04
    [Arguments]    ${bb_status}    ${administrative_state}=Unlocked    ${operational_state}=enabled
    ...    ${procedural_status}=configured    ${usage_state}=Active
    Should Be True    '${bb_status["administrativeState"]}'=='${administrative_state}'
    Should Be True    '${bb_status["operationalState"]}'=='${operational_state}'
    Should Be True    '${bb_status["proceduralStatus"]}'=='${procedural_status}'
    Should Be True    '${bb_status["usageState"]}'=='${usage_state}'

###    RU Status    ###
Verify BTS RUs Status Is Normal State
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    Verify BTS RUs Status Is RU Lock State    administrative_state=Unlocked

Verify BTS RUs Status Is BTS Block And RU Lock State
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    Verify BTS RUs Status Is RU Lock State

Verify BTS RUs Status Is RU Lock State
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${administrative_state}=Locked    ${operational_state}=enabled
    ...    ${procedural_status}=configured    ${connection}=GNB_OAM
    ${hw_info}    coam.get_detected_hw_info    connection=${connection}
    @{list_RUs}    Set variable    ${hw_info['radioModules']['rmod']}
    ${except_ru_status}    Create Dictionary    administrativeState=${administrative_state}
    ...    operationalState=${operational_state}
    ...    proceduralStatus=${procedural_status}
    FOR    ${ru_info}    IN    @{list_RUs}
        Verify BTS Target RU Status    ${ru_info['status']}    ${except_ru_status}
    END

Verify BTS Single RU Status Is Offline State
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/06/28 14:54
    [Arguments]    ${dist_name}    ${administrative_state}=Locked    ${operational_state}=disabled
    ...    ${availability_status}=off line    ${procedural_status}=configured    ${connection}=GNB_OAM
    ${hw_info}    coam.get_detected_hw_info    connection=${connection}
    @{list_RUs}    Set variable    ${hw_info['radioModules']['rmod']}
    ${except_ru_status}    Create Dictionary    administrativeState=${administrative_state}
    ...    operationalState=${operational_state}
    ...    availabilityStatus=${availability_status}
    ...    proceduralStatus=${procedural_status}
    FOR    ${ru_info}    IN    @{list_RUs}
        Continue For Loop If    '${ru_info['id']['configuration']}'!='${dist_name}'
        Verify BTS Target RU Status    ${ru_info['status']}    ${except_ru_status}
    END

Verify BTS Single RU Status Is Reset State
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/01/26 10:12
    [Arguments]    ${dist_name}    ${administrative_state}=Unlocked    ${operational_state}=disabled
    ...    ${availability_status}=off line    ${procedural_status}=initializing    ${connection}=GNB_OAM
    Verify BTS Single RU Status Is Offline State    dist_name=${dist_name}
    ...    administrative_state=${administrative_state}    operational_state=${operational_state}
    ...    availability_status=${availability_status}    procedural_status=${procedural_status}
    ...    connection=${connection}

Verify BTS Single RU Status Is Lock State
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/03/11 22:04
    [Arguments]    ${dist_name}    ${administrative_state}=Locked    ${operational_state}=enabled
    ...    ${procedural_status}=configured    ${connection}=GNB_OAM
    ${hw_info}    coam.get_detected_hw_info    connection=${connection}
    @{list_RUs}    Set variable    ${hw_info['radioModules']['rmod']}
    ${except_ru_status}    Create Dictionary    administrativeState=${administrative_state}
    ...    operationalState=${operational_state}
    ...    proceduralStatus=${procedural_status}
    FOR    ${ru_info}    IN    @{list_RUs}
        Continue For Loop If    '${ru_info['id']['configuration']}'!='${dist_name}'
        Verify BTS Target RU Status    ${ru_info['status']}    ${except_ru_status}
    END

Verify BTS RUs Status Is BTS Block State
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/07/10 11:04
    [Arguments]    ${administrative_state}=Unlocked    ${operational_state}=enabled
    ...    ${procedural_status}=configured    ${usageState}=Idle    ${connection}=GNB_OAM
    ${hw_info}    coam.get_detected_hw_info    connection=${connection}
    @{list_RUs}    Set variable    ${hw_info['radioModules']['rmod']}
    ${except_ru_status}    Create Dictionary    administrativeState=${administrative_state}
    ...    operationalState=${operational_state}
    ...    proceduralStatus=${procedural_status}
    ...    usageState=${usageState}
    FOR    ${ru_info}    IN    @{list_RUs}
        Verify BTS Target RU Status    ${ru_info['status']}    ${except_ru_status}
    END

Verify BTS Single RU Status Is Power Off State
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/09/02 10:48
    [Arguments]    ${ru_index}    ${administrative_state}=Unlocked
    ...    ${availability_status}=not installed    ${operational_state}=disabled
    ...    ${procedural_status}=not initialized    ${usage_state}=Idle    ${connection}=GNB_OAM
    ${hw_info}    coam.get_detected_hw_info    connection=${connection}
    @{list_RUs}    Set variable    ${hw_info['radioModules']['rmod']}
    ${except_ru_status}    Create Dictionary    administrativeState=${administrative_state}
    ...    availabilityStatus=${availability_status}
    ...    operationalState=${operational_state}
    ...    proceduralStatus=${procedural_status}
    ...    usageState=${usage_state}
    FOR    ${ru_info}    IN    @{list_RUs}
        Continue For Loop If    '${ru_info['id']['configuration']}'!='MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-${ru_index}'
        Verify BTS Target RU Status    ${ru_info['status']}    ${except_ru_status}
    END

Verify BTS Single RU Status Is Normal State
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/09/02 13:27
    [Arguments]    ${ru_index}    ${administrative_state}=Unlocked
    ...    ${operational_state}=enabled
    ...    ${procedural_status}=configured    ${usage_state}=Active    ${connection}=GNB_OAM
    ${hw_info}    coam.get_detected_hw_info    connection=${connection}
    @{list_RUs}    Set variable    ${hw_info['radioModules']['rmod']}
    ${except_ru_status}    Create Dictionary    administrativeState=${administrative_state}
    ...    operationalState=${operational_state}
    ...    proceduralStatus=${procedural_status}
    ...    usageState=${usage_state}
    FOR    ${ru_info}    IN    @{list_RUs}
        Continue For Loop If    '${ru_info['id']['configuration']}'!='MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-${ru_index}'
        Verify BTS Target RU Status    ${ru_info['status']}    ${except_ru_status}
    END

Verify BTS Target RU Status
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${current_ru_status}    ${except_ru_status}
    FOR    ${status_name}    IN    @{except_ru_status}
        Should Be Equal As Strings    ${current_ru_status['${status_name}']}    ${except_ru_status['${status_name}']}
    END

_Reset And Check Success RF Coam
    [Documentation]   Author: xudong.1.li@nokia-sbell.com
    ...               Description:Reset RU and check if success
    ...               ${ru_index}:value from MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1/2/3.....
    [Arguments]  ${MRBTS_ID}    ${timeout}=600    ${ru_index}=1   ${connection}=GNB_OAM
    Connect to gnb coam via ssl    connection=${connection}
    ${output}    coam.reset_unit    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-${ru_index}
    ...    force_radio_reset=${True}    timeout=${timeout}    connection=${connection}
    ${result}    set variable    ${output[1]['resultNode']['parameters']['status']}
    Should Be Equal As Strings  ${result}    Succeeded
    LOG TO CONSOLE    ${\n}======RU Reset Succeeded.
    [Return]  ${result}

###    Cell Status    ###
Verify BTS Single RU's Cells Status Is Reset State
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/09/02 15:55
    [Arguments]    ${ru_index}=1    ${connection}=GNB_OAM
    ${hw_info}    coam.get_detected_hw_info    connection=${connection}
    @{list_RUs}    Set variable    ${hw_info['radioModules']['rmod']}
    FOR    ${ru_info}    IN    @{list_RUs}
        Continue For Loop If    '${ru_info['id']['configuration']}'!='MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-${ru_index}'
        FOR    ${carrier}    IN    @{ru_info["carrierList"]}
            ${cell_distname}    ${other}    Split String From Right    ${carrier["id"]["configuration"]}    /    1
            Verify BTS Single Cell Status Is Reset State    dist_name=${cell_distname}
        END
    END

Verify BTS Single Cell Status Is Reset State
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/09/02 16:19
    [Arguments]    ${dist_name}    ${availability_status}=failed
    ...    ${cell_type}=nr    ${connection}=GNB_OAM
    ${except_cell_status}    Create Dictionary    availabilityStatus=${availability_status}
    ${cells_info}    coam.get_cells_info    cell_type=${cell_type}    connection=${connection}
    FOR  ${cell_info}  IN  @{cells_info}
        ${passed}    Run Keyword And Return Status    Should Be Equal As Strings
        ...    ${dist_name}    ${cell_info['id']['configuration']}
        Run Keyword If    ${passed}    Verify BTS Target Cell Status    ${cell_info['status']}    ${except_cell_status}
    END

Verify BTS Single RU's Cells Status Is RU Lock State
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/09/08 15:01
    [Arguments]    ${ru_index}=1    ${connection}=GNB_OAM
    ${hw_info}    coam.get_detected_hw_info    connection=${connection}
    @{list_RUs}    Set variable    ${hw_info['radioModules']['rmod']}
    FOR    ${ru_info}    IN    @{list_RUs}
        Continue For Loop If    '${ru_info['id']['configuration']}'!='MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-${ru_index}'
        FOR    ${carrier}    IN    @{ru_info["carrierList"]}
            ${cell_distname}    ${other}    Split String From Right    ${carrier["id"]["configuration"]}    /    1
            Verify BTS Single Cell Status Is RU Lock State    dist_name=${cell_distname}
        END
    END

Verify BTS Single Cell Status Is RU Lock State
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/09/08 15:02
    [Arguments]    ${dist_name}    ${administrative_state}=Unlocked
    ...    ${availability_status}=dependency
    ...    ${operational_state}=disabled
    ...    ${cell_type}=nr    ${connection}=GNB_OAM
    ${except_cell_status}    Create Dictionary
    ...    administrativeState=${administrative_state}
    ...    availabilityStatus=${availability_status}
    ...    operationalState=${operational_state}
    ${cells_info}    coam.get_cells_info    cell_type=${cell_type}    connection=${connection}
    FOR  ${cell_info}  IN  @{cells_info}
        ${passed}    Run Keyword And Return Status    Should Be Equal As Strings
        ...    ${dist_name}    ${cell_info['id']['configuration']}
        Run Keyword If    ${passed}    Verify BTS Target Cell Status    ${cell_info['status']}    ${except_cell_status}
    END

Verify BTS Single Cell Status Is Normal State
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${dist_name}    ${administrative_state}=Unlocked
    ...    ${blocking_state}=Unblocked    ${operational_state}=enabled
    ...    ${cell_type}=nr    ${connection}=GNB_OAM
    ${except_cell_status}    Create Dictionary    administrativeState=${administrative_state}
    ...    blockingState=${blocking_state}
    ...    operationalState=${operational_state}
    ${cells_info}    coam.get_cells_info    cell_type=${cell_type}    connection=${connection}
    FOR  ${cell_info}  IN  @{cells_info}
        ${passed}    Run Keyword And Return Status    Should Be Equal As Strings
        ...    ${dist_name}    ${cell_info['id']['configuration']}
        Run Keyword If    ${passed}    Verify BTS Target Cell Status    ${cell_info['status']}    ${except_cell_status}
    END

Verify BTS Single Cell Status Is Block State
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/09/03 17:09
    [Arguments]    ${dist_name}
    ...    ${operational_state}=disabled
    ...    ${availability_status}=off line
    ...    ${blocking_state}=Blocked
    ...    ${cell_type}=nr    ${connection}=GNB_OAM
    ${except_cell_status}    Create Dictionary    operationalState=${operational_state}
    ...    availabilityStatus=${availability_status}
    ...    blockingState=${blocking_state}
    ${cells_info}    coam.get_cells_info    cell_type=${cell_type}    connection=${connection}
    FOR  ${cell_info}  IN  @{cells_info}
        ${passed}    Run Keyword And Return Status    Should Be Equal As Strings
        ...    ${dist_name}    ${cell_info['id']['configuration']}
        Run Keyword If    ${passed}    Verify BTS Target Cell Status    ${cell_info['status']}    ${except_cell_status}
    END

Verify BTS Single Cell Status Is Locked State
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/03/11 10:31
    [Arguments]    ${dist_name}    ${administrative_state}=Locked    ${availabilityStatus}=off line
    ...    ${blocking_state}=Unblocked    ${operational_state}=disabled
    ...    ${cell_type}=nr    ${connection}=GNB_OAM
    ${except_cell_status}    Create Dictionary    administrativeState=${administrative_state}
    ...    availabilityStatus=${availabilityStatus}
    ...    blockingState=${blocking_state}
    ...    operationalState=${operational_state}
    ${cells_info}    coam.get_cells_info    cell_type=${cell_type}    connection=${connection}
    FOR  ${cell_info}  IN  @{cells_info}
        ${passed}    Run Keyword And Return Status    Should Be Equal As Strings
        ...    ${dist_name}    ${cell_info['id']['configuration']}
        Run Keyword If    ${passed}    Verify BTS Target Cell Status    ${cell_info['status']}    ${except_cell_status}
    END

Verify BTS 5G Cells Status Is Normal State
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    The availabilityStatus not exist in cell status when cell is unblock
    [Arguments]    ${administrative_state}=Unlocked
    ...    ${blocking_state}=Unblocked    ${operational_state}=enabled
    ${except_cell_status}    Create Dictionary    administrativeState=${administrative_state}
    ...    blockingState=${blocking_state}
    ...    operationalState=${operational_state}
    Verify BTS Cells Status    except_cell_status=${except_cell_status}

Verify BTS All Cells Status Is Normal State
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/07/10 10:19
    Verify BTS 5G Cells Status Is Normal State
    Verify BTS 4G Cells Status Is Normal State

Verify BTS 4G Cells Status Is Normal State
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    The availabilityStatus not exist in cell status when cell is unblock
    [Arguments]    ${administrative_state}=unlocked
    ...    ${blocking_state}=Unblocked    ${operational_state}=enabled
    ${except_cell_status}    Create Dictionary    administrativeState=${administrative_state}
    ...    blockingState=${blocking_state}
    ...    operationalState=${operational_state}
    Verify BTS Cells Status    except_cell_status=${except_cell_status}    cell_type=lte

Verify All 4G and 3G Cells are OnAir
    [Documentation]    Author:chun.li@nokia-sbell.com
    ...    Verify all 4G and 3G cells should be onair
    Verify BTS 4G Cells Status Is Normal State
    ${WCELS_NORAML_STATUS}    Create Dictionary    blockingState=Unblocked    operationalState=enabled
    Verify BTS Cells Status    except_cell_status=${WCELS_NORAML_STATUS}    cell_type=wcdma

Verify BTS 4G Cells Status Is Locked State
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    The availabilityStatus not exist in cell status when cell is unblock
    [Arguments]    ${administrative_state}=locked
    ...    ${blocking_state}=Unblocked    ${operational_state}=disabled
    ...    ${availabilityStatus}=off line    ${usageState}=Idle
    ${except_cell_status}    Create Dictionary    administrativeState=${administrative_state}
    ...    blockingState=${blocking_state}
    ...    operationalState=${operational_state}
    ...    availabilityStatus=${availabilityStatus}
    ...    usageState=${usageState}
    Verify BTS Cells Status    except_cell_status=${except_cell_status}    cell_type=lte

Verify BTS 5G Cells Status Is Cell Lock State
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    Verify BTS 5G Cells Status Is BTS Block State    administrative_state=Locked    blocking_state=Unblocked

Verify BTS 5G Cells Status Is Cell Reset State
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${administrative_state}=Unlocked    ${availability_status}=off line
    ...    ${blocking_state}=Unblocked    ${operational_state}=disabled
    ${except_cell_status}    Create Dictionary    administrativeState=${administrative_state}
    ...    availabilityStatus=${availability_status}
    ...    blockingState=${blocking_state}
    ...    operationalState=${operational_state}
    Verify BTS Cells Status    except_cell_status=${except_cell_status}

Verify BTS 5G Cells Status Is BTS Block State
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${administrative_state}=Unlocked    ${availability_status}=off line
    ...    ${blocking_state}=Blocked    ${operational_state}=disabled
    ${except_cell_status}    Create Dictionary    administrativeState=${administrative_state}
    ...    availabilityStatus=${availability_status}
    ...    blockingState=${blocking_state}
    ...    operationalState=${operational_state}
    Verify BTS Cells Status    except_cell_status=${except_cell_status}

Verify BTS 5G Cells Status Is RU Lock State
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${administrative_state}=Unlocked    ${availability_status}=dependency
    ...    ${blocking_state}=Unblocked    ${operational_state}=disabled
    ...    ${procedural_status}=configured
    ${except_cell_status}    Create Dictionary    administrativeState=${administrative_state}
    ...    availabilityStatus=${availability_status}
    ...    blockingState=${blocking_state}
    ...    operationalState=${operational_state}
    ...    proceduralStatus=${procedural_status}
    Verify BTS Cells Status    except_cell_status=${except_cell_status}

Verify BTS 5G Cells Status Is BTS Block And RU Lock State
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${availability_status}=dependency
    Verify BTS 5G Cells Status Is RU Lock State    availability_status=${availability_status}    blocking_state=Blocked

Verify BTS 5G Cells Status Is BTS Unblock And RU Lock State
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    Verify BTS 5G Cells Status Is RU Lock State    procedural_status=initializing

Verify BTS 5G FDD Cells Status Normal
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/01/23 13:20
    [Arguments]    ${cell_type}=nr    ${connection}=GNB_OAM
    ${except_cell_status}    Create Dictionary    administrativeState=Unlocked
    ...    blockingState=Unblocked    operationalState=enabled
    Connect to gnb coam via ssl
    ${cells_info}    coam.get_cells_info    cell_type=${cell_type}    connection=${connection}
    FOR  ${cell_info}  IN  @{cells_info}
        Continue For Loop If    '${cell_info['technology']}'=='TDD'
        Verify BTS Target Cell Status    ${cell_info['status']}    ${except_cell_status}
    END

Verify BTS Cells Status
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    except_cell_status :{
    ...    administrativeState: Unlocked
    ...    availabilityStatus: -
    ...    blockingState: Unblocked
    ...    operationalState: enabled
    ...    }
    [Arguments]    ${except_cell_status}    ${cell_type}=nr    ${connection}=GNB_OAM
    Connect to gnb coam via ssl
    ${cells_info}    coam.get_cells_info    cell_type=${cell_type}    connection=${connection}
    FOR  ${cell_info}  IN  @{cells_info}
        Verify BTS Target Cell Status    ${cell_info['status']}    ${except_cell_status}
    END

Verify BTS Target Cell Status
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${current_cell_status}    ${except_cell_status}
    FOR    ${status_name}    IN    @{except_cell_status}
        Should Be Equal As Strings    ${current_cell_status['${status_name}']}    ${except_cell_status['${status_name}']}
    END

Verify BTS Cells Enable Number
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${enable_number}    ${connection}=GNB_OAM
    ${cells_info}    coam.get_cells_info    connection=${connection}
    ${enable_cells_num}    Set Variable    0
    FOR    ${cell_group}    IN    @{cells_info}
         ${opreational_state}    run keyword and return status    Should contain
         ...    ${cell_group['status']['operationalState']}    Enabled    ignore_case=True
         ${enable_cells_num}    run keyword if    ${opreational_state}    Evaluate    ${enable_cells_num} + 1
         ...    ELSE    Evaluate    ${enable_cells_num} + 0
    END
    Should Be Equal As Numbers    ${enable_cells_num}    ${enable_number}

_Verify Appoint CellType Cells Status Are Normal State
    [Documentation]    Author: xudong.1.li@nokia-sbell.com
    ...                Description: copy from CI_commssion.Verify all cells should be Online
    ...                ${cell_type}: add cell_type to choose,can be lte/nr/gsm/wcdma
    [Arguments]    ${cell_type}=nr    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    connection=${connection}
    ${cells_info}   taf.sbts.oam.coam.admin.get_cells_info    cell_type=${cell_type}    connection=${connection}
    FOR  ${cell_group}  IN   @{cells_info}
         Should contain    ${cell_group['status']['operationalState']}    Enabled    ignore_case=True
         Should contain    ${cell_group['status']['administrativeState']}    Unlocked    ignore_case=True
         Should contain    ${cell_group['status']['blockingState']}    Unblocked    ignore_case=True
         ${status_keys}    Collections.get dictionary keys    ${cell_group['status']}
         ${availability_status}    run keyword and return status    should contain
         ...    ${status_keys}    availabilityStatus    ignore_case=True
         run keyword if    ${availability_status}    Should contain
         ...    ${cell_group['status']['availabilityStatus']}    Online    ignore_case=True
    END
    LOG TO CONSOLE    ${\n}${SPACE*2}======${cell_type} cells are Online.
   # [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Get Cells Info By Rmod
    [Documentation]    v1.0 initial draft by yinhua.zhang@nokia-sbell.com
    ...    v1.0 the function is to get all cells configured under specific rmod
    ...    v1.0 rmod is specific rmod; RAT_list is all RATs configured in BTS
    [Arguments]    ${rmod}    ${RAT_list}    ${all_cells_info}=@{EMPTY}    ${connection}=GNB_OAM
    @{rmod_cells_info}    Create List

    FOR    ${rat}    IN    @{RAT_list}
        ${cells_info}   coam.get_cells_info    cell_type=${rat}    connection=${connection}
        ${all_cells_info}    Combine Lists   ${all_cells_info}    ${cells_info}
    END
    FOR    ${each_cell_info}    IN    @{all_cells_info}
        Run Keyword If    '${rmod}' in '${each_cell_info["carrierList"][0]["antennaLineId"]["configuration"]}'
        ...    Append To List    ${rmod_cells_info}    ${each_cell_info}
    END
    [Return]    ${rmod_cells_info}

Verify Specific Cells Status
    [Arguments]    ${specific_cells_info}    ${administrative_state}=Unlocked
    ...    ${blocking_state}=Unblocked    ${operational_state}=enabled
    ${expected_cell_status}    Create Dictionary    administrativeState=${administrative_state}
    ...    blockingState=${blocking_state}
    ...    operationalState=${operational_state}
    FOR  ${cell_info}  IN  @{specific_cells_info}
        Verify BTS Target Cell Status    ${cell_info['status']}    ${expected_cell_status}
    END

Verify Cells Of Specified Rmod On Air
    [Documentation]    v1.0 initial draft by yinhua.zhang@nokia
    ...    ${RAT_list} is the set of RATs configured in BTS
    [Arguments]    ${rmod}    ${RAT_list}    ${administrative_state}=Unlocked    ${connection}=GNB_OAM
    ${rmod_cells_info}    Get Cells Info By Rmod    rmod=${rmod}
    ...   RAT_list=${RAT_list}    connection=${connection}
    Verify Specific Cells Status    administrative_state=${administrative_state}
    ...    specific_cells_info=${rmod_cells_info}
