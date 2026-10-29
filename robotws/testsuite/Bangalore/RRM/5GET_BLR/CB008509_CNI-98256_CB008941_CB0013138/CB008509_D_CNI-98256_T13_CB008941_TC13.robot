*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_FDD

Documentation
...  AUTHOR          :   Kiran.G  kiran.1.g@nokia.com
...  MAINTAINER      :   Kiran.G  kiran.1.g@nokia.com
...  INTRODUCTION    :   CB013138 RIM Mitigation Enhancemment
...  TEST SET NAME   :   CB013138_A_02_D_02_RIMRS1_RS2_based_DL_mitigation
...  TESTING SPLIT   :   Split-A , Split-B , Split-D
...  CONTACTS        :   kiran.1.g@nokia.com
...  REFERENCES      :   CB013138-CFAM
...  REQUIREMENT ID  :   5G_RAN_USR_RRM_26491;5G_RAN_USR_RRM_26492;5G_RAN_USR_RRM_26504;CB_FIM_48841;5G_PM_1974
...  Requirement ID  :   5G_RAN_USR_RRM_17671


Resource         ./CB008509_Resource.robot
Resource         ./CB008941_resource.robot
Resource         ./basic_resource.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../resources/ECEcommon/common_setup_teardown.robot
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/PM_Counters.robot
Library          ta5g_enb
Library          taf.sw.scout    WITH NAME     scout
Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Library          Collections
Library          ta5g_commissioning
Library          ../resources/python/BIP_Capture.py
Library          ../resources/python/CPRT_Capture.py

*** Variables ***
${WTS_DIR}             /opt/iphy/latest
&{WTS}                 Ip=127.0.0.1        Username=ute         Connection=Wts
${wts_cfg_file1}     ${CURDIR}/wts/basic_setup_2CC_max_gfbr_30_tdd_um_mode.cfg
${wts_cfg_file2}     ${CURDIR}/wts/basic_setup_gen.cfg
${wts_cfg_file3}     ${CURDIR}/wts/basic_setup_APoABIO_MultiUe_VONR_tdd.cfg
${epc_log_path}    /tmp/
${UE_ID}        1
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID}    1
${TRF_ID2}    2
${largebwp_id}   1
${smallbwp_id}   2
${psbwp_id}     3
&{ciph}         nea0=1      nea1_128=2  nea2_128=4  nea3_128=3
&{intgr}        nia0=1      nia1_128=2  nia2_128=4  nia3_128=3
${ip_prof}      null
${ip_prof1}      snow3g
${ip_prof2}      aes
${ip_prof3}      zuc
&{ue_profile}    ${1}=${ip_prof3}    ${2}=${ip_prof2}
&{ip_ie}    ${1}=preferred      ${2}=preferred
&{max_ip_rate}    ${1}=maximum-UE-rate     ${2}=maximum-UE-rate
&{max_ip_rate_dl}    ${1}=maximum-UE-rate      ${2}=maximum-UE-rate
&{ip_result}      ${1}=performed     ${2}=performed
${TEST_NAME}            Cell_setup
${IPHY_FILE}                   ${CURDIR}/wts/Conf_7752-B-SANSA-TDD-iphy.xml
${PRB_USED_PDSCH}              M55308C10001
${DL_DATA_SLOTS}               M55308C00001
${SS_BURST_SLOTS}              M55308C00003
${DATA_SLOT_PDSCH}             M55308C00005
${SSB_SLOT_PDSCH}              M55308C00015
${TRS_SLOT_PDSCH}              M55308C00017
${DL_SLOTS_BELOW_TGT_LOAD}     M55308C00043
${DL_SLOTS_ARTIFICIAL_LOAD}    M55308C00044
${DL_PRB_ARTIFICIAL_LOAD}      M55308C00045
${TRS_SLOTS}                   M55308C00046
${AVE_NUMBER_OF_SA_RRC}        M55138C00008
${AVE_NUMBER_OF_NSA_USERS}     M55114C00008
${MAX_LOAD_PERCENT}    ${25}
${CellBW}              ${273}
${st_ue_id}      ${1}
${en_ue_id}      ${2}
${SCFC}=            testsuite/Bangalore/RRM/5GET_BLR/CNI-98256/config/SCF/TDD_2cell_scf.xml
${AP_XML}=          testsuite/Bangalore/RRM/5GET_BLR/CNI-98256/config/SCF/TDD_2cell_iphy.xml
# GFBR and MFBR profile <qos flow id>_gfbr_<dir>=speed
&{gfbr_mfbr_profile}                5_gfbr_ul=10   5_gfbr_dl=20    5_mfbr_ul=40     5_mfbr_dl=50

