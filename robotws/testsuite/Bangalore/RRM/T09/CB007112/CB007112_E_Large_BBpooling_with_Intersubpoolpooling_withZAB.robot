*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LOOO     VARIANT_SANSA_FS_ECPRI_CMWV_TDD
...               RAN_5G_FDD    RAN_5G      5G_RAN     SBTS00    CONFIGURED   CRT
Documentation    :copyright: Nokia
...              :authors: Sowrabha.S.M
...              :contact: sowrabha.s_m@nokia.com
...              Feature Overview:
...    "CB007112: Baseband resource pooling of up to 16 DL MIMO layers" increases the DL MIMO layers to 16DL
...    for 3 cells TDD FR1 deployment on top of baseband pooling feature CB008940 implementation.

...    Both CB007112 and CB008940 provide pooling of L1 DL PRB processing resources in DL between NR TDD FR1 cells.
...    The main differences are: CB007112 is applicable on full ABIO/ASOE board deployment,
...    CB008940 is applicable on half ABIO/ASOE board deployment, it means CB007112 manages 2 L1 pool processing resources per
...    L2-RT instance, CB008940 manage 1 L1 pool resource per L2-RT instance. CB007112 controls L1 DL PRB processing resources
...    on subcell level granularity, CB008940 controls L1 DL PRB processing resources on stream-PRB level granularity.


Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../../../resources/robot/Setup_Env.robot
Resource         ../../../resources/robot/Airphone.robot
Resource         ../../../resources/robot/WTS_Runner_Keywords.robot
Resource         ./resources/CB007112_keywords.robot
Resource         ../../../resources/robot/common_log_collection.robot
Resource         ../CB009215/resources/CB009215_keyword.robot
Resource         ../CB010544/CB010544_Resource.robot
Library          taf.sw.scout    WITH NAME     scout
Library          resources/check_prballocation.py

Suite Teardown   Run Keyword and Ignore Error    Get Sos Report

*** Variables ***
${wts_cfg_file}        ${CURDIR}/config/basic_setup_7112enable_bkup.cfg
${WTS_DIR}             /opt/iphy/latest
&{WTS}                 Ip=127.0.0.1        Username=ute         Connection=Wts
${en_ue_id}         ${13}
@{cell_id}          50    51    52
${SCFC}=                   Bangalore/RRM/ET/CB007112/SCF_CB007112_largeBBpooling.xml
${AP_XML}=                 Bangalore/RRM/ET/CB007112/iphy_CB007112_largeBBpooling.xml
${BSR_SW_FILE}             BSR_AEHC_2_H2_ALN60_ARP60_P01_COVERAGE_00452_00001.zip
&{minprb}      50=${48}  51=${48}   52=${48}
${wts_cfg_file1}        ${CURDIR}/config/basic_setup_7112enable_csirs.cfg
${filepath}         "https://artifactory-espoo1.ext.net.nokia.com:443/artifactory/mnpute-rotta-local/srjacob/CB007112/"
${UE_RRC_Reject}    RRC Reject was received
${Timeout_SA}    15
${r&d_parameter}      0x580265=2;0x580117=1
${wts_cfg_file2}     ${CURDIR}${/}../CB009842/config/basic_setup_robustness_100UE.cfg
@{syslog_regex_bwp}     DCI11   DCI01
@{syslog_regex_csi}     CSI-RS sending   PER-CSI-PUCCH receiving
${wts_cfg_file3}     ${CURDIR}${/}../CB010544/config/basic_setup_8DL.cfg
${largebwp_id}   1
${psbwp_id}     2
${start_ue_id}    1
${end_ue_id}      6
${BSR_SW_FILE1}     BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001.zip


