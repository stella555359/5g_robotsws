*** Settings ***
Documentation     Keywords related to collection and conversion of TTI Traces

Library    OperatingSystem
Library    Collections
Library    String

Library    taf.collectors.l2stream3                                  WITH NAME  l2stream3
Library    taf.converters.twdecoder                                  WITH NAME  tct
Library    python/ttitrace.py                                        WITH NAME  tti_streammode
Library    python/tti_analyzer_framework/tti_extractor_framework.py  WITH NAME  tti_trace_analyzer
Library    python/tti_analyzer_framework/tti_dataframe.py            WITH NAME  tti_dataframe
Library    python/testline_information.py

Resource   testline.robot
Resource   gnb.robot
Resource   connect.robot
Resource   tcpdump.robot
Resource   aashell.robot


*** Variables ***
#Tagged for further improvement -> to capture the values from SCF
${P_console}                   ${False}        # output to console can be enabled via "Set Console Output" from testline.robot
@{DEFAULT_COMPONENTS}          L2Ps
${DEFAULT_TTIFILTER_PROFILE}   Default
${DEFAULT_TTI_DSCP}            0

${TTI_COLLECTION_FAILS_ON_DROPPED_PACKAGES}       ${False}
${TTI_COLLECTION_FAILS_ON_NO_PACKAGES_CAPTURED}   ${False}

&{TTI_TRACE_CFG}    dest_ip=172.16.2.10
...                 trace_port=5678
...                 fronthaul_ip_oam=192.168.2.112
...                 set_static_route=${False}


*** Keywords ***
Collect TTI Traces In Streaming Mode
    [Documentation]
    ...  Collect TTI Traces in Streaming mode for a defined period of time.
    ...  The tti filter is a string of coma separated profiles.
    ...  Check the link for detailed information and allowed values
    ...  https://boamui-onion.dynamic.nsn-net.net/branches/master/cli-docs/tutorial-getL2PsProfileFilterList.html
    ...  e.g.  tti_filter=Default, PUCCH
    ...
    ...    | tti_trace_path     | Directory where TTI Trace is placed |
    ...    | tti_trace_filename | Name of tti trace file |
    ...    | tti_trace_duration | Length of trace capture in seconds      [1.. ]      |
    ...    | gnb_id             | Id of gNB                               [0.. ]      |
    ...    | tti_filter         | String of coma separated profile names              |
    ...    | nr_phy_cell_ids    | NR Physical cell ids                    50,51       |
    ...    | components         | The list of uplane components the logs shall        |
    ...    |                    | be collected for. default is a list containting     |
    ...    |                    | only L2Ps, allowed are L2Ps,L2Lo,L2HiPdcp,L2HiRlc   |
    ...    | event_filter_list  | List or String of comma separated TTI event types to be filtered |
    ...
    ...    *Returns*   Path to the captured TTI trace file
    ...
    [Arguments]  ${tti_trace_path}=None
    ...  ${tti_trace_duration}=10
    ...  ${gnb_id}=${0}
    ...  ${tti_filter}=${DEFAULT_TTIFILTER_PROFILE}
    ...  ${event_filter_list}=${None}
    ...  ${tti_trace_filename}=ttitrace_streaming
    ...  ${nr_phy_cell_ids}=${EMPTY}
    ...  ${dest_ip}=${TTI_TRACE_CFG}[dest_ip]
    ...  ${components}=${DEFAULT_COMPONENTS}

    Start TTI Traces In Streaming Mode
    ...   gnb_id=${gnb_id}
    ...   tti_filter=${tti_filter}
    ...   event_filter_list=${event_filter_list}
    ...   nr_phy_cell_ids=${nr_phy_cell_ids}
    ...   tti_trace_filename=${tti_trace_filename}
    ...   dest_ip=${dest_ip}
    ...   components=${components}

    Sleep  ${tti_trace_duration}s

    Stop TTI Traces In Streaming Mode     tti_trace_filename=${tti_trace_filename}

    RETURN  ${tti_trace_path}/${tti_trace_filename}.pcap


Fail If Internal Trace Is Not Activated
    [Arguments]     ${gnb_id}
    ${oam_session}=    Setup OAM HTTP Session     node_id=${gnb_id}

    ${data}   admin.Get Parameter By Class    class_name=TRBLCADM
    ...                                       parameter_list=${{ ['actInternalTrace'] }}
    ...                                       connection=${oam_session}

    IF   ${data[0]['parameters']['actInternalTrace']} == ${False}
       Fail   The internal traces must be activated first! (TRBLCADM:actInternalTrace)
    END


