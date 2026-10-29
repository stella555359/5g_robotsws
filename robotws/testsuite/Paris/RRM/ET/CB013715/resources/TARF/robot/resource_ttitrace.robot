*** Settings ***
Documentation     Keywords related to collection of TTI Traces
...
...  Resources to collect TTI Traces in Streaming mode
...  following variables need to be assigned:
...  | ${gnb_id}         | gnb number from which the TTI trace should be captured, id = 0 if only 1 gnb is configured |
...  | ..                | refer to the __init__.py configuration of the testline |
...  | ${du_id}          | DU id if several DUs are connected to the gNB. If only 1 DU is configured du_id = 0. |
...  | ..                | refer to the __init__.py configuration of the testline |
...  | ${common_unit_id} | ASIK id if several ASIKs are connected to the DU. If only 1 ASIK is configured |
...  | ..                | By default all above values are configured as 0 |
...  | ..                | refer to the __init__.py configuration of the testline |

Library    OperatingSystem
Library    Collections

Library    taf.collectors.l2stream3                                     WITH NAME  l2stream3
Library    taf.converters.eventdecoder                                  WITH NAME  tce
Library    ../python/ttitrace.py                                        WITH NAME  tti_streammode
Library    testsuite/Paris/RRM/ET/resources/common/TtiTrace/python/tti_analyzer_framework/tti_extractor_framework.py  WITH NAME  tti_trace_analyzer
Library    testsuite/Paris/RRM/ET/resources/common/TtiTrace/python/tti_analyzer_framework/tti_dataframe.py            WITH NAME  tti_dataframe
Library    testsuite/Paris/RRM/ET/resources/common/TtiTrace/python/tti_analyzer_framework/set_pandas.py               WITH NAME  set_pandas


Resource   Scenario-Common-Keywords.robot
Resource   connect.robot
Resource   tcpdump.robot
Resource   aashell.robot


*** Variables ***
#Tagged for further improvement -> to capture the values from SCF
${P_console}                   ${False}        # output to console can be enabled via "Set Console Output" from testline.robot
@{DEFAULT_COMPONENTS}          L2Ps
# @{DEFAULT_COMPONENTS}          L2Ps   L2Lo   L2HiPdcp   L2HiRlc
# @{DEFAULT_COMPONENTS}          L2Ps   L2Lo   L2HiRlc
${DEFAULT_TTIFILTER_PROFILE}   Default
${DEFAULT_TTI_DSCP}            0

${TTI_COLLECTION_FAILS_ON_DROPPED_PACKAGES}       ${False}
${TTI_COLLECTION_FAILS_ON_NO_PACKAGES_CAPTURED}   ${False}

&{TTI_TRACE_CFG}    dest_ip=172.16.2.10
...                 trace_port=5678
...                 fronthaul_ip_oam=192.168.2.112
...                 set_static_route=${False}


*** Keywords ***
# robocop: off=unused-argument
# robocop: off=possible-variable-overwriting

Collect TTI Traces in Streaming mode
    [Documentation]
    ...  Collect TTI Traces in Streaming mode for a defined period of time.
    ...  The tti filter is a string of coma separated profiles.
    ...  Check the link for detailed information and allowed values
    ...  https://boamui-onion.dynamic.nsn-net.net/branches/master/cli-docs/tutorial-getL2PsProfileFilterList.html
    ...  e.g.  tti_filter=Default, PUCCH
    ...  WARNING: This filter argument DOES NOT WORK with AIC!!!! Change RAD PARAMS before!
    ...  keyword ->  Update TTI Trace Filter Using Rad Parameters
    ...
    ...
    ...    | tti_trace_path       | Directory where TTI Trace is placed |
    ...    | tti_trace_filename   | Name of tti trace file |
    ...    | tti_trace_duration   | Length of trace capture in seconds      [1.. ]      |
    ...    | gnb_id               | Id of gNB                               [0.. ]      |
    ...    | du_id                | Id of DU                                [0..16]     |
    ...    | tti_filter           | String of coma separated profile names              |
    ...    | nr_phy_cell_ids      | NR Physical cell ids                    50,51       |
    ...    | components           | The list of uplane components the logs shall        |
    ...    |                      | be collected for. default is a list containting     |
    ...    |                      | only L2Ps, allowed are L2Ps,L2Lo,L2HiPdcp,L2HiRlc   |
    ...    |                      | The components names for aic/vran might vary        |
    ...
    [Arguments]  ${tti_trace_path}=None
    ...  ${tti_trace_duration}=10
    ...  ${gnb_id}=${0}
    ...  ${du_id}=${0}
    ...  ${tti_filter}=${DEFAULT_TTIFILTER_PROFILE}
    ...  ${tti_trace_filename}=ttitrace_streaming
    ...  ${nr_phy_cell_ids}=${EMPTY}
    ...  ${dest_ip}=${TTI_TRACE_CFG}[dest_ip]
    ...  ${components}=${DEFAULT_COMPONENTS}

    Start TTI Traces in Streaming mode   gnb_id=${gnb_id}
    ...                                  du_id=${du_id}
    ...                                  tti_filter=${tti_filter}
    ...                                  nr_phy_cell_ids=${nr_phy_cell_ids}
    ...                                  tti_trace_filename=${tti_trace_filename}
    ...                                  dest_ip=${dest_ip}
    ...                                  components=${components}

    Sleep  ${tti_trace_duration}s

    Stop TTI Traces in Streaming mode     tti_trace_filename=${tti_trace_filename}
    [Return]  ${tti_trace_path}/${tti_trace_filename}.pcap

Warn If Internal Trace is not activated
    [Arguments]     ${gnb_id}
    ${oam_session}=    Setup OAM http Session     node_id=${gnb_id}

    ${data}   admin.Get Parameter By Class    class_name=TRBLCADM
    ...                                       parameter_list=${{ ['actInternalTrace'] }}
    ...                                       connection=${oam_session}

    IF   ${data[0]['parameters']['actInternalTrace']} == ${False}
        BuiltIn.Log   The internal traces must be activated first! (TRBLCADM:actInternalTrace)   level=WARN
    END

