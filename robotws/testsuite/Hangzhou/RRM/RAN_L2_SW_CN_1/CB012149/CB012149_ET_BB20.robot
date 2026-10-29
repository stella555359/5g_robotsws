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
#${WTS_CFG_BB20}               wts_CB012149_BB20.cfg
#${LOCAL_WTS_DIR}              ${CURDIR}/Config/WTS
#${SCF_BB20}                   ${SCF_PATH}/CB012149_BB20.xml
#${iphy_BB20}                  ${CURDIR}/Config/IPHY/iphy_BB20.xml
#${SWCONFIG_BB20}              0x4B000F=1;0x58012d=2
#${UE_ID1}                      3
#${UE_ID2}                      1
#${UE_ID3}                      2
#${RANK2}                       ['RANK2']
#${RANK1}                       ['RANK1']
#${1T1F_SCELLS}                ('1', '52', '78')
#${SLIVLIST_1}                   ["","27.0"]
#${SLIVLIST_2}                   ["","27.0","55.0"]
#${SLIVLIST_3}                   ["","27.0"]
#@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}
#
#*** Test Cases ***
#CB012149ET-BB020_PUSCH_typeB_UL_TX_switing_UE_mixed_with_othe_UE_with_differece_PUSCH_QAM_capbility
#    [Documentation]
#    ...    Precondition:
#    ...      FDD 20M and pcell TDD with 1116 0ms frame structure.
#    ...      NRBTS/NRDU/ulTxSwitchingSupportList = 220(ca_F_Fr1T_Sa_switchedUl)
#    ...      A1 based scell added configured.
#    ...    Test Steps:
#    ...      Step1: Attach UE1 to FDD Pcell and make SA call.
#    ...      Step2: Send A1 report, 1 scell is added.
#    ...      Step3: start big DL traffic for UE1.
#    ...      Step4: Attach UE2 and UE3 to FDD Pcell and make SA call.
#    ...      Step5: start big DL and UL traffic for UE2 and UE3.
#    ...      Step6: Simulate UE2 ASRS by UL bler.
#    ...      Step7: start big UL for UE1.
#    ...      Step8: start small UL for UE1.
#    ...      Step9: start big UL for UE1.
#    ...      Step10: Detach all UEs.
#    [Tags]    caseBB20    Manual_lading    TA_lading
#    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG_BB20}
#    ...        AND    Suite Setup Update GNB    scf_file=${SCF_BB20}    iphy_file=${iphy_BB20}    swconfig_param=${SWCONFIG_BB20}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Common Test Setup 2
#    ...        AND    Suite Setup Start WTS And Check OnAir    ${wts_cfg}
#    #Step1 to Step6
#    Attach nonCA UE and send big ULDL traffic    ${UE_ID2}
#    Send Commond To Trigger UE2 Lower Sinr    130    2
#    Attach 1st CA UE and send big DL traffic    ${UE_ID1}    ${1T1F_SCELLS}
#    Attach nonCA UE and send big ULDL traffic    ${UE_ID3}
#    #Step7
#    Send small or big traffic For UL    3    170
#    CUDU_L2 Capture And Decode TTitrace    2    2
#    Check SLIV ON Special slot for step7
#    #Step8
#    Send small or big traffic For UL    3    2
#    CUDU_L2 Capture And Decode TTitrace    3    2
#    Check SLIV ON Special slot for step8
#    #Step9
#    Send small or big traffic For UL    3    170
#    CUDU_L2 Capture And Decode TTitrace    4    2
#    Check SLIV ON Special slot for step9
#    #step10
#    Detach all UEs
#
#*** Keywords ***
#Check SLIV ON Special slot for step7
#    Check SLIV On Specific Slot In TTI    log_id=2    SLIV=53.0    slot=8    SLIVLIST=${SLIVLIST_1}
#    Check SLIV On Specific Slot In TTI    log_id=2    SLIV=69.0    slot=6    SLIVLIST=${SLIVLIST_2}
#    #Check SLIV On Specific Slot In TTI    log_id=2    SLIV=55.0    slot=5    SLIVLIST=${SLIVLIST_3}
#    #Check SLIV On Specific Slot In TTI    log_id=2    SLIV=55.0    slot=9    SLIVLIST=${SLIVLIST_3}
#    Check SLIV On Specific Slot In TTI    log_id=2    SLIV=53.0    slot=3    SLIVLIST=${SLIVLIST_1}
#    Check SLIV On Specific Slot In TTI    log_id=2    SLIV=55.0    slot=1    SLIVLIST=${SLIVLIST_3}
#    Check SLIV On Specific Slot In TTI when ASRS triggered    log_id=2    SLIV=55.0    slot1=5    slot2=9    SLIVLIST=${SLIVLIST_3}
#
#Check SLIV ON Special slot for step8
#    #Check SLIV On Specific Slot In TTI    log_id=3    SLIV=55.0    slot=5    SLIVLIST=${SLIVLIST_3}
#    #Check SLIV On Specific Slot In TTI    log_id=3    SLIV=55.0    slot=9    SLIVLIST=${SLIVLIST_3}
#    Check SLIV On Specific Slot In TTI when ASRS triggered    log_id=3    SLIV=55.0    slot1=5    slot2=9    SLIVLIST=${SLIVLIST_3}
#
#Check SLIV ON Special slot for step9
#    Check SLIV On Specific Slot In TTI    log_id=4    SLIV=53.0    slot=8    SLIVLIST=${SLIVLIST_1}
#    Check SLIV On Specific Slot In TTI    log_id=4    SLIV=69.0    slot=6    SLIVLIST=${SLIVLIST_2}
#    #Check SLIV On Specific Slot In TTI    log_id=4    SLIV=55.0    slot=5    SLIVLIST=${SLIVLIST_3}
#    #Check SLIV On Specific Slot In TTI    log_id=4    SLIV=55.0    slot=9    SLIVLIST=${SLIVLIST_3}
#    Check SLIV On Specific Slot In TTI    log_id=4    SLIV=53.0    slot=3    SLIVLIST=${SLIVLIST_1}
#    Check SLIV On Specific Slot In TTI    log_id=4    SLIV=55.0    slot=1    SLIVLIST=${SLIVLIST_3}
#    Check SLIV On Specific Slot In TTI when ASRS triggered    log_id=4    SLIV=55.0    slot1=5    slot2=9    SLIVLIST=${SLIVLIST_3}
#
#Detach all UEs
#    SA 5G Detach    ue_id=1
#    SA 5G Detach    ue_id=2
#    SA 5G Detach    ue_id=3
