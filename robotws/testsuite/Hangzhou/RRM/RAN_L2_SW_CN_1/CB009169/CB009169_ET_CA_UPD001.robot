*** Settings ***
Documentation      CB009169-CA-UPD001-014
Resource    ./Resources/CB009169_C_resource.robot
Resource    ./../CUDU_L2/common_setup_teardown.robot
Resource    ./../CUDU_L2/common_log_capture.robot
Resource    ./../CB006137/resources/6137_BO_lib.robot
Resource    ./../CB006137/resources/CB006137_BB_resource.robot
Resource    ./../CB006137/resources/CB006137_BC_resource.robot
Test Teardown    Common Test Teardown 2    check_tl=False
Suite Teardown    Common Suite Teardown 2
Force Tags        CLOUD_5G_I_BOO_AP_LOO    SBTS00    CN1_SG09_SM2
...                RAN_5G    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD    CRT

*** Variables ***
${UE_ID}               1
${PROFILE_ID}          1
${GNB_ID}              2
${CELL_ID}             1
${BEARER_ID}           2
${Egatelog_path}       ${CURDIR}
${LOCAL_WTS_DIR}       ${CURDIR}/Config/CB009169_C
${SCF_DIR}             ${CURDIR}/Config/CB009169_C
${9169_RD}             0x4B000F=1
${UPD006_RD}           0x4B000F=1;0x58056B=1;0x580497=1;0x58062d=1;0x580692=1
${UPD017_RD}           0x4B000F=1;0x5900B9=1
${IPHY_UPD010}          ${LOCAL_WTS_DIR}/iphy_CA_UPD001_010.xml
${IPHY_UPD013}         ${LOCAL_WTS_DIR}/iphy_UPD013.xml
${IPHY}                ${LOCAL_WTS_DIR}/iphy_UPD014.xml
${IPHY_UPD017}         ${LOCAL_WTS_DIR}/iphy_UPD017.xml
${9169_UPD006_SCF}     ${SCF_DIR}/SCF_UPD006.xml
${9169_UPD010_SCF}      ${SCF_DIR}/SCF_C_CA_UPD001_010_SRS.xml
${9169_UPD011_SCF}     ${SCF_DIR}/SCF_UPD011.xml
${9169_UPD013_SCF}     ${SCF_DIR}/SCF_UPD013.xml
${9169_UPD014_SCF}     ${SCF_DIR}/SCF_UPD014.xml
${9169_UPD017_SCF}     ${SCF_DIR}/SCF_UPD017.xml
${WTS_CFG_UPD006}      basic_setup_UPD006.cfg
${WTS_CFG_UPD010}       basic_setup_CA_UPD001_010_SRS.cfg
${WTS_CFG_UPD011}      basic_setup_UPD011.cfg
${WTS_CFG_UPD013}      basic_setup_UPD013.cfg
${WTS_CFG_UPD014}      basic_setup_UPD014.cfg
${WTS_CFG_UPD017}      basic_setup_UPD017.cfg
${1T1F_SCELLS}         ('2', '52', '71')
${1T1F_SCELLS_2}       ('1', '50', '71')
${1T2F_SCELLS}         ('1', '51', '71'), ('2', '53', '25')
${2T2F_SCELLS}         ('1', '51', '25'), ('2', '52', '66'), ('3', '61', '41')
${3T1F_SCELLS}         ('1', '51', '25'), ('2', '60', '77'), ('3', '62', '41')
${2T2F_SCELLS_011}     ('1', '51', '25'), ('2', '52', '66'), ('3', '61', '41')
${2T2F_SCELLS_014}     ('1', '50', '71'), ('2', '52', '66'), ('3', '60', '77')
${1208DL_SLOT}         [0, 1, 2, 3, 5, 6, 7, 8, 10, 11, 12, 13, 15, 16, 17, 18]
${1070DL_SLOT}         [0, 1, 2, 3, 5, 6, 7, 10, 11, 12, 13, 15, 16, 17]
${1116_0UL_SLOT}       [4, 5, 14, 15]
${1208_DL_UNMUTE_SLOT}       [1, 2, 3, 6, 7, 8, 10, 11, 12, 13]
${1208_UL_UNMUTE_SLOT}       [4, 14]
${SCRIPT_PATH}        /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_L2_SW_CN_1/CUDU_L2/scripts/
${lfs}                lfs-nw_switch-mirror-tool.sh
${BIP_FILTER1}        dldata_pdcchsendreq&&!(3gpp.rnti == 65535)
${BIP_FILTER2}        3gpp.subcellid
${BIP_FILTER3}        itf_l2_ps_peerctrl_ScellDrxInactivityTimerStatusInd_t.sCellNrCellIdentity
${force_reboot}        ${True}
@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}

