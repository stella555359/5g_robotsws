*** Settings ***
Documentation
...    = Author =
...    marek.kot@nokia.com
...    = Maintainer =
...    piotr.lukaszewicz@nokia.com
...    = Reviewer =
...    artur.czainski@nokia.com
...    lukasz.lechowicz@nokia.com
...    = Summary =
...    Purpose: Verify RSSI selection algorithm
...    eNB should choose the best frequency channels from 12 grants due to optimal frequency selection based on RSSI,
...    the RSSI lower the channel is better. Carrier Aggregation feature is disabled.

*** Keywords ***
CBRS_LTE5177_FeVe_01_Lower_RSSI_channels_selection_when_CA_is_disabled
    [Documentation]    Requiement: LTE_OPR_REQ_14652
    [Timeout]    30min

    ${enb_id}   Set Variable    ${testlines.${testline_id}.enb_id}
    @{expected_alarms}   Create List     SAS Registration Failure

    Kill All SAS Processes
    Disable CBRS Feature On eNB
    Disable Carrier Aggregation    ${enb_id}    alias=RAT_1ST

    Start Capturing Historical Alarms

    ${cbsd_1st}         Get Random Cbsd Object    alias=RAT_1ST
    ${cells_list_1st}   Get Cells List From Cbsd Object    ${cbsd_1st}    alias=RAT_1ST
    ${cbsd_id_1st}      Get Cbsd Id From Cbsd Object    ${cbsd_1st}    alias=RAT_1ST
    Replace Variables In File    ${CURDIR}/Data/FeVe01/FEVE_1_RAT_1ST_Precondition.json    ${OUTPUT_DIR}/FEVE_1_RAT_1ST_Precondition.json
    ...    ENB_ID=${enb_id}    CBSD_ID=${cbsd_id_1st}
    Replace Variables In File    ${CURDIR}/Data/FeVe01/FEVE_1_RAT_1ST_Precondition2.json    ${OUTPUT_DIR}/FEVE_1_RAT_1ST_Precondition2.json
    ...    ENB_ID=${enb_id}
    Replace Variables In File    ${CURDIR}/Data/FeVe01/FEVE_1_RAT_1ST_Postcondition.json    ${OUTPUT_DIR}/FEVE_1_RAT_1ST_Postcondition.json
    ...    ENB_ID=${enb_id}    CBSD_ID=${cbsd_id_1st}
    Replace Variables In File    ${CURDIR}/Data/FeVe01/FEVE_1_RAT_1ST_Postcondition2.json    ${OUTPUT_DIR}/FEVE_1_RAT_1ST_Postcondition2.json
    ...    ENB_ID=${enb_id}

    Wait Until BTS Is Not Busy    alias=RAT_1ST
    #Limit spectrum to 11 channels between 3560-3670 MHz
    Perform Delta Recommissioning    ${OUTPUT_DIR}/FEVE_1_RAT_1ST_Precondition.json    skip_parameter_relation_errors=${TRUE}    connection=RAT_1ST

    #Checking if channel bandwidth is 10 MHz for all CBSD cells
    FOR    ${i}    IN RANGE    ${1}    ${5}
        ${chBw_10MHz}   Run Keyword And Return Status    Query Infomodel    alias=RAT_1ST
        ...    query=check /MRBTS-1/RAT-1/MCTRL-*/BBTOP_M-*/MRBTS_M-*/LNBTS_M-*/CELL_M-${i}/LNCEL_M-${i} is [ulChBw=10000000]
        IF  '${chBw_10MHz}'=='False'  Wait Until BTS Is Not Busy
        IF  '${chBw_10MHz}'=='False'  Perform Delta Recommissioning
        ...  ${OUTPUT_DIR}/FEVE_1_RAT_1ST_Precondition2.json  skip_parameter_relation_errors=${TRUE}  connection=RAT_1ST
        IF  '${chBw_10MHz}'=='False'  BREAK
    END
    Log    ${\n}Channel bandwidth is 10 MHz for all CBSD cells    console=true

    ${sas_pid}    ${sas_logs_dir} =    Start SAS Process    default
    ...                                                     4433
    ...                                                     config=${CURDIR}/Data/FeVe01/SAS_Sim.conf

    Enable CBRS Feature On eNB

    #Wait Until BTS Is Not Busy    alias=RAT_1ST
    Wait For All Cells To Be OnAir    alias=RAT_1ST

    ${best_bands}   Get Best Bands From Measurement Report

    Log    ${\n}best bands: ${best_bands}    console=True
    ${bands}   Get Cells Bands
    Log    ${\n}actual bands: ${bands}    console=True
    List Should Contain Sub List    ${best_bands}    ${bands}    ignore_order=True

    [Teardown]    Run Keywords
    ...    Get SAS Logs To Logs Dir    alias=default    AND
    ...    Wait Until BTS Is Not Busy    alias=RAT_1ST    AND
    ...    IF  '${chBw_10MHz}'=='False'  Perform Delta Recommissioning
           ...  ${OUTPUT_DIR}/FEVE_1_RAT_1ST_Postcondition2.json  skip_parameter_relation_errors=${TRUE}  connection=RAT_1ST  AND
    ...    Wait Until BTS Is Not Busy    alias=RAT_1ST    AND
    ...    Wait Until Keyword Succeeds    10x    30s    Perform Delta Recommissioning
           ...    ${OUTPUT_DIR}/FEVE_1_RAT_1ST_Postcondition.json    skip_parameter_relation_errors=${TRUE}    connection=RAT_1ST    AND
    ...    Wait Until BTS Is Not Busy    alias=RAT_1ST    AND
    ...    Wait Until Keyword Succeeds    6x    30s    Enable Carrier Aggregation    ${enb_id}    alias=RAT_1ST    AND
    ...    Wait For All Cells To Be OnAir    alias=RAT_1ST    AND
    ...    Save And Check Historical Alarms    expected_alarms=@{expected_alarms}    AND
    ...    Kill All SAS Processes

Get Cells Bands
    [Arguments]    ${alias}=RAT_1ST
    ${bands}   Create List
    ${cells}   Query Infomodel    query=get list /MRBTS-1/RAT-1//CHANNEL_GROUP_M-*    alias=${alias}
    FOR    ${cell}    IN    @{cells}
        ${temp}   Get From Dictionary  ${cell}    fcnDLs
        ${temp}   Evaluate  ${temp}-5000000
        ${temp}   Convert To String    ${temp}
        Append To List    ${bands}    ${temp[:4]}MHz
    END
    Sort List    ${bands}
    RETURN    ${bands}


Get Best Bands From Measurement Report
    [Arguments]    ${alias}=RAT_1ST
    ${raport}   Query Infomodel    query=get object /MRBTS-1/RAT-1//CBRS_BAND_MEASUREMENT_REPORT-*    alias=${alias}
    ${measurementReport}   Set Variable    ${raport["measurementReport"][0]["measResult"]}
    ${measResult}   Create Dictionary

    FOR    ${i}    IN RANGE    ${1}    ${12}
        Set To Dictionary    ${measResult}    ${measurementReport[${i}]["measFrequency"]}    ${measurementReport[${i}]["measRcvdPower"]}
    END
    #Selecting the best 8 (maximum configurable channels with granularity 10 MHz) frequency channels
    ${measResult}   Evaluate    sorted(${measResult}.items(), key=lambda x: x[1])
    ${measResult}   Evaluate    dict(${measResult[:-3]})
    ${best_bands}   Get Dictionary Keys    ${measResult}
    Sort List    ${best_bands}
    RETURN    ${best_bands}