*** Test Cases ***
[1]CB007112_E_1_Verify_inter_intra_L1SP_pooling_loadbased_algo_with_ZAB
    [Tags]    TC01
    [Setup]   Run keywords    Prepare TL with all config files
    ...                 AND    Perform SCF Delta Commissioning with Delta_configuration_BSR_Package.json
    ...                 AND    Get and Update BSR SW via gitlab   ${BSR_SW_FILE}
    ...                 AND    Add routes
    ...                 AND    gnb.Perform gNB reboot
    ...                 AND    Sleep   500s    reason=wait for RMOD- to comeup
    ...                 AND    Start WTS Using WTS_Runner      ${wts_cfg_file}
    log to console   Suite setup successful ...
    ${LOG_PATH}   Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    Set SRS Beam Position for muMIMO for UE pairing
    Attach four SA UEs in cell and trigger traffic    start_ue_id=1    end_ue_id=1   DL_rate=1    UL_rate=1
    Attach four SA UEs in cell and trigger traffic    start_ue_id=5    end_ue_id=6   DL_rate=1    UL_rate=1
    Attach four SA UEs in cell and trigger traffic    start_ue_id=9    end_ue_id=12   DL_rate=1    UL_rate=1
    Trigger Low Data in All cells
    Run Keyword And Continue On Failure  Collect TTI and Validate lowload subcell Allocation
    Trigger High Data in All cells
	Run Keyword And Continue On Failure  Collect and Valiadate TTI Logs
    [Teardown]    Run Keywords    Run Keyword and Ignore Error     Kill WTS processes Using WTS_Runner
    ...        AND     Run Keyword and Ignore Error    Get Snapshot
    ...        AND   Link SCOUT SCF to Configuration ID for Reporting

[1]CB007112_F_1_Admission_control_for_UE_specific_CSI-RS_in_L1_pool_level
    [Tags]    TC02
    [Setup]    Run keywords   BuiltIn.Set Suite Variable    ${SCFC}    Bangalore/RRM/ET/CB007112/SCF_CB007112_csirs.xml
    ...     AND    BuiltIn.Set Suite Variable     ${AP_XML}      Bangalore/RRM/ET/CB007112/iphy_CB007112_csirs.xml
    ...     AND    Prepare TL with all config files
    ...                 AND    Add routes
    ...                 AND    Update GNB R&D Parameter
    ...                 AND    gnb.Perform gNB reboot
    ...                 AND    Sleep   500s    reason=wait for RMOD to comeup
    ...                 AND    Start WTS Using WTS_Runner      ${wts_cfg_file1}
    ...                 AND    sleep  60s   reason=wait for mib sib
    log to console   Suite setup successful ...
    ${LOG_PATH}   Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    Attach four SA UEs in cell and trigger traffic    start_ue_id=1    end_ue_id=12   DL_rate=10    UL_rate=10
    Run Keyword And Continue On Failure    Collect and Valiadate TTI Sherpa Logs
    Register UE and check RRC Rejection    ue_id=13
    Register UE and check RRC Rejection    ue_id=15
    [Teardown]   Run Keywords  Run Keyword and Ignore Error    MultiUE Deregister should be Successful   1   12
    ...        AND     Run Keyword and Ignore Error    Get Snapshot
    ...        AND     Link SCOUT SCF to Configuration ID for Reporting

