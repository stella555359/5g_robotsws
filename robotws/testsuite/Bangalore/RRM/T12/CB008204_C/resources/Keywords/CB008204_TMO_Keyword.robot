*** Settings ***
Documentation   :copyright: Nokia
...             :author   : Amitha
...             :contact  : amitha.kadambi@nokia.com
...              The aim of the feature is to validate the counters introduced in 8204-C.
...              This File consist Keywords specific to the Feature CB008204-C

Library         DateTime
Library         XML
Library         ute_fsmaccess
Library         ta5g_pm_counters
Library         taf.sw.syslog       WITH NAME   slog
Resource        ${CURDIR}/../../../resources/Keywords/ap_Keywords.robot
Resource        ${CURDIR}/../../../resources/Keywords/generic_kw.robot
Resource        ${CURDIR}/../../../resources/Keywords/gnb_Keywords.robot
Resource        ${CURDIR}/../../../resources/Keywords/PCMD_Related_KW.robot
Resource        ${CURDIR}/../../../resources/Keywords/tsharkPcapVerifyKeywords.robot
Resource        ${CURDIR}/../../../resources/Keywords/HO_KW.robot
Resource        ${CURDIR}/../../../resources/Keywords/ute_wts_runner.robot
Resource        ${CURDIR}/../../../resources/Variables/common_variables.robot


*** Variables ***
${TOPOLOGY}                 CLOUD_5G_I_LOO_AP_LOOO
${RANSIM_GNBID}             3
${ENB_ID}                   1
${MEASUREMENT_ID}           NR MEASUREMENT IDENTITIES
${XN_HO_PATTERN_CHECK}      PATH_SWITCH_REQUEST_ACK Received
${NG_HO_PATTERN_CHECK}      OnReceiveHandoverNotify
${IRAT_HO_PATTERN_CHECK}    IRAT Handover from NR to EUTRA completed
${NSA_HO_IAFR_PATTERN_CHECK}        Sending SgNB Change Confirm
${NSA_HO_IEFR_A3_CHECK}     rrcConnectionReconfigurationComplete
${X2_LINK_PATTERN_RANSIM}   X2AP Link with GNB-3
${NSA_HO_IAFR_REVERSE}      Inter Sgnb Handover is successful
${DELTACONFIGDIR}           ${CURDIR}/../../config/scf
${APCONFIGDIR}              ${CURDIR}/../../config/ap_iphy
${VLAN_ID}                  ${tl.gnbs[0].cu.x2c.vlan_id}
${MRBTS_DISTNAME}           MRBTS-1
${VLANIF_DISTNAME}          ${MRBTS_DISTNAME}/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-1
${MODIFICATION_CHECK}       Sending SgNB Modification Confirm
${AP_CONFIG_BASIC}          ${CURDIR}/../../config/wts


*** Keywords ***
Prepare TestCase For TC Setup
    [Documentation]     Prepare for Test Case and does all pre-requisite
    ...     Creates Directory for this testcaes updated NIDD parameter using Delta file
    ...     Uses CFG file to get Site On Air
	[Arguments]		${TC_Dir}=CB008204		${Delta}=Delta_Configuration_APoABIO_8204Changes_1.json		${CFG_File}=8204_basic.cfg
	${Log_Path}    Create Log Directory     ${TC_Dir}
    Link SCOUT SCF to Configuration ID for Reporting
    Set Test Variable       ${Log_Path}
    Create Interface For Xn HO
	Create Basic Interface On UTE
    GNB Delta Commission     ${DELTACONFIGDIR}/${Delta}
    Wait Coam Site To Be Ready
    Start UTE WTS      ${CFG_File}

TearDown TC For CB008204
	[Arguments]		${PcapFile}=CB008204_C1.pcap    ${Rev_Delta}=Delta_Configuration_APoABIO_8204Changes_1_reverse.json
	Stop PCAP On WTS        ${get_Pid}
    Run         mv ${PcapFile} ${Log_Path}
    slog.Stop Syslog
    Snapshot Collection     ${Log_Path}     Snapshot_AE.zip
    Copy Files      ${WTS_WORKING_DIR}/egate_console.log      ${LOG_PATH}
    Run     zip -r ${OUTPUTDIR}/CB012464_TC1.zip ${LOG_PATH}
    GNB Delta Commission     ${DELTACONFIGDIR}/${Rev_Delta}
    Sleep   10s
    RAT Block Unblock

