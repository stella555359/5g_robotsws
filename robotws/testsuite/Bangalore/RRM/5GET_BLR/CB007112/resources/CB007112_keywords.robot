*** Settings ***
Documentation    :copyright: Nokia
...              :authors: Sowrabha.S.M
...              :contact: sowrabha.s_m@nokia.com
Variables      ta5g_global_var
Resource       taf/rfrl/common_resources/robot/libraries_instances.robot
Resource       ../../resources/robot/common_log_collection.robot
Resource       pandas_common.resource
Resource       ../../resources/robot/BBpooling_MuMIMO.robot
Resource       ../../resources/robot/WTS_Runner_BF_CA_HO_Keywords.robot
Library       ../../resources/python/avg_dl_data.py
Resource       ../../5GC000937/resources/5GC000937_Keywords.robot
Library         ute_admin                         WITH NAME   ute_adm
Library        taf.collectors.btslog  WITH NAME   btslog
Library        Collections
Library        OperatingSystem
Library        ta5g_tshark
Library        ta5g_commissioning
Library        taf.analyzer.pdml     WITH NAME    taf_pdml_analyser
Library        taf.transport.ssh                 WITH NAME    csn
Library        SSHLibrary
Library        check_prballocation.py


*** Variables ***
${NOKIA_LOGIN}  toor4nsn
${NOKIA_PASS}   oZPS0POrRieRtu
${GNB_IP}     192.168.255.129
${AP_IP}     192.168.200.1
${WTS.Connection}
${WTS_DIR}          /opt/iphy/latest
${WTS.Ip}           127.0.0.1
${ENB_ID}           1
${GNB_ID}           2
${st_ue_id}         11
${en_ue_id}         14
${pdu_id}           1
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1



#Variables for TC 5GC001227-A-B6 CsirsPoolingGroupId check
@{FIELDS_cell_cellsetupreq}              physCellId     csirsPoolingGroupId

#Variables for TC 5GC001227-A-B5 PRB limitation check
${csv_file_name_dlStat}     macro__dlStat.csv
${csv_file_name_ulStat}     macro__ulStat.csv
${expected_MAX_PRB_DL}         106
${expected_MAX_PRB_UL}         94
${operator_compare}            >=
${column_name}              MAX PRB


${l1l2_csv_file_name}                 micro__l1l2Trace.csv
${DL_Pooling_Sherpa_Msg}              Dl PrbPoolingAllocationReport
${UL_Pooling_Sherpa_Msg}              Ul PrbPoolingAllocationReport
${DL_Pooling_Csv_Extracted}           Dl_PrbPoolingAllocationReport_45_.csv
${UL_Pooling_Csv_Extracted}           Ul_PrbPoolingAllocationReport_45_.csv
${DL_MinPrb_Expected}                 48
${UL_MinPrb_Expected}                 36

#Variables for TC 5GC001227-A-B8-B9 Round Robin check
@{UL_Pooling_Report}      Ul PrbPoolingAllocationReport(45)
@{DL_Pooling_Report}      Dl PrbPoolingAllocationReport(45)
${Regexp_UL_Subcell0_Selected}       (Type.UL,Mode.RR).*(NRCellid=0x4001).*(PrbAllocated.67).*
${Regexp_UL_Subcell1_Selected}       (Type.UL,Mode.RR).*(NRCellid=0x4003).*(PrbAllocated.67).*
${Regexp_UL_Subcell0_NoSelected}     (Type.UL,Mode.RR).*(NRCellid=0x4001).*(PrbAllocated.36).*
${Regexp_UL_Subcell1_NoSelected}     (Type.UL,Mode.RR).*(NRCellid=0x4003).*(PrbAllocated.36).*
${Regexp_DL_Subcell0_Selected}       (Type.DL,Mode.RR).*(NRCellid=0x4001).*(PrbAllocated.106).*
${Regexp_DL_Subcell1_Selected}       (Type.DL,Mode.RR).*(NRCellid=0x4003).*(PrbAllocated.106).*
${Regexp_DL_Subcell0_NoSelected}     (Type.DL,Mode.RR).*(NRCellid=0x4001).*(PrbAllocated.101).*
${Regexp_DL_Subcell1_NoSelected}     (Type.DL,Mode.RR).*(NRCellid=0x4003).*(PrbAllocated.101).*

