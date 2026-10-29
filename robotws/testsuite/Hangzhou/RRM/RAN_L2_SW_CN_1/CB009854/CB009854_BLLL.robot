*** Settings ***
Documentation    ...
#Resource    ./../CUDU_L2/common_setup_teardown.robot
#Resource           ./CB009854_resource.robot
#Suite Setup        Common Suite Setup 2
#Test Teardown      Common Test Teardown 2
#Suite Teardown     Common Suite Teardown 2
#Force Tags         CLOUD_5G_I_BLLL_AP_LOO    SBTS00    SBTS23R1
#...                RAN_5G    RAN_5G_TDD
#*** Variables ***
#${SCF_PATH}                    ${CURDIR}/config/SCF
#${LOG_PATH}                    ${OUTPUT DIR}
#${LOCAL_WTS_DIR}               ${CURDIR}/config/WTS
#${WTS_DIR}                     /opt/iphy/latest
#${scf_ca_fdd_tdd}              ${SCF_PATH}/scf_CB009854_3F3T.xml
#${scf_ca_AB06}                 ${SCF_PATH}/AB06_SCF.xml
#${scf_ca_fdd_tdd_007}          ${SCF_PATH}/scf_CB009854_3F4T_007.xml
#${scf_ca_fdd_tdd_010}          ${SCF_PATH}/scf_CB009854_3F4T_010.xml
#${iphy_CB009854_3F4T}          ${CURDIR}/config/IPHY/iphy_CB009854_3F4T.xml
#${iphy_CB009854_AB06}          ${CURDIR}/config/IPHY/iphy_CB009854_AB06.xml
#${iphy_CB009854_007}          ${CURDIR}/config/IPHY/iphy_CB009854_007.xml
#${WTS_CFG_CA}                  wts_CB009854.cfg
#${WTS_CFG_AB06}                wts_9854_AB06.cfg
#${WTS_CFG_007}                 wts_CB009854_007.cfg
#${WTS_CFG_010}                 wts_CB009854_010.cfg
#${SWCONFIG_AA_02}              0x4B000F=1;0x3F007C=1024;0x58012d=3;
#${UE3_ID}                      3
#${UE30_ID}                     30
#${4CC_2F2T_SCELL}             ('1', '51', '25'), ('2', '52', '66'), ('3', '54', '41')
#${5CC_3F2T_SCELL}             ('1', '51', '25'), ('2', '52', '66'), ('3', '54', '41'), ('4', '55', '41')
##${5CC_2F3T_SCELL}             ('1', '51', '25'), ('2', '54', '41'), ('3', '55', '41'), ('4', '56', '77')
#${5CC_3F2T_SRS_SCELL}         ('1', '51', '66'), ('2', '52', '66'), ('3', '54', '77'), ('4', '56', '77')
#@{5CC_scell_index}            1    2    3    4
#${5CC_2F3T_SCELL}             ('1', '52', '41'), ('2', '53', '41'), ('3', '60', '25'), ('4', '62', '66')
#${egate_console_log}          /opt/wts/latest/egate_console.log
#${Egatelog_path}              ${CURDIR}
#@{dlonly_scell_index}         1    3    4
#@{no_scell_index}             2
#@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}
#
#*** Test Cases ***
#CB009854D-ET-007_2F3T_loner_gnb_pcsi_bunding_per_CC_enable_on_FDD_pcell
#    [Documentation]
#    ...    SCF config:
#    ...    Global cell ID(lcrId)/Cell technology/Band/Physical layer cell ID(physCellId)/NR cell ID/NRARFCN/Downlink MIMO mode
#    ...    cell1    TDD    n78    50    16385    60MHz    633000    4x4 or 4x2 Closed Loop Spatial Multiplexing
#    ...    cell2    TDD    n77    51    16386    80MHz    623400    4x4 or 4x2 Closed Loop Spatial Multiplexing
#    ...    cell3    TDD    n41    52    16387    40MHz    508494    8x4 Closed Loop Spatial Multiplexing
#    ...    cell4    TDD    n41    53    16388    60MHz    529998    8x4 Closed Loop Spatial Multiplexing
#    ...    cell11   FDD    n25    60    16395    20MHz    392500/376500    2x2 Closed Loop Spatial Multiplexing
#    ...    cell13   FDD    n66    62    16397    20MHz    425100/349000    2x2 Closed Loop Spatial Multiplexing
#    ...    cell12   FDD    n71    61    16396    20MHz    125460/136100    2x2 Closed Loop Spatial Multiplexing
#    ...    ue8:physCellId 61(pcell),physCellId 52(sCell1),physCellId 53(sCell2),physCellId 60(sCell3),physCellId 62(sCell4)
#    ...    Precondition:
#    ...    actPerCsiReportBundlingFdd=true
#    ...    Test Steps:
#    ...    1. UE attach to FDD as Pcell.
#    ...    2. start big data for TDD pcell
#    ...    3. UE send UCI 44  bit include 19 bit UCI for CQI (CRI=2,RI=2,LI=2,i11=3,i12=3,i13=2,i2=1,CQI=4) and 15 bit for beam report
#    ...       and 4 bit ACK and 1SR. Total 44bit for each TDD scell1, UCI for CQI(7bit)+beam (15 bit) for TDD scell2 ,
#    ...       UCI for CQI(11bit)+ beam (15 bit) for TDD scell3.
#    ...    4. Stop DL and UL data to trigger UE enter to DRX sleep status.
#    ...    5. Start UL data gain.
#    ...    6. start DL data.
#    ...    7. Rlease call.
#    ...    Check Points:
#    ...    1. Verify Scell addditon successfully.
#    ...    2. Scell addition successfully.
#    ...    3.Data transfer on pcell and scell correctly for each.
#    ...    4.Verfiy 49bit Pcsi and HARQ on Pcell pusch successfully , not DTX and RACK found. Scell will not schedule when pcsi overlap slot.
#    ...    5.After step4, check the TDD scell will release.
#    ...    6.After step5 ,TDD scell add again.
#    ...    7 Pcsi and HARQ on Pcell pucch successfully , not DTX and RACK found.
#    ...    5. Call release succesfully."
#    [Tags]     case_007    Mannual_Sun_Yaling    TA_Ma_Yue
#    [Setup]    Run Keywords    Set Test Variable    ${WTS_CFG}    ${WTS_CFG_007}
#    ...        AND    Suite Setup Update GNB    scf_file=${scf_ca_fdd_tdd_007}    iphy_file=${iphy_CB009854_007}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Common Test Setup 2
##    ...        AND    Suite Setup Start WTS And Check OnAir    log=${False}
#    CB009854_resource.Start WTS And Check OnAir
#    Attach UE And Start Traffic For Case007
#
#*** Keywords ***
#Attach UE And Start Traffic For Case007
#    [Arguments]    ${UE_ID}=8
#    SA 5G Attach    ue_id=${UE_ID}
#    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=1
#    SA 5G PDU Session Setup    ue_id=${UE_ID}
#    Trigger A1 Scell Addition    ${UE_ID}    85    53
#    Get And Check Scell Infos    ${5CC_2F3T_SCELL}
#    Start SA UE Big DL Traffic Internal    ${UE_ID}    1000
#    Start SA UE Big UL Traffic Internal    ${UE_ID}    200
#    Sleep    5s    reason=Wait for TP stable...
#    Run Keyword And Continue On Failure    Check Whether UE In CA Mode    ${UE_ID}    5    pdsch
#    Run Keyword And Continue On Failure    Check Whether UE In CA Mode    ${UE_ID}    2    pusch
#    Setup Ttitrace
#    Check UL And DL DTX From Ttitrace Quickly    C07_1    1
#    Run Keyword And Continue On Failure    Check NumOfUciCsiPart1Bits On Specific Scell    C07_1    53    34
#    Run Keyword And Continue On Failure    Check NumOfUciCsiPart1Bits On Specific Scell    C07_1    52    37
#    #Step 4:Stop DL and UL data to trigger UE enter to DRX sleep status.
#    SA Stop Data Traffic Internal    ${UE_ID}    1
#    Start SA UE Big DL Traffic Internal    ${UE_ID}    1000
#    Start SA UE Big UL Traffic Internal    ${UE_ID}    200
#    Sleep    5s    reason=Wait for TP stable...
#    Run Keyword And Continue On Failure    Check Whether UE In CA Mode    ${UE_ID}    5    pdsch
#    Run Keyword And Continue On Failure    Check Whether UE In CA Mode    ${UE_ID}    2    pusch
#    Check UL And DL DTX From Ttitrace Quickly    C07_2    1
#    Teardown Ttitrace
#    Run Keyword And Continue On Failure    Check NumOfUciCsiPart1Bits On Specific Scell    C07_2    53    34
#    Run Keyword And Continue On Failure    Check NumOfUciCsiPart1Bits On Specific Scell    C07_2    52    37
##    Run Keyword And Continue On Failure    Check NumOfUciCsiPart1Bits On Specific Scell    C07_2    60    7
##    Run Keyword And Continue On Failure    Check NumOfUciCsiPart1Bits On Specific Scell    C07_2    61    7    #pcell
##    Run Keyword And Continue On Failure    Check NumOfUciCsiPart1Bits On Specific Scell    C07_2    62    7
#    SA 5G Detach    ${UE_ID}
#
#Suite Setup Start WTS And Check OnAir Without Workaround
#    [Arguments]    ${log}=${True}    ${enb_id}=1    ${gnb_id}=2    ${wts_cfg_file}=${WTS_CFG}    ${gnb_num}=1    ${skip_X2}=${True}
#    [Documentation]    This keyword is to modify vlan, start WTS, wait for onAir
#    Modify UTE SCTP Timeout
#    Modify AP SCTP Timeout
#    Configure UTE ETH3
#    Start UTE WTS    ${wts_cfg_file}
#    Run Keyword If    '${GNBCUTYPE}'=='SANSA'    UE SIB Decoding Should Be Successful
#    Run Keyword If    '${GNBCUTYPE}'=='SA'    UE SIB Decoding
#    #Get NR Cell Number
#    Run Keyword If    '${GNBCUTYPE}'=='NSA'    Setup X2 Connection    ${enb_id}    ${gnb_id}
#    Verify Cell Setup    gnb_num=${gnb_num}
#    Run Keyword If    '${GNBCUTYPE}'=='SANSA' or '${GNBCUTYPE}'=='SA'    Check All Cells Received SIB2
#    Run Keyword If    '${GNBCUTYPE}'=='SANSA' and '${skip_X2}'=='${False}'    Setup X2 Connection    ${enb_id}    ${gnb_id}
#    [Teardown]    Run Keyword If    "${log}"=="${True}"    common_log_capture.Stop Logs    ${LOG_NAME_SUITE_SETUP}    ${SUITE_LOG_DIRECTORY}
#
#Catch BIP Log
#    [Arguments]    ${time}=0.5s    ${log_id}=1
#    Start Gnb BIP Log
#    Sleep    ${time}
#    Stop Gnb BIP Log    ${OUTPUT_DIR}/BIP/${log_id}
#
