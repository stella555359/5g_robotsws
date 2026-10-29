*** Settings ***
Suite Teardown    Common Suite Teardown 2
Test Teardown     Common Test Teardown 2
Resource          ./../CB008236/Resources/CB008236_resource.robot
Resource          ./../CUDU_L2/common_setup_teardown.robot
Resource          ./../CUDU_L2/common_log_capture.robot
Resource          ./../CUDU_L2/common_multi_UE_resource.robot
Resource          ./Resources/CB009855_resource.robot
Resource          ../CB008532/keywords_CB008532_common_AP.robot
Library           ./../CB008236/Resources/CB008236_resource.py

Force Tags        SBTS00    CN1_SG09_SM2    RAN_5G    CRT

*** Variables ***
${UE_ID}                   1
${PROFILE_ID}              1
${GNB_ID}                  2
${CELL_ID}                 1
${BEARER_ID}               2
${LOCAL_WTS_DIR}           ${CURDIR}/Config/
${SCF_DIR}                 ${CURDIR}/Config/
${RD}                      0x4B000F=1;0x58057A=4;0x58057f=8192;0x58012d=2
${WTS_CFG_B1b_VoNR}        basic_3T_3F_VoNR.cfg
${WTS_CFG_B1c_02}          basic_3T_3F_B1c02.cfg
${IPHY_B1b}                ${CURDIR}/Config/iphy_3T_3F_B1b.xml
${SCF_B1b_VoNR}            ${CURDIR}/Config/SCF_B1b_VoNR.xml
${SCF_B1c_02}              ${CURDIR}/Config/SCF_B1c_02.xml
@{5CC_4UE_LIST}            1    2    3    4
@{5CC_PCELL_PCI_LIST}      55    55    55    55
@{5CC_SCELL_PCI_LIST}      ${5CC_SCELL_PCI_1}    ${5CC_SCELL_PCI_2}    ${5CC_SCELL_PCI_1}    ${5CC_SCELL_PCI_2}
@{5CC_SCELL_PCI_1}         50    52    53    54
@{5CC_SCELL_PCI_2}         50    51    52    53
${CC_NUMS_5}               5
&{UE1_5QI5}                ue_id=1    qfi=2    qosflows_id_5qi=5
&{UE1_5QI1}                ue_id=1    qfi=3    qosflows_id_5qi=1
&{UE2_5QI5}                ue_id=2    qfi=2    qosflows_id_5qi=5
&{UE2_5QI1}                ue_id=2    qfi=3    qosflows_id_5qi=1
&{UE3_5QI5}                ue_id=3    qfi=2    qosflows_id_5qi=5
&{UE3_5QI1}                ue_id=3    qfi=3    qosflows_id_5qi=1
&{UE4_5QI5}                ue_id=4    qfi=2    qosflows_id_5qi=5
&{UE4_5QI1}                ue_id=4    qfi=3    qosflows_id_5qi=1
@{UE_5QI_INFO_LIST}        ${UE1_5QI5}    ${UE1_5QI1}    ${UE2_5QI5}    ${UE2_5QI1}    ${UE3_5QI5}    ${UE3_5QI1}    ${UE4_5QI5}    ${UE4_5QI1}
@{UE1_3_LIST}              1    3
@{UE2_4_LIST}              2    4
@{Exp_UE1_3_DL_Tput}       60    12    60    60    25
@{Exp_UE2_4_DL_Tput}       60    12    20    60    60
@{Exp_UE_UL_Tput}          5    10
${A1THRESHOLD}             120
${WTS_CFG_B1b_07}          wts_cfg_B1b_07.cfg
${IPHY_B1b_07}             ${CURDIR}/Config/iphy_B1b_07.xml
${SCF_B1b_07}              ${CURDIR}/Config/SCF_B1b_07.xml
@{SCELL_PHYSICALID_LIST}    ${5CC_SCELL_PHYSICALID_1}    ${5CC_SCELL_PHYSICALID_2}
@{5CC_SCELL_PHYSICALID_1}    50    51    52    53
@{5CC_SCELL_PHYSICALID_2}    50    51    53    54
@{5CC_UE_LIST}             1    2
@{5CC_PCELL_ID_LIST}       55    55
@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}

