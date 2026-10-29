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

Library    taf.collectors.l2stream3                                  WITH NAME  l2stream3
Library    taf.converters.eventdecoder                               WITH NAME  tce
Library    python/ttitrace.py                                        WITH NAME  tti_streammode
Library    python/tti_analyzer_framework/tti_extractor_framework.py  WITH NAME  tti_trace_analyzer
Library    python/tti_analyzer_framework/tti_dataframe.py            WITH NAME  tti_dataframe
Library    python/set_pandas.py                                      WITH NAME  set_pandas
Library    python/testline_information.py

Resource   testline.robot
Resource   gnb.robot
Resource   connect.robot
Resource   tcpdump.robot
Resource   aic_tti.robot
Resource   aic_vdu_commissioning.robot


*** Variables ***
#Tagged for further improvement -> to capture the values from SCF
${fronthaul_ip_oam}      192.168.2.112
${P_console}             ${False}           # output to console can be enabled via "Set Console Output" from testline.robot


*** Keywords ***
Collect TTI Traces in Streaming mode
    [Documentation]
    ...  for a defined period of time.
    ...  PS: Works only for Classical TL. Work in progress for cloud coam TLs

    ...    | tti_trace_path       | Directory where TTI Trace is placed |
    ...    | tti_trace_filename   | Name of tti trace file |
    ...    | tti_trace_duration   | Length of trace capture in seconds      [1.. ]  |
    ...    | gnb_id               | Id of gNB                               [0.. ]  |
    ...    | du_id                | Id of DU                                [0..16] |
    ...    | comu_id              | Id of Common Unit                       [0...1] |
    ...    | capu_id              | Id of Capcity Unit                      [1...3] |
    ...    | param filter_bitmap1 | Filter bitmap1 for TTI Trace filtering  [0x...] |
    ...    | param filter_bitmap2 | Filter bitmap2 for TTI Trace filtering  [0x...] |
    ...    | trace_ip             | Destination IP where TTI Trace is captured      |
    ...    | nr_phy_cell_ids      | NR Physical cell ids                    50,51   |
    ...
    [Arguments]  ${tti_trace_path}=None
    ...  ${tti_trace_duration}=10
    ...  ${gnb_id}=${0}
    ...  ${du_id}=${0}
    ...  ${comu_id}=${0}
    ...  ${capu_id}=${0}
    ...  ${filter_bitmap1}=0xFFFFFFFF
    ...  ${filter_bitmap2}=0xFFFFFFFF
    ...  ${tti_trace_filename}=ttitrace_streaming
    ...  ${trace_ip}=${EMPTY}
    ...  ${nr_phy_cell_ids}=${EMPTY}
    ...  ${dest_ip}=10.0.1.1
    ...  ${up_port_aic}=5678
    ...  ${nrcell_id_list_aic}=${None}
    ...  ${dscp_aic}=0

    Start TTI Traces in Streaming mode   gnb_id=${gnb_id}
    ...                                  du_id=${du_id}
    ...                                  comu_id=${comu_id}
    ...                                  capu_id=${capu_id}
    ...                                  filter_bitmap1=${filter_bitmap1}
    ...                                  filter_bitmap2=${filter_bitmap2}
    ...                                  trace_ip=${trace_ip}
    ...                                  nr_phy_cell_ids=${nr_phy_cell_ids}
    ...                                  tti_trace_filename=${tti_trace_filename}
    ...                                  dest_ip=${dest_ip}
    ...                                  up_port_aic=${up_port_aic}
    ...                                  nrcell_id_list_aic=${nrcell_id_list_aic}
    ...                                  dscp_aic=${dscp_aic}

    Sleep  ${tti_trace_duration}s

    Stop TTI Traces in Streaming mode     tti_trace_filename=${tti_trace_filename}
    [Return]  ${tti_trace_path}/${tti_trace_filename}.pcap

