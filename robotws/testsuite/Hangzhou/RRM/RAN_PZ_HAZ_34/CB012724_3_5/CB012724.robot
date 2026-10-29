# @Time    : 2025/10/21 11:09
# @Author  : Jiao.hu
# @Email   : jiao.hu@nokia-sbell.com
# @Group   : NSB MN RAN RD VRF HAZ3 5
# @File    : CB012724.robot
# @Software: PyCharm
# @Doc     : Some Description
*** Settings ***
Documentation

Suite Setup         Run Keywords    SISO Coam Suite Setup
Suite Teardown      SISO Coam Suite Teardown
Test Setup          Run Keywords    MMW5 Common Case Setup      allowed_faults_ids=4589,1933
...    AND          COAM Commission with scf file    ${COMMON_SCF}    is_pdl_checking_needed=${False}    timeout=900
...    AND          Wait Until Keyword Succeeds    25min    30s    Verify BTS 5G Cells Status Is Normal State
Test Teardown       Run Keywords    Restore PA      AND    MMW5 Common Case Teardown
Force Tags          CRT_TRUNK    PY36

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/feature/CB012724_common_keywords.robot
Library    check_tti.py
Library     taf.collectors.l2stream3    WITH NAME    L2STREAM3
Library     taf.converters.eventdecoder    WITH NAME    EVENTDECODER

*** Variables ***

${if_commissioning}                 False
${COMMON_SCF}                       ${CURDIR}/../../../../../commissionings/HGZ/7_5_UTE5G402T2027/302.xml

*** Test Cases ***
CB012724-H_302_FR1_TDD_SA_DL_UL_grant_HARQ_ACK_BWP_switch_256QAM_with_DynamicAL
    [Documentation]    Author: jiao.hu@nokia-sbell.com
    ...    Init Define: 2025/10/21 11:42
    [Tags]    c302
	#Step1: modify PA FOR CALL
   Set PA for RU-11 CALL
   Modify Parameter On BTS With Activate    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-302    parameter=administrativeState
    ...    value=Locked

	check_tti.wait_until_next_5_min
	Start GNB Ttitrace With Streaming Mode		nr_phy_cell_ids=111
    # Step 2: ue attach Cell312 cell ok

	UE Attach And Traffic With Detach    global_cell_id=312    ul_tp=1M
    ...    dl_tp=10k    duration=4

	${pcap_path}    Stop GNB Ttitrace With Streaming Mode
    check_tti.wait_until_next_5_min    extra_sleep_time=50
  Decoder Tttirace From Pcap To Csv    ${pcap_path}    ${SAVE LOG DIRECTORY}/l2stream3/tcpdump
  ${M55335C00034}    ${M55335C00035}    	${M55335C00036}			check_dtx_cellBwpId_UL
  ...    ${SAVE LOG DIRECTORY}/l2stream3/tcpdump_ul.csv
  ${M55335C00044}      count_and_export_non_dtx_per_sched_1    ${SAVE LOG DIRECTORY}/l2stream3/tcpdump_dl.csv
  ...    ${SAVE LOG DIRECTORY}/l2stream3/tcpdump/non_dtx_with_bwp1.txt    bwp_id=1
  ${M55335C00045}      count_and_export_non_dtx_per_sched_1    ${SAVE LOG DIRECTORY}/l2stream3/tcpdump_dl.csv
  ...    ${SAVE LOG DIRECTORY}/l2stream3/tcpdump/non_dtx_with_bwp2.txt    bwp_id=2
  ${M55335C00046}      count_and_export_non_dtx_per_sched_1    ${SAVE LOG DIRECTORY}/l2stream3/tcpdump_dl.csv
  ...    ${SAVE LOG DIRECTORY}/l2stream3/tcpdump/non_dtx_with_bwp3.txt    bwp_id=3

  Check Counters For H302    M55335C00034=${M55335C00034}    M55335C00035=${M55335C00035}
   ...     M55335C00036=${M55335C00036}     M55335C00044=${M55335C00044}
   ...     M55335C00045=${M55335C00045}     M55335C00046=${M55335C00046}

