*** Settings ***
Documentation    ...
#Suite Setup       Common Suite Setup
#Test Setup        Common Test Setup
#Suite Teardown    Common Suite Teardown
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    CRT    Owner_peafu
#...               SBTS00    VRF4_SG11    CB011080
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#Resource          ./../CUDU_L2/common_CA_DSS_diff_cell.robot
#Resource          resources/CB011080_resource.robot
#
#*** Variables ***
#### Suite level ###
#${SCF_PATH}           ${CURDIR}/Config
#${FULL_SCFC}          SCF_CB011080_DSS.xml
#${WTS_CFG}            CB011080_dss.lua
#${LOCAL_WTS_DIR}      ${CURDIR}/Config/wts
#${IPHY_XML}           ${CURDIR}/Config/wts/iphy_CB011080_DSS.xml
#@{LOG_NAME_LIST}      snapshot    btsLog
#${UE_ID}              1
#${ENBID}              2
#${GNBID}              1
#${ENB_CELL_ID}        1
#${GNB_CELL_ID}        2
#${ANTP_NUM}           4
#${CC_NUM}             6
#@{SCELL_LIST}         51    52    53    54    55
#${NORMAL_SUBFRAME}    1111110110-0111011110-1111110110-1111011111-0111111110-0111011111-1111011110-0111011111
#${UL_PRB_LIST}        0,5|5,25|30,20
#${DL_PRB_LIST_P1}     0:0,50+1:1,3|5,3+2:20,2+5:0,100+9:0,100+15:0,100+19:0,100+25:0,100+29:0,100+35:0,100+39:0,100+
#${DL_PRB_LIST_P2}     45:0,100+49:0,100+55:0,100+59:0,100+65:0,100+69:0,100+75:0,100+79:0,100
#
#*** Test Cases ***
#CB011080_ET_A1301_Verify_6CC_IWK_With_DSS
#    [Documentation]
#    ...    cell1    cell2(DSS)    cell3    cell4    cell5    cell6    cell7
#    ...    N25(F)    N71(F)    N66(F)    N66(F)    N41(T)    N78(T)    N78(T)
#    ...    PCI:    50    51    52    53    54    55    56
#    ...    UE1/3T3F:    S1    S2    S3    S4    S5    P
#    Configure CELL1 DSS    30    100    20    70
#    Single UE Attach
#    Check Scell Addition
#    Setup DL UL Traffic
#    Check Tput
#    Check DSS Scheduling On Slots059
#
#*** Keywords ***
#Common Suite Setup
#    Suite Setup Update GNB    scf_file=${FULL_SCFC}    iphy_file=${IPHY_XML}
#    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    Suite Setup Start WTS And And Load Cfg File
#
#Configure CELL1 DSS
#    [Arguments]    ${mindl_dss_ratio}    ${maxdl_dss_ratio}    ${minul_dss_ratio}    ${maxul_dss_ratio}
#    Setup XP LINK    ${ENBID}    ${GNBID}
#    ute_wtssim.Execute Egate Command    cmd=enb_disp id=${ENBID} type=xp_info
#    Enable DSS DMS3 Feature On    ${ENBID}
#    Set LTE NR DSS Mode PHASE3    ${ENBID}    ${ENB_CELL_ID}    ${ANTP_NUM}
#    Setup DSS Link PHASE3    ${ENBID}    ${GNBID}    ${ENB_CELL_ID}    ${GNB_CELL_ID}
#    Set DL RESOURCE Cell Reservation    ${mindl_dss_ratio}    ${maxdl_dss_ratio}    ${ENBID}    ${ENB_CELL_ID}
#    Cell Resource Coordination PHASE3    ${ENBID}    ${GNBID}    ${ENB_CELL_ID}    ${GNB_CELL_ID}    DL
#    UL Resource Cell Reservation    ${minul_dss_ratio}    ${maxul_dss_ratio}    ${ENBID}    ${GNBID}    ${ENB_CELL_ID}    ${GNB_CELL_ID}
#    ${DL_PRB_LIST}    Catenate    SEPARATOR=    ${DL_PRB_LIST_P1}    ${DL_PRB_LIST_P2}
#    Cell Allocation    ${NORMAL_SUBFRAME}    ${UL_PRB_LIST}    ${ENBID}    ${GNBID}    ${ENB_CELL_ID}    ${GNB_CELL_ID}    ${DL_PRB_LIST}
#    common_setup_teardown.UE SIB Decoding Should Be Successful
#    Sleep    10s    reason=waiting for SIB for all cells
#
#Single UE Attach
#    [Arguments]    ${ue_id}=1    ${pdu_id}=1
#    Log To Console    UE${ue_id} Start Attach...
#    SA 5G Attach    ue_id=${ue_id}
#    SA Set Traffic Type To Internal    ue_id=${ue_id}    pdu_id=${pdu_id}
#    ute_wtssim.Execute Egate Command And Wait For Data    cmd=ue_pdu_session_setup pdu=${pdu_id} ue=${ue_id} nwslice=1
#    ...    pass_regexp=setup/reestablishment complete    timeout=3minutes
#
#Check Scell Addition
#    Check SA All Scell PhysicalID With UE ID    ue_id=1    scell_physicalid_list=${SCELL_LIST}    cc_num=${CC_NUM}
#
#Setup DL UL Traffic
#    SA Start DL Traffic Internal    ue_id=1    pdu_id=1    mbps=2600
#    SA Start UL Traffic Internal    ue_id=1    pdu_id=1    mbps=150
#
#Check Tput
#    Sleep    10s    reason=waiting for traffic stable
#    Capture Convert Format Ttitrace With Streaming Mode    1s    log_dir=${test_log_directory}/ttitrace/1
#    Check CA UE Pcell Scell Cell TPut On Target    1    dl    pcell    0    500
#    Check CA UE Pcell Scell Cell TPut On Target    1    dl    scell    1    100
#    Check CA UE Pcell Scell Cell TPut On Target    1    dl    scell    2    400
#    Check CA UE Pcell Scell Cell TPut On Target    1    dl    scell    3    300
#    Check CA UE Pcell Scell Cell TPut On Target    1    dl    scell    4    300
#    Check CA UE Pcell Scell Cell TPut On Target    1    dl    scell    5    400
#    Check CA UE Pcell Scell Cell TPut On Target    1    ul    pcell    0    85
#    Check CA UE Pcell Scell Cell TPut On Target    1    ul    scell    1    10
#    Run Keyword And Ignore Error    Rename DL TTItrace CSV
#    CUDU L2 Check DTXNACK Rate    log_id=1    expect_rate=0.1
#	CUDU_L2 Check UL DTXCRC Rate   log_id=1    expect_rate=0.1
#
#Check DSS Scheduling On Slots059
#    ${UE_CRNTI}=    Get Crnti From Egate Log    ${UE_ID}
#    Set Suite Variable    ${UE_CRNTI}
#    Run Keyword And Continue On Failure    ta_a2a.Check Log With Au2anlysis
#    ...    ${CURDIR}${/}A2A/CB011080_DSS.ini
#    ...    i    save_log_directory=${TEST_LOG_DIRECTORY}/ttitrace/1
#
#
#Rename DL TTItrace CSV
#    ${csvdir}    Set Variable    ${TEST_LOG_DIRECTORY}/ttitrace/1
#    OperatingSystem.Run    cp ${csvdir}/output_dl.0.csv ${csvdir}/output_dl.csv