Start TTI Traces in Streaming mode
    [Documentation]
    ...  PS: Works only for Classical TL. Work in progress for cloud coam TLs
    ...    | gnb_id             | Id of gNB                               [0.. ]  |
    ...    | du_id              | Id of DU                                [0..16] |
    ...    | comu_id            | Id of Common Unit                       [0...1] |
    ...    | capu_id            | Id of Capcity Unit                      [1...3] |
    ...    | filter_bitmap1     | Filter bitmap1 for TTI Trace filtering  [0x...] |
    ...    | filter_bitmap2     | Filter bitmap2 for TTI Trace filtering  [0x...] |
    ...    | trace_ip           | Destination IP where TTI Trace is captured      |
    ...    | nr_phy_cell_ids    | NR Physical cell ids                    50,51   |
    ...    | tti_trace_filename | the filename to use                             |
    ...    | up_destIpAddr_aic  | in case of all in cloud destination ip address  |
    ...    | up_port_aic        | up port for tti collection on all in cloud      |
    ...    | nrcell_id_list_aic | NR Cell IDs for all in cloud |
    ...    | dscp_aic           | DSCP for all in cloud |
    ...
    [Arguments]
    ...  ${gnb_id}=${0}
    ...  ${du_id}=${0}
    ...  ${comu_id}=${0}
    ...  ${capu_id}=${0}
    ...  ${filter_bitmap1}=0xFFFFFFFF
    ...  ${filter_bitmap2}=0xFFFFFFFF
    ...  ${trace_ip}=${EMPTY}
    ...  ${nr_phy_cell_ids}=${EMPTY}
    ...  ${tti_trace_filename}=ttitrace_streaming
    ...  ${dest_ip}=10.0.1.1
    ...  ${up_port_aic}=5678
    ...  ${nrcell_id_list_aic}=${None}
    ...  ${dscp_aic}=0

    BuiltIn.Log   BTS Type Identified : ${tl_info.deployment_type(${gnb_id})}

    ${nr_phy_cell_ids}=  Determine NR Cell IDs  nr_phy_cell_ids=${nr_phy_cell_ids}

    Run Keyword If   '${tl_info.deployment_type(${gnb_id})}'=='classical'
    ...       Update TTI Trace filter    filter_bitmap1=${filter_bitmap1}
    ...                                  filter_bitmap2=${filter_bitmap2}
    ...                                  gnb_id=${gnb_id}
    ...                                  du_id=${du_id}
    ...                                  comu_id=${comu_id}

    BuiltIn.Log     TTI Traces are forwarded to IP: ${dest_ip}

    Create collectors and Start Generation of TTI Trace  gnb_id=${gnb_id}
    ...                                                  du_id=${du_id}
    ...                                                  comu_id=${comu_id}
    ...                                                  dest_ip=${dest_ip}
    ...                                                  tti_trace_filename=${tti_trace_filename}
    ...                                                  nr_phy_cell_ids=${nr_phy_cell_ids}
    ...                                                  bts_type=${tl_info.deployment_type(${gnb_id})}


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

    ${dir_tti_trace}=  Run Keyword If  '${tti_trace_path}'=='${EMPTY}'   Get testcase log directory
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

    ${output_file_path}=  Determine Output File Path                  input_file_path=${input_file_path}
    ...                                                               output_file_path=${output_file_path}

    tce.Create eventDecoder Converter    name=converter
    ...                                  input_file_path=${input_file_path}
    ...                                  output_file_format=excelCsv
    ...                                  output_file_path=${output_file_path}
    ...                                  excel_csv_options=${options}

    tce.Convert    name=converter


Convert TTI trace from pcap to data frame
    [Documentation]
    ...  This keyword converts TTi traces to json then to a pandas data frame and
    ...  requires the Library taf.converters.eventdecoder and pandas
    ...  | input_file_path | Path to the input file (full Path with Filename) Example ${targed_Dir}/ttitraceStreaming.pcap |
    ...  | events_list | Filter events from the tti trace, leave blank if all events are needed Example: ulTdSchedSubcellData |
    ...  | write_to_pickle | Writes the generated dataframe to a pickle file, the pickle file will have the same name as the input_file_path |

    [Arguments]  ${input_file_path}=${EMPTY}    ${events_list}=${EMPTY}  ${write_to_pickle}=${False}

    Init Pandas

    ${input_file_path}=  tti_streammode.add File ending if missing        file_path=${input_file_path}
    ...                                                                   file_ending=.pcap

    ${df}=  tti_dataframe.convert_tti_trace_to_df    ${input_file_path}   ${events_list}

    Run Keyword If  ${write_to_pickle}  tti_dataframe.write_df_to_pickle  df=${df}
    ...                                                                   target_path=${input_file_path}

    [Return]  ${df}


