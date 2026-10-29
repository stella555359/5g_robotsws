*** Settings ***
Documentation
...               Feature    : eCPRI RRM porting for FR1-FDD on ABIO
...               Feature Id : CB007814
...               Author     : debanjali.misra@nokia.com
...               Email Id   :
Resource          ../resources/Common_resource.robot
Resource                  ./resources/CB007623_keywords.robot
Library           taf.sw.dcap.rd     WITH NAME   dcap
Resource          ../../resources/robot/common_setup_teardown.robot

Force Tags        CRT    SBTS24R3    FL00    QCD_MN_RAN    QCP_RAN_VRF


Suite Setup     Suite Setup Update GNB           scf_file=${scf_path}${scf_file}
Suite Teardown    Common Suite Teardown     scfc_file=${OUTPUT_DIR}/SCF_before_suite.xml

Test setup        CB007623_keywords.Admin Setup
Test Teardown     CB007623_keywords.Admin Teardown





*** Variables ***
&{CB007814_5GC001085_CB006127_ANR_addition_for_intra_frequency_intra_gNB_neighbour_for_SA_deployment}
...     QC_ID_FL00=QC_31506    QC_ID_SBTS24R2=QC_774137

@{UE_alias}=  UE1												# UE ID in configuration file
@{capabilities}    Legacy_1										# UE capability
@{data_transfer_protocol}       UDP								# Default data transfer type
${scf_path}=    ${CURDIR}/resources/
${scf_file}=        Configuration_scf_MRBTS-1236_4_4_ANR.xml
@{direction}                dl 									# Direction for data
${timeout}=      100
@{LTE_cell}     0
${NRCELL2_dict}		['BTS']['MRBTS-1236']['NRBTS-1236']['NRCELL-2']['NRCI-20250627']['MCC-404']['MNC-99']['NRREL']
${NRCELL3_dict}		['BTS']['MRBTS-1236']['NRBTS-1236']['NRCELL-3']['NRCI-20250626']['MCC-404']['MNC-99']['NRREL']
*** Test Cases ***

CB007814_5GC001085_CB006127_ANR_addition_for_intra_frequency_intra_gNB_neighbour_for_SA_deployment
    Set Suite variable   ${message_col}  ${4}
    Set Suite variable   ${content_col}  ${19}
