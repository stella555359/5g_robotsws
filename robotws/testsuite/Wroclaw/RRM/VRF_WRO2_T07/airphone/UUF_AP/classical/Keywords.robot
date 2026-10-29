*** Settings ***

Documentation    :copyright: Nokia

*** Keywords ***
Attach Multiple UE And Establish PDU Session With Traffic
    [Arguments]    ${first_ue}=1    ${last_ue}=10    ${pdu_id}=1    ${nwslice}=1    ${direction}=both    ${throughput}=10kbps
    FOR    ${index}    IN RANGE    ${first_ue}    ${last_ue}+1
        Attach Ue    ue_id=${index}
        Establish Pdu Session With Traffic    ue_id=${index}    pdu_id=${pdu_id}    nwslice=${nwslice}
        ...                                   gw_id=${index}    direction=${direction}    throughput=${throughput}
    END

Lock And Unlock All Cells Multiple Times
    [Arguments]    ${number_of_loops}=10
    FOR    ${index}    IN RANGE    1    ${number_of_loops}+1
        Lock All Cells
        Unlock All Cells
        Check All Cells Are Enabled
    END

Lock And Unlock Single Cell Multiple Times
    [Arguments]    ${number_of_loops}=10    ${cell_id}=1
    FOR    ${index}    IN RANGE    1    ${number_of_loops}+1
        Lock Single Cell    cell_id=${cell_id}
        Unlock Single Cell    cell_id=${cell_id}
    END

Block And Unblock All Cells Multiple Times
    [Arguments]    ${number_of_loops}=10
    FOR    ${index}    IN RANGE    1    ${number_of_loops}+1
        Block All Cells
        Unblock All Cells
        Check All Cells Are Enabled
    END

Block And Unblock Single Cell Multiple Times
    [Arguments]    ${number_of_loops}=10    ${cell_id}=1
    FOR    ${index}    IN RANGE    1    ${number_of_loops}+1
        Block Single Cell    cell_id=${cell_id}
        Unblock Single Cell    cell_id=${cell_id}
    END

Break F1 Link And Wait For Faults To Be Up
    Log To Console    Break F1 Link And Wait For Faults To Be Up
    Execute Enb Command    cmd=iptables -A OUTPUT -p sctp --dport 38472 -j DROP
    Execute Enb Command    cmd=ip6tables -A OUTPUT -p sctp --dport 38472 -j DROP
    Wait For Fault To Be Up    fault_id=7303    timeout=300
    Wait For Fault To Be Up    fault_id=7504    timeout=300

Restore F1 Link And Wait For Faults To Be Down
    Log To Console    Restore F1 Link And Wait For Faults To Be Down
    Execute Enb Command    cmd=iptables -t filter -F OUTPUT
    Execute Enb Command    cmd=ip6tables -t filter -F OUTPUT
    Wait For Fault To Be Down    fault_id=7303    timeout=300
    Wait For Fault To Be Down    fault_id=7504    timeout=300

Break F1 Link And Restore It Multiple Times
    [Arguments]    ${number_of_loops}=10
    FOR    ${index}    IN RANGE    1    ${number_of_loops}+1
        Break F1 Link And Wait For Faults To Be Up
        Restore F1 Link And Wait For Faults To Be Down
    END