Convert TTI trace from data frame to csv
    [Documentation]
    ...  This keyword converts TTi traces pandas data frame to csv
    ...
    ...  | df                 | the pandas data frame |
    ...  | tti_trace_path     | the path where to store the tti trace file |
    ...  | tti_trace_filename | the tti trace csv filename |
    ...
    [Arguments]  ${df}=${EMPTY}    ${tti_trace_path}=${EMPTY}   ${tti_trace_filename}=ttitrace_streaming.csv

    Init Pandas

    ${dir_tti_trace}=  Run Keyword If  '${tti_trace_path}'=='${EMPTY}'
    ...     Get testcase log directory
    ...  ELSE
    ...     Set Variable  ${tti_trace_path}

    tti_dataframe.save_df_to_csv    ${df}    csv_file_name=${tti_trace_filename}    folder_path=${dir_tti_trace}/

    [Return]  ${dir_tti_trace}/${tti_trace_filename}


Update TTI Trace filter
    [Documentation]
    ...  This keyword updates the TTI Trace filter
    ...  The keyword accpets the following parameters
    ...
    ...    | gnb_id               | Id of gNB                               [0.. ] |
    ...    | du_id                | Id of DU                                [0..16] |
    ...    | comu_id              | Id of Common Unit                       [0...1] |
    ...    | param filter_bitmap1 | Filter bitmap1 for TTI Trace filtering  [0x...]  |
    ...    | param filter_bitmap2 | Filter bitmap2 for TTI Trace filtering  [0x...]  |
    ...
    [Arguments]  ${filter_bitmap1}=0xFFFFFFFF  ${filter_bitmap2}=0xFFFFFFFF  ${gnb_id}=${0}  ${du_id}=${0}  ${comu_id}=${0}
    Set SW Config On Common Module  rad_param=0x580115  rad_param_value=${filter_bitmap1}  gnb_id=${gnb_id}
    ...  du_id=${du_id}  comu_id=${comu_id}
    Set SW Config On Common Module  rad_param=0x580116  rad_param_value=${filter_bitmap2}  gnb_id=${gnb_id}
    ...  du_id=${du_id}  comu_id=${comu_id}

Identify Destination IP for tti trace capture
    [Documentation]
    ...    This keyword identifies the destination IP i.e. the IP address where the trace is to be collected
    ...
    ...    | bts_type | Bts type (classical/clod) |
    ...    | trace_ip | User desired trace ip, i.e. 10.0.1.1 |
    ...
    ...    *Returns*   The Destination IP where the trace is to be collected

    [Arguments]  ${bts_type}  ${trace_ip}

    Return From Keyword If   '${bts_type}'=='cloud'   10.0.1.1
    ${trace_ip}=  Set Variable if  '${tl.gnbs[${0}].cu.x2c.v4}'=='10.1.1.1'  10.0.1.1  ${trace_ip}
    ${backhaul_ip}=  Set Variable if  '${bts_type}'=='classical' and '${trace_ip}'=='${EMPTY}'  ${tl.gnbs[${0}].cu.x2c.v4}  ${trace_ip}
    Set Test Variable  ${backhaul_ip}
    ${dest_ip}=  set variable if  '${bts_type}'=='classical'  ${backhaul_ip}  ${fronthaul_ip_oam}
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
    ...            ${dest_port}=5678
    ...            ${tti_trace_filename}=ttitrace_streaming
    ...            ${gnb_id}=${0}
    ...            ${du_id}=${0}
    ...            ${comu_id}=${0}
    ...            ${nr_cell_ids}=${1}

    ${collector}=   Run Keyword If    '${bts_type}'=='classical'
    ...       Create TTI Trace Collector for classical BTS     bts_type=${bts_type}
    ...                                                        nr_phy_cell_ids=${nr_phy_cell_ids}
    ...                                                        dest_ip=${dest_ip}
    ...                                                        tti_trace_filename=${tti_trace_filename}
    ...                                                        gnb_id=${gnb_id}
    ...                                                        du_id=${du_id}
    ...                                                        comu_id=${comu_id}
    ...   ELSE
    ...       Create TTI Trace Collector for AIC on VDU        gnb_id=${gnb_id}
    ...                                                        du_id=${du_id}
    ...                                                        nr_cell_ids=${nr_cell_ids}
    ...                                                        dest_ip=${dest_ip}
    ...                                                        dest_port=${dest_port}
    ...                                                        tti_trace_filename=${tti_trace_filename}
    [Return]   ${collector}


