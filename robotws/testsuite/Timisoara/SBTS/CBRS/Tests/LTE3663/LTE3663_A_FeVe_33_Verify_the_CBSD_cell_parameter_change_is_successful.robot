*** Settings ***
Documentation
...    = Author =
...    albert.sakowicz@nokia.com
...    = Maintainer =
...    piotr.lukaszewicz@nokia.com
...    = Reviewer =
...    lukasz.lechowicz@nokia.com
...    aleksandra.chudzik@nokia.com
...    karol.sadowski@nokia.com
...    katarzyna.kadziela@nokia.com
...    = Summary =
...    Feature LTE3663 introduces the capability for Macro eNBs (Airscale) to operate in the shared 3.5GHz (Band48)
...    spectrum to leverage the control and manage of 3.5GHz (Band48) LTE spectrum usage. The purpose of this test case
...    is to check if there will be no relinquishment procedure, after earfcn parameter modification. Scenario is not
...    recommended for customer because it leads to cell downtime without any benefits (at the end SAS will overwrite
...    modified earfcn).

*** Keywords ***
LTE3663_A_FeVe_33_Verify_the_CBSD_cell_parameter_change_is_successful
    [Documentation]    Requirement: OM_GEN_SFS_CBRS.347
    [Timeout]    20min

    ${enb_id}   Set Variable    ${testlines.${testline_id}.enb_id}
    ${num_of_cells}   Get Number of Cells    ${enb_id}
    IF  ${1} < ${num_of_cells} < ${5}
        Log  ${\n}${num_of_cells} cells detected  console=True
    ELSE
        Fail  Configuration with ${num_of_cells} cell(s) not supported by this scenario
    END
    Wait Until BTS Is Not Busy
    Disable CBRS Feature On eNB
    Kill All SAS Processes
    Check If Cells Are Disabled    ${enb_id}

    ${start_time}   Get Time
    ${sas_pid}    ${sas_log}   Start SAS Process
    Log To Console    SAS Simulator is running
    Enable CBRS Feature On eNB
    Wait For All Cells To Be OnAir
    BTS Operational State Should Be OnAir
    Log To Console    All cells are OnAir
    Start Watchdog Alarm Detection

    ${current_earfcn_values}   Get Earfcn Values And Cells Id To A Dictionary    cells_quantity=${num_of_cells}
    Log To Console    Current earfcn values: ${current_earfcn_values}
    ${new_earfcn_dict}   Calculate New Earfcn Values To Be Different Than Current
    ...    cells_quantity=${num_of_cells}    dict_earfcn=${current_earfcn_values}

    Log To Console    Setting new earfcn values: ${new_earfcn_dict}
    IF  '${num_of_cells}'=='2'
        Replace Variables In File  file_path=${CURDIR}/Data/modify_earfcn_2_cells.json
        ...  file_destination=${OUTPUT_DIR}/setting_earfcn.json  enb_id=${enb_id}
        ...  earfcn_cell_1=${new_earfcn_dict[1]}  earfcn_cell_2=${new_earfcn_dict[2]}
    ELSE IF  '${num_of_cells}'=='3'
        Replace Variables In File  file_path=${CURDIR}/Data/modify_earfcn_3_cells.json
        ...  file_destination=${OUTPUT_DIR}/setting_earfcn.json  enb_id=${enb_id}
        ...  earfcn_cell_1=${new_earfcn_dict[1]}  earfcn_cell_2=${new_earfcn_dict[2]}  earfcn_cell_3=${new_earfcn_dict[3]}
    ELSE IF  '${num_of_cells}'=='4'
        Replace Variables In File  file_path=${CURDIR}/Data/modify_earfcn_4_cells.json
        ...  file_destination=${OUTPUT_DIR}/setting_earfcn.json  enb_id=${enb_id}
        ...  earfcn_cell_1=${new_earfcn_dict[1]}  earfcn_cell_2=${new_earfcn_dict[2]}
        ...  earfcn_cell_3=${new_earfcn_dict[3]}  earfcn_cell_4=${new_earfcn_dict[4]}
    END

    Wait Until BTS Is Not Busy
    Perform Delta Recommissioning    ${OUTPUT_DIR}/setting_earfcn.json    connection=RAT_1ST
    Wait For All Cells To Be OnAir
    BTS Operational State Should Be OnAir
    ${stop_time}   Get Time

    Log To Console    Checking SAS log
    ${parsed_log_file}   Parse Sas Log File    log_file_name=${sas_log}
    ...                                          date_start=${start_time}
    ...                                          date_stop=${stop_time}
    ${registration_response}   Extract Values From Sas Log    log_name=${parsed_log_file}
    ...                                                         parameter=responseMessage
    ...                                                         data_type=registrationResponse
    Should Contain    ${registration_response}    CBSD request is approved by SAS
    ${registration_code}   Extract Values From Sas Log    log_name=${parsed_log_file}
    ...                                                     parameter=responseCode
    ...                                                     data_type=registrationResponse
    ${required_code}   Convert To Integer    0
    Should Contain    ${registration_code}    ${required_code}

    ${grantId_list}   Extract Values From Sas Log    log_name=${parsed_log_file}
    ...                                                parameter=grantId
    ...                                                data_type=heartbeatResponse
    ...                                                packet_amount=1

    ${parsed_log_file_str}   Convert To String    ${parsed_log_file}
    ${release_version}       Get Active Release Version

    # evaluation based on PR647079
    IF  '${release_version}'=='SBTS21B' or '${release_version}'=='SBTS22R1'
        Should Contain  ${parsed_log_file_str}  relinquishmentRequest
    ELSE
        Should Not Contain  ${parsed_log_file_str}  relinquishmentRequest
    END

    [Teardown]    Run Keywords    Get SAS Logs To Logs Dir    alias=default    AND
    ...                           Stop Watchdog Alarm Detection And Check For Failures

