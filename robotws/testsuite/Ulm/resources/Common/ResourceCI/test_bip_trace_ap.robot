*** Settings ***

Documentation
...   This is a test suite used in KW resourceCI running against real AP TL.
...   It verifies proper function of KWs in bip_trace_ap.robot.


Resource    ../ute_workarounds.robot
Resource    ../wts_ue.robot
Resource    ../bip_trace_ap.robot
Resource    ../testline.robot
Library    OperatingSystem


Suite Setup      Bring Airphone To On Air Status
*** Test Cases ***
Test Start Stop Airphone BIP Traces
    [TAGS]              BIP     TCPDUMP


    ${cu_type}=    Get GNbCuType Info


    IF   '${cu_type}'=='SANSA'
        Attach UE To LTE   ue_id=11
        Trigger LTE-NR Dual Connectivity For Bearers   ue_id=11
        Start Data Traffic In Egate   ue_id=11  direction=ul   id=1   trf_id=1
    ELSE
        Ue Register
        Start Data Traffic In Egate   ue_id=1   direction=ul  id=1   trf_id=1   mbps=10
    END

    Start Airphone BIP Traces
    Sleep  10s
    ${biptrace_file}=  Stop Airphone BIP Traces

    IF   '${cu_type}'=='SANSA'
        Stop Data Traffic In Egate      ue_id=11   direction=ul  id=1   trf_id=1
        UE Dual Connectivity Release    ue_id=11
        Detach UE From LTE              ue_id=11
    ELSE
        Stop Data Traffic In Egate    ue_id=1   direction=ul  id=1   trf_id=1
        Ue Deregister
    END
    File Should Exist           ${biptrace_file}
    File Should Not Be Empty    ${biptrace_file}
    The PCAP File Should Contain BIP Traces   ${biptrace_file}


*** Keywords ***

Bring Airphone To On Air Status
    UTE Cloud Workaround

    ${connected}=   Connect To Running Egate   ap_egate
    IF   ${connected}   RETURN

    ${wts_status}=    Run Keyword And Return Status    Bring Airphone TL To On Air Status Without Reboot
    IF    not ${wts_status}             Bring Airphone TL To On Air Status


Teardown The WTS Sim
    Teardown Egate Connection For Airphone
    Teardown Edaemon Connection For Airphone

The PCAP File Should Contain BIP Traces
    [Arguments]   ${biptrace_file}

    ${amount_of_bip_event_chaining_messages}=  Run   tshark -r ${biptrace_file} -Y bip_event_chaining | wc -l
    ${message_count}=   Convert To Integer   ${amount_of_bip_event_chaining_messages}
    Should Be True      ${message_count} > 100   There should at least be 100 bip messages, so we can sure to have bip traces!
