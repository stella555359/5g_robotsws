*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO   CRT  RAN_5G    5G_RAN_TDD    5G_RAN   SBTS00    CONFIGURED




Resource         CB008227_Resource.robot
Resource         ../CB008285/CB008285_Resource.robot
Resource         ../resources/robot/configuration_id.robot
Resource         ../CB008285/CB008285_Resource.robot
Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../resources/robot/PM_Counters.robot
Library          ../resources/python/BIP_Capture.py
Library          ../resources/python/CPRT_Capture.py
Resource         ../resources/robot/configuration_id.robot
Resource       ../resources/ECEcommon/common_setup_teardown.robot
Resource         CB008227_Resource.robot
Resource         CB008227_keywords.robot





Suite Teardown      Run keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Stop Default Logging Gnb ASIL_ABIO



Suite Setup         Run Keyword and Ignore Error      Suite setup from scratch



Documentation
...
...             author:           Madhukara M V
...             maintainer:       madhukara.m_v@nokia.com
...
...             INTRODUCTION:     one robot merger


*** Variables ***
${wts_cfg_file_tc58}     ${CURDIR}/config/TC42_basic_setup_3PLMN.cfg
${SCFC_tc58}=                        TC42_SCFC_SLICE_NBR_CONG.xml
${AP_XML_tc58}=                      ${CURDIR}/config/TC45_IPHY.xml
${wts_cfg_file_tc16}     ${CURDIR}/config/basic_setup.cfg
${SCFC_tc16}=                        scfc.xml
${AP_XML_tc16}=                      ${CURDIR}/config/iphy.xml
${Delta_scf_feature_enable_tc16}     Delta_CB008227_act_tc16.json
${Delta_scf_feature_disable_tc16}    Delta_CB008227_deact.json
${delta_set_nbr_ul_dl_tc16} =        nbrul_dl_TC16.json
${SCFC_tc33}=                        PScell_change_scf.xml
${AP_XML_tc33}=                      ${CURDIR}/config/PScell_change_iphy.xml
${Delta_scf_feature_enable_tc33}     Delta_CB008227_act.json
${Delta_scf_feature_disable_tc33}    Delta_CB008227_deact.json
${wts_cfg_file_tc37}     ${CURDIR}/config/8227_ARP_basic_setup.cfg
${wts_cfg_file_tc33}     ${CURDIR}/config/PScell_change_basic_setup.cfg
${SCFC_tc37}=                        8227_ARP_SCF.xml
${AP_XML_tc37}=                      ${CURDIR}/config/8227_ARP_iphy.xml

${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${epc_log_path}    /tmp/
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${TRF_ID}     1
${QFI_ID}     1
${QFI_ID1}     2
${QFI_ID2}     3
${QFI_ID3}     4
${QFI_ID4}     5
${QFI_ID5}     6


${CELL_ID_tc58}    3
${CELL_ID_tc33}    1
${CELL_ID_tc37}   1
${sa_ue_id1}   1
${sa_ue_id2}   2
${sa_ue_id3}   3
${sa_ue_id4}  4
${sa_ue_id9}  9
${sa_ue_id10}  10
${nsa_ue_id1} 	101
${nsa_ue_id2} 	102
${nsa_ue_id3} 	103
${nsa_ue_id4} 	104
${nsa_ue_id9} 	109
${nsa_ue_id10} 	110
${nsa_ue_id11} 	111

${nsa_ue_id31} 	31

${TEST_NAME_16}     TC16
${TEST_NAME_33}     TC33
${TEST_NAME_37}     TC37
${TEST_NAME_58}     TC58

${x2_UP_pattern_with_simulated_gnb}    ENB-1: X2AP Link with GNB-4 .* is up
${UE_attach_pattern_RA}                   Bearer-type change from MCG to SCG-split is \nsuccessful
${UE_attach_pattern}                   reported successful RA
${timeout}    20

*** Test Cases ***
[1]CB008227-EA#B1_TC58_NBR_interworking_with_slice_Aware_Scheduler_and_NBR_congestion
	[Documentation]
	...
	...             author:           Madhukara M V
	...             maintainer:       madhukara.m_v@nokia.com
	...
	...             INTRODUCTION:     This user scenario describes the gNB behavior that slice aware scheduler
	...                               works fine with NBR Congestion control. It depriotize the bearer at slice
	...								  Level qutoa that at the cell level with maxnbrtraffilimit=10
	...                               	 	SLICE       MINquota	Maxquota	PLMN
	...                               UE1	SNSSAI-1	10	        20	        311,489
	...                               UE2	SNSSAI-2	20	        20	        311,490
	...                               UE3	SNSSAI-3	5	        10	        311,491
	...
	...                               Bearer1: 5QI-6 : NRDRB_MAC-5 : NBR Bearer, nbrdl: 200 , nbrul: 40, PLMN1: 311,489
	...                               Bearer2: 5QI-7 : NRDRB_MAC-2 : nonGBR Bearer, PLMN2: 311,490
	...                               Bearer2: 5QI-8 : NRDRB_MAC-2 : nonGBR Bearer, PLMN3: 311,491
	...
	...                               NRDRB-1 ---> NRDRB_MAC-1 : nbrdl: 100 , nbrul: 40
	...
	...                               UE1 with 5QI-6 and 5QI-7
	...                               UE2 with 5QI-6 and 5QI-7
	...                               UE3 with 5QI-6 and 5QI-7
	...
	...                               NRDRB-1 ---> NRDRB_MAC-1 : nbrdl: 100 , nbrul: 40
	...                               UE1
	...                               5QI-6 ---> nrDrbDN:NRDRB-11 --> nrDrbMacDN: NRDRB_MAC-5(with nbr configuration)
	...                               5QI-7 ---> use default: NRDRB-1 due to cannot find nrDrb5Qi for 5QI: 7
	...
	...                               UE2
	...                               5QI-6 ---> use default: NRDRB-1 due to cannot find nrDrb5Qi for 5QI: 6
	...                               5QI-7 ---> nrDrbDN:NRDRB-12 --> nrDrbMacDN: NRDRB_MAC-2 (without nbr cofiguration)
	...
	...                               UE3
	...                               5QI-6 ---> use default: NRDRB-1 due to cannot find nrDrb5Qi for 5QI: 6
	...                               5Qi-7 ---> use default: NRDRB-1 due to cannot find nrDrb5Qi for 5QI: 7
	...
	...
	...
	...             TEST SET NAME:    CB008227
	...             TESTING SPLIT:    Refer CB008227 Test Plan
	...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
	...             REFERENCES:       CB008227 CFAM
	...             Requirement ID:   5G_RAN_USR_RRM_20732
	[Setup]     Testcase Setup   ${AP_XML_tc58}   ${SCFC_tc58}   ${wts_cfg_file_tc58}   4
    set suite variable     ${TEST_NAME_58}
    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME_58}
    set test variable      ${LOG_PATH}

    Wait until the next Measurement Period starts
    log to console   "SA UE attach with NBR Bearers are trigerring now"
