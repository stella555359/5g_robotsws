*** Settings ***
Resource          ../resources/KISS/robot/common_resource.robot


*** Variables ***


*** Test Cases ***

test 4g
    ${trace_id}    DCAP start collect log      10.0.1.2        enb_trace_profile=dcap-lite-default      bts_trace_profile=dcap-lite-default
    DCAP stop collect log    ${trace_id}    
	
test 5g
    DCAP start collect log      10.0.1.2        gnb_trace_profile=dcap-lite-default      bts_trace_profile=dcap-lite-default	
    DCAP stop collect log    ${trace_id}    