Create TTI Trace Collector for classical BTS
    [Documentation]
    ...  This keyword creates a TTI Trace collector
    ...  The keyword accpets the following parameters
    ...
    ...    | gnb_id               | Id of gNB                               [0.. ] |
    ...    | du_id                | Id of DU                                [0..16] |
    ...    | comu_id              | Id of Common Unit                       [0...1] |
    ...    | tti_trace_filename   | Name of the pcap file |
    ...    | bts_type             | Bts type  classical / cloud |
    ...    | dest_ip              | Destination IP where TTI Trace is captured |
    ...    | nr_phy_cell_ids      | NR Physical cell ids  50,51   |
    ...
    ...    *Returns*  The collector name
    ...
    [Arguments]  ${bts_type}  ${nr_phy_cell_ids}  ${dest_ip}  ${tti_trace_filename}=ttitrace_streaming
    ...  ${gnb_id}=${0}  ${du_id}=${0}  ${comu_id}=${0}

    ${tti_trace_collector}=  Set variable  l2stream3_${tti_trace_filename}

    ${tcpdump_collector}=   Identify TTI Trace Capture Location and Create Collector
    ...  bts_type=${bts_type}  gnb_id=${gnb_id}  tti_trace_filename=${tti_trace_filename}

    ${executor}=  Run Keyword If  '${bts_type}'=='classical'
    ...         Get OAM Webservice connection for Classical gNB  gnb_id=${gnb_id}
    ...  ELSE   Get OAM Webservice connection for Cloud gNB  gnb_id=${gnb_id}  du_id=${du_id}

    ${l2_stream_config_1}=  Create Dictionary
    ...  nr_phy_cell_ids=${nr_phy_cell_ids}
    @{l2_stream_configuration}    Create List    ${l2_stream_config_1}
    ${source_ip_addr}=  Get source IP address  gnb_id=${gnb_id}  du_id=${du_id}  comu_id=${comu_id}
    l2stream3.create_sbts_l2stream_collector
    ...  name=${tti_trace_collector}
    ...  webservice=${executor}
    ...  source_ip_addr=${source_ip_addr}
    ...  destination_ip_addr=${dest_ip}
    ...  collector=${tcpdump_collector}
    ...  l2_stream_configuration=${l2_stream_configuration}
    l2stream3.setup_collectors    names=${tti_trace_collector}
    l2stream3.Set Suite Alias     ${tti_trace_collector}
    [Return]  ${tti_trace_collector}


