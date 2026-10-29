*** Settings ***

Documentation
...		[Authors]     		        	"uthika kaul"
...		[Date] 			            "29-04-2025"
...		[Feature_ID] 		        	"CB013487"

Force Tags    CUS    SBTS00    4G_FDD    CLOUD_R4LAPO_CUS   CA_VRF_RRM    CRT    QC_183093
Resource    ./resources/CB008966_keywords.robot



Suite Setup           Setup testline for Slim Carrier

Library     ta_uexgate
Library     taf.ul.ue.sim.env_setup
Library     BuiltIn
Library     Collections
Library     DateTime
Library     FtpLibrary
Library     OperatingSystem
Library     Process
Library     String

Library  taf.sw.scout    WITH NAME    scout

*** Variables ***
${scfc}         CB008966_5MHz_B5.xml
${lua}          ${CURDIR}${/}config${/}epc_5Mhz.lua
${cus_ini}      ${CURDIR}${/}config${/}cus_5Mhz_FXEB.ini
${ue_db}        ${CURDIR}${/}config${/}ue_5Mhz.db
${ue_id}        1
${cell_id}      1
${ue_id_2}      2
${cell_id_2}      2
${WRITE_PM_COUNTERS_EVERY_MINUTE} =    0x9D0000=15
@{SWCONFIG_FLAGS}=    ${WRITE_PM_COUNTERS_EVERY_MINUTE}
${ue_eutra_capabilities_R14}     DA20009D0008206102860E2048A163069022489942A58B983268D9D3
...    CB5F9D3A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A000
...    00001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000
...    000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E8000000
...    07400000003A00000001D000000029834622800801C364000000017BA000000080952A0225040000028A2
...    1090002AE021C85350ED555555555555550A5C200040004000
${COMMISSIONING_DELTA_CB008966_Activation}=   Delta_Activate_CB008966.json
${COMMISSIONING_DELTA_CB008966_Activation_prach3}=  Delta_prachconfig3.json
${TTIBoffset_for_prach}=    0     # Table1 of CB008966-SR-S-B1_US2


*** Test Cases ***

CB008966-SR-A-B1_US15_CB008966_5MHz_Feature_Activation
    Create aliases
    taf.sw.syslog.teardown_all_aliases_for_syslog
    taf.sw.syslog.Start Syslog    log_dir=/tmp    log_name=feat_act.log    alias=feat_act
	...    ip=192.168.255.126    ports=51000

    Run UEx Command   ue_param   id=1  release=15   category=5   rohc=24:udp,ip,rtp
	...    supported_bands=3,4,11,64
	...    extended_supported_bands=11:66,64:72
    ...    fgi=2,3,4,5,7,8,9,10,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,28
    ...    fgi_r9=2,3,4,5,7,8,9,10,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,28

    Run UEx Command   ue_param   id=2..4   release=10   category=4   rohc=24:udp,ip,rtp
	...    supported_bands=3,4,11,64    extended_supported_bands=11:66,64:72
    ...    fgi=2,3,4,5,7,8,9,10,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,28
    ...    fgi_r9=2,3,4,5,7,8,9,10,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,28

	Run UEx command   ue_attach  id=1  cell=1
    Run UEx command   ue_attach  id=2..4  cell=1

    Run UEx command   bearer_add   ue=1  qci=65  mbr_ul=64  mbr_dl=64  gbr_ul=64  gbr_dl=64
    Run UEx command   bearer_add   ue=2..4  qci=1  mbr_ul=31  mbr_dl=31  gbr_ul=31  gbr_dl=31
    sleep  2
    Run UEx Command   trf_data_start   ue=1   dir=dl   rate=20   protocol=udp   qci=65   kbps=64   stats=true
    Run UEx Command   trf_data_start   ue=1   dir=ul   rate=20   protocol=udp   qci=65   kbps=64   stats=true

    Run UEx Command   trf_data_start   ue=2..4   dir=dl   rate=20   protocol=udp   qci=1   kbps=31   stats=true
    Run UEx Command   trf_data_start   ue=2..4   dir=ul   rate=20   protocol=udp   qci=1   kbps=31   stats=true
    Run UEx command     ue_ul_power_control    id=1    pathloss=126  cell=both
    sleep  0.1
    Run UEx command  ue_harq_error id=1   ul_err_ratio=0..7:1000:250:0   cell=both
    sleep  0.1
	Run UEx command     ue_ul_power_control    id=2    pathloss=126  cell=both
    sleep  0.1
    Run UEx command  ue_harq_error id=2   ul_err_ratio=0..7:1000:250:0   cell=both
    sleep  0.1
	Run UEx command     ue_ul_power_control    id=3    pathloss=126  cell=both
    sleep  0.1
    Run UEx command  ue_harq_error id=3   ul_err_ratio=0..7:1000:250:0   cell=both
    sleep  0.1
	Run UEx command     ue_ul_power_control    id=4    pathloss=126  cell=both
    sleep  0.1
    Run UEx command  ue_harq_error id=4   ul_err_ratio=0..7:1000:250:0   cell=both
    sleep  30s
    Run UEx command   ue_detach  all    rate=10
    [Teardown]     Post condition