#Step 1. Attach SA UE's with 1 default Bearer and 3 NBR Beareres
    Link SCOUT SCF to Configuration ID for Reporting
    Start Log    cprt
    MultiUE Register should be Successful with diff slice    ${sa_ue_id1}     ${sa_ue_id3}
    sleep     2s
    Add new Bearer for Multiple SA UE    ${sa_ue_id1}    ${sa_ue_id3}    ${Pdu_session_ID}    ${QFI_ID1}
    ${path1}    Stop Log    cprt   test_scenario=usersetup
    MultiUE Trigger DL Traffic for SA   ${sa_ue_id1}    ${sa_ue_id3}    Traffic_rate=mbps   dl_rate=150
    ...   pdu_id=1     trf_id=1     qfi_id=1
    MultiUE Trigger UL Traffic for SA   ${sa_ue_id1}    ${sa_ue_id3}    Traffic_rate=mbps   ul_rate=150
    ...   pdu_id=1     trf_id=1     qfi_id=1
    sleep   10s
    Validate DL Traffic For all UEs   43   43   22
    Validate UL Traffic For all UEs   77   52    76
    Wait until the current Measurement Period stops
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File   output_dirpath=${OUTPUT DIR}/pmcounter1
#Update counter values according to testing
    Verify Any Counters In File
    ...  M55139C03509  1500  SA_DU_DRB_NBR_DL
    ...  M55139C03510  1500  SA_DU_DRB_NBR_UL
    ...  M55300C12010  < 1000  ACC_DU_DRB_NBR_DL_DEPRIO_CONG
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL_ID_tc58}
    ...  file_path=${pm_counter_file}
    MultiUE Deregister should be Successful    ${sa_ue_id1}    ${sa_ue_id3}
    [Teardown]    Run Keywords    common Teardown




CB008227-A#B5_TC16_Online_modification_Nominal_Bit_Rate_parameters_SA_Downlink_only
	[Documentation]
	...
	...             author:           Madhukara M V
	...             maintainer:       madhukara.m_v@nokia.com
	...
	...             INTRODUCTION:     This user scenario describes the gNB behaviour for the online enable/disable
	...                               of the feature in SA mode
	...             TEST SET NAME:    CB008227
	...             TESTING SPLIT:    Refer CB008227 Test Plan
	...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
	...             REFERENCES:       CB008227 CFAM
	...             Requirement ID:   xxxxx

    [Setup]         Run keywords     Log to console      "Suite Setup started"
    ...         Start Log   btslog
    ...         AND     Suite setup from scratch
    ...         AND     Start Default Logging Gnb ASIL_ABIO
    ...         AND     Start WTS Using WTS_Runner      ${wts_cfg_file_TC16}

    set test variable      ${LOG_PATH}

    log to console   "SA UE Registerrr"
