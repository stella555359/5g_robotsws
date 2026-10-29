*** Settings ***
Documentation
...    = Author =
...    _jakub.klein@nokia.com_
...    = Maintainer =
...    _aleksandra.chudzik@nokia.com_
...    = Reviewer =
...    lukasz.lechowicz@nokia.com
...    piotr.lukaszewicz@nokia.com
...    katarzyna.olszewska@nokia.com
...    michal.moskala@nokia.com

*** Keywords ***
CBRS_LTE5703_FeVe_22_SAS_Heartbeat_procedure_responseCode_106
    [Documentation]    This scenario verifies CBSD reaction for responseCode = 106. eNB should report failure
    ...                and after waiting time send heartbeatRequest again. Tested Requirement: OM_GEN_SFS_CBRS.298

    Set Suite Variable    ${ims_alias}    RAT_1ST
    ${enb_id}   Set Variable    ${testlines.${testline_id}.enb_id}
    &{expected_alarm}   Create Dictionary    fault_id=6829    fault_name=SAS Heartbeat Failure    severity=Critical
    ...    reason=Heartbeat Exception with Reason: 106. ResponseMessage: Do not contact SAS for the time being.
    ${expected_alarms_objects}   Create Watchdog Alarm List    ${expected_alarm}
    ${pci_list}    ${pci_per_cell}   Get Parameter From LNCEL Or Under For HB106    object=phyCellId
    ${chbw_list}   Get Parameter From LNCEL Or Under For HB106    object=chBw    level=*/LNCEL_TDD_A-*
    ${ecgi}    ${ecgi_cell_id}   Set The Binary Form Of ECGI For HB106    ${enb_id}    ${pci_per_cell}
    ${config}   Set Variable    ${CURDIR}/Data/FeVe_22/SAS_Sim.conf
    ${config}   OperatingSystem.Get File    ${config}

    Disable CBRS Feature On eNB
    Kill All SAS Processes

    Log To Console    Start SAS processes, set preconditions in eNB configuration
    ${sas_pid}    ${sas_log}   Start SAS Process    alias=LTE5703_HB106    config=${CURDIR}/Data/FeVe_22/SAS_Sim.conf

    Replace Variables In File    file_path=${CURDIR}/Data/FeVe_22/enb_preconditions.json
    ...                          file_destination=${OUTPUT_DIR}/enb_preconditions.json
    ...                          enb_id=${enb_id}
    ...                          cbrsaGroupIdIcg=testICG
    ...                          cbrsaGroupIdCcg=testCCG
    ...                          userId=test_user
    ...                          sasUserGroupList=1
    Replace Variables In File    file_path=${CURDIR}/Data/FeVe_22/enb_postconditions.json
    ...                          file_destination=${OUTPUT_DIR}/enb_postconditions.json
    ...                          enb_id=${enb_id}
    ...                          userId=2

    Wait Until Keyword Succeeds    6x   10s    Run Keywords
    ...    Wait Until BTS Is Not Busy    AND
    ...    Perform Delta Recommissioning    ${OUTPUT_DIR}/enb_preconditions.json    connection=RAT_1ST

    Log To Console    Start Time
    ${start_time}   Get Time

    Log To Console    Enable CBRS feature on eNB

    Enable CBRS Feature On eNB
    Start Watchdog Alarm Detection    expected_alarms=${expected_alarms_objects}
    Wait For Watchdog Alarm Activation    fault_id=${expected_alarm}[fault_id]    fault_name=${expected_alarm}[fault_name]
    ...                                   severity=${expected_alarm}[severity]    reason=${expected_alarm}[reason]    timeout=90
    ${grant_info_list}   ute_admin_infomodel.Query Infomodel
    ...                    query=get list /MRBTS-*/RAT-*/SYSADAPTER-*/CBRS-*/CBSD-*/GRANT_INFO-*    alias=${ims_alias}
    Wait For Watchdog Alarm Deactivation    fault_id=${expected_alarm}[fault_id]    fault_name=${expected_alarm}[fault_name]
    ...                                     severity=${expected_alarm}[severity]    reason=${expected_alarm}[reason]    timeout=90
    Remove Fault From Watchdog Ignored List    fault_id=${expected_alarm}[fault_id]    fault_name=${expected_alarm}[fault_name]
    ...                                        severity=${expected_alarm}[severity]
    Wait Until BTS Is Not Busy    wait_time=5min
    ${earfcn}    ${num_of_cell}   List Earfcn Values For All Cells    ${enb_id}
    ${end_time}   Get Time

    ${parsed_log_file}   Parse Sas Log File    log_file_name=${sas_log}
    ...                                          date_start=${start_time}
    ...                                          date_stop=${end_time}
    ${heartbeatrequest_log}   Extract Values From Sas Log    log_name=${parsed_log_file}
    ...                                                        parameter=groupingParam
    ...                                                        data_type=heartbeatRequest
    ${heartbeatresponse_log}   Extract Values From Sas Log    log_name=${parsed_log_file}
    ...                                                         parameter=response
    ...                                                         data_type=heartbeatResponse
    ${first_hb_req}   Extract Values From SAS Log    log_name=${parsed_log_file}
    ...                                                parameter=date
    ...                                                data_type=heartbeatRequest

    ${grant_info_list}   Convert To String    ${grant_info_list}
    ${reason}   Get Regexp Matches    ${grant_info_list}    (?=Heartbeat).+?(?=.ResponseMessage)
    ${time_from_conf}   Get Regexp Matches    ${config}    (?<=force_response_data = ).*