@{QOS_Prof1}                1           5
@{QOS_Prof1_speed_ul}       2           6
@{QOS_Prof1_speed_dl}       2           6
@{QOS_Prof1_unit}           mbps        mbps
@{L2PS_RI_DEBUG}=           0x58057A = 4
...                         0x58057f = 3
${RI_LOW_POWER_VALUES}=     SEPARATOR=
...                         -140,-140,-139,-138,-137,-136,-135,-134,-133,-132,-131,-130,-128,-126,-124,-122,-120,
...                         -118,-120,-124,-126,-128,-130,-131,-132,-133,-134,-135,-136,-137,-138,-140
${RI_HIGH_POWER_VALUES}=    SEPARATOR=
...                         -100,-97,-95,-92,-90,-89,-85,-81,-78,-77,-75,-73,-70,-67,-65,-60,-52,-55,-60,-64,-68,
...                         -72,-76,-80,-84,-88,-91,-94,-97,-99,-100,-101
${RI_MONITORING_PERIOD}=    5m

*** Test Cases ***

[1]CB008509-D_TC3_Verify_Legacy_Counters_with_Dummy_load_on_PDSCH_PDCCH_SSB_TRS_with_PRB_pooling_TDD_without_BeamForming

    [Tags]    TC01
	[Setup]    Run keywords     Suite setup from scratch
	...                 AND     Add RD Parameters To GNB Swconfig File    ${radparam}
	...                 AND     Enable CPRT Debug Log
	...                 AND     Perform SCF Delta Commissioning with D_TC3.json
#	...                 AND     Start Default Logging    output_dirpath=${LOG_PATH}
	...                 AND     Reboot gNB System Module from Console and check Airscale is ready
	...                 AND     Load CFG Config And Capture CPRT Traces      ${wts_cfg_file1}
	...                 AND     Start Log    btslog


    ${pdschheader}     Create list    type    3gpp.subcellid    3gpp.sfn    3gpp.slot     3gpp.rnti
    ...    DlData_PdschGrant.numOfPrb    DlData_PdschGrant.rat0Bitmap    DlData_PdschGrant.mcs
    ...    DlData_PdschGrant.mcsTable    DlData_PdschGrant.patternId_item

    ${pdcchheader}     Create list    type    3gpp.subcellid    3gpp.sfn    3gpp.slot     3gpp.rnti
    ...    DlData_DciInfo.startSymbolNumber    DlData_DciInfo.numOfSymbols    DlData_DciInfo.startCce
    ...    DlData_DciInfo.aggregationLevel    DlData_DciInfo.coresetFreqDomain    DlData_DciInfo.interleaverRows
    ...    DlData_DciInfo.regBundleSize    DlData_DciInfo.coresetFreqDomainRbShift    DlData_DciInfo.patternId_item

    ${actualtargetload}    Evaluate    (${CellBW}*${MAX_LOAD_PERCENT})/${100}
    ${targetloadpdsch}    Calculate Target Load Sector Beam    ${CellBW}    ${1}    ${MAX_LOAD_PERCENT}
    ...    nbrOfBlankedPRBsHighEdgeDL=${0}    nbrOfBlankedPRBsLowEdgeDL=${0}
    log to console    targetloadpdsch-${targetloadpdsch}

    ${pdcchtargetload}    Calculate Target Load Sector Beam PDCCH    ${CellBW}    ${MAX_LOAD_PERCENT}
    log to console    targetloadpdsch-${pdcchtargetload}

    ${targetload}    get_max_prb     ${targetloadpdsch}     ${pdcchtargetload}
    log to console    targetload-${targetload}

    log to console   UE attach trigerring now...
    Wait until the next Measurement Period starts  additional_time=${0}
    Start Log    biptaf
    sleep    1s
    ${scen1}     Stop Log     biptaf     test_scenario=cell_idle
    ${CsvPathpdsch1}     Convert PCAP to CSV    ${scen1}[biptaf]   dldata_pdschsendreql1sw    dldata_pdschsendreqlisw
    ...    @{pdschheader}
    ${CsvPathpdcch1}     Convert PCAP to CSV    ${scen1}[biptaf]   dldata_pdcchsendreql1sw    dldata_pdcchsendreql1sw
    ...    @{pdcchheader}
    sleep    120s
    Wait until the current Measurement Period stops
    CB008509 Collect PM Counters New

    Get counters and validate     ${PRB_USED_PDSCH}     ${DL_DATA_SLOTS}     ${SS_BURST_SLOTS}     ${DATA_SLOT_PDSCH}
    ...    	${SSB_SLOT_PDSCH}    ${TRS_SLOT_PDSCH}     ${DL_SLOTS_BELOW_TGT_LOAD}	${DL_SLOTS_ARTIFICIAL_LOAD}
    ...     ${DL_PRB_ARTIFICIAL_LOAD}     ${TRS_SLOTS}    ${AVE_NUMBER_OF_SA_RRC}     ${AVE_NUMBER_OF_NSA_USERS}
    ...     1    2    1    ${actualtargetload}    ${targetload}