#Step 1. SA ue and NSA Ue attach/regiester with NBR disabled and verify traffic
    Link SCOUT SCF to Configuration ID for Reporting
    UE Register with ICS+PDU should be Successful   ${sa_ue_id1}
    sleep     5s
    MultiUE Trigger DL Traffic for SA    ${sa_ue_id1}  ${sa_ue_id1}   Traffic_rate=mbps     dl_rate=30        pdu_id=1     trf_id=1     qfi_id=1
    sleep     10s
    Validate DL Traffic For MultiUE for SA   ${sa_ue_id1}  ${sa_ue_id1}   dl_rate=30   pdu_id=1   qfi_id=1
    X2AP Link Should be UP
    sleep     5s
    Multiple NSA UE Register   ${nsa_ue_id1}    ${nsa_ue_id1}
    sleep     5s
    Multiple NSA UE start and validate DL Traffic    ${nsa_ue_id1}  ${nsa_ue_id1}   dl_rate=18
    Multiple NSA UE start and validate UL Traffic    ${nsa_ue_id1}  ${nsa_ue_id1}   dl_rate=11
#Step 2. Enable NBR and register ue id 2 and verify traafic.
    Perform SCF Delta Commissioning with ${Delta_scf_feature_enable_tc16}
    sleep    5s
    Start Log    cprt
    FOR    ${m}    IN RANGE    2    10
        UE Register with ICS+PDU should be Successful   ${m}
        sleep   2s
        MultiUE Trigger DL Traffic for SA    ${m}  ${m}   Traffic_rate=mbps     dl_rate=30        pdu_id=1     trf_id=1     qfi_id=1
    END
    ${path1}    Stop Log    cprt   test_scenario=bearersetup
    Verify nbrDrbSpecificParams In bearersetupreq   ${path1}[cprt]/NODECPRT_GNB.pcap   sctp    2000   2000
    sleep     5s
    Validate DL Traffic For MultiUE for SA   ${sa_ue_id1}  ${sa_ue_id9}   dl_rate=30   pdu_id=1   qfi_id=1
    Start Log    cprt
    Multiple NSA UE Register   ${nsa_ue_id2}    ${nsa_ue_id2}
    sleep     5s
    ${path2}    Stop Log    cprt   test_scenario=user_bearersetup
    Verify nbrDrbSpecificParams In usersetupreq   ${path2}[cprt]/NODECPRT_GNB.pcap   sctp    2000    2000
    Multiple NSA UE Register   ${nsa_ue_id3}    ${nsa_ue_id10}
    Multiple NSA UE start and validate DL Traffic    ${nsa_ue_id2}  ${nsa_ue_id10}   dl_rate=18
    Multiple NSA UE start and validate UL Traffic    ${nsa_ue_id2}  ${nsa_ue_id10}   dl_rate=11
    Validate DL Traffic For NSA     ${nsa_ue_id1}    18
    Validate UL Traffic For NSA     ${nsa_ue_id1}    11
#Step 3. Disable NBR and register ue id 3 and verify traffic
    Perform SCF Delta Commissioning with ${Delta_scf_feature_disable_tc16}
    UE Register with ICS+PDU should be Successful   ${sa_ue_id10}
    sleep     5s
    MultiUE Trigger DL Traffic for SA    ${sa_ue_id10}  ${sa_ue_id10}   Traffic_rate=mbps     dl_rate=30        pdu_id=1     trf_id=1     qfi_id=1
    sleep    5s
    Validate DL Traffic For MultiUE for SA   ${sa_ue_id1}  ${sa_ue_id10}   dl_rate=30   pdu_id=1   qfi_id=1
    Multiple NSA UE Register   ${nsa_ue_id11}    ${nsa_ue_id11}
    sleep     5s
    Multiple NSA UE start and validate DL Traffic    ${nsa_ue_id11}  ${nsa_ue_id11}   dl_rate=18
    Multiple NSA UE start and validate UL Traffic    ${nsa_ue_id11}  ${nsa_ue_id11}   dl_rate=11
    FOR    ${m}      IN RANGE    101      112
        Validate DL Traffic For NSA     ${m}     18
        Validate UL Traffic For NSA     ${m}     11
    END
    Stop MultiUE Data Traffic for SA     ${sa_ue_id1}    ${sa_ue_id3}
# Check NBR deactivated successfully for ue id 3 and ue id 2 not affected   need to write the keyword
    MultiUE Deregister should be Successful   ${sa_ue_id1}    ${sa_ue_id10}
    Multiple NSA UE Detach   ${nsa_ue_id1}  ${nsa_ue_id11}
    Stop Log   btslog   snapshot
    [Teardown]     Run Keywords    common Teardown