Start TTI Traces In Streaming Mode
    [Documentation]
    ...  For more detailed information about the tti_filter please check the
    ...  Collect TTI Traces in Streaming mode keyword
    ...
    ...  This keyword is designed to work with classical bts.
    ...    | gnb_id             | Id of gNB                               [0.. ]  |
    ...    | tti_filter         | String of coma separated profile names          |
    ...    | nr_phy_cell_ids    | NR Physical cell ids                    50,51   |
    ...    | tti_trace_filename | the filename to use                             |
    ...    | components         | The list of uplane components the logs shall be collected for  |
    ...    | event_filter_list  | List or String of comma separated TTI event types to be filtered |
    ...
    ...    *Returns*   collector name needed to stop the running collector
    ...
    [Arguments]
    ...  ${gnb_id}=${0}
    ...  ${tti_filter}=${DEFAULT_TTIFILTER_PROFILE}
    ...  ${event_filter_list}=${None}
    ...  ${nr_phy_cell_ids}=${EMPTY}
    ...  ${tti_trace_filename}=ttitrace_streaming
    ...  ${dest_ip}=${TTI_TRACE_CFG}[dest_ip]
    ...  ${components}=${DEFAULT_COMPONENTS}

    Log   BTS Type Identified : ${tl_info.deployment_type(${gnb_id})}

    Log     TTI Traces are forwarded to IP: ${dest_ip}

    ${tti_trace_collector}   Create Collectors And Start Generation Of TTI Trace
    ...   gnb_id=${gnb_id}
    ...   dest_ip=${dest_ip}
    ...   tti_trace_filename=${tti_trace_filename}
    ...   tti_filter=${tti_filter}
    ...   event_filter_list=${event_filter_list}
    ...   nr_phy_cell_ids=${nr_phy_cell_ids}
    ...   components=${components}

    RETURN   ${tti_trace_collector}


Stop TTI Traces In Streaming Mode
    [Documentation]
    ...  The KW stops the running collector and returns the path to the captured TTI trace file.
    ...  The collector is identified by its name given as argument `collector_name` (highly recommended !!!)
    ...  or for backward compatibility reasons by the filename ttitrace_streaming.pcap.
    ...  The output directory and file can be specified using the name parameters
    ...  tti_trace_path and tti_trace_filename respectively.
    ...
    ...  *Note* Works only for Classical TL.
    ...
    ...  | tti_trace_path     | the path where to save the tti traces |
    ...  | tti_trace_filename | the file name of the tti trace |
    ...  | collector_name     | name of the collector, optional argument |
    ...
    ...  *Returns*   Path to the captured TTI trace file
    ...
    [Arguments]  ${collector_name}=${None}  ${tti_trace_path}=${EMPTY}  ${tti_trace_filename}=ttitrace_streaming

    ${dir_tti_trace}=  IF   '${tti_trace_path}'=='${EMPTY}'   Get Testcase Log Directory   ELSE    Set Variable  ${tti_trace_path}

    Stop Generation And Collect TTI Trace   ${collector_name}
    ...   desired_storage_directory=${dir_tti_trace}   desired_file_name=${tti_trace_filename}
    RETURN  ${dir_tti_trace}/${tti_trace_filename}.pcap