#Step-2: attach 2 UEs, UE-1 and UE-2
    Wait until the next Measurement Period starts  additional_time=${0}
    ${crnti_list_1}=      MultiUE Register should be Successful    1   2    pdu_id=1     nw_id=1

#Step-3: start data transfer from UE-1 so that no of PRBs used by UE-1(e.g. Y-PRBS) is less than PRB defined by
#        targetTotalLoadSectorBeam (X-PRBs)

    MultiUE Trigger DL Traffic for SA    1  2    Traffic_rate=mbps     dl_rate=80     pdu_id=1    trf_id=1      qfi_id=1
    MultiUE Trigger UL Traffic for SA    1  2    Traffic_rate=mbps     ul_rate=40     pdu_id=1    trf_id=1      qfi_id=1
    X2AP Link Should be UP
    MultiUE Attach for NSA    31    31
    MultiUE DL Traffic Start for NSA    31    31    mbps    80     id=2    trf_id=1
    MultiUE UL Traffic Start for NSA    31    31    mbps    20     id=2    trf_id=1
    sleep    120s
    Start Log    biptaf
    sleep    1s
    ${scen2}     Stop Log     biptaf    test_scenario=with_3_real_ue
    ${CsvPathpdsch2}     Convert PCAP to CSV    ${scen2}[biptaf]    dldata_pdschsendreql1sw    dldata_pdschsendreql1sw
    ...    @{pdschheader}
    ${CsvPathpdcch2}     Convert PCAP to CSV    ${scen2}[biptaf]    dldata_pdcchsendreql1sw    dldata_pdcchsendreql1sw
    ...    @{pdcchheader}
    sleep    600s
    Wait until the current Measurement Period stops
    CB008509 Collect PM Counters New
    Get counters and validate     ${PRB_USED_PDSCH}     ${DL_DATA_SLOTS}     ${SS_BURST_SLOTS}
    ...    	${DATA_SLOT_PDSCH}     ${SSB_SLOT_PDSCH}    ${TRS_SLOT_PDSCH}     ${DL_SLOTS_BELOW_TGT_LOAD}
    ...     ${DL_SLOTS_ARTIFICIAL_LOAD}     ${DL_PRB_ARTIFICIAL_LOAD}     ${TRS_SLOTS}    ${AVE_NUMBER_OF_SA_RRC}
    ...     ${AVE_NUMBER_OF_NSA_USERS}     2    ${2}    ${1}    ${actualtargetload}    ${targetload}

    Stop MultiUE Data Traffic for SA     1  2
    MultiUE Detach for NSA    31    31
    MultiUE Deregister should be Successful   1  2

	[Teardown]      Run Keywords
    ...             Sleep   1s
    ...             AND     Kill WTS processes Using WTS_Runner
    ...             AND     Link SCOUT SCF to Configuration ID for Reporting