*** Keywords ***
Verify TTIB Offset for M Region UE
    [Arguments]    ${tti_trace_content}    ${CRNTI}
    @{columns}=    Create List
    ${header_line}=    Set Variable    0
    Append To List    ${columns}    Time    ETtiTraceUlParCell_sfn    ETtiTraceUlParCell_esfn
	...    ETtiTraceUlParUe_Modulation    ETtiTraceUlParUe_firstAllocPrb
    ...    ETtiTraceUlParCell_firstPrachPrb    ETtiTraceUlParUe_cRnti    ETtiTraceUlParUe_bundleInd
    ${tti_trace_content}=    Get File Lines From Tti Trace Txt File    tti_txt_dirpath=${OUTPUT_DIR}
    ... /tti_traces/tc1_entrance    tti_trace_direction=uplink
    ${tti_trace_ue_crnti}=    Filter Tti Trace By Value In Given Column
    ...                                            tti_file_lines=${tti_trace_content}
    ...                                            column_name=ETtiTraceUlParUe_cRnti
    ...                                            value=${CRNTI}
    ${tti_trace_ttimod}=    Filter Tti Trace By Value In Given Column
    ...                                            tti_file_lines=${tti_trace_ue_crnti}
    ...                                            column_name=ETtiTraceUlParUe_Modulation
    ...                                            value=QPSK
    ${check_prb_range}=    Get Values From Columns In Tti    tti_file_lines=${tti_trace_ttimod}
    ...   names_of_colums=@{columns}
    Remove From List     ${check_prb_range}   ${header_line}
    ${counter}=    Set Variable    0
    FOR    ${element}    IN    @{check_prb_range}
       ${counter}=    Set Variable    ${counter}
       ${counter2}=     Evaluate    ${counter}+1
       ${counter}=      Set Variable  ${counter2}
    END
    ${tti_trace_ttibund}=    Filter Tti Trace By Value In Given Column
    ...                                            tti_file_lines=${tti_trace_ttimod}
    ...                                            column_name=ETtiTraceUlParUe_bundleInd
    ...                                            value=0
    ${Check_TTIBoffset}=    Get Values From Columns In Tti    tti_file_lines=${tti_trace_ttibund}   names_of_colums=@{columns}
    Remove From List     ${Check_TTIBoffset}   ${header_line}


First TTIB is excluded
    [Arguments]    ${element}    ${counter}
        Should Be True      ${element [4]} >= 4 or ${element [4]} <=9
    [Return]    ${counter}

Verify Prb Range for M Region UE
    [Arguments]    ${element}
        Should Be True      ${element [4]} == 10 or ${element [4]} == 11 or ${element [4]} == 12

