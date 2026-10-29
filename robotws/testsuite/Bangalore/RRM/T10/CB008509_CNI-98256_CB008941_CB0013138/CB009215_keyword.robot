*** Settings ***
Documentation    :copyright: Nokia
...              :authors: SUNIL T KURIAN
...              :contact: sunil.t_kurian@nokia.com
Variables      ta5g_global_var
Resource       taf/rfrl/common_resources/robot/libraries_instances.robot
Resource       taf/rfrl/common_resources/robot/coam.robot
Resource       ../../../resources/robot/common_log_collection.robot
Resource       ../../../resources/robot/Gnb.robot
Resource       ../../../resources/robot/WTS_Runner_Keywords.robot
Resource       ../../../resources/robot/Setup_Env.robot
Resource       ../../../resources/robot/Airphone.robot
Resource       ../../../resources/robot/WTS_Runner_Keywords.robot
Resource       ../../../resources/robot/PM_Counters.robot
Resource       ../../../resources/robot/Common_Keywords.robot
Resource	   ../../../resources/robot/TTI.robot
Resource       ../../../resources/robot/WTS_Runner_BF_CA_HO_Keywords.robot
Resource       ./5GC000937_Keywords.robot
Resource       pandas_common.resource

#Library        ute_admin              WITH NAME    ute_adm
Library        taf.collectors.btslog  WITH NAME    btslog
Library        taf.analyzer.pdml      WITH NAME    taf_pdml_analyser
Library	       taf.transport.ssh      WITH NAME    ssh
Library        taf.wts.runner         WITH NAME    wtsrunner
Library        Collections
Library        OperatingSystem
Library        String
Library        BuiltIn
Library        ta5g_tshark
Library        ta5g_commissioning
Library        SSHLibrary
Library        XML    True
Library	       ute_reporting_portal
Library        ../../../resources/python/avg_dl_data.py

*** Variables ***
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${UE_ID}        1
${nwslice_ID}   1
${gw_ID}     1
${QFI_ID}    1
${QFI_ID2}    2
${QFI_ID3}    3
${TRF_ID}    1
${TRF_ID2}    2
${TRF_ID3}    3
${TRF_ID4}    4
${epc_log_path}    /tmp/
${Pdu_session_ID}       1

*** Keywords ***
Add routes 3AMF
    [Documentation]    This keyword is to configure VM interfaces..
    Run    sudo ip addr add 10.0.1.132/24 dev eth3
    Run    sudo ip addr add 10.0.1.133/24 dev eth3
    Run    sudo ip addr add 10.0.1.131/24 dev eth3
    Run    sudo ip addr add 10.0.1.134/24 dev eth3
    Run    sudo ip addr add 10.0.1.135/24 dev eth3
    Run    sudo ip addr add 10.0.1.136/24 dev eth3
    Run    sudo ip addr add 10.0.1.99/24 dev eth3
    Run    sudo ip addr add 10.0.1.121/24 dev eth3
    Run    sudo ip addr add 10.0.1.123/24 dev eth3
    Run    sudo ip addr add 10.0.1.124/24 dev eth3
    Run    sudo ip addr add 10.0.1.125/24 dev eth3
    Run    sudo ip addr add 10.0.1.137/24 dev eth3
    Run    sudo ip addr add 10.0.1.3/24 dev eth3
    Run    sudo ip addr add 10.0.1.4/24 dev eth3
    Run    sudo ip addr add 10.0.1.61/24 dev eth3
    Run    sudo ip addr add 10.0.1.62/24 dev eth3
    Run    sudo ip addr add 10.0.1.138/24 dev eth3
    Run    sudo ip addr add 10.0.1.139/24 dev eth3
    Run    sudo ip addr add 10.0.1.140/24 dev eth3
    Run    sudo ip addr add 10.0.1.141/24 dev eth3

Update GNB R&D Parameter
   [Arguments]   ${LOG_PATH}   ${r&d_parameter}
   Get GNB Swconfig File    ${LOG_PATH}
   Modify Swconfig File Parameters    ${LOG_PATH}/swconfig_gnb.txt    ${r&d_parameter}
   Send Swconfig for GNB    ${LOG_PATH}/swconfig_gnb.txt

Register and trigger Multiple NonGBR biDir UE Traffic in a Cell
    [Arguments]   ${Start_UE}   ${End_UE}   ${DL_Rate}   ${UL_Rate}   ${Traffic_rate}=mbps
    MultiUE Register should be Successful    ${Start_UE}   ${End_UE}
    MultiUE Trigger DL Traffic for SA    ${Start_UE}   ${End_UE}    Traffic_rate=mbps     dl_rate=${DL_Rate}      trf_id=${TRF_ID}
    MultiUE Trigger UL Traffic for SA    ${Start_UE}   ${End_UE}    Traffic_rate=mbps     ul_rate=${UL_Rate}      trf_id=${TRF_ID}
    log to console  ${Traffic_rate}
Register and trigger NonGBR biDir Traffic 1UE per Cell
    [Arguments]   ${Start_UE}   ${NumCells}   ${DL_Rate}   ${UL_Rate}   ${Traffic_rate}=mbps
	FOR  ${UE}   IN RANGE   ${Start_UE}   (${NumCells}-1)*10+${Start_UE}+1   10
	    log to console    UEID: ${UE} :Non GBR call triggering now...
		UE Register should be Successful    ${UE}   gw_id=${UE}
		Trigger DL Data Traffic for SA    ue_id=${UE}    Traffic_rate=mbps     dl_rate=${DL_Rate}      trf_id=${TRF_ID}
		Trigger UL Data Traffic for SA    ue_id=${UE}    Traffic_rate=mbps     ul_rate=${UL_Rate}      trf_id=${TRF_ID}
	END
    log to console  ${Traffic_rate}
Register and trigger Multiple GBR biDir UE Traffic in a Cell
    [Arguments]   ${Start_UE}   ${End_UE}   ${DL_Rate}   ${UL_Rate}   ${Traffic_rate}=mbps
    FOR  ${UE}   IN RANGE   ${Start_UE}   ${End_UE}+1
        log to console     UEID: ${UE} : GBR call triggering now...
        UE Register should be Successful     ${UE}   gw_id=${UE}
        Run Keyword And Continue On Failure   UE PDU Modfication should be Successful  ${UE}   qosflows_to_add=2
        sleep   3s
        Run Keyword And Continue On Failure   UE PDU Modfication should be Successful  ${UE}   qosflows_to_add=3
        sleep   3s
        Run Keyword And Continue On Failure   UE PDU Modfication should be Successful  ${UE}   qosflows_to_add=4
        sleep   3s
        Run Keyword And Continue On Failure   Trigger VoNR DL Traffic for SA   ${UE}   qfi_id=3   rtp_codec=custom
        Run Keyword And Continue On Failure   Trigger VoNR UL Traffic for SA   ${UE}   qfi_id=3   rtp_codec=custom
        Run Keyword And Continue On Failure   Trigger DL Traffic for SA   ue_id=${UE}
        ...   Traffic_rate=${Traffic_rate}   dl_rate=${DL_Rate}   qfi_id=4
        Run Keyword And Continue On Failure   Trigger UL Non Bursty Data Traffic for SA   ue_id=${UE}
        ...   Traffic_rate=${Traffic_rate}   ul_rate=${UL_Rate}   qfi_id=4
        sleep   5s
        Run Keyword And Ignore Error   Validate DL GBR Traffic For SA   ue_id=${UE}   dl_rate=${DL_Rate}   qfi_id=4
        Run Keyword And Ignore Error   Validate UL GBR Traffic For SA   ue_id=${UE}   ul_rate=${UL_Rate}   qfi_id=4
     log to console   Ue${UE} ViNR call Successful
    END

Validate DL GBR Traffic For SA
    [Arguments]    ${ue_id}     ${dl_rate}    ${pdu_id}=${Pdu_session_ID}     ${qfi_id}=${QFI_ID}
    wtsrunner.bearer_stats  ue=${ue_id}   pdu=${pdu_id}   qfi=${qfi_id}   dir=dl
    ${bearer_stat_dl}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    Check Average Rate      ${bearer_stat_dl}    DL    ${dl_rate}
Validate UL GBR Traffic For SA
    [Arguments]    ${ue_id}     ${ul_rate}     ${pdu_id}=${Pdu_session_ID}      ${qfi_id}=${QFI_ID}
    wtsrunner.bearer_stats  ue=${ue_id}   pdu=${pdu_id}   qfi=${qfi_id}   dir=ul
    ${bearer_stat_ul}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    Check Average Rate      ${bearer_stat_ul}    UL    ${ul_rate}

Register and trigger GBR biDir Traffic 1UE per Cell
    [Arguments]   ${Start_UE}   ${NumCells}   ${DL_Rate}   ${UL_Rate}   ${Traffic_rate}=mbps
    FOR  ${UE}   IN RANGE   ${Start_UE}   (${NumCells}-1)*10+${Start_UE}+1   10
        log to console     UEID: ${UE} :GBR call triggering now...
        UE Register should be Successful     ${UE}   gw_id=${UE}
        Run Keyword And Continue On Failure   UE PDU Modfication should be Successful  ${UE}   qosflows_to_add=2
        sleep   3s
        Run Keyword And Continue On Failure   UE PDU Modfication should be Successful  ${UE}   qosflows_to_add=3
        sleep   3s
        Run Keyword And Continue On Failure   UE PDU Modfication should be Successful  ${UE}   qosflows_to_add=4
        sleep   3s
        Run Keyword And Continue On Failure   Trigger VoNR DL Traffic for SA   ${UE}   qfi_id=3   rtp_codec=custom
        Run Keyword And Continue On Failure   Trigger VoNR UL Traffic for SA   ${UE}   qfi_id=3   rtp_codec=custom
        Run Keyword And Continue On Failure   Trigger DL Traffic for SA   ue_id=${UE}
        ...   Traffic_rate=${Traffic_rate}   dl_rate=${DL_Rate}   qfi_id=4
        Run Keyword And Continue On Failure   Trigger UL Non Bursty Data Traffic for SA   ue_id=${UE}
        ...   Traffic_rate=${Traffic_rate}   ul_rate=${UL_Rate}   qfi_id=4
        sleep   5s
        Run Keyword And Ignore Error   Validate DL Traffic For SA   ue_id=${UE}   dl_rate=${DL_Rate}   qfi_id=4
        Run Keyword And Ignore Error   Validate UL Traffic For SA   ue_id=${UE}   ul_rate=${UL_Rate}   qfi_id=4
     log to console   Ue${UE} ViNR call Successful
    END