*** Test Cases ***

#CB009855-B1c-02_Verify_3T2F_DL_CA_Peak_UCIBits_With_BuftferBasedAct_PCSI_Bundling_MultiUE_on_Thor
#    [Documentation]
#    ...    CB009855 parameter configuration:
#    ...    NRBTS/NRDU. carrierAggregationSupportList contains an entry set to “700: ca_Fr1Tdd_Any_Sa”; AND
#    ...    NRBTS/NRCELL. maxNumScellsDlFr1 is set to 4.
#    ...                 scellAdditionMethod = covBasedA1
#    ...                 scellActivationMethod = blind and scellDeactivationTimerGNB = infinity
#    ...                 actCDrx = True, and parameters under NRBTS/NRCELL.drxProfile1 are configured appropriately based on PDL rules
#    ...                 actBeamforming = true and basicBeamSet=beamset6( 1208, 1070, 1116-0ms)
#    ...                 Frame structure of Pcell is set to “tdLte”, frame structure of TDD Scells are set to “semi-static 4:1”
#    ...                 nrBtsBeamRefinementP2=true
#    ...                 periodicCsiAcquisition.maxCsirsNumber=2
#    ...                 actPucchAdditionalDmrs=False and dlMimoMode=70  && Subpanel = 4
#    ...                 pucchF3ModulationScheme=pi2bpsk and pucchF3MaxCodeRate=zeroDot25
#    ...    Test Steps:
#    ...                 Step1. Attach 4 5CC Capable UEs to TDD cell6.
#    ...                 Step2. give full DL traffic for all UE.
#    ...                 Step3. After several seconds, give full UL traffic for all UE
#    ...    Check points:
#    ...                 1.In step1, 4 cells are added as SCells.
#    ...                 2.In step2, every UE and every cell reaches to expected Tput. UCI bits are correct.
#    ...                 3.In step3, check numOfUciCsiPart1Bits are correct.

#    [Tags]    case_B1c02    Manual_lilidong    TA_lilidong
#    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG_B1c_02}
#    ...        AND    Suite Setup Update GNB    scf_file=${SCF_B1c_02}    iphy_file=${IPHY_B1b}    swconfig_param=${RD}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Common Test Setup 2
#    ...        AND    Suite Setup Start WTS And Check OnAir    ${wts_cfg}

#    # step1&step2
#    ${savepoint} =  Capture savepoint  alias=${GNB_SYSLOG.alias}
#    SA Multi UE Attach With Scell A1 Addition    ${5CC_4UE_LIST}    ${5CC_PCELL_PCI_LIST}    ${5CC_SCELL_PCI_LIST}    ${A1THRESHOLD}    ${CC_NUMS_5}
#    SA Multi UE Start DL Traffic    ${5CC_4UE_LIST}    400
#    Sleep    10s    reason=wait for traffic statble
#    Traffic Display    1
#    Traffic Display    2
#    Traffic Display    3
#    Traffic Display    4
#    Collect from savepoint  savepoint=${savepoint}  destination_file=${TEST_LOG_DIRECTORY}/syslog  alias=${GNB_SYSLOG.alias}
#    ##wait until keyword succeeds    60min    15min    Check Uci Bits For CB009855-B1c-02 PUCCH
#    #CUDU_L2 Capture And Decode TTitrace    DL    1
#    #Check Uci Bits For CB009855-B1c-02    CB009855_Uci_Bits_B1c02_pucch.ini    ${TEST_LOG_DIRECTORY}/ttitrace/DL
#    # step3
#    SA Multi UE Start UL Traffic    ${5CC_4UE_LIST}    50
#    Sleep    20s    reason=wait for traffic statble
#    Traffic Display    1
#    Traffic Display    2
#    Traffic Display    3
#    Traffic Display    4
#    CUDU_L2 Capture And Decode TTitrace    DLUL    0.5
#   Check Uci Bits For CB009855-B1c-02    CB009855_Uci_Bits_B1c02_pusch.ini    ${TEST_LOG_DIRECTORY}/ttitrace/DLUL
#    Check Multi UE DLCA Cell L1 tput    ${UE1_3_LIST}    ${Exp_UE1_3_DL_Tput}    ${CC_NUMS_5}
#    Check Multi UE DLCA Cell L1 tput    ${UE2_4_LIST}    ${Exp_UE2_4_DL_Tput}    ${CC_NUMS_5}
#    Check Multi UE ULCA Cell L1 tput    ${5CC_4UE_LIST}    ${Exp_UE_UL_Tput}    ${CC_NUMS_5}
#    CUDU_L2 Check DTXNACK Rate    log_id=DLUL
#    CUDU_L2 Check UL DTXCRC Rate    log_id=DLUL
#    SA Multi Continuous UE Stop DL Traffic    1    4
#    SA Multi UE Detach    ${5CC_4UE_LIST}

