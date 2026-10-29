*** Settings ***
Force Tags      SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_GMC

Documentation
...
...             author           Akhil K P (Nokia) <akhil.k_p@nokia.com>
...             maintainer       Akhil K P (Nokia) <akhil.k_p@nokia.com>
...
...             INTRODUCTION     CNI-119314_TC1_Increased_FDM_UE_per_TTI_for_ASOE_10MHZ_FDD_SA
...             TEST SET NAME    CNI-119314_TC1_Increased_FDM_UE_per_TTI_for_ASOE_10MHZ_FDD_SA
...             Description        This case is to verify the DL&UL data transmission with an increased number of allocations on PDSCH and
...                                PUSCH per slot for FDD FR1 10MHz( 12 in dl and 10 in ul) on ASOE hw

...             TESTING SPLIT    NA
...             TESTING SPLIT:    See CB008225 testplan split I
...             CONTACTS         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES       https://jiradc.ext.net.nokia.com/browse/CNI-119314
...             REFERENCES:       CB008225 CFAM
...             Requirement ID   FDD_10105_#1
...             Requirement ID:  5G_RAN_USR_RRM_18316

#Suite Setup         Run keywords    Suite setup from scratch
#...                 AND     Update bsr package
#...                 AND     gnb.Perform gNB reboot
#...                 AND     sleep    30

Resource          ./resources/common/common_setup_teardown.robot
Resource          ./CB007859_Resource.robot
Library           ./resources/python/lib.py
Library           ./resources/python/read_csv.py
Library            taf.wts.runner              WITH NAME    wtsrunner
Resource          ./LN_CB008225_resource.robot

*** Variables ***
${iphy_file}               ${CURDIR}/resources/wts/new_3cell_iphy.xml
#${scf_file_path}           new_3cell_pet_config.xml
${DELTA_FILE}              119314_delta.json
@{LOG_NAME_LIST}           btslog    snapshot
${LOCAL_WTS_DIR}           ${CURDIR}/resources/wts
${WTS_CFG}                 cni119314_basic_setup_new.cfg
${WTS_AP_XML}              AirphoneConfig_multiue_tdd.xml
@{OLD_PARAS_IPHY}          <cell>2.1</cell>    <cell>2.2</cell>    <GSCN>.*</GSCN>
@{NEW_PARAS_IPHY}          <cell>2.1</cell>    <cell>2.2</cell>    <GSCN>7881</GSCN>
&{UE_INFO}                 profile_id=1    gnb_id=2    cell_id=1    bearer_id=2    dl_traffic=10M    ul_traffic=3M
${UE_NUM}                  50
${UE_NUM_DL}               30
${UE_NUM_CHANGE}            2
&{UE_INFO_DL}              profile_id=1    gnb_id=2    cell_id=1    bearer_id=2    dl_traffic=10M    ul_traffic=0
&{UE_INFO_UL}              profile_id=1    gnb_id=2    cell_id=1    bearer_id=2    dl_traffic=0      ul_traffic=3M
${wts_cfg_file}     ${CURDIR}/resources/wts/basic_setup_2CC_gASOE-apLO_tdd_emergency.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${UE_ID}        1
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}    1
#${TRF_ID}    1
${TEST_NAME}        test_case
${split}        resume
${start_ue_id}      ${1}
${end_ue_id}      ${3}
${delta}       30
${tp_duration}      40
${inactivity_timer}      100
# GFBR and MFBR profile <qos flow id>_gfbr_<dir>=speed
&{gfbr_mfbr_profile}                6_gfbr_ul=10   6_gfbr_dl=20    6_mfbr_ul=40     6_mfbr_dl=50
...                                 7_gfbr_ul=10   7_gfbr_dl=20    7_mfbr_ul=40     7_mfbr_dl=50
...                                 3_gfbr_ul=10   3_gfbr_dl=20    3_mfbr_ul=40     3_mfbr_dl=50
#Make sure VONR Traffic profile should in kbps for 5QI1 and 5QI 5 i.e QFI 2 and 3
@{QOS_Prof1}               1     #5QI 6    ARP(7)
@{QOS_Prof1_speed_dl}      10
@{QOS_Prof1_speed_ul}      1
@{QOS_Prof1_unit}          mbps