Start TTI Traces in Streaming mode
    [Documentation]
    ...  For more detailed information about the tti_filter please check the
    ...  Collect TTI Traces in Streaming mode keyword
    ...
    ...  This keyword is designed to work with classical bts and vran bts.
    ...  The tti filter DOES NOT WORK WITH AIC! use RAD parameters
    ...    | gnb_id             | Id of gNB                               [0.. ]  |
    ...    | du_id              | Id of DU                                [0..16] |
    ...    | tti_filter         | String of coma separated profile names          |
    ...    | nr_phy_cell_ids    | NR Physical cell ids                    50,51   |
    ...    | tti_trace_filename | the filename to use                             |
    ...    | up_destIpAddr_aic  | in case of all in cloud destination ip address  |
    ...    | components         | The list of uplane components the logs shall be collected for  |
    ...
    [Arguments]
    ...  ${gnb_id}=${0}
    ...  ${du_id}=${0}
    ...  ${tti_filter}=${DEFAULT_TTIFILTER_PROFILE}
    ...  ${nr_phy_cell_ids}=${EMPTY}
    ...  ${tti_trace_filename}=ttitrace_streaming
    ...  ${dest_ip}=${TTI_TRACE_CFG}[dest_ip]
    ...  ${components}=${DEFAULT_COMPONENTS}


    Warn If Internal Trace is not activated    gnb_id=${gnb_id}

    BuiltIn.Log   BTS Type Identified : ${tl_info.deployment_type(${gnb_id})}

    BuiltIn.Log     TTI Traces are forwarded to IP: ${dest_ip}

    Create collectors and Start Generation of TTI Trace  gnb_id=${gnb_id}
    ...                                                  du_id=${du_id}
    ...                                                  dest_ip=${dest_ip}
    ...                                                  tti_trace_filename=${tti_trace_filename}
    ...                                                  tti_filter=${tti_filter}
    ...                                                  nr_phy_cell_ids=${nr_phy_cell_ids}
    ...                                                  bts_type=${tl_info.deployment_type(${gnb_id})}
    ...                                                  components=${components}


Stop TTI Traces in Streaming mode
    [Documentation]
    ...  With the filename ttitrace_streaming.pcap. The output directory and file can be specified using the name parameters
    ...  tti_trace_path and tti_trace_filename respectively.
    ...  *Note* Works only for Classical TL. Work in progress for cloud coam TLs
    ...
    ...  | tti_trace_path     | the path where to save the tti traces |
    ...  | tti_trace_filename | the file name of the tti trace
    ...
    [Arguments]  ${tti_trace_path}=${EMPTY}  ${tti_trace_filename}=ttitrace_streaming

    ${dir_tti_trace}=  Run Keyword If  '${tti_trace_path}'=='${EMPTY}'   testcase-Keywords.Get testcase log directory
    ...                          ELSE                                    Set Variable  ${tti_trace_path}

    BuiltIn.Log  BTS Type Identified : ${tl_info.deployment_type()}

    Stop Generation and collect TTI Trace  desired_storage_directory=${dir_tti_trace}  desired_file_name=${tti_trace_filename}
    [Return]  ${dir_tti_trace}/${tti_trace_filename}.pcap


Convert pcap to udp
    [Documentation]
    ...  This keyword strips tcp header and converts a pcap to a udp
    ...  The keyword accepts source and target as mandatory arguments.
    ...
    ...  | source     | the path to the pcap file |
    ...  | target     | the path to the destination udp file |
    ...
    [Arguments]  ${source}   ${target}
    OperatingSystem.Run
    ...  tshark -r ${source} --disable-protocol swe --disable-protocol syscom -T fields -e data | perl -0ne's/\n//g;print pack"H*",$_' > ${target}


Convert TTI trace from pcap to excelCsv
    [Documentation]
    ...  This keyword convertes TTi traces to CSV and requires the Library taf.converters.eventdecoder
    ...
    ...  | input_file_path | Path to the input file (full Path with Filename) Example ${targed_Dir}/ttitraceStreaming.pcap |
    ...
    ...  The created files will be saved at the Test Bese Directory.
    ...  The name of the File is <folder Name>_{up/dl} for the uplink and downlink files.
    ...
    ...  Example: if the input is ttitrace_streaming.pcap, the Output Files will be in the same directory
    ...  and called ttitrace_streaming_dl_and_ul.csv and ttitrace_streming.pcap.up.csv

    [Arguments]  ${input_file_path}=${EMPTY}  ${output_file_path}=${EMPTY}  ${options}=-d combineDlAndUl

    ${input_file_path}=   tti_streammode.add File ending if missing   file_path=${input_file_path}
    ...                                                               file_ending=.pcap

    ${output_file_path}=  resource_ttitrace.Determine Output File Path         input_file_path=${input_file_path}
    ...                                                                        output_file_path=${output_file_path}

    tce.Create eventDecoder Converter    name=converter
    ...                                  input_file_path=${input_file_path}
    ...                                  output_file_format=excelCsv
    ...                                  output_file_path=${output_file_path}
    ...                                  excel_csv_options=${options}

    tce.Convert    name=converter

    # Copy excel macro file to easier open csv file
    Run keyword and ignore error    copy file    /opt/tti-dec/tti-dec-bin/excelCsvViewer/5G_TTI_Trace.xlsm
    ...    ${input_file_path}/5G_TTI_Trace.xlsm


Convert TTI trace from pcap to legacyCsv
    [Documentation]
    ...  This keyword convertes TTi traces to CSV and requires the Library taf.converters.eventdecoder
    ...
    ...  | input_file_path | Path to the input file (full Path with Filename) Example ${targed_Dir}/ttitraceStreaming.pcap |
    ...
    ...  The created files will be saved at the Test Bese Directory.
    ...  The name of the File is <folder Name>_{up/dl} for the uplink and downlink files.
    ...
    ...  Example: if the input is ttitrace_streaming.pcap, the Output Files will be in the same directory
    ...  and called ttitrace_streaming_dl_and_ul.csv and ttitrace_streming.pcap.up.csv

    [Arguments]  ${input_file_path}=${EMPTY}  ${output_file_path}=${EMPTY}  ${options}=-d combineDlAndUl

    ${input_file_path}=   tti_streammode.add File ending if missing   file_path=${input_file_path}
    ...                                                               file_ending=.pcap

    ${output_file_path}=  resource_ttitrace.Determine Output File Path         input_file_path=${input_file_path}
    ...                                                                        output_file_path=${output_file_path}

    tce.Create eventDecoder Converter    name=converter
    ...                                  input_file_path=${input_file_path}
    ...                                  output_file_format=legacyCsv
    ...                                  output_file_path=${output_file_path}
    # ...                                  excel_csv_options=${options}

    tce.Convert    name=converter

    # Copy excel macro file to easier open csv file
    Run keyword and ignore error    copy file    /opt/tti-dec/tti-dec-bin/excelCsvViewer/5G_TTI_Trace.xlsm
    ...    ${input_file_path}/5G_TTI_Trace.xlsm


