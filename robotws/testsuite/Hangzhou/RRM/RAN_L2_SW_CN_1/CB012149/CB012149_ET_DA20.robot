*** Settings ***
Documentation    ...
Resource           ./CB012149_resource.robot
Resource           ./../CUDU_L2/common_setup_teardown.robot
Suite Setup        Common Suite Setup 2
Test Teardown      Common Test Teardown 2    check_tl=False
Suite Teardown     Common Suite Teardown 2
Force Tags         CLOUD_5G_I_BOO_AP_LOO    SBTS00
...                RAN_5G    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD

*** Variables ***
${SCF_PATH}                   ${CURDIR}/Config/SCF
${WTS_DIR}                    /opt/iphy/latest
${WTS_CFG_DA20}               wts_CB012149_DA20.cfg
${LOCAL_WTS_DIR}              ${CURDIR}/Config/WTS/
${SCF_DA20}                   ${SCF_PATH}/CB012149_DA20.xml
${iphy_DA20}                  ${CURDIR}/Config/IPHY/iphy_DA20.xml
${SWCONFIG_DA20}              0x4B000F=1;0x58012d=2
${UE1_ID}                      1
${UE2_ID}                      2
${1T1F_SCELLS}                ('1', '54', '66')
${TDD_MUTE_SLOT_1208}              [4, 14]
${SLIVLIST_1}                 ["","27.0"]
${SLIVLIST_slot1_1}                 ["69.0","55.0"]
${SLIVLIST_slot1_2}                 ["55.0","69.0"]
${RANK2}                       ['RANK2']
${RANK1}                      ['RANK1']
@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}

*** Test Cases ***
CB012149ET-DA020_UL muting for TDD pcell
    [Documentation]
    ...    Precondition:
    ...      FDD 20M and pcell TDD with 1208 frame structure.
    ...      :with beam=4 and refine beam is enable
    ...      NRBTS.sCellActivationMethod=1:blind
    ...      A1 based scell added configured.
    ...    Test Steps:
    ...      Step1: UE1 attach to TDD cell as pcell, UE2 without CA capability attach to FDD cell.
    ...      Step2: UE1 report A1 to trigger scells additon.
    ...      Step3: UE1 start  big data on  UL and DL.
    ...      Step4: Start big UL and DL data for  UE2
    ...      Step5: UE2 simulate bad SINR to trigger UL RANK from 2 to 1.
    ...      Step6: UE released.

    ...    Check point：
    ...      1. After step3 Verify UE1 TDD pcell  with UL 2 layer and  slot 9 and 19 are mute.
    ...         For FDD scell PUSCH slot before or after TDD UL slot SLIV like this: slot1 or  slot6 : S=0, L=11  (SLIV 69).
    ...         other FDD UL scheudle slot use noraml 14 symbol like legacy.
    ...      2. After step5, UE2 UL Layer from 2 to 1 and ASRS trigger.
    ...         Verify UE1 TDD pcell  with UL 2 layer and For FDD scell PUSCH slot before or after TDD UL slot SLIV like this:
    ...         slot1 or  slot6 : S=0, L=11  (SLIV 69)  , slot5:  s=2, l=12(SLIV53) . other FDD UL scheudle slot use noraml 14 symbol like legacy.
    ...      3. No DTX or NACK on  PUSCH or PUCCH.
    [Tags]    caseDA20    Manual_suqian    TA_suqian
    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG_DA20}
    ...        AND    Suite Setup Update GNB    scf_file=${SCF_DA20}    iphy_file=${iphy_DA20}    swconfig_param=${SWCONFIG_DA20}
    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
    ...        AND    Common Test Setup 2
    ...        AND    Suite Setup Start WTS And Check OnAir    ${wts_cfg}
    #Step1
    SA Single UE Attach    ${UE2_ID}
    Sleep    2s    reason=Wait for log
    Send Large Traffic Over DRB1    2
    Start SA UE Big DL Traffic Internal    2    mbps=500
    Sleep    10s    #sleep for stable traffic
    Send Commond To Trigger UE2 Lower Sinr
    #Step2
    SA Single UE Attach    ${UE1_ID}
    CB012149_resource.Trigger A1 Scell Addition    ${UE1_ID}    1    100
    #checkpoint 1
	Sleep    3s    reason=Wait for log
    Get And Check Scell Infos    ${1T1F_SCELLS}
    #Step3
    Send Large Traffic Over DRB1
    Start SA UE Big DL Traffic Internal    1    mbps=1750
    Sleep    10s    #sleep for stable traffic
    Start Gnb BIP Log
    Sleep    1s    reason=Wait for log
    Stop Gnb BIP Log    ${TEST_LOG_DIRECTORY}/1/
    CUDU_L2 Capture And Decode TTitrace    1   2
    #Check point1
    #Check Slot For TDD for 1208    ${TEST_LOG_DIRECTORY}/ttitrace/1/output_ul.csv     ulFdSchedData.dciFormat    55    ${TDD_MUTE_SLOT_1208}
    #Check SLIV On Specific Slot In TTI    log_id=1    SLIV=55.0    slot=6    SLIVLIST=${SLIVLIST_1}
    #Check SLIV On Specific Slot For 1208    log_id=1    SLIV1=${SLIVLIST_slot1_1}    SLIV2=${SLIVLIST_slot1_2}    slot=1    SLIVLIST=${SLIVLIST_1}
    #Check Layer For Cell    ${TEST_LOG_DIRECTORY}/ttitrace/1/output_ul.csv    55    ${RANK2}
    #Check Layer For Cell    ${TEST_LOG_DIRECTORY}/ttitrace/1/output_ul.csv    54    ${RANK1}
    #Check point2
    #Check SLIV On Specific Slot In TTI    log_id=1    SLIV=55.0    slot=5    SLIVLIST=${SLIVLIST_1}
    #Check SLIV On Specific Slot In TTI    log_id=1    SLIV=55.0    slot=9    SLIVLIST=${SLIVLIST_1}
    #step6
    SA 5G Detach    ue_id=1
    SA 5G Detach    ue_id=2
    #Check point3
    CUDU_L2 Check DTXNACK Rate    1
    CUDU_L2 Check UL DTXCRC Rate    1