Get Current Time As HHMM
    [Documentation]     This keyword is used to create variable base on timein hour and min in HHMM format
    ${time}     Get Time    result_format=%H%M
    ${hh}       Get Substring       ${time}   11  13
    ${mm}       Get Substring       ${time}   14  16
    ${hhmm}     Set Variable        ${hh}${mm}
    [Return]    ${hhmm}

Check Egate Logs And Extract Timestamp
    [Documentation]    Extracting Timestamp from the EGATE Console logs.
    ${OUTPUT}    Read WTS Output Until Pattern Matches     ${Modification_check}       timeout=20
    ${OUTPUT}    Get Lines Matching Regexp    ${OUTPUT}    Sending SgNB Modification Confirm   partial_match=${TRUE}
    Log To Console    ${OUTPUT}
    Set Suite Variable      ${OP_STR}   ${OUTPUT}
    ${value_ms}      Mscalc      ${OP_STR}
    [Return]    ${value_ms}

Parameter Commissioning
    [Documentation]    Single parameter commissioning is done with this keyword.
    [Arguments]         ${parameter}        ${value}        ${dist_name}
    Perform Parameter Commissioning         parameter=${parameter}      value=${value}    dist_name=${dist_name}
    ...         operation='update'      skip_parameter_relation_errors=True     should_activate=True

Get Time
    [Documentation]    Getting time from the given method Mscalc
    [Arguments]         ${match_str}
    ${value_ms}      Mscalc      ${match_str}
    Log To Console      /nHere --${match_str}
    [Return]    ${value_ms}

Make ENDC Call
    [Documentation]    NSA Call for UE 11
    LTE Attach Should Be Successful For NSA     11
    Enb Endc Param      id=1    serving_cell_index_range_scg=5:31
    UE Attach Should Be Successful For NSA      11   1

Setup PHR Testmode
    [Documentation]    This keywords is used for setting up the PHR testmode.
    [Arguments]     ${profile_id}    ${phr_start_value}     ${phr_min_value}     ${phr_step_size}
    Phr Override Testmode Nr    profile_id=${profile_id}    phr_start=${phr_start_value}
    ...           phr_min=${phr_min_value}   phr_max=40     phr_step_size=${phr_step_size}
    ...           phr_period=1       pc_max=33       phr_mode=Fixed
    Log           PHR Test Mode Override

Activate TestMode
    [Documentation]        this keyword is used to Activate the Testmode
    [Arguments]     ${UEID}      ${Testmode_name}    ${action}    ${Profile_Id_number}    ${Scellid}
    Ue Testmode Set Nr      id=${UEID}      testmode=${Testmode_name}       action=${action}
    ...             profile_id=${Profile_Id_number}    scell=${Scellid}
    Log    TestMode ${Testmode_name} is set

Mscalc
    [Documentation]        This is calculating time from the given string.
    [Arguments]    ${op_str}
    ${s}     Evaluate    re.findall('[0-9]+', '${op_str}')    modules=re
    ${ss}    Convert To Integer    ${s}[2]
    ${s1}    Convert To Integer    ${s}[1]
    ${s2}    Convert To Integer    ${s}[0]
    ${s3}    Convert To Integer    ${s}[3]
    ${result}    Evaluate    int(${s2}) * 60 * 60000 + int(${s1}) * 60000 + int(${ss}) * 1000 + int(${s3})
    [Return]    ${result}

Calculate Time Delta
    [Documentation]     Checking Delta of the given time
    [Arguments]    ${time1}       ${time2}
    ${result}      Evaluate       ${time2} - ${time1}
    [Return]       ${result}

Calculate Sum
    [Documentation]     Adding Time and returning sum
    [Arguments]    ${time1}    ${time2}
    ${result}      Evaluate    ${time2} + ${time1}
    [Return]       ${result}

UE Detach Should Be Successful For NSA 8204
    [Documentation]    This keyword is used to Detach the UE with gNB and checks the completion message in output file.
    ...                Modified Date: 31-March-2021
    ...                Last Modified by: anil.1.pachauri@nokia.com
    [Arguments]    ${UE_ID}=${UE_ID_NSA}
    wtsrunner.Ue Detach    id=${UE_ID}
    ${OUTPUT}    Read WTS Output Until Pattern Matches    ${UE_detach_pattern}    ${Timeout_NSA}
    Print Matching Lines From Output File    ${OUTPUT}    ${UE_detach_pattern}
    Log    detach_is_ok
    Log To Console     \nDetach ----  ${match_str}