Convert TTI trace from pcap to data frame
    [Documentation]
    ...  This keyword converts TTi traces to json then to a pandas data frame and
    ...  requires the Library taf.converters.eventdecoder and pandas
    ...  | input_file_path | Path to the input file (full Path with Filename) Example ${targed_Dir}/ttitraceStreaming.pcap |
    ...  | events_list | Filter events from the tti trace, leave blank if all events are needed Example: ulTdSchedSubcellData |
    ...  | max_num_events_json | number of  events |
    ...  | write_to_pickle | Writes the generated dataframe to a pickle file, the pickle file will have the same name as the input_file_path |

    [Arguments]  ${input_file_path}=${EMPTY}    ${events_list}=${EMPTY}  ${max_num_events_json}=${200000}    ${write_to_pickle}=${False}
    ...          ${filter_json_flag}=${True}    ${number_rows}=${200000}

    Init Pandas

    ${input_file_path}=  tti_streammode.add File ending if missing        file_path=${input_file_path}
    ...                                                                   file_ending=.pcap

    ${df}=  tti_dataframe.convert_tti_trace_to_df    ${input_file_path}   ${events_list}   filter_json_flag=${filter_json_flag}
    # ...                                              max_num_events_json=${max_num_events_json}

    ${df_head}=     tti_dataframe.head_df    df=${df}    number_rows=${number_rows}
    Run Keyword If  ${write_to_pickle}  tti_dataframe.write_df_to_pickle  df=${df_head}
    ...                                                                   target_path=${input_file_path}

    [Return]  ${df_head}


Convert TTI trace from data frame to csv
    [Documentation]
    ...  This keyword converts TTi traces pandas data frame to csv
    ...
    ...  | df                 | the pandas data frame |
    ...  | tti_trace_path     | the path where to store the tti trace file |
    ...  | tti_trace_filename | the tti trace csv filename |
    ...
    [Arguments]  ${df}=${EMPTY}    ${tti_trace_path}=${EMPTY}   ${tti_trace_filename}=ttitrace_streaming.csv

    set_pandas.init_pandas

    ${dir_tti_trace}=  run keyword if  '${tti_trace_path}'=='${EMPTY}'
    ...     testcase-Keywords.Get testcase log directory
    ...  ELSE
    ...     Set Variable  ${tti_trace_path}

    tti_dataframe.save_df_to_csv    ${df}    csv_file_name=${tti_trace_filename}    folder_path=${dir_tti_trace}/

    # Copy excel macro file to easier open csv file
    Run keyword and ignore error    copy file    /opt/tti-dec/tti-dec-bin/excelCsvViewer/5G_TTI_Trace.xlsm
    ...    ${dir_tti_trace}/5G_TTI_Trace.xlsm

    [Return]  ${dir_tti_trace}/${tti_trace_filename}


Convert L2Lo TTI trace from pcap to data frame
    [Documentation]
    ...  This keyword converts l2lo TTi traces to json then to a pandas data frame and
    ...  requires the Library taf.converters.eventdecoder and pandas
    ...  | input_file_path | Path to the input file (full Path with Filename) Example ${targed_Dir}/ttitraceStreaming.pcap |
    ...  | events_list | Filter events from the tti trace, leave blank if all events are needed Example: ulTdSchedSubcellData |
    ...  | write_to_pickle | Writes the generated dataframe to a pickle file, the pickle file will have the same name as the input_file_path |

    [Arguments]  ${input_file_path}=${EMPTY}    ${events_list}=${EMPTY}  ${write_to_pickle}=${False}  ${filter_json_flag}=${True}

    Init Pandas

    ${input_file_path}=  tti_streammode.add File ending if missing        file_path=${input_file_path}
    ...                                                                   file_ending=.pcap

    ${df}=  tti_dataframe.convert_tti_l2lo_trace_to_df    ${input_file_path}   ${events_list}   filter_json_flag=${filter_json_flag}

    Run Keyword If  ${write_to_pickle}  tti_dataframe.write_df_to_pickle  df=${df}
    ...                                                                   target_path=${input_file_path}

    [Return]  ${df}


Update TTI Trace Filter Using Rad Parameters
    [Documentation]
    ...  This keyword updates the TTI Trace filter using RAD parameters
    ...  Documentation about tti trace filter RAD parameters: https://confluence.ext.net.nokia.com/x/UnXCZ
    ...  The filter consists in a list with 7 elements. The first position is reserved for
    ...  selecting one of the pre-defined profiles. The following 6 are the masks for the tti events.
    ...  Each bit corresponds to one event. 32x6 (bits) are the maximum number of events that fit
    ...  in this filtering mask. The 7 elements of the list will be written to the following RAD parameters:
    ...   0x5808FF  rdComponentBitMapProfile
    ...   0x580900  rdComponentBitMapvector0
    ...   0x580901  rdComponentBitMapvector1
    ...   0x580902  rdComponentBitMapvector2
    ...   0x580903  rdComponentBitMapvector3
    ...   0x580904  rdComponentBitMapvector4
    ...   0x580905  rdComponentBitMapvector5
    ...
    ...  The event IDs can be checked in gnb/itf/L2Log/Du/Ps/Events/Events.tt
    ...  By default (no tti_filter given) pre defined profile 0 is selected which logs all tti events.
    ...  Example of usage to select a predefined profile. This is for profile 0 (default):
    ...
    ...    ${filter_profile_0}=         Create List         1         0         0         0
    ...    ...                                                        0         0         0
    ...    Update TTI Trace Filter Using Rad Parameters  tti_filter=${filter_profile_0}
    ...
    ...  The mask bits can be used to modify (add events to) the selected predefined profile
    ...  If we don't want to use any predifined profile and want to select the events one by one, the first
    ...  position of the list should have the value 0.
    ...  Example of usage filtering only for DLFDSCHEDDATA:
    ...
    ...    ${filter_DLFDSCHEDDATA}=         Create List     0   4194304         0         0
    ...    ...                                                        0         0         0
    ...    Update TTI Trace Filter Using Rad Parameters  tti_filter=${filter_DLFDSCHEDDATA}
    ...
    ...  Note that 4194304 = 0x400000 which is in binary 10000000000000000000000
    ...  Is the mask for the event 22 which is the ID of the DLFDSCHEDDATA
    ...  Some events like the utc time stamp and a few others are always present and cannot be filtered out
    ...  The keyword accpets the following parameters
    ...
    ...    | gnb_id               | Id of gNB                               [0.. ]  |
    ...    | du_id                | Id of DU                                [0..16] |
    ...    | tti_filter           | Filter for TTI Trace                            |
    ...
    [Arguments]   ${tti_filter}=@{EMPTY}  ${gnb_id}=${0}  ${du_id}=${0}

    # no change to RAD parameters if no filter is provided
    Return from Keyword If  ${tti_filter}==@{EMPTY}

    # rad filter - these rad parameters control the tti trace filtering
    ${rad_tti_filter_list}=    Create List  0x5808FF  0x580900  0x580901  0x580902
    ...                                               0x580903  0x580904  0x580905

    FOR  ${rad_param}  ${tti_filter_value}  IN ZIP  ${rad_tti_filter_list}  ${tti_filter}
        Set Rad Parameter Using Aashell  rad_param=${rad_param}  rad_param_value=${tti_filter_value}
        ...                              gnb_id=${gnb_id}  du_id=${du_id}
    END


