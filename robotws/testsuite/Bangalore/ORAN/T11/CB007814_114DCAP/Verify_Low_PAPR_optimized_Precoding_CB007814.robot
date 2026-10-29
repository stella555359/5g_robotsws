*** Settings ***
Documentation
...               Feature ID: CB007814
...               Author: Divyanshi.gupta@nokia.com
Resource    ./resources/CB007623_keywords.robot
Resource    ../../resources/robot/common_setup_teardown.robot
Library     ta_attenuator
Resource    ../../resources/robot/common_log_analyzer.robot/
Library     taf.sw.dcap.rd     WITH NAME   dcap
Library            taf.file.pack    WITH NAME   interface
Resource          ../resources/Common_resource.robot
Force Tags        CRT    SBTS24R3    FL00    QCD_MN_RAN    QCP_RAN_VRF

Suite Setup		Suite Setup Update GNB  ###    scf_file=${scf_path}${scf_file}
Test setup        CB007623_keywords.Admin Setup
Test Teardown     CB007623_keywords.Admin Teardown

*** Variables ***
${BTS_ID}       1236
${CELL_ID}          1
${Commission_timeout}       500                                                         # Full commissioning timeout
@{capabilities}    Legacy_1
@{throughput_dl}=  250
@{throughput_ul}=   60
@{UE_alias}=  UE1
@{direction_dl}=  dl
@{direction_ul}=  ul
#@{duration}=  700s
@{timeout}      100
@{tcpcalltype}=    TCP
@{udpcalltype}=    UDP
@{deviation_dl}=  100
@{deviation_ul}=  100
${ASP_BOARD_TYPE}     ABIO0
${scf_path}=    ${CURDIR}/resources/
${scf_file}=        Configuration_scf_MRBTS-1236_2_2_ClosedLoopSA.xml
${scf_file_1}=        Configuration_scf_MRBTS-1236_4_4_SA.xml
${path1}     /tmp/testgetter/output_file/macro__dlStat.csv
@{gnb_customfilter}    L2Ps_Sherpa      L2Lo_Sherpa     condor5gSyslog     cp_5g        bip_interface_mirroring
@{bts_custom_filter}        immediateSnapshot    scf
${FILTER}         dldata_pdschsendreq
@{COLUMN_NAME}    DlData_PdschGrant.pdschBundleSize
${bip_log}        		    5GBipL2L1_filtering_off.pcap
${bts_user}			nemuuser
${bts_password}		nemuadmin
${Repetation_count}     2
${wait_for_transfer}    True
@{LTE_cell}     0
@{NR_cell}      3
&{CB007814_CB007657_Verify_Low_PAPR_optimized_Precoding_evaluation_for_Closed_Loop_4x4_SU_MIMO}
...     QC_ID_FL00=QC_31647        QC_ID_SBTS24R3=QC_774281

*** Test Cases ***
CB007814_CB007657_Verify_Low_PAPR_optimized_Precoding_evaluation_for_Closed_Loop_4x4_SU_MIMO
#    ${dlMimoMode}      Get Current Parameter Value    ${dist_name}/NRCELL-1         dlMimoMode
#	${actDlLowPAPRoptimizedPrecoding}    Get Current Parameter Value    ${dist_name}/NRCELL-1
#	...		actDlLowPAPRoptimizedPrecoding
#    ${status}      Run Keyword And Return Status     Run Keyword If
#	 ...	'${actDlLowPAPRoptimizedPrecoding}'!= 'True'
#    ...      Parameter value change    ${dist_name}/NRCELL-1 		actDlLowPAPRoptimizedPrecoding  	True
#    Should Not Be True    ${status}
#    Configure setup    ${scf_path}${scf_file_1}
    ${dlMimoMode}      Get Current Parameter Value    ${dist_name}/NRCELL-1         dlMimoMode
    Verify Coam Site Is Ready
    Lock cells  ${LTE_cell}
    Lock NR cells  ${NR_cell}
    Start DCAP log collection
    ${val_1}	Data Transfer 	@{udpcalltype}
	${actDlLowPAPRoptimizedPrecoding}    Get Current Parameter Value    ${dist_name}/NRCELL-1
	...		actDlLowPAPRoptimizedPrecoding
    Run Keyword If       '${actDlLowPAPRoptimizedPrecoding}'!= 'false'
	...		Parameter value change    ${dist_name}/NRCELL-1
    ...     actDlLowPAPRoptimizedPrecoding  	true
    Verify Coam Site Is Ready
	${val_2}	Data Transfer 	@{udpcalltype}
    Run keyword and continue on failure     tput_validation     ${val_1}     ${val_2}
