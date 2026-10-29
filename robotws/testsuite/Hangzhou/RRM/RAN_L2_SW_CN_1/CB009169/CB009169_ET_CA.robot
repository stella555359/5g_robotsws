*** Settings ***
Documentation    ...
#Resource    ./Resources/CB009169_C_resource.robot
#Resource    ./../CUDU_L2/common_setup_teardown.robot
#Resource    ./../CB006137/resources/CB006137_BB_resource.robot
#Test Teardown    Common Test Teardown 2
#Suite Teardown    Common Suite Teardown 2
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    SBTS00    CN1_SG09_SM2
#...                RAN_5G    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD    CRT
#
#*** Variables ***
#${UE_ID}               1
#${PROFILE_ID}          1
#${GNB_ID}              2
#${CELL_ID}             1
#${BEARER_ID}           2
#${Egatelog_path}       ${CURDIR}
#${LOCAL_WTS_DIR}       ${CURDIR}/Config/CB009169_C
#${SCF_DIR}             ${CURDIR}/Config/CB009169_C
#${IPHY}                ${LOCAL_WTS_DIR}/iphy_CA001.xml
#${5CC_IPHY}            ${LOCAL_WTS_DIR}/iphy_5CC.xml
#${IPHY_CA009}          ${LOCAL_WTS_DIR}/iphy_CA009.xml
#${IPHY_CA014}          ${LOCAL_WTS_DIR}/iphy_CA014.xml
#${9169_CA001_SCF}      ${SCF_DIR}/SCF_C_CA001_25MHz.xml
#${9169_CA003_SCF}      ${SCF_DIR}/SCF_C_CA003_DMRS.xml
#${9169_CA008_SCF}      ${SCF_DIR}/SCF_C_CA008_2200.xml
#${9169_CA009_SCF}      ${SCF_DIR}/SCF_C_CA009_pc2b.xml
#${9169_CA014_SCF}      ${SCF_DIR}/SCF_C_CA014.xml
#${WTS_CFG_CA001}       basic_setup_CA001_25MHz.cfg
#${WTS_CFG_CA003}       basic_setup_5CC.cfg
#${WTS_CFG_CA008}       basic_setup_5CC_DMRS_VONR.cfg
#${WTS_CFG_CA009}       basic_setup_CA009.cfg
#${WTS_CFG_CA014}       basic_setup_CA014.cfg
#${1T1F_SCELLS}         ('1', '51', '66')
#${1T2F_SCELLS}         ('1', '51', '71'), ('2', '53', '25')
#${2T2F_SCELLS_CA003}    ('1', '50', '71'), ('2', '52', '66'), ('3', '60', '77')
#${2T2F_SCELLS}         ('1', '51', '25'), ('2', '52', '66'), ('3', '61', '41')
#${2T2F_SCELLS_2}       ('1', '50', '71'), ('2', '52', '66'), ('3', '61', '41')
#${9169_RD}             0x4B000F=1
#${force_reboot}        ${True}
#
#*** Test Cases ***
#CB009169-ET-CA001_Multiple_BWPs_UL_CA_T+F_with_large_BWP_25MHZ
#    [Documentation]
#    ...    Precondition:
#    ...      multi-BWP enabled(actMultipleDedicatedBWPs && actEnhMultipleDedicatedBWPs
#    ...      FDD scell is one of band 1, 3, 7, 25, 66, 70 and 71.
#    ...      Large BWP is set to 25MHz for both DL and UL.
#    ...      Small BWP is set to 20Mhz for both DL and UL.
#    ...      A1 based scell added configured.
#    ...    Test Steps:
#    ...      Step1: Attach UE1 to TDD Pcell and make SA call.
#    ...      Step2: Send A1 report, scell is added.
#    ...      Step3: Start full UL traffic.
#    ...      Step4: Do robustness testing for scell active deactivate.
#    ...    Check point：
#    ...      1. UE1 attaches to PCell successfully.
#    ...      2. SCell Addition is ok, DL 3CC and UL 2CC.
#    ...      3. UL Scell bwp size and PRB number are correct.
#    ...      4. Scell active deactivate are ok.
#    ...      5. PM counter is ok.
#    [Tags]    caseCA001    Manual_Mike    TA_Coliu
#    [Setup]    Run Keywords    Set Test Variable    ${WTS_CFG}    ${WTS_CFG_CA001}
#    ...        AND    Suite Setup Update GNB    force_reboot=${force_reboot}    scf_file=${9169_CA001_SCF}    iphy_file=${IPHY}
#    ...               swconfig_param=${9169_RD}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Suite Setup Start WTS And Check OnAir    log=${False}
#    ...        AND    Common Test Setup 2
#    Clear PM Counter Reports
#    OperatingSystem.Run And Return Rc And Output    mkdir -p ${SUITE_LOG_DIRECTORY}/PMFile/CA
#    #Step1
#    SA Single UE Attach    ${UE_ID}
#    #Step2
#    CB009169_C_resource.Trigger A1 Scell Addition    ${UE_ID}
#    Sleep    5s    reason=Wait for log
#    #Checkpoint1 2
#    Get And Check Scell Infos    ${1T2F_SCELLS}
#    #checkpoint3
#    Check LocationAndBandwidth From Egate Log    36300
#    #Step3
#    Start SA UE Big UL Traffic Internal    ${UE_ID}    mbps=150
#    CUDU_L2 Capture And Decode TTitrace
#    #checkpoint3
#    SA Stop Data Traffic Internal    ${UE_ID}    1
#    #Step4 checkpoint4
#    Robustness Testing For Scell Active Deactivate    5
#    #checkpoint5
#    Wait Until Keyword Succeeds    10min    5min    Check PM Counter For Large BWP
#    SA 5G Detach    ue_id=${UE_ID}
#
#CB009169-ET-CA003_High_speed_UE_support_in_FR1_TDD_cell_with_two_additional_DMRS
#    [Documentation]
#    ...    Precondition:
#    ...      ulDMRSAdditionalPosition = 1 and dlDMRSAdditionalPosition = 1 on FDD Scell.
#    ...      actHighSpeedCell = TRUE on TDD Pcell.
#    ...      ulDMRSAdditionalPosition = 2 and dlDMRSAdditionalPosition = 2 (Two additional DMRS) on TDD Pcell.
#    ...      actGeneralConnectivitySilver = True.
#    ...      puschMappingType=TypeB.
#    ...    Test Steps:
#    ...      Step1: Attach UE to TDD cell and make SA call.
#    ...      Step2: DL/UL data of non-GBR DRBs are transferred over PCell and SCell.
#    ...      Step3: Adjust UE speed from static(no speed) to 350km/h.
#    ...      Step4. After some time, DL/UL data transmission is stopped.
#    ...      Step5. Detach UE.
#    ...    Check point：
#    ...      1. UE1 attaches to PCell successfully.
#    ...      2. SCell Addition is ok, DL 4CC and UL 2CC.
#    ...      3. Verify additional dmrs is activated.
#    ...      4. Verify dmrs configration is correct.
#    ...      5. DL/UL data are transferred over PCell and SCell successfully
#    [Tags]    caseCA003    Manual_Susie    TA_Susie
#    [Setup]    Run Keywords    Set Test Variable    ${WTS_CFG}    ${WTS_CFG_CA003}
#    ...        AND    Suite Setup Update GNB    force_reboot=${force_reboot}    scf_file=${9169_CA003_SCF}    iphy_file=${5CC_IPHY}
#    ...               swconfig_param=${9169_RD}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Suite Setup Start WTS And Check OnAir    log=${False}
#    ...        AND    Common Test Setup 2
#    #step1 & checkpoint1
#    SA Single UE Attach    ue_id=1
#    Sleep    2s    reason=Wait for log
#    #checkpoint2
#    Get And Check Scell Infos    ${2T2F_SCELLS_CA003}
#    #step2
#    Start SA UE Big UL Traffic Internal    1    mbps=100
#    Start SA UE Big DL Traffic Internal    1    mbps=500
#    #step3
#    Adjust UE To High Speed
#    #checkpoint5
#    Wait Until Keyword Succeeds    5min    20s    Check CA Cell Sum Average Throughput    ${UE_ID}    ul    60    3
#    Wait Until Keyword Succeeds    5min    20s    Check CA Cell Sum Average Throughput    ${UE_ID}    dl    400    4
#    Start Gnb BIP Log
#    Sleep    2s    reason=Wait for bip logs
#    Stop Gnb BIP Log    ${TEST_LOG_DIRECTORY}/bip/1
#    #step4
#    SA Stop Data Traffic Internal    1    1    dl
#    SA Stop Data Traffic Internal    1    1    ul
#    #step5
#    SA 5G Detach    ue_id=1
#    #checkpoint3  4
#    Get And Check UL And DL DMRS    ${TEST_LOG_DIRECTORY}/bip/1
#
#CB009169-ET-CA008_Single_UE_call_setup_for_power_class_2(a)_CA_UE_with_2200
#    [Documentation]
#    ...    Precondition:
#    ...      5GC002200 is enabled on TDD FR1 cell.
#    ...      UE supports power class 2 for the TDD-FDD band combination,
#    ...      but UE only supports power class 3 on TDD band and FDD band
#    ...    Test Steps:
#    ...      Step1: Attach UE to TDD cell and make SA call.
#    ...      Step2: DL/UL data of non-GBR DRBs are transferred over PCell and SCell.
#    ...      Step3. After some time, DL/UL data transmission is stopped.
#    ...      Step4. Detach UE.
#    ...    Check point：
#    ...      1. 5G-UE is attached and configured with TDD FR1 cell as PCell and FDD cell as SCell.
#    ...      2. gNB initiates blind SCell activation and SCell remains active for the duration of RRC connection.
#    ...      3. UE performs periodic CSI Measurements on both PCell and SCell, and report CQI measurements
#    ...         via PUCCH on PCell or multiplexed in PUSCH on PCell.
#    ...      4. Beamforming is enabled on TDD FR1 PCell, and UE also sends Beam management reports for PCell
#    ...         via PUCCH on PCell or multiplexed in PUSCH on PCell.
#    ...      5. DL data transmission of the nonGBR DRB bearers is scheduled via PCell and SCell,as long as
#    ...         there is data in the DL transmission buffer. DL data transmission for SRB is scheduled via PCell only.
#    ...      6. UL data transmission of nonGBR DRB bearers is scheduled via PCell and SCell,
#    ...         as long as 5G-UE indicates nonGBR data in the UL transmission buffer (via BSR).
#    ...      7. DL/UL data are transferred over PCell and SCell successfully.
#    [Tags]    caseCA008    Manual_YueRong    TA_Susie
#    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG_CA008}
#    ...        AND    Suite Setup Update GNB    force_reboot=${force_reboot}    scf_file=${9169_CA008_SCF}    iphy_file=${5CC_IPHY}
#    ...               swconfig_param=${9169_RD}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Suite Setup Start WTS And Check OnAir    log=${False}
#    ...        AND    Common Test Setup 2
#    #step1 & checkpoint1
#    SA Single UE Attach    ue_id=2
#    Sleep    2s    reason=Wait for log
#    #checkpoint2
#    Get And Check Scell Infos    ${2T2F_SCELLS_2}
#    #step2
#    Start SA UE Big UL Traffic Internal    2    mbps=100
#    Start SA UE Big DL Traffic Internal    2    mbps=300
#    CUDU_L2 Capture And Decode TTitrace
#    #checkpoint5 6
#    Wait Until Keyword Succeeds    5min    6s    Check CA Cell Sum Average Throughput    2    ul    60    3
#    Wait Until Keyword Succeeds    5min    6s    Check CA Cell Sum Average Throughput    2    dl    100    4
#    #step3
#    SA Stop Data Traffic Internal    2    1    dl
#    SA Stop Data Traffic Internal    2    1    ul
#    #step4
#    SA 5G Detach    ue_id=2
#    #checkpoint3
#    @{cells}    Create List    60    61    50    52
#    Verify Period Of Beam Or PCSI Report For CA Cells    ${cells}    ${TEST_LOG_DIRECTORY}/ttitrace/1
#    #checkpoint4
#    @{cells_with_beamforming}    Create List    60    61
#    Verify Period Of Beam Or PCSI Report For CA Cells    ${cells_with_beamforming}    ${TEST_LOG_DIRECTORY}/ttitrace/1    beam
#    #checkpoint7
#    Check No Scheduled Slot For Scell    ${TEST_LOG_DIRECTORY}/ttitrace/1
#    Check Pmax Info From Gnb_syslog
#
#CB009169-ET-CA009_Single_UE_call_setup_for_power_class_2(b)_CA_UE_with_beamforming
#    [Documentation]
#    ...    Precondition:
#    ...      Beamforming is enabled on TDD FR1 cell
#    ...      2T+2F CA, DL 4CC and UL 2CC, blind add and blind act.
#    ...      UE supports pc 2 for the TDD-FDD band combination, and UE supports pc 2 on TDD band and pc 3 on FDD band.
#    ...    Test Steps:
#    ...      Step1: Attach UE1 to TDD Pcell and make SA call.
#    ...      Step2: Start full UL traffic.
#    ...      Step3: Stop traffic and UE detach.
#    ...    Check point：
#    ...      1. UE1 attaches to PCell successfully. SCell Addition is ok, DL 4CC and UL 2CC.
#    ...      2. Check Pmax info.
#    ...      3. Check CQI measurement on both Pcell and Scell, and check there is no power split.
#    ...      4. Check beam report.
#    ...      5. Check peak Tput
#    [Tags]    caseCA009    Manual_lilidong    TA_lilidong
#    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG_CA009}
#    ...        AND    Suite Setup Update GNB    scf_file=${9169_CA009_SCF}    iphy_file=${IPHY_CA009}    swconfig_param=${9169_RD}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Suite Setup Start WTS And Check OnAir    ${wts_cfg}
#    ...        AND    Common Test Setup 2
#    #Step1
#    SA Single UE Attach    ${UE_ID}
#    #Checkpoint1
#    Get And Check Scell Infos    ${2T2F_SCELLS_2}
#    #Step2
#    Start SA UE Big UL Traffic Internal    ${UE_ID}    mbps=50
#    Start SA UE Big DL Traffic Internal    ${UE_ID}    mbps=600
#    #Checkpoint5
#    ${tp_syslog}=    Get Cell Throughput From Btslog    20s
#    Check Cell Throughput Quality From Btslog    ${tp_syslog}    16385    ul    13
#    Check Cell Throughput Quality From Btslog    ${tp_syslog}    16395    ul    34
#    #Checkpoint2
#    Check Pmax Info From Gnb_syslog    26    23    26
#    #Checkpoint3 4
#    CUDU_L2 Capture And Decode TTitrace
#    #Check PCSI For Each Cell    ${TEST_LOG_DIRECTORY}/ttitrace/1
#    @{cells}    Create List    60    61    50    52
#    Verify Period Of Beam Or PCSI Report For CA Cells    ${cells}    ${TEST_LOG_DIRECTORY}/ttitrace/1
#    @{cells_with_beamforming}    Create List    60    61
#    Verify Period Of Beam Or PCSI Report For CA Cells    ${cells_with_beamforming}    ${TEST_LOG_DIRECTORY}/ttitrace/1    beam
#    Check Power Split State    ${TEST_LOG_DIRECTORY}/ttitrace/1
#    SA 5G Detach    ue_id=${UE_ID}
#
#CB009169-ET-CA014_p0UePusch_is_not_changed_during_SCell_AdditionSwapRelease_when_p0UePusch_is_set_to_-3
#    [Documentation]
#    ...    Precondition:
#    ...      NRBTS/NRCELL/ulPowerControlCommon.p0UePusch is set to -3 dB on PCell
#    ...      NRBTS.actSCellSwapFr1 is set to ‘enabled’
#    ...      SCell swap related measurement configuration parameters in (SCell)NRCELL.a6MeasSCellSwapSsbRsrp and (SCell)NRCELL.a6MeasSCellSwapSsbRsrq
#    ...    Test Steps:
#    ...      Step1: Attach UE1 to TDD Pcell and make SA call
#    ...      Step2: Send A1 report, scell is added.
#    ...      Step3: Start full UL traffic.
#    ...      Step4: UE report A6 MR(F2's offset is higher than F1)
#    ...      Step5: UE report A2 MR(release CELL4 )
#    ...    Check point：
#    ...      1. UE1 attaches to PCell successfully
#    ...      2. SCell Addition is ok, DL 2CC and UL 2CC
#    ...      3. SCell swap successfully
#    ...      4. FDD Scell release
#    ...      5. During UL SCell addition/change/release procedure, P0-PUSCH-AlphaSet did not change
#    [Tags]    caseCA014    Manual_Abby    TA_xinwang
#    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG_CA014}
#    ...        AND    Suite Setup Update GNB    force_reboot=${force_reboot}    scf_file=${9169_CA014_SCF}
#    ...               iphy_file=${IPHY_CA014}    swconfig_param=${9169_RD}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Suite Setup Start WTS And Check OnAir    log=${False}
#    ...        AND    Common Test Setup 2
#    #Step1
#    SA Single UE Attach    ${UE_ID}
#    #Step2
#    CB009169_C_resource.Trigger A1 Scell Addition    ${UE_ID}    1    100
#    Sleep    5s    reason=Wait for log
#    #Checkpoint1 2
#    Get And Check Scell Infos    ${1T1F_SCELLS}
#    #Step3
#    Start SA UE Big UL Traffic Internal    ${UE_ID}    mbps=100
#    Start SA UE Big DL Traffic Internal    ${UE_ID}    mbps=500
#    #Step4 Checkpoint3
#    Trigger A6 Scell Swap    ${UE_ID}
#    #Step5
#    ${output}=    Trigger A2 MR Scell Release    1    2    2    50
#    #Checkpoint4
#    Check Scell Release Infos After A2 MR    ${output}    2
#    #Checkpoint5
#    Check P0 Value Not Changed
#    SA 5G Detach    ue_id=${UE_ID}