*** Keywords ***
Start GNB Ttitrace With Streaming Mode
    [Arguments]     ${nr_phy_cell_ids}=    ${up_sw}=L2Ps     ${name}=l2stream3
    [Documentation]    This keyword will collect gnb ttitrace log.
    ...    | Input Parameters | Man. | Description |
    ...    | ${nr_phy_cell_ids} | No | Physical layer cell ID |
    ...    | ${up_sw}       | No | option for capture. Default value is "L2Ps". It can be "L2Ps", "L2Lo", "L2iPdcp", "L2HiRlc"  |
    ...    | ${name}        | No | It can be the same as alias. The default value is l2stream3 |
    ...    Examples(BTS should be Onair and UE attach and data transfer is started. ):
    ...    | Start GNB Ttitrace With Streaming Mode | lcr_cell_id=1,2  | name=myttitrace |
    ...    | ${pacp}=  |  Stop GNB Ttitrace With Streaming Mode  |  save_path=${TEST_LOG_DIRECTORY()} | name=myttitrace |
    ...    or
    ...    | Start GNB Ttitrace With Streaming Mode | | |
    ...    | ${pacp}=  |  Stop GNB Ttitrace With Streaming Mode  |  save_path=${TEST_LOG_DIRECTORY()} |
    ...    | Download Ttitrace Decode Tool  | | |
    ...    | Decoder Tttirace From Pcap To Csv  | pcap_path=${pacp} | output_path_with_tag=${TEST_LOG_DIRECTORY()}nsa_tti |
    @{sw_list}    String.Split String    ${Active_SW_version}    _
	&{asik_vm}=         Create Dictionary
	...    host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
	...    user=Nemuadmin
	...    password=nemuuser
	...    port=443
	...    release=${sw_list[0]}
	${scfc_on_gnb_now}=    Backup Scf     ${SAVE LOG DIRECTORY}      scfc_for_tti.xml
	#${nr_phy_cell_ids}=    Set Variable    111
	${local_ip_addr}=    Set Variable        ${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
	${eth_ip}=      Set Variable    10.57.167.106
  ${eth_port}=    Set Variable    eth0
  @{event_filter_list}    Create List    ULFDSCHEDDATA
    ${l2_stream_config_1}=    Create Dictionary       nr_phy_cell_ids=${nr_phy_cell_ids}     up_sw=${up_sw}    profile_filter_list=PDCCH
    # event_filter_list=ULFDSCHEDDATA
    @{l2_stream_configuration}=    Create List    ${l2_stream_config_1}
	TCPDUMP.Create Tcpdump Collector
	...  name=tcpdump
	...  options=-i ${eth_port} udp and dst ${eth_ip} and dst port 5678
	...  sudo_password=ute
	L2STREAM3.Create Sbts L2stream Collector
	...  name=${name}
	...  destination_ip_addr=${eth_ip}
	...  collector=tcpdump
	...  l2_stream_configuration=${l2_stream_configuration}
	...  webservice=${asik_vm}
    ...  dscp=15
    L2STREAM3.Set Suite Alias    alias=${name}
    CORE.setup_collectors    names=${name}
    CORE.start_collectors    names=${name}
    [Teardown]    Run Keyword And Ignore Error    Run    rm ${scfc_on_gnb_now}

Backup Scf
    [Arguments]    ${log_dir}    ${backup_name}=scfc.xml
    [Documentation]    This keyword is to back up SCF file
    ...    | Input Parameters | Man. | Description |
    ...    | ${log_dir} | Yes | the folder directory to store the scf file |
    ...    | ${backup_name} | No | the saved SCF file name. default:scfc.xml |
    ...    Examples:
    ...    | Backup Scf | /tmp | before_suite |
    ...    | ${scfc_full_path}= | Backup Scf | /tmp | before_suite |
    coam.Setup Admin    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}    alias=back_scf    timeout=60
    coam.Get Current Scf File    local_dir_path=${SAVE LOG DIRECTORY}    file_name=${backup_name}    connection=back_scf    timeout=50
    [Teardown]    Run Keyword And Ignore Error    coam.Teardown    connection=back_scf
    [Return]    ${SAVE LOG DIRECTORY}/${backup_name}