Validate biDir NonGBR Traffic for MultiUE in a cell
    [Arguments]   ${Start_UE}   ${End_UE}   ${DL_Rate}   ${UL_Rate}   ${Traffic_rate}=mbps
    Validate DL Traffic For MultiUE for SA  ${Start_UE}   ${End_UE}   ${DL_Rate}
    Validate UL Traffic For MultiUE for SA  ${Start_UE}   ${End_UE}   ${UL_Rate}
    log to console  ${Traffic_rate}
Validate biDir GBR Traffic for MultiUE in a cell
    [Arguments]   ${Start_UE}   ${End_UE}   ${DL_Rate}   ${UL_Rate}   ${Traffic_rate}=mbps
        Run Keyword And Ignore Error   Validate DL Traffic For SA   ue_id=${UE}   dl_rate=${DL_Rate}   qfi_id=4
        Run Keyword And Ignore Error   Validate UL Traffic For SA   ue_id=${UE}   ul_rate=${UL_Rate}   qfi_id=4
        log to console  ${Start_UE}  ${End_UE}  ${Traffic_rate}
Validate biDir NonGBR Traffic for 1UE per cell
    [Arguments]   ${Start_UE}   ${NumCells}   ${DL_Rate}   ${UL_Rate}   ${Traffic_rate}=mbps
	FOR  ${UE}   IN RANGE   ${Start_UE}   (${NumCells}-1)*10+${Start_UE}+1   10
		Validate DL Traffic For SA    ${UE}   dl_rate=${DL_Rate}
		Validate UL Traffic For SA    ${UE}   ul_rate=${UL_Rate}
	END
    log to console  ${Traffic_rate}
Validate biDir GBR Traffic for 1UE per cell
    [Arguments]   ${Start_UE}   ${NumCells}   ${DL_Rate}   ${UL_Rate}   ${Traffic_rate}=mbps
	FOR  ${UE}   IN RANGE   ${Start_UE}   (${NumCells}-1)*10+${Start_UE}+1   10
		Validate DL Traffic For SA     ${UE}   dl_rate=${DL_Rate}   qfi_id=4
		Validate UL Traffic For SA     ${UE}   ul_rate=${UL_Rate}   qfi_id=4
	END
    log to console  ${Traffic_rate}
Attach and trigger NSA biDir call 1UE per Cell
    [Arguments]    ${Start_UE}    ${NumCells}   ${DL_Rate}   ${UL_Rate}
    [Documentation]    This keyword is used for running multiple NSA calls
	#X2AP Link Should be UP
	sleep   5s
    FOR	    ${nsa_ue_idx}   IN RANGE    ${Start_UE} 	  ${Start_UE}+${NumCells}
		LTE Attach should be Successful    NSA_UE_ID=${nsa_ue_idx}
		${Target_cell}     Evaluate   ${nsa_ue_idx}-${Start_UE}+1
		UE Attach should be Successful   NSA_UE_ID=${nsa_ue_idx}     Trgt_Cell=${Target_cell}
		Trigger DL Traffic for NSA    ue_id=${nsa_ue_idx}    Traffic_rate=mbps     dl_rate=${DL_Rate}     id=2    trf_id=1
		Trigger UL Traffic for NSA    ue_id=${nsa_ue_idx}    Traffic_rate=mbps     ul_rate=${UL_Rate}     id=2    trf_id=1
	END
	BuiltIn.Log    MultiUE_NSACall_is_ok
Validate NSA biDir Traffic for 1UE per cell
    [Arguments]   ${Start_UE}   ${NumCells}    ${DL_Rate}   ${UL_Rate}
	FOR  ${UE}   IN RANGE   ${Start_UE}   ${Start_UE}+${NumCells}
		Run Keyword And Continue On Failure   Validate DL Traffic For NSA    ${UE}   ${DL_Rate}   id=2
		Run Keyword And Continue On Failure   Validate UL Traffic For NSA    ${UE}   ${UL_Rate}   id=2
	END

Check MIB_SIB status of Active cell
    [Arguments]   ${Cell_Id}
   wtsrunner.enb_cell_ib_disp   enb=2   cell=${Cell_Id}
   ${output}   wtsrunner.read_wtsemu_output_until_re    expected=SIB5.\*80  timeout=120
   ${MIB}     Get Lines Matching Regexp    ${output}    MIB    partial_match=${TRUE}
   ${SIB1}     Get Lines Matching Regexp    ${output}    SIB1    partial_match=${TRUE}
   Should contain    ${MIB}     yes
   Should contain    ${SIB1}     yes
Check MIB_SIB status of deleted cell
    [Arguments]   ${Cell_Id}
   wtsrunner.enb_cell_ib_disp   enb=2   cell=${Cell_Id}
   ${output}   wtsrunner.read_wtsemu_output_until_re    expected=SIB1.\*80   timeout=120
   ${MIB}     Get Lines Matching Regexp    ${output}    MIB    partial_match=${TRUE}
   ${SIB1}     Get Lines Matching Regexp    ${output}    SIB1    partial_match=${TRUE}
   Should contain    ${MIB}     no

Validate bidir SCH data 1UE per cell
     [Arguments]   ${Start_UE}   ${NumCells}   ${DL_Rate}   ${UL_Rate}   ${Traffic_rate}=mbps
     FOR  ${UE}   IN RANGE   ${Start_UE}   (${NumCells}-1)*10+${Start_UE}+1   10
        ${pcell_dl_tput}=    Get AVG DL DATA TRAFFIC For Given CC   ue_id=${UE}  scell_idx=0  unit=Mbps
        Run Keyword And Continue On Failure   Should Be True    ${pcell_dl_tput} > ${DL_Rate}
        ${pcell_ul_tput}=    Get AVG UL DATA TRAFFIC For Given CC   ue_id=${UE}  scell_idx=0  unit=Mbps
        Run Keyword And Continue On Failure   Should Be True    ${pcell_ul_tput} > ${UL_Rate}
     END
    log to console  ${Traffic_rate}
Validate bidir SCH data for MultiUE in a cell
     [Arguments]   ${Start_UE}   ${End_UE}   ${DL_Rate}   ${UL_Rate}  ${Traffic_rate}=mbps
     FOR  ${UE}   IN RANGE   ${Start_UE}   ${End_UE}+1
        ${pcell_dl_tput}=    Get AVG DL DATA TRAFFIC For Given CC   ue_id=${UE}  scell_idx=0  unit=Mbps
        Run Keyword And Continue On Failure   Should Be True    ${pcell_dl_tput} > ${DL_Rate}
        ${pcell_ul_tput}=    Get AVG UL DATA TRAFFIC For Given CC   ue_id=${UE}  scell_idx=0  unit=Mbps
        Run Keyword And Continue On Failure   Should Be True    ${pcell_ul_tput} > ${UL_Rate}
     END
    log to console  ${Traffic_rate}
Get PUSCH UE Stats NR
    [documentation]   WA to CleanUp egate Console...
    [Arguments]    ${ue_id}=1    ${scell_idx}=0
    wtsrunner.ue_stats_nr   id=${ue_id}    type=pusch    scell=${scell_idx}
    ${output}    wtsrunner.Read Wtsemu Output Until    expected=NR PUSCH Throughput   timeout=10
    [Return]      ${output}
GET UE PUSCH Stats
    ${output}    wtsrunner.read_wtsemu_output_until_prompt    timeout=10
    Log to Console    ${output}
    should contain    ${output}    Average
    [Return]      ${output}
Get PUSCH UE Stats for Given CC
    [Arguments]    ${ue_id}=1    ${scell_idx}=0
    Log to Console    PUSCH UE stats for given CC
    wtsrunner.ue_stats_nr   id=${ue_id}    type=pusch    scell=${scell_idx}
    ${output}    Wait Until Keyword Succeeds     1 min    2 sec    GET UE PUSCH Stats
    Get Lines Matching Regexp    ${output}    NR PUSCH Throughput    partial_match=${TRUE}
    [Return]      ${output}

Get AVG UL DATA TRAFFIC For Given CC
    [Arguments]    ${ue_id}=1    ${scell_idx}=0     ${unit}=Mbps
    ${pusch_ue_stats}    Get PUSCH UE Stats for Given CC    ${ue_id}    ${scell_idx}
	${avg_tput}   avg_dl_data.get_avg_dl_data_traffic    ${pusch_ue_stats}    ${unit}
	Log to Console    ${avg_tput}
    [Return]      ${avg_tput}

Validate ZAB privilege granted
    [Arguments]   ${csv_file_path}
    ${Result}    check_zab_for_each_cell.has_zab_privilege    ${csv_file_path}/output_dl_formated.csv
    [Return]   ${Result}[0]   ${Result}[1]

Retrieve PRB Pooling Reports Lines within defined range
    [Documentation]    Retrieve raws in a range defined between {First_Line} and {Last_line}
    ...                and export the selected raws into a new csv file with name raws_between=First_Line&Last_line.csv
    [Arguments]     ${file_name}    ${First_Line}    ${Last_line}
    ${data} =  OperatingSystem.Get File    ${file_name}
    ${count} =      Get Line Count    ${data}
    Dated Log New Line         Number of Raws : ${count}
    ${Top_row} =  Get Line    ${data}    0
    ${sherpa_csv_outputfile_range} =    Replace String    ${file_name}    _45_.csv    _45_Output_Range_Lines_${First_Line}-${Last_line}.csv
    Set Suite Variable    ${sherpa_csv_outputfile_range}
    Append To File     ${sherpa_csv_outputfile_range}    ${Top_row}\n
    FOR    ${loopIND}    IN RANGE    ${First_Line}    ${Last_line}
    ${raw} =    Get Line    ${data}    ${loopIND}
    Append To File     ${sherpa_csv_outputfile_range}    ${raw}\n
    END
    [Return]       ${sherpa_csv_outputfile_range}