#Variables for TC 5GC001227-B Metric Based checks
*** Keywords ***
Load CFG Config and make cells on-air
    [Arguments]    ${wts_cfg_file}
    Fetch board type
    Configure UTE ETH3 IPs
    Wait Until Keyword Succeeds    5min    20sec     Check gNB Airscale is Ready - ${BBoard_Type}
    ${oam_alias}=    Setup OAM session
    Wait Until Keyword Succeeds    10min    20sec    Verify Single Radio is Online      connection=${oam_alias}
    ${file_name}    set variable     NODECPRT_GNB_cellsetup.pcap
    set Suite variable      ${file_name}
    Check gNB Airscale is Ready - ${BBoard_Type}
#    Run keyword and ignore error    Start Collecting Syslog    NAME=cell_setup
#    run keyword if     '${BBoard_Type}'=='ASOE'     CPRT Monitoring Start ASOE
#    ...    ELSE        Start CPRT Trace Capturing
    Log To console     loading cfg file
    Start WTS Using WTS_Runner      ${wts_cfg_file}
#    run keyword if     '${BBoard_Type}'=='ASOE'     CPRT Monitoring Stop Collect ASOE      ${LOG_PATH}
#    ...    ELSE        Stop CPRT capture     ${CaptureCPRT}
#    run keyword and ignore error    run keyword if     '${BBoard_Type}'=='ASOE'     Move File
#	...     ${LOG_PATH}/SYSCOM_NODECPRT_GNB.pcap    ${LOG_PATH}/${file_name}
#    ...    ELSE        Move File      ${LOG_PATH}/NODECPRT_GNB.pcap    ${LOG_PATH}/${file_name}
#    run keyword and ignore error    run keyword if     '${BBoard_Type}'=='ASOE'     Move File
#    ...    ${LOG_PATH}/External_NODECPRT_GNB.pcap
#    ...     ${LOG_PATH}/External_NODECPRT_GNB_cellsetup.pcap
#    log to console     ${file_name}
#    Run keyword and ignore error     Stop Collecting Syslog     NAME=cell_setup

Add routes
    [Documentation]    This keyword is to configure VM interfaces..
    Run    sudo ip addr add 10.0.1.132/24 dev eth3
    Run    sudo ip addr add 10.0.1.133/24 dev eth3
    Run    sudo ip addr add 10.0.1.131/24 dev eth3
    Run    sudo ip addr add 10.0.1.134/24 dev eth3
    Run    sudo ip addr add 10.0.1.135/24 dev eth3
    Run    sudo ip addr add 10.0.1.136/24 dev eth3
    Run    sudo ip addr add 10.0.1.99/24 dev eth3
    Run    sudo ip addr add 10.0.1.121/24 dev eth3
    Run    sudo ip addr add 10.0.1.137/24 dev eth3
    Run    sudo ip addr add 10.0.1.3/24 dev eth3
    Run    sudo ip addr add 10.0.1.4/24 dev eth3
    Run    sudo ip addr add 10.0.1.61/24 dev eth3
    Run    sudo ip addr add 10.0.1.62/24 dev eth3
    Run    sudo ip addr add 10.0.1.138/24 dev eth3
    Run    sudo ip addr add 10.0.1.139/24 dev eth3
    Run    sudo ip addr add 10.0.1.140/24 dev eth3
    Run    sudo ip addr add 10.0.1.141/24 dev eth3