[1]CB009842_23_AIWK2_AEC7_Successful_ECID_Measurement_Reporting_for_NR_TADV_Measurement_Quantity_with_Super_cell
    [Tags]    TC03
    [Setup]    Run keywords   BuiltIn.Set Suite Variable  ${SCFC}  testsuite/Bangalore/RRM/5GET_BLR/CB009842/config/SCF/CB009842_Supercell_scf.xml
    ...    AND    BuiltIn.Set Suite Variable    ${AP_XML}   testsuite/Bangalore/RRM/5GET_BLR/CB009842/config/SCF/CB009842_Supercell_iphy.xml
    ...    AND    Prepare TL with all config files
    ...                 AND     Run Keyword and Ignore Error      Suite setup from scratch
    ...                 AND     sleep    300s
    ...                 AND     Start WTS Using WTS_Runner     ${wts_cfg_file2}
    ...                 AND     Check gNB Bulid
    [Documentation]    Robustnes_Test_For_10UEs
	${LOG_PATH}   Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
	Start Log    cprt    biptaf
	wtsrunner.ue_ta_nr   profile_id=1   ue_p_delay_initial=100
	Create TA mode for ues    1    10
	Beam Profile Creation
	Activate Beam profile    1     10    1
	MultiUE Register should be Successful    1    10
	MultiUE Trigger DL Traffic for SA    1    10   mbps    175
	Sleep    5s
	Trigger LMF for ues     1    10
    ${attach}    Stop Log    btslog    cprt    biptaf    test_scenario=attach
    log to console   checking for TA value...
    CheckTAValue    ${attach}[cprt]/NODECPRT_GNB.pcap      100
    Sleep    30s
	Activate Beam profile    1     10    2
	Start Log    cprt    biptaf
	Trigger LMF for ues     1    10
    ${delay}    Stop Log    cprt   biptaf      test_scenario=delay
    log to console   checking for TA value...
    CheckTAValue Empty TADV  ${delay}[cprt]/NODECPRT_GNB.pcap
    Sleep    30s
	Start Log    cprt    biptaf
	Trigger LMF for TADV     1    10
    ${delay1}    Stop Log    cprt   biptaf      test_scenario=delay1
    log to console   checking for TA value...
    CheckTAValue temporarily-not-available  ${delay1}[cprt]/NODECPRT_GNB.pcap
    Sleep    30s
	Activate Beam profile    1     10    1
    Start Log    cprt    biptaf
	Trigger LMF for ues     1    10
    ${delay2}    Stop Log    cprt   biptaf      test_scenario=delay2
    log to console   checking for TA value...
    CheckTAValue    ${delay2}[cprt]/NODECPRT_GNB.pcap      100
    Sleep    30s
    MultiUE Deregister should be Successful   1   10
    [Teardown]     Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
    ...                 AND     Run Keyword and Ignore Error    Get Snapshot
    ...                 AND     Link SCOUT SCF to Configuration ID for Reporting

[1]CB010544_B_05_12UE_to_LBWP_PSBWP_Trigger_BFR_IWK_CB010513
    [Tags]    TC04
    [Setup]     Run keywords       BuiltIn.Set Suite Variable     ${SCFC}      Bangalore/RRM/ET/CB010544/CB010544_B5_10513_scf.xml
    ...    AND    BuiltIn.Set Suite Variable     ${AP_XML}      Bangalore/RRM/ET/CB010544/CB010544_B5_10513_iphy.xml
    ...    AND    Prepare TL with all config files
    ...                 AND     Suite setup from scratch
    ...                 AND     Get and Update BSR SW via gitlab   ${BSR_SW_FILE1}
    ...                 AND     Start WTS Using WTS_Runner     ${wts_cfg_file3}
    ...                 AND     Check gNB Bulid
    [Documentation]   This test case verifies functinality of CB010544 with CB010513.
    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    Start Log  btslog
    Create BeamForming profile attach UE and trigger low data
    Stop Log   btslog  test_scenario=attach
    Start Log  btslog
    Trigger Beam recovery and verify PSBWP through TTI trace
    Stop Log   btslog  test_scenario=beam
    Increase traffic on UE and validate switching to LargeBWP and data traffic
    Stop Data Traffic for SA     ue_id=${UE_ID}
    MultiUE Deregister should be Successful   1   6
    [Teardown]    Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
    ...                 AND     Run Keyword and Ignore Error    Get Snapshot
    ...                 AND     Link SCOUT SCF to Configuration ID for Reporting

*** Keywords ***
Collect TTI and Validate noload subcell Allocation
	Start Log      ttitrace
	Sleep   2s
    ${tti_noload}    Stop Log       ttitrace   test_scenario=Dl_tti_noload
	Decode TTI Trace    Dl_tti_noload
    ${alloacated_subcell}    Create List     2     4    3
    ${alloacated_ulsubcell}    Create List     1     1    1
    ${ch_bw}    Create list   100  60  80
    Validate cell dlprballocation from TTI traces    ${tti_noload}[ttitrace]    ${cell_id}   ${alloacated_subcell}
    ...    ${ch_bw}   subcell=${7}

Collect TTI and Validate lowload subcell Allocation
	Start Log      ttitrace
	Sleep    2s
    ${tti_lowload}    Stop Log       ttitrace   test_scenario=Dl_tti_lowload
	Decode TTI Trace    Dl_tti_lowload
    ${alloacated_subcell}    Create List     1    3    4
    ${alloacated_ulsubcell}    Create List     1     1    1
    ${ch_bw}    Create list   100  60  80
    Validate cell dlprballocation from TTI traces    ${tti_lowload}[ttitrace]    ${cell_id}   ${alloacated_subcell}
    ...    ${ch_bw}   subcell=${7}