###Step 1###
    Log To Console    Checking whether parameters in heartbeatRequest message have similar value as on eNB
    Compare Parameters Between Heartbeat Message And ENB For HB106    ${num_of_cell}    ${pci_list}    ${chbw_list}
    ...                                                     ${ecgi_cell_id}    ${heartbeatrequest_log}

###Step 2###
    Log To Console    Checking whether heartbeatResponse with responseCode 106 is presented in SAS_Sim logs
    ${hertbeatresponse_log_as_string}   Convert to string    ${heartbeatresponse_log}
    Should Contain X times    container=${hertbeatresponse_log_as_string}    item='responseCode': 106    count=1

###Step 3###
    Log To Console    Checking CBSD status in InfoModel under GRANT_INFO object
    Should Contain    ${reason}    Heartbeat Exception with Reason: 106.

###Step 4###
    Log To Console    Checking whether next heartbeatRequest appears after define time interval
    ${time_from_logs}   Extract Values From SAS Log    log_name=${parsed_log_file}    parameter=responseData    data_type=heartbeatResponse
    ${impacted_heartbeat}   Get Regexp Matches    ${config}    (?<=force_sas_method_sequence = ).*
    ${subtracted_from_heartbeatrequest}   Subtract Date From Date
    ...    ${first_hb_req[${impacted_heartbeat[0]}]}    ${first_hb_req[${impacted_heartbeat[0]}-1]}
    ${subtracted_from_heartbeatrequest}   Convert To Integer    ${subtracted_from_heartbeatrequest}
    Should Be True    '${subtracted_from_heartbeatrequest}s'=='${time_from_logs[0][0]}' or '${subtracted_from_heartbeatrequest}s'=='11s'
    Should Be True    '${subtracted_from_heartbeatrequest}s'=='${time_from_conf[0]}' or '${subtracted_from_heartbeatrequest}s'=='11s'

    [Teardown]    Run Keywords    Wait Until BTS Is Not Busy    AND
    ...                           Wait Until Keyword Succeeds    10x    10s    Perform Delta Recommissioning
    ...                                ${OUTPUT_DIR}/enb_postconditions.json    connection=${ims_alias}    AND
    ...                           Stop Watchdog Alarm Detection And Check For Failures    AND
    ...                           Kill All SAS Processes    AND
    ...                           Get SAS Logs To Logs Dir    alias=LTE5703_HB106    AND
    ...                           Check If Cells Are Disabled    enb_id=${enb_id}

