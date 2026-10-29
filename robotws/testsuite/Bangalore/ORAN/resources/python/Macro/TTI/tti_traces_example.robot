*** Settings ***

Resource    ./tti_traces.robot

*** Test Cases ***
Test TTitrace With Streaming Mode
    Start Ttirace With Streaming Mode
    Sleep    1s    wait to catch ttitrace...
    Stop Ttirace
    Convert Tttirace From Pcap To Excelcsv    ${OUTPUT_DIR}/ttitrace_streaming/

Test Parser Ttitrace
    ${numOf5qi1Prb_list}=    Ttitrace Filter Source Column Return Self Column    ${OUTPUT_DIR}/ttitrace_streaming/output_ul.csv
    ...    ulFdSchedData.numOf5qi1Prb     ["0", "", "0.0"]    except    yes
    ${rnti_list}=    Ttitrace Filter Source Column Return Other Column    ${OUTPUT_DIR}/ttitrace_streaming/output_ul.csv
    ...    ulFdSchedData.numOf5qi1Prb     ["0", "", "0.0"]    except    rnti    yes
    ${sfn_list}=    Ttitrace Filter Source Column Return Other Column    ${OUTPUT_DIR}/ttitrace_streaming/output_ul.csv
    ...    ulFdSchedData.numOf5qi1Prb     ["0", "", "0.0"]    except    sfn    no
    ${interval}=    Ttitrace Count Interval    ${sfn_list}    no