@{QOS_Prof2}               1       22            #5QI 9     ARP(9)
@{QOS_Prof2_speed_dl}      10       10
@{QOS_Prof2_speed_ul}      10       10
@{QOS_Prof2_unit}          mbps     mbps

${duration}      600
${trf_id}      ${1}
${split2}     fallback
${radparam}                SEPARATOR=${EMPTY}    0x890073 = 0

*** Test Cases ***
[1][1.0] CB008225-I_B1_1-Successful transition of suspended UE in RRC_INACTIVE state to RRC_CONNECTED with DRB preemption limit maxNumOfRrcSA TDD_LN
#
    [Tags]    TC01
	[Setup]        Run keywords     Suite setup from scratch
	...                 AND     Update bsr package
	...                 AND     Perform SCF Delta Commissioning with Delta_Config_NonRANsha_InactBased_UeLevel_UePreemption_gLN_apLO_TDD.json
    ...                 AND     sleep    180
    ...                 AND     Add RD Parameters To GNB Swconfig File      ${radparam}
    ...                 AND     gnb.Perform gNB reboot
    ...                 AND     sleep    30
    ...                 AND     Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces      ${wts_cfg_file}

    set test variable      ${LOG_PATH}
    log to console   UE attach trigerring now...
#    Modify NIDD parameters     paramName=maxNumOfRrcSA       paramValue=3       operation=update       paramDst=MRBTS-1/NRBTS-1/NRCELL-1
#    Modify NIDD parameters     paramName=actUserPreemption       paramValue=true       operation=update       paramDst=MRBTS-1/NRBTS-1
    ${qos_profile}               Create Dictionary   ${1}=${QOS_Prof1}                ${2}=${QOS_Prof2}             ${3}=${QOS_Prof1}
    ${qos_profile_speed_ul}      Create Dictionary   ${1}=${QOS_Prof1_speed_ul}       ${2}=${QOS_Prof2_speed_ul}    ${3}=${QOS_Prof1_speed_ul}
    ${qos_profile_speed_dl}      Create Dictionary   ${1}=${QOS_Prof1_speed_dl}       ${2}=${QOS_Prof2_speed_dl}    ${3}=${QOS_Prof1_speed_dl}
    ${qos_profile_unit}          Create Dictionary   ${1}=${QOS_Prof1_unit}           ${2}=${QOS_Prof2_unit}        ${3}=${QOS_Prof1_unit}
    ${cnai}                      Create Dictionary           ${1}=on                     ${2}=on                       ${3}=on
    ${state}                     Create Dictionary          ${1}=inactive               ${2}=active                   ${3}=active
    ${trigger}                   Create Dictionary             ${1}=uldata                  ${2}=uldata                    ${3}=uldata

    Start Log      btslog     cprt
    ${ue_to_bearer_list}=      MultiUE Register should be Successful with CNAI     ${start_ue_id}    ${end_ue_id}      cnai=${cnai}
    Start Data Transfer     ${start_ue_id}     ${end_ue_id}     ${duration}    both   ${trf_id}   ${qos_profile_unit}
    ...      ${qos_profile_speed_ul}     ${qos_profile_speed_dl}    ${qos_profile}
    PDU Modfication and Deletion of other PDU       2       2      1     qosflows_to_add=22       qosflows_to_del=1
    sleep   ${delta}s
    ${inactivity_start}     Stop MultiUE Data Traffic for SA with timestamp        ${start_ue_id}    ${end_ue_id}      ${qos_profile}      ${state}
    Modify NIDD parameters     paramName=maxNumOfRrcSA       paramValue=2       operation=update       paramDst=MRBTS-1/NRBTS-1/NRCELL-1
    Sleep till inactivity timer expiry
    ${full_rnti_list}      ${inactivity_stop}     Check MultiUE RRC State       ${start_ue_id}    ${end_ue_id}        state=${state}
    ${cause_list}       Trigger RRC Resume        ${start_ue_id}       ${end_ue_id}        ${state}        ${trigger}
    Start Data Transfer     1     1     ${duration}    both   ${trf_id}   ${qos_profile_unit}
    ...      ${qos_profile_speed_ul}     ${qos_profile_speed_dl}    ${qos_profile}
    ${scen1}     Stop Log      btslog     cprt

    ${inactivity_timer_cal}        Verify Inactivity Timer         ${start_ue_id}       ${end_ue_id}            ${state}
         ...      ${inactivity_start}        ${inactivity_stop}        ${delta}        ${inactivity_timer}
    Verify MultiUE Cplane messages from pcap       ${scen1}[cprt]/NODECPRT_GNB.pcap        1        1
    ...       ${qos_profile}          ${full_rnti_list}          ${state}       ${split}      ${cause_list}        activityNotify=uE
    Verify UE released due to preemption        ${scen1}[cprt]/NODECPRT_GNB.pcap          2
    MultiUE Deregister should be Successful   ${start_ue_id}    ${end_ue_id}