Create TTI Trace Collector for AIC on VDU
    [Documentation]
    ...   This keyword creates a TTI Trace collector for AIC VDU
    ...
    ...    | gnb_id               | Id of gNB                               [0.. ] |
    ...    | vdu_id               | Id of the VDU                          [0..16] |
    ...    | dest_ip              | Destination IP where TTI Trace is captured on TestVM |
    ...    | dest_port            | Destination port on Test VM             [0...1] |
    ...    | tti_trace_filename   | Name of the pcap file |
    ...    | nr_cell_ids      | NR Physical cell ids  50,51   |
    ...
    ...    *Returns*  The collector name
    [Arguments]  ${gnb_id}
    ...          ${du_id}
    ...          ${dest_ip}
    ...          ${dest_port}
    ...          ${tti_trace_filename}=ttitrace_streaming
    ...          ${nr_cell_ids}=None

    ${tti_trace_collector}=    Set variable   l2stream3_${tti_trace_filename}

    Prepare AIC VDU for TTI Tracing by setting Static Route on VDU     gnb_id=${gnb_id}
    ...                                                                vdu_id=${du_id}
    ...                                                                dest_ip_addr=${dest_ip}

    ${vdu_oam}=     Set Variable   ${tl.gnbs[${gnb_id}].dus[${du_id}].oam_http_connection_details}
    ${webservice}=  Create Dictionary           host=${vdu_oam.addr}
    ...                                         user=${vdu_oam.username}
    ...                                         password=${vdu_oam.password}
    ...                                         port=${vdu_oam.port}

    Run Keyword If   '${nr_cell_ids}'!='None'
    ...   Log   Cell Selection for TTI Trace on AIC not yet supported    WARN

    ${nr_cell_ids}=   Run Keyword If   '${nr_cell_ids}'=='None'
    ...     Set Variable   ${nr_cell_ids}
    ...  ELSE
    ...     Get VDU NRCell DistNames   gnb_id=${gnb_id}   vdu_id=${du_id}

    ${l2_stream_config}=  Create Dictionary     trace_type=Component
    ...                                         target_component=L2Ps
    ...                                         nr_cell_dn_list=${nr_cell_ids}

    @{l2_stream_configuration}   Create List    ${l2_stream_config}

    ${interface}=  Identify Interface with IP   ${dest_ip}

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
    ...    | gnb_id               | Id of gNB                               [0.. ]  |
    ...    | du_id                | Id of DU                                [0..16] |
    [Arguments]    ${iprt_dist_name}
    ...            ${gnb_id}=${0}
    ...            ${vdu_id}=${0}

    ${oam_alias}=         Connect To OAM DU   gnb_id=${gnb_id}   du_id=${vdu_id}
    ${iprt_params}=       Get Managed Object Parameters of Current Plan   dist_name=${iprt_dist_name}
    ...                                                                   vdu_connection=${oam_alias}
    ${static_routes}=     Get Static Route Parameters   ${iprt_params}

    [Return]              ${static_routes}
    [Teardown]            Disconnect from OAM DU    ${oam_alias}


Get VDU NRCell DistNames
    [Documentation]
    ...    This Keyword determines all available NRCell Dist names of the SCF of the
    ...    VDU identified by the gnb_id and vdu_id
    ...    | gnb_id               | Id of gNB                                [0.. ]  |
    ...    | vdu_id                | Id of DU                                [0..16] |
    ...
    [Arguments]    ${gnb_id}=${0}
    ...            ${vdu_id}=${0}

    ${target_dir}=          testline.Get Testcase Log Directory
    ${vdu_scf}=             Get DU current Plan file           gnb_id=${gnb_id}
    ...                                                        resultConfigDir=${target_dir}
    ${vdu_scf_content}=     Get File   filepath=${vdu_scf}     function_name=test
    ${nrcell_dist_names}=   gnb_lib.Get distNames From SCF     regex=MRBTS-\\d+/NRBTS-\\d+/NRCELL-\\d+
    ...                                                        scf_content=${vdu_scf_content}

    [Return]   ${nrcell_dist_names}


Prepare AIC VDU for TTI Tracing by setting Static Route on VDU
    [Documentation]
    ...    This Keyword prepares the configuration of an all in cloud VDU for tti tracing.
    ...    The Managed Object MRBTS-1/TNLSVC-1/TNL-3/IPNO-1/IPRT-1 is checked for the currently
    ...    set list 'staticRoutes'. If there is no entry, or the entry is not fitting to the expected
    ...    gateway from testline configuration, the values are correspondingly commissioned
    ...
    ...    | gnb_id               | Id of gNB                               [0.. ]  |
    ...    | du_id                | Id of DU                                [0..16] |
    ...    | dest_ip_addr         | Destination IP for tracing on Test VM           |
    [Arguments]    ${gnb_id}=${0}
    ...            ${vdu_id}=${0}
    ...            ${dest_ip_addr}=10.0.1.1


    # If we search for all dist names with same patterns, we get two (!) dist names for 'Tracing F1-U'
    # needs to be checked, if both must be set, and what the gateway must then be for second one.
    ${ipno_dist_name}=  Set Variable    MRBTS-1/TNLSVC-1/TNL-3/IPNO-1

    ${target_dir}=           testline.Get Testcase Log Directory
    ${vdu_scf}=              Get DU current Plan file   gnb_id=${gnb_id}
    ...                                                 resultConfigDir=${target_dir}
    scf.Load SCF             ${vdu_scf}
    ${address_identifier}=   scf.Get Value From Scf         dist_name=${ipno_dist_name}/IPIF-1/IPADDRESSV4-1
    ...                                                 p_name=uniqueIpAddressIdentifier

    Should Be Equal    ${address_identifier}    Tracing F1-U   The dist name doesn't fit for TTI Tracing!

    ${iprt_dist_name}=    Set Variable   ${ipno_dist_name}/IPRT-1


    ${gateway}=        Get Gateway IP from TL Config   ${tl}

    ${static_routes}=  Get Static Routes from IPRT    iprt_dist_name=${iprt_dist_name}
    ...                                               gnb_id=${gnb_id}
    ...                                               vdu_id=${vdu_id}

    ${commisioning_required}=   Check if recommissioning of Static Routes is required   static_routes=${static_routes}
    ...                                                                                 dest_ip_addr=${dest_ip_addr}
    ...                                                                                 gateway=${gateway}

    Run Keyword If     ${commisioning_required}
    ...    Configure Static Routes on VDU for TTI Tracing    dist_name=${iprt_dist_name}
    ...                                                      gateway=${gateway}
    ...                                                      dest_ip_addr=${dest_ip_addr}
    ...                                                      gnb_id=${gnb_id}
    ...                                                      vdu_id=${vdu_id}


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


