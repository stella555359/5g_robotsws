*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LOOO  CLOUD_5G_I_LO_AP_LOOO_SANSA_FS_ECPRI_CMWV_TDD
...             SBTS00   CONFIGURED   5G_RAN   RAN_5G   RAN_5G_TDD   5G_RAN_TDD   CRT

Documentation    :copyright: Nokia
...              :authors: Bhabani
...              :contact: bhabani.sankar_rout@nokia.com
...             The feature enhances UL NR E-CID positioning method to provide the Timing advanced (Tadv) measurments to help
...             improving UE positioning accuracy, e.g. during emergency calls.
...             Tadv can be provided to LMF in addition to the SS-RSRP/RSRQ measurements introduced by CB008281 feature
...             Super cell is activated as per US CB008985-A#1: Feature activation and configuration
...             CB009842 feature is activated in the cell as per US CB009842-A#B1: CB009842 Feature Activation
...             UE has a successful SA call ongoing in one of the subcells (subcell #1) as described in US CB008985-A#5:
...             TDD FR1 SA call on supercell

...             Requirement id - 5G_RAN_USR_RRM_16771, 5G_RAN_USR_RRM_23350, 5G_RAN_USR_RRM_16872, 5G_RAN_USR_RRM_23358, 5G_RAN_USR_RRM_16871

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Library          Collections
Resource         ../CB008541/resources/CB008541_Keywords.robot
Resource         ../5GC000937/resources/5GC000937_Keywords.robot
Resource         ../../../resources/robot/common_log_collection.robot
Resource         ../CB008541/resources/CB008541_Keywords.robot
Resource         ../../../resources/robot/common_log_collection.robot

Suite Setup         Run keywords    Prepare TL with all config files
...                 AND     Run Keyword and Ignore Error      Suite setup from scratch
...                 AND     sleep    300s
...                 AND     Start WTS Using WTS_Runner     ${wts_cfg_file}
...                 AND     Check gNB Bulid

Suite Teardown    Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Run Keyword and Ignore Error    Get Snapshot
...                 AND     Run Keyword and Ignore Error    Get Sos Report
Test Teardown      Link SCOUT SCF to Configuration ID for Reporting


*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/basic_setup_robustness_100UE.cfg
&{WTS}              Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${UE_ID}            1
${nwslice_ID}     1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID}    1
${TRF_ID2}    2
${epc_log_path}    /tmp/
@{syslog_regex_bwp}     DCI11   DCI01
@{syslog_regex_csi}     CSI-RS sending   PER-CSI-PUCCH receiving
${SCFC}=           ${CURDIR}/config/SCF/supercell_scf.xml
${AP_XML}=         ${CURDIR}/config/SCF/supercell_iphy.xml

*** Test Cases ***
[1]CB009842_23_AIWK2_AEC7_Successful_ECID_Measurement_Reporting_for_NR_TADV_Measurement_Quantity_with_Super_cell
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

*** Keywords ***
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