*** Test Cases ***
CB009169-CA-UPD001-014_UL_CA_T+F_interworking_with_Coordination_of_TDD_deployments_over_country_borders_(5GC002516)_with_BilateralAgreement
    [Documentation]
    ...    Precondition:
    ...      gNB is operating in TDD FR1 with a known frame structure (see US 5GC002516-A#B1 matrix in Alternative Scenario)
    ...      :with souce 1208 and interfering 1116 3ms
    ...      MRBTS/NRBTS/NRCELL/infTddFrameStructure/infTddFrameMutingBiAgreement set to TRUE
    ...      MRBTS/NRBTS/NRCELL/actInfTddFrameMuting = TRUE
    ...      A1 based scell added configured.
    ...    Test Steps:
    ...      Step1: Attach UE1 to TDD Pcell and make SA call.
    ...      Step2: Send A1 report, 3 scells is added,UL 2cc,DL 4cc.
    ...      Step3: start full DL and UL traffic and capture logs.
    ...      Step4: UE detach.
    ...    Check point：
    ...      1. Slot type changed to SLOT_TYPE_MUTED.
    ...      2. UE is configured with DL 4CCs and UL 2CCs successfully.
    ...      3.1. Slot 5 & 15 are muted, no data scheduled on mute slots.
    ...      3.2. UL slot4&9&14&19 (1208)  are  scheduled successfully
    ...      3.3. No DTX/CRC NOK
    [Tags]    caseCAUPD001-014    Manual_Abby    TA_junyihu
    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG_UPD014}
    ...        AND    Suite Setup Update GNB    scf_file=${9169_UPD014_SCF}    iphy_file=${IPHY}    swconfig_param=${9169_RD}
    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
    ...        AND    Common Test Setup 2
    ...        AND    Suite Setup Start WTS And Check OnAir    ${wts_cfg}
    #checkpoint1
    @{slot_muted_list}    Create List    5  15
    Check Slot Type Muted From Gnb_syslog    @{slot_muted_list}
    #Step1
    SA Single UE Attach    ${UE_ID}
    #Step2
    CB009169_C_resource.Trigger A1 Scell Addition    1
    Sleep    2s    reason=Wait for log
    #checkpoint 2
    Get And Check Scell Infos    ${2T2F_SCELLS_014}
    #Step3
    Start SA UE Big UL Traffic Internal    1    mbps=150
    Start SA UE Big DL Traffic Internal    1    mbps=800
    Start Gnb BIP Log
    Sleep    1s    reason=Wait for log
    Stop Gnb BIP Log    ${TEST_LOG_DIRECTORY}/1/
    CUDU_L2 Capture And Decode TTitrace    1   3
    Get CA Cell Average Throughput    ${UE_ID}    ul    scell    2
    SA Stop Data Traffic Internal    ue_id=1    pdu_id=1    dir=bi
    #step4
    SA 5G Detach    ue_id=1
    #checkpoint 3.1
    Check Muted Slots For Pcell    ttitrace_slotmuteUPD001_014_pcell.ini    ${TEST_LOG_DIRECTORY}/ttitrace/1/
    #checkpoint 3.2
    Check Scheduled slots    ttitrace_scheduledslots.ini    ${TEST_LOG_DIRECTORY}/ttitrace/1/
    #checkpoint 3.3
    CUDU_L2 Check DTXNACK Rate    1
    CUDU_L2 Check UL DTXCRC Rate    1