Verify TTIB Offset for U Region UE
    [Arguments]    ${tti_trace_content}    ${CRNTI}
    @{columns}=    Create List
    ${header_line}=    Set Variable    0
    Append To List    ${columns}    Time    ETtiTraceUlParCell_sfn    ETtiTraceUlParCell_esfn
    ...    ETtiTraceUlParUe_Modulation    ETtiTraceUlParUe_firstAllocPrb
    ...    ETtiTraceUlParCell_firstPrachPrb    ETtiTraceUlParUe_cRnti    ETtiTraceUlParUe_bundleInd
    ${tti_trace_content}=    Get File Lines From Tti Trace Txt File    tti_txt_dirpath=${OUTPUT_DIR}
    ...    /tti_traces/tc1_entrance    tti_trace_direction=uplink
    ${tti_trace_ue_crnti}=    Filter Tti Trace By Value In Given Column
    ...                                            tti_file_lines=${tti_trace_content}
    ...                                            column_name=ETtiTraceUlParUe_cRnti
    ...                                            value=${CRNTI}
    ${tti_trace_ttimod}=    Filter Tti Trace By Value In Given Column
    ...                                            tti_file_lines=${tti_trace_ue_crnti}
    ...                                            column_name=ETtiTraceUlParUe_Modulation
    ...                                            value=QPSK
    ${check_prb_range}=    Get Values From Columns In Tti    tti_file_lines=${tti_trace_ttimod}
    ...    names_of_colums=@{columns}
    Remove From List     ${check_prb_range}   ${header_line}
    ${counter}=    Set Variable    0
    FOR    ${element}    IN    @{check_prb_range}
       ${counter}=    Set Variable    ${counter}
       ${counter2}=     Evaluate    ${counter}+1
       ${counter}=      Set Variable  ${counter2}
    END
    ${tti_trace_ttibund}=    Filter Tti Trace By Value In Given Column
    ...                                            tti_file_lines=${tti_trace_ttimod}
    ...                                            column_name=ETtiTraceUlParUe_bundleInd
    ...                                            value=0
    ${Check_TTIBoffset}=    Get Values From Columns In Tti    tti_file_lines=${tti_trace_ttibund}
	...    names_of_colums=@{columns}
    Remove From List     ${Check_TTIBoffset}   ${header_line}


Verify Prb Range for U Region UE
    [Arguments]    ${element}
        Should Be True      ${element [4]} == 19 or ${element [4]} == 20


Verify TTIB Offset for P Region UE
    [Arguments]    ${tti_trace_content}    ${CRNTI}
    @{columns}=    Create List
    ${header_line}=    Set Variable    0
    Append To List    ${columns}    Time    ETtiTraceUlParCell_sfn    ETtiTraceUlParCell_esfn
	...    ETtiTraceUlParUe_Modulation    ETtiTraceUlParUe_firstAllocPrb
    ...    ETtiTraceUlParCell_firstPrachPrb    ETtiTraceUlParUe_cRnti    ETtiTraceUlParUe_bundleInd
    ${tti_trace_content}=    Get File Lines From Tti Trace Txt File    tti_txt_dirpath=${OUTPUT_DIR}
    ... /tti_traces/tc1_entrance    tti_trace_direction=uplink
    ${tti_trace_ue_crnti}=    Filter Tti Trace By Value In Given Column
    ...                                            tti_file_lines=${tti_trace_content}
    ...                                            column_name=ETtiTraceUlParUe_cRnti
    ...                                            value=${CRNTI}
    ${tti_trace_ttimod}=    Filter Tti Trace By Value In Given Column
    ...                                            tti_file_lines=${tti_trace_ue_crnti}
    ...                                            column_name=ETtiTraceUlParUe_Modulation
    ...                                            value=QPSK
    ${check_prb_range}=    Get Values From Columns In Tti    tti_file_lines=${tti_trace_ttimod}
	...    names_of_colums=@{columns}
    Remove From List     ${check_prb_range}   ${header_line}


Check TTIBoffset
    [Arguments]   ${sfn}    ${esfn}
    ${value_1}=    Evaluate    (${sfn}*10 )+${esfn}
    ${value_2}=    Evaluate    (${value_1})%4
    Should Be True    ${value_2} == ${TTIBoffset_for_prach}

Check TTIBoffset is not of P_region
    [Arguments]   ${sfn}    ${esfn}
    ${value_1}=    Evaluate    (${sfn}*10 )+${esfn}
    ${value_2}=    Evaluate    (${value_1})%4
    Should Be True    ${value_2} != ${TTIBoffset_for_prach}

