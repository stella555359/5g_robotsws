*** Settings ***
Documentation    Insert Feature Specific validation keywords here

#Import required libraries for validation
#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

*** Keywords ***
Extract TTI Trace and Convert to JSON
    [Arguments]  @{varargs}
    RETURN


Extract TTI Trace and Convert to Pickle
    [Arguments]  ${path_to_tti_trace_pcap}
    ${events_required}=  Create List  csiSrReportData  dlHarqRxDataArray
    Convert TTI trace from pcap to data frame  input_file_path=${path_to_tti_trace_pcap}
    ...  events_list=${events_required}
    ...  write_to_pickle=${TRUE}