#CB009169-CA-UPD001-017_UL_CA_T+F_IWK_with_Srs_Based_DLUL_BF_+_cell_specific_CSI-RS_and_5GC002516_local_5GC001208_remote_5GC001116_3ms
#    [Documentation]
#    ...    Precondition:
#    ...      Pcell frame structure 1208, boundary interference cell frame structure 1116 3ms.
#    ...      actInfTddFrameMuting TRUE and infTddFrameMutingBiAgreement FALSE.
#    ...      T+F CA, DL 2CC and UL 2CC, blind add and bufferBased act.
#    ...      UE is capable of TAS SRS.

#    ...    Test Steps:
#    ...      Step1: Attach UE1 to TDD Pcell and make SA call.
#    ...      Step2: Start DL and UL traffic.
#    ...      Step3: Stop traffic and UE detach.
#    ...    Check point：
#    ...      1. UE1 attaches to PCell successfully. SCell Addition is ok, DL 2CC and UL 2CC.
#    ...      2. Check mute symbols, DL slot 5/15 and UL slot 9/19 muted in this case configuration.
#    ...      3. Check UL data is always scheduled on slot 4/14 in this case configuration.
#    ...      4. Check P-SRS is on slot 3 or slot 13, periodicty is 10ms.
#    [Tags]    caseUPD001_17    Manual_lilidong    TA_lilidong
#    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG_UPD017}
#    ...        AND    Suite Setup Update GNB    scf_file=${9169_UPD017_SCF}    iphy_file=${IPHY_UPD017}    swconfig_param=${UPD017_RD}
#    ...        AND    Common Test Setup 2
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Suite Setup Start WTS And Check OnAir    ${wts_cfg}
#    #Step1
#    SA Single UE Attach    ${UE_ID}
#    #Step2
#    SA Start DL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=100    trf_id=1
#    SA Start UL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=50    trf_id=1
#    Wait Until Keyword Succeeds    5min    6s    Check CA Cell Sum Average Throughput    1    ul    40    4
#    Wait Until Keyword Succeeds    5min    6s    Check CA Cell Sum Average Throughput    1    dl    90    4
#    Start Gnb BIP Log
#    Sleep    1s    reason=Wait for log
#    Stop Gnb BIP Log    ${TEST_LOG_DIRECTORY}/BIP/1
#    CUDU_L2 Capture And Decode TTitrace    1    1
#    #Checkpoint1
#    Get And Check Scell Infos    ${1T1F_SCELLS_2}
#    #Checkpoint2
#    @{slot_muted_list}    Create List    5  15  9  19
#    Check Slot Type Muted From Gnb_syslog    @{slot_muted_list}
#    #Checkpoint3
#    Check Slot For TDDFrame    ${TEST_LOG_DIRECTORY}/ttitrace/1/output_ul.csv    ulFdSchedData.numOfPrb    61    ${1208_UL_UNMUTE_SLOT}
#    #Checkpoint4
#    CB009169_C_resource.Check Srsreceivereq With A2A    BIP/1    ttitrace_srsreceivereqUPD017.ini
#    SA 5G Detach    ue_id=1

