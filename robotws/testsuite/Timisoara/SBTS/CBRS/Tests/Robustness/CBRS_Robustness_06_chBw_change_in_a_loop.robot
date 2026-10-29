*** Settings ***
Documentation
...    = Author =
...    katarzyna.kadziela@nokia.com
...    = Maintainer =
...    katarzyna.kadziela@nokia.com
...    = Reviewer =
...    aleksandra.chudzik@nokia.com
...    lukasz.lechowicz@nokia.com
...    piotr.lukaszewicz@nokia.com
...    karol.sadowski@nokia.com
...    = Summary =
...    Purpose: Verify system behavior in case of many random chBw changes.

*** Keywords ***
CBRS_Robustness_06_chBw_change_in_a_loop
    [Documentation]  Purpose: Verify system behavior in case of many random chBw changes.
    [Timeout]    500min

    ${num_of_loops}   Set Variable    1
    ${enb_id}   Set Variable    ${testlines.${testline_id}.enb_id}

    Disable CBRS Feature On eNB
    Kill All SAS Processes
    Check If Cells Are Disabled     ${enb_id}
    Enable CBRS Feature On eNB
    Enable Carrier Aggregation    ${enb_id}    alias=RAT_1ST
    Wait Until BTS Is Not Busy
    ${sas_pid}    ${sas_logs_dir} =    Start SAS Process    config=${CURDIR}/Data/Robustness_06/SAS_Sim.conf
    Wait For All Cells To Be OnAir
    Log    ${\n}CBRS feature enabled, cells are on air    console=true
    Start Capturing Historical Alarms

    @{changes}   Create List    Change ChBw For All Cells Depending On Value
    ...                           Change ChBw For Random Cell Depending On Value

    FOR  ${loop_nr}  IN RANGE  0  ${num_of_loops}
        Log to console with time  ---Change of chBw - loop ${loop_nr+1}--

        #Getting CBSD parameters
        ${cbsd_mo}    Get Random Cbsd Object    alias=RAT_1ST
        ${cbsd_id}    Get Cbsd Id From Cbsd Object    ${cbsd_mo}    alias=RAT_1ST
        ${cbrspr_id}    Get Cbrspr Id From Cbsd Object    ${cbsd_mo}    alias=RAT_1ST
        ${channelSpace_list}   Set Random ChannelSpace Values    ${enb_id}    ${cbsd_id}    ${cbrspr_id}

        ${random_change}   Evaluate    random.sample(${changes}, 1)    modules=random
        IF  '${random_change[0]}'=='Change ChBw For All Cells Depending On Value'
            Change ChBw For All Cells Depending On Value    ${enb_id}
        ELSE IF  '${random_change[0]}'=='Change ChBw For Random Cell Depending On Value'
            Change ChBw For Random Cell Depending On Value    ${enb_id}
        END
        Wait For All Cells To Be OnAir

        #Check if cells are adjacent and channelSpaces has correct value
        Check If Assigned Bandwidth Is Continuous
        Check If Channel Spaces Between Cells Have Correct Distance    ${cbsd_mo}     ${channelSpace_list}
    END

    [Teardown]    Run Keywords    Wait Until Keyword Succeeds   2x    60s
    ...                           Get SAS Logs To Logs Dir    alias=default    AND
    ...                           Kill All SAS Processes


*** Keywords ***
Get Cbrspr Id From Cbsd Object
    [Documentation]  Description:           Gets cbrsPrId from Infomodel.${\n}
    ...              Return:                cbrsPrId${\n}
    ...              Output:                { ${string} }${\n}
    ...              Author:                marek.kot@nokia.com${\n}
    ...              Maintainer:            CBRS Team${\n}
    [Arguments]     ${cbsd_mo}    ${alias}=RAT_1ST
    ${query}   Set Variable    /MRBTS-1/RAT-1/RUNTIME_VIEW-*/MRBTS_R-*/LNBTS_R-${testlines.${testline_id}.enb_id}/CBSD_R-*
    ${cbsd_r_mo}   Query Infomodel    alias=${alias}
    ...    query=get object ${query} is [assignedCbsdId=${cbsd_mo["assignedCbsdId"]}]
    ${conf_ref_mo}   Query Infomodel    alias=${alias}    query=get object ${cbsd_r_mo.dist_name}/CONF_REF-1
    ${cbrspr_mo}   Query Infomodel    alias=${alias}    query=get object ${conf_ref_mo.distName}
    ${cbrspr_id}   Convert To String    ${cbrspr_mo["cbrsPrId"]}
    RETURN    ${cbrspr_id}


