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
        Sleep    10s
        Unlock All Cells
        Wait For All Cells To Be Enabled Aic    timeout=30
        Check All Cells Are Enabled Aic
    END

Lock And Unlock Single Cell Multiple Times
    [Arguments]    ${number_of_loops}=10    ${cell_id}=1
    FOR    ${index}    IN RANGE    1    ${number_of_loops}+1
        Lock Single Cell    cell_id=${cell_id}
        Sleep    1s
        Unlock Single Cell    cell_id=${cell_id}
        Wait For All Cells To Be Enabled Aic    timeout=30
        Check Single Cell Aic    cell_id=1    search_key=operational_state    expected_state=enabled
    END

Block And Unblock All Cells Multiple Times
    [Arguments]    ${number_of_loops}=10
    FOR    ${index}    IN RANGE    1    ${number_of_loops}+1
        Block All Cells
        Sleep    10s
        Unblock All Cells
        Wait For All Cells To Be Enabled Aic    timeout=30
        Check All Cells Are Enabled Aic
    END

Block And Unblock Single Cell Multiple Times
    [Arguments]    ${number_of_loops}=10    ${cell_id}=1
    FOR    ${index}    IN RANGE    1    ${number_of_loops}+1
        Block Single Cell    cell_id=${cell_id}
        Sleep    10s
        Unblock Single Cell    cell_id=${cell_id}
        Wait For All Cells To Be Enabled Aic    timeout=300
        Check All Cells Are Enabled Aic
        Check Single Cell Aic    cell_id=1    search_key=operational_state    expected_state=enabled
    END
