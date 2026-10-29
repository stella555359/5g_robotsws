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
${LOCAL_WTS_DIR}              ${CURDIR}/Config/WTS/
${SWCONFIG_DA11}              0x4B000F=1;
${UE_ID}                      1
${WTS_CFG_DA11}               wts_CB012149_DA11.cfg
${SCF_DA11}                   ${SCF_PATH}/CB012149_DA11.xml
${iphy_DA11}                  ${CURDIR}/Config/IPHY/iphy_DA11.xml
${SLIVLIST_1}                 ["0", "","27.0","41.0","53.0","55.0","255.0"]
${SLIVLIST_2}                 ["0", "","27.0","41.0","55.0","69.0","255.0"]
@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}

*** Test Cases ***
CB012149ET-DA011_CG_configured__in_TDD_as_Pcell_for_TF_UL_TX_switch_UE
    [Documentation]
    ...    Precondition:
    ...      FDD 20M and pcell TDD with 1208 frame structure.
    ...      :with beam=4 and refine beam is enable
    ...      NRBTS.sCellActivationMethod=blind sCellAdditionMethod =0:blind
    ...    Test Steps:
    ...      Step1: UE attach to TDD cell as pcell
    ...      Step2: PDU seesion setup for 5QI8.
    ...      Step3: UE report A1 to trigger scells additon.
    ...      Step4: Start UL data for 5QI8.
    ...      Step5: PDU seesion setup for 5QI6.
    ...      Step6: UE start big DL and UL data for 5QI6
    ...      Step7: PDU session modify to release 5QI8
    ...      Step8: PDU session setup for 5QI8.
    ...      Step9: Start UL data for 5QI8.
    ...    Check point:
    ...      1. Check CG configure successfully and UL data send on CG slot on TDD pcell.
    ...      2. After scell active by step6,periodic SRS trigger for TDD scell.FDD pcell PUSCH slot before or after TDD
    ...      UL slot SLIV like this:   slot1 & slot6 : S=0, L=11  (SLIV 69),  and   slot0 & slot5  :S=2, L=12   (SLIV 53).
    ...      other FDD UL schedule slot use normal 14 symbol like legacy.
    ...      3. Verify after data transfer GNB schedule UL data on FDD Pcell which is not overlap with TDD scell and 2
    ...      layer on TDD cell at TDD UL slot.
    ...      4. After step 7,Verify CG release.
    ...      5. No DTX/CRC NOK
    [Tags]    caseDA11    Manual_dguan   TA_dguan
    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG_DA11}
    ...        AND    Suite Setup Update GNB    scf_file=${SCF_DA11}    iphy_file=${iphy_DA11}    swconfig_param=${SWCONFIG_DA11}
    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
    ...        AND    Common Test Setup 2
    ...        AND    Suite Setup Start WTS And Check OnAir    ${wts_cfg}
    #Step1&2
    Log To Console   \n-------------step1:gnb ready--------------------------------------
    SA Single UE Attach    ${UE_ID}
    #Step3
    CB012149_resource.Trigger A1 Scell Addition    ${UE_ID}    1    100
    #checkpoint 1
    Check Egate Log For CG Status    setup
    Log To Console   \n-------------step2:ue attach and a1--------------------------------------
    #Step4
    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=ul bps=6000000 trf_id=1
    Log To Console   \n-------------step1:ul data has trnasfer--------------------------------------

    Sleep    2s
    ute_wtssim.Execute Egate Command    cmd=ue_stats_nr id=1 type=pusch scell=0-3
    Log To Console   \n-------------egate show TUPT--------------------------------------

    CUDU_L2 Capture And Decode TTitrace    1   3
    Log To Console   \n-------------decode TTI--------------------------------------

    #checkpoint 1
    ute_wtssim.Execute Egate Command    cmd=ue_stats_nr id=1 type=pusch scell=0-3
    Check CsRnti In TTI    log_id=1    numofcsrnti=2
    ute_wtssim.Execute Egate Command    cmd=ue_stats_nr id=1 type=pusch scell=0-3
    #Step5
    Execute Egate Command    cmd=qosflow_modify qos_flow=2 default=on
    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=2
    Setup PDU Session    ${UE_ID}    2
    #Step6
    Start SA UE Big DL Traffic Internal    ${UE_ID}    700    2
    Start SA UE Big UL Traffic Internal    ${UE_ID}    170    2
    Sleep    5s
    CUDU_L2 Capture And Decode TTitrace    2   2
    #checkpoint 2
#    Check SLIV On Specific Slot In TTI    log_id=2    SLIV=69.0    slot=1    SLIVLIST=${SLIVLIST_1}
    Check SLIV On Specific Slot In TTI    log_id=2    SLIV=53.0    slot=0    SLIVLIST=${SLIVLIST_2}
    Check SLIV On Specific Slot In TTI    log_id=2    SLIV=53.0    slot=5    SLIVLIST=${SLIVLIST_2}
    #checkpoint 3
    Check SlotNum Of UL In TTI    log_id=2    physcellid=54    Numofslot=6
    Start Gnb BIP Log
    Sleep    2s
    Stop Gnb BIP Log    ${TEST_LOG_DIRECTORY}
    #Step7
    SA 5G PDU Session Release    ${UE_ID}    1
    #checkpoint 4
    Check Egate Log For CG Status    release
    Execute Egate Command    cmd=qosflow_modify qos_flow=1 default=on
    #Step8
    Sleep    2s
    Setup PDU Session    ${UE_ID}    1
    #Step9
    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=ul bps=6000000 trf_id=1
    Sleep    5s
    CUDU_L2 Capture And Decode TTitrace    3   2
    #checkpoint 5
    CUDU_L2 Check UL DTXCRC Rate    3