Convert TTI Trace From PCAP To Parquet
    [Documentation]
    ...  This keyword convertes TTi traces to Parquet and requires the Library taf.converters.twdecoder,
    ...  Information about TtiTraceDecoder.py, see:
    ...  https://confluence.ext.net.nokia.com/pages/viewpage.action?pageId=1696888323
    ...
    ...  | input_file_path  | Path to the input file (full path with filename) Example ${targed_Dir}/ttitraceStreaming.pcap |
    ...  | output_file_path | Path to the output file |
    ...  | extra_options    | additional options to be passed to TtiTraceDecoder.py script, for possible extra option call |
    ...  |                  | TtiTraceDecoder.py script located in /opt/tti-dec/tti-dec-bin/ without arguments. |
    ...  | stdout_path      | write TtiTraceDecoder.py stdout to a file (full path with filename) |
    ...  | stderr_path      | write TtiTraceDecoder.py stderr to a file (full path with filename) |
    ...
    ...  An output directory with default name “parq” will be created where the parquet files will be stored.
    ...
    [Arguments]  ${input_file_path}  ${output_file_path}=${EMPTY}  ${extra_options}=${EMPTY}    ${stdout_path}=${EMPTY}    ${stderr_path}=${EMPTY}

    ${input_file_path}=   tti_streammode.Add File Ending If Missing   file_path=${input_file_path}
    ...                                                               file_ending=.pcap

    ${output_file_path}=  Determine Output File Path                  input_file_path=${input_file_path}
    ...                                                               output_file_path=${output_file_path}

    ${stdout_path}    Set Variable If    '${stdout_path}'=='${EMPTY}'    ${output_file_path}/tti_2_parq_stdout.log    ${stdout_path}
    ${stderr_path}    Set Variable If    '${stderr_path}'=='${EMPTY}'    ${output_file_path}/tti_2_parq_stderr.log    ${stderr_path}

    tct.Create Twdecoder Converter       name=twconverter
    ...                                  input_file_path=${input_file_path}
    ...                                  tti_trace_decoder_options=parquet --output-directory ${output_file_path} ${extra_options}
    ...                                  stdout_path=${stdout_path}
    ...                                  stderr_path=${stderr_path}

    tct.Convert    name=twconverter


Convert TTI Trace From PCAP To ParquetCsv
    [Documentation]
    ...  This keyword convertes TTi traces to Parquet CSV and requires the Library taf.converters.twdecoder,
    ...  Information about TtiTraceDecoder.py, see:
    ...  https://confluence.ext.net.nokia.com/pages/viewpage.action?pageId=1696888323
    ...
    ...  | input_file_path  | Path to the input file (full path with filename) Example ${targed_Dir}/ttitraceStreaming.pcap |
    ...  | output_file_path | Path to the output file |
    ...  | extra_options    | additional options to be passed to TtiTraceDecoder.py script, for possible extra option call |
    ...  |                  | TtiTraceDecoder.py script located in /opt/tti-dec/tti-dec-bin/ without arguments. |
    ...  | stdout_path      | write TtiTraceDecoder.py stdout to a file (full path with filename) |
    ...  | stderr_path      | write TtiTraceDecoder.py stderr to a file (full path with filename) |
    ...
    [Arguments]  ${input_file_path}  ${output_file_path}=${EMPTY}  ${extra_options}=${EMPTY}    ${stdout_path}=${EMPTY}    ${stderr_path}=${EMPTY}

    ${input_file_path}=   tti_streammode.Add File Ending If Missing   file_path=${input_file_path}
    ...                                                               file_ending=.pcap

    ${output_file_path}=  Determine Output File Path                  input_file_path=${input_file_path}
    ...                                                               output_file_path=${output_file_path}

    ${stdout_path}    Set Variable If    '${stdout_path}'=='${EMPTY}'    ${output_file_path}/tti_2_parqCsv_stdout.log    ${stdout_path}
    ${stderr_path}    Set Variable If    '${stderr_path}'=='${EMPTY}'    ${output_file_path}/tti_2_parqCsv_stderr.log    ${stderr_path}

    tct.Create Twdecoder Converter       name=twconverter
    ...                                  input_file_path=${input_file_path}
    ...                                  tti_trace_decoder_options=parquetCsv --output-directory ${output_file_path} ${extra_options}
    ...                                  stdout_path=${stdout_path}
    ...                                  stderr_path=${stderr_path}

    tct.Convert    name=twconverter

    # Copy excel macro file to easier open csv file
    Run Keyword And Warn On Failure    OperatingSystem.Copy File
    ...    /opt/tti-dec/tti-dec-bin/excelCsvViewer/5G_TTI_Trace.xlsm
    ...    ${output_file_path}/5G_TTI_Trace.xlsm