Collect and Valiadate TTI Logs
	Start Log      ttitrace
	Sleep    0.5s
    ${sherp_tti}    Stop Log       ttitrace   test_scenario=Dl_tti
	Decode TTI Trace    Dl_tti
    ${alloacated_subcell}    Create List     1     3    4
    ${alloacated_ulsubcell}    Create List     1     1    1
    ${ch_bw}    Create list   100  60  80
    Validate cell dlprballocation from TTI traces    ${sherp_tti}[ttitrace]    ${cell_id}   ${alloacated_subcell}
    ...    ${ch_bw}   subcell=${8}
    #Run Keyword And Continue On Failure   Validate cell ulprballocation from TTI traces    ${sherp_tti}[ttitrace]
    #...    ${cell_id}   ${alloacated_ulsubcell}   ${ch_bw}
    ${ZAB_cells}  ${NOZAB_cells}   Validate ZAB privilege granted    ${sherp_tti}[ttitrace]
    FOR  ${cell}  IN  @{cell_id}
        List Should Contain Value   ${ZAB_cells}    ${cell}
    END
    check_prballocation.Check_minprballocation   ${sherp_tti}[ttitrace]/output_dl_formated.csv    ${minprb}

Trigger Low Data in All cells
    MultiUE Trigger DL Traffic for SA with mutiple traffic id    start_ue_id=1    end_ue_id=1   Traffic_rate=mbps     dl_rate=50
    ...   ul_rate=50   pdu_id=1     trf_id=1     qfi_id=1
    MultiUE Trigger DL Traffic for SA with mutiple traffic id    start_ue_id=5    end_ue_id=6   Traffic_rate=mbps     dl_rate=25
    ...   ul_rate=25   pdu_id=1     trf_id=1     qfi_id=1
    MultiUE Trigger DL Traffic for SA with mutiple traffic id    start_ue_id=9    end_ue_id=12   Traffic_rate=mbps     dl_rate=15
    ...   ul_rate=15   pdu_id=1     trf_id=1     qfi_id=1

Trigger High Data in All cells
    MultiUE Trigger DL Traffic for SA with mutiple traffic id    start_ue_id=1    end_ue_id=1   Traffic_rate=mbps     dl_rate=175
    ...   ul_rate=170   pdu_id=1     trf_id=1     qfi_id=1
    MultiUE Trigger DL Traffic for SA with mutiple traffic id    start_ue_id=5    end_ue_id=6   Traffic_rate=mbps     dl_rate=175
    ...   ul_rate=170   pdu_id=1     trf_id=3     qfi_id=1
    MultiUE Trigger DL Traffic for SA with mutiple traffic id    start_ue_id=9    end_ue_id=12   Traffic_rate=mbps     dl_rate=175
    ...   ul_rate=170   pdu_id=1     trf_id=2     qfi_id=1
    Run Keyword and Ignore Error   Verify DL Tput For all the UEs connected in all cells
    ...   start_ue_id=1    end_ue_id=1
    Run Keyword and Ignore Error   Verify DL Tput For all the UEs connected in all cells
    ...   start_ue_id=5    end_ue_id=6
    Run Keyword and Ignore Error   Verify DL Tput For all the UEs connected in all cells
    ...   start_ue_id=9    end_ue_id=12

Update GNB R&D Parameter
   Get GNB Swconfig File    ${LOG_PATH}
   Modify Swconfig File Parameters    ${LOG_PATH}/swconfig_gnb.txt    ${r&d_parameter}
   Send Swconfig for GNB    ${LOG_PATH}/swconfig_gnb.txt

Register UE and check RRC Rejection
    [Arguments]   ${ue_id}
    wtsrunner.ue_register   id=${ue_id}
    ${output}    Read WTS Output Until Pattern Matches    ${UE_RRC_Reject}    ${Timeout_SA}
    Log to Console    ---> ${UE_RRC_Reject}
    Print Matching Lines from Output File    ${output}    ${UE_RRC_Reject}
    BuiltIn.Log                ue_rejected
    [Return]      ${output}