#CB008225-I_B7_2 - RRCResumeRequest1 for resumeCause for EM during C-Plane Overload (Success) with NRRCC_RRC_RESUME Counters TDD_ASOE
    log to console    Emergency call case
    Perform SCF Delta Commissioning with Delta_Config_NonRANsha_InactBased_UeLevel_gABIP_apLO_TDD_Emergency.json
    ${end_ue_id}     set variable          ${2}
#    Perform SCF Delta Commissioning with temp_Online_Delta_Config_NonRANsha_InactBased_UeLevel_gASOE_apLO_TDD.json
    Wait until the next Measurement Period starts  additional_time=${0}
    log to console   UE attach trigerring now...
    ${qos_profile}               Create Dictionary   ${1}=${QOS_Prof1}                ${2}=${QOS_Prof2}
    ${qos_profile_speed_ul}      Create Dictionary   ${1}=${QOS_Prof1_speed_ul}       ${2}=${QOS_Prof2_speed_ul}
    ${qos_profile_speed_dl}      Create Dictionary   ${1}=${QOS_Prof1_speed_dl}       ${2}=${QOS_Prof2_speed_dl}
    ${qos_profile_unit}          Create Dictionary   ${1}=${QOS_Prof1_unit}           ${2}=${QOS_Prof2_unit}
    ${cnai}                  Create Dictionary           ${1}=on                     ${2}=on
    ${state}                  Create Dictionary          ${1}=inactive               ${2}=inactive
    ${trigger}             Create Dictionary             ${1}=emergency                  ${2}=emergency

    Start Log      btslog     cprt
    ${ue_to_bearer_list}=      MultiUE Register should be Successful with CNAI     ${start_ue_id}    ${end_ue_id}      cnai=${cnai}
    Create Modify PDU session   ${start_ue_id}    ${end_ue_id}    ${qos_profile}   pdu_id=1
    ...     gfbr_mfbr_profile=${gfbr_mfbr_profile}                       ue_to_bearer_list=${ue_to_bearer_list[1]}
    Perform CPLANE OVL activation via R&D mechanism
    Start Data Transfer     ${start_ue_id}     ${end_ue_id}     ${duration}    both   ${trf_id}   ${qos_profile_unit}
    ...      ${qos_profile_speed_ul}     ${qos_profile_speed_dl}    ${qos_profile}
    sleep   ${delta}s
    ${inactivity_start}     Stop MultiUE Data Traffic for SA with timestamp        ${start_ue_id}    ${end_ue_id}      ${qos_profile}      ${state}
    ${tp_read}          Verify data transfer and get tp gbr_nongbr      ${start_ue_id}     ${end_ue_id}
    ...     ${delta}    both   ${trf_id}   ${qos_profile_unit}  ${qos_profile_speed_ul}
    ...     ${qos_profile_speed_dl}    ${qos_profile}
    Perform SCF Delta Commissioning with Online_Delta_Config_NonRANsha_InactBased_UeLevel_gASOE_apLO_TDD.json
    Sleep till inactivity timer expiry
    ${full_rnti_list}      ${inactivity_stop}     Check MultiUE RRC State       ${start_ue_id}    ${end_ue_id}        state=${state}
    sleep   100s
    ${cause_list}       Trigger RRC Resume        ${start_ue_id}       ${end_ue_id}        ${state}        ${trigger}
    Start Data Transfer     ${start_ue_id}     ${end_ue_id}     ${duration}    both   ${trf_id}   ${qos_profile_unit}
    ...      ${qos_profile_speed_ul}     ${qos_profile_speed_dl}    ${qos_profile}
    sleep   ${delta}s
    ${scen1}     Stop Log      btslog     cprt
    sleep   300s
