*** Settings ***
Resource    ../ute_workarounds.robot
Resource    ../wts_ue.robot
Resource    ../testline.robot
Resource    ../bip_trace.robot
Library     ../python/PcapAnalysis.py
Library     ../python/BipTraceDissectors.py
Library     ../python/MCSharkDissectors.py


Suite Setup      Bring Airphone to on Air status
Suite Teardown   Teardown the wts sim


*** Test Cases ***
Test Collection of BIP Trace using Admin
    [TAGS]   WIP   BIP

    ${bip_trace_list}=   Execute Bip Collection    5 sec
    Analyse the collected bip trace    ${bip_trace_list}


Test Collection of BIP Trace using Admin with default target dir
    [TAGS]   WIP   BIP

    ${bip_trace_list}=   Execute Bip Collection without giving target dir    5 sec
    Analyse the collected bip trace    ${bip_trace_list}


*** Keywords ***

Bring Airphone to on Air status
    UTE Cloud Workaround

    ${connected}=   Connect To Running Egate   ap_egate
    Return From Keyword If   ${connected}

    ${wts_status}=    Run Keyword and Return Status    Bring Airphone TL to on Air status without reboot
    Run Keyword If    ${wts_status} == False             Bring Airphone TL to on Air status


Teardown the wts sim
    Teardown Egate Connection for Airphone
    Teardown Edaemon Connection for Airphone


Execute Bip Collection
    [Arguments]   ${duration}=1 sec
    Start Bip Traces

    Ue Register
    Sleep   ${duration}
    Ue Deregister

    ${bip_trace_list}=   Stop Bip Traces   target_dir=/tmp
    [Return]   ${bip_trace_list}


Execute Bip Collection Without giving target dir
    [Arguments]   ${duration}=1 sec
    Start Bip Traces

    Ue Register
    Sleep   ${duration}
    Ue Deregister

    ${bip_trace_list}=   Stop Bip Traces
    [Return]   ${bip_trace_list}


Analyse the collected bip trace
    [Arguments]    ${bip_trace_list}
    FOR     ${trace}    IN  @{bip_trace_list}
        File Should Not Be Empty    ${trace}    Failure: BIP trace is empty!
    END
    ${gnb_sw_version}=    Get gNB SW version

    Update MCShark Dissector   ${gnb_sw_version}

    ${uldata_prachreceivereq_fields}=   Create Dictionary    prachPrbOffset   UlData_prachReceiveReqSubcell_t.prachPrbOffset

    ${test_data}=    Create Dictionary   uldata_prachreceivereq    ${uldata_prachreceivereq_fields}

    ${bip_trace}=     Get From List   ${bip_trace_list}   0
    ${bip_data}=   Create Analysis Data    pcap_file=${bip_trace}   test_data=${test_data}

    Should Not be Empty   ${bip_data}    BIP Trace is empty - no BIP Trace detected. PrachReceiveReq should be present.
    ${amount_of_prach_reseive_req}=    Get Length    ${bip_data}
    Should Be True     ${amount_of_prach_reseive_req} > 10    Not enouth Prach Receive Reqs found!



