*** Settings ***
Resource    ../bip_trace_ap.robot
Resource    ../testline.robot
Library    OperatingSystem


*** Test Cases ***
Test Start Stop Airphone BIP Traces
    [TAGS]              BIP     TCPDUMP
    Start Airphone BIP Traces
    Sleep   10
    ${biptrace_file}=  Stop Airphone BIP Traces
    File Should Exist           ${biptrace_file}
    File Should not be empty    ${biptrace_file}
