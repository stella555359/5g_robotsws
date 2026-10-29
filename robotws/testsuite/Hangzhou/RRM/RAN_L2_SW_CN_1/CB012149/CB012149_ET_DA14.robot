*** Settings ***
Resource           ./CB012149_resource.robot
Resource           ./../CUDU_L2/common_setup_teardown.robot
Suite Setup        Common Suite Setup 2
Test Teardown      Common Test Teardown 2
Suite Teardown     Common Suite Teardown 2
Force Tags         CLOUD_5G_I_BOO_AP_LOO    SBTS00
...                RAN_5G    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD

*** Variables ***
${SCF_PATH}                   ${CURDIR}/Config/SCF
${WTS_DIR}                    /opt/iphy/latest
${WTS_CFG_DA14}               wts_CB012149_DA14.cfg
${LOCAL_WTS_DIR}              ${CURDIR}/Config/WTS
${SCF_DA14}                   ${SCF_PATH}/CB012149_DA14.xml
${iphy_DA14}                  ${CURDIR}/Config/IPHY/iphy_DA14.xml
${SWCONFIG_DA14}              0x4B000F=1;0x58012d=2
${UE_ID1}                      1
${UE_ID2}                      2
${UE_ID3}                      3
${RANK2}                       ['RANK2']
${RANK1}                       ['RANK1']
${1T1F_SCELLS}                ('1', '54', '66')
${SLIVLIST_1}                   ["","27.0","55.0","69.0","81.0"]
${SLIVLIST_2}                   ["","27.0","55.0","53.0","81.0"]
${SLIVLIST_3}                   ["","27.0","55.0","69.0","53.0"]
${SLIVLIST_4}                   ["","27.0","81.0","69.0","53.0"]
@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}

*** Test Cases ***
CB012149ET-DA014__Activate_adaptive_retransmission_for_1208_frame_structure
    [Documentation]
    ...    Precondition:
    ...      FDD 20M and pcell TDD with 1208 frame structure.
    ...      NRBTS/NRCELL-maxNumOfUlCaUeParallelTx=2
    ...      A1 based scell added configured.
    ...    Test Steps:
    ...      Step1: Attach UE1 to TDD Pcell and make SA call.
    ...      Step2: Send A1 report, 1 scell is added
    ...      Step3: start big DL and UL traffic for UE1.
    ...      Step4: Attach UE2 and UE3 to TDD Pcell and make SA call.
    ...      Step5: start big DL and UL traffic for UE2.
    ...      Step6: Simulate UE1 UL retransmission by UL bler.
    ...      Step7: Simulate UE2 and UE3 WITH bad SINR to trigger UL rank from 2 to 1.
    ...      Step8: Cancel BLER on PCELL and check no DTX or CRC NOK
    ...      Step9: Detach all UEs
    [Tags]    caseDA14    Manual_lading    TA_lading
    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG_DA14}
    ...        AND    Suite Setup Update GNB    scf_file=${SCF_DA14}    iphy_file=${iphy_DA14}    swconfig_param=${SWCONFIG_DA14}
    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
    ...        AND    Common Test Setup 2
    ...        AND    Suite Setup Start WTS And Check OnAir    ${wts_cfg}
    #Step1&Step2&Step3
    Attach 1st CA UE and send big ULDL traffic    ${UE_ID1}    ${1T1F_SCELLS}
    #Step4&Step5
    Attach nonCA UE and send big ULDL traffic    ${UE_ID2}
    Attach nonCA UE and send big ULDL traffic    ${UE_ID3}
    #Collect logs and check log
    CUDU_L2 Capture And Decode TTitrace    1    2
    CUDU_L2 Check DTXNACK Rate    1
    #Step5&Step6&Step7
    Trigger UL BLER For Three UEs
    #Check point1 for step5&6&7
    CUDU_L2 Capture And Decode TTitrace    2    3
    Check Layer For Cell    ${TEST_LOG_DIRECTORY}/ttitrace/2/output_ul.csv    55    ${RANK2}
    Check Layer For Cell    ${TEST_LOG_DIRECTORY}/ttitrace/2/output_ul.csv    54    ${RANK1}
    #Check point2 for step5&6&7
    #Check SLIV ON Special slot
    #Check point2 for step5&6&7
    CUDU_L2 Check DTXNACK Rate    2
    #Step8
    Cancel BLER on PCELL for UE    1
    #Check point for step8
    CUDU_L2 Capture And Decode TTitrace    3    3
    CUDU_L2 Check DTXNACK Rate    3
    #step9
    Detach all UEs








*** Keywords ***
Check SLIV ON Special slot
    Check SLIV On Specific Slot In TTI    log_id=2    SLIV=53.0    slot=0    SLIVLIST=${SLIVLIST_1}
    Check SLIV On Specific Slot In TTI    log_id=2    SLIV=69.0    slot=1    SLIVLIST=${SLIVLIST_2}
    Check SLIV On Specific Slot In TTI    log_id=2    SLIV=81.0    slot=5    SLIVLIST=${SLIVLIST_3}
    Check SLIV On Specific Slot In TTI    log_id=2    SLIV=55.0    slot=6    SLIVLIST=${SLIVLIST_4}

Detach all UEs
    SA 5G Detach    ue_id=1
    SA 5G Detach    ue_id=2
    SA 5G Detach    ue_id=3
