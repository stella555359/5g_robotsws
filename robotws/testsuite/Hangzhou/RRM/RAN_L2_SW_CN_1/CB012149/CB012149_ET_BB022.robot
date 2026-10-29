*** Settings ***
Documentation    ...
Resource           ./CB012149_resource.robot
Resource           ./../CUDU_L2/common_setup_teardown.robot
Suite Setup        Common Suite Setup 2
Test Teardown      Common Test Teardown 2
Suite Teardown     Common Suite Teardown 2
Force Tags         CLOUD_5G_I_LPQ_AP_LOO    SBTS00
...                RAN_5G    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD

*** Variables ***
${SCF_PATH}                   ${CURDIR}/Config/SCF
${WTS_DIR}                    /opt/iphy/latest
${WTS_CFG_BB022}               wts_CB012149_BB022.cfg
${LOCAL_WTS_DIR}              ${CURDIR}/Config/WTS/
${SCF_BB022}                   ${SCF_PATH}/CB012149_BB022.xml
${iphy_BB022}                  ${CURDIR}/Config/IPHY/iphy_BB022.xml
${SWCONFIG_BB022}              0x4B000F=1;0x58012d=2
${UE1_ID}                      1
${UE2_ID}                      2
${UE3_ID}                      3
${1T1F_SCELLS}                ('1', '54', '41')
${SLIVLIST_1}                 ["","27.0"]
${SLIVLIST_slot1_1}                 ["69.0","55.0"]
${SLIVLIST_slot1_2}                 ["55.0","69.0"]
${RANK2}                       ['RANK2']
${RANK1}                      ['RANK1']
${FILTER1}                SEPARATOR=${EMPTY}    (UlData_pucchReceiveReqPucchResource_t.firstSymbol == 4) &&
...                      (UlData_pucchReceiveReqPucchResource_t.numOfSymbols == 7)
@{CSV_TITLE_LIST1}        UlData_pucchReceiveReqPucchResource_t.firstSymbol    UlData_pucchReceiveReqPucchResource_t.numOfSymbols
${CHECK_POINT_REGEXP1}    "UlData_PucchReceiveReq\\s*","4","7"
${FILTER2}                SEPARATOR=${EMPTY}    (UlData_pucchReceiveReqPucchResource_t.firstSymbol == 3) &&
...                      (UlData_pucchReceiveReqPucchResource_t.numOfSymbols == 8)
@{CSV_TITLE_LIST2}        UlData_pucchReceiveReqPucchResource_t.firstSymbol    UlData_pucchReceiveReqPucchResource_t.numOfSymbols
${CHECK_POINT_REGEXP2}    "UlData_PucchReceiveReq\\s*","3","8"
${FILTER3}                SEPARATOR=${EMPTY}    UlData_srsReceiveReqSubcell_t.srsSuMimoEnable == 1
@{CSV_TITLE_LIST3}        UlData_srsReceiveReqSubcell_t.srsSuMimoEnable
${CHECK_POINT_REGEXP3}    "UlData_SrsReceiveReq\\s*","1"
@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}

