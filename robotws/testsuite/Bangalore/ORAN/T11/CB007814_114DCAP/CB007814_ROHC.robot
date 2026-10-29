*** Settings ***
Documentation
...               Feature ID: CB007814
#Suite Setup       Run Keywords    Suite Setup Update GNB
###...               AND    Stop suite BTSlog
#Suite Teardown    Run Keywords    Common Suite Teardown
#...               AND    Wait Until Keyword Succeeds    ${MAX_WAITTIME_CONFIGURED}    30s    Verify BTS Is OnAir
Resource          ../resources/Common_resource.robot
Resource                  ./resources/CB007623_keywords.robot
Library    		  taf.sw.dcap.rd     WITH NAME   dcap
Force Tags        CRT    FL00   SBTS24R3     QCD_MN_RAN    QCP_RAN_VRF


Test setup        CB007623_keywords.Admin Setup
Test Teardown     CB007623_keywords.Admin Teardown

*** Variables ***
&{CB007814_5GC000774_Verification_VONR_with_ROHC_enabled_UE_with_IPv4_with_FDD}
...     QC_ID_FL00=QC_31510   QC_ID_SBTS24R3=QC_852737
${ASP_BOARD_TYPE}     ABIO0
${Retry_count}    		    2
@{direction}                dl                                                   # Direction for data
@{capabilities}				Legacy_2											# UE capability
@{data_transfer_protocol}       UDP
${voice_call_TC}=    VONR_Server_Call_automation
${dist_name}     MRBTS-1236/NRBTS-1236
@{UE_alias}      UE2
@{LTE_cell}     0
@{NR_cell}      3
${dict}     ['BTS']['MRBTS-1236']['NRBTS-1236']['NRCELL-1']['NRRCC']
*** Test Cases ***
CB007814_5GC000774_Verification_VONR_with_ROHC_enabled_UE_with_IPv4_with_FDD
#    Set Suite variable   ${message_col}  ${5}
#    Set Suite variable   ${content_col}  ${19}
    Dcap Start Trace SA
    Lock cells  ${LTE_cell}
    Lock NR cells  ${NR_cell}
    Parameter value change    ${dist_name}		 actRohc		true
    Parameter value change    ${dist_name}/NRCELL-1		 actEnhancedVoNR		true
    Parameter value change    ${dist_name}/NRCELL-3		 actEnhancedVoNR		true
	ta_ultracaller.Require UE   ue_alias=${UE_alias}   capabilities=${capabilities}
    ta_ultracaller.Detach UE     ue_alias=${UE_alias}
    ta_ultracaller.Attach UE     ue_alias=${UE_alias}
	ta_ultracaller.start_voice_call    ${UE_alias}    ${voice_call_TC}
	sleep    40
	ta_ultracaller.stop_voice_call    ${UE_alias}
    Parameter value change    ${dist_name}		 actRohc		false
    Parameter value change    ${dist_name}/NRCELL-1		 actEnhancedVoNR		false
    Parameter value change    ${dist_name}/NRCELL-3		 actEnhancedVoNR		false

    Dcap Stop Trace and Get results SA
    Run keyword and continue on failure     Unlock cells    ${LTE_cell}
    Run keyword and continue on failure     Unlock NRcells  ${NR_cell}
    @{check}	Create list     PDUSessionResourceModifyRequest::fiveQI 1
	Verify Emil logs    @{check}
    Counter value ROHC    M55135C01001
    Counter value ROHC    M55135C01002
    Counter value ROHC    M55135C01003
    Counter value ROHC NRRCC    M55124C06001
    Counter value ROHC NRRCC    M55124C06002


*** Keywords ***
Counter value ROHC
    [Arguments]    ${counter_name}
    [Documentation]     Check counter value of gnb
    Log to console      \nChecking gnb counter   ${counter_name}
    ${result}     Wait Until Keyword Succeeds    ${Retry_count} times    60      COAM.get_pm_counters
    ...     counter_ids=${counter_name}    timeout=60    connection=${connection}
    log    ${result}
    ${values}    Get Dictionary Values    ${result['BTS']['MRBTS-1236']['NRBTS-1236']['NE1CS']['${counter_name}']}
    ${Total_Count}    Get value of Counter    ${values}
    Should Be True      ${Total_Count} > 1
    [Return]    ${Total_Count}

Counter value ROHC NRRCC
    [Arguments]    ${counter_name}
    [Documentation]     Check counter value of gnb
    Log to console      \nChecking gnb counter   ${counter_name}
    ${result}     Wait Until Keyword Succeeds    ${Retry_count} times    60      COAM.get_pm_counters
    ...     counter_ids=${counter_name}    timeout=60    connection=${connection}
    log    ${result}
    ${dict}     Catenate    ${dict} ['${counter_name}']
    ${values}=      Get Dictionary Values   ${result${dict}}
    ${Total_Count}    Get value of Counter    ${values}
    Should Be True      ${Total_Count} > 1
    [Return]    ${Total_Count}