[1]CB008227-C#B6_TC33_Support_Nominal_Bit_Rate_of_nonGBR_bearers_for_Inter_gNB_PSCell_change_procedure_NSA
	[Documentation]
	...
	...             author:           Madhukara M V
	...             maintainer:       madhukara.m_v@nokia.com
	...
	...             INTRODUCTION:     This user scenario describes the gNB behaviour for  NBR activation when PSCell change happens
	...                               during the inter GNB handover of the feature in NSA mode  ( with 5GC000573-A#B1: Intra-Frequency inter
	...                               en-gNB mobility for NSA Opt 3x  Successful scenario (Ref 5G_RAN_USR_RRM_1034) are satisfied.)

	...             TEST SET NAME:    CB008227
	...             TESTING SPLIT:    Refer CB008227 Test Plan
	...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
	...             REFERENCES:       CB008227 CFAM
	...             Requirement ID:   xxxxx
    [Setup]         Run Keywords          Configure UTE ETH3 and ETH4 IPs
    ...             AND       Testcase Setup   ${AP_XML_tc33}   ${SCFC_tc33}   ${wts_cfg_file_tc33}   2
	 set suite variable     ${TEST_NAME_33}
     ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME_33}
    set test variable      ${LOG_PATH}
    Perform SCF Delta Commissioning with ${Delta_scf_feature_enable_tc33}
    log to console   "waiting till next messurement  period"
    Wait until the next Measurement Period starts
    log to console   "Next Meassuement period  started"
    log to console   "Make X2 link up with ENB1(Simulated) and GNB4(simulated) and make x2 link up with ENB1 and Real GNB2"
#Step : 1 Attach NSA UE to simulated ENB 1 and configure ENDC with Sumilated GNB 4
    X2AP Link Should be UP
    X2AP Link Should be UP with simulated ENB and simulated GNB    src=1   target=4
    sleep     5s
    Link SCOUT SCF to Configuration ID for Reporting
    UE Attach and ENDC should be Successful sim   ${nsa_ue_id31}  Trgt_Cell=1   Trgt_gNB4=4  Bearer_ID=2
    sleep     5s
    Multiple NSA UE start and validate DL Traffic    ${nsa_ue_id31}  ${nsa_ue_id31}   dl_rate=20
    Multiple NSA UE start and validate UL Traffic    ${nsa_ue_id31}  ${nsa_ue_id31}   dl_rate=10
    sleep    5s
    Start Log    cprt
#step 3: Trigger the A3 measuusremts report from NSA ue from Simuated GNB 4 about the target GNB(real) cell (phycell id 50)
    Trigger A3 RsrpAndRsrq Measurement from simulated gnb to real gNB for PScell Change    ue_id=${nsa_ue_id31}    meas_id=3    phycell_id=50
    ${path2}    Stop Log    cprt   test_scenario=user_bearersetup
    Verify nbrDrbSpecificParams In usersetupreq   ${path2}[cprt]/NODECPRT_GNB.pcap   sctp    2000    2000
    sleep   10s
    Validate DL Traffic For NSA     ${nsa_ue_id31}     20
    Validate UL Traffic For NSA     ${nsa_ue_id31}     10
	# verify that NBR ADMIT and NBR Request counters are geting pegged
	${pm_counter_file}=    Get Next Unpacked Full Pm Counters File   output_dirpath=${OUTPUT DIR}/pmcounter1
    Verify Any Counters In File
    ...  M55115C03506  1  NSA_DU_DRB_NBR_REQ
    ...  M55115C03507  1  NSA_DU_DRB_NBR_ADMIT_WITH_NBR
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL_ID_tc33}
    ...  file_path=${pm_counter_file}

    log to console   "wait till meas period stops and collect the PM files and verify the PM counters for NBR DL and UL"
    Wait until the current Measurement Period stops
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File   output_dirpath=${OUTPUT DIR}/pmcounter2
    Verify Any Counters In File
    ...  M55115C03509  300  NSA_DU_DRB_NBR_DL
    ...  M55115C03510  300  NSA_DU_DRB_NBR_UL
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL_ID_tc33}
    ...  file_path=${pm_counter_file}

    Multiple NSA UE Detach   ${nsa_ue_id31}  ${nsa_ue_id31}
    Stop Log   btslog   snapshot
    [Teardown]   Run Keywords    common Teardown




[1]CB008227-D#B1_TC37_NBR_congestion_detection_and_handling_Enable_combinations_of_congestion_control_pdsch_pusch_congcontrol_flag_arpPrio_SA_NSA
	[Documentation]
	...
	...             author:           Madhukara M V
	...             maintainer:       madhukara.m_v@nokia.com
	...
	...             INTRODUCTION:     This user scenario describes the gNB behavior related to NBR bearers
	...                               congestion detection and congestion handling with both
	...                               "PDSCH & PUSCH congeztion control" and congWeightAlg set to "arpPrioVul"
	...
	...             TEST SET NAME:    CB008227
	...             TESTING SPLIT:    Refer CB008227 Test Plan
	...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
	...             REFERENCES:       CB008227 CFAM
	...             Requirement ID:   5G_RAN_USR_RRM_20653
	...             Testing method:   Enable congession detection and handling for PUSCH and PDSCH with "arpPrioVul" method
	...                               1. Attach 1 SA UE with fqi 6 VONR(GBR) capabilty, add 3 more SA bearers with 5qi 7,8, and 9
	...                               2. Add VONR(GBR) bearer with 5qi 5 and 1
	...                               3. Set nbrdl=300 and nbrul=100 and maxnbrtrafficlimit=10 and maxnbrprbsperue=90%
	...                               4. Attach 1 NSA nbr bearer with qci 9
	...                               5. Verify that all the SA and NSA bearers are de prioritized and counters get pegged
	...                               6. Verify no impact on GBR bearer is observed and  no call drop when nbr congession is detected
	...                               7. Here nbr tput may not be achived as congession is detetected as they are de prioritized
	...                               8. The validation of tput is not mandatory as it varying accroding to de/re-prio
	...                               9. the tput verification is checked gbr bit rate of vonr bearer 2MBPS and other berers with > 2 MBPS

    [Setup]     Testcase Setup   ${AP_XML_tc37}   ${SCFC_tc37}   ${wts_cfg_file_tc37}   4
    set suite variable     ${TEST_NAME_37}
     ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME_37}
    set test variable      ${LOG_PATH}
    X2AP Link Should be UP
    Wait until the next Measurement Period starts
    log to console   "SA UE attach with NBR Bearers are trigerring now"
