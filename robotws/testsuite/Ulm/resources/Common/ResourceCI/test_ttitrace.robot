*** Settings ***

Documentation
...   This is a test suite used in KW resourceCI running against real classical TL.
...   It verifies proper function of KWs in ttitrace.robot for classical deployments.


Library    OperatingSystem

Resource   ../ttitrace.robot
Resource   ../testline.robot
Resource   ../connect.robot
Resource   ../wts_ue.robot
Resource   ../ute_workarounds.robot

Suite Setup     Prepare Pre-condition For TTI Trace Test

*** Variables ***
${TTI_COLLECTION_DURATION}  2s

*** Test Cases ***
Test Tti Trace Collection in Streaming mode with default name
    [TAGS]  TTI
    ttitrace.Collect TTI Traces In Streaming Mode
    ${target_dir}=    testline.Get Testcase Log Directory
    OperatingSystem.File Should Not Be Empty    ${target_dir}/ttitrace_streaming.pcap


Test Tti Trace Collection in Streaming mode with csv event filter
    [TAGS]  TTI
    ttitrace.Collect TTI Traces In Streaming Mode
    ...   event_filter_list=ulAllocatedPooledResourcesData,dlAllocatedPooledResourcesData
    ${target_dir}=    testline.Get Testcase Log Directory
    OperatingSystem.File Should Not Be Empty    ${target_dir}/ttitrace_streaming.pcap


Test Tti Trace Collection in Streaming mode with list event filter
    [TAGS]  TTI
    ${event_filter_list}   Create List   ulAllocatedPooledResourcesData   dlAllocatedPooledResourcesData
    ttitrace.Collect TTI Traces In Streaming Mode
    ...   event_filter_list=${event_filter_list}
    ${target_dir}=    testline.Get Testcase Log Directory
    OperatingSystem.File Should Not Be Empty    ${target_dir}/ttitrace_streaming.pcap


Test Start Stop TTI Traces in Streaming mode
    [TAGS]  TTI
    ttitrace.Start TTI Traces In Streaming Mode
    Sleep   ${TTI_COLLECTION_DURATION}
    ${tti_trace}    ttitrace.Stop TTI Traces In Streaming Mode  tti_trace_filename=ttitrace_streaming
    OperatingSystem.File Should Not Be Empty    ${tti_trace}
    Set Suite Variable  ${tti_trace}


Test Start Stop TTI Traces in Streaming mode for L2Lo
    [TAGS]  TTI
    ${components}=    Create List    L2Lo
    ttitrace.Start TTI Traces In Streaming Mode    components=${components}
    Sleep   ${TTI_COLLECTION_DURATION}
    ${tti_trace}=    ttitrace.Stop TTI Traces In Streaming Mode  tti_trace_filename=ttitrace_streaming
    OperatingSystem.File Should Not Be Empty    ${tti_trace}
    Set Suite Variable  ${tti_trace}


Test Start Stop TTI Traces in Streaming mode for L2Ps L2Lo L2HiPdcp L2HiRlc
    [TAGS]  TTI
    ${components}=    Create List    L2Ps   L2Lo   L2HiPdcp   L2HiRlc

    ttitrace.Start TTI Traces In Streaming Mode    components=${components}

    wts_ue.Ue Register
    Sleep   ${TTI_COLLECTION_DURATION}
    wts_ue.Ue Deregister

    ${tti_trace}=    ttitrace.Stop TTI Traces In Streaming Mode  tti_trace_filename=ttitrace_streaming
    OperatingSystem.File Should Not Be Empty    ${tti_trace}
    Set Suite Variable  ${tti_trace}


Test Start Stop TTI Traces in Streaming mode with filter
    [TAGS]  TTI

    ttitrace.Start TTI Traces In Streaming Mode  tti_filter=All events
    Sleep   ${TTI_COLLECTION_DURATION}
    ${tti_trace}=    ttitrace.Stop TTI Traces In Streaming Mode  tti_trace_filename=ttitrace_streaming
    OperatingSystem.File Should Not Be Empty    ${tti_trace}
    Set Suite Variable  ${tti_trace}


Test Convert TTI trace from pcap to dataframe with Ue Action
    [TAGS]  TTI2DF
    ${components}=    Create List    L2Lo   L2Ps
    ttitrace.Start TTI Traces In Streaming Mode    components=${components}

    wts_ue.UE Register
    Sleep   ${TTI_COLLECTION_DURATION}
    wts_ue.UE Deregister

    ${tti_trace}=    ttitrace.Stop TTI Traces In Streaming Mode  tti_trace_filename=ttitrace_streaming

    ttitrace.Convert TTI Trace From Pcap To Data Frame    input_file_path=${tti_trace}
    ...                                          write_to_pickle=${true}

    ttitrace.Convert L2Lo TTI Trace From Pcap To Data Frame    input_file_path=${tti_trace}
    ...                                               write_to_pickle=${true}


Test Convert TTI trace from pcap to parquetCsv and parquet with Ue Action
    [TAGS]  TTI2CSV
    ${collector_name}   ttitrace.Start TTI Traces In Streaming Mode
    wts_ue.UE Register   ue_id=1
    Sleep   ${TTI_COLLECTION_DURATION}
    wts_ue.UE Deregister  ue_id=1
    ${tti_trace}   ttitrace.Stop TTI Traces In Streaming Mode
    ...   collector_name=${collector_name}   tti_trace_filename=ttitrace_streaming

    ${target_dir}=    testline.Get Testcase Log Directory

    ttitrace.Convert TTI Trace From Pcap To ParquetCsv         input_file_path=${tti_trace}
    ...   output_file_path=${target_dir}/sample_ttitrace_pcap2parquetcsv

    OperatingSystem.Directory Should Exist      ${target_dir}/sample_ttitrace_pcap2parquetcsv/parq_component=PS

    ${dl_files}   OperatingSystem.List Directory              path=${target_dir}/sample_ttitrace_pcap2parquetcsv
    ...   pattern=ttitrace_streaming_*_parqCsv_dl_*.csv   absolute=${True}
    IF   ${{ len(${dl_files})==0 }}   Fail   No CSV file found for DL!
    FOR   ${file}   IN   @{dl_files}
       OperatingSystem.File Should Not Be Empty    ${file}
    END

    ${ul_files}   OperatingSystem.List Directory              path=${target_dir}/sample_ttitrace_pcap2parquetcsv
    ...   pattern=ttitrace_streaming_*_parqCsv_ul_*.csv   absolute=${True}
    IF   ${{ len(${ul_files})==0 }}   Fail   No CSV file found for UL!
    FOR   ${file}   IN   @{ul_files}
       OperatingSystem.File Should Not Be Empty    ${file}
    END

    ttitrace.Convert TTI Trace From Pcap To Parquet         input_file_path=${tti_trace}
    ...                                            output_file_path=${target_dir}/sample_ttitrace_pcap2parquet/
    OperatingSystem.Directory Should Not Be Empty      ${target_dir}/sample_ttitrace_pcap2parquet/parq_component=PS


*** Keywords ***
Prepare Pre-condition For TTI Trace Test
    UTE Cloud Workaround
    Bring Airphone To On Air Status


Bring Airphone To On Air Status
    TRY
        ute_workarounds.Bring Airphone TL To On Air Status Without Reboot
    EXCEPT
        ute_workarounds.Bring Airphone TL To On Air Status
    END