Check Counters For H302
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/09/16 11:28
    [Arguments]    ${M55335C00034}    ${M55335C00035}    ${M55335C00036}    ${M55335C00044}    ${M55335C00045}
    ...     ${M55335C00046}   ${connection}=GNB_OAM
    #check_tti.wait_until_next_5_min    extra_sleep_time=60
    ${h_302_counters}        Catenate    SEPARATOR=    M55335C00033,M55335C00034,M55335C00035,M55335C00036,
    ...    M55335C00037,M55335C00038,M55335C00039,M55335C00040,M55335C00041,M55335C00042,M55335C00043,
    ...    M55335C00044,M55335C00045,M55335C00046,M55335C00047,M55335C00048,
    ...    M55335C00049,M55335C00050,M55335C00051,M55335C00052
    coam.connect_to    name=${connection}
    ${counters}    coam.get_pm_counters    counter_ids=${h_302_counters}
    ...    connection=${connection}
    coam.teardown    connection=${connection}

    # Checkponit1: UL_grant ack for BWP0,BWP4~BWP9,dl_grant_ack for BWP4~BWP9 both equal 0,dl_grant_ack for BWP0 equal 1.
    ${r}    Get Recent Multi Counters Value    ${counters['BTS']['MRBTS-2027']['NRBTS-37572']['NRCELL-312']['PDCCH']}
    Should Be True    ${r['M55335C00037']}==0
    Should Be True    ${r['M55335C00038']}==0
    Should Be True    ${r['M55335C00039']}==0
    Should Be True    ${r['M55335C00040']}==0
    Should Be True    ${r['M55335C00041']}==0
    Should Be True    ${r['M55335C00042']}==0
    Should Be True    ${r['M55335C00033']}==0
    Should Be True    ${r['M55335C00043']}==1
    Should Be True    ${r['M55335C00047']}==0
    Should Be True    ${r['M55335C00048']}==0
    Should Be True    ${r['M55335C00049']}==0
    Should Be True    ${r['M55335C00050']}==0
    Should Be True    ${r['M55335C00051']}==0
    Should Be True    ${r['M55335C00052']}==0
    Should Be True    ${M55335C00034}==${r['M55335C00034']}
    Should Be True    ${M55335C00035}==${r['M55335C00035']}
    Should Be True    ${M55335C00036}==${r['M55335C00036']}
    Should Be True    ${M55335C00044}==${r['M55335C00044']}
    Should Be True    ${M55335C00045}==${r['M55335C00045']}
    Should Be True    ${M55335C00046}==${r['M55335C00046']}

Get Recent Multi Counters Value
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/09/27 20:13
    [Arguments]    ${counters}
    ${counter_values}    Create Dictionary
    ${counter_names}    Get Dictionary Keys    ${counters}
    FOR    ${counter_name}    IN    @{counter_names}
        ${values}    Get Dictionary Values    ${counters['${counter_name}']}
        Set To Dictionary    ${counter_values}    ${counter_name}=${values[-1]}
    END
    [Return]    ${counter_values}

Decoder Tttirace From Pcap To Csv
    [Arguments]    ${pcap_path}      ${output_path_with_tag}       ${decode_format}=excelCsv
    [Documentation]    This keyword will decode pcap file to csv.
    ...    | Input Parameters          | Man. | Description |
    ...    | ${pcap_path}              | Yes  | pcap file path. |
    ...    | ${output_path_with_tag}   | Yes  | Decode output file save path. |
    ...    | ${output_file_format}     |  No  | output file format can be "json", "legacyCsv" or "excelCsv", default is "excelCsv" |
    ...   Example:
    ...    | Start GNB Ttitrace With Streaming Mode | | |
    ...    | some action | | |
    ...    | ${pacp}=  |  Stop GNB Ttitrace With Streaming Mode  |  save_path=${TEST_LOG_DIRECTORY()} |
    ...    | Download Ttitrace Decode Tool  | | |
    ...    | Decoder Tttirace From Pcap To Csv  | pcap_path=${pacp} | output_path_with_tag=${TEST_LOG_DIRECTORY()}nsa_tti |
    EVENTDECODER.Create Eventdecoder Converter    name=converter    input_file_path=${pcap_path}    output_file_format=${decode_format}
    ...    output_file_path=${output_path_with_tag}    excel_csv_options=-w
    EVENTDECODER.Convert    name=converter
    #Is Csv File Generated     ${output_path_with_tag}
    ${path}    ${tag}    Split Path    ${output_path_with_tag}
    #GNB_TTI.Decode Ttitrace File    ${pcap_path}    ${output_path_with_tag}    ${output_file_format}    ${excel_csv_options}    ${conversion_filter}
    [Return]    ${path}

Stop GNB Ttitrace With Streaming Mode
    [Arguments]    ${save_path}=${SAVE LOG DIRECTORY}    ${name}=l2stream3
    [Documentation]    This keyword will stop collect gnb ttitrace log.
    ...    | Input Parameters | Man. | Description |
    ...    | ${save_path}   | No | ttitrace save path. The default value is ${SAVE LOG DIRECTORY}. |
    ...    | ${name}        | No | It should be the same as it set in 'Start GNB Ttitrace With Streaming Mode'. The default value is l2stream3 |
    ...    Example:
    ...    | Start GNB Ttitrace With Streaming Mode | | |
    ...    | some action | | |
    ...    | ${pacp}=  |  Stop GNB Ttitrace With Streaming Mode  |  save_path=${SAVE LOG DIRECTORY} |
    ...    | Download Ttitrace Decode Tool  | | |
    ...    | Decoder Tttirace From Pcap To Csv  | pcap_path=${pacp} | output_path_with_tag=${SAVE LOG DIRECTORY}nsa_tti |
    CORE.stop_collectors    names=${name}
    CORE.collect_collectors    names=${name}     target_dir=${save_path}
    CORE.teardown_collectors    names=${name}
	[Return]    ${save_path}/${name}/tcpdump/tcpdump.pcap