Convert TTI Trace From PCAP To Data Frame
    [Documentation]
    ...  This keyword converts TTi traces to json then to a pandas data frame and
    ...  requires the library taf.converters.eventdecoder and pandas.
    ...
    ...  | input_file_path | Path to the input file (full Path with Filename) Example ${targed_Dir}/ttitraceStreaming.pcap |
    ...  | events_list | Filter events from the tti trace, leave blank if all events are needed Example: ulTdSchedSubcellData |
    ...  | write_to_pickle | Writes the generated dataframe to a pickle file, the pickle file will have the same name as the input_file_path |
    ...  | eventdecoder_stdout_path | Path to the std_output file (full Path with Filename) Example ${targed_Dir}/ttitraceStreaming.log
    ...
    ...  *Returns*   pandas dataframe object
    ...
    [Arguments]  ${input_file_path}=${EMPTY}    ${events_list}=${EMPTY}  ${write_to_pickle}=${False}  ${filter_json_flag}=${True}
    ...    ${eventdecoder_stdout_path}=${EMPTY}

    IF   '${eventdecoder_stdout_path}'=='${EMPTY}'
        ${target_dir}    testline.Get Testcase Log Directory
        ${eventdecoder_stdout_path}   Set Variable   ${target_dir}${/}ttitraceStreaming_stdout.log
    END

    ${input_file_path}=  tti_streammode.Add File Ending If Missing        file_path=${input_file_path}
    ...                                                                   file_ending=.pcap

    ${df}=  tti_dataframe.Convert TTI Trace To Df
    ...    tti_pcap_file=${input_file_path}
    ...    events_list=${events_list}
    ...    filter_json_flag=${filter_json_flag}
    ...    eventdecoder_stdout_path=${eventdecoder_stdout_path}

    IF    ${write_to_pickle}    tti_dataframe.Write DF To Pickle    df=${df}    target_path=${input_file_path}
    RETURN  ${df}


Convert L2Lo TTI Trace From PCAP To Data Frame
    [Documentation]
    ...  This keyword converts l2lo TTi traces to json then to a pandas data frame and
    ...  requires the Library taf.converters.eventdecoder and pandas.
    ...
    ...  | input_file_path | Path to the input file (full Path with Filename) Example ${targed_Dir}/ttitraceStreaming.pcap |
    ...  | events_list | Filter events from the tti trace, leave blank if all events are needed Example: ulTdSchedSubcellData |
    ...  | write_to_pickle | Writes the generated dataframe to a pickle file, the pickle file will have the same name as the input_file_path |
    ...  | eventdecoder_stdout_path | Path to the std_output file (full Path with Filename) Example ${targed_Dir}/ttitraceStreaming.log
    ...
    ...  *Returns*   pandas dataframe object
    ...
    [Arguments]  ${input_file_path}=${EMPTY}    ${events_list}=${EMPTY}  ${write_to_pickle}=${False}  ${filter_json_flag}=${True}
    ...    ${eventdecoder_stdout_path}=${EMPTY}

    IF   '${eventdecoder_stdout_path}'=='${EMPTY}'
        ${target_dir}    testline.Get Testcase Log Directory
        ${eventdecoder_stdout_path}   Set Variable   ${target_dir}${/}l2lo_ttitraceStreaming_stdout.log
    END

    ${input_file_path}=  tti_streammode.Add File Ending If Missing        file_path=${input_file_path}
    ...                                                                   file_ending=.pcap

    ${df}=  tti_dataframe.Convert TTI L2lo Trace To Df
    ...    tti_pcap_file=${input_file_path}
    ...    events_list=${events_list}
    ...    filter_json_flag=${filter_json_flag}
    ...    eventdecoder_stdout_path=${eventdecoder_stdout_path}

    IF    ${write_to_pickle}    tti_dataframe.Write DF To Pickle    df=${df}    target_path=${input_file_path}

    RETURN  ${df}


Convert TTI Trace From Data Frame To CSV
    [Documentation]
    ...  This keyword converts TTi traces pandas data frame to csv
    ...
    ...  | df                 | the pandas data frame |
    ...  | tti_trace_path     | the path where to store the tti trace file |
    ...  | tti_trace_filename | the tti trace csv filename |
    ...
    ...  *Returns*   path to TTI trace file
    ...
    [Arguments]  ${df}=${EMPTY}    ${tti_trace_path}=${EMPTY}   ${tti_trace_filename}=ttitrace_streaming.csv

    ${dir_tti_trace}=  IF   '${tti_trace_path}'=='${EMPTY}'   Get Testcase Log Directory   ELSE    Set Variable  ${tti_trace_path}

    tti_dataframe.Save Df To CSV    ${df}    csv_file_name=${tti_trace_filename}    folder_path=${dir_tti_trace}/

    # Copy excel macro file to easier open csv file
    Run Keyword And Warn On Failure    OperatingSystem.Copy File
    ...    /opt/tti-dec/tti-dec-bin/excelCsvViewer/5G_TTI_Trace.xlsm
    ...    ${dir_tti_trace}/5G_TTI_Trace.xlsm

    RETURN  ${dir_tti_trace}/${tti_trace_filename}


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
    IF    ${tti_filter}==@{EMPTY}       RETURN
    # rad filter - these rad parameters control the tti trace filtering
    ${rad_tti_filter_list}=    Create List  0x5808FF  0x580900  0x580901  0x580902
    ...                                               0x580903  0x580904  0x580905

    FOR  ${rad_param}  ${tti_filter_value}  IN ZIP  ${rad_tti_filter_list}  ${tti_filter}
        Set Rad Parameter Using Aashell  rad_param=${rad_param}  rad_param_value=${tti_filter_value}
        ...                              gnb_id=${gnb_id}  du_id=${du_id}
    END