Collect and Valiadate TTI Sherpa Logs
	Start Log      ttitrace
	Sleep    0.5s
    ${sherp_tti}    Stop Log       ttitrace   test_scenario=Dl_tti
	Decode TTI Trace    Dl_tti
    ${alloacated_subcell}    Create List     1     1    1
    ${alloacated_ulsubcell}    Create List     1     1    1
    ${ch_bw}    Create list   100  100  100
    Validate cell dlprballocation from TTI traces    ${sherp_tti}[ttitrace]    ${cell_id}   ${alloacated_subcell}
    ...    ${ch_bw}   subcell=${3}
    #Run Keyword And Continue On Failure   Validate cell ulprballocation from TTI traces    ${sherp_tti}[ttitrace]
    #...    ${cell_id}   ${alloacated_ulsubcell}   ${ch_bw}
    ${ZAB_cells}  ${NOZAB_cells}   Validate ZAB privilege granted    ${sherp_tti}[ttitrace]
    FOR  ${cell}  IN  @{cell_id}
        List Should Contain Value   ${ZAB_cells}    ${cell}
    END
    check_prballocation.Check_minprballocation   ${sherp_tti}[ttitrace]/output_dl_formated.csv    ${minprb}

Create TA mode for ues
    [Arguments]    ${startue}    ${endue}
    FOR    ${ue_idx}   IN RANGE    ${startue}    ${endue}+1
       wtsrunner.ue_testmode_set_nr    id=${ue_idx}    testmode=ta   profile_id=1    action=activate
    END

Beam Profile Creation
     wtsrunner.beam_control_testmode_nr    profile_id=1    ueBeamIndexInitial=0,1,2,3,4,5    ssbeam_bestbeam=0    ssbeam_rsrp_best=-44
	 ...    ssbeam_rsrp_avg=-50
     wtsrunner.beam_control_testmode_nr    profile_id=2    ueBeamIndexInitial=1,0,2,3,4,5    ssbeam_bestbeam=1    ssbeam_rsrp_best=-45
	 ...    ssbeam_rsrp_avg=-50

Activate Beam profile
     [Arguments]       ${startue}    ${endue}    ${prfileid}
     FOR    ${ue_idx}   IN RANGE    ${startue}    ${endue}+1
      wtsrunner.ue_testmode_set_nr    id=${ue_idx}    testmode=beam_control  action=activate    profile_id=${prfileid}
	 ...   beamaction=attach    scell=0
     END

Trigger LMF for ues
     [Arguments]       ${startue}    ${endue}
     FOR    ${ue_idx}   IN RANGE    ${startue}    ${endue}+1
       wtsrunner.lmf_send_ecid_meas_req    id=1  ue=${ue_idx}    nrppa_transaction_id=1    lmf_ue_measurement_id=1
	   ...    report_characteristics=OnDemand
       ...    meas_qty=SS-RSRP,SS-RSRQ,NR_Timing_Advance
     END

Trigger LMF for TADV
     [Arguments]       ${startue}    ${endue}
     FOR    ${ue_idx}   IN RANGE    ${startue}    ${endue}+1
      wtsrunner.lmf_send_ecid_meas_req    id=1  ue=${ue_idx}    nrppa_transaction_id=1    lmf_ue_measurement_id=1
	 ...    report_characteristics=OnDemand    meas_qty=NR_Timing_Advance
     END

CheckTAValue
    [Arguments]    ${file_path}    ${value}
    ${pdmlFile} =    Get filtered PDML file from pcap   pcapFile=${file_path}    filterExp=nrppa.NR_TADV
    ${pdml_entries}    taf_pdml_analyser.get_pdml_entries     ${pdmlFile}
	...    field_name=nrppa.MeasuredResultsValue   attrib_name=show     attrib_value=5
    ${attrib_values}    taf_pdml_analyser.get_attrib_value_from_pdml_entries    ${pdml_entries}
    ...    field_name=nrppa.NR_TADV  attrib_name=showname
    should be equal    ${attrib_values}[0]    NR-TADV: ${value}