*** Test Cases ***
CB012149ET-BB022_PUSCH typeB Mulit UEs configured UL TX with with FDD ASRS PUSCH typeA for Non CA UE and Psrs for CA ue
    [Documentation]
    ...    Precondition:
    ...      FDD 10M and pcell TDD with 1070 frame structure.
    ...      with beam=4  and refine beam is enable
    ...      NRBTS.sCellActivationMethod=1:bufferBased
    ...      A1 based scell added configured.
    ...    Test Steps:
    ...      Step1: UE2 and UE3 attach to FDD cell as pcell, and UE1 without CA capability attach to FDD cell.
    ...      Step2: UE2 and UE3 report A1 to trigger scells additon.
    ...      Step3: Start big UL and DL data for UE1 and UE2 and UE3
    ...      Step4: UE1 simulate bad SINR to trigger UL RANK from  2 to 1.
    ...      Step5: UE2 start small UL and DL data to triger scell deactive
    ...      Step6: UE2 simulate UL BLER and trigger UL Retx on FDD pcell.
    ...      Step7: UE2 start big traffic again
    ...    Check point：
    ...      1. Verify after data transfer GNB schedule UL data on FDD Pcell which is not overlap with TDD scell and 2layer on TDD cell at
    ...         TDD UL slot for UE2 and UE3. Verify when UCI on PUCCH,   PUCCH F1 with  S=4 L=7 and PUCCH F3 with  S=3 L=8 for UE2/UE3.
    ...      2. Verify UE2 FDD pcell PUSCH slot before or after TDD UL slot SLIV like this: slot1 & 3&6&slot8 : S=0, L=11 (SLIV 69) when
    ...         psrs on these slot  and   slot0 & slot5  :S=2, L=12 (SLIV 53). other FDD UL scheudle slot use noraml 14 symbol like legacy.
    ...      3.  Afte step4, UE1 UL Layer from 2 to 1 and ASRS trigger.
    ...      4. Verify UE2&UE3 FDD pcell PUSCH slot before or after TDD UL slot SLIV like this: slot1 & 3&6&slot8 : S=0, L=11 (SLIV 69) and
    ...         slot5 : S=2, L=10  (SLIV 81) when  UE1 asrs on slot5 . other FDD UL scheudle slot use noraml 14 symbol like legacy.
    ...      5. After step6,UL Retx trigger but will not Retx at short symbol pucch slot from noraml pucch slot.
    ...      6. After step7 ,UE1 UL data transfer to TDD scell again due to recover.
    ...      7. No DTX or NACK on  PUSCH or PUCCH.
    [Tags]    caseBB022    Manual_suqian    TA_suqian
    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG_BB022}
    ...        AND    Suite Setup Update GNB    scf_file=${SCF_BB022}    iphy_file=${iphy_BB022}    swconfig_param=${SWCONFIG_BB022}
    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
    ...        AND    Common Test Setup 2
    ...        AND    Suite Setup Start WTS And Check OnAir    ${wts_cfg}
    #Step1~Step3
    SA Single UE Attach    ${UE1_ID}
    Sleep    2s    reason=Wait for log
    Start SA UE Big UL Traffic Internal    ${UE1_ID}    150
    Start SA UE Big DL Traffic Internal    1    mbps=300
    Sleep    10s    #sleep for stable traffic
    SA Single UE Attach    ${UE2_ID}
    Sleep    2s    reason=Wait for log
    Trigger A1 Addition For BB007   ${UE2_ID}
    Sleep    3s    reason=Wait for log
    Get And Check Scell Infos    ${1T1F_SCELLS}
    Send Big Traffic For DL and UL    2
    SA Single UE Attach    ${UE3_ID}
    Trigger A1 Addition For BB007   ${UE3_ID}
    Sleep    3s    reason=Wait for log
    Get And Check Scell Infos    ${1T1F_SCELLS}
    Start SA UE Big UL Traffic Internal    ${UE3_ID}    150
    Start SA UE Big DL Traffic Internal    3    mbps=500
    Sleep    10s    #sleep for stable traffic
    Start Gnb BIP Log
    Sleep    1s    reason=Wait for log
    Stop Gnb BIP Log    ${TEST_LOG_DIRECTORY}/1/
    CUDU_L2 Capture And Decode TTitrace    1   2
    #Step4
    Send Commond To Trigger UE2 Lower Sinr    130    1
    Sleep    10s    #sleep for stable
    Start Gnb BIP Log
    Sleep    1s    reason=Wait for log
    Stop Gnb BIP Log    ${TEST_LOG_DIRECTORY}/2/
    CUDU_L2 Capture And Decode TTitrace    2   2
    #Step5
    Send Small Traffic For UL and DL    2
    #Step6
    Set Value For Large UL BLER testmode    2
    Sleep    10s    #sleep for stable
    Start Gnb BIP Log
    Sleep    1s    reason=Wait for log
    Stop Gnb BIP Log    ${TEST_LOG_DIRECTORY}/3/
    CUDU_L2 Capture And Decode TTitrace    3   2
    #Step7
    Cancel BLER on PCELL for UE    2
    Recover Traffic For UL and DL    2
    CUDU_L2 Capture And Decode TTitrace    4   2
    #Check point1~2
    #Check SLIV On Specific Slot In TTI    log_id=2    SLIV=53.0    slot=0    SLIVLIST=${SLIVLIST_1}
    #Check SLIV On Specific Slot In TTI    log_id=2    SLIV=53.0    slot=5    SLIVLIST=${SLIVLIST_1}
    #Check SLIV On Specific Slot In TTI    log_id=2    SLIV=55.0    slot=6    SLIVLIST=${SLIVLIST_1}
    #Check SLIV On Specific Slot In TTI    log_id=2    SLIV=55.0    slot=8    SLIVLIST=${SLIVLIST_1}
    #Check SLIV On Specific Slot In TTI    log_id=1    SLIV=55.0    slot=8    SLIVLIST=${SLIVLIST_1}
    #Check SLIV On Specific Slot For 1208    log_id=1    SLIV1=${SLIVLIST_slot1_1}    SLIV2=${SLIVLIST_slot1_2}    slot=1    SLIVLIST=${SLIVLIST_1}
    #Check SLIV On Specific Slot For 1208    log_id=1    SLIV1=${SLIVLIST_slot1_1}    SLIV2=${SLIVLIST_slot1_2}    slot=3    SLIVLIST=${SLIVLIST_1}
    #Check point3
    ${bip_log}    Set Variable    ${TEST_LOG_DIRECTORY}/2/5GBipL2L1_filtering_off.pcap
    Convert BIP To CSV By MCShark    ${bip_log}    ${OUTPUT_DIR}/bip_log3.csv    ${FILTER3}    ${CSV_TITLE_LIST3}
    ${csv_content}    OperatingSystem.Get File    ${OUTPUT_DIR}/bip_log3.csv
    ${check_status}    Run Keyword And Return Status    Should Match Regexp    ${csv_content}    ${CHECK_POINT_REGEXP3}
    #Check point4
    #Check SLIV On Specific Slot In TTI    log_id=2    SLIV=53.0    slot=0    SLIVLIST=${SLIVLIST_1}
    #Check SLIV On Specific Slot In TTI    log_id=2    SLIV=53.0    slot=5    SLIVLIST=${SLIVLIST_1}
    #Check SLIV On Specific Slot In TTI    log_id=2    SLIV=55.0    slot=6    SLIVLIST=${SLIVLIST_1}
    #Check SLIV On Specific Slot In TTI    log_id=2    SLIV=55.0    slot=8    SLIVLIST=${SLIVLIST_1}
    #Check SLIV On Specific Slot For 1208    log_id=2    SLIV1=${SLIVLIST_slot1_1}    SLIV2=${SLIVLIST_slot1_2}    slot=1    SLIVLIST=${SLIVLIST_1}
    #Check SLIV On Specific Slot For 1208    log_id=2    SLIV1=${SLIVLIST_slot1_1}    SLIV2=${SLIVLIST_slot1_2}    slot=3    SLIVLIST=${SLIVLIST_1}
    #Check point5
    #Check Layer For Cell    ${TEST_LOG_DIRECTORY}/ttitrace/3/output_ul.csv    54    ${RANK2}
    #step6
    SA 5G Detach    ue_id=1
    SA 5G Detach    ue_id=2
    SA 5G Detach    ue_id=3
    #Check point6
    CUDU_L2 Check DTXNACK Rate    1
    CUDU_L2 Check UL DTXCRC Rate    1