#   Set Suite variable   ${OUTPUT_DIR}
#   ...     /home/ute/results/SBTS00_ENB_9999_240625_000009/2024_06_25_10_07/CB007814/CB007814_5GC001085_CB006127_ANR.robot
    Lock cells  ${LTE_cell}
    Run Keyword     Start DCAP log collection
	${set attenuation}  Create List     ${CA_cell_1},0     ${CA_cell_2},0      ${CA_cell_3},0      ${CA_cell_4},0
	...		${CA_cell_5},30      ${CA_cell_6},30		${CA_cell_7},30		${CA_cell_8},30
    Change attenuation  ${set attenuation}
	Sleep   20s
	${set attenuation}  Create List     ${CA_cell_1},10     ${CA_cell_2},10      ${CA_cell_3},10      ${CA_cell_4},10
	...		${CA_cell_5},20      ${CA_cell_6},20		${CA_cell_7},20		${CA_cell_8},20
    Change attenuation  ${set attenuation}
	Sleep   20s
	${set attenuation}  Create List     ${CA_cell_1},20     ${CA_cell_2},20      ${CA_cell_3},20      ${CA_cell_4},20
	...		${CA_cell_5},10      ${CA_cell_6},10		${CA_cell_7},10		${CA_cell_8},10
    Change attenuation  ${set attenuation}
	Sleep   20s
	${set attenuation}  Create List     ${CA_cell_1},30     ${CA_cell_2},30      ${CA_cell_3},30      ${CA_cell_4},30
	...		${CA_cell_5},0      ${CA_cell_6},0 	${CA_cell_7},0		${CA_cell_8},0
    Change attenuation  ${set attenuation}
	Sleep   20s
	${set attenuation}  Create List     ${CA_cell_1},40     ${CA_cell_2},40      ${CA_cell_3},40      ${CA_cell_4},40
	...		${CA_cell_5},0      ${CA_cell_6},0		${CA_cell_7},0		${CA_cell_8},0
    Change attenuation  ${set attenuation}
	Sleep   20s
	${set attenuation}  Create List     ${CA_cell_1},50     ${CA_cell_2},50      ${CA_cell_3},50      ${CA_cell_4},50
	...		${CA_cell_5},0      ${CA_cell_6},0		${CA_cell_7},0		${CA_cell_8},0
    Change attenuation  ${set attenuation}
	Sleep   20s
	${set attenuation}  Create List     ${CA_cell_1},60     ${CA_cell_2},60      ${CA_cell_3},60      ${CA_cell_4},60
	...		${CA_cell_5},0      ${CA_cell_6},0		${CA_cell_7},0		${CA_cell_8},0
    Change attenuation  ${set attenuation}
	Sleep   20s
	${set attenuation}  Create List     ${CA_cell_1},60     ${CA_cell_2},60      ${CA_cell_3},60      ${CA_cell_4},60
	...		${CA_cell_5},0      ${CA_cell_6},0		${CA_cell_7},0		${CA_cell_8},0
    Change attenuation  ${set attenuation}
	Sleep   20s
	${set attenuation}  Create List     ${CA_cell_1},50     ${CA_cell_2},50      ${CA_cell_3},50      ${CA_cell_4},50
	...		${CA_cell_5},10      ${CA_cell_6},10		${CA_cell_7},10		${CA_cell_8},10
    Change attenuation  ${set attenuation}
	Sleep   20s
	${set attenuation}  Create List     ${CA_cell_1},40     ${CA_cell_2},40      ${CA_cell_3},40      ${CA_cell_4},40
	...		${CA_cell_5},20      ${CA_cell_6},20		${CA_cell_7},20		${CA_cell_8},20
    Change attenuation  ${set attenuation}
	Sleep   20s
    ${set attenuation}  Create List     ${CA_cell_1},30     ${CA_cell_2},30      ${CA_cell_3},30      ${CA_cell_4},30
	...		${CA_cell_5},30      ${CA_cell_6},30		${CA_cell_7},30		${CA_cell_8},30
    Change attenuation  ${set attenuation}
	Sleep   20s
	${set attenuation}  Create List     ${CA_cell_1},20     ${CA_cell_2},20      ${CA_cell_3},20      ${CA_cell_4},20
	...		${CA_cell_5},30      ${CA_cell_6},30		${CA_cell_7},30		${CA_cell_8},30
    Change attenuation  ${set attenuation}
	Sleep   20s
	${set attenuation}  Create List     ${CA_cell_1},10     ${CA_cell_2},10      ${CA_cell_3},10      ${CA_cell_4},10
	...		${CA_cell_5},30      ${CA_cell_6},30		${CA_cell_7},30		${CA_cell_8},30
    Change attenuation  ${set attenuation}
	Sleep   20s
	${set attenuation}  Create List     ${CA_cell_1},0     ${CA_cell_2},0      ${CA_cell_3},0      ${CA_cell_4},0
	...		${CA_cell_5},30      ${CA_cell_6},30		${CA_cell_7},30		${CA_cell_8},30
    Change attenuation  ${set attenuation}
    sleep    120s
