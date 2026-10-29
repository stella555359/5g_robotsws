*** Settings ***
Documentation    ...
#Documentation     \\eseefsn50.emea.nsn-net.net\rotta4internal\ATF\juvirtan
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#Resource          ./../CUDU_L2/common_CA_DSS.robot
#Suite Teardown    Common Suite Teardown    debug
##Test Teardown    Common Test Teardown    debug
#Test Teardown     Common Test Teardown 2
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    SBTS00    SBTS23R1    RAN_5G    RAN_5G_TDD
#
#*** Variables ***
#${LOCAL_WTS_DIR}       ${CURDIR}/config
#${SCF_PATH}            ${CURDIR}/config
#${SCF}                 ${SCF_PATH}/SCF_DSS_LOO.xml
#${IPHY_DSS}            ${CURDIR}/config/iphy_DSS_LOO.xml
#${WTS_CFG}             basic_3T_3F_bigbuffersizeDSS.cfg
#@{LOG_NAME_LIST}       btslog    egatelog
#${force_reboot}        ${True}
#${ENBID}               2
#${GNBID}               1
#${CELL_ID1}            1
#${CELL_ID2}            2
#${ANTP_NUM}            2
#${NORMAL_SUBFRAME1}    0010000000-1111111111-0000000000-1111111111-0000000000-1111111111-1011110011-1111111111
#${NORMAL_SUBFRAME2}    0010001000-1111110111-0000001000-1111110111-0000001000-1111110111-1011111011-1111110111
#${PRB_LIST}            0,5|5,35|101,5
#${DL_PRB_LIST1}    0:0,52+1:0,52+2:0,52+3:0,52+4:0,52+5:0,52+6:0,52+7:0,52+8:0,52+9:0,52+10:0,52+11:0,52+12:0,52+13:0,52+14:0,52+15:0,52+16:0,52+17:
#${DL_PRB_LIST2}    0,52+18:0,52+19:0,52+20:0,52+21:0,52+22:0,52+23:0,52+24:0,52+25:0,52+26:0,52+27:0,52+28:0,52+29:0,52+30:0,52+31:0,52+32:0,52+33:0
#${DL_PRB_LIST3}    ,52+34:0,52+35:0,52+36:0,52+37:0,52+38:0,52+39:0,52+40:0,52+41:0,52+42:0,52+43:0,52+44:0,52+45:0,52+46:0,52+47:0,52+48:0,52+49:0,
#${DL_PRB_LIST4}    52+50:0,52+51:0,52+52:0,52+53:0,52+54:0,52+55:0,52+56:0,52+57:0,52+58:0,52+59:0,52+60:0,52+61:0,52+62:0,52+63:0,52+64:0,52+65:0,5
#${DL_PRB_LIST5}    2+66:0,52+67:0,52+68:0,52+69:0,52+70:0,52+71:0,52+72:0,52+73:0,52+74:0,52+75:0,52+76:0,52+77:0,52+78:0,52+79:0,52
#
#*** Test Cases ***
#5GC002329-ET-ACB1002-Verify FR1 TDD + FDD DL CA interworking with DSS with A1 Scell addition
#    [Tags]    case_ACB1002    Manual_Johnny    TA_Krihu
#    [Setup]    Run Keywords
#    ...    Suite Setup Update GNB    force_reboot=${force_reboot}    log=${False}    scf_file=${SCF}    iphy_file=${IPHY_DSS}
#    ...    AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...    AND    Common Test Setup 2
#    Suite Setup Start WTS And and load cfg file    enb_id=2    gnb_id=1
#    Configure DSS    30    100    20    70
#	Check All Cells Received SIB2
#    Attach UE    1
#    Trigger A1 addition and Start Traffic    1    1    4
#    Check Traffic On Pcell and Scell    1
#
#*** Keywords ***
#Configure DSS
#    [Arguments]    ${mindl_dss_ratio}    ${maxdl_dss_ratio}    ${minul_dss_ratio}    ${maxul_dss_ratio}
#    Setup X2 AND XP LINK
#	Sleep    20s
#    Enable DSS DMS3 Feature On    ${ENBID}
#	Sleep    20s
#    Set LTE NR DSS Mode PHASE3    ${ENBID}    ${CELL_ID1}    ${ANTP_NUM}
#    Set LTE NR DSS Mode PHASE3    ${ENBID}    ${CELL_ID2}    ${ANTP_NUM}
#	Sleep    20s
#    Setup DSS Link PHASE3    ${ENBID}    ${GNBID}    ${CELL_ID1}
#    Setup DSS Link PHASE3    ${ENBID}    ${GNBID}    ${CELL_ID2}
#	Sleep    20s
#    Set DL RESOURCE Cell Reservation    ${mindl_dss_ratio}    ${maxdl_dss_ratio}    ${ENBID}    ${CELL_ID1}
#    ${cmd}    Catenate    SEPARATOR=${SPACE}    enb_dss_dl_resource_cell_reservation cell=${CELL_ID1} enb=${ENBID}
#    ...    prb_area_reservation_list=0,0,0-10-none+0,0,5-10-none+0,0,9-10-none
#    ute_wtssim.Execute Egate Command    cmd=${cmd}
#    Set DL RESOURCE Cell Reservation    ${mindl_dss_ratio}    ${maxdl_dss_ratio}    ${ENBID}    ${CELL_ID2}
#    ${cmd}    Catenate    SEPARATOR=${SPACE}    enb_dss_dl_resource_cell_reservation cell=${CELL_ID2} enb=${ENBID}
#    ...    prb_area_reservation_list=0,0,0-10-none+0,0,5-10-none+0,0,9-10-none
#    ute_wtssim.Execute Egate Command    cmd=${cmd}
#    Sleep    20s
#    Cell Resource Coordination PHASE3    ${ENBID}    ${GNBID}    ${CELL_ID1}    DL
#    Cell Resource Coordination PHASE3    ${ENBID}    ${GNBID}    ${CELL_ID2}    DL
#	Sleep    20s
#    UL Resource Cell Reservation    ${minul_dss_ratio}    ${maxul_dss_ratio}    ${ENBID}    ${GNBID}    ${CELL_ID1}
#    UL Resource Cell Reservation    ${minul_dss_ratio}    ${maxul_dss_ratio}    ${ENBID}    ${GNBID}    ${CELL_ID2}
#	Sleep    20s
#	${DL_PRB_LIST}=    Catenate    SEPARATOR=    ${DL_PRB_LIST1}    ${DL_PRB_LIST2}    ${DL_PRB_LIST3}    ${DL_PRB_LIST4}    ${DL_PRB_LIST5}
#    Cell Allocation    ${NORMAL_SUBFRAME1}    ${PRB_LIST}    ${ENBID}    ${GNBID}    ${CELL_ID1}    ${DL_PRB_LIST}
#    Cell Allocation    ${NORMAL_SUBFRAME2}    ${PRB_LIST}    ${ENBID}    ${GNBID}    ${CELL_ID2}    ${DL_PRB_LIST}
#
#Setup X2 AND XP LINK
#    [Arguments]    ${enb_id}=2   ${xppeers_id}=1
#    [Documentation]    This keyword is to setup XP Link.
#    ...
#    ...    | Input Parameters | Man. | Description |
#    ...    | enb_id | No | bts_id for eNB |
#    ...    | xppeers_id | No | bts_id for gNB |
#    ...
#    ...    Examples:
#    ...    | Setup XP LINK | 2 | 1 |
#    ...
#    Setup X2 Connection    enb_id=2    gnb_id=1
#    Log To Console   \nSetup XP Link...\n
#    ute_wtssim.Execute Egate Command    sim_trace enb\=${enb_id} protocol\=xp on
#    ute_wtssim.Execute Egate Command    enb_xp_param id\=${enb_id} xp_peers\=none
#    ute_wtssim.Execute Egate Command    enb_xp_param id\=${enb_id} xp_peers\=${xppeers_id}
#    ${pattern}    Set Variable    ENB-${enb_id}: XpAP Link with GNB-${xppeers_id} .* is up
#    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    enb_xp_link_up enb\=${enb_id} target\=${xppeers_id}
#    ...    pass_regexp=${pattern}    timeout=5min
#    ${output}    String.Get Lines Matching Regexp    ${output}    ${pattern}    partial_match=True
#    Log To Console    \n${output}
#
#Attach UE
#    [Arguments]    ${UE_ID}
#    SA 5G Attach    ue_id=${UE_ID}
#    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=1
#    SA 5G PDU Session Setup    ue_id=${UE_ID}
#
#Check Traffic On Pcell and Scell
#    [Arguments]    ${UE_ID}
#    Sleep    30s    reason=wait traffic stable
#    ${pcell_dl_tp}=    Get CA Cell Average Throughput    ${UE_ID}    dir=dl    cell_type=pcell    scell_index=0
#    Run Keyword And Continue On Failure    Should Be True    ${pcell_dl_tp}>400
#    ${scell_dl_tp}=    Get CA Cell Average Throughput    ${UE_ID}    dir=dl    cell_type=pcell    scell_index=1
#    Run Keyword And Continue On Failure    Should Be True    ${scell_dl_tp}>40
#    ${pcell_ul_tp}=    Get CA Cell Average Throughput    ${UE_ID}    dir=ul    cell_type=pcell    scell_index=0
#    Run Keyword And Continue On Failure    Should Be True    ${pcell_ul_tp}>20
#
#Trigger A1 addition and Start Traffic
#    [Arguments]    ${UE_ID}    ${activate_times}    ${trf_id_num}
#	${output}    ute_wtssim.Execute Egate Command And Wait For Data    cmd=ue_measurement_send_nr id\=${UE_ID} meas_id=1 event=A1 srsrp_nr=95
#    ...    pass_regexp=SCellIndex 1 activated successfully    timeout=3minutes
#	ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${UE_ID} pdu=1 qfi=1 trf_id=1 mbps=175 dir=ul
#    :FOR    ${index}    IN RANGE    1    ${trf_id_num}+1
#    \    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${UE_ID} pdu=1 qfi=1 trf_id\=${index} mbps=175 dir=dl