Identify Destination IP for tti trace capture
    [Documentation]
    ...    This keyword identifies the destination IP i.e. the IP address where the trace is to be collected
    ...
    ...    | bts_type | Bts type (classical/clod) |
    ...    | trace_ip | User desired trace ip, i.e. 10.0.1.1 |
    ...
    ...    *Returns*   The Destination IP where the trace is to be collected

    [Arguments]  ${bts_type}  ${trace_ip}

    Return From Keyword If   '${bts_type}'=='cloud'   ${TTI_TRACE_CFG}[dest_ip]
    ${trace_ip}=     Set Variable if  '${tl.gnbs[${0}].cu.x2c.v4}'=='10.1.1.1'   10.0.1.1   ${trace_ip}
    ${backhaul_ip}=  Set Variable if  '${bts_type}'=='classical' and '${trace_ip}'=='${EMPTY}'  ${tl.gnbs[${0}].cu.x2c.v4}  ${trace_ip}
    Set Test Variable  ${backhaul_ip}
    ${dest_ip}=  set variable if  '${bts_type}'=='classical'  ${backhaul_ip}  ${TTI_TRACE_CFG}[fronthaul_ip_oam]
    [Return]  ${dest_ip}


Create TTI Trace Collector
    [Documentation]
    ...   This Keyword creates the collector for collecting the TTI traces.
    ...   It delegates the call, depending on the bts type to the keywords
    ...   `Create TTI Trace Collector for classical BTS` and
    ...   `Create TTI Trace Collector for AIC on VDU`.
    ...   See those keywords for a more detailed description on the keyword arguments.
    [Arguments]    ${bts_type}
    ...            ${nr_phy_cell_ids}
    ...            ${dest_ip}
    ...            ${tti_filter}=${DEFAULT_TTIFILTER_PROFILE}
    ...            ${dest_port}=${TTI_TRACE_CFG}[trace_port]
    ...            ${tti_trace_filename}=ttitrace_streaming
    ...            ${gnb_id}=${0}
    ...            ${du_id}=${0}
    ...            ${nr_cell_ids}=${1}
    ...            ${components}=${DEFAULT_COMPONENTS}

    ${collector}=   Run Keyword If    '${bts_type}'=='classical'
    ...       Create TTI Trace Collector for classical BTS     nr_phy_cell_ids=${nr_phy_cell_ids}
    ...                                                        tti_filter=${tti_filter}
    ...                                                        dest_ip=${dest_ip}
    ...                                                        tti_trace_filename=${tti_trace_filename}
    ...                                                        gnb_id=${gnb_id}
    ...                                                        components=${components}

    ...   ELSE
    ...       Create TTI Trace Collector for AIC on VDU        gnb_id=${gnb_id}
    ...                                                        du_id=${du_id}
    ...                                                        nr_cell_ids=${nr_cell_ids}
    ...                                                        dest_ip=${dest_ip}
    ...                                                        dest_port=${dest_port}
    ...                                                        tti_trace_filename=${tti_trace_filename}
    ...                                                        components=${components}
    [Return]   ${collector}


Create L2 Stream Config For Classical BTS
    [Arguments]    ${tti_filter}
    ...            ${nr_phy_cell_ids}
    ...            ${component}
    # empty dictionary to select all cells if nr_phy_cell_ids is EMPTY
    ${l2_stream_config_all}=  Create Dictionary      up_sw=${component}

    ${l2_stream_config_1}=    Create Dictionary      nr_phy_cell_ids=${nr_phy_cell_ids}
    ...                                              up_sw=${component}

    ${l2_stream_config}=  Set Variable If  '${nr_phy_cell_ids}'=='${EMPTY}'
    ...                   ${l2_stream_config_all}
    ...                   ${l2_stream_config_1}


    # profile_filter_list is only set for L2Ps
    Run Keyword If   '${component}'=='L2Ps'
    ...     Set To Dictionary      ${l2_stream_config}      profile_filter_list=${tti_filter}

    [Return]    ${l2_stream_config}


Create TTI Trace Collector For Classical BTS
    [Documentation]
    ...  This keyword creates a TTI Trace collector
    ...  The keyword accpets the following parameters
    ...
    ...    | gnb_id               | Id of gNB                               [0] |
    ...    | du_id                | Id of DU                                [0..16] |
    ...    | tti_trace_filename   | Name of the pcap file |
    ...    | bts_type             | Bts type  classical / cloud |
    ...    | dest_ip              | Destination IP where TTI Trace is captured |
    ...    | nr_phy_cell_ids      | NR Physical cell ids  50,51   |
    ...    | tti_filter           | String of coma separated profile names              |
    ...    | components           | The list of uplane components the logs shall be collected for  |
    ...    | dscp                 | dscp value. Default value is 0  |
    ...
    ...    *Returns*  The collector name
    ...
    [Arguments]      ${nr_phy_cell_ids}     ${dest_ip}
    ...              ${tti_trace_filename}=ttitrace_streaming
    ...              ${gnb_id}=${0}
    ...              ${components}=${DEFAULT_COMPONENTS}
    ...              ${tti_filter}=${DEFAULT_TTIFILTER_PROFILE}
    ...              ${dscp}=${DEFAULT_TTI_DSCP}

    ${tti_trace_collector}=  Set variable  l2stream3_${tti_trace_filename}

    ${source_ip_addr}=  resource_ttitrace.Get source IP address for classical bts   node_id=${gnb_id}    node_type=gnb
    ${dest_ip}=         resource_ttitrace.Get target IP address for classical bts   source_ip_address=${source_ip_addr}

    Log To Console     Source IP: ${source_ip_addr} - Destination IP: ${dest_ip}

    ${tcpdump_collector}=   Create TCPDump Collector on backhaul interface   tti_trace_filename=${tti_trace_filename}
    ...                                                                      ip_addr=${dest_ip}

    ${executor}=  resource_ttitrace.Get OAM Webservice connection for Classical gNB    gnb_id=${gnb_id}

    ${l2_stream_configuration}    Create List

    FOR   ${component}  IN   @{components}
        ${l2_stream_config}=    resource_ttitrace.Create L2 Stream Config For Classical BTS    component=${component}
        ...                                                                           nr_phy_cell_ids=${nr_phy_cell_ids}
        ...                                                                           tti_filter=${tti_filter}
        Append To List    ${l2_stream_configuration}    ${l2_stream_config}
    END

    l2stream3.create_sbts_l2stream_collector
    ...  name=${tti_trace_collector}
    ...  webservice=${executor}
    ...  source_ip_addr=${source_ip_addr}
    ...  destination_ip_addr=${dest_ip}
    ...  collector=${tcpdump_collector}
    ...  l2_stream_configuration=${l2_stream_configuration}
    ...  dscp=${dscp}
    l2stream3.setup_collectors    names=${tti_trace_collector}
    l2stream3.Set Suite Alias     ${tti_trace_collector}
    [Return]  ${tti_trace_collector}