Create TTI Trace Collector
    [Documentation]
    ...   This Keyword creates the collector for collecting the TTI traces.
    ...   It delegates the call, depending on the bts type to the keywords
    ...   `Create TTI Trace Collector for classical BTS` and
    ...   See those keywords for a more detailed description on the keyword arguments.
    ...
    [Arguments]   @{}
    ...           ${nr_phy_cell_ids}
    ...           ${dest_ip}
    ...           ${tti_filter}=${DEFAULT_TTIFILTER_PROFILE}
    ...           ${event_filter_list}=${None}
    ...           ${tti_trace_filename}=ttitrace_streaming
    ...           ${gnb_id}=${0}
    ...           ${components}=${DEFAULT_COMPONENTS}

    Fail If Internal Trace Is Not Activated    gnb_id=${gnb_id}

    ${collector}   Create TTI Trace Collector For Classical BTS
    ...   nr_phy_cell_ids=${nr_phy_cell_ids}
    ...   tti_filter=${tti_filter}
    ...   event_filter_list=${event_filter_list}
    ...   dest_ip=${dest_ip}
    ...   tti_trace_filename=${tti_trace_filename}
    ...   gnb_id=${gnb_id}
    ...   components=${components}


    RETURN   ${collector}


Create L2 Stream Config For Classical BTS
    [Arguments]    ${tti_filter}
    ...            ${nr_phy_cell_ids}
    ...            ${component}
    ...            ${event_filter_list}=${None}
    # empty dictionary to select all cells if nr_phy_cell_ids is EMPTY
    ${l2_stream_config_all}=  Create Dictionary      up_sw=${component}

    ${l2_stream_config_1}=    Create Dictionary      nr_phy_cell_ids=${nr_phy_cell_ids}
    ...                                              up_sw=${component}

    ${l2_stream_config}=  Set Variable If  '${nr_phy_cell_ids}'=='${EMPTY}'
    ...                   ${l2_stream_config_all}
    ...                   ${l2_stream_config_1}

    # profile_filter_list is only set for L2Ps
    IF   '${component}'=='L2Ps'
        Set To Dictionary      ${l2_stream_config}      profile_filter_list=${tti_filter}
    END
    IF   $event_filter_list is not None
        Set To Dictionary      ${l2_stream_config}      event_filter_list=${event_filter_list}
    END

    RETURN    ${l2_stream_config}


