*** Settings ***
Documentation
...   author: Lekhashree S N
...   contact: lekhashree.s_n@nokia.com
Library    OperatingSystem
Library    CNI.py

*** Variables ***
${path}    C:\\Users\\lesn\\Desktop\\EMIL\\       #in linux   /home/home/log_path

*** Test Cases ***
test1
   EMIl log validation    ${path}


*** Keywords ***
EMIl log validation
    [Arguments]    ${path}
    ${result}		Parse_Emil_Csv_File_For_Message_content_required_not_required 	 ${path}
    ...    ueCapabilityEnquiry    rat-Type nr,    rat-Type eutra
    ${result1}		Parse_Emil_Csv_File_For_Message_content_required_not_required 	 ${path}
    ...    ueCapabilityEnquiry    rat-Type nr,.rat-Type eutra.rat-Type eutra-nr,
    ${result2}		Parse_Emil_Csv_File_For_Message_content_required_not_required 	 ${path}
    ...    InitialContextSetupResponse
    ${status}    compare_values    ${result}    ${result1}    ${result2}
    Run Keyword If    "${status}" == "True"    Log to console    CNI-98693 validation is done and its passed
    ...    ELSE    log to console    CNI-98693 validation is done and its failed
    Run Keyword And Continue On Failure    Should Be Equal    ${status}    ${True}