#   Run keyword and continue on failure     Should Be True    ${t_put}
	Stop DCAP log collection
    Sleep   100s
    Run keyword and continue on failure     Unlock cells    ${LTE_cell}
    Run keyword and continue on failure     Unlock NRcells  ${NR_cell}
    Set Suite Variable    ${Log_path}        ${OUTPUT_DIR}/DCAP_Logs
    Set Suite Variable    ${source_paths}      ${Log_path}/Extracted
    create directory         ${source_paths}
    ${files}     OperatingSystem.List Files In Directory    ${Log_path}
    FOR    ${zip}    IN    @{files}
        interface.Extract
                         ...  path=${Log_path}/${zip}
                         ...  output_dir=${source_paths}
                         ...  .=*/*/*.*
        interface.Extract
                         ...  path=${Log_path}/${zip}
                         ...  output_dir=${source_paths}
                         ...  .=*/*/*_interface-mirroring.zip
                         ...  **/*_interface-mirroring.zip=BTS*_1011_*.zip
                         ...  **/BTS*_1011_*.zip=*.pcap.xz
                         ...  **/BTS*_1011_*.zip/*.pcap.xz=*

    END
    ${result}=    Run Process
    ...    find ${source_paths} -type f \\\( -name "*syslog.log" -o -name "*.pcap" \\\) -exec cp '{}' ${OUTPUT_DIR} \\\;
    ...    shell=True
    Copy Files      ${OUTPUT_DIR}/*syslog.log  ${OUTPUT_DIR}/SYSLOG
    Copy Files      ${source_paths}/*sherpa.pcap      ${OUTPUT_DIR}/SHERPA
    Run Process    command=mergecap -a ${OUTPUT_DIR}/SHERPA/*sherpa.pcap -w ${OUTPUT_DIR}/SHERPA/output_file.pcap
	...		shell=True
    Run Process    command=mergecap -a ${OUTPUT_DIR}/*sherpa.pcap -w ${OUTPUT_DIR}/SHERPA/output_file.pcap
	...		shell=True
    Run keyword and continue on failure     Convert pcap to sherpa csv
    Run keyword and continue on failure     Convert sherpa csv and validate
    Run Keyword     BIP analysis


*** Keywords ***

Data Transfer
    [Arguments]
    ta_ultracaller.Require UE    ue_alias=${UE_alias}    capabilities=${capabilities}
    ta_ultracaller.Detach UE    ue_alias=${UE_alias}
    Log to console    \nSwitching Aeroplane Mode On/OFF
    ta_ultracaller.Attach UE    ue_alias=${UE_alias}
    Log to console    \nStarting data transfer
    ta_ultracaller.start_data_transfer  ${UE_alias}   ${udpcalltype}    direction=${direction_dl}
	Log to console    \nWaiting for data transfer
    sleep    100
    Run Keyword If    '${wait_for_transfer}'=='True'    Run Keywords
	...		ta_ultracaller.await_data_transfer_finish    ${UE_alias}    ${direction_dl}
    ...     ${timeout}
    ...    AND    Sleep    150
    ...    AND    Log to console    \nData transfer completed
    &{val_1}    ta_ultracaller.calculate_thrughtput    ue_alias=${UE_alias}    direction=${direction_dl}
    ...     thrughtput=${throughput_dl}    deviation=${deviation_dl}
    [Return]	${val_1}

Convert sherpa csv and validate
    sherpa_analyzer.setup reader    ${path1}
    ${result1}     sherpa_analyzer.Get Values For Column    256QAM      #regexfilter=None
    ${result2}     sherpa_analyzer.Get Values For Column    MAX MCS     27
    ${result3}     sherpa_analyzer.Get Values For Column    MAX PRB    106
    ${result4}		sherpa_analyzer.Get Values For Column    MEAN RI   3
    ${result6}    value     ${result2}
    Should Be True    ${result4}
    ${result5}    QAM_validation    ${result1}
    Should Not Be Empty     ${result5}
    Should Contain      ${result4}		3.00
    Should Contain      ${result2}		27
    Should Contain     ${result3}		106

Start DCAP log collection
    dcap.connect_to  host=${DCAP_host}   port=443    username=${dcapuser}	password=${dcap_password}
    ...              rd_version=dcapv3  secure=True
#    &{bts1_info}   create dictionary  host=${M_plane_ip}    port=443    username=${bts_user}
#	...	password=${bts_password}
     &{bts1_info}   create dictionary  host=${BTS_M_plane_ip}    port=443
    @{enb_custom_profile}=    Create List    condor4gSyslog     scf4g
    ${output}    dcap.start_trace     duration=25    bts=${bts1_info}
    ...    gnb_custom_profile=@{gnb_customfilter}
    LogToConsole    ${output}
    ${output}=    Set Suite Variable    ${output}
    sleep   100


Stop DCAP log collection
    ${trace_id} =   Get From Dictionary   ${output}   tracer_id
    Run Keyword And Continue On Failure    dcap.stop_trace    trace_id=${trace_id}
    LogToConsole    ${trace_id}
    ${dcap_dirname}    dcap.get_results    result_id=${trace_id}
    ...     target_dir=${OUTPUT_DIR}/DCAP_Logs    timeout=2000
    LogToConsole    ${dcap_dirname}
    ${dcap_dirname}=    Set Suite Variable    ${dcap_dirname}

Convert pcap to sherpa csv
    Create Directory        /tmp/testgetter
    sherpa.create sherpa converter
        ...    name=sherpa
        ...    file_path_pattern=${OUTPUT_DIR}/SHERPA/output_file.pcap
        ...    output_path=/tmp/testgetter
    sherpa.setup    sherpa
    sherpa.convert    sherpa
    sherpa.teardown    sherpa

BIP analysis
   Run Process     command=mergecap ${OUTPUT_DIR}/*mirroring* -w ${OUTPUT_DIR}/5GBipL2L1_filtering_off.pcap
   ...	shell=True
    Copy Files      ${OUTPUT_DIR}/5GBipL2L1_filtering_off.pcap  ${OUTPUT_DIR}/BIP
   Get BIP csv file
    ${value}    verify_Biplog    ${BIP_CSV_LOG}    ${COLUMN_NAME}   ${Repetation_count}
    Run keyword and continue on failure    Should be True    ${value}

Get BIP csv file
    Set Suite Variable    ${BIP_CSV_LOG}    ${OUTPUT_DIR}/BIP//bip_log.csv
    OperatingSystem.Run   sudo rm -rf /usr/lib/x86_64-linux-gnu/wireshark/plugins/4.0/epan/mcshark-*buster.so
    Convert BIP To CSV By MCShark    ${OUTPUT_DIR}/BIP/${bip_log}    ${BIP_CSV_LOG}    ${FILTER}    ${COLUMN_NAME}
    ${csv_content}    Get File    ${BIP_CSV_LOG}


Configure setup
    [Documentation]     Perform commissioning
    [Arguments]         ${SCF_file}
    Log to console      \nCommissioning site with SCF : ${SCF_file}
    COAM.Perform Commissioning      bts_id=${BTS_ID}        scf_file=${SCF_file}
	...		skip_parameter_relation_errors=True
    ...                             should_activate=True    timeout=${Commission_timeout}   connection=${connection}
    Log to console      \nWaiting for BTS status to be OnAir
    Wait Until Keyword Succeeds    15 times    60    Check BTS is OnAir