##############
###Keywords###
##############
Compare Parameters Between Heartbeat Message And ENB For HB106
    [Arguments]    ${num_of_cell}    ${pci_list}    ${chbw_list}    ${ecgi_cell_id}    ${heartbeatrequest_log}
    [Documentation]    This kw compare parameters from heartbeat meassage in SAS_Sim.log and eNB configuration
    FOR    ${item}    IN RANGE    ${num_of_cell}
        Should Be Equal As Strings    ${heartbeatrequest_log[${item}][0]['groupType']}    COEXISTENCE_GROUP
        Should Be Equal As Strings    ${heartbeatrequest_log[${item}][0]['groupId']}    CBRS_ALLIANCE
        Should Be Equal As Strings    ${heartbeatrequest_log[${item}][0]['groupInfo']['cbrsAllianceInfo']['cbrsaVersion']}    v2.0
        Should Be Equal As Strings    ${heartbeatrequest_log[${item}][0]['groupInfo']['cbrsAllianceInfo']['frameStructure'][0]}    FS2
        Should Be Equal As Strings
        ...    ${heartbeatrequest_log[${item}][0]['groupInfo']['cbrsAllianceInfo']['cbrsaGroupingParam'][0]['cbrsaGroupType']}    CBRSA_CCG
        Should Be Equal As Strings
        ...    ${heartbeatrequest_log[${item}][0]['groupInfo']['cbrsAllianceInfo']['cbrsaGroupingParam'][1]['cbrsaGroupType']}    CBRSA_ICG

        #NEW SAS SIM SYNTAX FIX IFOLOGY
        IF  '${SOFTWARE_VERSION}'!='SBTS22R4' and '${SOFTWARE_VERSION}'!='SBTS22R3'
            Should Be Equal As Strings
            ...    ${heartbeatrequest_log[${item}][0]['groupInfo']['cbrsAllianceInfo']['cbrsaGroupingParam'][1]['cbrsaGroupId']}    test_usertestICG
        ELSE
            Should Be Equal As Strings
            ...    ${heartbeatrequest_log[${item}][0]['groupInfo']['cbrsAllianceInfo']['cbrsaGroupingParam'][1]['cbrsaGroupId']}    test_user testICG
        END
        IF  '${SOFTWARE_VERSION}'!='SBTS22R4' and '${SOFTWARE_VERSION}'!='SBTS22R3'
            Should Be Equal As Strings
            ...    ${heartbeatrequest_log[${item}][0]['groupInfo']['cbrsAllianceInfo']['cbrsaGroupingParam'][0]['cbrsaGroupId']}    test_usertestCCG
        ELSE
            Should Be Equal As Strings
            ...    ${heartbeatrequest_log[${item}][0]['groupInfo']['cbrsAllianceInfo']['cbrsaGroupingParam'][0]['cbrsaGroupId']}    test_user testCCG
        END
        #NEW SAS SIM SYNTAX FIX IFOLOGY

        ${usedtddconfig}   Get Parameter From LNCEL Or Under For HB106    object=tddFrameConf    level=*/LNCEL_TDD_A-*
        IF  '${usedtddconfig[${item}]}'!='None'    List Should Contain Value
        ...    ${usedtddconfig}    ${heartbeatrequest_log[${item}][0]['groupInfo']['cbrsAllianceInfo']['usedTddConfig']['ulDLConfig']}
        ${usedtddspecsubfconf}   Get Parameter From LNCEL Or Under For HB106    object=tddSpecSubfConf    level=*/LNCEL_TDD_A-*
        IF  '${usedtddspecsubfconf[${item}]}'!='None'    List Should Contain Value
        ...    ${usedtddspecsubfconf}    ${heartbeatrequest_log[${item}][0]['groupInfo']['cbrsAllianceInfo']['usedTddConfig']['ssfConfig']}
        ${desiredtddframeconf}   Get Parameter From LNCEL Or Under For HB106    object=desiredTddFrameConf    level=*/CBSDCEL_A-*
        IF  '${desiredtddframeconf[${item}]}'!='None'    List Should Contain Value
        ...    ${desiredtddframeconf}    ${heartbeatrequest_log[${item}][0]['groupInfo']['cbrsAllianceInfo']['desiredTddConfig']['ulDLConfig']}
        ${desiredtddspecsubfconf}   Get Parameter From LNCEL Or Under For HB106    object=desiredTddSpecSubfConf    level=*/CBSDCEL_A-*
        IF  '${desiredtddspecsubfconf[${item}]}'!='None'    List Should Contain Value
        ...    ${desiredtddspecsubfconf}    ${heartbeatrequest_log[${item}][0]['groupInfo']['cbrsAllianceInfo']['desiredTddConfig']['ssfConfig']}
        ${fallbtddframeconf}   Get Parameter From LNCEL Or Under For HB106    object=fallBTddFrameConf    level=*/CBSDCEL_A-*
        IF  '${fallbtddframeconf[${item}]}'!='None'    List Should Contain Value
        ...    ${fallbtddframeconf}    ${heartbeatrequest_log[${item}][0]['groupInfo']['cbrsAllianceInfo']['fallbackTddConfig']['ulDLConfig']}
        ${fallbtddspecsubfconf}   Get Parameter From LNCEL Or Under For HB106    object=fallBTddSpecSubfConf    level=*/CBSDCEL_A-*
        IF  '${fallbtddspecsubfconf[${item}]}'!='None'    List Should Contain Value
        ...    ${fallbtddspecsubfconf}    ${heartbeatrequest_log[${item}][0]['groupInfo']['cbrsAllianceInfo']['fallbackTddConfig']['ssfConfig']}

        ${pci}   Set Variable    ${heartbeatrequest_log[${item}][0]['groupInfo']['cbrsAllianceInfo']['cellInfo'][0]['eutraInfo']['signalPci']}
        List Should Contain Value    ${pci_list}    ${pci}
        ${signalbandwidth}   Evaluate
        ...    ${heartbeatrequest_log[${item}][0]['groupInfo']['cbrsAllianceInfo']['cellInfo'][0]['eutraInfo']['signalBandwidth']}/10
        ${signalbandwidth}   Convert To Integer    ${signalbandwidth}
        List Should Contain Value    ${chbw_list}    ${signalbandwidth} MHz
        ${pci_ecgi}   Get From Dictionary    ${ecgi_cell_id}    ${pci}
        Should Be Equal    ${pci_ecgi}
        ...    ${heartbeatrequest_log[${item}][0]['groupInfo']['cbrsAllianceInfo']['cellInfo'][0]['eutraInfo']['signalEcgi']}
    END