#CB009169-CA-UPD001-010_UL_CA_T+F_interworking_with_SRS_based_DLUL_beamforming_for_PC2_Ues_with_UE_specific_CSI-RS_typeB_actCsirsMultiplexing_enable
#    [Documentation]
#    ...    Precondition:
#    ...      NRCELL.actDlSrsBm = true,NRBTS.NRCELL.actUeCsirsCoexistCellCsirs = true.
#    ...      FDD SCell is configured with PUSCH mapping type B.
#    ...      actCsirsMultiplexing = true on PCell.
#    ...      NRCELL.actUlSrsBm = true.
#    ...      NRBTS/NRCELL/actCDrx to false on PCell.
#    ...    Test Steps:
#    ...      Step1: Attach UE1 and UE2 to the TDD FR1 cell.
#    ...      Step2: Start enough DL/UL traffic.
#    ...      Step3: UE detach.
#    ...    Check point：
#    ...      1. UE1 attaches to PCell successfully, UE1 and UE2 are is configured with DL 2CCs and UL 2CCs successfully.
#    ...      2. UE specific CSI-RS resource is assigned in RRC reconfiguration message to UE.
#    ...      3. UE1 and UE2 are configured with CB-SRS in TDD FR1 PCell.
#    ...      4. 2 CSI-RS resource are multiplexed in frequency domain.
#    ...      5. PUSCH and PDSCH used DFT beam.
#    [Tags]    caseCA-UPD001-010    Manual_cora    TA_Coliu
#    [Setup]    Run Keywords    Set Test Variable    ${WTS_CFG}    ${WTS_CFG_UPD010}
#    ...        AND    Suite Setup Update GNB    force_reboot=${force_reboot}    scf_file=${9169_UPD010_SCF}    iphy_file=${IPHY_UPD010}
#    ...               swconfig_param=${9169_RD}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Suite Setup Start WTS And Check OnAir    log=${False}
#    ...        AND    Common Test Setup 2
#    #Step1 2
#    Multi UE Attach And Do UL DL Traffic    1    2    100    400
#    ute_wtssim.Execute Egate Command    sim_log_set flush
#    Start Gnb BIP Log
#    Sleep    1s
#    Stop Gnb BIP Log    ${TEST_LOG_DIRECTORY}
#    CUDU_L2 Capture And Decode TTitrace    1    1
#    #Checkpoint1
#    Get And Check Scell Infos    ${1T1F_SCELLS}
#    #Checkpoint2
#    Get And Check Nrofports For CSI-RS    p4    2
#    #Checkpoint3
#    Get And Check SrsType    6    0
#    #Checkpoint4
#    Check CSI-RS Resource Are Multiplexed
#    #Checkpoint5
#    Check PatternID Of DL And UL For Multi Ues    ${TEST_LOG_DIRECTORY}/ttitrace/1    1    2
#    #Step3
#    SA 5G Detach    ue_id=1-2

#CB009169-CA-UPD001-006_DRX_setup_for_UE_having_Voice_over_NR_call_with_TDD_FR1-FDD_UL_CA_configured_with_A1_addition_and_data_DRB_eCPRI
#    [Documentation]
#    ...    Precondition:
#    ...      NRBTS/NRDU/flexibleCAMode = 3 (NumberCellAmount).
#    ...      sCellActivationMethod = “1:bufferBased”.
#    ...      sCellAdditionMethod = covBasedA1
#    ...      sCellDeactivationTimerGNB=1280
#    ...      NRBTS/NRCELL/actCDrx = true
#    ...      In FDD Cell: actCDrxVoNR = true.
#    ...      NRBTS/NRCELL/drxProfile1/drxLongCycle = 40ms, drxOnDurationTimer=10ms, drxInactivityTimer=3ms.
#    ...      NRBTS/NRCELL/drxProfile2/drxLongCycle = 40ms, drxOnDurationTimer=6ms, drxInactivityTimer=3ms.
#    ...      frame structure=1070
#    ...    rd parameter:
#    ...      0x58067c=0x1 #enable 6137-C
#    ...      0x58062d=1 #rdEnable6137Fr1CaDrxSolution
#    ...      0x580497=1 #CB007737 feature flag
#    ...      0x580692=1 #rd9169Enable
#    ...    Test Steps:
#    ...      Step1: Attach UE-1 to the FDD NR cell.
#    ...      Step2: Send A1 report, scell is added
#    ...      Step3: Add  5QI1 and 5QI5
#    ...      Step4: Send VONR traffic bi-direction
#    ...      Step5: Send Non-GBR traffic bi-direction
#    ...      Step6: Release GBR bear(5QI1-5QI5)
#    ...      Step7: UE detach
#    ...    Check point：
#    ...      1.check 7737 is actived ,FDD 2 cells  have same emCoreId in TTI trace
#    ...      2.UE attach is ok , DRX configuration(DRX PROFILE1) is send in RRC message, UE is configued 4CC
#    ...      3.5QI1 DRB is added , DRX configuration(DRX PROFILE2) is reconfigued
#    ...      4.scell is not active,UE traffic is only through PCELL ,UE Throughput is ok,DL and UL no DTX on all cells ,
#    ...       UE go into DRX when no DL&UL schdule
#    ...      5.Scell is active,UE Throughput is ok,DL and UL no DTX on all cells ,UE go into DRX when no DL&UL schdule
#    ...      6.DRX configuration(DRX PROFILE1) is reconfigued,UE Throughput is ok,DL and UL no DTX on all cells ,
#    ...       UE go into DRX when no DL&UL schdule
#    ...      7.UE detached
#    [Tags]    caseCAUPD001-006    Manual_Abby    TA_Abby
#    [Setup]    Run Keywords    Set Test Variable    ${WTS_CFG}    ${WTS_CFG_UPD006}
#    ...        AND    Suite Setup Update GNB    force_reboot=${force_reboot}    scf_file=${9169_UPD006_SCF}    iphy_file=${IPHY}
#    ...        swconfig_param=${UPD006_RD}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Common Test Setup 2
#    ...        AND    Suite Setup Start WTS And Check OnAir    log=${False}

