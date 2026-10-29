*** Settings ***
Documentation    ...
#Resource           ./CB012149_resource.robot
#Resource           ./../CUDU_L2/common_setup_teardown.robot
#Suite Setup        Common Suite Setup 2
#Test Teardown      Common Test Teardown 2
#Suite Teardown     Common Suite Teardown 2
#Force Tags         CLOUD_5G_I_LPQ_AP_LOO    SBTS00
#...                RAN_5G    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD
#
#*** Variables ***
#${SCF_PATH}                   ${CURDIR}/Config/SCF
#${WTS_DIR}                    /opt/iphy/latest
#${WTS_CFG_BB007}               wts_CB012149_BB007.cfg
#${LOCAL_WTS_DIR}              ${CURDIR}/Config/WTS/
#${SCF_BB007}                   ${SCF_PATH}/CB012149_BB007.xml
#${iphy_BB007}                  ${CURDIR}/Config/IPHY/iphy_BB007.xml
#${SWCONFIG_BB007}              0x4B000F=1;
#${UE1_ID}                      1
#${UE2_ID}                      2
#${UE3_ID}                      3
#${1T1F_SCELLS}                ('1', '54', '41')
#${TDD_MUTE_SLOT_1070}              [4, 14]
#${SLIVLIST_1}                 ["","27.0"]
#${SLIVLIST_slot1_1}                 ["69.0","55.0"]
#${SLIVLIST_slot1_2}                 ["55.0","69.0"]
#${RANK2}                       ['RANK2']
#${RANK1}                      ['RANK1']
#${FILTER1}                SEPARATOR=${EMPTY}    (UlData_pucchReceiveReqPucchResource_t.firstSymbol == 4) &&
#...                      (UlData_pucchReceiveReqPucchResource_t.numOfSymbols == 7)
#@{CSV_TITLE_LIST1}        UlData_pucchReceiveReqPucchResource_t.firstSymbol    UlData_pucchReceiveReqPucchResource_t.numOfSymbols
#${CHECK_POINT_REGEXP1}    "UlData_PucchReceiveReq\\s*","4","7"
#${FILTER2}                SEPARATOR=${EMPTY}    (UlData_pucchReceiveReqPucchResource_t.firstSymbol == 3) &&
#...                      (UlData_pucchReceiveReqPucchResource_t.numOfSymbols == 8)
#@{CSV_TITLE_LIST2}        UlData_pucchReceiveReqPucchResource_t.firstSymbol    UlData_pucchReceiveReqPucchResource_t.numOfSymbols
#${CHECK_POINT_REGEXP2}    "UlData_PucchReceiveReq\\s*","3","8"
#@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}
#
#*** Test Cases ***
#CB012149ET-BB007_TDD scell and UE UL TX switch with PUSCH typeB
#    [Documentation]
#    ...    Precondition:
#    ...      FDD 20M and pcell TDD with 1070 frame structure.
#    ...      with beam=6
#    ...      NRBTS.sCellActivationMethod=1:bufferBased
#    ...      A1 based scell added configured.
#    ...    Test Steps:
#    ...      Step1:  UE1 with UL TX swich attach to FDD cell as pcell. UL and DL data on UE2 and UE3 with Rr15 UL CA capability for backgrand call
#    ...      Step2: start big data on UL and DL for all UEs.
#    ...      Step3: UE1 report A1 to trigger scells additon.
#    ...      Step4: UE1 start small data on UL.
#    ...      Step5: UE1 start big data agian.
#    ...      Step6: Relese call.
#    ...    Check point：
#    ...      1. Verify  after step3 for UE1, data transfer GNB schedule UL data on FDD Pcell which is not overlap with TDD scell
#    ...         and 2layer on TDD cell at TDD UL slot. data transfer on Pcell and scell for UE2 and UE3 successfully.
#    ...      2. Verify  FDD pcell  PUSCH slot before or after TDD UL slot SLIV like this: slot1 & 3&6&slot8 : S=0, L=12 (SLIV 55),
#    ...         and  slot0 & slot5  :S=2, L=12  (SLIV 53). other FDD UL scheudle slot use noraml 14 symbol like legacy.
#    ...      3. Verify when UCI on PUCCH, UE1 with same starting PRB forPUCCH F1 as UE2 and UE3.
#    ...         But UE1 with short PUCCH F1 with S=4 L=7 and PUCCH F3 with S=3 L=8.
#    ...      4. After small data transfer , buffer split will stop on TDD scell. GNB will use noraml 14 symbol  to schedule ul data
#    ...         on Pcell PUSCH like legacy.UE1 with short  PUCCH F1 with  S=4 L=7 and PUCCH F3 with S=3 L=8.
#    ...      5. After step5 data transfer again, verify UL data schedule Scell TDD slots delay from buffer 0 to  non-empty buffer.
#    ...         The short PUSCH SLIV on Pcell: slot1 & 3&6&slot8 : S=0, L=12 (SLIV 55), and slot0 & slot5 :S=2, L=12 (SLIV 53).
#    ...      6.  No DTX or NACK on  PUSCH or PUCCH.
#    [Tags]    caseBB007    Manual_suqian    TA_suqian
#    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG_BB007}
#    ...        AND    Suite Setup Update GNB    scf_file=${SCF_BB007}    iphy_file=${iphy_BB007}    swconfig_param=${SWCONFIG_BB007}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Common Test Setup 2
#    ...        AND    Suite Setup Start WTS And Check OnAir    ${wts_cfg}
#    #Step1
#    SA Single UE Attach    ${UE3_ID}
#    Sleep    2s    reason=Wait for log
#    Start SA UE Big UL Traffic Internal    ${UE3_ID}    100
#    Start SA UE Big DL Traffic Internal    3    mbps=200
#    Sleep    10s    #sleep for stable traffic
#    SA Single UE Attach    ${UE1_ID}
#    Sleep    2s    reason=Wait for log
#    Start SA UE Big UL Traffic Internal    ${UE1_ID}    100
#    Start SA UE Big DL Traffic Internal    1    mbps=200
#    Sleep    10s    #sleep for stable traffic
#    SA Single UE Attach    ${UE2_ID}
#    #step3
#    Trigger A1 Addition For BB007   ${UE2_ID}
#    Sleep    3s    reason=Wait for log
#    Get And Check Scell Infos    ${1T1F_SCELLS}
#    #Step
#    Send Traffic for BB007    2
#    Start SA UE Big DL Traffic Internal    2    mbps=1000
#    Sleep    10s    #sleep for stable traffic
#    CUDU_L2 Capture And Decode TTitrace    1   2
#    #Step4
#    Send Small Traffic over DRB1    2
#    Sleep    10s    #sleep for stable traffic
#    Start Gnb BIP Log
#    Sleep    1s    reason=Wait for log
#    Stop Gnb BIP Log    ${TEST_LOG_DIRECTORY}/2/
#    #Step5
#    Recover Traffic for DA10    2
#    Sleep    10s    #sleep for stable traffic
#    CUDU_L2 Capture And Decode TTitrace    3   2
#    #Check point1
#    #Check Layer For Cell    ${TEST_LOG_DIRECTORY}/ttitrace/1/output_ul.csv    54    ${RANK2}
#    #Check point2
#    #Check SLIV On Specific Slot In TTI    log_id=1    SLIV=53.0    slot=0    SLIVLIST=${SLIVLIST_1}
#    #Check SLIV On Specific Slot In TTI    log_id=1    SLIV=53.0    slot=5    SLIVLIST=${SLIVLIST_1}
#    #Check SLIV On Specific Slot In TTI    log_id=1    SLIV=55.0    slot=1    SLIVLIST=${SLIVLIST_1}
#    #Check SLIV On Specific Slot In TTI    log_id=1    SLIV=55.0    slot=3    SLIVLIST=${SLIVLIST_1}
#    #Check SLIV On Specific Slot In TTI    log_id=1    SLIV=55.0    slot=6    SLIVLIST=${SLIVLIST_1}
#    #Check SLIV On Specific Slot In TTI    log_id=1    SLIV=55.0    slot=8    SLIVLIST=${SLIVLIST_1}
#    #Check point3 and 4
#    ${bip_log}    Set Variable    ${TEST_LOG_DIRECTORY}/2/5GBipL2L1_filtering_off.pcap
#    Convert BIP To CSV By MCShark    ${bip_log}    ${OUTPUT_DIR}/bip_log.csv    ${FILTER1}    ${CSV_TITLE_LIST1}
#    ${csv_content}    OperatingSystem.Get File    ${OUTPUT_DIR}/bip_log.csv
#    ${check_status}    Run Keyword And Return Status    Should Match Regexp    ${csv_content}    ${CHECK_POINT_REGEXP1}
#    Should Be True    ${check_status}
#    Convert BIP To CSV By MCShark    ${bip_log}    ${OUTPUT_DIR}/bip_log2.csv    ${FILTER2}    ${CSV_TITLE_LIST2}
#    ${csv_content}    OperatingSystem.Get File    ${OUTPUT_DIR}/bip_log2.csv
#    ${check_status}    Run Keyword And Return Status    Should Match Regexp    ${csv_content}    ${CHECK_POINT_REGEXP2}
#    Should Be True    ${check_status}
#    #Check point5
#    Check Layer For Cell    ${TEST_LOG_DIRECTORY}/ttitrace/1/output_ul.csv    54    ${RANK2}
#    #Check SLIV On Specific Slot In TTI    log_id=2    SLIV=53.0    slot=0    SLIVLIST=${SLIVLIST_1}
#    #Check SLIV On Specific Slot In TTI    log_id=2    SLIV=53.0    slot=5    SLIVLIST=${SLIVLIST_1}
#    #Check SLIV On Specific Slot In TTI    log_id=2    SLIV=55.0    slot=1    SLIVLIST=${SLIVLIST_1}
#    #Check SLIV On Specific Slot In TTI    log_id=2    SLIV=55.0    slot=3    SLIVLIST=${SLIVLIST_1}
#    #Check SLIV On Specific Slot In TTI    log_id=2    SLIV=55.0    slot=6    SLIVLIST=${SLIVLIST_1}
#    #Check SLIV On Specific Slot In TTI    log_id=2    SLIV=55.0    slot=8    SLIVLIST=${SLIVLIST_1}
#    #step6
#    SA 5G Detach    ue_id=1
#    SA 5G Detach    ue_id=2
#    SA 5G Detach    ue_id=3
#    #Check point6
#    CUDU_L2 Check DTXNACK Rate    3
#    CUDU_L2 Check UL DTXCRC Rate    3
#
#*** Keywords ***