Create TTI Trace Collector For AIC on VDU
    [Documentation]
    ...   This keyword creates a TTI Trace collector for AIC VDU
    ...   You can influence, if a static route is set. This is not achieved by a argument
    ...   but by setting the key "set_static_route" of the global dictionary ${TTI_TRACE_CFG} to ${True}
    ...
    ...    | gnb_id               | Id of gNB                               [0.. ] |
    ...    | du_id                | Id of the VDU                          [0..16] |
    ...    | dest_ip              | Destination IP where TTI Trace is captured on TestVM |
    ...    | dest_port            | Destination port on Test VM             [0...1] |
    ...    | tti_trace_filename   | Name of the pcap file |
    ...    | nr_cell_ids          | NR Physical cell ids  50,51   |
    ...    | components           | The list of uplane components the logs shall be collected for  |
    ...
    ...    *Returns*  The collector name
    [Arguments]  ${gnb_id}
    ...          ${du_id}
    ...          ${dest_ip}
    ...          ${dest_port}
    ...          ${tti_trace_filename}=ttitrace_streaming
    ...          ${nr_cell_ids}=None
    ...          ${components}=${DEFAULT_COMPONENTS}


    ${tti_trace_collector}=    Set variable   l2stream3_${tti_trace_filename}

    Run Keyword If   ${TTI_TRACE_CFG}[set_static_route]
    ...    Prepare AIC VDU for TTI Tracing by setting Static Route on VDU     gnb_id=${gnb_id}
    ...                                                                       vdu_id=${du_id}
    ...                                                                       dest_ip_addr=${dest_ip}

    ${vdu_oam}=     Set Variable   ${tl.gnbs[${gnb_id}].dus[${du_id}].oam_http_connection_details}
    ${webservice}=  Create Dictionary           host=${vdu_oam.addr}
    ...                                         user=${vdu_oam.username}
    ...                                         password=${vdu_oam.password}
    ...                                         port=${vdu_oam.port}

    Run Keyword If   '${nr_cell_ids}'!='None'
    ...   BuiltIn.Log   Cell Selection for TTI Trace on AIC not yet supported    WARN

    ${nr_cell_ids}=   Run Keyword If   '${nr_cell_ids}'=='None'
    ...     Set Variable   ${nr_cell_ids}
    ...  ELSE
    ...     Get VDU NRCell DistNames   gnb_id=${gnb_id}   vdu_id=${du_id}

    ${l2_stream_configuration}=  Create List
    FOR   ${component}   IN  @{components}
        ${l2_stream_config}=  Create Dictionary     trace_type=Component
        ...                                         target_component=${component}
        ...                                         nr_cell_dn_list=${nr_cell_ids}
        Append To List  ${l2_stream_configuration}   ${l2_stream_config}
    END

    ${interface}=  testline-Keywords.Identify Interface with IP   ${dest_ip}

    tcpdump.create tcpdump collector
    ...  name=${tti_trace_filename}
    ...  options=-i ${interface} udp and dst ${dest_ip} and dst port ${dest_port}
    ...  sudo_password=ute

    l2stream3.create vdu l2stream collector
    ...  name=${tti_trace_collector}
    ...  webservice=${webservice}
    ...  destination_ip_addr=${dest_ip}
    ...  collector=${tti_trace_filename}
    ...  l2_stream_configuration=${l2_stream_configuration}

    l2stream3.setup_collectors    names=${tti_trace_collector}
    l2stream3.Set Suite Alias     ${tti_trace_collector}
    l2stream3.Set Suite Alias     ${tti_trace_filename}
    Set Suite Variable       ${tti_trace_collector}

    [Return]   ${tti_trace_collector}


Get Static Routes from IPRT
    [Documentation]
    ...   This Keyword fetches the managed object IPRT from the SCF from the vdu oam
    ...   and returns the list of static routes in the format of vdu oam
    ...
    ...   | iprt_dist_name | The dist name to identify the IPRT managed object      |
    ...   | gnb_id               | Id of gNB                               [0.. ]  |
    ...   | vdu_id               | Id of DU                                [0..16] |
    [Arguments]    ${iprt_dist_name}
    ...            ${gnb_id}=${0}
    ...            ${vdu_id}=${0}

    ${oam_alias}=         Connect To OAM DU   gnb_id=${gnb_id}   du_id=${vdu_id}
    ${iprt_params}=       Get Managed Object Parameters of Current Plan   dist_name=${iprt_dist_name}
    ...                                                                   vdu_connection=${oam_alias}
    ${static_routes}=     Get Static Route Parameters   ${iprt_params}

    [Return]              ${static_routes}
    [Teardown]            Disconnect from OAM DU    gnb_id=${gnb_id}   du_id=${vdu_id}


Check if recommissioning of Static Routes is required
    [Documentation]
    ...   Checks if the given static route matches the expected dest_ipo_addr and gateway
    ...
    ...   | static_routes | The current setting of static route from SCF      |
    ...   | dest_ip_addr  | The expected destination ip for static route      |
    ...   | gateway       | The expected gateway for the static route setting |
    [Arguments]    ${static_routes}
    ...            ${dest_ip_addr}
    ...            ${gateway}

    ${number_of_routes}=    Get Length    ${static_routes}

    Return From Keyword If    ${number_of_routes}==${0}                                ${True}
    Return From Keyword If    '${static_routes[0]["gateway"]}'!='${gateway}'           ${True}
    Return From Keyword If    '${static_routes[0]["destIpAddr"]}'!='${dest_ip_addr}'   ${True}

    [Return]   ${False}