Get First Value in a Column against Specified Column In File
    [Documentation]     INTERNAL USAGE
    ...                 Verify the integer numeric string values in a cvs file generated by sherpa using an operator and a reference value
    ...                 returns True if all of them satisfy the condition, False if not.
    [Arguments]         ${file}    ${column_name}    ${regex_prereq}=None    ${colum_prereq}=None    ${column_filter}=\d*
    ###  DO NOT USE DIRECTLY! ################################
    # Please use keyword       Verify Message presence in csv Files
    SherpaCsvReader.setup reader    ${file}
    # Reactivate for debug
    # Dated Log             Params are:\n${valuetocheck} ${check_operator} ${Column_name} ${regex_prereq} ${colum_prereq}
    @{result_temp}          SherpaCsvReader.check csv column match all match another            ${Column_name}
    ...                     ${regex_prereq}                                 ${colum_prereq}     ${column_filter}
    log to console    ${result_temp}[1]
    ${list_values}=    Get From List    ${result_temp}    1
    log to console    ${list_values}
    ${first_value}=    Get From List    ${list_values}    0
    log to console    ${first_value}
    [Return]    ${first_value}

Check Values on Operator In File with Prereq
    [Documentation]     INTERNAL USAGE
    ...                 Verify the integer numeric string values in a cvs file generated by sherpa using an operator and a reference value
    ...                 returns True if all of them satisfy the condition, False if not.
    [Arguments]         ${file}    ${column_name}    ${check_operator}    ${valuetocheck}
    ...                 ${regex_prereq}=None        ${colum_prereq}=None    ${column_filter}=\d*
    ###  DO NOT USE DIRECTLY! ################################
    # Please use keyword       Verify Message presence in csv Files
    SherpaCsvReader.setup reader    ${file}
    # Reactivate for debug
    # Dated Log             Params are:\n${valuetocheck} ${check_operator} ${column_name} ${regex_prereq} ${colum_prereq}
    @{result_temp}          Run Keyword if                                  '${regex_prereq}'!='None'
    ...                     SherpaCsvReader.check csv column match all match another            ${column_name}
    ...                     ${regex_prereq}                                 ${colum_prereq}     ${column_filter}
    ...                     ELSE
    ...                     SherpaCsvReader.check csv column match all      ${column_name}      ${column_filter}
    ${result}               Set Variable                                    ${None}
    @{values_to_check}      Set Variable                                    ${result_temp}[1]
    Dated Log               values_to_check is: ${values_to_check}
    FOR    ${elem}    IN    @{values_to_check}
        ${result}           Run keyword If              '${elem}'!=''
        ...                 Check on Operator           ${valuetocheck}      ${check_operator}
        ...                 ${elem}
    END
    Dated Log            Result is: ${result}
    [Return]    ${result}

Copy Sherpa Files
    [Arguments]    ${sherpa_output_path}
    @{pcap_files}                  OperatingSystem.List Files In Directory     ${sherpa_output_path}        *.csv
    Create Directory               ${sherpa_output_path}/tcpdump
    FOR    ${file}    IN     @{pcap_files}
        Dated Log                  Moving file ${file}
        run                        mv ${sherpa_output_path}/${file} ${sherpa_output_path}/tcpdump
    END

Get Counter Value With Admin
     [Arguments]    ${counter_id}
    [Documentation]    This keyword is to get the lastest value of couter from Admin
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${counter_id} | Yes | Counte id, such as M55323C14001 |
    ...
    ...    Examples:
    ...    | Get Latest PM Counter Value With Admin | M55323C14001 |
    ...
    COAM.Setup Admin
    ${counter}    COAM.Get Pm Counters    ${counter_id}
    ${counter_str}    Convert To String    ${counter}
    ${counter_list}    String.Get Regexp Matches    ${counter_str}
    ...    (?P<counter_time>\\d+)':\\s(?P<counter_num>\\d+)    counter_time    counter_num
    ${latest}    Evaluate    max(${counter_list})
    [Teardown]    Run Keyword And Ignore Error    COAM.Teardown
    [Return]    ${latest[-1]}

Collect TTI Log
    [Arguments]    ${Test_Step}  ${Duration}
    Start Log      ttitrace
    Sleep     ${Duration}
    ${tti_path}    Stop Log       ttitrace   test_scenario=${Test_Step}

Decode and Valiadate Prb Allocation from TTI Logs
    [Arguments]    ${Test_Step}   ${CellId}   ${DL_Threshold1}    ${DL_Threshold2}   ${UL_Threshold1}    ${UL_Threshold2}
    ${TEST_NAME}      replace string    ${TEST_NAME}      ${SPACE}      _
    Decode TTI Trace DLUL   ${Test_Step}
    FOR  ${Cell}  IN  @{CellId}
         Validate cell prballocation from TTI traces multicell    ${LOG_PATH}/${TEST_NAME}/gNB/ttitrace/${Test_Step}    ${Cell}
         ...    ${DL_Threshold1}    ${DL_Threshold2}   ${UL_Threshold1}    ${UL_Threshold2}
    END
    Sleep    40s

Validate cell prballocation from TTI traces multicell
    [Arguments]   ${csv_file_path}  ${CellId}    ${DL_Threshold1}    ${DL_Threshold2}   ${UL_Threshold1}    ${UL_Threshold2}
    log to console   python123 ...
    ${TEST_NAME}      replace string    ${TEST_NAME}      ${SPACE}      _
    ${DL_Check}   Verify cell dlprballocation multicell   ${csv_file_path}/output_dl_formated.csv    ${CellId}
    ...      ${DL_Threshold1}    ${DL_Threshold2}
    ${UL_Check}   Verify cell ulprballocation multicell   ${csv_file_path}/output_ul_formated.csv    ${CellId}
    ...      ${UL_Threshold1}    ${UL_Threshold2}
    log to console   Debug123 ...
    run keyword and continue on failure   Run Keyword if   ${DL_Check}!=${True}   Fail   prb allocation failure
    run keyword and continue on failure   Run Keyword if   ${UL_Check}!=${True}   Fail   prb allocation failure

Verify cell ulprballocation multicell
    [Arguments]   ${csv_file_path}  ${cellid}    ${Threshold1}    ${Threshold2}
    log to console   python123_CALLING_PYTHON ...
    ${Result}   check_dl_ul_prballocation.check_ulallocatedprb   ${csv_file_path}    ${cellId}    ${Threshold1}
    ...                        ${Threshold2}
    [Return]   ${Result}
Verify cell dlprballocation multicell
    [Arguments]   ${csv_file_path}  ${cellid}    ${Threshold1}    ${Threshold2}
    log to console   python123_CALLING_PYTHON ...
    ${Result}   check_dl_ul_prballocation.check_dlallocatedprb   ${csv_file_path}    ${cellId}    ${Threshold1}
    ...                        ${Threshold2}
    [Return]   ${Result}

Verify cell ulprballocation multicell_G
    [Arguments]   ${csv_file_path}      ${cellid}    ${Threshold1}    ${Threshold2}
    log to console   python123_CALLING_PYTHON ...
    ${Result}   check_prb_multicell.check_ulallocatedprb      ${csv_file_path}    ${cellId}      ${Threshold1}
    ...                        ${Threshold2}
    [Return]   ${Result}

Decode TTI Trace DLUL
    [Arguments]    ${ttitrace_path}=${EMPTY}
    Dated Log                        converting ttitrace pcap to csv
    ${TEST_NAME}      replace string    ${TEST_NAME}      ${SPACE}      _
    ${tti_path}      Set Variable     ${LOG_PATH}/${TEST_NAME}/gNB/ttitrace/${ttitrace_path}/
    Common Convert Ttitrace From Pcap To Excelcsv        ${tti_path}
    Common Format Tti In Stream Mode         ${tti_path}/output_dl.csv     ${tti_path}/output_dl_formated.csv
    Common Format Tti In Stream Mode         ${tti_path}/output_ul.csv     ${tti_path}/output_ul_formated.csv


Collect and Decode Sherpa logs
    [Arguments]    ${folder_name}   ${Duration}
    Start Log    sherpa
    Sleep    ${Duration}
    ${sherp_path_tti}    Stop Log     sherpa     test_scenario=${folder_name}
    log to console    ${sherp_path_tti}
	Decode Sherpa pcap     ${folder_name}
	Set Global Variable     ${sherpa_output_path}     ${sherp_path_tti}[sherpa]
	Copy Sherpa Files    ${sherpa_output_path}
	log to console    ${sherpa_output_path}

Verify PRB capability and CSI_RS Pooling Group Allocation for 3 20Mhz Cells
    [Arguments]   ${Test_Step}   ${Dl_SP0_Threshold}  ${Dl_SP1_Threshold}  ${Ul_SP0_Threshold}  ${Ul_SP1_Threshold}
    Calling Panda Extract Csv function    ${sherpa_output_path}
    Verify numallocatedStreamPRBsDL is equal to threshold  ${sherpa_output_path}
	...    Dl_SP0_Threshold=${Dl_SP0_Threshold}   Dl_SP1_Threshold=${Dl_SP1_Threshold}
    Verify numallocatedStreamPRBsUL is equal to threshold    ${sherpa_output_path}
	...   Ul_SP0_Threshold=${Ul_SP0_Threshold}   Ul_SP1_Threshold=${Ul_SP1_Threshold}
    Verify each cell assigned to different csiRsPoolingGroup    ${sherpa_output_path}    expected_value=1
    log to console  ${Test_Step}
Verify PRB capability and CSI_RS Pooling Group Allocation after 3 40Mhz Cell Addition
    [Arguments]   ${Test_Step}   ${Dl_SP0_Threshold}  ${Dl_SP1_Threshold}  ${Ul_SP0_Threshold}  ${Ul_SP1_Threshold}
    Calling Panda Extract Csv function    ${sherpa_output_path}
    Verify numallocatedStreamPRBsDL is greater than threshold    ${sherpa_output_path}
	...   Dl_SP0_Threshold=${Dl_SP0_Threshold}   Dl_SP1_Threshold=${Dl_SP1_Threshold}
    Verify numallocatedStreamPRBsUL is greater than threshold   ${sherpa_output_path}
	...   Ul_SP0_Threshold=${Ul_SP0_Threshold}   Ul_SP1_Threshold=${Ul_SP1_Threshold}
    Verify each csiRsPoolingGroup has the same number of cells     ${sherpa_output_path}
    log to console  ${Test_Step}
