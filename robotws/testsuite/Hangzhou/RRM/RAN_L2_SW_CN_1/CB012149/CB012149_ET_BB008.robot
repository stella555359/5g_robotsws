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
#${WTS_CFG_BB008}               wts_CB012149_BB008.cfg
#${LOCAL_WTS_DIR}              ${CURDIR}/Config/WTS/
#${SCF_BB008}                   ${SCF_PATH}/CB012149_BB008.xml
#${iphy_BB008}                  ${CURDIR}/Config/IPHY/iphy_BB008.xml
#${SWCONFIG_BB008}              0x4B000F=1;
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
#
#*** Test Cases ***
#CB012149ET-BB008_Mux UCI bit for UE configured UL TX switch
#    [Documentation]
#    ...    Precondition:
#    ...      FDD 10M and pcell TDD with 1070 frame structure.
#    ...      with beam=6 and refinebeam is enabled
#    ...      NRBTS.sCellActivationMethod=1:blind
#    ...      A1 based scell added configured.
#    ...    Test Steps:
#    ...      Step1: 9 UEs attach to FDD cell as pcell with UL TX switch capablity
#    ...      Step2: UE report A1 to trigger scells additon.
#    ...      Step3: Start big UL and  big DL data transfer to trigger scell active.
#    ...      Step4: UEs start small data on UL
#    ...      Step5: UEs start big data on UL.
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
#    [Tags]    caseBB008    Manual_suqian    TA_suqian
#    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG_BB008}
#    ...        AND    Suite Setup Update GNB    scf_file=${SCF_BB008}    iphy_file=${iphy_BB008}    swconfig_param=${SWCONFIG_BB008}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Common Test Setup 2
#    ...        AND    Suite Setup Start WTS And Check OnAir    ${wts_cfg}
#    #Step1
#    Start MultiUE Register And A1 Addition    2    10
#    Start UL And DL Traffic For MultiUE    2    10
#    Start Gnb BIP Log
#    Sleep    1s    reason=Wait for log
#    Stop Gnb BIP Log    ${TEST_LOG_DIRECTORY}/1/
#    CUDU_L2 Capture And Decode TTitrace    1   2
#    Stop UL traffic For MultiUE    2    10
#    Start Gnb BIP Log
#    Sleep    1s    reason=Wait for log
#    Stop Gnb BIP Log    ${TEST_LOG_DIRECTORY}/2/
#    CUDU_L2 Capture And Decode TTitrace    2   2
#    Recover UL traffic For MultiUE    2    10
#    Start Gnb BIP Log
#    Sleep    1s    reason=Wait for log
#    Stop Gnb BIP Log    ${TEST_LOG_DIRECTORY}/3/
#    CUDU_L2 Capture And Decode TTitrace    3   2
#    #Check point1
#    Check Layer For Cell    ${TEST_LOG_DIRECTORY}/ttitrace/1/output_ul.csv    54    ${RANK2}
#    #Check point3
#    ${bip_log}    Set Variable    ${TEST_LOG_DIRECTORY}/1/5GBipL2L1_filtering_off.pcap
#    Convert BIP To CSV By MCShark    ${bip_log}    ${OUTPUT_DIR}/bip_log.csv    ${FILTER1}    ${CSV_TITLE_LIST1}
#    ${csv_content}    OperatingSystem.Get File    ${OUTPUT_DIR}/bip_log.csv
#    ${check_status}    Run Keyword And Return Status    Should Match Regexp    ${csv_content}    ${CHECK_POINT_REGEXP1}
#    Should Be True    ${check_status}
#    Convert BIP To CSV By MCShark    ${bip_log}    ${OUTPUT_DIR}/bip_log2.csv    ${FILTER2}    ${CSV_TITLE_LIST2}
#    ${csv_content}    OperatingSystem.Get File    ${OUTPUT_DIR}/bip_log2.csv
#    ${check_status}    Run Keyword And Return Status    Should Match Regexp    ${csv_content}    ${CHECK_POINT_REGEXP2}
#    Should Be True    ${check_status}
#    #Check point4
#    Check Layer For Cell    ${TEST_LOG_DIRECTORY}/ttitrace/3/output_ul.csv    54    ${RANK2}
#    Check SLIV is Correct As Expected    log_id=3    slotid=0    expected_value=53.0
#    Check SLIV is Correct As Expected    log_id=3    slotid=5    expected_value=53.0
#    Check SLIV is Correct As Expected    log_id=3    slotid=6    expected_value=55.0
#    Check SLIV is Correct As Expected    log_id=3    slotid=1    expected_value=55.0
#    Check SLIV is Correct As Expected    log_id=3    slotid=3    expected_value=55.0
#    Check SLIV On Specific Slot In TTI    log_id=3    SLIV=55.0    slot=8    SLIVLIST=${SLIVLIST_1}
#    #step6
#    Detach MultiUE    2    10
#    #Check point5
#    CUDU_L2 Check DTXNACK Rate    3
#    CUDU_L2 Check UL DTXCRC Rate    3
#
#*** Keywords ***
#
#Start MultiUE Register And A1 Addition
#    [Arguments]    ${start_ue_id}   ${end_ue_id}
#	FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
#    SA Single UE Attach    ${ue_idx}
#    Sleep    10s    reason=Wait for log
#    Trigger A1 Addition For BB007    ${ue_idx}
#	END
#
#Start UL And DL Traffic For MultiUE
#    [Arguments]    ${start_ue_id}   ${end_ue_id}
#	FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
#    Execute Egate Command    cmd=trf_data_start ue=${ue_idx} pdu=1 qfi=1 dir=dl mbps=170 trf_id=1
#    Execute Egate Command    cmd=trf_data_start ue=${ue_idx} pdu=1 qfi=1 dir=dl mbps=170 trf_id=2
#    Execute Egate Command    cmd=trf_data_start ue=${ue_idx} pdu=1 qfi=1 dir=ul mbps=170 trf_id=1
#    Sleep    10s    reason=Wait for traffic stable
#    Get And Check Scell Infos    ${1T1F_SCELLS}
#	END
#
#Stop UL traffic For MultiUE
#    [Arguments]    ${start_ue_id}   ${end_ue_id}
#	FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
#    Execute Egate Command    cmd=trf_data_stop ue=${ue_idx} pdu=1 dir=ul trf_id=1
#    Sleep    10s    reason=Wait for traffic stable
#	END
#
#Recover UL traffic For MultiUE
#    [Arguments]    ${start_ue_id}   ${end_ue_id}
#	FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
#    Execute Egate Command    cmd=trf_data_start ue=${ue_idx} pdu=1 qfi=1 dir=ul mbps=170 trf_id=1
#    Sleep    10s    reason=Wait for traffic stable
#	END
#
#Detach MultiUE
#    [Arguments]    ${start_ue_id}   ${end_ue_id}
#	FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
#    SA 5G Detach    ${ue_idx}
#    Sleep    10s    reason=Wait for log
#	END
