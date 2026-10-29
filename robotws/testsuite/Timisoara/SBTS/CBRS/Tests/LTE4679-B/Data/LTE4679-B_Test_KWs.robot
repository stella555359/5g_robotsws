*** Settings ***
Documentation
...    = Author =
...    marek.kot@nokia.com
...    = Maintainer =
...    marek.kot@nokia.com
...    = Summary =
...    Set of Keywords used for LTE4237-specific System Testing

*** Keywords ***
Terminate cell
    [Arguments]    ${alias}    ${radio_id}    ${grant}     ${cell_id}    ${earfcn}
    Log    Grant terminate for neighbour cell    console=true
	Send Command To SAS Manager    default    grant_terminate ${radio_id} ${grant}
	Log    Wait for new earfcn
	Wait Until Keyword Succeeds    6x    30s    Query Infomodel    alias=${alias}    timeout=10
	...    query=check /MRBTS-1/RAT-1/BTS_L-*/BTS_CONF-*/NP-*/SCF-*/MRBTS_A-*/LNBTS_A-*/LNCEL_A-${cell_id}/LNCEL_TDD_A-* is [earfcn!=${earfcn}]
    Wait For All Cells To Be OnAir    alias=${alias}

Get N Random Cells From Cells List
	[Arguments]    ${cell_list}    ${n}
	${cell_pair}   Evaluate    random.sample(${cell_list}, ${n})    modules=random
	RETURN    ${cell_pair}

Get Random Cell
	[Arguments]    ${cbsd_object}    ${alias}=RAT_1ST
	${rmod_object}   Query Infomodel    alias=${alias}    query=get object ${cbsd_object["rmodDN"]}
	${status_old_list}   Run Keyword And Return Status    Dictionary Should Contain Key    ${rmod_object}    activeCellsList
    ${status_new_list}   Run Keyword And Return Status    Dictionary Should Contain Key    ${rmod_object}    activeLteCellsList
    ${cells_list}   Set Variable If    '${status_old_list}'=='True' and '${status_new_list}'=='False'
    ...    ${rmod_object["activeCellsList"]}    ${rmod_object["activeLteCellsList"]}
	${cell}   Evaluate    random.sample(${cells_list}, 1)    modules=random
	RETURN    ${cell[0]}

Get Cells List From CBSD
	[Arguments]    ${cbsd_object}    ${alias}=RAT_1ST
	${rmod_object}   Query Infomodel    alias=${alias}    query=get object ${cbsd_object["rmodDN"]}
	${status_old_list}   Run Keyword And Return Status    Dictionary Should Contain Key    ${rmod_object}    activeCellsList
    ${status_new_list}   Run Keyword And Return Status    Dictionary Should Contain Key    ${rmod_object}    activeLteCellsList
    ${cells_list}   Set Variable If    '${status_old_list}'=='True' and '${status_new_list}'=='False'
    ...    ${rmod_object["activeCellsList"]}    ${rmod_object["activeLteCellsList"]}
	RETURN    ${cells_list}


Check If No Additional Fault Occurs
    [Arguments]      ${allowed_faults}   ${historical_alarms}
    ${historical_alarms}    Remove Duplicates    ${historical_alarms}
    ${faults_to_delete}   Create List

    #Check if all of expected alarms are present on eNB
    FOR    ${fault}    IN    @{allowed_faults}
        ${fault}    Convert To Integer    ${fault}
        Append To List    ${faults_to_delete}    ${fault}
    END

    Remove Values From List    ${historical_alarms}    @{faults_to_delete}
    Should Be Empty    ${historical_alarms}