Verify PRB capability for 3 20Mhz Cells
    [Arguments]   ${Test_Step}   ${Dl_SP0_Threshold}  ${Dl_SP1_Threshold}  ${Ul_SP0_Threshold}  ${Ul_SP1_Threshold}
    Calling Panda Extract Csv function    ${sherpa_output_path}
    Verify numallocatedStreamPRBsDL is equal to threshold  ${sherpa_output_path}
	...    Dl_SP0_Threshold=${Dl_SP0_Threshold}   Dl_SP1_Threshold=${Dl_SP1_Threshold}
    Verify numallocatedStreamPRBsUL is equal to threshold    ${sherpa_output_path}
	...   Ul_SP0_Threshold=${Ul_SP0_Threshold}   Ul_SP1_Threshold=${Ul_SP1_Threshold}
    log to console  ${Test_Step}

Verify PRB capability 4 20Mhz Cells
    [Arguments]   ${Test_Step}   ${Dl_SP0_Threshold}  ${Dl_SP1_Threshold}  ${Ul_SP0_Threshold}  ${Ul_SP1_Threshold}
    Calling Panda Extract Csv function    ${sherpa_output_path}
    Verify numallocatedStreamPRBsDL is greater than threshold    ${sherpa_output_path}
	...   Dl_SP0_Threshold=${Dl_SP0_Threshold}   Dl_SP1_Threshold=${Dl_SP1_Threshold}
    Verify numallocatedStreamPRBsUL is greater than threshold   ${sherpa_output_path}
	...   Ul_SP0_Threshold=${Ul_SP0_Threshold}   Ul_SP1_Threshold=${Ul_SP1_Threshold}
    log to console  ${Test_Step}
Verify numallocatedStreamPRBsDL is equal to threshold
    [Documentation]     Check the DL NumAllocStreamPrb in SP0 & SP1  is equal to some threshold
    [Arguments]     ${sherpa_output_path}   ${Dl_SP0_Threshold}  ${Dl_SP1_Threshold}
    ${file_path_Dl_PrbPoolingAllocation_semicolon} =      set variable    ${sherpa_output_path}/tcpdump/Dl_PrbPoolingAllocationSubpool_45_.csv
    ${alloc_streamprb_Dl_SP0}=    Create List
    ${alloc_streamprb_Dl_SP1}=    Create List
    Retrieve PRB Pooling Reports Lines within defined range    file_name=${file_path_Dl_PrbPoolingAllocation_semicolon}
    ...                                                        First_Line=10     Last_line=20
    Dated Log New Line    Saved the PRB Requested values in ${file_path_Dl_PrbPoolingAllocation_semicolon}
    ${alloc_streamprb_Dl_SP0}     Get First Value in a Column against Specified Column In File    file=${file_path_Dl_PrbPoolingAllocation_semicolon}
    ...                                  column_name=NumAllocStreamPrb    regex_prereq=0     colum_prereq=SubPoolId
    ${alloc_streamprb_Dl_SP1}     Get First Value in a Column against Specified Column In File    file=${file_path_Dl_PrbPoolingAllocation_semicolon}
    ...                                  column_name=NumAllocStreamPrb    regex_prereq=1     colum_prereq=SubPoolId
    log to console    NumAllocStreamPrb_SP0= ${alloc_streamprb_Dl_SP0}
    log to console    NumAllocStreamPrb_SP1= ${alloc_streamprb_Dl_SP1}
    Should Be True    ${alloc_streamprb_Dl_SP0}>=${Dl_SP0_Threshold}
    Should Be True    ${alloc_streamprb_Dl_SP1}>=${Dl_SP1_Threshold}

Verify numallocatedStreamPRBsUL is equal to threshold
    [Documentation]     Check the UL NumAllocStreamPrb in SP0 & SP1 is equal to some threshold
    [Arguments]     ${sherpa_output_path}  ${Ul_SP0_Threshold}  ${Ul_SP1_Threshold}
    ${file_path_Ul_PrbPoolingAllocation_semicolon} =      set variable    ${sherpa_output_path}/tcpdump/Ul_PrbPoolingAllocationSubpool_45_.csv
    ${alloc_streamprb_Ul_SP0}=    Create List
    ${alloc_streamprb_Ul_SP1}=    Create List
    Retrieve PRB Pooling Reports Lines within defined range    file_name=${file_path_Ul_PrbPoolingAllocation_semicolon}
    ...                                                        First_Line=10     Last_line=20
    Dated Log New Line    Saved the PRB Requested values in ${file_path_Ul_PrbPoolingAllocation_semicolon}
    ${alloc_streamprb_Ul_SP0}     Get First Value in a Column against Specified Column In File    file=${file_path_Ul_PrbPoolingAllocation_semicolon}
    ...                                  column_name=NumAllocStreamPrb    regex_prereq=0     colum_prereq=SubPoolId
    ${alloc_streamprb_Ul_SP1}     Get First Value in a Column against Specified Column In File    file=${file_path_Ul_PrbPoolingAllocation_semicolon}
    ...                                  column_name=NumAllocStreamPrb    regex_prereq=1     colum_prereq=SubPoolId
    log to console    NumAllocStreamPrb_SP0= ${alloc_streamprb_Ul_SP0}
    log to console    NumAllocStreamPrb_SP1= ${alloc_streamprb_Ul_SP1}
    Should Be True    ${alloc_streamprb_Ul_SP0}==${Ul_SP0_Threshold}
    Should Be True    ${alloc_streamprb_Ul_SP1}==${Ul_SP1_Threshold}
Verify numallocatedStreamPRBsDL is greater than threshold
    [Documentation]     Check the DL NumAllocStreamPrb in SP0 & SP1 is greater than some threshold
    [Arguments]     ${sherpa_output_path}   ${Dl_SP0_Threshold}  ${Dl_SP1_Threshold}
    ${file_path_Dl_PrbPoolingAllocation_semicolon} =      set variable    ${sherpa_output_path}/tcpdump/Dl_PrbPoolingAllocationSubpool_45_.csv
    ${alloc_streamprb_Dl_SP0}=    Create List
    ${alloc_streamprb_Dl_SP1}=    Create List
    Retrieve PRB Pooling Reports Lines within defined range    file_name=${file_path_Dl_PrbPoolingAllocation_semicolon}
    ...                                                        First_Line=10     Last_line=20
    Dated Log New Line    Saved the PRB Requested values in ${file_path_Dl_PrbPoolingAllocation_semicolon}
    ${alloc_streamprb_Dl_SP0}     Get First Value in a Column against Specified Column In File    file=${file_path_Dl_PrbPoolingAllocation_semicolon}
    ...                                  column_name=NumAllocStreamPrb    regex_prereq=0     colum_prereq=SubPoolId
    ${alloc_streamprb_Dl_SP1}     Get First Value in a Column against Specified Column In File    file=${file_path_Dl_PrbPoolingAllocation_semicolon}
    ...                                  column_name=NumAllocStreamPrb    regex_prereq=1     colum_prereq=SubPoolId
    log to console    NumAllocStreamPrb_SP0= ${alloc_streamprb_Dl_SP0}
    log to console    NumAllocStreamPrb_SP1= ${alloc_streamprb_Dl_SP1}
    Should Be True    ${alloc_streamprb_Dl_SP0}>=${Dl_SP0_Threshold}
    Should Be True    ${alloc_streamprb_Dl_SP1}>=${Dl_SP1_Threshold}

Verify numallocatedStreamPRBsUL is greater than threshold
    [Documentation]     Check the UL NumAllocStreamPrb in SP0 & SP1 is greater than some threshold
    [Arguments]     ${sherpa_output_path}  ${Ul_SP0_Threshold}  ${Ul_SP1_Threshold}
    ${file_path_Ul_PrbPoolingAllocation_semicolon} =      set variable    ${sherpa_output_path}/tcpdump/Ul_PrbPoolingAllocationSubpool_45_.csv
    ${alloc_streamprb_Ul_SP0}=    Create List
    ${alloc_streamprb_Ul_SP1}=    Create List
    Retrieve PRB Pooling Reports Lines within defined range    file_name=${file_path_Ul_PrbPoolingAllocation_semicolon}
    ...                                                        First_Line=10     Last_line=20
    Dated Log New Line    Saved the PRB Requested values in ${file_path_Ul_PrbPoolingAllocation_semicolon}
    ${alloc_streamprb_Ul_SP0}     Get First Value in a Column against Specified Column In File    file=${file_path_Ul_PrbPoolingAllocation_semicolon}
    ...                                  column_name=NumAllocStreamPrb    regex_prereq=0     colum_prereq=SubPoolId
    ${alloc_streamprb_Ul_SP1}     Get First Value in a Column against Specified Column In File    file=${file_path_Ul_PrbPoolingAllocation_semicolon}
    ...                                  column_name=NumAllocStreamPrb    regex_prereq=1     colum_prereq=SubPoolId
    log to console    NumAllocStreamPrb_SP0= ${alloc_streamprb_Ul_SP0}
    log to console    NumAllocStreamPrb_SP1= ${alloc_streamprb_Ul_SP1}
    Should Be True    ${alloc_streamprb_Ul_SP0}>=${Ul_SP0_Threshold}
    Should Be True    ${alloc_streamprb_Ul_SP1}>=${Ul_SP1_Threshold}

Verify each cell assigned to different csiRsPoolingGroup
    [Documentation]     Check whether each cell is assigned to different csiRsPoolingGroup
    [Arguments]     ${sherpa_output_path}     ${expected_value}
    ${file_path_Dl_PrbPoolingAllocation_semicolon} =      set variable    ${sherpa_output_path}/tcpdump/Dl_PrbPoolingAllocationReport_45_.csv
    ${sherpa_file_range}     Retrieve PRB Pooling Reports Lines within defined range    file_name=${file_path_Dl_PrbPoolingAllocation_semicolon}
    ...                                                        First_Line=10     Last_line=20

    log to console    Check whether each cell is assigned to different csiRsPoolingGroup
    ${num_of_cells_in_csirsgrp0}     Get the length of List of Values in a Column against Specified Column In File
    ...                 file=${sherpa_file_range}
    ...                                  column_name=NRCellid    regex_prereq=0     colum_prereq=csirsPoolingGroupId
    ${num_of_cells_in_csirsgrp1}     Get the length of List of Values in a Column against Specified Column In File
    ...                 file=${sherpa_file_range}
    ...                                  column_name=NRCellid    regex_prereq=1     colum_prereq=csirsPoolingGroupId
    ${num_of_cells_in_csirsgrp2}     Get the length of List of Values in a Column against Specified Column In File
    ...                 file=${sherpa_file_range}
    ...                                  column_name=NRCellid    regex_prereq=2     colum_prereq=csirsPoolingGroupId
    log to console    Number of cells in CSIRS pooling group 0=${num_of_cells_in_csirsgrp0}
    log to console    Number of cells in CSIRS pooling group 1=${num_of_cells_in_csirsgrp1}
    log to console    Number of cells in CSIRS pooling group 2=${num_of_cells_in_csirsgrp2}
    Should Be True    ${num_of_cells_in_csirsgrp0} == ${expected_value}
    Should Be True    ${num_of_cells_in_csirsgrp1} == ${expected_value}
    Should Be True    ${num_of_cells_in_csirsgrp2} == ${expected_value}