[1]CNI_98256_B_B1_5_US1_Xn_HO_with_UPIP_activated_Integrity_Protection_Indication_preferred_UPIP_traffic_64kbps_UPIPInd-Pref_UPIPAlg-ZUC_IWK_CB008699

    [Tags]    TC02
	[Setup]    Run keywords     Suite setup from scratch
	...                 AND     OperatingSystem.Run     sudo ip addr add 10.0.1.3/24 dev eth3
	...                 AND     OperatingSystem.Run     sudo ip addr add 10.0.1.4/24 dev eth3
	...                 AND     Perform SCF Delta Commissioning with basic_setup_2CC_tdd_XnHO_ref_5QI6-3.json
	...                 AND     sleep    120
	...                 AND     Reboot gNB System Module from Console and check Airscale is ready
	...                 AND     update_delta_and_create.update_cfg  ${CURDIR}/wts/basic_setup_2CC_tdd_XnHO_5QI6-3_ZUC.cfg      ${ue_profile}
#	...                 AND     Start Default Logging    output_dirpath=${LOG_PATH}
	...                 AND     Configure UTE ETH3 IPs_CNI
	...                 AND     Start WTS Using WTS_Runner      ${wts_cfg_file2}


    Set Suite Variable    ${ip_ie}      &{ip_ie}
    Set Suite Variable    ${max_ip_rate}      &{max_ip_rate}
    Set Suite Variable    ${max_ip_rate_dl}      &{max_ip_rate_dl}
    Set Suite Variable    ${ip_result}      &{ip_result}
    Set Suite Variable    ${ue_profile}      &{ue_profile}

    Increase Buffer Size for VM and IPHY
    X2AP Link Should be UP
    ue location change
    Sleep   20
    ${qos_profile}               Create Dictionary   ${1}=${QOS_Prof1}              ${2}=${QOS_Prof1}
    ${qos_profile_speed_ul}      Create Dictionary   ${1}=${QOS_Prof1_speed_ul}     ${2}=${QOS_Prof1_speed_ul}
    ${qos_profile_speed_dl}      Create Dictionary   ${1}=${QOS_Prof1_speed_dl}     ${2}=${QOS_Prof1_speed_dl}
    ${qos_profile_unit}          Create Dictionary   ${1}=${QOS_Prof1_unit}         ${2}=${QOS_Prof1_unit}

    Wait until the next Measurement Period starts
    ${ue_to_bearer_list}=  MultiUE Register should be Successful Custom      ${st_ue_id}    ${en_ue_id}   pdu_session_setup
    ... 	${ip_ie}      ${max_ip_rate}     pdu_id=1    nw_id=1  ho=${1}    negtive=${1}

    Create Modify PDU session   ${st_ue_id}     ${en_ue_id}    ${qos_profile}   pdu_id=1    gfbr_mfbr_profile=${gfbr_mfbr_profile}
    ...    ue_to_bearer_list=${ue_to_bearer_list[1]}  ho=${1}
       Wait until the current Measurement Period stops
    ${duration}      Set Variable    500
    ${trf_id}      Set Variable    ${1}

    Start Data Transfer     ${st_ue_id}     ${en_ue_id}     ${duration}    both   ${trf_id}   ${qos_profile_unit}  ${qos_profile_speed_ul}
    ...     ${qos_profile_speed_dl}    ${qos_profile}
        Establish Xn Link To UPIP gNB3
    sleep   ${120}s

    Enable Max integrity dat rate       path_switch    ${ip_ie[${st_ue_id}]}    required
    wtsrunner.gnb_xn_handover_preparation_param  id=3  action=modify_drb_qos_mapping  drb_qos_map_modification=exclude_mapping  pdu_sessions=1
    ${capture_cprt}     Capture CPRT Set Upon Config

    sleep   ${60}s
    Start Log    cprt
    HO SA A3 UE measurements Custom
    sleep  10s
    ${cprt_log}     Stop Log  cprt  test_scenario=ue_test
    sleep   ${180}s
        Collect PM Counter
      ${Counters}    Create Dictionary    ${PDU_SES_STP_ATT_UPIP_PREF}=${1}     ${PDU_SES_STP_SUC_UPIP_ACT_PREF}=${1}
    ...    ${PDU_SES_STP_SUC_UPIP_NACT_PREF}=${0}
    Verify Counters upip   ${Counters}

    sleep   ${120}s
    Verify Bearer_context_setup_req     ${cprt_log}[cprt]/NODECPRT_GNB.pcap      ${st_ue_id}
    Verify Bearer_context_setup_req_ho   ${cprt_log}[cprt]/NODECPRT_GNB.pcap      ${st_ue_id}
    Verify_path_swicth_request    ${cprt_log}[cprt]/NODECPRT_GNB.pcap             ${st_ue_id}

    Check Integrity failure count
    MultiUE Deregister should be Successful      ${st_ue_id}    ${en_ue_id}

	[Teardown]      Run Keywords
    ...             Sleep   1s
    ...             AND     Kill WTS processes Using WTS_Runner
    ...             AND     Link SCOUT SCF to Configuration ID for Reporting