Create collectors and Start Generation of TTI Trace
    [Documentation]
    ...
    ...  This keyword starts the generation of TTI Trace
    ...
    ...  The keyword accpets the following parameters
    ...
    ...    | gnb_id             | Id of gNB               [0.. ]           |
    ...    | du_id              | Id of DU                [0..16]          |
    ...    | tti_trace_filename | Name of the pcap file                    |
    ...    | nr_phy_cell_ids    | NR Physical cell ids    50,51            |
    ...    | bts_type           | Bts type   :             classical/cloud |
    ...    | dest_ip            | Destination IP where TTI Trace is captured |
    ...    | components         | The list of uplane components the logs shall be collected for  |
    ...    | tti_filter         | String of coma separated profile names   |

    ...
    ...    *Returns*  The collector name
    ...
    [Arguments]  ${tti_trace_filename}   ${bts_type}  ${nr_phy_cell_ids}  ${dest_ip}
    ...  ${gnb_id}=${0}  ${du_id}=${0}   ${components}=${DEFAULT_COMPONENTS}
    ...  ${tti_filter}=${DEFAULT_TTIFILTER_PROFILE}

    ${tti_trace_collector}=  Create TTI Trace Collector   tti_trace_filename=${tti_trace_filename}
    ...                                                   bts_type=${bts_type}
    ...                                                   tti_filter=${tti_filter}
    ...                                                   nr_phy_cell_ids=${nr_phy_cell_ids}
    ...                                                   dest_ip=${dest_ip}
    ...                                                   dest_port=${TTI_TRACE_CFG}[trace_port]
    ...                                                   gnb_id=${gnb_id}
    ...                                                   du_id=${du_id}
    ...                                                   components=${components}

    l2stream3.start_collectors    names=${tti_trace_collector}
    [Return]  ${tti_trace_collector}


Start TTI Trace generation
    [Documentation]
    ...
    ...  This keyword starts the generation of TTI Trace using a given collector name
    ...
    [Arguments]  ${tti_trace_collector_name}
    l2stream3.start_collectors    names=${tti_trace_collector_name}

Stop TTI Trace generation
    [Documentation]
    ...
    ...  This keyword stops the generation of TTI Trace using a given collector name
    ...
    [Arguments]  ${tti_trace_collector_name}
    l2stream3.stop_collectors    names=${tti_trace_collector_name}


Collect TTI Trace and teardown collectors
    [Documentation]
    ...
    ...  This keyword collects the TTI Trace generated and tearsdown the collector
    ...
    ...  | desired_storage_directory  | Path to trace storage directory            |
    ...  | desired_file_name          | Desired file name of the ttitrace :        |
    ...  | ...                        | (should be identical with the name used in |
    ...  | ...                        | keyword Create TTI Trace Collector)        |
    ...
    [Arguments]  ${desired_storage_directory}=${EMPTY}  ${desired_file_name}=ttitrace_streaming
    l2stream3.collect_collectors    names=l2stream3_${desired_file_name}  target_dir=${desired_storage_directory}
    l2stream3.teardown_collectors    names=${desired_file_name},l2stream3_${desired_file_name}
    resource_ttitrace.Move Trace File to Desired Directory  desired_storage_directory=${desired_storage_directory}
    ...                                                     desired_file_name=${desired_file_name}


Create TCPDump Collector on backhaul interface
    [Documentation]
    ...  *Scope* Internal
    ...
    ...  *Returns* Collector name
    ...
    [Arguments]  ${tti_trace_filename}   ${ip_addr}

    ${interface_name}=  testline-Keywords.Identify Interface with IP  ip=${ip_addr}

    BuiltIn.Log  \nIdentified interface for TCP Dump on Test PC is: ${interface_name}   console=${P_console}

    ${collector}=  resource_ttitrace.Create TCP Dump Collector  interface_name=${interface_name}
    ...                                                         tti_trace_filename=${tti_trace_filename}
    [Return]    ${collector}


Create TCP Dump Collector
    [Documentation]
    ...  *Scope* Internal
    ...
    ...  *Returns* TTI trace file name
    ...
    [Arguments]  ${interface_name}
    ...          ${tti_trace_filename}=ttitrace_streaming

    ${testpc_ssh_config}=  Create Dictionary
    ...     host=${tl.test_pc.default_ssh_connection_details.addr}
    ...     user=${tl.test_pc.default_ssh_connection_details.username}
    ...     password=${tl.test_pc.default_ssh_connection_details.password}

    ${testcase_log_dir}         testcase-Keywords.Get testcase log directory
    ${TCPDUMP_STDOUT_FILE}      Join Path   ${testcase_logdir}   tcpdump_stdout.log
    Set Suite Variable          ${TCPDUMP_STDOUT_FILE}

    tcpdump.create_tcpdump_collector
    ...     name=${tti_trace_filename}
    # ...     options=-i ${interface_name} port ${TTI_TRACE_CFG}[trace_port]
    ...     options=-p -Q in -i ${interface_name} port ${TTI_TRACE_CFG}[trace_port] 2> >(tee >(cat 1>&2) > ${TCPDUMP_STDOUT_FILE})
    ...     executor=${testpc_ssh_config}
    tcpdump.set_suite_alias     ${tti_trace_filename}
    [RETURN]    ${tti_trace_filename}

Stop Generation And Collect TTI Trace
    [Documentation]
    ...  *Scope* Internal
    ...
    [Arguments]  ${desired_storage_directory}=${EMPTY}  ${desired_file_name}=ttitrace_streaming
    l2stream3.stop_collectors    names=l2stream3_${desired_file_name}
    l2stream3.collect_collectors    names=l2stream3_${desired_file_name}  target_dir=${desired_storage_directory}
    l2stream3.teardown_collectors    names=${desired_file_name},l2stream3_${desired_file_name}
    resource_ttitrace.Move Trace File to Desired Directory  desired_storage_directory=${desired_storage_directory}
    ...                                                     desired_file_name=${desired_file_name}

    Check tcpdump output file

Check Tcpdump Output File
    [Arguments]    ${fail_on_packet_loss}=${TTI_COLLECTION_FAILS_ON_DROPPED_PACKAGES}
    ...            ${fail_on_not_captured_data}=${TTI_COLLECTION_FAILS_ON_NO_PACKAGES_CAPTURED}

    ${tcpdump_output_file_exists}   Run Keyword and return Status    File Should Exist   ${TCPDUMP_STDOUT_FILE}

    IF    ${tcpdump_output_file_exists}
        ${content}    Get File    ${TCPDUMP_STDOUT_FILE}

        ${captured_packages}   Get Regexp Matches   ${content}  ([0-9]+) packets captured            1
        ${dropped_packages}    Get Regexp Matches   ${content}  ([0-9]+) packets dropped by kernel   1

        ${captured}   Convert To Integer   ${captured_packages[0]}
        ${dropped}    Convert To Integer   ${dropped_packages[0]}

        IF   ${dropped} > ${0}
            Log     There where dropped packages!!!   WARN
            IF   ${fail_on_packet_loss}    Fail    TTI Trace collection had packet loss during capturing!
        END

        IF   ${captured} == ${0}
            Log     No packages captured!    WARN
            IF   ${fail_on_not_captured_data}   Fail   TTI Trace collection captured no data!
        END
    END


Move Trace File to Desired Directory
    [Documentation]
    ...  *Scope* Internal
    ...
    [Arguments]  ${desired_storage_directory}  ${desired_file_name}
    Move file  ${desired_storage_directory}/l2stream3_${desired_file_name}/${desired_file_name}/${desired_file_name}.pcap
    ...  ${desired_storage_directory}/${desired_file_name}.pcap
    Remove Directory  ${desired_storage_directory}/l2stream3_${desired_file_name}/  recursive=True

