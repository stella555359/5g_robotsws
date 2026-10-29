*** Settings ***
Documentation
...		[Authors]     		        	"uthika kaul"
...		[Date] 			            "29-04-2025"
...		[Feature_ID] 		        	"CB013487"



Library     ta_emss
Library     BuiltIn
Library     taf.ul.ue.sim.env_setup
Library     ta_uexgate
Library     Process
Library     Collections
Library     OperatingSystem
Library     taf.sw.syslog
Library     ta_messaging



*** Keywords ***
Setup testline
	add_enb_configuration    scfc=${scfc}  rad_params=@{SWCONFIG_FLAGS}
	add_simulator            sim_type=cus   config=${cus_ini}
	add_epc                  config=${lua}
	configure_environment


Trigger UE_${ue_id} to send A2 event with RSRP lower than threshold2InterFreq
    Expect message flow
    ...                         UE_${ue_id}:RRC_RRCConnectionReconfiguration
    ...                         UE_${ue_id}:RRC_RRCConnectionReconfigurationComplete
    ...                         alias=UE_send_A2_meas_lower_than_threshold2InterFreq    overall_timeout=15
    Run UEx command  ue_measurement_send id=${ue_id}   event=A2    srsrp=35    srsrq=9
    sleep  2
    flow occurred as expected   UE_send_A2_meas_lower_than_threshold2InterFreq


Trigger UE_${ue_id} to send A2 event with RSRP greater than threshold2InterFreq
    Expect message flow
    ...                         UE_${ue_id}:RRC_RRCConnectionReconfiguration
    ...                         UE_${ue_id}:RRC_RRCConnectionReconfigurationComplete
    ...                         alias=UE_send_A2_meas_greater_than_threshold2InterFreq    overall_timeout=15
    Run UEx command  ue_measurement_send id=${ue_id} meas_id=5 srsrp=65
    sleep  2
    flow occurred as expected   UE_send_A2_meas_greater_than_threshold2InterFreq

Trigger ttiBundling activation for UE_${ue_id}
    Sleep   2s
    Run UEx command  ue_ul_power_control id=${ue_id}    pathloss=123   cell=both
    Sleep   0.1s
    Run UEx command  ue_harq_error id=${ue_id}   ul_err_ratio=0..7:1000:200:0   cell=both
    Sleep   20s

Trigger ttiBundling deactivation for UE_${ue_id}
    Run UEx command  ue_ul_power_control id=${ue_id}    pathloss=60    cell=both
    sleep  2

Apply Delta Commission
    [Arguments]  ${COMMISSIONING_FILE}
    Log to console    Delta commit: ${COMMISSIONING_FILE}
    configure     ${COMMISSIONING_FILE}
    Log to console    End of Commit: ${COMMISSIONING_FILE}
    Sleep   20s    'wait cell block unblock is finished'



Check TtiBundling PM Counters
    Wait For Pm File
    Verify Value Of Counter  object_name=LNCEL-1  counter_id=M8011C62  value=[1,4]
    Verify Value Of Counter  object_name=LNCEL-1  counter_id=M8011C63  value=[20,100000]
    Verify Value Of Counter  object_name=LNCEL-1  counter_id=M8011C64  value=1
    Verify Value Of Counter  object_name=LNCEL-1  counter_id=M8011C65  value=1
    Verify Value Of Counter  object_name=LNCEL-1  counter_id=M8011C66  value=1
    Verify Value Of Counter  object_name=LNCEL-1  counter_id=M8011C209  value=3
    Verify Value Of Counter  object_name=LNCEL-1  counter_id=M8011C210  value=3
    Verify Value Of Counter  object_name=LNCEL-1  counter_id=M8011C211  value=3
    Verify Value Of Counter  object_name=LNCEL-1  counter_id=M8011C212  value=3

Start observing for S1 bearer QCI${qci_id} addition message on UE${ue_id}
    Log To Console  Start observing for S1 bearer QCI${qci_id} addition message on UE${ue_id}
    Expect message flow
    ...    MME_1:S1AP_E-RABSetupRequest (E-RABToBeSetupItemBearerSUReq contains (qCI eq ${qci_id}))
    ...    MME_1:S1AP_E-RABSetupResponse
    ...    alias=S1_bearer_with_QCI${qci_id}_addition   overall_timeout=30

Start observing for RRC bearer QCI${qci_id} addition message on UE${ue_id}
    Log To Console  Start observing for RRC bearer QCI${qci_id} addition message on UE${ue_id}
    Expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (drb-ToAddModList is present)
    ...    alias=RRC_bearer_with_QCI${qci_id}_addition   overall_timeout=30

Verify if S1 bearer QCI${qci_id} addition succeded
    Log To Console  Verify if S1 bearer QCI${qci_id} addition succeded
    Flow occurred as expected    S1_bearer_with_QCI${qci_id}_addition

Verify if RRC bearer QCI${qci_id} addition succeded
    Log To Console  Verify if RRC bearer QCI${qci_id} addition succeded
    Flow occurred as expected    RRC_bearer_with_QCI${qci_id}_addition

Create aliases
    Create UE alias       alias=UE_1      ue_id=1      id_type=cus
    Create UE alias       alias=UE_2      ue_id=2      id_type=cus
    Create UE alias       alias=UE_3      ue_id=3      id_type=cus
    Create UE alias       alias=UE_4      ue_id=4      id_type=cus
    Create UE alias       alias=UE_5      ue_id=5      id_type=cus
    Create UE alias       alias=UE_6      ue_id=6      id_type=cus
    Create MME alias      alias=MME_1    mme_id=1      id_type=wts



Expected Maximum ${dir} Throughput ${throughput} For UE${ue_id} Should Be Reached
    ${ue_stats}=  Run UEx command  get_ue_stats  id=${ue_id}  type=${dir}_rlc  unit=kbps
    ${tputs_ue}=  Get From Dictionary   ${ue_stats}  UE
    ${tputs_overall}=  Get From Dictionary   ${tputs_ue}  Overall
    ${tput_max}=  Get From Dictionary  ${tputs_overall}  max
    Should Be True  ${tput_max} >= ${throughput}
    Log to console  ${tput_max}

Start Collecting TTI Traces
    [Arguments]    ${cell_id}  ${TTITRACE_OUTPUT_DIR}=${OUTPUT_DIR}
    ${tti_trace_cores}=     Choose Cores For Tti Trace Gathering For Both Directions
    ...    cell_number=${cell_id}
    ${tti_trace_object}=    Start Collecting Tti Trace    tti_trace_duration=${10}
    ...    tti_trace_cores=${tti_trace_cores}    tti_tracer_files_dir=${TTITRACE_OUTPUT_DIR}
    [Return]     ${tti_trace_object}

stop ttitrace
    [Arguments]    ${alias}=example_04
    @{dat_file}=    ta_ttitrace.stop tti stream    alias=${alias}
    : FOR    ${item}    IN    @{dat_file}
    \    ta_ttitrace.convert dat to txt    dat_file=${item}      alias=${alias}
    ta_ttitrace.teardown ttitrace    alias=${alias}


Configure CATM for UE
    [Arguments]    ${ue_id}   ${band}
    Run UEx command    cmd=ue_param id=${ue_id} release=14 category=10 category_dl=-1
    ...    category_ul=-1 supported_bands=${band}  ca_supported_bands=${band}:a:a
    sleep  1s




