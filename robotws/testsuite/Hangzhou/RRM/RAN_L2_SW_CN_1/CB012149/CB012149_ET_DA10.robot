*** Settings ***
Documentation    ...
#Resource           ./CB012149_resource.robot
#Resource           ./../CUDU_L2/common_setup_teardown.robot
#Suite Setup        Common Suite Setup 2
#Test Teardown      Common Test Teardown 2
#Suite Teardown     Common Suite Teardown 2
#Force Tags         CLOUD_5G_I_BOO_AP_LOO    SBTS00
#...                RAN_5G    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD
#
#*** Variables ***
#${SCF_PATH}                   ${CURDIR}/Config/SCF
#${WTS_DIR}                    /opt/iphy/latest
#${WTS_CFG_DA10}               wts_CB012149_DA10.cfg
#${LOCAL_WTS_DIR}              ${CURDIR}/Config/WTS/
#${SCF_DA10}                   ${SCF_PATH}/CB012149_DA10.xml
#${iphy_DA10}                  ${CURDIR}/Config/IPHY/iphy_DA10.xml
#${SWCONFIG_DA10}              0x4B000F=1;
#${UE_ID}                      3
#${1T1F_SCELLS}                ('1', '51', '66')
#${TDD_UNMUTE_SLOT_1208}       [4, 9, 14, 19]
#${RANK2}                      ['RANK2']
#${RANK1}                      ['RANK1']
#${SLIVLIST_slot1_1}           ["69.0","55.0"]
#${SLIVLIST_slot1_2}           ["55.0","69.0"]
#${SLIVLIST_1}                 ["","27.0"]
#
#*** Test Cases ***
#CB012149ET-DA010_UL Tx Switching UE with wideband TAS periodic SRS
#    [Documentation]
#    ...    Precondition:
#    ...      FDD 20M and pcell TDD with 1208 frame structure.
#    ...      :with beam=6 and refine beam is enable
#    ...      NRBTS.sCellActivationMethod=1:bufferBased
#    ...      A1 based scell added configured.
#    ...    Test Steps:
#    ...      Step1: Attach UE3 to TDD Pcell and make SA call.
#    ...      Step2: UEs report A1 to trigger scells additon.
#    ...      Step3: Start big DL and UL data transfer to trigger all scell active.
#    ...      Step4: start small data on UL for UE.
#    ...      Step5: start big data on UL.
#    ...      Step6: UE released.
#
#    ...    Check point：
#    ...      1. Verify  after data transfer GNB schedule UL data on FDD Pcell which is not overlap with TDD scell
#    ...         and 2 layer on TDD cell at TDD UL slot. and Periodic SRS trigger
#	...      2. Verify  FDD pcell  PUSCH slot before or after TDD UL slot SLIV like this:slot1&slot6:S=0,L=11(SLIV 69),
#    ...         and slot0&slot4:S=2,L=12(SLIV 53).other FDD UL scheudle slot use noraml 14 symbol like legacy
#    ...      3. No DTX or NACK on  PUSCH or PUCCH.
#    [Tags]    caseDA10    Manual_suqian    TA_suqian
#    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG_DA10}
#    ...        AND    Suite Setup Update GNB    scf_file=${SCF_DA10}    iphy_file=${iphy_DA10}    swconfig_param=${SWCONFIG_DA10}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Common Test Setup 2
#    ...        AND    Suite Setup Start WTS And Check OnAir    ${wts_cfg}
#    #Step1
#    SA Single UE Attach    ${UE_ID}
#    #Step2
#    CB012149_resource.Trigger A1 Scell Addition    ${UE_ID}    1    105
#    Sleep    2s    reason=Wait for log
#    #checkpoint 2
#    Get And Check Scell Infos    ${1T1F_SCELLS}
#    #Step3
#    Send Large Traffic for DA10
#    Start SA UE Big DL Traffic Internal    3    mbps=1750
#    Sleep    10s    #sleep for stable traffic
#    Start Gnb BIP Log
#    Sleep    1s    reason=Wait for log
#    Stop Gnb BIP Log    ${TEST_LOG_DIRECTORY}/1/
#    CUDU_L2 Capture And Decode TTitrace    1   2
#    #Step4
#    Send Small Traffic over DRB1    3
#    #Step5
#    Recover Traffic for DA10
#    Start Gnb BIP Log
#    Sleep    1s    reason=Wait for log
#    Stop Gnb BIP Log    ${TEST_LOG_DIRECTORY}/2/
#    CUDU_L2 Capture And Decode TTitrace    2   2
#    #Check point1
#    Check Layer For Cell    ${TEST_LOG_DIRECTORY}/ttitrace/1/output_ul.csv    52    ${RANK2}
#    Check Layer For Cell    ${TEST_LOG_DIRECTORY}/ttitrace/1/output_ul.csv    51    ${RANK1}
#    #Check point2
#    Check SLIV is Correct As Expected    log_id=1    slotid=0    expected_value=53.0
#    Check SLIV is Correct As Expected    log_id=1    slotid=5    expected_value=53.0
#    Check SLIV On Specific Slot For 1208    log_id=1    SLIV1=${SLIVLIST_slot1_1}    SLIV2=${SLIVLIST_slot1_2}    slot=1    SLIVLIST=${SLIVLIST_1}
#    Check SLIV On Specific Slot For 1208    log_id=1    SLIV1=${SLIVLIST_slot1_1}    SLIV2=${SLIVLIST_slot1_2}    slot=6    SLIVLIST=${SLIVLIST_1}
#    #step6
#    SA 5G Detach    ue_id=3
#    #Check point3
#    Check Layer For Cell    ${TEST_LOG_DIRECTORY}/ttitrace/2/output_ul.csv    52    ${RANK2}
#    Check Layer For Cell    ${TEST_LOG_DIRECTORY}/ttitrace/2/output_ul.csv    51    ${RANK1}
#    CUDU_L2 Check DTXNACK Rate    2
#    CUDU_L2 Check UL DTXCRC Rate    2
#
#*** Keywords ***