Get OAM Webservice connection for Classical gNB
    [Documentation]
    ...  *Scope* Internal
    ...
    ...  *Returns* Executor for collector creation
    ...
    [Arguments]  ${gnb_id}
    # ${release}=  gnb.Get release name  node_id=${gnb_id}
    ${executor_classical}=  Create Dictionary
    ...  host=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.addr}
    ...  user=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.username}
    ...  password=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.password}
    ...  port=443
    # ...  release=${release}
    [Return]  ${executor_classical}

Get OAM Webservice connection for Cloud gNB
    [Documentation]
    ...  *Scope* Internal
    ...
    ...  *Returns* The executor for cloud coam
    ...
    [Arguments]  ${gnb_id}  ${du_id}
    ${du_host_ip}=   gnb_lib.Get GNB DU Host IP   ${tl.gnbs[${gnb_id}].dus[${du_id}]}
    ${executor_cloud_coam}=  Create Dictionary
    ...  host=${du_host_ip}
    ...  user=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.username}
    ...  password=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.password}
    ...  port=443
    [Return]  ${executor_cloud_coam}

Get source IP address TO REMOVE
    [Documentation]
    ...  *Scope* Internal
    ...
    ...  *Returns* Source IP
    ...
    [Arguments]    ${gnb_id}=${0}  ${du_id}=${0}  ${comu_id}=${0}
    ${asik_alias}=    connect.Connect to Node Common Unit  node_id=${gnb_id}  du_id=${du_id}  comu_id=${comu_id}
    ${raw_ip}=  ssh.execute  ip -o -4 addr show | grep [b,f][p,r][0,1]  connection=${asik_alias}
    ${source_ip}=  tti_streammode.get source IP address  raw_ip=${raw_ip}
    [return]  ${source_ip}

Determine Output File Path
    [Documentation]
    ...  *Scope* Internal
    ...
    ...  *Returns* The output file path
    ...
    [Arguments]  ${input_file_path}=${EMPTY}  ${output_file_path}=${EMPTY}
    ${output_file_path}=  Run Keyword If   '${output_file_path}'=='${EMPTY}'
    ...           resource_ttitrace.Generate default output file path  input_file_path=${input_file_path}
    ...  ELSE  Set Variable  ${output_file_path}
    [Return]  ${output_file_path}

Generate default output file path
    [Documentation]
    ...  *Scope* Internal
    ...
    ...  *Returns* The output file path derived from the given `input_file_path`
    ...
    [Arguments]  ${input_file_path}=${EMPTY}
    ${output_file_path}=  Split Path	${input_file_path}
    [Return]  ${output_file_path[0]}

Determine NR Cell IDs
    [Documentation]
    ...  *Scope* Internal
    ...
    ...  *Returns* NR Physical Cell IDs

    [Arguments]  ${nr_phy_cell_ids}
    ${extracted_phy_cell_ids}=  Run Keyword If  '${nr_phy_cell_ids}'=='${EMPTY}'  resource_ttitrace.Extract Cell Ids if not known
    ${nr_phy_cell_ids}=  Set Variable If  '${nr_phy_cell_ids}'=='${EMPTY}'  ${extracted_phy_cell_ids}  ${nr_phy_cell_ids}
    [Return]  ${nr_phy_cell_ids}

Extract Cell Ids if not known
    [Documentation]
    ...  *Scope* Internal
    ...
    ...  *Returns* Physical cell IDs from gNodeB
    ...
    ${cell_dist_ids}=   Scenario-Common-Keywords.Get gNB Physical Cell ID From Classical
    ${phy_cell_ids}=    Collections.Get Dictionary Values   ${cell_dist_ids}   sort_keys=True
    ${phy_cell_ids}=    Catenate    SEPARATOR=,   @{phy_cell_ids}
    [Return]  ${phy_cell_ids}

Process TTI Traces for all scenarios
    FOR    ${collector}    IN    @{collector_names}
        BuiltIn.log    processing tti traces for collector: ${collector}
        ${status}=    run keyword and return status    Convert TTI Traces to CSV  collector=${collector}
        run keyword if    not ${status}    BuiltIn.log    Convert TTI Traces to CSV failed in ${collector} FAILED!    level=ERROR
        ${status}=    run keyword and return status    Convert TTI Traces to filtered JSON    collector=${collector}
        run keyword if    not ${status}    BuiltIn.log    Convert TTI Traces to filtered JSON in ${collector} FAILED!    level=ERROR
        ${status}=    run keyword and return status    resource_ttitrace.Convert TTI Traces using ReaderEvtDec and store    collector=${collector}
        run keyword if    not ${status}    BuiltIn.log    Convert TTI Traces using ReaderEvtDec and store in ${collector} FAILED!    level=ERROR
        ${status}=   run keyword and return status   resource_ttitrace.Convert TTI Traces to Dataframe and store as pickle    collector=${collector}
        run keyword if    not ${status}    BuiltIn.log    Convert TTI Traces to Dataframe and store as pickle in ${collector} FAILED!    level=ERROR
    END


Convert TTI Traces to CSV
    [Arguments]  ${collector}  ${size_per_file_bytes}=${30000000}
    Return from keyword if    '${logs_and_traces_flags['TTITrace']['conversion']['excelCsv']}'=='False'
    ${file_size_bytes}=  Get File Size  ${ts_log_dir}/tti_trace_${collector}/ttitrace_streaming.pcap
    ${num_of_splits}=  Evaluate  int(math.ceil(float(${file_size_bytes})/float(${size_per_file_bytes})))  math
    log to console  TTI Trace will be split into ${num_of_splits} files
    Run Keyword if  ${num_of_splits}>${1}  Split and convert PCAP Files to CSV
    ...  collector=${collector}
    ...  num_of_splits=${num_of_splits}
    ...  size_per_file_bytes=${size_per_file_bytes}  ELSE  Convert unsplit file from pcap to csv  collector=${collector}


Split and convert PCAP Files to CSV
    [Arguments]  ${collector}  ${num_of_splits}  ${size_per_file_bytes}
    Prepare and split pcap to smaller files
    ...  collector=${collector}
    ...  size_per_file_bytes=${size_per_file_bytes}
    Convert split pcap file to csv  collector=${collector}  num_of_splits=${num_of_splits}


