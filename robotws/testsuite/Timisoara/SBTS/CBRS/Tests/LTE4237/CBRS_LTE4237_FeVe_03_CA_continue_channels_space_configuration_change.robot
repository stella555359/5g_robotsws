*** Settings ***
Documentation
...    = Author =
...    _marek.kot@nokia.com_
...    = Maintainer =
...    _piotr.lukaszewicz@nokia.com_
...    = Reviewer =
...
...    = Summary =
...    Purpose: Verify whether eNB use correct channel space when CA is enabled
...    Step 1. Prepare and provision random channelSpace values between cells 1010, 1020 and 2020
...    Step 2. Check if selected channel spaces are visible

*** Keywords ***
CBRS_LTE4237_FeVe_03_CA_continue_channels_space_configuration_change
    [Documentation]    Requirement: OM_GEN_SFS_CBRS.293

    ${enb_id}     Set Variable    ${testlines.${testline_id}.enb_id}
    Kill All SAS Processes
    Check If Cells Are Disabled    ${enb_id}

    Replace Variables In File    ${CURDIR}/Data/FeVe03/FEVE_3_set_chBw_to_20_MHz.json    ${OUTPUT_DIR}/FEVE_3_set_chBw_to_20_MHz.json
    ...    ENB_ID=${enb_id}
    Replace Variables In File    ${CURDIR}/Data/FeVe03/FEVE_3_set_chBw_to_10_MHz.json    ${OUTPUT_DIR}/FEVE_3_set_chBw_to_10_MHz.json
    ...    ENB_ID=${enb_id}

    Enable CBRS Feature On eNB

    #Checking if channel bandwidth is set to 20 MHz for all CBSD cells
    FOR    ${i}    IN RANGE    ${1}    ${5}
        ${is_chBw_20MHz}   Run Keyword And Return Status    Query Infomodel    alias=RAT_1ST
        ...    query=check /MRBTS-1/RAT-1/MCTRL-*/BBTOP_M-*/MRBTS_M-*/LNBTS_M-*/CELL_M-${i}/LNCEL_M-${i} is [ulChBw=20000000]
        IF  '${is_chBw_20MHz}'=='False'  Wait Until BTS Is Not Busy
        IF  '${is_chBw_20MHz}'=='False'  Perform Delta Recommissioning  delta_file=${OUTPUT_DIR}/FEVE_3_set_chBw_to_20_MHz.json
        ...  skip_parameter_relation_errors=${TRUE}  connection=RAT_1ST
        IF  '${is_chBw_20MHz}'=='False'  BREAK
    END
    Log To Console    Channel bandwidth is set to 20 MHz for all CBSD cells

    ${required_spectrum}   Create List    3560    3565    3570    3575    3580    3585    3590    3595    3600    3605
    ...                                     3610    3615    3620    3625    3630    3635    3640    3645    3650    3655
    ...                                     3660    3665    3670    3675    3680    3685
    Set Supported Spectrum    bts_id=${enb_id}    target_spectrum_list=${required_spectrum}

    #Check if Carrier Aggregation is active
    Enable Carrier Aggregation    ${enb_id}    alias=RAT_1ST
    Wait Until BTS Is Not Busy

    ${sas_pid}    ${sas_logs_dir} =    Start SAS Process    default    4433    config=${CURDIR}/Data/FeVe03/SAS_Sim.conf
    Wait For All Cells To Be OnAir
    Start Watchdog Alarm Detection

    #Step 1. Prepare preconditon
    ${cbsd_mo}   Get Random Cbsd Object    alias=RAT_1ST
    ${cbsd_id}   Get Cbsd Id From Cbsd Object    ${cbsd_mo}    alias=RAT_1ST
    ${cbrspr_id}   Get Cbrspr Id From Cbsd Object    ${cbsd_mo}    alias=RAT_1ST
    ${cells_list}   Get Cells List From Cbsd Object    ${cbsd_mo}    alias=RAT_1ST

    ${channelSpace1010}   Get Random ChannelSpace Value From List    9.9     9.6     9.3
    ${channelSpace1020}   Get Random ChannelSpace Value From List    14.4    14.1    13.8
    ${channelSpace2020}   Get Random ChannelSpace Value From List    19.8    19.5    19.2
    ${channelSpace_list}   Create channelSpace List    ${channelSpace1010}    ${channelSpace1020}    ${channelSpace2020}

    Replace Variables In File    file_path=${CURDIR}/Data/FeVe03/FEVE_3_Precondition_delta.json
    ...    file_destination=${OUTPUT_DIR}/FEVE_3_Precondition_delta_tmp.json
    ...    enb_id=${enb_id}    cbsd_id=${cbsd_id}    cbrspr_id=${cbrspr_id}
    ...    cell_1_id=${cells_list[0]}    cell_2_id=${cells_list[1]}
    ...    channelSpace1010=${channelSpace1010}    channelSpace1020=${channelSpace1020}    channelSpace2020=${channelSpace2020}
    Wait Until Keyword Succeeds    6x    10s    Run Keywords
    ...    Wait Until BTS Is Not Busy    AND
    ...    Perform Delta Recommissioning    delta_file=${OUTPUT_DIR}/FEVE_3_Precondition_delta_tmp.json    connection=RAT_1ST
    Wait For Any Cell To Be Dropped
    Wait For All Cells To Be OnAir

    #Step 2. Check channel spaces between cells
    Check If Channel Spaces Between Cells Have Correct Distance    ${cbsd_mo}    ${channelSpace_list}

    Wait Until BTS Is Not Busy
    Wait Until Keyword Succeeds    5x    30s    Disable Carrier Aggregation    ${enb_id}    alias=RAT_1ST
    Replace Variables In File    file_path=${CURDIR}/Data/FeVe03/FEVE_3_Postcondition_delta.json
    ...    file_destination=${OUTPUT_DIR}/FEVE_3_Postcondition_delta_tmp.json
    ...    enb_id=${enb_id}    cell_1_id=${cells_list[0]}    cell_2_id=${cells_list[1]}
    Wait Until Keyword Succeeds    6x    10s    Run Keywords
    ...    Wait Until BTS Is Not Busy    AND
    ...    Perform Delta Recommissioning    delta_file=${OUTPUT_DIR}/FEVE_3_Postcondition_delta_tmp.json    connection=RAT_1ST
    Wait For All Cells To Be OnAir

    [Teardown]    Run Keywords
    ...    Get SAS Logs To Logs Dir    alias=default    AND
    ...    Wait Until BTS Is Not Busy    alias=RAT_1ST    AND
    ...    Wait Until Keyword Succeeds    3x    60s  Perform Delta Recomissioning For Teardown Feve 03  ${is_chBw_20MHz}  AND
    ...    Wait For All Cells To Be OnAir    AND
    ...    Restore Supported Spectrum    bts_id=${enb_id}    AND
    ...    Stop Watchdog Alarm Detection And Check For Failures    AND
    ...    Kill All SAS Processes