#	Set Environment Variable        TA_UE_CONFIG        ${CONFIG_PATH}
	ta_ultracaller.Require UE   ue_alias=${UE_alias}   capabilities=${capabilities}
	ta_ultracaller.Detach UE     ue_alias=${UE_alias}
    ta_ultracaller.Attach UE     ue_alias=${UE_alias}
    ta_ultracaller.start_data_transfer   ${UE_alias}     ${data_transfer_protocol}     direction=${direction}
    Sleep   40s
	${set attenuation}  Create List     ${CA_cell_1},0     ${CA_cell_2},0      ${CA_cell_3},0      ${CA_cell_4},0
	...		${CA_cell_5},30      ${CA_cell_6},30		${CA_cell_7},30		${CA_cell_8},30
    Change attenuation  ${set attenuation}
	Sleep   20s
	${set attenuation}  Create List     ${CA_cell_1},10     ${CA_cell_2},10      ${CA_cell_3},10      ${CA_cell_4},10
	...		${CA_cell_5},30      ${CA_cell_6},30		${CA_cell_7},30		${CA_cell_8},30
    Change attenuation  ${set attenuation}
	Sleep   20s
	${set attenuation}  Create List     ${CA_cell_1},20     ${CA_cell_2},20      ${CA_cell_3},20      ${CA_cell_4},20
	...		${CA_cell_5},30      ${CA_cell_6},30		${CA_cell_7},30		${CA_cell_8},30
    Change attenuation  ${set attenuation}
	Sleep   20s
	${set attenuation}  Create List     ${CA_cell_1},30     ${CA_cell_2},30      ${CA_cell_3},30      ${CA_cell_4},30
	...		${CA_cell_5},30      ${CA_cell_6},30		${CA_cell_7},30		${CA_cell_8},30
    Change attenuation  ${set attenuation}
	Sleep   20s
	${set attenuation}  Create List     ${CA_cell_1},40     ${CA_cell_2},40      ${CA_cell_3},40      ${CA_cell_4},40
	...		${CA_cell_5},30      ${CA_cell_6},30		${CA_cell_7},30		${CA_cell_8},30
    Change attenuation  ${set attenuation}
	Sleep   20s
	${set attenuation}  Create List     ${CA_cell_1},50     ${CA_cell_2},50      ${CA_cell_3},50      ${CA_cell_4},50
	...		${CA_cell_5},30      ${CA_cell_6},30		${CA_cell_7},30		${CA_cell_8},30
    Change attenuation  ${set attenuation}
	Sleep   20s
	${set attenuation}  Create List     ${CA_cell_1},60     ${CA_cell_2},60      ${CA_cell_3},60      ${CA_cell_4},60
	...		${CA_cell_5},30      ${CA_cell_6},30		${CA_cell_7},30		${CA_cell_8},30
    Change attenuation  ${set attenuation}
	Sleep   20s
	${set attenuation}  Create List     ${CA_cell_1},60     ${CA_cell_2},60      ${CA_cell_3},60      ${CA_cell_4},60
	...		${CA_cell_5},0      ${CA_cell_6},0		${CA_cell_7},0		${CA_cell_8},0
    Change attenuation  ${set attenuation}
	Sleep   20s
	${set attenuation}  Create List     ${CA_cell_1},50     ${CA_cell_2},50      ${CA_cell_3},50      ${CA_cell_4},50
    ...		${CA_cell_5},10      ${CA_cell_6},10		${CA_cell_7},10		${CA_cell_8},10
    Change attenuation  ${set attenuation}
	Sleep   20s
	${set attenuation}  Create List     ${CA_cell_1},40     ${CA_cell_2},40      ${CA_cell_3},40      ${CA_cell_4},40
	...		${CA_cell_5},20      ${CA_cell_6},20		${CA_cell_7},20		${CA_cell_8},20
    Change attenuation  ${set attenuation}
	Sleep   20s
	${set attenuation}  Create List     ${CA_cell_1},30     ${CA_cell_2},30      ${CA_cell_3},30      ${CA_cell_4},30
	...		${CA_cell_5},30      ${CA_cell_6},30		${CA_cell_7},30		${CA_cell_8},30
    Change attenuation  ${set attenuation}
	Sleep   20s
	${set attenuation}  Create List     ${CA_cell_1},20     ${CA_cell_2},20      ${CA_cell_3},20      ${CA_cell_4},20
	...		${CA_cell_5},30      ${CA_cell_6},30		${CA_cell_7},30		${CA_cell_8},30
    Change attenuation  ${set attenuation}
	Sleep   20s
	${set attenuation}  Create List     ${CA_cell_1},10     ${CA_cell_2},10      ${CA_cell_3},10      ${CA_cell_4},10
	...		${CA_cell_5},30      ${CA_cell_6},30		${CA_cell_7},30		${CA_cell_8},30
    Change attenuation  ${set attenuation}
	Sleep   20s
	${set attenuation}  Create List     ${CA_cell_1},0     ${CA_cell_2},0      ${CA_cell_3},0      ${CA_cell_4},0
	...		${CA_cell_5},30      ${CA_cell_6},30		${CA_cell_7},30		${CA_cell_8},30
    Change attenuation  ${set attenuation}
    sleep    120s
	ta_ultracaller.Detach UE     ue_alias=${UE_alias}
    ${set attenuation}  Create List     ${CA_cell_1},0     ${CA_cell_2},0      ${CA_cell_3},0      ${CA_cell_4},0
	...		${CA_cell_5},0      ${CA_cell_6},0     ${CA_cell_7},0     ${CA_cell_8},0
    Change attenuation  ${set attenuation}
    Stop DCAP log collection
	Run keyword and continue on failure         Unlock cells    ${LTE_cell}
    Run keyword and ignore error    COAM.setup_admin    bts_host=192.168.255.129    alias=${connection}
    ...		admin_api_log_dir=/tmp
    ${BTS_details}    COAM.get_bts_info    connection=${connection}
    Log    ${BTS_details}
	${count_1}		Counter value NRCELL2		M55153C00001
    ${count_2}      Run keyword and continue on failure    Counter value NRCELL3       M55153C00001
	${count_3}		Counter value NRCELL2       M55153C00002
    ${count_4}      Run keyword and continue on failure         Counter value NRCELL3       M55153C00002
	Should Be True		${count_1} > 0
	Should Be True		${count_2} > 0
	Run keyword and continue on failure     Should Be True      ${count_3} > 0
    Run keyword and continue on failure     Should Be True      ${count_4} > 0
    @{check}   Create list     rrcReconfigurationComplete
	@{check}   Create list     IntraGnbSourceHo
    Verify Emil logs	@{check}


