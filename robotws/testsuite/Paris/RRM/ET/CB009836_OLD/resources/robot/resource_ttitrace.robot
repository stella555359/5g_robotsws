*** Settings ***
Documentation     Keywords related to decodage of TTI Traces

Library    OperatingSystem
Library    Collections

Library    taf.converters.eventdecoder                                  WITH NAME  tce
Library    ../python/ttitrace.py                                        WITH NAME  ttitrace_py


*** Variables ***
${P_console}                   ${False}        # output to console can be enabled via "Set Console Output" from testline.robot

*** Keywords ***
# robocop: off=unused-argument
# robocop: off=possible-variable-overwriting


Determine Full Output File Path
    [Documentation]
    ...  *Scope* Internal
    ...
    ...  *Returns* The output file path
    ...
    [Arguments]  ${input_file_path}=${EMPTY}  ${output_file_path}=${EMPTY}
    ${output_file_path}=  Run Keyword If   '${output_file_path}'=='${EMPTY}'
    ...           resource_ttitrace.Generate full default output file path  input_file_path=${input_file_path}
    ...  ELSE  Set Variable  ${output_file_path}
    [Return]  ${output_file_path}


Generate full default output file path
    [Documentation]
    ...  *Scope* Internal
    ...
    ...  *Returns* The output file path derived from the given `input_file_path`
    ...
    [Arguments]  ${input_file_path}=${EMPTY}
    ${output_file_path}=  OperatingSystem.Split Path	${input_file_path}
    [Return]  ${output_file_path[0]}

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

    ${input_file_path}=   ttitrace_py.add_file_ending_if_missing   file_path=${input_file_path}
    ...                                                            file_ending=.pcap

    ${output_file_path}=  Determine Full Output File Path         input_file_path=${input_file_path}
    ...                                                           output_file_path=${output_file_path}

    tce.Create eventDecoder Converter    name=converter
    ...                                  input_file_path=${input_file_path}
    ...                                  output_file_format=legacyCsv
    ...                                  output_file_path=${output_file_path}
    # ...                                  excel_csv_options=${options}

    tce.Convert    name=converter

    # Copy excel macro file to easier open csv file
    Run keyword and ignore error    copy file    /opt/tti-dec/tti-dec-bin/excelCsvViewer/5G_TTI_Trace.xlsm
    ...    ${input_file_path}/5G_TTI_Trace.xlsm
