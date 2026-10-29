*** Settings ***
Documentation
...                  == Purpose ==
...                  The TTI Convertion library is used to convert a tti trace pcap file to JSON format.
...
...                  == Description ==
...                  This library contains a keyword used in roboframework tests as an interface to a library written in python
...                  and available in python/TtiTrace SWENG folder
...
...                  *Provided keyword:*
...                                 -    Convert TTI capture: This keyword is used to convert the TTI pcap capture to a JSON file
...
...                  == Usage ==
...                  The Tti Convert Interace allow to convert a pcap file into json format.
...                  This library is separated from Tti Analysis Interface as this other library need a json
...                  file to be present in order to be imported
...
...                  == Example ==
...                  | Convert TTI capture| ${path_to_pcap} | ${events_list} | ${tti_decoder_path} |
...
...                  Some files robotframework and in python are given as examples in
...                        examples folder
...                        and python/Examples folder
...

Resource            Tools.robot
Library             ../python/TtiTrace/tti_extractor.py    WITH NAME    TtiExtractor


*** Keywords ***

Convert TTI capture
    [Documentation]    This keyword is used to convert the given TTI pcap capture file to a JSON file.
    ...                The JSON file can be used to analyze the TTI data with the TtiAnalysis library.
    ...                The JSON file is stored in the same directory as the pcap file.
    ...                The pcap file is converted to a JSON file using the TtiExtractor library.
    ...                An event list is given as input to the TtiExtractor library to filter the events to be extracted.
    [Arguments]    ${pcap_file_path}      ${events_list}=${None}       ${tti_decoder_path}=/opt/tti-dec/tti-dec-bin/
    Tools.Dated Log New Line    Converting ${pcap_file_path} pcap file to JSON format
    Tools.Dated Log    > Events to extract: ${events_list}
    IF                  ${events_list} == None
                        TtiExtractor.Decode Events Using Event Decoder v1   file_name=${pcap_file_path}    tti_dec_path=${tti_decoder_path}
    ELSE
                        TtiExtractor.Decode Events Using Event Decoder    file_name=${pcap_file_path}    events_to_analyze=${events_list}
                        ...    tti_dec_path=${tti_decoder_path}    return_stuff=True
    END
