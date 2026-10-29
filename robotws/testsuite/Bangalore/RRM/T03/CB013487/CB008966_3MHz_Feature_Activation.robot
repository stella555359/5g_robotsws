*** Settings ***

Documentation
...		[Authors]     		        "uthika kaul"
...		[Feature_ID] 		        "CB013487"

Force Tags    CUS    SBTS00    4G_FDD    CLOUD_R4LAPO_CUS    CRT
Resource    ./resources/CB008966_keywords.robot


Suite Setup      Setup testline


Library     ta_uexgate
Library     taf.ul.ue.sim.env_setup
Library     BuiltIn
Library     Collections
Library     DateTime
Library     FtpLibrary
Library     OperatingSystem
Library     Process
Library     String
Library     taf.sw.scout    WITH NAME    scout


*** Variables ***
${scfc}         CB008966_3MHz_B4.xml
${lua}          ${CURDIR}${/}config${/}epc.lua
${cus_ini}      ${CURDIR}${/}config${/}cus_FRAC.ini
${ue_db}        ${CURDIR}${/}config${/}ue.db
${ue_id}        1
${cell_id}      1
${ue_id_legacy}      2
${cell_id_2}      2
${WRITE_PM_COUNTERS_EVERY_MINUTE} =    0x9D0000=15
@{SWCONFIG_FLAGS}=    ${WRITE_PM_COUNTERS_EVERY_MINUTE}
${ue_eutra_capabilities_R14}     DA20009D0008206102860E2048A163069022489942A58B983268D9D3
...    CB5F9D3A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A000
...    00001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000
...    000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E8000000
...    07400000003A00000001D000000029834622800801C364000000017BA000000080952A0225040000028A2
...    1090002AE021C85350ED555555555555550A5C200040004000


*** Test Cases ***

[1][1.0] CB013487_Activation of CB013487 Cat-M1 PRACH format 3 in 3 MHz cells and with TTI bundling
    [Tags]    CUS    SBTS00    4G_FDD    CLOUD_R4LAPO_CUS    CRT    QC_183094
    taf.sw.syslog.teardown_all_aliases_for_syslog
    taf.sw.syslog.Start Syslog    log_dir=/tmp    log_name=feat_act.log    alias=feat_act
	...    ip=192.168.255.126    ports=51000
    Run UEx Command   ue_param  id=${ue_id}   release=10   category=4   rohc=24:udp,ip,rtp
...    supported_bands=3,4,11,64    extended_supported_bands=11:66,64:72
...    fgi=2,3,4,5,7,8,9,10,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,28
...    fgi_r9=2,3,4,5,7,8,9,10,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,28
    Run UEx command   ue_attach  id=${ue_id}  cell=1
    Run UEx Command   trf_data_start   ue=${ue_id}   dir=dl   protocol=udp   Mbps=20   stats=true
    Run UEx Command   ue_stats    id=1   type=dl_mac    unit=Mbps
    Run UEx command   bearer_add  ue=${ue_id}  qci=1   mbr_ul=31   mbr_dl=31   gbr_ul=31   gbr_dl=31
    Sleep   2s
    Run UEx Command   trf_data_start   ue=${ue_id}   dir=dl   protocol=udp   qci=1   kbps=20   stats=true
    Run UEx Command   trf_data_start   ue=${ue_id}   dir=ul   protocol=udp   qci=1   kbps=20   stats=true
    Sleep   2s
    Run UEx Command   ue_stats    id=${ue_id}   type=dl_mac
    Trigger ttiBundling activation for UE_1
    Trigger ttiBundling deactivation for UE_1
    taf.sw.syslog.Stop Syslog    alias=feat_act
    Run UEx command   ue_detach  id=${ue_id}
    [Teardown]     Post condition


[1][1.0] CB013487_3MHz CatM with PRACH format 3 with TTIB enabled_10ms and 20ms periodicity
    [Tags]    CUS    SBTS00    4G_FDD    CLOUD_R4LAPO_CUS    CRT    QC_183095
    taf.sw.syslog.teardown_all_aliases_for_syslog
    Run UEx Command   ue_param  id=${ue_id}   release=10   category=4   rohc=24:udp,ip,rtp
...    supported_bands=3,4,11,64    extended_supported_bands=11:66,64:72
...    fgi=2,3,4,5,7,8,9,10,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,28
...    fgi_r9=2,3,4,5,7,8,9,10,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,28
    Run UEx command   ue_attach  id=${ue_id}  cell=1
    Run UEx Command   trf_data_start   ue=${ue_id}   dir=dl   protocol=udp   Mbps=20   stats=true
    Run UEx Command   ue_stats    id=1   type=dl_mac    unit=Mbps
    Run UEx command   bearer_add  ue=${ue_id}  qci=1   mbr_ul=31   mbr_dl=31   gbr_ul=31   gbr_dl=31
    Sleep   2s
    Run UEx Command   trf_data_start   ue=${ue_id}   dir=dl   protocol=udp   qci=1   kbps=20   stats=true
    Run UEx Command   trf_data_start   ue=${ue_id}   dir=ul   protocol=udp   qci=1   kbps=20   stats=true
    Sleep   2s
    Run UEx Command   ue_stats    id=${ue_id}   type=dl_mac
    Trigger ttiBundling activation for UE_1
    Trigger ttiBundling deactivation for UE_1
    Run UEx command   ue_detach  id=${ue_id}
    [Teardown]     Post condition



*** Keywords ***

Verify TTIB Activated for UE
    Verify Syslog For At Least Given Number Of Messages     regexp=.*tbm=1
...    number_of_messages=1    alias=feat_act
...    Collect Syslog Results    destination=${OUTPUTDIR}${/}feat_act.log    unzip=True
...    alias=feat_act


Start Collect Tti Trace
  [Arguments]    ${cell_number}    ${tti_trace_duration}    ${tti_tracer_files_dir}
  ${tti_trace_cores}=    Choose Cores For Tti Trace Gathering For Both Directions    cell_number=${cell_number}
  ${tti_trace_instance}=    Start Collecting Tti Trace Using Tti Trace Server
  ...    tti_trace_duration=${tti_trace_duration}    tti_trace_cores=${tti_trace_cores} tti_tracer_files_dir=${tti_tracer_files_dir}
  [Return]    ${tti_trace_instance}


Filter Tti lines
    [Arguments]    ${tti_trace}    ${condition}
    ${subtrace}=    libraries.ta_tti_trace_analyzer.Filter trace    ${tti_trace}    ${condition}
    [Return]    ${subtrace}

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