CheckTAValue Empty TADV
    [Arguments]    ${file_path}
    ${pdmlFile} =    Get filtered PDML file from pcap   pcapFile=${file_path}    filterExp=nrppa
    ${pdml_entries}    taf_pdml_analyser.get_pdml_entries     ${pdmlFile}
	...     field_name=nrppa.MeasuredResultsValue   attrib_name=show     attrib_value=5
    ${attrib_values}    taf_pdml_analyser.get_attrib_value_from_pdml_entries    ${pdml_entries}
    ...    field_name=nrppa.NR_TADV  attrib_name=showname
    should be empty    ${attrib_values}

CheckTAValue temporarily-not-available
    [Arguments]    ${file_path}
    ${pdmlFile} =    Get filtered PDML file from pcap   pcapFile=${file_path}    filterExp=nrppa.ProtocolIE_Field_element
    ${pdml_entries}    taf_pdml_analyser.get_pdml_entries     ${pdmlFile}
	...    field_name=nrppa.radioNetwork   attrib_name=show    attrib_value=2
    ${attrib_values}    taf_pdml_analyser.get_attrib_value_from_pdml_entries    ${pdml_entries}
    ...    field_name=nrppa.radioNetwork    attrib_name=showname
    should be equal    ${attrib_values}[0]    radioNetwork: requested-item-temporarily-not-available (2)

Create BeamForming profile attach UE and trigger low data
    Create Beamforming Profile for association of 4 Beams and activate MUE    1      6
    log to console   UE attach trigerring now...
    #Multi UE registration and no rach validation
    ${crnti_list}       Create List
    FOR      ${ue_idx}   IN RANGE    ${1} 	  ${6}+1
    ${rnti}     UE Registered Successfully & Rach validation      ue_id=${ue_idx}
    Append To List    ${crnti_list}   ${rnti}
    END
    set suite variable    ${crnti_list}
    Sleep    5s
    MultiUE Trigger DL Traffic for SA    1   6    Traffic_rate=kbps     dl_rate=10          trf_id=${TRF_ID}    qfi_id=${QFI_ID}
    MultiUE Trigger UL Traffic for SA    1   6    Traffic_rate=kbps     ul_rate=10          trf_id=${TRF_ID}    qfi_id=${QFI_ID}
    sleep   5s    reason=Wait for successful BWP switch
    ${bwpid}    Create List     3    3    3    3    3    3
    Run keyword and continue on failure    Capture TTI Traces and Validate UE bwpid    ${LOG_PATH}    lowdata    ${crnti_list}
    ...     ${bwpid}    ${Branch_22R1}

Trigger Beam recovery and verify PSBWP through TTI trace
    log to console    Trigger beam recovery...
    FOR	    ${ue_idx}   IN RANGE    ${start_ue_id} 	  ${end_ue_id}+1
    Beamcontrol Beam Recovery      ue_id=${ue_idx}    beam_profile_id=2    best_beam=2
    sleep      5s
    Check Rach msg
    END
    ${bwpid}    Create List     3    3    3    3    3    3
    Run keyword and continue on failure     Capture TTI Traces and Validate UE bwpid    ${LOG_PATH}    beamrecovery    ${crnti_list}
	...     ${bwpid}    ${Branch_22R1}
	Validate UE beamid from TTI traces    ${LOG_PATH}/ttitrace_streaming/beamrecovery     ${crnti_list}    ${2}
    Run keyword and ignore error    Validate DL Traffic For MultiUE for SA    1   6     dl_rate=0.010
    Run keyword and ignore error    Validate UL Traffic For MultiUE for SA    1   6     ul_rate=0.010

Increase traffic on UE and validate switching to LargeBWP and data traffic
    MultiUE Trigger DL Traffic for SA    1   6    Traffic_rate=mbps     dl_rate=100          trf_id=${TRF_ID}    qfi_id=${QFI_ID}
    MultiUE Trigger UL Traffic for SA    1   6    Traffic_rate=mbps     ul_rate=100          trf_id=${TRF_ID}    qfi_id=${QFI_ID}
    sleep      10s
    ${bwpid}    Create List     1      1      1      1      1      1
    Capture TTI Traces and Validate UE bwpid    ${LOG_PATH}    largeBWP    ${crnti_list}
	...     ${bwpid}    ${Branch_22R1}
    Run keyword and continue on failure     Validate DL Traffic For MultiUE for SA    1   6     dl_rate=100
    Run keyword and continue on failure     Validate UL Traffic For MultiUE for SA    1   6     ul_rate=75