Verify each csiRsPoolingGroup has the same number of cells
    [Documentation]     Check whether each cell is assigned to different csiRsPoolingGroup
    [Arguments]     ${sherpa_output_path}
    ${file_path_Dl_PrbPoolingAllocation_semicolon} =      set variable    ${sherpa_output_path}/tcpdump/Dl_PrbPoolingAllocationReport_45_.csv
    ${sherpa_file_range}     Retrieve PRB Pooling Reports Lines within defined range    file_name=${file_path_Dl_PrbPoolingAllocation_semicolon}
    ...                                                        First_Line=10     Last_line=20

    log to console    Check whether each csiRsPoolingGroup should have the same number of cells
    ${num_of_cells_in_csirsgrp0}     Get the length of List of Values in a Column against Specified Column In File
    ...                 file=${sherpa_file_range}
    ...                                  column_name=NRCellid    regex_prereq=0     colum_prereq=csirsPoolingGroupId
    ${num_of_cells_in_csirsgrp1}     Get the length of List of Values in a Column against Specified Column In File
    ...                 file=${sherpa_file_range}
    ...                                  column_name=NRCellid    regex_prereq=1    colum_prereq=csirsPoolingGroupId
    ${num_of_cells_in_csirsgrp2}     Get the length of List of Values in a Column against Specified Column In File
    ...                 file=${sherpa_file_range}
    ...                                  column_name=NRCellid    regex_prereq=2     colum_prereq=csirsPoolingGroupId

    Should Be True     ${num_of_cells_in_csirsgrp0}==${num_of_cells_in_csirsgrp1}
    Should Be True     ${num_of_cells_in_csirsgrp0}==${num_of_cells_in_csirsgrp2}


Get the length of List of Values in a Column against Specified Column In File
    [Documentation]     INTERNAL USAGE
    ...                 Returns the length of the List of Values in a column against Specified Column.
    [Arguments]         ${file}      ${column_name}    ${regex_prereq}=None
    ...                 ${colum_prereq}=None    ${column_filter}=\d*
    ###  DO NOT USE DIRECTLY! ################################
    # Please use keyword       Verify Message presence in csv Files
    SherpaCsvReader.setup reader    ${file}
    # Reactivate for debug
    # Dated Log             Params are:\n${valuetocheck} ${check_operator} ${Column_name} ${regex_prereq} ${colum_prereq}
    @{result_temp}          SherpaCsvReader.check csv column match all match another            ${Column_name}
    ...                     ${regex_prereq}                                 ${colum_prereq}     ${column_filter}
    log to console    ${result_temp}[1]
    ${list_values}=    Get From List    ${result_temp}    1
    ${list_values}=    Remove Duplicates     ${list_values}
    log to console    ${list_values}
    ${len_of_list_values}=     Get Length     ${list_values}
    log to console    NR-Cell-ID ${list_values} belongs to CSI-RS pooling group ${regex_prereq}
    log to console      Number of cells in CSI-RS pooling group ${regex_prereq} is ${len_of_list_values}
    [Return]    ${len_of_list_values}

Verify PM Counter for PRBs AVAL for PDSCH after 1st Cell Deletion
    [Arguments]     ${PM_counter}   ${Expected_Value}
    log to console   Collecting PM Counter now...
    Wait until the next Measurement Period starts
    ${PM_dir_B2_Step7}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    PM_Counters.Check PM counter value bigger than   expected_value=${Expected_Value}  pm_files_location=${PM_dir_B2_Step7}
    ...  pi_id=${PM_counter}    moc=NRCELL-2
	PM_Counters.Check PM counter value bigger than   expected_value=${Expected_Value}   pm_files_location=${PM_dir_B2_Step7}
    ...  pi_id=${PM_counter}    moc=NRCELL-3
    PM_Counters.Check PM counter value bigger than   expected_value=${Expected_Value}   pm_files_location=${PM_dir_B2_Step7}
    ...  pi_id=${PM_counter}    moc=NRCELL-4
Verify PM Counter Total PRBs Used is less than AVAL for all 4 Cells
    [Arguments]     ${PM_counter1}  ${PM_counter2}   ${CapacityThreshold}
    log to console   Collecting PM Counter now...
    Wait until the next Measurement Period starts
    ${PM_dir_B2_Step2}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    ${Cell1_PM_Counter1}=     PM_Counters.Get PM counter value   pm_files_location=${PM_dir_B2_Step2}   pi_id=${PM_counter1}    moc=NRCELL-1
    ${Cell1_PM_Counter2}=     PM_Counters.Get PM counter value   pm_files_location=${PM_dir_B2_Step2}   pi_id=${PM_counter2}    moc=NRCELL-1
    ${Cell2_PM_Counter1}=     PM_Counters.Get PM counter value   pm_files_location=${PM_dir_B2_Step2}   pi_id=${PM_counter1}    moc=NRCELL-2
    ${Cell2_PM_Counter2}=     PM_Counters.Get PM counter value   pm_files_location=${PM_dir_B2_Step2}   pi_id=${PM_counter2}    moc=NRCELL-2
    ${Cell3_PM_Counter1}=     PM_Counters.Get PM counter value   pm_files_location=${PM_dir_B2_Step2}   pi_id=${PM_counter1}    moc=NRCELL-3
    ${Cell3_PM_Counter2}=     PM_Counters.Get PM counter value   pm_files_location=${PM_dir_B2_Step2}   pi_id=${PM_counter2}    moc=NRCELL-3
    ${Cell4_PM_Counter1}=     PM_Counters.Get PM counter value   pm_files_location=${PM_dir_B2_Step2}   pi_id=${PM_counter1}    moc=NRCELL-4
    ${Cell4_PM_Counter2}=     PM_Counters.Get PM counter value   pm_files_location=${PM_dir_B2_Step2}   pi_id=${PM_counter2}    moc=NRCELL-4

    Should Be True      ${Cell1_PM_Counter1}<${Cell1_PM_Counter2}
    Should Be True      ${Cell2_PM_Counter1}<${Cell2_PM_Counter2}
    Should Be True      ${Cell3_PM_Counter1}<${Cell3_PM_Counter2}
    Should Be True      ${Cell4_PM_Counter1}<${Cell4_PM_Counter2}
    Should Be True      ${Cell1_PM_Counter2}+${Cell2_PM_Counter2}+${Cell3_PM_Counter2}+${Cell4_PM_Counter2}<=${CapacityThreshold}

Verify PRB_AVAIL_PDSCH_BB_POOL counter
     [Arguments]    ${expected}
     [Documentation]    the number of available PRBs for a PDSCH should be less but quite close to PRB demand
     log to console     Verify the Number of PRBs available equal to PRB demand
     sleep   300
     ${counter_dl}           Get Counter Value With Admin          M55308C10005
     Should Be True      ${counter_dl}<=${expected}

Verify PM Counter for l1sp1
    [Arguments]     ${PM_counter1}  ${PM_counter2}
    log to console   Collecting PM Counter now...
    Wait until the next Measurement Period starts
    ${PM_dir_B2_Step2}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    ${Cell1_PM_Counter1}=     PM_Counters.Get PM counter value   pm_files_location=${PM_dir_B2_Step2}   pi_id=${PM_counter1}    moc=NRCELL-1
    ${Cell4_PM_Counter1}=     PM_Counters.Get PM counter value   pm_files_location=${PM_dir_B2_Step2}   pi_id=${PM_counter1}    moc=NRCELL-4
    Should Be True      ${Cell1_PM_Counter1}>${Cell4_PM_Counter1}
    log to console  ${PM_counter2}
Verify PM Counter for l1sp2
    [Arguments]     ${PM_counter1}  ${PM_counter2}
    log to console   Collecting PM Counter now...
    Wait until the next Measurement Period starts
    ${PM_dir_B2_Step2}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    ${Cell1_PM_Counter1}=     PM_Counters.Get PM counter value   pm_files_location=${PM_dir_B2_Step2}   pi_id=${PM_counter1}    moc=NRCELL-1
    ${Cell4_PM_Counter1}=     PM_Counters.Get PM counter value   pm_files_location=${PM_dir_B2_Step2}   pi_id=${PM_counter1}    moc=NRCELL-4
    Should Be True      ${Cell1_PM_Counter1}<${Cell4_PM_Counter1}
    log to console  ${PM_counter2}