CB009855-B1b-07_Verify_interworking_with_CNI-80224_pCSI_bundling_2T+3F_on_Thor
    [Documentation]
    ...   CB009855 para:
    ...    NRBTS/NRDU. carrierAggregationSupportList contains an entry set to “700: ca_Fr1Tdd_Any_Sa”; AND
    ...    NRBTS/NRCELL.maxNumScellsDlFr1 is set to 4.
    ...                 scellAdditionMethod = covBasedA1
    ...                 scellActivationMethod = bufferBased
    ...                 scellDeactivationTimerGNB = ms1280
    ...                 actPerCsiReportBundlingTddFr1 = True
    ...    in each TDD cell:
    ...                 NRCELLGRP.numberOfTransmittedSsBlocks = 6
    ...                 NRCELL.dlMimoMode = 70
    ...                 NRCELL.beamSet.nrBtsBeamRefinementP2 = False
    ...    Frame structure of cell4 is set to “tdLte”, frame structure of cell5 and cell6 is set to “semi-static 4:1”
    ...   Test Steps:
    ...                 Step1. Attach UE1 and UE2 to cell4.
    ...                 Step2. Send A1 report (higher than FDD and TDD threshold) for all UEs.
    ...                 Step3. Start DL and UL traffic.
    ...   Check points:
    ...                 1.UE1 is configured with 3T + 2F CA, UE2 is configured with 2T + 3F CA.
    ...                 2.4 CSI-RS number configured to pcell, 1 resource overbooked for all UEs.
    ...                 3.pCSI and beam report is bundled.
    ...                 4.Traffic are ok, no dtx.
    ...                 5.UCI bits are correct on both PUSCH and PUCCH.
    [Tags]    case_B1b_07    Manual_Cora Liu    TA_Cora Liu
    [Setup]    Run Keywords    Set Test Variable    ${wts_cfg}    ${WTS_CFG_B1b_07}
    ...        AND    Suite Setup Update GNB    scf_file=${SCF_B1b_07}    iphy_file=${IPHY_B1b_07}    swconfig_param=${RD}
    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
    ...        AND    Common Test Setup 2
    ...        AND    Suite Setup Start WTS And Check OnAir    ${wts_cfg}
    # Step1 & Step2 & Checkpoint1
    ${savepoint} =  Capture savepoint  alias=${GNB_SYSLOG.alias}
    SA Multi UE Attach With Scell A1 Addition    ${5CC_UE_LIST}    ${5CC_PCELL_ID_LIST}
    ...    ${SCELL_PHYSICALID_LIST}    ${A1THRESHOLD}    5
    Collect from savepoint  savepoint=${savepoint}  destination_file=${TEST_LOG_DIRECTORY}/syslog  alias=${GNB_SYSLOG.alias}
    # Step3
    SA Multi UE Start DL Traffic    ${5CC_UE_LIST}    800
    Wait Untill Scell Activated    4    1
    Sleep    10s    reason=wait for traffic statble
    ##wait until keyword succeeds    60min    15min  Check Uci Bits For CB009855-B1b-07 PUCCH
    SA Multi UE Start UL Traffic    ${5CC_UE_LIST}    50
    Sleep    10s    reason=wait for traffic stable
    Traffic Display
    Start Ttitrace With Streaming Mode
    Sleep    1s
    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/DLUL
    #Checkpoint2
    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/DLUL
    Check Uci Bits For CB009855-B1b-07    CB009855_Uci_Bits_B1b_07_PUSCH.ini    ${TEST_LOG_DIRECTORY}/ttitrace/DLUL
    Check One More PCSI CPU Overbooked    syslog
    CUDU_L2 Check DTXNACK Rate    log_id=DLUL
    CUDU_L2 Check UL DTXCRC Rate    log_id=DLUL
    SA Multi UE Detach    ${5CC_UE_LIST}