[1]CB008941_A12_1_UL_Fragmentaion_and_CB006991_and_CB008249_enabled_and_succesfull_SA_Call_with_multiple_Ues
    [Documentation]   This user scenario validates system behavior in case when UL UP dynamic fragmentation is
    ...    activated and CB008249 is enabled together with CB006991 enabled, the data transmission in eCPRI uplink
    ...    contains the NR IQ of scheduled PRBs for TDD FR1 deployments, the NR carrier supports UL PRB dynamic
    ...    fragmentation.

    [Tags]    TC03
	[Setup]    Run keywords     Suite setup from scratch
	...                 AND     Modify IPHY File And Send to Airphone Custom    ${IPHY_FILE}
	...                 AND     Download MCShark To UTE_8941
	...                 AND     Add RD Parameters To GNB Swconfig File_8941     ${RD_PARAM}
	...                 AND     Find Scfc And Fix And Send Full Commissioning
	...                         scfc_filename=A12_scf.xml
	...                 AND     sleep    180
	...                 AND     gnb.Perform gNB reboot
	...                 AND     sleep    240
	...                 AND     Perform SCF Delta Commissioning with merged_json.json
	...                 AND     Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces      ${wts_cfg_file3}
	...                 AND     Check gNB Bulid


    Read Cellsetup msg_8941      ${cprt_log}[cprt]/NODECPRT_GNB.pcap
    set test variable      ${LOG_PATH}

    UE Beamforming Profile And Association For 2 Beams SA    ${3}
    Start Log    biptaf
    Register UE And Send Data    1    3
    ${scen1}     Stop Log     biptaf     test_scenario=attach_1_3
    Generate Remote Interference    2    ${RI_LOW_POWER_VALUES}
    Sleep   600s
    Deactivate Remote Interference Testmode    2
    Generate Remote Interference    3    ${RI_HIGH_POWER_VALUES}
    Sleep   600s
    Check If RI Alarm Is Present
    Deactivate Remote Interference Testmode    3
    log to console   check bearer stats
#    Validate UL Traffic For MultiUE for SA    1  3     ul_rate=40
    Sleep   600s

    Start Log         ttitrace
    sleep    1s
    ${scen3}     Stop Log     ttitrace         test_scenario=data_1_3
    sleep   30s    #run for 5min
    Deregister All UE    1   3

    Decode TTI Trace   data_1_3
    ${rc}   tti_utility.verify_sliv   ${scen3}[ttitrace]/output_ul_formated.csv    ulFdSchedData   SLIV
    Should Contain	${rc}	Pass
    ${rc}   Read pucch boundary      ${scen1}[biptaf]/BIP_L1L2.pcap
    Should Contain	${rc}	pass

	[Teardown]      Run Keywords
    ...             Sleep   1s
    ...             AND     Kill WTS processes Using WTS_Runner
    ...             AND     Link SCOUT SCF to Configuration ID for Reporting