*** Keywords ***
Start DCAP log collection
    [Documentation]     Start DCAP logs with custom filter
    Log to console      \nStarting DCAP trace
	dcap.connect_to  host=${DCAP_host}   port=443    username=utfuser   password=utfadmin!
    ...              rd_version=dcapv3  secure=True
    &{bts1_info}   create dictionary  host=${BTS_M_plane_ip}    port=443    username=Nemuadmin    password=nemuuser
    ...            credential_region_Id='DEFAULT_CREDENTIALS'
    ${output}       rd.start_trace  duration=30     bts=${BTS_INFO}    gnb_custom_profile=@{gnb_custom_filters}
    ...     bts_custom_profile=@{bts_custom_filter}		collection_timing=${collection_timing}
    Sleep       150      reason=Wait for DCAP start
    ${START_TRACE_ID}      Get from Dictionary    ${output}    tracer_id
    Set Suite Variable  ${START_TRACE_ID}
    LOG      DCAP log collection has been started in the gNB

Stop DCAP log collection
    [Documentation]     Stops DCAP and collect logs
    Log to console      \nStopping DCAP trace ID ${START_TRACE_ID} and collecting logs
    rd.stop_trace    ${START_TRACE_ID}
	Sleep   600s
    LOG     DCAP logging stopped
    rd.get_results    result_id=${START_TRACE_ID}    target_dir=${OUTPUT_DIR}/DCAP_Logs    timeout=600

Counter value NRCELL2
    [Arguments]    ${counter_name}
    [Documentation]     Check counter value of gnb
    Log to console      \nChecking gnb counter ${counter_name}
    ${result}     COAM.get_pm_counters    counter_ids=${counter_name}    timeout=60    connection=${connection}
    log    ${result}
    ${dict}     Catenate    ${NRCELL2_dict} ['${counter_name}']
    ${values}=      Get Dictionary Values   ${result${dict}}
#    ${values}    Get Dictionary Values
#    ...     ${result['BTS']['MRBTS-1236']['NRBTS-1236']['NRCELL-2']['NRCI-20250627']['MCC-404']['MNC-99']
#	...		['NRREL']['${counter_name}']}
    ${Total_Count}    Get value of Counter    ${values}
    [Return]    ${Total_Count}

Counter value NRCELL3
    [Arguments]    ${counter_name}
    [Documentation]     Check counter value of gnb
    Log to console      \nChecking gnb counter ${counter_name}
    ${result}     COAM.get_pm_counters    counter_ids=${counter_name}    timeout=60    connection=${connection}
    log    ${result}
    ${dict}     Catenate    ${NRCELL3_dict} ['${counter_name}']
    ${values}=      Get Dictionary Values   ${result${dict}}
#    ${values}    Get Dictionary Values
#    ...     ${result['BTS']['MRBTS-1236']['NRBTS-1236']['NRCELL-3']['NRCI-20250626']['MCC-404']['MNC-99']
#	...		['NRREL']['${counter_name}']}
    ${Total_Count}    Get value of Counter    ${values}
    [Return]    ${Total_Count}


Get value of Counter
    [Arguments]    ${Counter_value}
    [Documentation]     Get total value from list
    FOR    ${a}    IN    @{Counter_value}
        ${i}    Evaluate    ${i} + ${a}
    END
    [Return]    ${i}