#
    Get Fallback counters and validate       M55124C00007     M55124C00013      M55124C00014     M55306C06002       value_expected=2
    ${inactivity_timer_cal}        Verify Inactivity Timer         ${start_ue_id}       ${end_ue_id}            ${state}
         ...      ${inactivity_start}        ${inactivity_stop}        ${delta}        ${inactivity_timer}
    Verify MultiUE Cplane messages from pcap       ${scen1}[cprt]/NODECPRT_GNB.pcap       ${start_ue_id}      ${end_ue_id}
    ...       ${qos_profile}          ${full_rnti_list}          ${state}       ${split2}      ${cause_list}        activityNotify=uE
    Verify UE Successful ICS due to fallback cause emergency       ${scen1}[cprt]/NODECPRT_GNB.pcap         ${4}

    [Teardown]      Run Keywords   Log To console  TCTeardown
    ...             AND     Run Keyword and Ignore Error    Link SCOUT SCF to Configuration ID for Reporting

CNI-119314_TC1_Increased_FDM_UE_per_TTI_for_ASOE_10MHZ_FDD_SA
    [Tags]    TC02
	[Setup]        Run keywords     Convert TL Mode And Suite Setup Tdd_5
    ...               AND           Common New Test Setup

    Backup Scf    ${OUTPUT_DIR}    before_suite
    SA MultiUE Attach And Do UL Traffic on SANSA   max_ue_num=${UE_NUM}
    wait for previous action to stabilise ${650}s
    Verify fdm max ul Counters   10
    Detach multiple SA UEs      max_ue_num=${UE_NUM}
    sleep    60s
    SA MultiUE Attach And Do DL Traffic on SANSA   max_ue_num=${UE_NUM_DL}
    wait for previous action to stabilise ${650}s
    Verify fdm max dl Counters   12
    Detach multiple SA UEs      max_ue_num=${UE_NUM_DL}
    sleep     10s
    SA MultiUE Attach And Do Traffic on SANSA     max_ue_num=${UE_NUM}
    wait for previous action to stabilise ${350}s
    Verify fdm max dl Counters   12
    Verify fdm max ul Counters   10

    [Teardown]      Run Keywords
    ...             Common New Test Teardown
    ...             AND     Sleep   1s
#    ...             AND     Kill WTS processes Using WTS_Runner
    ...             AND     Run Keyword and Ignore Error    Link SCOUT SCF to Configuration ID for Reporting


*** Keywords ***
Start And Stop Tti Trace Streaming new
    [Arguments]         ${path}
    Start Ttitrace With Streaming Mode
    Sleep    1s    reason=get *L2TtiTrace_EventsSnapshot
    Stop Ttitrace
    Convert Ttitrace From Pcap To Excelcsv        ${path}
Detach NSA UEs
    [Arguments]    ${start_ue}      ${end_ue}
    FOR    ${ue_id}    IN RANGE    ${start_ue}    ${end_ue}+1
    NSA LTE Detach      ${ue_id}
    END

wait for counter update ${sleep}s
    sleep       ${sleep}s