Set Random ChannelSpace Values
    [Documentation]  Description:           Setting randomly picked value for channelSpace list.${\n}
    ...              Return:                channelSpace_list${\n}
    ...              Output:                { &{list} }${\n}
    ...              Author:                katarzyna.kadziela@nokia.com${\n}
    ...              Maintainer:            CBRS Team${\n}
    [Arguments]     ${enb_id}    ${cbsd_id}    ${cbrspr_id}
    ${channelSpace1010}   Get Random ChannelSpace Value From List    9.9     9.6     9.3
    ${channelSpace1020}   Get Random ChannelSpace Value From List    14.4    14.1    13.8
    ${channelSpace2020}   Get Random ChannelSpace Value From List    19.8    19.5    19.2
    ${channelSpace_list}   Create channelSpace List
    ...                      ${channelSpace1010}    ${channelSpace1020}    ${channelSpace2020}
    Replace Variables In File    file_path=${CURDIR}/Data/Robustness_06/Robustness_06_channelSpace_change.json
    ...    file_destination=${OUTPUT_DIR}/Robustness_06_channelSpace_change.json
    ...    enb_id=${enb_id}    cbsd_id=${cbsd_id}    cbrspr_id=${cbrspr_id}
    ...    channelSpace1010=${channelSpace1010}
    ...    channelSpace1020=${channelSpace1020}
    ...    channelSpace2020=${channelSpace2020}
    Wait Until BTS Is Not Busy
    Wait Until Keyword Succeeds    5x    30s    Run Keywords
    ...    Wait Until BTS Is Not Busy    AND
    ...    Perform Delta Recommissioning
    ...    delta_file=${OUTPUT_DIR}/Robustness_06_channelSpace_change.json
    ...    skip_parameter_relation_errors=${TRUE}    connection=RAT_1ST

    Wait For All Cells To Be OnAir
    RETURN     ${channelSpace_list}


Get Random ChannelSpace Value From List
    [Documentation]  Description:           Get one random value from given channelSpace list.${\n}
    ...              Return:                channelSpace value${\n}
    ...              Output:                { ${string} }${\n}
    ...              Author:                marek.kot@nokia.com${\n}
    ...              Maintainer:            CBRS Team${\n}
    [Arguments]      ${value_1}    ${value_2}    ${value_3}
    ${channelSpace_random_value}   Evaluate    random.sample([${value_1}, ${value_2}, ${value_3}], 1)[0]
    ...                              modules=random
    RETURN    ${channelSpace_random_value}


Create channelSpace List
    [Documentation]  Description:           Create a list from given channelSpace values.${\n}
    ...              Return:                channelSpace list${\n}
    ...              Output:                { }${\n}
    ...              Author:                marek.kot@nokia.com${\n}
    ...              Maintainer:            CBRS Team${\n}
    [Arguments]    ${channelSpace1010}    ${channelSpace1020}    ${channelSpace2020}
    ${channelSpace_list}   Evaluate
    ...                      [int(${channelSpace1010}*10), int(${channelSpace1020}*10), int(${channelSpace2020}*10)]
    RETURN    ${channelSpace_list}


Change ChBw For All Cells Depending On Value
    [Documentation]  Description:           Setting chBw value for 10 or 20 MHz for all cells depending on previous
    ...                                     value.${\n}
    ...              Return:                None${\n}
    ...              Output:                None${\n}
    ...              Author:                katarzyna.kadziela@nokia.com${\n}
    ...              Maintainer:            CBRS Team${\n}
    [Arguments]    ${enb_id}
    FOR    ${i}    IN RANGE    ${1}    ${5}
        ${chBw}   Query Infomodel    alias=RAT_1ST
        ...    query=get object /MRBTS-1/RAT-1/MCTRL-*/BBTOP_M-*/MRBTS_M-*/LNBTS_M-*/CELL_M-${i}/LNCEL_M-${i}
        ${ulChBw}   Get From Dictionary    ${chBw}    ulChBw
        IF  '${ulChBw}'=='10000000'
            Change ChBw For All Cells To 20 MHz    enb_id=${enb_id}
        ELSE IF  '${ulChBw}'=='20000000'
            Change ChBw For All Cells To 10 MHz    enb_id=${enb_id}
        END
        Exit For Loop
    END