Set SRS Beam Position for muMIMO for UE pairing
    Set Srs beam position    profile_id=1     quad_pos=0    sub_quad_pos=0
	Activate MIMO profile    ue_id=1     profile_id=1
    Set Srs beam position    profile_id=2     quad_pos=2    sub_quad_pos=3
	Activate MIMO profile    ue_id=2     profile_id=2
    Set Srs beam position    profile_id=5     quad_pos=0    sub_quad_pos=3
	Activate MIMO profile    ue_id=5     profile_id=5
    Set Srs beam position    profile_id=6     quad_pos=2    sub_quad_pos=0
	Activate MIMO profile    ue_id=6     profile_id=6
    Set Srs beam position    profile_id=9     quad_pos=0    sub_quad_pos=0
	Activate MIMO profile    ue_id=9     profile_id=9
    Set Srs beam position    profile_id=10     quad_pos=2    sub_quad_pos=3
	Activate MIMO profile    ue_id=10     profile_id=10
    Set Srs beam position    profile_id=3     quad_pos=1    sub_quad_pos=1
	Activate MIMO profile    ue_id=3     profile_id=3
    Set Srs beam position    profile_id=4     quad_pos=3    sub_quad_pos=0
	Activate MIMO profile    ue_id=4     profile_id=4
    Set Srs beam position    profile_id=7     quad_pos=1    sub_quad_pos=3
	Activate MIMO profile    ue_id=7     profile_id=7
    Set Srs beam position    profile_id=8     quad_pos=3    sub_quad_pos=0
	Activate MIMO profile    ue_id=8     profile_id=8
    Set Srs beam position    profile_id=11     quad_pos=1    sub_quad_pos=1
	Activate MIMO profile    ue_id=11     profile_id=11
    Set Srs beam position    profile_id=12     quad_pos=3    sub_quad_pos=0
	Activate MIMO profile    ue_id=12     profile_id=12

Attach four SA UEs in cell and trigger traffic
    [Arguments]   ${start_ue_id}    ${end_ue_id}   ${DL_rate}    ${UL_rate}
    FOR  ${UE}   IN RANGE    ${start_ue_id}     ${end_ue_id}+1
            UE Register should be Successful    ${UE}
            MultiUE Trigger DL Traffic for SA with mutiple traffic id   ${UE}   ${UE}    Traffic_rate=mbps     dl_rate=${DL_rate}
            ...   ul_rate=${UL_rate}   pdu_id=1     trf_id=1     qfi_id=1
    END

MultiUE Trigger DL Traffic for SA with mutiple traffic id
    [Arguments]     ${start_ue_id}    ${end_ue_id}    ${Traffic_rate}    ${dl_rate}   ${ul_rate}  ${pdu_id}=${Pdu_session_ID}
    ...     ${trf_id}=${TRF_ID}    ${qfi_id}=${QFI_ID}
    [Documentation]    This keyword starts the DL Traffic for the SA variant
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
        Log to Console    \nRunning DL Traffic for ${dl_rate} ${Traffic_rate}...${qfi_id}
        Trigger high tput for each UE    UE=${ue_idx}    DL_Rate=${dl_rate}     DL_Max_TRFID=2
        Trigger UL Data Traffic for SA    ue_id=${ue_idx}    Traffic_rate=mbps     ul_rate=${ul_rate}     pdu_id=${pdu_id}
        ...   trf_id=${TRFID}
	END

Trigger high tput for each UE
    [Arguments]     ${UE}    ${DL_Rate}   ${DL_Max_TRFID}
    FOR  ${TRFID}  IN RANGE   1   ${DL_Max_TRFID}+1
        Trigger DL Data Traffic for SA    ue_id=${UE}    Traffic_rate=mbps     dl_rate=${DL_Rate}     pdu_id=${Pdu_session_ID}
        ...   trf_id=${TRFID}
        sleep   5s
    END

Verify DL Tput For all the UEs connected in all cells
    [Arguments]     ${start_ue_id}    ${end_ue_id}
    FOR  ${UEID}  IN RANGE   ${start_ue_id}    ${end_ue_id}+1
	    log to console     verify UE tput for UE${UEID}
        ${UE_tput}=    Get AVG DL DATA TRAFFIC For Given CC    ue_id=${UEID}    scell_idx=0    unit=Mbps
        Should Be True    ${UE_tput} > ${150}
	END

Create cellprb Dictionary
    [Arguments]   ${cellid}   ${prb_in_c4}   ${ch_bw}
    ${Dict1}   Create Dictionary
    ${len}   Get Length    ${cellid}
    FOR    ${i}    IN RANGE   ${len}
         ${temp}   create list    ${prb_in_c4}[${i}]    ${ch_bw}[${i}]
         Set To Dictionary   ${Dict1}    ${cellid}[${i}]    ${temp}
    END
    [Return]   &{Dict1}