Configure Static Routes on VDU for TTI Tracing
    [Documentation]
    ...   Keyword to perform commissioning for the static route for tti tracing
    ...
    ...   | dist_name    | the dist name (from IPRT managed object) to set static route |
    ...   | gateway      | The gateway for the static route                             |
    ...   | dest_ip_addr | The destination ip on Test VM for the static route           |
    ...   | gnb_id       | Id of gNB                                            [0.. ]  |
    ...   | du_id        | Id of DU                                             [0..16] |
    [Arguments]    ${dist_name}
    ...            ${gateway}
    ...            ${dest_ip_addr}=10.0.1.1
    ...            ${gnb_id}=${0}
    ...            ${vdu_id}=${0}

    ${json_delta_file}=   tti_streammode.create_json_commissioning_file_for_static_route
    ...   dist_name=${dist_name}
    ...   gateway=${gateway}
    ...   dest_ip_addr=${dest_ip_addr}

    aic_vdu_commissioning.Delta Commissioning Json vDU And Wait For Success
    ...   ${json_delta_file}
    ...   gnb_id=${gnb_id}
    ...   du_id=${vdu_id}


Create collectors and Start Generation of TTI Trace
    [Documentation]
    ...
    ...  This keyword starts the generation of TTI Trace
    ...
    ...  The keyword accpets the following parameters
    ...
    ...    | gnb_id             | Id of gNB               [0.. ] |
    ...    | du_id              | Id of DU                [0..16] |
    ...    | comu_id            | Id of Common Unit       [0...1] |
    ...    | tti_trace_filename | Name of the pcap file   |
    ...    | bts_type           | Bts type   :             classical/cloud |
    ...    | nr_phy_cell_ids    | NR Physical cell ids    50,51   |
    ...    | dest_ip            | Destination IP where TTI Trace is captured |
    ...
    ...    *Returns*  The collector name
    ...
    [Arguments]  ${tti_trace_filename}  ${bts_type}  ${nr_phy_cell_ids}  ${dest_ip}
    ...  ${gnb_id}=${0}  ${du_id}=${0}  ${comu_id}=${0}

    ${tti_trace_collector}=  Create TTI Trace Collector   tti_trace_filename=${tti_trace_filename}
    ...                                                   bts_type=${bts_type}
    ...                                                   nr_phy_cell_ids=${nr_phy_cell_ids}
    ...                                                   dest_ip=${dest_ip}
    ...                                                   dest_port=5678
    ...                                                   gnb_id=${gnb_id}
    ...                                                   du_id=${du_id}
    ...                                                   comu_id=${comu_id}

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
    Move Trace File to Desired Directory  desired_storage_directory=${desired_storage_directory}  desired_file_name=${desired_file_name}