Get Parameter From LNCEL Or Under For HB106
    [Arguments]    ${object}    ${level}=*
    [Documentation]    This kw return list of values of indicated parameter via ${object} variable on LNCEL level or
    ...                under if this is specified by ${level}
    ${list}   Create List
    ${dict}  IF  '${object}'=='phyCellId'    Create Dictionary
    ${lncel_object}   ute_admin_infomodel.Query Infomodel
    ...    query=get list /MRBTS-*/RAT-*/BTS_L-*/BTS_CONF-*/NP-*/SCF-*/MRBTS_A-*/LNBTS_A-*/LNCEL_A-${level}    alias=${ims_alias}
    FOR    ${item}    IN    @{lncel_object}
        Append To List    ${list}    ${item.${object}}
        IF  '${object}'=='phyCellId'    Set To Dictionary    ${dict}    ${item.lcrId}    ${item.${object}}
    END
    Return From Keyword If    '${object}'=='phyCellId'    ${list}    ${dict}
    RETURN    ${list}

Set The Binary Form Of ECGI For HB106
    [Arguments]    ${enb_id}    ${pci_dict}
    [Documentation]    This kw return list of binary form of ECGI and dictionary in form: "pci:binary form of ECGI"
    ${ecgi_cell_dict}   Create Dictionary
    ${pci}   Get Dictionary Keys    ${pci_dict}
    FOR    ${item}    IN    @{pci}
        ${mnc}   Get Parameter From Infomodel    /MRBTS-1/RAT-1//MRBTS_A-${enb_id}/LNBTS_A-${enb_id}    mnc    alias=${ims_alias}
        ${mnc}   Convert To Binary    ${mnc}
        ${mcc}   Get Parameter From Infomodel    /MRBTS-1/RAT-1//MRBTS_A-${enb_id}/LNBTS_A-${enb_id}    mcc    alias=${ims_alias}
        ${mcc}   Convert To Binary    ${mcc}
        ${eutracellid}   Get Parameter From Infomodel    /MRBTS-1/RAT-1//LNBTS_R-${enb_id}/LNCEL_R-${item}    eutraCelId    alias=${ims_alias}
        ${eutracellid}   Convert To Binary    ${eutracellid}
        ${mnc}   Fill With Zero For HB106    ${mnc}    12
        ${mcc}   Fill With Zero For HB106    ${mcc}    12
        ${eutracellid}   Fill With Zero For HB106    ${eutracellid}    28
        ${ecgi_bin}   Set Variable    ${mcc}${mnc}${eutracellid}
        ${phycellid}   Get From Dictionary    ${pci_dict}    ${item}
        Set To Dictionary    ${ecgi_cell_dict}    ${phycellid}    ${ecgi_bin}
    END
    RETURN    ${ecgi_bin}    ${ecgi_cell_dict}

Fill With Zero For HB106
    [Arguments]    ${object}    ${length}
    FOR    ${item}    IN RANGE    ${length}
        ${current_length}   Get Length    ${object}
        Exit For Loop If    ${current_length}==${length}
        ${object}   Set Variable    0${object}
    END
    RETURN    ${object}