#    #Step1:
#    SA Single UE Attach    ue_id=1
#    #Step2:
#    CB009169_C_resource.Trigger A1 Scell Addition    1
#    Sleep    2s    reason=Wait for log
#    Run Keyword And Ignore Error    Get And Check Scell Infos    ${2T2F_SCELLS}
#    #Step3:
#    Trigger 5QI 5 Setup    ${UE_ID}
#    Trigger 5QI 1 Setup    ${UE_ID}
#    #Step4:
#    Start SA VONR GBR DL And UL Traffic    ueId=${UE_ID}    qfi_id=3    dl_trf=10    ul_trf=10
#    Sleep    1s    reason=Wait for log
#    #Step5:
#    Start SA UE Big UL Traffic Internal    1    mbps=150
#    Start SA UE Big DL Traffic Internal    1    mbps=800
#    CUDU_L2 Capture And Decode TTitrace    1    2
#    #Step6:
#    Release 5QI 5 And 5QI 1
#    Start BIP Log By lfs-nw_switch-mirror-tool Script    ABIO_BIP_mirroring_2slot_right.sh
#    SA Stop Data Traffic Internal    ue_id=1    pdu_id=1    dir=bi
#    Sleep    5s    reason=Wait for traffic
#    Stop BIP Log On GNB FCT    ${OUTPUT_DIR}
#    OperatingSystem.Run
#    ...    mergecap -a -w ${OUTPUT_DIR}/5GBipL2L1_filtering_off01.pcap ${OUTPUT_DIR}/5GBipL2L1_filtering_off.pcap*
#    #Step7:
#    SA 5G Detach    ue_id=1
#    Check 7737 Actived    ${TEST_LOG_DIRECTORY}/ttitrace/1    006
#    #checkpoint4 5
#    CB006137_BB_resource.Check DL DTXNACK Rate    ${TEST_LOG_DIRECTORY}/ttitrace/1
#    CB006137_BB_resource.Check UL DTXCRC Rate    ${TEST_LOG_DIRECTORY}/ttitrace/1
#    #checkpoint2 3 6
#    Check RRC Reconfig For DRX Configuration For CB009169-UPD006    ms3    3    ms3    3    ${TEST_LOG_DIRECTORY}
#    #checkpoint5
#    Check DRX InactivityTimer From BIP For CB009169-UPD006    3    16386    01