Perform Delta Recomissioning For Teardown Feve 03
    [Arguments]  ${is_chBw_20MHz}

    IF  '${is_chBw_20MHz}'=='False'  Perform Delta Recommissioning
    ...    ${OUTPUT_DIR}/FEVE_3_set_chBw_to_10_MHz.json    skip_parameter_relation_errors=${TRUE}    connection=RAT_1ST


Get Cbrspr Id From Cbsd Object
    [Documentation]    Author: Marek Kot
    [Arguments]     ${cbsd_mo}    ${alias}=RAT_1ST
    ${query}   Set Variable    /MRBTS-1/RAT-1/RUNTIME_VIEW-*/MRBTS_R-*/LNBTS_R-${testlines.${testline_id}.enb_id}
    ${cbsd_r_mo}   Query Infomodel    alias=${alias}
    ...    query=get object ${query}/CBSD_R-* is [assignedCbsdId=${cbsd_mo["assignedCbsdId"]}]
    ${conf_ref_mo}   Query Infomodel    alias=${alias}    query=get object ${cbsd_r_mo.dist_name}/CONF_REF-1
    ${cbrspr_mo}   Query Infomodel    alias=${alias}    query=get object ${conf_ref_mo.distName}
    ${cbrspr_id}   Convert To String    ${cbrspr_mo["cbrsPrId"]}
    RETURN    ${cbrspr_id}

Get Frequency List From Cells On Cbsd
    [Documentation]    Author: Marek Kot
    [Arguments]     ${cbsd_mo}    ${alias}=RAT_1ST
    ${frequency_list}   Create List
    ${cells_list}   Get Cells List From Cbsd Object    ${cbsd_mo}    ${alias}
    FOR    ${cell}    IN    @{cells_list}
        ${cell_mo}   Query Infomodel    alias=${alias}
        ...    query=get object /MRBTS-1/RAT-1/MCTRL-*/BBTOP_M-*/MRBTS_M-*/LNBTS_M-*/CELL_M-${cell}/CHANNEL_GROUP_M-1
        Append To List    ${frequency_list}    ${cell_mo.fcnULs}[0]
    END
    Sort List    ${frequency_list}
    ${frequency_list}   Evaluate    [i*0.00001 for i in map(int, ${frequency_list})]
    RETURN    ${frequency_list}

Check If Channel Spaces Between Cells Have Correct Distance
    [Documentation]    Check if selected channel spaces are visible.
    ...                Author: Marek Kot
    [Arguments]    ${cbsd_object}    ${channelSpace_list}
    ${frequency_list}   Get Frequency List From Cells On Cbsd    ${cbsd_object}
    FOR    ${i}    IN RANGE    3
        ${space}   Evaluate    int(${frequency_list[${i}+1]}-${frequency_list[${i}]})
        List Should Contain Value    ${channelSpace_list}    ${space}
    END

Get Random ChannelSpace Value From List
    [Documentation]    Get one value from given list.
    ...                Author: Marek Kot
    [Arguments]      ${value_1}    ${value_2}    ${value_3}
    ${channelSpace_random_value}   Evaluate    random.sample([${value_1}, ${value_2}, ${value_3}], 1)[0]    modules=random
    RETURN    ${channelSpace_random_value}

Create channelSpace List
    [Documentation]    Author: Marek Kot
    [Arguments]    ${channelSpace1010}    ${channelSpace1020}    ${channelSpace2020}
    ${channelSpace_list}   Evaluate    [int(${channelSpace1010}*10), int(${channelSpace1020}*10), int(${channelSpace2020}*10)]
    RETURN    ${channelSpace_list}