Identify TTI Trace Capture Location and Create Collector
    [Documentation]
    ...  *Scope* Internal
    ...
    [Arguments]  ${bts_type}  ${tti_trace_filename}=${EMPTY}  ${gnb_id}=0


    ${collector}=   Run Keyword If  '${bts_type}'=="classical"
    ...      Create TCPDump Collector on backhaul interface   tti_trace_filename=${tti_trace_filename}
    ...                                                       bts_type=${bts_type}
    ...  ELSE
    ...      Connect to CPIF and Start TCP Dump on fronthaul  gnb_id=${gnb_id}
    ...                                                       tti_trace_filename=${tti_trace_filename}
    [Return]    ${collector}


Create TCPDump Collector on backhaul interface
    [Documentation]
    ...  *Scope* Internal
    ...
    ...  *Returns* Collector name
    ...
    [Arguments]  ${bts_type}   ${tti_trace_filename}

    ${trace_ip}=     Set Variable      10.0.1.1
    ${backhaul_ip}=  Set Variable if   '${bts_type}'=='classical' and '${trace_ip}'=='${EMPTY}'
    ...                                ${tl.gnbs[${0}].cu.x2c.v4}
    ...                                ${trace_ip}

    ${interface_name}=  Identify Interface with IP  ip=${backhaul_ip}

    BuiltIn.Log  \nIdentified interface for TCP Dump on Test PC is: ${interface_name}   console=${P_console}

    ${collector}=  ttitrace.Create TCP Dump Collector  interface_name=${interface_name}
    ...                                                tti_trace_filename=${tti_trace_filename}
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

    tcpdump.create_tcpdump_collector
    ...     name=${tti_trace_filename}
    ...     options=-i ${interface_name} port 5678
    ...     executor=${testpc_ssh_config}
    tcpdump.set_suite_alias     ${tti_trace_filename}
    [RETURN]    ${tti_trace_filename}


Connect to CPIF and Start TCP Dump on fronthaul
    [Documentation]
    ...  *Scope* Internal
    ...
    ...  *Returns* Collector
    [Arguments]  ${gnb_id}=0  ${tti_trace_filename}=${EMPTY}

    ${collector}=   tcpdump.Start TCPdump on gNB VM    vm_name=cpif
    ...                                                gnb_id=${gnb_id}
    ...                                                interface=fronthaul
    ...                                                option=port 5678
    ...                                                collector=${tti_trace_filename}

    [Return]    ${collector}


Stop Generation and collect TTI Trace
    [Documentation]
    ...  *Scope* Internal
    ...
    [Arguments]  ${desired_storage_directory}=${EMPTY}  ${desired_file_name}=ttitrace_streaming
    l2stream3.stop_collectors    names=l2stream3_${desired_file_name}
    l2stream3.collect_collectors    names=l2stream3_${desired_file_name}  target_dir=${desired_storage_directory}
    l2stream3.teardown_collectors    names=${desired_file_name},l2stream3_${desired_file_name}
    Move Trace File to Desired Directory  desired_storage_directory=${desired_storage_directory}  desired_file_name=${desired_file_name}


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
    ${release}=  gnb.Get release name  node_id=${gnb_id}
    ${executor_classical}=  Create Dictionary
    ...  host=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.addr}
    ...  user=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.username}
    ...  password=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.password}
    ...  port=443
    ...  release=${release}
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

Get source IP address
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
    ${output_file_path}=  Run Keyword If   '${output_file_path}'=='${EMPTY}'  Generate default output file path  input_file_path=${input_file_path}
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
    ${extracted_phy_cell_ids}=  Run Keyword If  '${nr_phy_cell_ids}'=='${EMPTY}'  Extract Cell Ids if not known
    ${nr_phy_cell_ids}=  Set Variable If  '${nr_phy_cell_ids}'=='${EMPTY}'  ${extracted_phy_cell_ids}  ${nr_phy_cell_ids}
    [Return]  ${nr_phy_cell_ids}

Extract Cell Ids if not known
    [Documentation]
    ...  *Scope* Internal
    ...
    ...  *Returns* Physical cell IDs from gNodeB
    ...
    ${cell_dist_ids}=   gnb.Get gNB Physical Cell ID
    ${phy_cell_ids}=    Collections.Get Dictionary Values   ${cell_dist_ids}   sort_keys=True
    ${phy_cell_ids}=    Catenate    SEPARATOR=,   @{phy_cell_ids}
    [Return]  ${phy_cell_ids}
