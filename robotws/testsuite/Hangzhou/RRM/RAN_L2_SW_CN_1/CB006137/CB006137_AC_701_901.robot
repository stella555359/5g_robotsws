*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${SCF_FILE}    swconfig_param=${SWCONF}    iphy_file=${IPHY_FILE}
#...               AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#Suite Teardown    Common Suite Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    CRT    RAN_5G    RAN_5G_TDD    Owner_molyang
#...               CN1_SG06    CB006137    SBTS00    SBTS23R1
#Resource          ../CB008015/resources/CB008015_lib.robot
#Resource          resources/6137_BO_lib.robot
#
#*** Variables ***
#${SWCONF}                   0x580307=0x5FE;0x58062d=0x1
#${SCF_PATH}                 ${CURDIR}/config
#${SCF_FILE}                 CB006137_AC_701_901.xml
#${IPHY_FILE}                ${CURDIR}/config/WTS/AC_2F_1T_701_901_iphy.xml
#${LOCAL_WTS_DIR}            ${CURDIR}/config/WTS
#${WTS_CFG}                  AC_701_901_setup.cfg
#${UE_ID3}                   3    #F+T 2CC
#${PDU_ID}                   1
#@{SCELL_PHYSICALID_LIST}    50    53    54
#${A1THRESHOLD}              90
#${DL_CC_NUM}                4
#@{SCELL_INDEX_LIST}         0    1    2    3
#@{CELL_TPUT_LIST1}          93    434    434    175
#@{CELL_TPUT_LIST2}          81    378    378    152
#
#*** Test Cases ***
#CB006137_ET_AC701_BO_Verify_Single_UE_MG_Config_Successfully_Together_With_A3_Event_In_F_T_2CC_UL_CA
#    [Setup]    Run Keywords    Suite Setup Start WTS And Check OnAir
#    ...    AND    Common Test Setup
#    SA Attach    ${ue_id3}
#    Trigger A1 Scell Addition    ${ue_id3}    srsrp_nr=90    phycell_id=51
#    Check SA All Scell PhysicalID With UE ID    ${UE_ID3}    ${SCELL_PHYSICALID_LIST}    ${DL_CC_NUM}
#    Start SA UE Big DL Traffic Internal    ${UE_ID3}    1500
#    SA Start UL Traffic Internal    ${UE_ID3}    ${PDU_ID}    120
#    Sleep    20s    #wait for traffic stable
#    Display Multi UE Throughput    ${UE_ID3}
#    Verify DL4CC Tput Within Range    ${UE_ID3}    ${SCELL_INDEX_LIST}    ${CELL_TPUT_LIST1}
#    Verify UL2CC Tput Within Range    ${UE_ID3}    44    52    ${DL_CC_NUM}
#    Trigger A2 Event For Inter Freq Handover
#    Display Multi UE Throughput    ${UE_ID3}
#    Verify DL4CC Tput Within Range    ${UE_ID3}    ${SCELL_INDEX_LIST}    ${CELL_TPUT_LIST2}
#    Verify UL2CC Tput Within Range    ${UE_ID3}    40    48    ${DL_CC_NUM}
#    Trigger A3 Event For Inter Freq Handover
#    Verify Non CA UE DL UL Tput With In Range    ${UE_ID3}    170    100    0.1
#    [Teardown]    Run Keywords    Common Test Teardown    detach_ue_id=${UE_ID3}
#    ...    AND    Stop Edaemon Egate
#    ...    AND    Reboot TL And Check Configured
#
#CB006137_ET_AC901_BO_Verify_Single_UE_MG_Release_Successfully_Together_With_A3_Event_Removal_In_F_T_2CC_UL_CA
#    [Setup]    Run Keywords    Suite Setup Start WTS And Check OnAir
#    ...    AND    Common Test Setup
#    SA Attach    ${ue_id3}
#    Trigger A1 Scell Addition    ${ue_id3}    srsrp_nr=90    phycell_id=51
#    Check SA All Scell PhysicalID With UE ID    ${UE_ID3}    ${SCELL_PHYSICALID_LIST}    ${DL_CC_NUM}
#    Start SA UE Big DL Traffic Internal    ${UE_ID3}    1500
#    SA Start UL Traffic Internal    ${UE_ID3}    ${PDU_ID}    120
#    Sleep    20s    #wait for traffic stable
#    Display Multi UE Throughput    ${UE_ID3}
#    Verify DL4CC Tput Within Range    ${UE_ID3}    ${SCELL_INDEX_LIST}    ${CELL_TPUT_LIST1}
#    Verify UL2CC Tput Within Range    ${UE_ID3}    44    52    ${DL_CC_NUM}
#    Trigger A2 Event For Inter Freq Handover
#    Display Multi UE Throughput    ${UE_ID3}
#    Verify DL4CC Tput Within Range    ${UE_ID3}    ${SCELL_INDEX_LIST}    ${CELL_TPUT_LIST2}
#    Verify UL2CC Tput Within Range    ${UE_ID3}    40    48    ${DL_CC_NUM}
#    Trigger A1 Event For Inter Freq Handover Release
#    Verify DL4CC Tput Within Range    ${UE_ID3}    ${SCELL_INDEX_LIST}    ${CELL_TPUT_LIST1}
#    Verify UL2CC Tput Within Range    ${UE_ID3}    44    52    ${DL_CC_NUM}
#    [Teardown]    Common Test Teardown    detach_ue_id=${UE_ID3}
#
#*** Keywords ***
#Trigger A2 Event For Inter Freq Handover
#    Log To Console    Trigger A2 Event For Inter Freq Handover
#    ${pattern}    Set Variable    rrcReconfigurationComplete
#    ${cmd}    Catenate    ue_measurement_send_nr id=3 meas_id=1 event=A2 srsrp_nr=11 srsrq_nr=11
#    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    ${cmd}    pass_regexp=${pattern}    timeout=2min
#    Should Match Regexp    ${output}    measGapConfig[\\s\\S]+gapUE setup
#    Sleep    20s    reason=wait for traffic stable
#
#Trigger A1 Event For Inter Freq Handover Release
#    Log To Console    Trigger A1 Event For Inter Freq Handover Release
#    ${pattern}    Set Variable    rrcReconfigurationComplete
#    ${cmd}    Catenate    ue_measurement_send_nr id=3 meas_id=5 event=A1 srsrp_nr=90 srsrq_nr=90
#    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    ${cmd}    pass_regexp=${pattern}    timeout=2min
#    Should Contain    ${output}    gapUE release : NULL
#    Sleep    20s    reason=wait for traffic stable
#
#Trigger A3 Event For Inter Freq Handover
#    Log To Console    Trigger A3 Event For Inter Freq Handover
#    ${pattern}    Set Variable    Intra-eNB handover from EXT_ENB-2.2 to EXT_ENB-2.3 performed
#    ${cmd}    Catenate    ue_measurement_send_nr id=3 meas_id=6 event=A3 srsrp_nr=11 srsrq_nr=11
#    ...    phycell_id=52 nrsrp_nr=80 nrsrq_nr=80
#    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    ${cmd}    pass_regexp=${pattern}    timeout=2min
#    Sleep    20s    reason=wait for traffic stable
#
#Verify Non CA UE DL UL Tput With In Range
#    [Arguments]    ${ue_id}    ${dl_tput}    ${ul_tput}    ${threshold}
#    ${dl_tp}=    Get CA Cell Average Throughput    ue_id=${ue_id}    dir=dl    cell_type=pcell    scell_index=0
#    ${ul_tp}=    Get CA Cell Average Throughput    ue_id=${ue_id}    dir=ul    cell_type=pcell    scell_index=0
#    Log To Console    DL Troughput is ${dl_tp}
#    Log To Console    UL Troughput is ${ul_tp}
#    ${dl_thres}    Evaluate    abs(${dl_tp}-${dl_tput})/${dl_tput}
#    Should Be True    ${dl_thres}<${threshold}
#    ${ul_thres}    Evaluate    abs(${ul_tp}-${ul_tput})/${ul_tput}
#    Should Be True    ${ul_thres}<${threshold}
#
#Verify DL4CC Tput Within Range
#    [Arguments]    ${ue_id}    ${scell_index_list}    ${cell_tput_list}
#    FOR    ${id}    ${cell_tput}    IN ZIP    ${scell_index_list}    ${cell_tput_list}
#    \    ${cell_type}    Set Variable If    '${id}'=='0'    pcell    scell
#    \    ${scell_dl_tput}=    Get CA Cell Average Throughput    ue_id=${ue_id}    dir=dl    cell_type=${cell_type}    scell_index=${id}
#    \    ${dl_scell_threshhold}    Evaluate    abs(${scell_dl_tput}-${cell_tput})/${cell_tput}
#    \    Should Be True    ${dl_scell_threshhold}<0.05
#    \    Log To Console    ${cell_type} ${id} DL TPUT ${scell_dl_tput} Is Within Range
#
#Verify UL2CC Tput Within Range
#    [Arguments]    ${ue_id}    ${ul_pcell_tput}    ${ul_scell_tput}    ${DL_CC_NUM}
#    ${pcell_ul_tp}=    Get CA Cell Average Throughput    ue_id=${ue_id}    dir=ul    cell_type=pcell    scell_index=0
#    ${scell_ul_tp}=    Get CA Cell Average Throughput    ue_id=${ue_id}    dir=ul    cell_type=scell    scell_index=1-${DL_CC_NUM}
#    ${ul_p_threshhold}    Evaluate    abs(${pcell_ul_tp}-${ul_pcell_tput})/${ul_pcell_tput}
#    Should Be True    ${ul_p_threshhold}<0.05
#    Log To Console    Pcell UL TPUT ${pcell_ul_tp} Is Within Range
#    ${ul_s_threshhold}    Evaluate    abs(${scell_ul_tp}-${ul_scell_tput})/${ul_scell_tput}
#    Should Be True    ${ul_s_threshhold}<0.05
#    Log To Console    Scell UL TPUT ${scell_ul_tp} Is Within Range
#