*** Keywords ***

Start_capture_testcase_default_logging
    ${TEST_NAME}      replace string   ${TEST_NAME}      ${SPACE}        _
    set suite variable      ${TEST_NAME}
    Start Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}

Register UE And Send Data
    [Arguments]   ${Start_UE}   ${MAX_UE}
    #Start Collecting Syslog     NAME=syslog_ue_attach
    #Start CPRT Trace Capturing
    FOR  ${UE}  IN RANGE   ${Start_UE}   ${MAX_UE}+1    1
        log to console   UE attach triggering now...${UE}
        UE Register should be Successful     ${UE}
        Sleep    5s
        Trigger UL Data Traffic for SA    ue_id=${UE}     Traffic_rate=mbps   ul_rate=40      pdu_id=1    trf_id=1
        sleep   5s
        #Validate UL Traffic For SA   ue_id=${UE}     ul_rate=100      qfi_id=1
    END
    ##Stop Collecting Syslog       NAME=syslog_ue_attach
    #Run Keyword And Ignore Error     Stop CPRT capture   ${CaptureCPRT}
    #Run Keyword And Ignore Error     Move File    ${LOG_PATH}/NODECPRT_GNB.pcap   ${LOG_PATH}/UE_attach_cprt.pcap


Generate Remote Interference
    [Arguments]    ${ID}    ${RI_PWR}
    wtsrunner.remote_interference_testmode_nr  profile_id=${ID}    start_symbol_position=0   num_of_symbols=32
    ...     noise_power_values=${RI_PWR}
    Sleep    2s
    wtsrunner.cell_testmode_set_nr    testmode=remote_interference     gnb=2     cell_id=1      profile_id=${ID}
    ...     action=activate
    Sleep    10s

Create RI Profiles
    [Arguments]    ${RI_PWR}
    wtsrunner.remote_interference_testmode_nr profile_id=${ID}   start_symbol_position=0   num_of_symbols=32
    ...     noise_power_values=${RI_PWR}

Deactivate Remote Interference Testmode
    [Arguments]    ${ID}
    wtsrunner.cell_testmode_set_nr     testmode=remote_interference     gnb=2     cell_id=1     profile_id=${ID}
    ...      action=deactivate
    Sleep    10s

Check If RI Alarm Is Not Present
     ta5g_enb.Verify If Admin Fault Is Down    fault_id=7525

Check If RI Alarm Is Present
     ta5g_enb.Verify If Admin Fault Is Up    fault_id=7525


Deregister All UE
    [Arguments]   ${Start_UE}   ${MAX_UE}
    #Start Collecting Syslog     NAME=syslog_ue_attach
    #Start CPRT Trace Capturing
    FOR  ${UE}  IN RANGE   ${Start_UE}   ${MAX_UE}+1    1
        Stop Data Traffic for SA     ue_id=${UE}
        UE Deregister should be Successful   ue_id=${UE}
    END


Establish Xn Link To UPIP gNB${gnb}
    BuiltIn.Log    Setup Xn Link Between gNB${gnb} and gNB2...    console=${True}
    wtsrunner.gnb_param    id=${gnb}     xn_listening_socket=1     send_xn_setup=true     ciphering_disabled=6:false
    ...     integrityProtection_enabled=6:true     ciphering_algorithm=nea2     integrityprotection_algorithm=nia2
    ${output}       wtsrunner.read_wtsemu_output_until_prompt     timeout=20
    wtsrunner.gnb_xn_link_up      gnb=${gnb}     target=2
    Sleep   30s
    wtsrunner.gnb_xn_link_up      gnb=${gnb}     target=2
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=GNB-${gnb}: XnAP Link with GNB-2   timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    GNB-${gnb}: XnAP Link with GNB-2   partial_match=${TRUE}
    Log to Console    ${output}