NSA MultiUE Attach And send Traffic on SANSA
    [Arguments]    ${max_ue_num}    ${ue_info}
    [Documentation]    This keyword is to do NSA multi UE attach and do DL/UL traffic
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${max_ue_num} | Yes | the number of multi UE |
    ...    | ${ue_info} | Yes | the directory for setting UE info. |
    ...
    ...    Examples:
    ...    1. both UL and DL --- kbps
    ...    | ${max_ue_num} | set variable | 5 |
    ...    | &{ue_info} | Create Dictionary | profile_id=1 | gnb_id=2 | cell_id=1 | bearer_id=2 | dl_traffic=100M | ul_traffic=10m |
    ...    | NSA MultiUE Attach And Do Traffic | ${max_ue_num} | ${ue_info} |
    ...
    ...    2. both UL and DL --- mbps
    ...    | ${max_ue_num} | set variable | 5 |
    ...    | &{ue_info} | \ Create Dictionary | profile_id=1 | gnb_id=2 | cell_id=1 | bearer_id=2 | dl_traffic=100k | ul_traffic=10k |
    ...    | NSA MultiUE Attach And Do Traffic | ${max_ue_num} | ${ue_info} |
    ...
    ...    3. only UL or DL
    ...    | ${max_ue_num} | set variable | 5 |
    ...    | &{ue_info} | Create Dictionary | profile_id=1 | gnb_id=2 | cell_id=1 | bearer_id=2 | dl_traffic=0 | ul_traffic=10k |
    ...    | NSA MultiUE Attach And Do Traffic | ${max_ue_num} | ${ue_info} |
    ...    or
    ...    | ${max_ue_num} | set variable | 5 |
    ...    | &{ue_info} | Create Dictionary | \ profile_id=1 | gnb_id=2 | cell_id=1 | bearer_id=2 | dl_traffic=10m | ul_traffic=0 |
    ...    | NSA MultiUE Attach And Do Traffic | ${max_ue_num} | ${ue_info} |
    ${ul_traffic_type}    Run Keyword If    '${ue_info.ul_traffic}'!='0'    Evaluate    '${ue_info.ul_traffic}'[-1]
    ${dl_traffic_type}    Run Keyword If    '${ue_info.dl_traffic}'!='0'    Evaluate    '${ue_info.dl_traffic}'[-1]
    ${dl_type}    Run Keyword If    '${dl_traffic_type}'!='None'    String.Convert To Lowercase    ${dl_traffic_type}
    ${ul_type}    Run Keyword If    '${ul_traffic_type}'!='None'    String.Convert To Lowercase    ${ul_traffic_type}
    ${ul_traffic_value}    Run Keyword If    '${ul_type}'!='None'    Evaluate    '${ue_info.ul_traffic}'[0:-1]
    ${dl_traffic_value}    Run Keyword If    '${dl_type}'!='None'    Evaluate    '${ue_info.dl_traffic}'[0:-1]
    FOR    ${ue_id}    IN RANGE    21    ${max_ue_num}+21
    NSA LTE Attach    ${ue_id}    ${ue_info.profile_id}
    NSA 5G Attach    ${ue_id}    ${ue_info.gnb_id}    ${ue_info.cell_id}    ${ue_info.bearer_id}
#    NSA Verify If Attach Passed
    Run Keyword If    '${ul_type}'=='m'    NSA Start UL Traffic    ${ue_id}    ${ue_info.bearer_id}    ${ul_traffic_value}
    ...    ELSE IF    '${ul_type}'=='k'    NSA Start UL Small Traffic    ${ue_id}    ${ue_info.bearer_id}    ${ul_traffic_value}
    Run Keyword If    '${dl_type}'=='m'    NSA Start DL Traffic    ${ue_id}    ${ue_info.bearer_id}    ${dl_traffic_value}
    ...    ELSE IF    '${dl_type}'=='k'    NSA Start DL Small Traffic    ${ue_id}    ${ue_info.bearer_id}    ${dl_traffic_value}
    END

Verify fdm max dl Counters
     [Arguments]    ${dl_expected}
     [Documentation]    This keyword is to verify the FDM dl counter
     ${counter_dl}           Get Counter Value With Admin          M55308C17002
     Should Be True      ${counter_dl}==${dl_expected}