Verify cell dlprballocation
    [Arguments]   ${csv_file_path}  ${cellid}   ${prb_in_c4}   ${ch_bw}   ${subcell}
    ${all_prb}   Create cellprb Dictionary   ${cellid}   ${prb_in_c4}    ${ch_bw}
    ${Result}   check_prballocation.Check_dlallocatedprb    ${csv_file_path}   ${all_prb}   ${subcell}
    [Return]   ${Result}

Verify cell ulprballocation
    [Arguments]   ${csv_file_path}  ${cellid}   ${prb_in_c4}   ${ch_bw}
    ${all_prb}    Create cellprb Dictionary    ${cellid}   ${prb_in_c4}    ${ch_bw}
    ${Result}   check_prballocation.Check_ulallocatedprb    ${csv_file_path}    ${all_prb}
    [Return]   ${Result}

Validate cell dlprballocation from TTI traces
    [Arguments]   ${csv_file_path}  ${cellid}   ${prb_in_c4}   ${ch_bw}   ${subcell}
    ${Check}   Verify cell dlprballocation    ${csv_file_path}/output_dl_formated.csv    ${cellid}   ${prb_in_c4}    ${ch_bw}   ${subcell}
    run keyword and continue on failure   Run Keyword if   ${Check}!=${True}   Fail   prb allocation is not matching

Validate cell ulprballocation from TTI traces
    [Arguments]   ${csv_file_path}  ${cellid}   ${prb_in_c4}   ${ch_bw}
    ${Check1}  Verify cell ulprballocation   ${csv_file_path}/output_ul_formated.csv    ${cellid}   ${prb_in_c4}    ${ch_bw}
    run keyword and continue on failure   Run Keyword if   ${Check1}!=${True}   Fail  prb allocation is not matching

Copy Sherpa Files
    [Arguments]    ${sherpa_output_path}
    @{pcap_files}                  OperatingSystem.List Files In Directory     ${sherpa_output_path}        *.csv
    Create Directory               ${sherpa_output_path}/tcpdump
    FOR    ${file}    IN     @{pcap_files}
        Dated Log                  Moving file ${file}
        run                        mv ${sherpa_output_path}/${file} ${sherpa_output_path}/tcpdump
    END

#Check MinPRB Allocation
#    [Arguments]      ${sherpa_output_path}   ${expected_value}   ${skip}
#    &{dict_csv_filter}      Create Dictionary
#    ...                     sherpa_csv_file_name=${sherpa_output_path}/tcpdump/${l1l2_csv_file_name}
#    ...                     filter_column_name=TEXT
#    ...                     filter_by_value=MSGID
#    ...                     filter=Dl PrbPoolingAllocationReport
#    ...                     sherpa_event_id=45
#    ...                     separator=;
#    Extract Panda Csv Based On Filter    ${dict_csv_filter}
#    Dated Log       extracted csv file name : Dl_PrbPoolingAllocationReport_45_.csv
#    Dated Log       expected min PRB value : 48
#    ${found}                Sherpa.Verify value with operator in csv Files      CsvName=Dl_PrbPoolingAllocationReport_45_.csv
#    ...                     ColumnName=NumMinPrbAlloc                           valuetocheck=${expected_value}
#    ...                     check_operator===                                   directory=${sherpa_output_path}
#    ...   skip=${skip}
#    Should be equal         "${found}"     "True"

Check ZAB Privilige
    [Arguments]      ${sherpa_output_path}   ${expected_value}
    &{dict_csv_filter}      Create Dictionary
    ...                     sherpa_csv_file_name=${sherpa_output_path}/tcpdump/${l1l2_csv_file_name}
    ...                     filter_column_name=TEXT
    ...                     filter_by_value=MSGID
    ...                     filter=Dl PrbPoolingAllocationReport
    ...                     sherpa_event_id=45
    ...                     separator=;
    Extract Panda Csv Based On Filter    ${dict_csv_filter}
    Dated Log       extracted csv file name : Dl_PrbPoolingAllocationReport_45_.csv
    Dated Log       ZAB Privilege : 1
    ${found}                Sherpa.Verify value with operator in csv Files      CsvName=Dl_PrbPoolingAllocationReport_45_.csv
    ...                     ColumnName=ZAB Privilege                            valuetocheck=${expected_value}
    ...                     check_operator===                                   directory=${sherpa_output_path}
    Should be equal         "${found}"       "True"