Verify PRB Requested by BBRM for L1SP GBRandnonGBR
    [Documentation]     Check the number of PRB demanded by L1subpool#1 in UL/DL during a predefined time interval period
    ...                 so that the total PRB demand is higher than the actual PRB capability of SP#1
    [Arguments]     ${sherpa_output_path}    ${subpool_id}    ${prbvalue}
    ${file_path_Dl_PrbPoolingAllocation_semicolon} =      set variable    ${sherpa_output_path}/tcpdump/Dl_PrbPoolingAllocationReport_45_.csv
    ${file_path_Ul_PrbPoolingAllocation_semicolon} =      set variable    ${sherpa_output_path}/tcpdump/Ul_PrbPoolingAllocationReport_45_.csv
    log to console    Verify the number of PRB demanded by BBRM to L1SP${subpool_id}
    log to console    according to the GBR UL and DL Traffic demand of L1SP${subpool_id} during a predefined time interval
    BuiltIn.Log    ${file_path_Dl_PrbPoolingAllocation_semicolon}    console=no
    BuiltIn.Log    ${file_path_Ul_PrbPoolingAllocation_semicolon}    console=no
    ${range_file_dl}     Retrieve PRB Pooling Reports Lines within defined range    file_name=${file_path_Dl_PrbPoolingAllocation_semicolon}
    ...                                                        First_Line=10     Last_line=20
    log to console    Read the number of GBR PRB Requested for SUBPOOLID=${subpool_id} in Downlink
    ${SUBPOOL_0_Prb_Requested_Dl}    Check Values on Operator In File with Prereq    file=${range_file_dl}
    ...                                 column_name=GbrPrbRequest     check_operator=>=     valuetocheck=${prbvalue}
    ...                                 regex_prereq=${subpool_id}        colum_prereq=SubPoolId
    ${Check_SUBPOOL_Prb_Requested_Dl} =     Set Variable If   ${SUBPOOL_0_Prb_Requested_Dl}==True
    ...                                            The number of PRB Requested for SUBPOOL=${subpool_id} in Downlink is equal to ${prbvalue}
    ...                                            ${SUBPOOL_0_Prb_Requested_Dl}==False
    ...                                            The number of PRB Requested for SUBPOOL=${subpool_id} in Downlink is less than ${prbvalue}
    log to console     ${Check_SUBPOOL_Prb_Requested_Dl}
    should be true              ${SUBPOOL_0_Prb_Requested_Dl}==True
    log to console    Read the number of nonGBR PRB Requested for SUBPOOLID=${subpool_id} in Downlink
    ${SUBPOOL_0_nongbr_Requested_Dl}    Check Values on Operator In File with Prereq    file=${range_file_dl}
    ...                                 column_name=nonGbrPrbRequest     check_operator=<=     valuetocheck=${prbvalue}
    ...                                 regex_prereq=${subpool_id}        colum_prereq=SubPoolId
    ${Check_SUBPOOL_nongbr_Requested_Dl} =     Set Variable If   ${SUBPOOL_0_nongbr_Requested_Dl}==True
    ...                                            The number of PRB Requested for SUBPOOL=${subpool_id} in Downlink is equal to ${prbvalue}
    ...                                            ${SUBPOOL_0_nongbr_Requested_Dl}==False
    ...                                            The number of PRB Requested for SUBPOOL=${subpool_id} in Downlink is less than ${prbvalue}
    log to console     ${Check_SUBPOOL_nongbr_Requested_Dl}
    should be true              ${SUBPOOL_0_nongbr_Requested_Dl}==True
    ${range_file_ul}     Retrieve PRB Pooling Reports Lines within defined range    file_name=${file_path_Ul_PrbPoolingAllocation_semicolon}
    ...                                                        First_Line=10     Last_line=20
    log to console    Read the number of GBR PRB Requested for SUBPOOLID=${subpool_id} in Uplink
    ${SUBPOOL_Prb_Requested_Ul}     Check Values on Operator In File with Prereq    file=${range_file_ul}
    ...                                  column_name=GbrPrbRequest    check_operator=>=       valuetocheck=${prbvalue}
    ...                                  regex_prereq=${subpool_id}        colum_prereq=SubPoolId
    ${Check_SUBPOOL_Prb_Requested_Ul} =     Set Variable If   ${SUBPOOL_Prb_Requested_Ul}==True
    ...                                            The number of PRB Requested for SUBPOOL=${subpool_id} in Uplink is greater than ${prbvalue}
    ...                                            ${SUBPOOL_Prb_Requested_Ul}==False
    ...                                            The number of PRB Requested for SUBPOOL=${subpool_id} in Uplink is lower than ${prbvalue}
    should be true              ${SUBPOOL_Prb_Requested_Ul}==True
    log to console     ${Check_SUBPOOL_Prb_Requested_Ul}
    log to console    Read the number of nonGBR PRB Requested for SUBPOOLID=${subpool_id} in Uplink
    ${SUBPOOL_Prb_Requested_Ul}     Check Values on Operator In File with Prereq    file=${range_file_ul}
    ...                                  column_name=nonGbrPrbRequest    check_operator=<=       valuetocheck=${prbvalue}
    ...                                  regex_prereq=${subpool_id}        colum_prereq=SubPoolId
    ${Check_SUBPOOL_Prb_Requested_Ul} =     Set Variable If   ${SUBPOOL_Prb_Requested_Ul}==True
    ...                                            The number of PRB Requested for SUBPOOL=${subpool_id} in Uplink is greater than ${prbvalue}
    ...                                            ${SUBPOOL_Prb_Requested_Ul}==False
    ...                                            The number of PRB Requested for SUBPOOL=${subpool_id} in Uplink is lower than ${prbvalue}
    should be true              ${SUBPOOL_Prb_Requested_Ul}==True
    log to console     ${Check_SUBPOOL_Prb_Requested_Ul}

Verify free PRBs of the L1SP got allocated to the other L1SP
    [Documentation]     Check the free PRBs of the L1 SP#2 are allocated to the L1 SP#1
    ...                 so that the this triggers the inter-L1 SP PRB pooling
    [Arguments]     ${sherpa_output_path}    ${subpool_id1}    ${subpool_id2}
    ${file_path_Dl_PrbPoolingAllocation_semicolon} =      set variable    ${sherpa_output_path}/tcpdump/Dl_PrbPoolingAllocationSubpool_45_.csv
    ${file_path_Ul_PrbPoolingAllocation_semicolon} =      set variable    ${sherpa_output_path}/tcpdump/Ul_PrbPoolingAllocationSubpool_45_.csv
    @{alloc_streamprb_0_dl}=    Create List
    @{alloc_streamprb_1_dl}=    Create List
    @{alloc_streamprb_0_ul}=    Create List
    @{alloc_streamprb_1_ul}=    Create List
    Retrieve PRB Pooling Reports Lines within defined range    file_name=${file_path_Dl_PrbPoolingAllocation_semicolon}
    ...                                                        First_Line=10     Last_line=20
   log to console    Read the number of PRB Requested for SUBPOOLID=${subpool_id1} in Downlink
   log to console    Saved the PRB Requested values in ${file_path_Dl_PrbPoolingAllocation_semicolon}
    ${SUBPOOL0_allocstreamprb_Dl}     Get First Value in a Column against Specified Column In File
	...          file=${file_path_Dl_PrbPoolingAllocation_semicolon}
    ...          column_name=NumAllocStreamPrb    regex_prereq=${subpool_id1}     colum_prereq=SubPoolId
    FOR    ${elem}    IN    ${SUBPOOL0_allocstreamprb_Dl}
      #  Run Keyword If     '${elem}'=='True'     Continue For Loop
        ${elem}   convert to integer    ${elem}
        Append To List    ${alloc_streamprb_0_dl}    ${elem}
    END
    log to console    ${alloc_streamprb_0_dl}

   log to console    Read the number of PRB Requested for SUBPOOLID=${subpool_id2} in Downlink
    ${SUBPOOL1_allocstreamprb_Dl}    Get First Value in a Column against Specified Column In File
    ...    file=${file_path_Dl_PrbPoolingAllocation_semicolon}   column_name=NumAllocStreamPrb
    ...    regex_prereq=${subpool_id2}   colum_prereq=SubPoolId
    FOR    ${elem}    IN    ${SUBPOOL1_allocstreamprb_Dl}
      #  Run Keyword If     '${elem}'=='True'     Continue For Loop
        ${elem}   convert to integer    ${elem}
        Append To List    ${alloc_streamprb_1_dl}    ${elem}
    END
    log to console    ${alloc_streamprb_1_dl}

    Retrieve PRB Pooling Reports Lines within defined range    file_name=${file_path_Ul_PrbPoolingAllocation_semicolon}
    ...                                                        First_Line=10     Last_line=20
   log to console    Read the number of PRB Requested for SUBPOOLID=${subpool_id1} in Uplink
    ${SUBPOOL0_allocstreamprb_Ul}     Get First Value in a Column against Specified Column In File
    ...   file=${file_path_Ul_PrbPoolingAllocation_semicolon}
    ...   file=${file_path_Ul_PrbPoolingAllocation_semicolon}   column_name=NumAllocStreamPrb
    ...   regex_prereq=${subpool_id1}   colum_prereq=SubPoolId
    FOR    ${elem}    IN    ${SUBPOOL0_allocstreamprb_Ul}
      #  Run Keyword If     '${elem}'=='True'     Continue For Loop
        ${elem}   convert to integer    ${elem}
        Append To List    ${alloc_streamprb_0_ul}    ${elem}
    END
    log to console    ${alloc_streamprb_0_ul}

   log to console    Read the number of PRB Requested for SUBPOOLID=${subpool_id2} in Uplink
    ${SUBPOOL1_allocstreamprb_Ul}     Get First Value in a Column against Specified Column In File
     ...   file=${file_path_Ul_PrbPoolingAllocation_semicolon}   column_name=NumAllocStreamPrb
     ...   regex_prereq=${subpool_id2}   colum_prereq=SubPoolId
    FOR    ${elem}    IN    ${SUBPOOL1_allocstreamprb_Ul}
      #  Run Keyword If     '${elem}'=='True'     Continue For Loop
        ${elem}   convert to integer    ${elem}
        Append To List    ${alloc_streamprb_1_ul}    ${elem}
    END
    log to console    ${alloc_streamprb_1_ul}
    Should Be True    ${alloc_streamprb_0_dl} > ${alloc_streamprb_1_dl}
    Should Be True    ${alloc_streamprb_0_ul} > ${alloc_streamprb_1_ul}

sherpa collection and validation when SP1 loaded high
    Start Log    sherpa
    Sleep    1s
    ${sherp_path_tti}    Stop Log     sherpa     test_scenario=Traffic_load_inc_L1SP1
    log to console    ${sherp_path_tti}
	Decode Sherpa pcap    Traffic_load_inc_L1SP1
	Set Global Variable     ${sherpa_output_path}     ${sherp_path_tti}[sherpa]
	Copy Sherpa Files    ${sherpa_output_path}
	log to console    ${sherpa_output_path}
	Calling Panda Extract Csv function    ${sherpa_output_path}
    Check Pooling Interval       ${sherpa_output_path}    40ms    0
    Verify free PRBs of the L1SP got allocated to the other L1SP    ${sherpa_output_path}
    ...                             subpool_id1=0     subpool_id2=1