Verify fdm max ul Counters
     [Arguments]    ${ul_expected}
     [Documentation]    This keyword is to verify the FDM ul counter
     ${counter_ul}           Get Counter Value With Admin          M55308C18002
     Should Be True      ${counter_ul}==${ul_expected}

Check UL rnti per slot
    [Arguments]    ${path}  ${expected_ul}
    ${x}=    check_num_of_rnti_per_slot    ul    ${expected_ul}    ${path}/output_ul_formated.csv
    Should Contain    ${x}    Pass
#    ${y}=    check_num_of_rnti_per_slot    dl    ${expected_dl}    ${path}/output_dl_formated.csv
#    Should Contain    ${y}    Pass

Check DL rnti per slot
    [Arguments]    ${path}  ${expected_dl}

    ${y}=    check_num_of_rnti_per_slot    dl    ${expected_dl}    ${path}/output_dl_formated.csv
    Should Contain    ${y}    Pass

SA MultiUE Attach And Do UL Traffic on SANSA
    [Arguments]    ${max_ue_num}
    FOR    ${ue_id}    IN RANGE    1    ${max_ue_num}+1
    Wait Until Keyword Succeeds    2x   5sec    SA 5G Attach        ${ue_id}
    ute_wtssim.Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    SA 5G PDU Session Setup multiue       ${ue_id}
#    Start DL Traffic        ${ue_id}   ${dl_tput}
    Start UL Traffic        ${ue_id}
#    SA Start UL Traffic Internal     ${ue_id}     1     50
    Display average DL and UL data        ${ue_id}
    END

SA MultiUE Attach And Do DL Traffic on SANSA
    [Arguments]    ${max_ue_num}
    FOR    ${ue_id}    IN RANGE    1    ${max_ue_num}+1
    Wait Until Keyword Succeeds    2x   5sec    SA 5G Attach        ${ue_id}
    ute_wtssim.Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    SA 5G PDU Session Setup multiue       ${ue_id}
    Start DL Traffic        ${ue_id}
#    SA Start DL Traffic Internal     ${ue_id}     1     70
#    Start UL Traffic        ${ue_id}   ${ul_tput}
    Display average DL and UL data        ${ue_id}
    END

SA MultiUE Attach And Do Traffic on SANSA
    [Arguments]    ${max_ue_num}
    FOR    ${ue_id}    IN RANGE    1    ${max_ue_num}+1
    Wait Until Keyword Succeeds    2x   5sec    SA 5G Attach        ${ue_id}
    ute_wtssim.Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    SA 5G PDU Session Setup multiue       ${ue_id}
    Start DL Traffic        ${ue_id}
    Start UL Traffic        ${ue_id}
    Display average DL and UL data        ${ue_id}
    END

