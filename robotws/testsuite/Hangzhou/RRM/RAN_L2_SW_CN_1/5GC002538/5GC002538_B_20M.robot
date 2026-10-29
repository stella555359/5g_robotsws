*** Settings ***
Documentation    ...
#Suite Setup       Suite Setup Update GNB
#Suite Teardown    Common Suite Teardown    debug
#Force Tags        CLOUD_5G_I_LO_AP_LO    CRT    RAN_5G    RAN_5G_FDD    FR1    SBTS00
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#Resource          ./../CUDU_L2/common_CA_DSS.robot
#Resource          ./5GC002538_Resource.robot
#
#*** Variables ***
#${UE_ID}             51
#@{LOG_NAME_LIST}     btslog    snapshot
#
####B003###
#${SCF_PATH}                 ${CURDIR}/resources/config
#${FULL_SCF_FILE_DSS_20M}    Full_conf_5GC002538_B_ET_20M.xml
#${IPHY_FILE_DSS_20M}        ${CURDIR}/resources/wts/iphy_2538_DSS.xml
#${LOCAL_WTS_DSS_20M}        ${CURDIR}/resources/wts
#${WTS_CFG_DSS_20M}          basic_wts_2538_B_20M.cfg
## ${ENB_CELL_1}               1
#${ENBID}                    2
#${GNBID}                    1
#${CELL3_ID}                 3
#${ANTP_NUM}                 2
#${NORMAL_SUBFRAME}          1111110110-0111011110-1111110110-1111011111-0111111110-0111011111-1111011110-0111011111
#${UL_PRB_LIST}              0,5|5,25|30,20
#${DL_PRB_LIST_P1}           0:0,50+1:1,3|5,3+2:20,2+5:0,100+9:0,100+15:0,100+19:0,100+25:0,100+29:0,100+35:0,100+39:0,100+
#${DL_PRB_LIST_P2}           45:0,100+49:0,100+55:0,100+59:0,100+65:0,100+69:0,100+75:0,100+79:0,100
#
#*** Test Cases ***
#5GC002538_ET_B003_PDSCH_In_SSB_And_TRS_Slot_DL_Mimo_2x2_DSS_Sharing_50_percent_1UE_20M_NSA
#    [Tags]     Owner_xiaothan
#    [Setup]    Run Keywords    Test Setup Update GNB    scf_file=${FULL_SCF_FILE_DSS_20M}    iphy_file=${IPHY_FILE_DSS_20M}
#    ...    AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${LOCAL_WTS_DSS_20M}    wts_cfg_file=${WTS_CFG_DSS_20M}
#    ...    AND    Suite Setup Start WTS And and load cfg file    enb_id=2    gnb_id=1
#    ...    AND    Common Test Setup
#    Configure CELL3 DSS    30    100    20    70
#    SA Single UE Attach    ${UE_ID}
#    SA Start DL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=175    trf_id=1
#    Sleep    1s    reason=Wait For Transmission Stable
#    Start Gnb BIP Log
#    Sleep    3s    reason=Capture BIP log
#    Stop Gnb BIP Log    ${output_dir}
#    Covert BIP To Csv
#    Verify Single UE PDSCH Schedule In SSB Slot
#    Verify Single UE PDSCH Schedule In TRS Slot
#    Verify DL Not ACK Rate Less Than Target    ${output_dir}    0.05
#
#
#*** Keywords ***
#Configure CELL3 DSS
#    [Arguments]    ${mindl_dss_ratio}    ${maxdl_dss_ratio}    ${minul_dss_ratio}    ${maxul_dss_ratio}
#    Setup X2 Connection    ${ENBID}    ${GNBID}
#    Setup XP LINK    ${ENBID}    ${GNBID}
#    ute_wtssim.Execute Egate Command    cmd=enb_disp id=${ENBID} type=xp_info
#    Enable DSS DMS3 Feature On    ${ENBID}
#    Set LTE NR DSS Mode PHASE3    ${ENBID}    ${CELL3_ID}    ${ANTP_NUM}
#    Setup DSS Link PHASE3    ${ENBID}    ${GNBID}    ${CELL3_ID}
#    Set DL RESOURCE Cell Reservation    ${mindl_dss_ratio}    ${maxdl_dss_ratio}    ${ENBID}    ${CELL3_ID}
#    Cell Resource Coordination PHASE3    ${ENBID}    ${GNBID}    ${CELL3_ID}    DL
#    UL Resource Cell Reservation    ${minul_dss_ratio}    ${maxul_dss_ratio}    ${ENBID}    ${GNBID}    ${CELL3_ID}
#    ${DL_PRB_LIST}    catenate    SEPARATOR=    ${DL_PRB_LIST_P1}    ${DL_PRB_LIST_P2}
#    Cell Allocation    ${NORMAL_SUBFRAME}    ${UL_PRB_LIST}    ${ENBID}    ${GNBID}    ${CELL3_ID}    ${DL_PRB_LIST}
#    common_setup_teardown.UE SIB Decoding Should Be Successful
#    Sleep    10s    reason=waiting for SIB for all cells
#