*** Keywords ***
Get Earfcn Values And Cells Id To A Dictionary
    [Documentation]  Description:           Read earfcn value for every cell and save them inside a dictionary with
    ...                                     cell ID.                                             ${\n}
    ...              Return:                dictionary with cells ID and earfcn values           ${\n}
    ...              Output:                { &{dictionary} }                                    ${\n}
    ...              Author:                albert.sakowicz@nokia.com                            ${\n}
    ...              Maintainer:            piotr.lukaszewicz@nokia.com                          ${\n}
    [Arguments]      ${cells_quantity}      # number of cells

    ${dict_cell_num_earfcn}   Create Dictionary
    FOR    ${cell_id}    IN RANGE    ${1}    ${cells_quantity}+1
        ${cells_earfcn}   Get Earfcn Value By Cell Id    ${cell_id}
        Set To Dictionary    ${dict_cell_num_earfcn}    ${cell_id}    ${cells_earfcn}
    END

    RETURN    ${dict_cell_num_earfcn}

Calculate New Earfcn Values To Be Different Than Current
    [Documentation]  Description:           Calculate new earfcn values to be different than current. Algorithm prepares
    ...                                     two earfcn candidates: current earfcn increased by 210 and earfcn starting
    ...                                     at the beggining of CBRS spectrum (with 20MHz distance between cells). If
    ...                                     the first candidate exceeds highest CBRS earfcn, second candidate shall
    ...                                     be taken.                                            ${\n}
    ...              Return:                dictionary with cells ID and earfcn values           ${\n}
    ...              Output:                { &{dictionary} }                                    ${\n}
    ...              Author:                albert.sakowicz@nokia.com                            ${\n}
    ...              Maintainer:            piotr.lukaszewicz@nokia.com                          ${\n}
    [Arguments]      ${cells_quantity}      # number of cells
    ...              ${dict_earfcn}         # dictionary with cells ID and earfcn values

    ${new_earfcn_dict}    Create Dictionary
    ${earfcn_max}   Set Variable    56640
    FOR    ${cell_id}    IN RANGE    ${1}    ${cells_quantity}+1
        ${increased_curr_earfcn}    Evaluate    ${dict_earfcn[${cell_id}]}+210
        ${low_earfcn_cand}    Evaluate    55290+${cell_id}*200
        IF  ${increased_curr_earfcn} > ${earfcn_max}
            Set To Dictionary  ${new_earfcn_dict}  ${cell_id}  ${low_earfcn_cand}
        ELSE
            Set To Dictionary  ${new_earfcn_dict}  ${cell_id}  ${increased_curr_earfcn}
        END
    END

    RETURN    ${new_earfcn_dict}