Convert split pcap file to csv
    [Arguments]  ${collector}  ${num_of_splits}
    Log to console  Converting TTI Trace to excel CSV: 1/${num_of_splits}
    Run keyword and continue on failure  run Keyword  resource_ttitrace.Convert TTI trace from pcap to excelCsv
    ...  input_file_path=${ts_log_dir}/tti_trace_${collector}/ttitrace_streaming_split.pcap
    ...  output_file_path=${ts_log_dir}/tti_trace_${collector}/tti_trace_split_0
    FOR  ${split_itr}  IN RANGE  1  ${num_of_splits}
        Run keyword and continue on failure  run Keyword  resource_ttitrace.Convert TTI trace from pcap to excelCsv
        ...  input_file_path=${ts_log_dir}/tti_trace_${collector}/ttitrace_streaming_split.pcap${split_itr}
        ...  output_file_path=${ts_log_dir}/tti_trace_${collector}/tti_trace_split_${split_itr}
        Log to console  Converting TTI Trace to excel CSV: ${split_itr + ${1}}/${num_of_splits}
    END

Get Source IP Address For Classical BTS
    [Arguments]   ${node_type}=gnb   ${node_id}=${0}

    TRY
        ${admin_source_ip}    Get Source IP Address For Classical BTS From Admin   node_type=${node_type}   node_id=${node_id}
    EXCEPT
        BuiltIn.Log    Unable to get source IP from BTS (NRBTS.ngUplane.ipV4AddressDN1) - setting to default 10.0.1.2    level=WARN
        ${admin_source_ip}    Set Variable   10.0.1.2
    END

    RETURN   ${admin_source_ip}


Get Source IP Address For Classical BTS From Admin
    [Arguments]   ${node_type}=gnb   ${node_id}=${0}

    ${oam_alias}    connect.Setup OAM Http session  node_type=${node_type}   node_id=${node_id}

    ${data}=   admin.Get Parameter By Class
    ...                        class_name=NRBTS
    ...                        parameter_list=${{ ['ngUplane.ipV4AddressDN1'] }}
    ...                        connection=${oam_alias}

    ${data}=   admin.Get Parameter By Dist Name
    ...                        dist_name=${data[0]['parameters']['ngUplane'][0]['ipV4AddressDN1']}
    ...                        parameter_list=${{ ['localIpAddr'] }}
    ...                        connection=${oam_alias}

    RETURN    ${data[0]['parameters']['localIpAddr']}

Get Target IP Address For Classical Bts
    [Arguments]    ${source_ip_address}

    TRY
        ${trace_ip}=     Set Variable if  '${tl.gnbs[${0}].cu.x2c.v4}'=='10.1.1.1'   10.0.1.1   ${tl.gnbs[${0}].cu.x2c.v4}
        ${target_ip}     Set Variable   ${trace_ip}
        ${backhaul_ip}=  Set Variable if  '${trace_ip}'=='${EMPTY}'  ${tl.gnbs[${0}].cu.x2c.v4}  ${trace_ip}
        Set Test Variable  ${backhaul_ip}
    EXCEPT
        ${rc}   ${output}     Run And Return Rc And Output    ip route get ${source_ip_address}
        ${matches}            Get Regexp Matches    ${output}    src (?:\\d{1,3}\\.){3}\\d{1,3}
        ${_}   ${target_ip}   Split String          ${matches}[0]
    END

    RETURN     ${target_ip}

Convert unsplit file from pcap to csv
    [Arguments]  ${collector}
    Run keyword and continue on failure  run Keyword  Convert TTI trace from pcap to excelCsv
    ...  input_file_path=${ts_log_dir}/tti_trace_${collector}/ttitrace_streaming.pcap
    ...  output_file_path=${ts_log_dir}/tti_trace_${collector}/tti_trace_${collector}


Prepare and split pcap to smaller files
    [Arguments]  ${collector}  ${size_per_file_bytes}
    ${tti_source_file}=  Set variable  ${ts_log_dir}/tti_trace_${collector}/ttitrace_streaming.pcap
    ${tti_split_destination_file}=  Set variable  ${ts_log_dir}/tti_trace_${collector}/ttitrace_streaming_split.pcap
    ${size_per_file_MB}=  Evaluate  int(${size_per_file_bytes}/${1000000})
    Split PCAP File  source_path=${tti_source_file}  destination_split_path=${tti_split_destination_file}
    ...  size_per_split_MB=${size_per_file_MB}


Split PCAP File
    [Arguments]  ${source_path}  ${destination_split_path}  ${size_per_split_MB}
    OperatingSystem.Run   tcpdump -r ${source_path} -w ${destination_split_path} -C ${size_per_split_MB}


Convert TTI Traces to filtered JSON
    [Arguments]  ${collector}
    Return from keyword if    '${logs_and_traces_flags['TTITrace']['conversion']['filtered_json']}'=='False'
    Run keyword and continue on failure  Extract TTI Trace and Convert to JSON
    ...  path_to_tti_trace_pcap=${ts_log_dir}/tti_trace_${collector}/ttitrace_streaming.pcap
    ...  target_directory=${ts_log_dir}/tti_trace_${collector}


Convert TTI Traces to Dataframe and store as pickle
    [Arguments]  ${collector}
    Return from keyword if    '${logs_and_traces_flags['TTITrace']['collection']}'=='False'
    Return from keyword if    '${logs_and_traces_flags['TTITrace']['conversion']['pickled_df']}'=='False'
    Run keyword and continue on failure  Extract TTI Trace and Convert to Pickle
    ...  path_to_tti_trace_pcap=${ts_log_dir}/tti_trace_${collector}/ttitrace_streaming.pcap
    ...  ttitracepath=${ts_log_dir}/tti_trace_${collector}/
    ...  event_nr_max=${logs_and_traces_flags['TTITrace']['conversion']['ReaderEvtDec_event_nr_max']}

Convert TTI Traces using ReaderEvtDec and store
    [Arguments]  ${collector}
    Return from keyword if    '${logs_and_traces_flags['TTITrace']['collection']}'=='False'
    Return from keyword if    '${logs_and_traces_flags['TTITrace']['conversion']['ReaderEvtDec']}'=='False'
    ${tm}     Get Current Date
    ${tm}=    Remove String    ${tm.replace(' ','-')}    .
    ${path_to_tti_trace_pcap}=       set variable     ${ts_log_dir}/tti_trace_${collector}/ttitrace_streaming.pcap
    ${desired_storage_directory}=    set variable     ${ts_log_dir}/tti_trace_${collector}/
    Run keyword and continue on failure    tti_streammode.decode_tti_traces_using_TtitraceReaderEvtDec
    ...  desired_storage_directory=${desired_storage_directory}
    ...  num_of_events=${logs_and_traces_flags['TTITrace']['conversion']['ReaderEvtDec_event_nr_max']}
    Run Keyword And Ignore Error   OperatingSystem.Run
    ...                                 cp ${desired_storage_directory}/msg_all.csv ${desired_storage_directory}/msg-all-${tm}.csv