Create TTI Trace Collector For Classical BTS
    [Documentation]
    ...  This keyword creates a TTI Trace collector
    ...  The keyword accpets the following parameters
    ...
    ...    | gnb_id             | Id of gNB                               [0]                      |
    ...    | tti_trace_filename | Name of the pcap file                                            |
    ...    | dest_ip            | Destination IP where TTI Trace is captured                       |
    ...    | nr_phy_cell_ids    | NR Physical cell ids  50,51                                      |
    ...    | tti_filter         | String of coma separated profile names                           |
    ...    | event_filter_list  | List or String of comma separated TTI event types to be filtered |
    ...    | components         | The list of uplane components the logs shall be collected for    |
    ...    | dscp               | dscp value. Default value is 0                                   |
    ...
    ...    *Returns*  The collector name
    ...
    [Arguments]      ${nr_phy_cell_ids}     ${dest_ip}
    ...              ${tti_trace_filename}=ttitrace_streaming
    ...              ${gnb_id}=${0}
    ...              ${components}=${DEFAULT_COMPONENTS}
    ...              ${tti_filter}=${DEFAULT_TTIFILTER_PROFILE}
    ...              ${event_filter_list}=${None}
    ...              ${dscp}=${DEFAULT_TTI_DSCP}

    ${tti_trace_collector}   Set Variable  l2stream3_${tti_trace_filename}

    ${source_ip_addr}   Get Source IP Address For Classical Bts   node_id=${gnb_id}   node_type=gnb
    ${dest_ip}          Get Target IP Address For Classical Bts   source_ip_address=${source_ip_addr}

    Log To Console   Source IP: ${source_ip_addr} - Destination IP: ${dest_ip}

    ${tcpdump_collector}   Create TCPDump Collector On Backhaul Interface   tti_trace_filename=${tti_trace_filename}
    ...                                                                     ip_addr=${dest_ip}

    ${executor}   Get OAM Webservice Connection For Classical GNB   gnb_id=${gnb_id}
    ${l2_stream_configuration}   Create List

    FOR   ${component}   IN   @{components}
        ${l2_stream_config}   Create L2 Stream Config For Classical BTS   component=${component}
        ...                                                               nr_phy_cell_ids=${nr_phy_cell_ids}
        ...                                                               tti_filter=${tti_filter}
        ...                                                               event_filter_list=${event_filter_list}
        Append To List   ${l2_stream_configuration}   ${l2_stream_config}
    END

    l2stream3.Create SBTS L2stream Collector
    ...   name=${tti_trace_collector}
    ...   webservice=${executor}
    ...   source_ip_addr=${source_ip_addr}
    ...   destination_ip_addr=${dest_ip}
    ...   collector=${tcpdump_collector}
    ...   l2_stream_configuration=${l2_stream_configuration}
    ...   dscp=${dscp}
    ...   start_timeout=120
    ...   stop_timeout=120

    l2stream3.Setup Collectors   names=${tti_trace_collector}
    l2stream3.Set Suite Alias    ${tti_trace_collector}

    RETURN   ${tti_trace_collector}


Create Collectors And Start Generation Of TTI Trace
    [Documentation]
    ...
    ...  This keyword starts the generation of TTI Trace
    ...
    ...  The keyword accpets the following parameters
    ...
    ...    | gnb_id             | Id of gNB               [0.. ]           |
    ...    | tti_trace_filename | Name of the pcap file                    |
    ...    | nr_phy_cell_ids    | NR Physical cell ids    50,51            |
    ...    | dest_ip            | Destination IP where TTI Trace is captured |
    ...    | components         | The list of uplane components the logs shall be collected for  |
    ...    | tti_filter         | String of coma separated profile names   |
    ...    | event_filter_list  | List or String of comma separated TTI event types to be filtered |
    ...
    ...    *Returns*  The collector name
    ...
    [Arguments]  ${tti_trace_filename}   ${nr_phy_cell_ids}  ${dest_ip}
    ...  ${gnb_id}=${0}   ${components}=${DEFAULT_COMPONENTS}
    ...  ${tti_filter}=${DEFAULT_TTIFILTER_PROFILE}
    ...  ${event_filter_list}=${None}

    ${tti_trace_collector}=  Create TTI Trace Collector   tti_trace_filename=${tti_trace_filename}
    ...                                                   tti_filter=${tti_filter}
    ...                                                   event_filter_list=${event_filter_list}
    ...                                                   nr_phy_cell_ids=${nr_phy_cell_ids}
    ...                                                   dest_ip=${dest_ip}
    ...                                                   gnb_id=${gnb_id}
    ...                                                   components=${components}

    l2stream3.Start Collectors    names=${tti_trace_collector}
    RETURN  ${tti_trace_collector}


Start TTI Trace Generation
    [Documentation]
    ...
    ...  This keyword starts the generation of TTI Trace using a given collector name
    ...
    [Arguments]  ${tti_trace_collector_name}
    l2stream3.Start Collectors    names=${tti_trace_collector_name}


Stop TTI Trace Generation
    [Documentation]
    ...
    ...  This keyword stops the generation of TTI Trace using a given collector name
    ...
    [Arguments]  ${tti_trace_collector_name}
    l2stream3.Stop Collectors    names=${tti_trace_collector_name}


Collect TTI Trace And Teardown Collectors
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
    l2stream3.Collect Collectors    names=l2stream3_${desired_file_name}  target_dir=${desired_storage_directory}
    l2stream3.Teardown Collectors    names=${desired_file_name},l2stream3_${desired_file_name}
    Move Trace File To Desired Directory  desired_storage_directory=${desired_storage_directory}  desired_file_name=${desired_file_name}

    Check Tcpdump Output File


