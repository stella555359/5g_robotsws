*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${FULL_SCF}    iphy_file=${IPHY_FILE}
#...               AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}
#...               AND    Suite Setup Start WTS And Check OnAir
#Suite Teardown    Common Suite Teardown
#Test Setup        Common Test Setup
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    Owner_jshen
#...               SBTS00    CN1_SQ6    CB009169    RAN_5G    RAN_5G_TDD    CRT
#Resource          Resources/CB009169_Common.robot
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#
#*** Variables ***
#${SCF_PATH}                       ${CURDIR}/Config
#${FULL_SCF}                       CB009169_Ba1401_scfc.xml
#${IPHY_FILE}                      ${CURDIR}/Resources/wts/iphy_4F_2T_Ba1603.xml
#${WTS_LOCAL}                      ${CURDIR}/Resources/wts
#${WTS_CFG}                        CB009169_Ba1401.cfg
#${1T_3F_DL_DATA}                  1400
#${1T_3F_UL_DATA}                  160
#@{1T_3F_EXP_DL_TPUT_LIST}         280    50    50    50
#@{1T_3F_EXP_UL_TPUT_LIST}         10    10
#@{4CC_PCELL_ID_LIST}              52
#@{4CC_SCELL_PHYSICALID_1}         50    53    54
#@{4CC_SCELL_PHYSICALID_LIST_1}    ${4CC_SCELL_PHYSICALID_1}
#@{4CC_UE_LIST}                    3
#${LOW_A1THRESHOLD}                95
#${HIGH_A1THRESHOLD}               105
#
#*** Test Cases ***
#CB009169_ET_BA1401_2T_2F_SingleUE_FDD_Scell_Swap_A6_Without_ULCA
#    SA Multi UE Attach With Scell A1 Addition    ${4CC_UE_LIST}    ${4CC_PCELL_ID_LIST}
#    ...    ${4CC_SCELL_PHYSICALID_LIST_1}    ${LOW_A1THRESHOLD}    4
#    Triger UE Reestablishment    ${4CC_UE_LIST[0]}    2    3
#    Trigger A1 Scell Addition    ${4CC_UE_LIST[0]}    ${LOW_A1THRESHOLD}    52    1
#    SA Multi UE Start DL And UL Traffic    ${4CC_UE_LIST}    ${1T_3F_DL_DATA}    ${1T_3F_UL_DATA}
#    Sleep    10s    reason=wair for data is stable
#    Check Multi UE DLCA And 2CCULCA L1 Cell Tput    ${4CC_UE_LIST}    ${1T_3F_EXP_UL_TPUT_LIST}    ${1T_3F_EXP_DL_TPUT_LIST}    4
#    Trigger A6 Event For Scell Swap    ${4CC_UE_LIST[0]}    51    1    55    75    3
#    Check SCellIndex Of ULCA UE From Tput    ${4CC_UE_LIST[0]}    2
#    Trigger A1 Scell Addition    ${4CC_UE_LIST[0]}    ${HIGH_A1THRESHOLD}    52    2
#    SA 5G Detach    ${4CC_UE_LIST[0]}
#
#*** Keywords ***
#Trigger A6 Event For Scell Swap
#    [Arguments]    ${ue_id}    ${phycell_id}    ${scell_index}    ${scell_rsrp}=11    ${nrsrp_nr}=80    ${meas_id}=${EMPTY}
#    Log To Console    Trigger A6 Event For Scell Swap
#    ${meas_id_from_egate}    Get Measurement Id From Egate Log    A6
#    ${measida6}    Set Variable If    '${meas_id}'=='${EMPTY}'    ${meas_id_from_egate}    ${meas_id}
#    ${pattern}    Set Variable    rrcReconfigurationComplete
#    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${measida6} event=A6 scell=${scell_index}
#    ...    scell_rsrp=${scell_rsrp} phycell_id=${phycell_id} nrsrp_nr=${nrsrp_nr}
#    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    ${cmd}    pass_regexp=${pattern}    timeout=2min
#    Sleep    20s    reason=wait for traffic stable