#CB009169-CA-UPD001-011_TDD_FR1-FDD_UL_CA_with_AM_RLC_non-GBR_bearer_as_defalut_bearer
#    [Documentation]
#    ...    Precondition:
#    ...      5qi-9 configued as default DRB
#    ...      5qi-6 configured with UM RLC mode
#    ...    Test Steps:
#    ...      Step1: Attach UE-1 to the FDD NR cell,5QI-9 is added default.
#    ...      Step2: Scell is added blindly
#    ...      Step3: Add 5QI-6
#    ...      Step4: Start 5QI-6/5QI-9 Dl and UL traffic And Capture Logs for check point 4。
#    ...      Step5: Release 5QI-9 And Capture Logs for check point.
#    ...      Step6: Ue detach
#    ...    Check point：
#    ...      1. Attach successfully,5QI-9 is configured in RRC correctly
#    ...      2. Scell is added blindly
#    ...      3. 5QI-6 is added correctly
#    ...      4.1. 3 scells is activated successfully.
#    ...      4.2. 4CC DL and 2CC UL traffic is normal
#    ...      4.3. 5QI-6 is scheduled on Pcell DL，Pcell UL，scell2 UL From bip log
#    ...      4.4. Pcell csi report and beam report period is 16SFN from ttitrace
#    ...           csiSrReportData.csiReport.cqi=15 pcsi
#    ...           csiSrReportData.csiReport.cqi=255 beam report
#    ...      4.5. pcell and scell ulHarqRxData.dtx non-DTX from ttitrace
#    ...      5.1. scells 1,3 deactivated successfully.
#    ...      5.2. scells 1,2,3 dl traffic is 0.Pcell dl，pcell ul，scell2 ul traffic is normal.
#    ...      5.3. 5QI-6 is scheduled on Pcell DL，Pcell UL，scell2 UL From bip log still.
#    [Tags]    caseCAUPD001-011    Manual_yuerong    TA_junyihu
#    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG_UPD011}
#    ...        AND    Suite Setup Update GNB    scf_file=${9169_UPD011_SCF}    iphy_file=${IPHY}    swconfig_param=${9169_RD}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Suite Setup Start WTS And Check OnAir    ${wts_cfg}
#    ...        AND    Common Test Setup 2
#    #step1,2
#    SA Single UE Attach    ${UE_ID}
#    #check point1
#    Check 5QI-9 Is Correct
#    #check point2
#    Get And Check Scell Infos    ${2T2F_SCELLS_011}
#    #step3 and check point3
#    Trigger UE 5QI6 setup successfully
#    #step4 and check point4.1,4.2
#    Start 5QI-6 And 5QI-9 Traffic And Check For UPD011
#    Start Gnb BIP Log
#    Sleep    1s    reason=Wait for log
#    Stop Gnb BIP Log    ${TEST_LOG_DIRECTORY}/bip/1/
#    CUDU_L2 Capture And Decode TTitrace    1    2
#    #check point 4.3
#    Check 5QI6 Scheduled From BIP    1
#    #check point 4.4
#    CUDU_L2 Verify Period Of Beam Or PCSI Report    60    ${TEST_LOG_DIRECTORY}/ttitrace/1/    pcsi    16    output_ul.csv
#    CUDU_L2 Verify Period Of Beam Or PCSI Report    60    ${TEST_LOG_DIRECTORY}/ttitrace/1/    beam    16    output_ul.csv
#    #check point 4.5
#    CUDU_L2 Check Rate    ulHarqRxData.dtx    ["NON_DTX","DTX"]    ["DTX"]    1
#    #step5 and check point 5.1,5.2
#    Trigger 5QI9 Release And Check
#    Start Gnb BIP Log
#    Sleep    1s    reason=Wait for log
#    Stop Gnb BIP Log    ${TEST_LOG_DIRECTORY}/bip/2/
#    #check point 5.3
#    Check 5QI6 Scheduled From BIP    2
#    #step 6
#    SA 5G Detach    ue_id=1
