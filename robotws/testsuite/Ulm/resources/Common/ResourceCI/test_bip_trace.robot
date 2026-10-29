*** Settings ***

Documentation
...   This is a test suite used in KW resourceCI running against real AP TL.
...   It verifies proper function of KWs in bip_trace.robot.


Resource    ../ute_workarounds.robot
Resource    ../wts_ue.robot
Resource    ../testline.robot
Resource    ../bip_trace.robot
Library     ../python/PcapAnalysis.py
Library     ../python/MCSharkDissectors.py


Suite Setup      Bring Airphone To On Air Status
Suite Teardown   Teardown The WTS Sim


*** Test Cases ***
Test Collection of BIP Trace using Admin
    [TAGS]   WIP   BIP

    ${bip_trace_list}=   Execute Bip Collection    5 sec
    Analyse The Collected BIP Trace    ${bip_trace_list}


Test Collection of BIP Trace using Admin with default target dir
    [TAGS]   WIP   BIP

    ${bip_trace_list}=   Execute Bip Collection Without Giving Target Dir    5 sec
    Analyse The Collected BIP Trace    ${bip_trace_list}


*** Keywords ***

Bring Airphone To On Air Status
    UTE Cloud Workaround

    ${connected}=   Connect To Running Egate   ap_egate
    IF   ${connected}   RETURN

    ${wts_status}=    Run Keyword And Return Status    Bring Airphone TL To On Air Status Without Reboot
    IF    not ${wts_status}             Bring Airphone TL To On Air Status


Teardown The Wts Sim
    Teardown Egate Connection For Airphone
    Teardown Edaemon Connection For Airphone


Execute Bip Collection
    [Arguments]   ${duration}=1 sec
    Start Bip Traces

    Ue Register
    Sleep   ${duration}
    Ue Deregister

    ${bip_trace_list}=   Stop Bip Traces   target_dir=/tmp
    RETURN   ${bip_trace_list}


Execute BIP Collection Without Giving Target Dir
    [Arguments]   ${duration}=1 sec
    Start Bip Traces

    Ue Register
    Sleep   ${duration}
    Ue Deregister

    ${bip_trace_list}=   Stop Bip Traces
    RETURN   ${bip_trace_list}


Analyse The Collected BIP Trace
    [Arguments]    ${bip_trace_list}
    FOR     ${trace}    IN  @{bip_trace_list}
        File Should Not Be Empty    ${trace}    Failure: BIP trace is empty!
    END
    ${gnb_sw_version}=    Get GNB SW Version

    Update MCShark Dissector   ${gnb_sw_version}

    ${uldata_prachreceivereq_fields}=   Create Dictionary    prachPrbOffset   UlData_prachReceiveReqSubcell_t.prachPrbOffset

    ${test_data}=    Create Dictionary   uldata_prachreceivereq    ${uldata_prachreceivereq_fields}

    ${bip_trace}=     Get From List   ${bip_trace_list}   0
    ${bip_data}=   Create Analysis Data    pcap_file=${bip_trace}   test_data=${test_data}

    Should Not Be Empty   ${bip_data}    BIP Trace is empty - no BIP Trace detected. PrachReceiveReq should be present.
    ${amount_of_prach_reseive_req}=    Get Length    ${bip_data}
    Should Be True     ${amount_of_prach_reseive_req} > 10    Not enouth Prach Receive Reqs found!