#Step 1. Attach SA UE's with 1 default Bearer and 3 NBR Beareres and one VONR GBR bearer
    Link SCOUT SCF to Configuration ID for Reporting
    Start Log    cprt
#    Attach    ${nsa_ue_id1}
    UE Attach and ENDC should be Successful   ${nsa_ue_id1}  Trgt_Cell=1   Trgt_gNB4=2  Bearer_ID=2

    MultiUE Register should be Successful    ${sa_ue_id1}     ${sa_ue_id1}
    sleep     2s
#  ADd the VONR bearer and other 5QI bearers with 7,8 and 9
    Add new Bearer for Multiple SA UE    ${sa_ue_id1}    ${sa_ue_id1}    ${Pdu_session_ID}    ${QFI_ID1}
    Add new Bearer for Multiple SA UE    ${sa_ue_id1}    ${sa_ue_id1}    ${Pdu_session_ID}    ${QFI_ID2}
    Add new Bearer for Multiple SA UE    ${sa_ue_id1}    ${sa_ue_id1}    ${Pdu_session_ID}    ${QFI_ID3}
    Add new Bearer for Multiple SA UE    ${sa_ue_id1}    ${sa_ue_id1}    ${Pdu_session_ID}    ${QFI_ID4}
    Add new Bearer for Multiple SA UE    ${sa_ue_id1}    ${sa_ue_id1}    ${Pdu_session_ID}    ${QFI_ID5}

# start trafiic on NSA UE
    sleep    5s
    Multiple NSA UE start and validate DL Traffic    ${nsa_ue_id1}  ${nsa_ue_id1}   dl_rate=100
    Multiple NSA UE start and validate UL Traffic    ${nsa_ue_id1}  ${nsa_ue_id1}   dl_rate=50
# start the DL and UL traffic on VONR bearer and other 5QIs
    ${path1}    Stop Log    cprt   test_scenario=usersetup
    Trigger High DL Traffic SA   ue_id=${sa_ue_id1}    dl_rate=200   pdu_id=${Pdu_session_ID}   qfi_id=${QFI_ID}
    Trigger High DL Traffic SA   ue_id=${sa_ue_id1}    dl_rate=2   pdu_id=${Pdu_session_ID}   qfi_id=${QFI_ID1}
    Trigger High DL Traffic SA   ue_id=${sa_ue_id1}    dl_rate=2   pdu_id=${Pdu_session_ID}   qfi_id=${QFI_ID2}
    Trigger High DL Traffic SA   ue_id=${sa_ue_id1}    dl_rate=200   pdu_id=${Pdu_session_ID}   qfi_id=${QFI_ID3}
    Trigger High DL Traffic SA   ue_id=${sa_ue_id1}    dl_rate=200   pdu_id=${Pdu_session_ID}   qfi_id=${QFI_ID4}
    Trigger High DL Traffic SA   ue_id=${sa_ue_id1}    dl_rate=200   pdu_id=${Pdu_session_ID}   qfi_id=${QFI_ID5}
    sleep   10s
    Trigger High UL Traffic SA   ue_id=${sa_ue_id1}    ul_data=100   pdu_id=${Pdu_session_ID}   qfi_id=${QFI_ID}
    Trigger High UL Traffic SA   ue_id=${sa_ue_id1}    ul_data=2   pdu_id=${Pdu_session_ID}   qfi_id=${QFI_ID1}
    Trigger High UL Traffic SA   ue_id=${sa_ue_id1}    ul_data=2   pdu_id=${Pdu_session_ID}   qfi_id=${QFI_ID2}
    Trigger High UL Traffic SA   ue_id=${sa_ue_id1}    ul_data=100   pdu_id=${Pdu_session_ID}   qfi_id=${QFI_ID3}
    Trigger High UL Traffic SA   ue_id=${sa_ue_id1}    ul_data=100   pdu_id=${Pdu_session_ID}   qfi_id=${QFI_ID4}
    Trigger High UL Traffic SA   ue_id=${sa_ue_id1}    ul_data=100   pdu_id=${Pdu_session_ID}   qfi_id=${QFI_ID5}
    sleep   10s
    Wait until the current Measurement Period stops
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File   output_dirpath=${OUTPUT DIR}/pmcounter1
#Update counter values according to testing
    Verify Any Counters In File
    ...  M55139C03509  1200  SA_DU_DRB_NBR_DL
    ...  M55139C03510  1200  SA_DU_DRB_NBR_UL
    ...  M55115C03509  300  NSA_DU_DRB_NBR_DL
    ...  M55115C03510  300  NSA_DU_DRB_NBR_UL
    ...  M55300C12010   > 299  ACC_DU_DRB_NBR_DL_DEPRIO_CONG
    ...  M55370C00041   > 700  ACC_DU_DRB_NBR_UL_DEPRIO_CONG
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL_ID_tc37}
    ...  file_path=${pm_counter_file}
    Validate DL Traffic For UEs diff QFI   197   2  2   197  197  197
    Validate UL Traffic For UEs diff QFI   37   2  2   31  37  33