Verify UE is in M Region in syslog
    taf.sw.syslog.message_should_exist_in_syslog_file     regexp=.*region=1        alias=feat_act


Verify UE is in U Region in syslog
     taf.sw.syslog.message_should_exist_in_syslog_file     regexp=.*region=2        alias=feat_act

Verify UE is in P Region in syslog
   taf.sw.syslog.message_should_exist_in_syslog_file     regexp=.*region=3        alias=feat_act
   taf.sw.syslog.Collect Syslog Results   destination=${OUTPUTDIR}${/}feat_act.log    unzip=True
   ...    alias=feat_act


Start Collect Tti Trace
  [Arguments]    ${cell_number}    ${tti_trace_duration}    ${tti_tracer_files_dir}
  ${tti_trace_cores}=    Choose Cores For Tti Trace Gathering For Both Directions
  ...    cell_number=${cell_number}
  ${tti_trace_instance}=    Start Collecting Tti Trace Using Tti Trace Server
  ...    tti_trace_duration=${tti_trace_duration}    tti_trace_cores=${tti_trace_cores}
  ...    tti_tracer_files_dir=${tti_tracer_files_dir}
  [Return]    ${tti_trace_instance}




Setup testline for Slim Carrier
    Setup Emss
    ${run_update}    get variable value      ${configure}        "True"
    Run keyword if  ${run_update}=="True"
    ...   Setup environment for Slim Carrier
    taf.sw.syslog.teardown_all_aliases_for_syslog

Setup environment for Slim Carrier
	add_enb_configuration    scfc=${scfc}  rad_params=@{SWCONFIG_FLAGS}
	add_simulator            sim_type=cus   config=${cus_ini}
	add_epc                  config=${lua}
    Configure environment    validate_sim=false
    taf.sw.syslog.teardown_all_aliases_for_syslog

Post condition
    Get Hostname
    Link SCOUT SCF to Configuration ID for Reporting


Get Hostname
    ${rc}  ${hostname_tmp}=  Run And Return Rc And Output  hostname
    ${hostname_tmp}=  Replace String  ${hostname_tmp}  -  _
    ${hostname_tmp}=  Convert To String  ${hostname_tmp}
    ${hostname_part}=  Split String  ${hostname_tmp}  _
    ${hostname_combined}=  Catenate  ${hostname_part[0]}_${hostname_part[1]}_${hostname_part[2]}
    Set Test Variable  ${HOSTNAME}  ${hostname_combined}

Request Scout SCF
    [Arguments]   ${scout_testline_name}
    [Documentation]    :Author: Michele
    ...    Request Scout SCF used inside Link SCOUT SCF to Configuration ID for Reporting KW.
    scout.setup_scout  scout_testline_name=${scout_testline_name}
    ${external_scf_id}=   scout.request_scf   use_scout_internal_id=True
    scout.teardown_scout_api
    [Return]   ${external_scf_id}


Link SCOUT SCF to Configuration ID for Reporting
    [Documentation]
    ...    Associate the SCF to the Configuration ID in Reporting Portal using SCOUT.
    ...
    ...    Example:
    ...     |  Link SCOUT SCF to Configuration ID for Reporting    node_id=${0}    node_type=enb
    ...
    ...     |param node_id | (default=0) Id/Number of Node (eNB or gNB) |
    ...     |param node_type | (default=gnb) Node type; possible values: gnb or enb |

    [Arguments]    ${node_id}=${0}    ${node_type}=enb    ${tl_name_only}=${HOSTNAME}
    Log To Console    ${node_id}
    ${node_type_Name}        Run Keyword If  "${node_type}"=="gnb"   Set Variable  gNB
    ...     ELSE IF     "${node_type}"=="enb"                   Set Variable  eNB
    ...     ELSE        Fail    Wrong node_type '${node_type}'! allowed: enb|gnb


    Log To Console    ${\n}SCOUT Test Line Name: ${tl_name_only}

    ${scout_testline_name}=    Set Variable    ${tl_name_only}
    ${external_scf_id}=   Request Scout SCF   ${scout_testline_name}
    ${TC_ID}=    Set Variable    ute:id:${external_scf_id}
    Set Tags  ${TC_ID}


