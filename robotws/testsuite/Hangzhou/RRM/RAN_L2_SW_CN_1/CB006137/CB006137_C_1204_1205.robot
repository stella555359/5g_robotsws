*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${SCF_FILE}    swconfig_param=${SWCONF}    iphy_file=${IPHY_FILE}
#...               AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#Suite Teardown    Common Suite Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    CRT    RAN_5G    RAN_5G_TDD    Owner_molyang
#...               CN1_SG6    CB006137    SBTS00
#Resource          ../CB008015/resources/CB008015_lib.robot
#Resource          resources/6137_BO_lib.robot
#
#*** Variables ***
#${SWCONF}                   0x58067c=0x1;0x580497=1;
#${SCF_PATH}                 ${CURDIR}/config
#${SCF_FILE}                 Configuration_6137_C_4F_2T_1204_1205_scf.xml
#${IPHY_FILE}                ${CURDIR}/config/WTS/iphy_CB006137_C_4F_2T_1204_1205.xml
#${LOCAL_WTS_DIR}            ${CURDIR}/config/WTS
#${WTS_CFG}                  CB006137_C_1204_1205.cfg
#${PCELL_ID}                 51
#${UE_ID}                    1
#@{SCELL_PHYSICALID_LIST}    50    52    54
#${A1THRESHOLD}              90
#${DL_CC_NUM}                4
#${PDU_ID}                   1
#@{SCELL_INDEX_LIST1}        0    1    2    3
#@{SCELL_INDEX_LIST2}        0    2    3    4
#@{SCELL_INDEX_LIST3}        0    1    3    4
#@{CELL_TPUT_LIST1}          92    92    440    92
#@{CELL_TPUT_LIST2}          92    440    92    92
#@{CELL_TPUT_LIST3}          92    92    92    440
#
#*** Test Cases ***
#CB006137_ET_C1204_F_F_F_T_A6_Based_Scell_With_UL_CA_Swap_Rsrp
#    [Setup]    Run Keywords    Suite Setup Start WTS And Check OnAir
#    ...    AND    Common Test Setup
#    SA Attach    ${UE_ID}
#    Trigger A1 Scell Addition    ${UE_ID}    srsrp_nr=${A1THRESHOLD}    phycell_id=${PCELL_ID}
#    Check SA All Scell PhysicalID With UE ID    ${UE_ID}    ${SCELL_PHYSICALID_LIST}    ${DL_CC_NUM}
#    Start SA UE Big DL Traffic Internal    ${UE_ID}    800
#    SA Start UL Traffic Internal    ${UE_ID}    ${PDU_ID}    120
#    Sleep    20s    #wait for traffic stable
#    Display Multi UE Throughput    ${UE_ID}
#    Verify DL4CC Tput Within Range    ${UE_ID}    ${SCELL_INDEX_LIST1}    ${CELL_TPUT_LIST1}
#    Verify UL2CC Tput Within Range    ${UE_ID}    38    51    ${DL_CC_NUM}
#    Trigger A6 Event For Scell Swap    ${UE_ID}    4    1    53
#    Display Multi UE Throughput    ${UE_ID}
#    Verify DL4CC Tput Within Range    ${UE_ID}    ${SCELL_INDEX_LIST2}    ${CELL_TPUT_LIST2}
#    Verify UL2CC Tput Within Range    ${UE_ID}    38    51    ${DL_CC_NUM}
#    [Teardown]    Run Keywords    Common Test Teardown    detach_ue_id=${UE_ID}
#    ...    AND    Stop Edaemon Egate
#    ...    AND    Reboot TL And Check Configured
#
#CB006137_ET_C1205_F_F_F_T_A6_Based_Scell_without_UL_CA_Swap_Rsrp
#    [Setup]    Run Keywords    Suite Setup Start WTS And Check OnAir
#    ...    AND    Common Test Setup
#    SA Attach    ${UE_ID}
#    Trigger A1 Scell Addition    ${UE_ID}    srsrp_nr=${A1THRESHOLD}    phycell_id=${PCELL_ID}
#    Check SA All Scell PhysicalID With UE ID    ${UE_ID}    ${SCELL_PHYSICALID_LIST}    ${DL_CC_NUM}
#    Start SA UE Big DL Traffic Internal    ${UE_ID}    800
#    SA Start UL Traffic Internal    ${UE_ID}    ${PDU_ID}    120
#    Sleep    20s    #wait for traffic stable
#    Display Multi UE Throughput    ${UE_ID}
#    Verify DL4CC Tput Within Range    ${UE_ID}    ${SCELL_INDEX_LIST1}    ${CELL_TPUT_LIST1}
#    Verify UL2CC Tput Within Range    ${UE_ID}    38    51    ${DL_CC_NUM}
#    Trigger A6 Event For Scell Swap    ${UE_ID}    5    2    55
#    Display Multi UE Throughput    ${UE_ID}
#    Verify DL4CC Tput Within Range    ${UE_ID}    ${SCELL_INDEX_LIST3}    ${CELL_TPUT_LIST3}
#    Verify UL2CC Tput Within Range    ${UE_ID}    38    51    ${DL_CC_NUM}
#    [Teardown]    Test Teardown Recover Env
#
#*** Keywords ***
#Trigger A6 Event For Scell Swap
#    [Arguments]    ${UE_ID}    ${meas_id}    ${scell_index}    ${target_scell_id}
#    Log To Console    Trigger A6 Event For Scell Swap
#    ${pattern}    Set Variable    SCellIndex \\d activated successfully at airphone
#    ${cmd}    Catenate    ue_measurement_send_nr id=${UE_ID} meas_id=${meas_id} event=A6
#    ...    scell=${scell_index} scell_rsrp=60 phycell_id=${target_scell_id} nrsrp_nr=70
#    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    ${cmd}    pass_regexp=${pattern}    timeout=2min
#    Sleep    20s    reason=wait for traffic stable
#
#Verify DL4CC Tput Within Range
#    [Arguments]    ${UE_ID}    ${scell_index_list}    ${cell_tput_list}
#    FOR    ${id}    ${cell_tput}    IN ZIP    ${scell_index_list}    ${cell_tput_list}
#    \    ${cell_type}    Set Variable If    '${id}'=='0'    pcell    scell
#    \    ${scell_dl_tput}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=dl    cell_type=${cell_type}    scell_index=${id}
#    \    ${dl_scell_threshhold}    Evaluate    abs(${scell_dl_tput}-${cell_tput})/${cell_tput}
#    \    Should Be True    ${dl_scell_threshhold}<0.05
#    \    Log To Console    ${cell_type} ${id} TPUT ${scell_dl_tput} Is Within Range
#
#Verify UL2CC Tput Within Range
#    [Arguments]    ${UE_ID}    ${ul_pcell_tput}    ${ul_scell_tput}    ${DL_CC_NUM}
#    ${pcell_ul_tp}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=ul    cell_type=pcell    scell_index=0
#    ${scell_ul_tp}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=ul    cell_type=scell    scell_index=1-${DL_CC_NUM}
#    ${ul_p_threshhold}    Evaluate    abs(${pcell_ul_tp}-${ul_pcell_tput})/${ul_pcell_tput}
#    Should Be True    ${ul_p_threshhold}<0.05
#    Log To Console    UL Pcell TPUT ${pcell_ul_tp} Is Within Range
#    ${ul_s_threshhold}    Evaluate    abs(${scell_ul_tp}-${ul_scell_tput})/${ul_scell_tput}
#    Should Be True    ${ul_s_threshhold}<0.05
#    Log To Console    UL Scell TPUT ${scell_ul_tp} Is Within Range
#