Start DL Traffic
    [Arguments]    ${ue_id}
    ${output}         ute_wtssim.Execute Egate Command and Wait for Data
    ...               trf_data_start ue\=${ue_id} pdu\=1 qfi\=1 dir\=dl period_ms\=4 burst\=8 size\=50
    ...               pass_regexp=TRF:
    ${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
    Log to Console    ${output}

Start UL Traffic
    [Arguments]    ${ue_id}
    ${output}         ute_wtssim.Execute Egate Command and Wait for Data
    ...               trf_data_start ue\=${ue_id} pdu\=1 qfi\=1 dir\=ul period_ms\=4 burst\=8 size\=50
    ...               pass_regexp=TRF:
#    ${output}         ute_wtssim.Execute Egate Command and Wait for Data
#    ...               trf_data_start ue\=${ue_id} pdu\=1 dir\=ul trf_id\=1 kbps\=${ul_tput}
#    ...               pass_regexp=TRF:
    ${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
    Log to Console    ${output}

PDU Modfication and Deletion of other PDU
     [Arguments]          ${start_ue_id}     ${end_ue_id}      ${pdu_id}     ${qosflows_to_add}     ${qosflows_to_del}
     FOR	    ${ue_idx}   IN RANGE    ${start_ue_id}	  ${end_ue_id}+1
     wtsrunner.ue_pdu_session_modify      ue=${ue_idx}       pdu=${pdu_id}    qosflows_to_add=${qosflows_to_add}
     ...           qosflows_to_del=${qosflows_to_del}       by=amf
     ${output}    Read WTS Output Until Pattern Matches    .*Added QosFlow with QFI:2 fiveQI:9*.     ${Timeout_SA}
     Print Matching Lines from Output File    ${output}    .*Deleting QosFlow with QFI:1 5QI:6*.
     Print Matching Lines from Output File    ${output}    .*Added QosFlow with QFI:2 fiveQI:9*.
     Log to Console  ${Pdu_session_mod_patten}
     wtsrunner.trf_data_start     ue=${ue_idx}     pdu=${pdu_id}   qfi=2    dir=dl    trf_id=1     mbps=10
     ${output1}   Read WTS Output For Pattern And Print matching Lines      .*UE${ue_idx}: Started Downlink Internal traffic Receiver*.
     ...          ${Timeout_SA}
     END

Verify UE released due to preemption
	[Arguments]    ${pcap_file}         ${idx}=${ue_idx}
    ${pdmlFile}=   Fetch filtered PDML file from pcap    ${pcap_file}         filterExp=ngap.UEContextReleaseRequest_element
    ...              filterName=UE_${idx}_preemption
    ${rel_cause}    analyzer.get_shownames     pdmlFile=${pdmlFile}
    ...                                                packetName=ngap.UEContextReleaseRequest_element
    ...                                                path=ngap.radioNetwork
    ...                                                endPacket=-${1}
    ...                                                kind=show
    List Should Contain Value            ${rel_cause}         46
    Log to Console      Verified UE ${idx} preemption

Verify UE Successful ICS due to fallback cause emergency
	[Arguments]    ${pcap_file}         ${count}
    ${pdmlFile}   Fetch filtered PDML file from pcap      ${pcap_file}        filterExp=ngap.InitialContextSetupResponse_element       filterName=ICS
    ${ICS_pkt}    analyzer.count_path     pdmlFile=${pdmlFile}
    ...                                                packetName=ngap.InitialContextSetupResponse_element
    ...                                                path=ngap.InitialContextSetupResponse_element
    ...                                                pkt_count=${1}
    Should Be Equal           ${ICS_pkt}          ${count}
    Log to Console      Verified UE Successful ICS due to fallback cause emergency

Modify File Parameter
    [Arguments]    ${file_path}    ${old_value}    ${new_value}
    [Documentation]    This keyword is to replace string for file
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${file_path} | No | the file path which need to modify |
    ...    | ${old_value} | No | the value need to be replaced |
    ...    | ${new_value} | No | the new value |
    ...
    ...    Examples:
    ...    | ${delta_path} | OperatingSystem.Join Path | ${scf_path} | ${SW_BRANCH} | SCF | Delta_Conf_5GC002504.json |
    ...    | Modify File Parameter | ${delta_path} | MRBTS-[0-9]+/NRBTS-[0-9]+ | ${NRBTS_DISTNAME} |
    ${joined_path} =    Set Variable    ${file_path}
    ${content}=    OperatingSystem.Get File    ${joined_path}
    ${content}=    String.Replace String Using Regexp    ${content}    ${old_value}    ${new_value}

Update bsr package
    Run     mkdir ${CURDIR}/BSR
    ${dllink}   Set Variable     https://artifactory-espoo1.ext.net.nokia.com:443/artifactory/mnpute-rotta-local/BSR
    ${filename}    Set variable     BSR_AQQJ_6_H6_ALN45_ARP45_P00_COVERAGE_00423_00001_CB010471.zip
    Run     sudo wget ${dllink}/${filename} --user=dheerajn --password=AP33ZXKC1P9cgTCGJmyvY3bv5NA -P ${CURDIR}/BSR
    coam.setup admin
    ${ret}     coam.Update Software      ${CURDIR}/BSR/BSR_AQQJ_6_H6_ALN45_ARP45_P00_COVERAGE_00423_00001_CB010471.zip
    coam.teardown admin