Change ChBw For All Cells To 10 MHz
    [Documentation]  Description:           Setting chBw value for 10 MHz for all cells.${\n}
    ...              Return:                None${\n}
    ...              Output:                None${\n}
    ...              Author:                katarzyna.kadziela@nokia.com${\n}
    ...              Maintainer:            CBRS Team${\n}
    [Arguments]    ${enb_id}
    Replace Variables In File    ${CURDIR}/Data/Robustness_06/Robustness_06_set_chBw_to_10_MHz.json
    ...    ${OUTPUT_DIR}/Robustness_06_set_chBw_to_10_MHz.json    ENB_ID=${enb_id}
    Wait Until BTS Is Not Busy
    Wait Until Keyword Succeeds    5x    30s    Run Keywords
    ...    Wait Until BTS Is Not Busy    AND
    ...    Perform Delta Recommissioning
    ...    delta_file=${OUTPUT_DIR}/Robustness_06_set_chBw_to_10_MHz.json
    ...    skip_parameter_relation_errors=${TRUE}    connection=RAT_1ST


Change ChBw For All Cells To 20 MHz
    [Documentation]  Description:           Setting chBw value for 20 MHz for all cells.${\n}
    ...              Return:                None${\n}
    ...              Output:                None${\n}
    ...              Author:                katarzyna.kadziela@nokia.com${\n}
    ...              Maintainer:            CBRS Team${\n}
    [Arguments]    ${enb_id}
    Replace Variables In File    ${CURDIR}/Data/Robustness_06/Robustness_06_set_chBw_to_20_MHz.json
    ...    ${OUTPUT_DIR}/Robustness_06_set_chBw_to_20_MHz.json    ENB_ID=${enb_id}
    Wait Until BTS Is Not Busy
    Wait Until Keyword Succeeds    5x    30s    Run Keywords
    ...    Wait Until BTS Is Not Busy    AND
    ...    Perform Delta Recommissioning
    ...    delta_file=${OUTPUT_DIR}/Robustness_06_set_chBw_to_20_MHz.json
    ...    skip_parameter_relation_errors=${TRUE}    connection=RAT_1ST


Change ChBw For Random Cell Depending On Value
    [Documentation]  Description:           Setting chBw value for 10 or 20 MHz for a given cell depending on
    ...                                     previous value.${\n}
    ...              Return:                None${\n}
    ...              Output:                None${\n}
    ...              Author:                katarzyna.kadziela@nokia.com${\n}
    ...              Maintainer:            CBRS Team${\n}
    [Arguments]    ${enb_id}
    ${cell_ID}   Get Random Cell ID    alias=RAT_1ST
    ${random_cell}   Fetch From Right    ${cell_ID}    -
    ${chBw}   Query Infomodel    alias=RAT_1ST
    ...    query=get object /MRBTS-1/RAT-1/MCTRL-*/BBTOP_M-*/MRBTS_M-*/LNBTS_M-*/CELL_M-${random_cell}/LNCEL_M-${random_cell}
    ${ulChBw}   Get From Dictionary    ${chBw}    ulChBw
    IF  '${ulChBw}'=='10000000'
        Change ChBw For One Cell To 20 MHz  enb_id=${enb_id}    random_cell=${random_cell}
    ELSE IF  '${ulChBw}'=='20000000'
        Change ChBw For One Cell To 10 MHz  enb_id=${enb_id}    random_cell=${random_cell}
    END


Change ChBw For One Cell To 10 MHz
    [Documentation]  Description:           Setting chBw value for 10 MHz for a given cell.${\n}
    ...              Return:                None${\n}
    ...              Output:                None${\n}
    ...              Author:                katarzyna.kadziela@nokia.com${\n}
    ...              Maintainer:            CBRS Team${\n}
    [Arguments]    ${enb_id}    ${random_cell}
    Replace Variables In File    ${CURDIR}/Data/Robustness_06/Robustness_06_set_chBw_to_10_MHz_for_one_cell.json
    ...    ${OUTPUT_DIR}/Robustness_06_set_chBw_to_10_MHz_for_one_cell.json
    ...    ENB_ID=${enb_id}    RANDOM_CELL=${random_cell}
    Wait Until BTS Is Not Busy
    Wait Until Keyword Succeeds    5x    30s    Run Keywords
    ...    Wait Until BTS Is Not Busy    AND
    ...    Perform Delta Recommissioning
    ...    delta_file=${OUTPUT_DIR}/Robustness_06_set_chBw_to_10_MHz_for_one_cell.json
    ...    skip_parameter_relation_errors=${TRUE}    connection=RAT_1ST