Create TCPDump Collector On Backhaul Interface
    [Documentation]
    ...  *Scope* Internal
    ...
    ...  *Returns* Collector name
    ...
    [Arguments]  ${tti_trace_filename}   ${ip_addr}

    ${interface_name}=  Identify Interface With IP  ip=${ip_addr}

    Log  \nIdentified interface for TCP Dump on Test PC is: ${interface_name}   console=${P_console}

    ${collector}=  ttitrace.Create TCP Dump Collector  interface_name=${interface_name}
    ...                                                tti_trace_filename=${tti_trace_filename}
    RETURN    ${collector}


Create TCP Dump Collector
    [Documentation]
    ...  Creates a tcpdump collector as the base for the l2stream3 collector.
    ...  Its collector name is derived from the argument `tti_trace_filename` and defaults to 'ttitrace_streaming'!
    ...
    ...  *Scope* Internal
    ...
    ...  *Returns* tcpdump collector name (=tti_trace_filename!)
    ...
    [Arguments]  ${interface_name}
    ...          ${tti_trace_filename}=ttitrace_streaming

    ${testpc_ssh_config}=  Create Dictionary
    ...     host=${tl.test_pc.default_ssh_connection_details.addr}
    ...     user=${tl.test_pc.default_ssh_connection_details.username}
    ...     password=${tl.test_pc.default_ssh_connection_details.password}

    ${testcase_log_dir}         Get Testcase Log Directory
    ${TCPDUMP_STDOUT_FILE}      Join Path   ${testcase_logdir}   tcpdump_stdout.log
    Set Suite Variable          ${TCPDUMP_STDOUT_FILE}

    tcpdump.Create TCPDump Collector
    ...     name=${tti_trace_filename}
    ...     options=-p -Q in -i ${interface_name} port ${TTI_TRACE_CFG}[trace_port] 2> >(tee >(cat 1>&2) > ${TCPDUMP_STDOUT_FILE})
    ...     executor=${testpc_ssh_config}
    tcpdump.Set Suite Alias     ${tti_trace_filename}
    RETURN    ${tti_trace_filename}


Stop Generation And Collect TTI Trace
    [Documentation]
    ...  *Scope* Internal
    ...
    [Arguments]  ${collector_name}=${None}  ${desired_storage_directory}=${EMPTY}  ${desired_file_name}=ttitrace_streaming
    IF   $collector_name is None
         ${collector_name}   Set Variable   l2stream3_${desired_file_name}
    END
    l2stream3.Stop Collectors    names=${collector_name}
    l2stream3.Collect Collectors    names=${collector_name}  target_dir=${desired_storage_directory}
    # stopping the l2stream3 collector should also stop the underlying tcpdump collector !
    l2stream3.Teardown Collectors    names=${collector_name}
    Move Trace File To Desired Directory  desired_storage_directory=${desired_storage_directory}  desired_file_name=${desired_file_name}

    Check TCPDump Output File


Check Tcpdump Output File
    [Arguments]    ${fail_on_packet_loss}=${TTI_COLLECTION_FAILS_ON_DROPPED_PACKAGES}
    ...            ${fail_on_not_captured_data}=${TTI_COLLECTION_FAILS_ON_NO_PACKAGES_CAPTURED}

    ${tcpdump_output_file_exists}   Run Keyword And Return Status    File Should Exist   ${TCPDUMP_STDOUT_FILE}

    IF    ${tcpdump_output_file_exists}
        ${content}    Get File    ${TCPDUMP_STDOUT_FILE}

        ${captured_packages}   String.Get Regexp Matches   ${content}  ([0-9]+) packets? captured            1
        ${dropped_packages}    String.Get Regexp Matches   ${content}  ([0-9]+) packets? dropped by kernel   1


        IF   len(${captured_packages}) > 0
            ${captured}   Convert To Integer   ${captured_packages[0]}
        ELSE
            ${captured}   Set Variable   ${0}
        END

        IF   len(${dropped_packages}) > 0
            ${dropped}    Convert To Integer   ${dropped_packages[0]}
        ELSE
            ${dropped}    Set Variable   ${0}
        END

        IF   ${dropped} > ${0}
            Log     There where dropped packages!!!   WARN
            IF   ${fail_on_packet_loss}    Fail    TTI Trace collection had packet loss during capturing!
        END

        IF   ${captured} == ${0}
            Log     No packages captured!    WARN
            IF   ${fail_on_not_captured_data}   Fail   TTI Trace collection captured no data!
        END
    END