# check the traffic on SA bearers and NSA and VONR .. this make sure that there is no call drop
    Validate DL Traffic For NSA with No Cap on Tput     ${nsa_ue_id1}     50
    Validate UL Traffic For NSA with No Cap on Tput     ${nsa_ue_id1}     49

    MultiUE Deregister should be Successful    ${sa_ue_id1}    ${sa_ue_id1}
    Multiple NSA UE Detach   ${nsa_ue_id1}  ${nsa_ue_id1}
    [Teardown]   Run Keywords    common Teardown

*** Keywords ***

Validate DL Traffic For UEs diff QFI
    [Arguments]    ${de_qfi}   ${qfi1}   ${qfi2}   ${qfi3}   ${qfi4}  ${qfi5}
    Validate DL Traffic For SA with no Cap on Tput   ue_id=${sa_ue_id1}     dl_rate=${de_qfi}   pdu_id=1    qfi_id=${QFI_ID}
    Validate DL Traffic For SA with no Cap on Tput   ue_id=${sa_ue_id1}     dl_rate=${qfi1}   pdu_id=1    qfi_id=${QFI_ID1}
    Validate DL Traffic For SA with no Cap on Tput   ue_id=${sa_ue_id1}     dl_rate=${qfi2}   pdu_id=1    qfi_id=${QFI_ID2}
    Validate DL Traffic For SA with no Cap on Tput   ue_id=${sa_ue_id1}     dl_rate=${qfi3}   pdu_id=1    qfi_id=${QFI_ID3}
    Validate DL Traffic For SA with no Cap on Tput   ue_id=${sa_ue_id1}     dl_rate=${qfi4}   pdu_id=1    qfi_id=${QFI_ID4}
    Validate DL Traffic For SA with no Cap on Tput   ue_id=${sa_ue_id1}     dl_rate=${qfi5}   pdu_id=1    qfi_id=${QFI_ID5}

Validate UL Traffic For UEs diff QFI
    [Arguments]    ${qfi}   ${qfi1}   ${qfi2}   ${qfi3}   ${qfi4}  ${qfi5}
    Validate UL Traffic For SA with no Cap on Tput   ue_id=${sa_ue_id1}     ul_rate=${qfi}   pdu_id=1    qfi_id=${QFI_ID}
    Validate UL Traffic For SA with no Cap on Tput   ue_id=${sa_ue_id1}     ul_rate=${qfi1}   pdu_id=1    qfi_id=${QFI_ID1}
    Validate UL Traffic For SA with no Cap on Tput   ue_id=${sa_ue_id1}     ul_rate=${qfi2}   pdu_id=1    qfi_id=${QFI_ID2}
    Validate UL Traffic For SA with no Cap on Tput   ue_id=${sa_ue_id1}     ul_rate=${qfi3}   pdu_id=1    qfi_id=${QFI_ID3}
    Validate UL Traffic For SA with no Cap on Tput   ue_id=${sa_ue_id1}     ul_rate=${qfi4}   pdu_id=1    qfi_id=${QFI_ID4}
    Validate UL Traffic For SA with no Cap on Tput   ue_id=${sa_ue_id1}     ul_rate=${qfi5}   pdu_id=1    qfi_id=${QFI_ID5}

Add new Bearer for Multiple SA UE
     [Arguments]    ${first_ue_id}    ${last_ue_id}    ${pdu_id}      ${qos_id}
     FOR   ${ue_id}    IN RANGE    ${first_ue_id}     ${last_ue_id}+${1}
        UE PDU Modfication should be Successful   ${ue_id}      pdu_id=${pdu_id}      qosflows_to_add=${qos_id}
        sleep   5s
     END