Change ChBw For One Cell To 20 MHz
    [Documentation]  Description:           Setting chBw value for 20 MHz for a given cell.${\n}
    ...              Return:                None${\n}
    ...              Output:                None${\n}
    ...              Author:                katarzyna.kadziela@nokia.com${\n}
    ...              Maintainer:            CBRS Team${\n}
    [Arguments]    ${enb_id}    ${random_cell}
    Replace Variables In File    ${CURDIR}/Data/Robustness_06/Robustness_06_set_chBw_to_20_MHz_for_one_cell.json
    ...    ${OUTPUT_DIR}/Robustness_06_set_chBw_to_20_MHz_for_one_cell.json
    ...    ENB_ID=${enb_id}    RANDOM_CELL=${random_cell}
    Wait Until BTS Is Not Busy
    Wait Until Keyword Succeeds    5x    30s    Run Keywords
    ...    Wait Until BTS Is Not Busy    AND
    ...    Perform Delta Recommissioning
    ...    delta_file=${OUTPUT_DIR}/Robustness_06_set_chBw_to_20_MHz_for_one_cell.json
    ...    skip_parameter_relation_errors=${TRUE}    connection=RAT_1ST


Check If Assigned Bandwidth Is Continuous
    [Documentation]  Description:           Check if there is no gap between cells. It is recommended to use this KW
    ...                                     after first  resource negotiation between CBSD and SAS, for BTS with CA
    ...                                     enabled.${\n}
    ...              Return:                None${\n}
    ...              Output:                None${\n}
    ...              Author:                katarzyna.kadziela@nokia.com${\n}
    ...              Maintainer:            CBRS Team${\n}

    ${grant_info_list}   ute_admin_infomodel.Query Infomodel
    ...    query=get list /MRBTS-1/RAT-1/SYSADAPTER-*/CBRS-*/CBSD-*/GRANT_INFO-*    alias=RAT_1ST
    ${grant_count}   Get Length    ${grant_info_list}
    ${grant_id_list}   Create List
    FOR    ${i}    IN RANGE    ${grant_count}
        ${grant_id_full}   Set Variable    ${grant_info_list[${i}]['grantId']}
        ${grant_id}   Split String    ${grant_id_full}    _
        ${grant_id_list}   Combine Lists    ${grant_id_list}    ${grant_id}
    END

    Sort List    ${grant_id_list}
    Remove From List    ${grant_id_list}    0
    Remove From List    ${grant_id_list}    -1
    ${list_count}    Get Length    ${grant_id_list}
    #Iterate every 2nd item in a list to compare if high frequency of a grant X is equal low frequency of a grant X+1.
    FOR    ${i}    IN RANGE    ${list_count}
        ${is_even}  Evaluate  float(${i}) / 2
        IF  '${is_even}'=='0.0' or '${is_even}'=='1.0' or '${is_even}'=='2.0'
            Should Be Equal    ${grant_id_list[${i}]}    ${grant_id_list[${i+1}]}
        ELSE
            CONTINUE
        END
    END


Check If Channel Spaces Between Cells Have Correct Distance
    [Documentation]  Description:           Check if selected channel spaces are visible.${\n}
    ...              Return:                None${\n}
    ...              Output:                { @{list} }${\n}
    ...              Author:                marek.kot@nokia.com${\n}
    ...              Maintainer:            CBRS Team${\n}
    [Arguments]    ${cbsd_object}    ${channelSpace_list}
    ${frequency_list}   Get Frequency List From Cells On Cbsd    ${cbsd_object}
    FOR    ${i}    IN RANGE    3
        ${space}   Evaluate    int(${frequency_list[${i}+1]}-${frequency_list[${i}]})
        List Should Contain Value    ${channelSpace_list}    ${space}
    END


Get Frequency List From Cells On Cbsd
    [Documentation]  Description:           Gets frequency values from Infomodel for a given CBSD object.${\n}
    ...              Return:                List of fetched parameters from infomodel.${\n}
    ...              Output:                { @{list} }${\n}
    ...              Author:                marek.kot@nokia.com${\n}
    ...              Maintainer:            CBRS Team${\n}
    [Arguments]     ${cbsd_mo}    ${alias}=RAT_1ST
    ${frequency_list}   Create List
    ${cells_list}   Get Cells List From Cbsd Object    ${cbsd_mo}    ${alias}
    FOR    ${cell}    IN    @{cells_list}
        ${cell_mo}   Query Infomodel    alias=${alias}
        ...    query=get object /MRBTS-1/RAT-1/MCTRL-*/BBTOP_M-*/MRBTS_M-*/LNBTS_M-*/CELL_M-${cell}/CHANNEL_GROUP_M-1
        Append To List    ${frequency_list}      ${cell_mo.fcnULs}
    END
    Sort List    ${frequency_list}
    ${frequency_list}   Evaluate    [i*0.00001 for i in map(int, ${frequency_list})]
    RETURN    ${frequency_list}