Move Trace File To Desired Directory
    [Documentation]
    ...  *Scope* Internal
    ...
    [Arguments]  ${desired_storage_directory}  ${desired_file_name}
    Move File  ${desired_storage_directory}/l2stream3_${desired_file_name}/${desired_file_name}/${desired_file_name}.pcap
    ...  ${desired_storage_directory}/${desired_file_name}.pcap
    Remove Directory  ${desired_storage_directory}/l2stream3_${desired_file_name}/  recursive=True


Get OAM Webservice Connection For Classical GNB
    [Documentation]
    ...  *Scope* Internal
    ...
    ...  *Returns* Executor for collector creation
    ...
    [Arguments]  ${gnb_id}
    ${release}=  gnb.Get Release Name  node_id=${gnb_id}
    ${executor_classical}=  Create Dictionary
    ...  host=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.addr}
    ...  user=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.username}
    ...  password=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.password}
    ...  port=443
    ...  release=${release}
    RETURN  ${executor_classical}


Determine Output File Path
    [Documentation]
    ...  *Scope* Internal
    ...
    ...  *Returns* The output file path
    ...
    [Arguments]  ${input_file_path}=${EMPTY}  ${output_file_path}=${EMPTY}
    IF   '${output_file_path}'=='${EMPTY}'
        ${output_file_path}    Generate Default Output File Path  input_file_path=${input_file_path}
    END

    RETURN  ${output_file_path}


Generate Default Output File Path
    [Documentation]
    ...  *Scope* Internal
    ...
    ...  *Returns* The output file path derived from the given `input_file_path`
    ...
    [Arguments]  ${input_file_path}=${EMPTY}
    ${output_file_path}=  Split Path	${input_file_path}
    RETURN  ${output_file_path[0]}


Determine NR Cell IDs
    [Documentation]
    ...  *Scope* Internal
    ...
    ...  *Returns* NR Physical Cell IDs

    [Arguments]  ${nr_phy_cell_ids}
    IF   '${nr_phy_cell_ids}'=='${EMPTY}'
        ${extracted_phy_cell_ids}    Extract Cell Ids If Not Known
    END
    ${nr_phy_cell_ids}=  Set Variable If  '${nr_phy_cell_ids}'=='${EMPTY}'  ${extracted_phy_cell_ids}  ${nr_phy_cell_ids}
    RETURN  ${nr_phy_cell_ids}


Extract Cell Ids If Not Known
    [Documentation]
    ...  *Scope* Internal
    ...
    ...  *Returns* Physical cell IDs from gNodeB
    ...
    ${cell_dist_ids}=   gnb.Get GNB Physical Cell ID
    ${phy_cell_ids}=    Collections.Get Dictionary Values   ${cell_dist_ids}   sort_keys=True
    ${phy_cell_ids}=    Catenate    SEPARATOR=,   @{phy_cell_ids}
    RETURN  ${phy_cell_ids}


Get Source IP Address For Classical BTS
    [Arguments]   ${node_type}=gnb   ${node_id}=${0}

    TRY
        ${admin_source_ip}    Get Source IP Address For Classical BTS From Admin   node_type=${node_type}   node_id=${node_id}
    EXCEPT
        Log    Unable to get source IP from BTS (NRBTS.ngUplane.ipV4AddressDN1) - setting to default 10.0.1.2    level=WARN
        ${admin_source_ip}    Set Variable   10.0.1.2
    END

    RETURN   ${admin_source_ip}


Get Source IP Address For Classical BTS From Admin
    [Arguments]   ${node_type}=gnb   ${node_id}=${0}

    ${oam_alias}    connect.Setup OAM HTTP Session  node_type=${node_type}   node_id=${node_id}

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

    ${_}   ${output}      OperatingSystem.Run And Return Rc And Output    ip route get ${source_ip_address}
    ${matches}            String.Get Regexp Matches    ${output}    src (?:\\d{1,3}\\.){3}\\d{1,3}
    ${_}   ${target_ip}   String.Split String          ${matches}[0]

    RETURN        ${target_ip}