Check Average Rate with No Cap on Tput
    [Arguments]    ${bearer_stat}    ${dir}    ${mbps}
    ${output}         Get Regexp Matches    ${bearer_stat}    Average data rate +(\\d+)    1
    ${result}         Evaluate    ( int(${output[0]}) > 2 )
    Run Keyword if    ${result}    Log to Console    ${dir} Average data rate: ${output[0]}
    ...               ELSE    BuiltIn.Log     ${dir} Average data rate: ${output[0]}    level=ERROR
    Run Keyword and Continue on Failure
    ...               Should Be True    ${result}    msg=${dir} Average data rate failed!
    log to console      ${mbps}

Validate DL Traffic For SA with no Cap on Tput
    [Documentation]    SA Traffic Criteria
    ...                1. Average data rate must be within 90% and 110% of expected rate
    ...                2. DL Bytes Received must be equal to ALL Bytes Sent
    [Arguments]    ${ue_id}     ${dl_rate}     ${pdu_id}=${Pdu_session_ID}      ${qfi_id}=${QFI_ID}
    wtsrunner.bearer_stats  ue=${ue_id}   pdu=${pdu_id}   qfi=${qfi_id}   dir=dl
    ${bearer_stat_dl}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    Check Average Rate with No Cap on Tput      ${bearer_stat_dl}    DL    ${dl_rate}
    Run keyword and Ignore Error    Check DL Data Loss      ${bearer_stat_dl}    ${bearer_stat_dl}
Validate UL Traffic For SA with no Cap on Tput
    [Documentation]    SA Traffic Criteria
    ...                1. Average data rate must be within 90% and 110% of expected rate
    ...                2. UL Bytes Sent must be equal to ALL Bytes Received
    [Arguments]    ${ue_id}     ${ul_rate}     ${pdu_id}=${Pdu_session_ID}      ${qfi_id}=${QFI_ID}
    wtsrunner.bearer_stats  ue=${ue_id}   pdu=${pdu_id}   qfi=${qfi_id}   dir=ul
    ${bearer_stat_ul}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    Check Average Rate with No Cap on Tput      ${bearer_stat_ul}    UL    ${ul_rate}
    Run keyword and Ignore Error    Check UL Data Loss      ${bearer_stat_ul}    ${bearer_stat_ul}
Validate UL Traffic For NSA with No Cap on Tput
    [Documentation]    SA Traffic Criteria
    ...                1. Average data rate must be within 90% and 110% of expected rate
    ...                2. UL Bytes Sent must be equal to ALL Bytes Received
    [Arguments]    ${ue_id}     ${ul_rate}     ${id}=${Bearer_ID}
    wtsrunner.bearer_stats  ue=${ue_id}   id=${id}   dir=ul
    ${bearer_stat_ul}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    Check Average Rate with No Cap on Tput      ${bearer_stat_ul}    UL    ${ul_rate}
    Run keyword and Ignore Error    Check UL Data Loss      ${bearer_stat_ul}    ${bearer_stat_ul}
Validate DL Traffic For NSA with No Cap on Tput
    [Documentation]    SA Traffic Criteria
    ...                1. Average data rate must be within 90% and 110% of expected rate
    ...                2. DL Bytes Received must be equal to ALL Bytes Sent
    [Arguments]    ${ue_id}     ${dl_rate}     ${id}=${Bearer_ID}
    wtsrunner.bearer_stats  ue=${ue_id}   id=${id}   dir=dl
    ${bearer_stat_dl}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    Check Average Rate with No Cap on Tput      ${bearer_stat_dl}    DL    ${dl_rate}
    Run keyword and Ignore Error    Check DL Data Loss      ${bearer_stat_dl}    ${bearer_stat_dl}

MultiUE Register should be Successful with diff slice
    [Arguments]    ${start_ue_id}   ${end_ue_id}
    FOR     ${ue_id}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
       UE Register should be Successful   ue_id=${ue_id}     pdu_id=${Pdu_session_ID}     nw_id=${nwslice_ID}      gw_id=${gw_ID}
       ${nwslice_ID}=      Evaluate       ${nwslice_ID}+1
       ${gw_ID}=      Evaluate       ${gw_ID}+1
    END

Validate DL Traffic For all UEs
    [Arguments]    ${ue1_tput}    ${ue2_tput}    ${ue3_tput}
    Run Keyword and continue on Failure   Validate DL Traffic For SA   ue_id=${sa_ue_id1}     dl_rate=${ue1_tput}   pdu_id=1    qfi_id=${QFI_ID}
    Run Keyword and continue on Failure   Validate DL Traffic For SA   ue_id=${sa_ue_id2}     dl_rate=${ue2_tput}   pdu_id=1    qfi_id=${QFI_ID}
    Run Keyword and continue on Failure   Validate DL Traffic For SA   ue_id=${sa_ue_id3}     dl_rate=${ue3_tput}   pdu_id=1    qfi_id=${QFI_ID}