sherpa collection and validation when SP2 loaded high
    Start Log    sherpa
    Sleep    1s
    ${sherp_path_tti}    Stop Log     sherpa     test_scenario=Traffic_load_inc_L1SP2
    log to console    ${sherp_path_tti}
	Decode Sherpa pcap    Traffic_load_inc_L1SP2
	Set Global Variable     ${sherpa_output_path}     ${sherp_path_tti}[sherpa]
	Copy Sherpa Files    ${sherpa_output_path}
	log to console    ${sherpa_output_path}
	Calling Panda Extract Csv function    ${sherpa_output_path}
    Verify free PRBs of the L1SP got allocated to the other L1SP    ${sherpa_output_path}
    ...                             subpool_id1=1     subpool_id2=0

sherpa collection and validation when both SP loaded equally
	Start Log    sherpa
    Sleep    1s
    ${sherp_path_tti}    Stop Log     sherpa     test_scenario=Traffic_load_equal_L1SP12
    log to console    ${sherp_path_tti}
	Decode Sherpa pcap    Traffic_load_equal_L1SP12
	Set Global Variable     ${sherpa_output_path}     ${sherp_path_tti}[sherpa]
	Copy Sherpa Files    ${sherpa_output_path}
	log to console    ${sherpa_output_path}
	Calling Panda Extract Csv function    ${sherpa_output_path}
    Verify prb allocation when both SPs loaded equally    ${sherpa_output_path}
    ...                             subpool_id1=0     subpool_id2=1

Verify prb allocation when both SPs loaded equally
    [Documentation]     Check the free PRBs of the L1 SP#2 are allocated to the L1 SP#1
    ...                 so that the this triggers the inter-L1 SP PRB pooling
    [Arguments]     ${sherpa_output_path}    ${subpool_id1}    ${subpool_id2}
    ${file_path_Dl_PrbPoolingAllocation_semicolon} =      set variable    ${sherpa_output_path}/tcpdump/Dl_PrbPoolingAllocationSubpool_45_.csv
    ${file_path_Ul_PrbPoolingAllocation_semicolon} =      set variable    ${sherpa_output_path}/tcpdump/Ul_PrbPoolingAllocationSubpool_45_.csv
    @{alloc_streamprb_0_dl}=    Create List
    @{alloc_streamprb_1_dl}=    Create List
    @{alloc_streamprb_0_ul}=    Create List
    @{alloc_streamprb_1_ul}=    Create List
    Retrieve PRB Pooling Reports Lines within defined range    file_name=${file_path_Dl_PrbPoolingAllocation_semicolon}
    ...                                                        First_Line=10     Last_line=20
   log to console    Read the number of PRB Requested for SUBPOOLID=${subpool_id1} in Downlink
   log to console    Saved the PRB Requested values in ${file_path_Dl_PrbPoolingAllocation_semicolon}
    ${SUBPOOL0_allocstreamprb_Dl}     Get First Value in a Column against Specified Column In File
    ...   file=${file_path_Dl_PrbPoolingAllocation_semicolon}   column_name=NumAllocStreamPrb
    ...   regex_prereq=${subpool_id1}   colum_prereq=SubPoolId
    FOR    ${elem}    IN    ${SUBPOOL0_allocstreamprb_Dl}
      #  Run Keyword If     '${elem}'=='True'     Continue For Loop
        ${alloc_streamprb_0_dl}   convert to integer    ${elem}
      #  Append To List    ${alloc_streamprb_0_dl}    ${elem}
    END
    log to console    ${alloc_streamprb_0_dl}

   log to console    Read the number of PRB Requested for SUBPOOLID=${subpool_id2} in Downlink
    ${SUBPOOL1_allocstreamprb_Dl}    Get First Value in a Column against Specified Column In File
    ...   file=${file_path_Dl_PrbPoolingAllocation_semicolon}   column_name=NumAllocStreamPrb
    ...   regex_prereq=${subpool_id2}   colum_prereq=SubPoolId
    FOR    ${elem}    IN    ${SUBPOOL1_allocstreamprb_Dl}
      #  Run Keyword If     '${elem}'=='True'     Continue For Loop
        ${alloc_streamprb_1_dl}   convert to integer    ${elem}
      #  Append To List    ${alloc_streamprb_1_dl}    ${elem}
    END
    log to console    ${alloc_streamprb_1_dl}

    Retrieve PRB Pooling Reports Lines within defined range    file_name=${file_path_Ul_PrbPoolingAllocation_semicolon}
    ...                                                        First_Line=10     Last_line=20
   log to console    Read the number of PRB Requested for SUBPOOLID=${subpool_id1} in Uplink
    ${SUBPOOL0_allocstreamprb_Ul}     Get First Value in a Column against Specified Column In File
    ...   file=${file_path_Ul_PrbPoolingAllocation_semicolon}   column_name=NumAllocStreamPrb
    ...   regex_prereq=${subpool_id1}   colum_prereq=SubPoolId
    FOR    ${elem}    IN    ${SUBPOOL0_allocstreamprb_Ul}
      #  Run Keyword If     '${elem}'=='True'     Continue For Loop
        ${alloc_streamprb_0_ul}  convert to integer    ${elem}
      #  Append To List    ${alloc_streamprb_0_ul}    ${elem}
    END
    log to console    ${alloc_streamprb_0_ul}

   log to console    Read the number of PRB Requested for SUBPOOLID=${subpool_id2} in Uplink
    ${SUBPOOL1_allocstreamprb_Ul}     Get First Value in a Column against Specified Column In File
     ...   file=${file_path_Ul_PrbPoolingAllocation_semicolon}   column_name=NumAllocStreamPrb
     ...    regex_prereq=${subpool_id2}   colum_prereq=SubPoolId
    FOR    ${elem}    IN    ${SUBPOOL1_allocstreamprb_Ul}
      #  Run Keyword If     '${elem}'=='True'     Continue For Loop
        ${alloc_streamprb_1_ul}   convert to integer    ${elem}
     #   Append To List    ${alloc_streamprb_1_ul}    ${elem}
    END
    log to console    ${alloc_streamprb_1_ul}
    Should Be True    700 > ${alloc_streamprb_0_dl} > 500
    Should Be True    700 > ${alloc_streamprb_0_ul} > 500
    Should Be True    700 > ${alloc_streamprb_1_dl} > 500
    Should Be True    700 > ${alloc_streamprb_1_ul} > 500

Verify PRB Requested by BBRM for L1L2SP GBRandnonGBR
    [Documentation]     Check the number of PRB demanded by L1subpool#1 in UL/DL during a predefined time interval period
    ...                 so that the total PRB demand is higher than the actual PRB capability of SP#1
    [Arguments]     ${sherpa_output_path}    ${subpool_id}    ${prbvalue}
    ${file_path_Dl_PrbPoolingAllocation_semicolon} =      set variable    ${sherpa_output_path}/tcpdump/Dl_PrbPoolingAllocationReport_45_.csv
    ${file_path_Ul_PrbPoolingAllocation_semicolon} =      set variable    ${sherpa_output_path}/tcpdump/Ul_PrbPoolingAllocationReport_45_.csv
   log to console    Verify the number of PRB demanded by BBRM to L1SP${subpool_id}
   log to console    according to the GBR UL and DL Traffic demand of L1SP${subpool_id} during a predefined time interval
    BuiltIn.Log    ${file_path_Dl_PrbPoolingAllocation_semicolon}    console=no
    BuiltIn.Log    ${file_path_Ul_PrbPoolingAllocation_semicolon}    console=no
    Retrieve PRB Pooling Reports Lines within defined range    file_name=${file_path_Dl_PrbPoolingAllocation_semicolon}
    ...                                                        First_Line=10     Last_line=20

   log to console    Read the number of GBR PRB Requested for SUBPOOLID=${subpool_id} in Downlink
   log to console    Saved the PRB Requested values in ${file_path_Dl_PrbPoolingAllocation_semicolon}
    ${SUBPOOL_0_Prb_Requested_Dl}    Check Values on Operator In File with Prereq    file=${file_path_Dl_PrbPoolingAllocation_semicolon}
    ...                                 column_name=GbrPrbRequest     check_operator=>=     valuetocheck=${prbvalue}
    ...                 				regex_prereq=${subpool_id}        colum_prereq=SubPoolId
    ${Check_SUBPOOL_Prb_Requested_Dl} =     Set Variable If   ${SUBPOOL_0_Prb_Requested_Dl}==True
    ...                                            The number of PRB Requested for SUBPOOL=${subpool_id} in Downlink is equal to ${prbvalue}
    ...                                            ${SUBPOOL_0_Prb_Requested_Dl}==False
    ...                                            The number of PRB Requested for SUBPOOL=${subpool_id} in Downlink is less than ${prbvalue}
   log to console     ${Check_SUBPOOL_Prb_Requested_Dl}
    should be true              ${SUBPOOL_0_Prb_Requested_Dl}==True
	Dated Log New Line    Read the number of nonGBR PRB Requested for SUBPOOLID=0 in Downlink
   log to console    Saved the PRB Requested values in ${file_path_Dl_PrbPoolingAllocation_semicolon}
    ${SUBPOOL_0_nongbr_Requested_Dl}    Check Values on Operator In File with Prereq    file=${file_path_Dl_PrbPoolingAllocation_semicolon}
    ...                                 column_name=nonGbrPrbRequest     check_operator=>=     valuetocheck=${prbvalue}
    ...                 				regex_prereq=${subpool_id}        colum_prereq=SubPoolId
    ${Check_SUBPOOL_nongbr_Requested_Dl} =     Set Variable If   ${SUBPOOL_0_nongbr_Requested_Dl}==True
    ...                                            The number of PRB Requested for SUBPOOL=${subpool_id} in Downlink is equal to ${prbvalue}
    ...                                            ${SUBPOOL_0_nongbr_Requested_Dl}==False
    ...                                            The number of PRB Requested for SUBPOOL=${subpool_id} in Downlink is less than ${prbvalue}
   log to console     ${Check_SUBPOOL_nongbr_Requested_Dl}
    should be true              ${SUBPOOL_0_nongbr_Requested_Dl}==True
    Retrieve PRB Pooling Reports Lines within defined range    file_name=${file_path_Ul_PrbPoolingAllocation_semicolon}
    ...                                                        First_Line=10     Last_line=20

   log to console    Read the number of GBR PRB Requested for SUBPOOLID=${subpool_id} in Uplink
   log to console    Saved the PRB Requested values in ${file_path_Ul_PrbPoolingAllocation_semicolon}
    ${SUBPOOL_Prb_Requested_Ul}     Check Values on Operator In File with Prereq    file=${file_path_Ul_PrbPoolingAllocation_semicolon}
    ...                                  column_name=GbrPrbRequest    check_operator=>=       valuetocheck=${prbvalue}
    ...                 				 regex_prereq=${subpool_id}        colum_prereq=SubPoolId
    ${Check_SUBPOOL_Prb_Requested_Ul} =     Set Variable If   ${SUBPOOL_Prb_Requested_Ul}==True
    ...                                            The number of PRB Requested for SUBPOOL=${subpool_id} in Uplink is greater than ${prbvalue}
    ...                                            ${SUBPOOL_Prb_Requested_Ul}==False
    ...                                            The number of PRB Requested for SUBPOOL=${subpool_id} in Uplink is lower than ${prbvalue}
    should be true              ${SUBPOOL_Prb_Requested_Ul}==True
   log to console     ${Check_SUBPOOL_Prb_Requested_Ul}
	Dated Log New Line    Read the number of nonGBR PRB Requested for SUBPOOLID=${subpool_id} in Uplink
   log to console    Saved the PRB Requested values in ${file_path_Ul_PrbPoolingAllocation_semicolon}
    ${SUBPOOL_Prb_Requested_Ul}     Check Values on Operator In File with Prereq    file=${file_path_Ul_PrbPoolingAllocation_semicolon}
    ...                                  column_name=nonGbrPrbRequest    check_operator=>=       valuetocheck=${prbvalue}
    ...                 				 regex_prereq=${subpool_id}        colum_prereq=SubPoolId
    ${Check_SUBPOOL_Prb_Requested_Ul} =     Set Variable If   ${SUBPOOL_Prb_Requested_Ul}==True
    ...                                            The number of PRB Requested for SUBPOOL=${subpool_id} in Uplink is greater than ${prbvalue}
    ...                                            ${SUBPOOL_Prb_Requested_Ul}==False
    ...                                            The number of PRB Requested for SUBPOOL=${subpool_id} in Uplink is lower than ${prbvalue}
    should be true              ${SUBPOOL_Prb_Requested_Ul}==True
   log to console     ${Check_SUBPOOL_Prb_Requested_Ul}