*** Keywords ***
Check Uci Bits For CB009855-B1c-02
    [Arguments]    ${ini_file}    ${log_dir}    ${csv_file}=output_ul.csv
    ${UE1_rnti}=    Get Crnti From Egate Log    1
    Set Suite Variable    ${UE1_rnti}
    ${UE2_rnti}=    Get Crnti From Egate Log    2
    Set Suite Variable    ${UE2_rnti}
    ${UE3_rnti}=    Get Crnti From Egate Log    3
    Set Suite Variable    ${UE3_rnti}
    ${UE4_rnti}=    Get Crnti From Egate Log    4
    Set Suite Variable    ${UE4_rnti}
    A2A_Check_CSV_Table    ${CURDIR}/A2A/CB009855_B/${ini_file}    ${csv_file}    ${log_dir}

Check One More PCSI CPU Overbooked
    [Arguments]    ${log_name}
    ${csirs_info}    Set Variable    Overbooked with 1 resource for the beam report
    ${rst_csirs_info}    Run    cat ${TEST_LOG_DIRECTORY}/${log_name}|grep -i "${csirs_info}"|wc -l
    Should Be True    ${rst_csirs_info} == 5

Check Uci Bits For CB009855-B1b-07
    [Arguments]    ${ini_file}    ${log_dir}=${OUTPUT_DIR}    ${csv_file}=output_ul.csv
    ${UE1_rnti}=    Get Crnti From Egate Log    1
    Set Suite Variable    ${UE1_rnti}
    ${UE2_rnti}=    Get Crnti From Egate Log    2
    Set Suite Variable    ${UE2_rnti}
    A2A_Check_CSV_Table    ${CURDIR}/A2A/CB009855_B/${ini_file}    ${csv_file}    ${log_dir}

Check Uci Bits For CB009855-B1b-07 PUCCH
    Traffic Display
    Start Ttitrace With Streaming Mode
    Sleep    2s
    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/DL
    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/DL
    Check Uci Bits For CB009855-B1b-07    CB009855_Uci_Bits_B1b_07_PUCCH.ini    ${TEST_LOG_DIRECTORY}/ttitrace/DL

Check Uci Bits For CB009855-B1c-02 PUCCH
    Traffic Display    1
    Traffic Display    2
    Traffic Display    3
    Traffic Display    4
	CUDU_L2 Capture And Decode TTitrace    DL    1
    Check Uci Bits For CB009855-B1c-02    CB009855_Uci_Bits_B1c02_pucch.ini    ${TEST_LOG_DIRECTORY}/ttitrace/DL

Traffic Display
    [Arguments]    ${ue_id}=1
    Run Keyword And Ignore Error    ute_wtssim.Execute Egate Command And Wait For Data    cmd=ue_stats_nr id=${ue_id} type=pdsch scell=0-4
    ...    pass_regexp=CellIndex-0    timeout=60s
    sleep    5s    #for traffic
    Run Keyword And Ignore Error    ute_wtssim.Execute Egate Command And Wait For Data    cmd=ue_stats_nr id=${ue_id} type=pusch scell=0-4
    ...    pass_regexp=CellIndex-0    timeout=60s