Validate UL Traffic For all UEs
    [Arguments]    ${ue1_tput}    ${ue2_tput}    ${ue3_tput}
    Run Keyword and continue on Failure   Validate UL Traffic For SA   ue_id=${sa_ue_id1}     ul_rate=${ue1_tput}   pdu_id=1    qfi_id=${QFI_ID}
    Run Keyword and continue on Failure   Validate UL Traffic For SA   ue_id=${sa_ue_id2}     ul_rate=${ue2_tput}   pdu_id=1    qfi_id=${QFI_ID}
    Run Keyword and continue on Failure   Validate UL Traffic For SA   ue_id=${sa_ue_id3}     ul_rate=${ue3_tput}   pdu_id=1    qfi_id=${QFI_ID}




X2AP Link Should be UP with simulated ENB and simulated GNB    # This is for setting ENDC call with ENB and GNB ( both simulated)
    [Arguments]     ${src}   ${target}
    [Documentation]    This keyword is used to Create a X2 connection with gNB
    ...                And checks if the X2AP link with the gNB is UP in the output file.
    wtsrunner.enb_x2_link_up    enb=${src}    target=${target}
    Read WTS Output For Pattern And Print matching Lines    ${x2_UP_pattern_with_simulated_gnb}    ${timeout}
    BuiltIn.Log    x2_is_ok

UE Attach and ENDC should be Successful  #NSA
    [Arguments]    ${NSA_UE_ID}  ${Trgt_Cell}   ${Trgt_gNB4}   ${Bearer_ID}
    [Documentation]    This keyword is used to Attach the UE with gNB and check the completion message in output file.
    LTE Attach should be Successful    ${NSA_UE_ID}
    sleep    10s
    wtsrunner.enb_ue_dc_start    target_gnb=${Trgt_gNB4}    target_cells=${Trgt_Cell}    ue=${NSA_UE_ID}
    ...  bearer=${Bearer_ID}    type=split_scg
    ${output}    Read WTS Output For Pattern And Print matching Lines    ${UE_attach_pattern}    ${timeout}
    [Return]      ${output}

UE Attach and ENDC should be Successful sim  #NSA
    [Arguments]    ${NSA_UE_ID}  ${Trgt_Cell}   ${Trgt_gNB4}   ${Bearer_ID}
    [Documentation]    This keyword is used to Attach the UE with gNB and check the completion message in output file.
    LTE Attach should be Successful    ${NSA_UE_ID}
    sleep    10s
    wtsrunner.enb_ue_dc_start    target_gnb=${Trgt_gNB4}    target_cells=${Trgt_Cell}    ue=${NSA_UE_ID}
    ...  bearer=${Bearer_ID}    type=split_scg
    ${output}    Read WTS Output For Pattern And Print matching Lines    ${UE_attach_pattern_RA}    ${timeout}
    [Return]      ${output}


Trigger A3 RsrpAndRsrq Measurement from simulated gnb to real gNB for PScell Change
    [Arguments]     ${ue_id}    ${meas_id}    ${phycell_id}
    wtsrunner.ue_measurement_send_nr    id=${ue_id}    meas_id=${meas_id}    event=A3    srsrp_nr=1    srsrq_nr=1    phycell_id=${phycell_id}
    ...   nrsrp_nr=30    nrsrq_nr=20
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Inter Sgnb Handover is successful   timeout=15
    ${output}         Get Lines Matching Regexp    ${output}    Inter Sgnb Handover is successful    partial_match=${TRUE}
    Log to Console    ${output}

Configure UTE ETH3 and ETH4 IPs
    [Documentation]    This keyword is to configure VM interfaces.
    Log To Console    configure VM interfaces...
    OperatingSystem.Run     sudo ip addr add 10.0.2.1/24 dev eth4
    OperatingSystem.Run     sudo ip addr add 10.0.1.121/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.122/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.123/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.124/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.125/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.126/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.127/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.128/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.129/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.130/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.131/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.132/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.133/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.134/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.135/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.136/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.137/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.138/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.139/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.140/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.141/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.142/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.143/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.144/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.145/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.146/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.147/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.148/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.149/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.150/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.151/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.152/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.153/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.154/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.155/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.2.90/24 dev eth4
    OperatingSystem.Run     sudo ip addr add 10.0.2.91/24 dev eth4
    OperatingSystem.Run     sudo ip addr add 10.0.2.92/24 dev eth4
    OperatingSystem.Run     sudo ip addr add 10.0.2.93/24 dev eth4
    OperatingSystem.Run     sudo ip addr add 10.0.2.94/24 dev eth4
    OperatingSystem.Run     sudo ip addr add 10.0.2.95/24 dev eth4
    OperatingSystem.Run     sudo ip addr add 10.0.2.96/24 dev eth4
    OperatingSystem.Run     sudo ip addr add 10.0.2.97/24 dev eth4
    OperatingSystem.Run     sudo ip addr add 10.0.2.98/24 dev eth4
    OperatingSystem.Run     sudo ip addr add 10.0.2.99/24 dev eth4
    OperatingSystem.Run     sudo ip addr add 10.0.2.100/24 dev eth4
    OperatingSystem.Run     sudo ip addr add 10.0.1.9/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.10/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.11/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.12/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.13/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.14/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.15/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.100/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.101/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.102/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.103/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.104/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.105/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.106/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.107/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.108/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.109/24 dev eth3