Check Pooling Interval
    [Arguments]      ${sherpa_output_path}   ${expected_value}   ${skip}
    &{dict_csv_filter}      Create Dictionary
    ...                     sherpa_csv_file_name=${sherpa_output_path}/tcpdump/${l1l2_csv_file_name}
    ...                     filter_column_name=TEXT
    ...                     filter_by_value=MSGID
    ...                     filter=Dl PrbPoolingAllocationReport
    ...                     sherpa_event_id=45
    ...                     separator=;
    Extract Panda Csv Based On Filter    ${dict_csv_filter}
    Dated Log       extracted csv file name : Dl_PrbPoolingAllocationReport_45_.csv
    Dated Log       expected Pooling Interval : 40ms
    ${found}                Verify value with operator in csv Files for Pooling Interval      CsvName=Dl_PrbPoolingAllocationReport_45_.csv
    ...                     ColumnName=Period                           valuetocheck=${expected_value}
    ...                     check_operator===                                   directory=${sherpa_output_path}
    ...   skip=${skip}
    Dated Log    ${found}
    #$Should be equal         "${found}"     "True"
Verify value with operator in csv Files for Pooling Interval
    [Documentation]     Verify the values in cvs files column issued from sherpa using an operator and a reference value.
    ...                 - The directory parameter indicates where csv files are stored, \
    ...                   usually default value is given by the variable sherpa_output_path
    ...                 - The *valuetocheck* is checked with *check_operator* in column *ColumnName* for all the values from the files named \
    ...                   *CsvName* found in *directory* subdirectories.
    ...                 - Return True if the condition is verified for all the values, False if not.
    [Arguments]    ${CsvName}    ${ColumnName}    ${valuetocheck}   ${check_operator}    ${directory}    ${skip}=0
    ${found} =    Set Variable    False
    @{my_dir} =    OperatingSystem.List Directories In Directory             ${directory}
    FOR    ${dir}    IN     @{my_dir}
        ${found} =    Loop on files    ${dir}               ${CsvName}         Check Values on Operator In File for Pooling Interval
        ...           ${ColumnName}    ${check_operator}    ${valuetocheck}    ${skip}
        Exit For Loop If    "${found}"=="False"
    END
    #Should be equal    "${found}"    "True"
    [Return]           ${found}

Check Values on Operator In File for Pooling Interval
    [Documentation]     INTERNAL USAGE
    ...                 Verify the integer numeric string values in a cvs file generated by sherpa using an operator and a reference value
    ...                 returns True if all of them satisfy the condition, False if not.
    [Arguments]         ${file}    ${Column_name}    ${check_operator}    ${valuetocheck}   ${skip}=0   ${column_filter}=/d*
    ###  DO NOT USE DIRECTLY! ################################
    # Please use keyword       Verify Message presence in csv Files
    SherpaCsvReader.setup reader    ${file}
    BuiltIn.Log          Params are:\n${Column_name} ${check_operator} ${valuetocheck}    console=yes
    @{result_temp}       SherpaCsvReader.check csv column match all    ${Column_name}     ${column_filter}
    ${result}            Set Variable                                  ${True}
    @{values_to_check}   Set Variable     ${result_temp}[1]
    Dated Log            values_to_check is: ${values_to_check}
    FOR    ${elem}    IN    @{values_to_check}
        Run keyword If      '${elem}'=='${skip}'    Continue For Loop
        ${result}           Run keyword If              '${elem}'!=''
        ...                 Check on Operator for Pooling Interval           ${valuetocheck}      ${check_operator}
        ...                 ${elem}
        Exit For Loop If    "${result}"=="${False}"
    END
    Dated Log            Result is: ${result}
    [Return]    ${result}

Check on Operator for Pooling Interval
    [Documentation]     INTERNAL USAGE
    [arguments]    ${valuetotest}      ${operator}    ${val}
    ${result}    Should Be Equal As Strings    ${valuetotest}     ${val}
    Dated Log      ${result}
    [return]    ${result}
    log to console  ${operator}
Register UEs and Trigger NonGBR UL Traffic in Cell
    [Arguments]   ${Start_UE}   ${End_UE}    ${UL_Rate}   ${Traffic_rate}=mbps
    MultiUE Register should be Successful    ${Start_UE}   ${End_UE}
    MultiUE Trigger UL Traffic for SA    ${Start_UE}   ${End_UE}    Traffic_rate=mbps     ul_rate=${UL_Rate}      trf_id=${TRF_ID}
    log to console  ${Traffic_rate}
Register UEs and Trigger GBR UL Traffic in Cell
    [Arguments]   ${Start_UE}   ${End_UE}    ${UL_Rate}   ${Traffic_rate}=mbps
        FOR  ${UE}   IN RANGE   ${Start_UE}   ${End_UE}+${1}
        log to console   ${UE}th GBR UE reg triggering now...
        UE Register should be Successful     ${UE}   gw_id=${UE}
        Run Keyword And Continue On Failure   UE PDU Modfication should be Successful  ${UE}   qosflows_to_add=2
        sleep   3s
        Run Keyword And Continue On Failure   UE PDU Modfication should be Successful  ${UE}   qosflows_to_add=3
        sleep   3s
        Run Keyword And Continue On Failure   UE PDU Modfication should be Successful  ${UE}   qosflows_to_add=4
        sleep   3s
        Run Keyword And Continue On Failure   Trigger VoNR UL Traffic for SA   ${UE}   qfi_id=3   rtp_codec=custom
        Run Keyword And Continue On Failure   Trigger UL Non Bursty Data Traffic for SA   ue_id=${UE}
        ...   Traffic_rate=${Traffic_rate}   ul_rate=${UL_Rate}   qfi_id=4
        sleep   5s
        Run Keyword And Ignore Error   Validate UL GBR Traffic For SA   ue_id=${UE}   ul_rate=${UL_Rate}   qfi_id=4
        log to console  /n Ue${UE} ViNR call Successful
        END
    log to console  ${Traffic_rate}
Validate NGBR UL Traffic
    [Arguments]   ${Start_UE}   ${End_UE}    ${UL_Rate}   ${Traffic_rate}=mbps
    Validate UL Traffic For MultiUE for SA    ${Start_UE}   ${End_UE}   ul_rate=${UL_Rate}
    log to console  ${Traffic_rate}
Validate GBR UL Traffic
    [Arguments]   ${Start_UE}    ${End_UE}    ${UL_Rate}    ${Traffic_rate}=mbps    ${qfi_id}=${QFI_ID}
    Validate UL Traffic For MultiUE for SA     ${Start_UE}     ${End_UE}    ul_rate=${UL_Rate}    qfi_id=4
    log to console  ${Traffic_rate}  ${qfi_id}
Validate GBR DL Traffic
    [Arguments]   ${Start_UE}   ${End_UE}    ${DL_Rate}    ${Traffic_rate}=mbps    ${qfi_id}=${QFI_ID}
    Validate DL Traffic For MultiUE for SA    ${Start_UE}   ${End_UE}    dl_rate=${DL_Rate}    qfi_id=4
    log to console  ${Traffic_rate}  ${qfi_id}
Validate Slot_3_6_8 Muting enabled for Zab cells
    [Arguments]     ${csv_file_path}     ${Exp_SLIV}    ${ZAB_cells}
    [Documentation]    PR: 03804082: [NPI 24R1 0.2.1mMP]TMOUS][M03][5G] Tput is decreased and other KPI are
    ...   impacted after CB009215 activation.
    ...     slowPrbPoolFddFr1EnhCompMode = Value 1 corresponding to 'mute_slot_3_6_8' means PDSCH last symbol muting in
    ...    slot 3 and 6 in even SFNs and slot 8 in odd SFNs is enabled
    log to console   Checking last symbol muting of Slot_3_6_8 when slowPrbPoolFddFr1EnhCompMode is enabled
    ${Result}     check_Last_sym_muting_in_Zab_cells.Slot_3_6_8_Muting_for_Zab_cells      ${csv_file_path}/output_dl_formated.csv
    ...     ${ZAB_cells}     ${Exp_SLIV}
    Should Be True    ${Result} == ${True}

