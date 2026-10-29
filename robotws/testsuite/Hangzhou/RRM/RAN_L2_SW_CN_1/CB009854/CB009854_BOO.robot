*** Settings ***
Documentation    ...
#Resource    ./../CUDU_L2/common_setup_teardown.robot
#Resource           ./CB009854_resource.robot
#Suite Setup        Common Suite Setup 2
#Test Teardown      Common Test Teardown 2
#Suite Teardown     Common Suite Teardown 2
#Force Tags         CLOUD_5G_I_BOO_AP_LOO    SBTS00    SBTS23R1
#...                RAN_5G    RAN_5G_TDD    AP_REG
#*** Variables ***
#${SCF_PATH}                    ${CURDIR}/config/SCF
#${LOG_PATH}                    ${OUTPUT DIR}
#${LOCAL_WTS_DIR}               ${CURDIR}/config/WTS
#${WTS_DIR}                     /opt/iphy/latest
#${scf_ca_fdd_tdd}              ${SCF_PATH}/scf_CB009854_3F3T.xml
#${scf_ca_AB06}                 ${SCF_PATH}/AB06_SCF.xml
#${scf_ca_fdd_tdd_007}          ${SCF_PATH}/scf_CB009854_3F4T_007.xml
#${scf_ca_fdd_tdd_010}          ${SCF_PATH}/scf_CB009854_3F4T_010.xml
#${scf_ca_fdd_tdd_C02}          ${SCF_PATH}/scf_CB009854_3F4T_C02.xml
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
#${5CC_2F3T_SCELL}             ('1', '51', '25'), ('2', '54', '41'), ('3', '55', '41'), ('4', '56', '77')
#${5CC_3F2T_SRS_SCELL}         ('1', '51', '66'), ('2', '52', '66'), ('3', '54', '77'), ('4', '56', '77')
#@{5CC_scell_index}            1    2    3    4
#${egate_console_log}          /opt/wts/latest/egate_console.log
#${Egatelog_path}              ${CURDIR}
#@{dlonly_scell_index}         1    3    4
#@{no_scell_index}             2
#@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}
#
#*** Test Cases ***
#CB009854B-ET-10_Pcell FDD and Differnce frame structures and mimo capbility for TDD cells on DL5CC UL 2CC CA
#    [Documentation]
#    ...    Precondition:
#    ...    Global cell ID(lcrId)/Cell technology/Band/Physical layer cell ID(physCellId)/NR cell ID/NRARFCN/Downlink MIMO mode
#    ...    cell1    FDD    n25    51    16385    20MHz    392500/376500    2x2 Open Loop Spatial Multiplexing
#    ...    cell2    FDD    n66    52    16386    20MHz    425100/349000    2x2 Open Loop Spatial Multiplexing
#    ...    cell3    FDD    n71    53    16387    20MHz    125460/136100    2x2 Open Loop Spatial Multiplexing
#    ...    cell4    TDD    n41    54    16388    40MHz    508494           8x4 Closed Loop Spatial Multiplexing
#    ...    cell5    TDD    n41    55    16389    60MHz    529998           2x2 Closed Loop Spatial Multiplexing
#    ...    cell6    TDD    n77    56    16390    80MHz    623400           4x4 or 4x2 Closed Loop Spatial Multiplexing
#    ...    sCellAdditionMethod=covBasedA1
#    ...    sCellActivationMethod=bufferbased
#    ...    actAperCsi=true
#    ...    actFdmScheduling=true
#    ...    actIncreasedFdmUsersPerSlot=true
#    ...    actPerCsiReportBundlingFdd=true
#    ...    Test Steps:
#    ...    1.2 UEs attach to FDD as pcell.
#    ...    2. UE send A1 reprot to add FDD scell ,TDD scell1 ,TDD scell2.
#    ...    3. Start big DL and UL data for both UE1 and UE2.
#    ...    4. start small DL data transfer for UE1.
#    ...    5. stop UL data transferor UE1.
#    ...    6. Start big data on both DL and UL for UE1
#    ...    7. release call.
#    ...    Check Points:
#    ...    1. Verify Scell addditon successfully.
#    ...    2. Scell addition successfully.
#    ...    3.Data transfer on pcell and scell correctly for each.
#    ...    4.Verfiy UE will send  UCI bits  csi for cqi+ACK  and  UCI bits csi for beam+ACK for each cell on FDD pcell for acsi and pcsi.
#    ...    19 bit CQI and 15 beam  and 8 ACK for TTD scell1,
#    ...    7 bit  CQI and 19 beam  and 8 ACK for TTD scell2,
#    ...    11 bit CQI  and 17 bit for TDD scell3.
#    ...    5. After step4 , only pcell schedule , check ther are no NACK and DTX for HARQ.
#    ...    Verfiy UE will send  UCI bits  csi for cqi+ACK  and  UCI bits csi for beam for each cell on TDD scell for acsi and pcsi.
#    ...    6. After step 5 , ACK/NACK and CSI report on Pcell pucch.
#    ...    7.Verify ACK/NACK and CSI on pcell pusch agian.
#    ...    8. Call release.
#    ...    Log path: \\beeefsn01.china.nsn-net.net\DCM_project\CB009854\Pass_log
#    [Tags]     case_010    Mannual_Ding_Lanxin    TA_Ma_Yue    CLOUD_5G_I_BOO_AP_LOO
#    [Setup]    Run Keywords    Set Test Variable    ${WTS_CFG}    ${WTS_CFG_010}
#    ...        AND    Suite Setup Update GNB    scf_file=${scf_ca_fdd_tdd_010}    iphy_file=${iphy_CB009854_3F4T}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Common Test Setup 2
##    ...        AND    Suite Setup Start WTS And Check OnAir    log=${False}
#    CB009854_resource.Start WTS And Check OnAir
#    Attach UE And Start Traffic For Case010
#
#CB009854-ET-C002__Buffer_based_one_shot_SCell_Addition_with_measurement_based_SCell_Addition
#    [Documentation]
#    ...    Precondition:
#    ...    sCellAdditionMethod=covBasedA1
#    ...    sCellActivationMethod=bufferAndRLQualityBased
#    ...    actBufferBasedSCellAddition=oneShot_Dl_Fr1
#    ...    actPerCsiReportBundlingFdd=true
#    ...    Test Steps:
#    ...    1. UE attach to FDD cell as Pcell.
#    ...    2. start small data on Dl and UL
#    ...    3. UE report 1A to trigger scell additon
#    ...    4. Start big data on DL and UL
#    ...    5. start small data on DL
#    ...    6. stop UL data transfer.
#    ...    7. Call release
#    ...    Check Points:
#    ...    1. Verify Scell addditon successfully.
#    ...    2. Scell addition successfully.
#    ...    3.Data transfer on pcell and scell correctly for each.
#    ...    4.Verfiy UCI bit correct on FDD pcell
#    ...    5.After step4 , UE enter to DRX inactive
#    ...    6. After step5, Data transfer successfully again.
#    ...    7.Call release.
#    [Tags]     case_C002    Mannual_Ding_Lanxin    TA_Ma_Yue    CLOUD_5G_I_BOO_AP_LOO
#    [Setup]    Run Keywords    Set Test Variable    ${WTS_CFG}    ${WTS_CFG_CA}
#    ...        AND    Suite Setup Update GNB    scf_file=${scf_ca_fdd_tdd_C02}    iphy_file=${iphy_CB009854_3F4T}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Common Test Setup 2
##    ...        AND    Suite Setup Start WTS And Check OnAir    log=${False}
#    CB009854_resource.Start WTS And Check OnAir
#    Attach UE And Start Traffic For C002
#
#*** Keywords ***
#Attach UE And Start Traffic For Case010
#    [Arguments]    ${UE_ID1}=3    ${UE_ID2}=2
#    SA 5G Attach    ue_id=${UE_ID1}
#    SA Set Traffic Type To Internal    ue_id=${UE_ID1}    pdu_id=1
#    SA 5G PDU Session Setup    ue_id=${UE_ID1}
#    SA 5G Attach    ue_id=${UE_ID2}
#    SA Set Traffic Type To Internal    ue_id=${UE_ID2}    pdu_id=1
#    SA 5G PDU Session Setup    ue_id=${UE_ID2}
#    Trigger A1 Scell Addition    ${UE_ID1}    85    53
#    Trigger A1 Scell Addition    ${UE_ID2}    85    53
#    Get And Check Scell Infos    ${5CC_2F3T_SCELL}
#    #3. Start big DL and UL data for both UE1 and UE2.
#    Start SA UE Big DL Traffic Internal    ${UE_ID1}    525
#    SA Start UL Traffic Internal    ${UE_ID1}    1    60
#    Start SA UE Big DL Traffic Internal    ${UE_ID2}    525
#    SA Start UL Traffic Internal    ${UE_ID2}    1    60
#    #4. start small DL data transfer for UE1.
#    SA Start DL Traffic Internal    ${UE_ID1}    1    20
#    Setup Ttitrace
#    Run Keyword And Continue On Failure    Check UL And DL DTX From Ttitrace Quickly    10_1    1
#    Run Keyword And Continue On Failure    CUDU_L2 Verify Period Of Beam Or PCSI Report    53    ${TEST_LOG_DIRECTORY}/ttitrace/10_1/
#    Run Keyword And Continue On Failure    Check NumOfUciCsiPart1Bits On Specific Scell    10_1    56    11
#    Run Keyword And Continue On Failure    Check NumOfUciCsiPart1Bits On Specific Scell    10_1    54    19
#    #5. stop UL data transferor UE1.
#    SA Stop Data Traffic Internal    ${UE_ID1}    1    dl
#    SA Stop Data Traffic Internal    ${UE_ID1}    1    ul
#    Sleep    10s    Wait Scells are added...
#    Run Keyword And Continue On Failure    Check Whether UE In CA Mode    ${UE_ID1}    5    pdsch
#    Run Keyword And Continue On Failure    Check Whether UE In CA Mode    ${UE_ID1}    2    pusch
#    Run Keyword And Continue On Failure    Check UL And DL DTX From Ttitrace Quickly    10_2    1
#    Run Keyword And Continue On Failure    CUDU_L2 Verify Period Of Beam Or PCSI Report    53    ${TEST_LOG_DIRECTORY}/ttitrace/10_2/
#    Run Keyword And Continue On Failure    Check NumOfUciCsiPart1Bits On Specific Scell    10_2    56    11
#    Run Keyword And Continue On Failure    Check NumOfUciCsiPart1Bits On Specific Scell    10_2    54    19
#    #6. Start big data on both DL and UL for UE1
#    Start SA UE Big DL Traffic Internal    ${UE_ID1}    525
#    SA Start UL Traffic Internal    ${UE_ID1}    1    60
#    Check UL And DL DTX From Ttitrace Quickly    10_3    1
#    Teardown Ttitrace
#    Run Keyword And Continue On Failure    CUDU_L2 Verify Period Of Beam Or PCSI Report    53    ${TEST_LOG_DIRECTORY}/ttitrace/10_3/
#    Run Keyword And Continue On Failure    Check NumOfUciCsiPart1Bits On Specific Scell    10_3    56    11
#    Run Keyword And Continue On Failure    Check NumOfUciCsiPart1Bits On Specific Scell    10_3    54    19
#    SA 5G Detach    ${UE_ID1}
#    SA 5G Detach    ${UE_ID2}
#
#Attach UE And Start Traffic For C002
#    [Arguments]    ${UE_ID1}=3
#    SA 5G Attach    ue_id=${UE_ID1}
#    SA Set Traffic Type To Internal    ue_id=${UE_ID1}    pdu_id=1
#    SA 5G PDU Session Setup    ue_id=${UE_ID1}
#    SA Start DL Traffic Internal    ${UE_ID1}    1    20
#    SA Start UL Traffic Internal    ${UE_ID1}    1    10
#    Run Keyword And Continue On Failure    Check Whether UE In CA Mode    ${UE_ID1}    1    pdsch
#    Run Keyword And Continue On Failure    Check Whether UE In CA Mode    ${UE_ID1}    1    pusch
#    Send A1 report    ${UE_ID1}    80    53
#    Start SA UE Big DL Traffic Internal    ${UE_ID1}    875
#    SA Start UL Traffic Internal    ${UE_ID1}    1    100
#    Sleep    20s    Wait Scells are added...
#    Run Keyword And Continue On Failure    Check Whether UE In CA Mode    ${UE_ID1}    5    pdsch
#    Run Keyword And Continue On Failure    Check Whether UE In CA Mode    ${UE_ID1}    2    pusch
#    Run Keyword And Continue On Failure    Get And Check Scell Infos    ${5CC_2F3T_SCELL}
#    Check UL And DL DTX From Ttitrace    C02    1
#    Run Keyword And Continue On Failure    Check NumOfUciCsiPart1Bits On Specific Scell    C02    54    18
#    Run Keyword And Continue On Failure    Check NumOfUciCsiPart1Bits On Specific Scell    C02    55    18
#    Run Keyword And Continue On Failure    Check NumOfUciCsiPart1Bits On Specific Scell    C02    56    18
#    SA 5G Detach    ${UE_ID1}
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
