*** Settings ***
Documentation
...    = Author =
...    _jakub.klein@nokia.com_
...    = Maintainer =
...    _aleksandra.chudzik@nokia.com_
...    = Reviewer =
...    _albert.sakowicz@nokia.com_
...    _lukasz.lechowicz@nokia.com
...    = Pre - Requirements =
...    _robotlte/config/<testline name>/__init__.py and site specific keyword_

*** Keywords ***
CBRS_LTE5703_FeVe_24_SAS_Heartbeat_procedure_responseCode_500
    [Documentation]    This scenario verifies CBSD reaction for responseCode = 500.
    ...                eNB should report failure and start Grant Termination Procedure.
    ...                Tested Requirement: OM_GEN_SFS_CBRS.298

    Set Test Variable    ${ims_alias}    RAT_1ST
    ${enb_id}   Set Variable    ${testlines.${testline_id}.enb_id}
    &{expected_alarm}   Create Dictionary    fault_id=6823    fault_name=SAS Grant Termination Revocation Failure    severity=Critical
    ...                                        reason=Heartbeat Exception with Reason: 500.
    ${expected_alarms_objects}   Create Watchdog Alarm List    ${expected_alarm}
    ${chbw_list}   Get Parameter From LNCEL Level Or Lower Level    object=chBw    level=*/LNCEL_TDD_A-*
    ${pci_list}    ${pci_per_cell}   Get Parameter From LNCEL Level Or Lower Level    object=phyCellId
    ${ecgi}    ${ecgi_cell_id}   Set The Binary Form Of ECGI    ${enb_id}    ${pci_per_cell}

    Disable CBRS Feature On eNB
    Kill All SAS Processes

    Log To Console    Start SAS processes, set preconditions in eNB configuration
    ${sas_pid}    ${sas_log}   Start SAS Process    alias=LTE5703_HB500    config=${CURDIR}/Data/FeVe_24/SAS_Sim.conf

    Replace Variables In File    file_path=${CURDIR}/Data/FeVe_24/enb_preconditions.json
    ...                          file_destination=${OUTPUT_DIR}/enb_preconditions.json
    ...                          enb_id=${enb_id}
    ...                          cbrsaGroupIdIcg=testICG
    ...                          cbrsaGroupIdCcg=testCCG
    ...                          userId=test_user
    ...                          sasUserGroupList=1
    Replace Variables In File    file_path=${CURDIR}/Data/FeVe_24/enb_postconditions.json
    ...                          file_destination=${OUTPUT_DIR}/enb_postconditions.json
    ...                          enb_id=${enb_id}
    ...                          userId=2
    Wait Until Keyword Succeeds    6x    10s    Run Keywords
    ...    Wait Until BTS Is Not Busy    AND
    ...    Perform Delta Recommissioning    ${OUTPUT_DIR}/enb_preconditions.json    connection=${ims_alias}

    ${start_time}   Get Time
    Log To Console    Enable CBRS feature on eNB
    Enable CBRS Feature On eNB
    Start Watchdog Alarm Detection    expected_alarms=${expected_alarms_objects}
    Wait For Watchdog Alarm Activation    fault_id=${expected_alarm}[fault_id]    fault_name=${expected_alarm}[fault_name]
    ...                                   severity=${expected_alarm}[severity]    reason=${expected_alarm}[reason]    timeout=240

    ${grant_info_list}   ute_admin_infomodel.Query Infomodel
    ...                    query=get list /MRBTS-*/RAT-*/SYSADAPTER-*/CBRS-*/CBSD-*/GRANT_INFO-*
    ...                    alias=${ims_alias}
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

###Get HB number from SAS_Sim.conf and set range###
    ${config}   OperatingSystem.Get File    ${CURDIR}/Data/FeVe_24/SAS_Sim.conf
    ${heartbeat_position}   Get Regexp Matches    ${config}    (?<=force_sas_method_group=.........._..........,heartbeat,)\\d+(?=,500)
    ${min_item}    ${max_item}   Item For Specified HB    ${num_of_cell}    ${heartbeat_position[0]}

###Step 1###
    Log To Console    Checking whether parameters in heartbeatRequest message have similar value as on eNB
    Compare Parameters Between Heartbeat Message And eNB    ${num_of_cell}    ${pci_list}    ${chbw_list}
    ...                                                     ${ecgi_cell_id}    ${heartbeatrequest_log}

###Step 2###
    Log To Console    Checking whether heartbeat message with responseCode: 500 is presented in heartbeatResponse
    FOR    ${item}    IN RANGE    ${min_item}    ${max_item}
        Should Be Equal As Strings    ${heartbeatResponse_log[${item}]['responseCode']}    500
        Should Be Equal As Strings    ${heartbeatResponse_log[${item}]['responseMessage']}    The grant is terminated
    END

###Step 3###
    Log To Console    Checking CBSD status in InfoModel under GRANT_INFO object
    FOR    ${item}    IN    @{grant_info_list}
        ${id}   set variable    ${item['dist_name'][-1]}
        Should Be Equal As Strings    Grant_Info_Id:${id} Reason:${item.reason} reasoningStatus:${item.stateInfo.reasoningStatus[0]}
        ...    Grant_Info_Id:${id} Reason:Heartbeat Exception with Reason: 500. reasoningStatus:SasGrantTerminationRevocation
    END

###Step 4###
    Log To Console    Checking whether grantRequest/Response is presented in SAS_Sim.log
    ${heartbeat}   Run    grep -n -m${heartbeat_position[0]} -E '"responseCode": 500' ${sas_log} | cut -d : -f 1
    ${grantrequest}   Run    grep -n -m${heartbeat_position[0]} 'grantRequest' ${sas_log} | tail -n1 | cut -d : -f 1
    ${grantresponse}   Run    grep -n -m${heartbeat_position[0]} -E '"responseCode": 0' ${sas_log} | tail -n1 | cut -d : -f 1
    Evaluate    ${heartbeat}<${grantrequest}
    Evaluate    ${heartbeat}<${grantresponse}

    [Teardown]    Run Keywords    Wait Until BTS Is Not Busy    AND
    ...                           Wait Until Keyword Succeeds    10x    10s     Perform Delta Recommissioning
    ...                                ${OUTPUT_DIR}/enb_postconditions.json    connection=${ims_alias}    AND
    ...                           Stop Watchdog Alarm Detection And Check For Failures    AND
    ...                           Kill All SAS Processes    AND
    ...                           Get SAS Logs To Logs Dir    alias=LTE5703_HB500    AND
    ...                           Check If Cells Are Disabled    enb_id=${enb_id}

##############
###Keywords###
##############
Check If Alarm Is Not Visible
    [Arguments]    ${not_expected_alarms}    ${allowed_alarms}    ${alias}=default
    [Documentation]    This kw fails if not expected alamr is presented in admin
    ${out_active_alarms_list}   taf.sbts.oam.coam.admin.Get Active Alarms    connection=${alias}
    ${status}   Run Keyword And Return Status    Admin Alarms Check    available=${out_active_alarms_list}
    ...    allowed=${allowed_alarms}    mandatory=${not_expected_alarms}
    IF  '${status}'=='True'    Fail

Item For Specified HB
    [Arguments]    ${num_of_cell}    ${hb}
    [Documentation]    This kw create range of value for specific heartbeat value
    ${max_item}   Evaluate    ${num_of_cell}*${hb}
    ${min_item}   Evaluate    ${max_item}-${num_of_cell}
    RETURN    ${min_item}    ${max_item}

Compare Parameters Between Heartbeat Message And eNB
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

        ${usedtddconfig}   Get Parameter From LNCEL Level Or Lower Level    object=tddFrameConf    level=*/LNCEL_TDD_A-*
        IF  '${usedtddconfig[${item}]}'!='None'    List Should Contain Value
        ...    ${usedtddconfig}    ${heartbeatrequest_log[${item}][0]['groupInfo']['cbrsAllianceInfo']['usedTddConfig']['ulDLConfig']}
        ${usedtddspecsubfconf}   Get Parameter From LNCEL Level Or Lower Level    object=tddSpecSubfConf    level=*/LNCEL_TDD_A-*
        IF  '${usedtddspecsubfconf[${item}]}'!='None'    List Should Contain Value
        ...    ${usedtddspecsubfconf}    ${heartbeatrequest_log[${item}][0]['groupInfo']['cbrsAllianceInfo']['usedTddConfig']['ssfConfig']}
        ${desiredtddframeconf}   Get Parameter From LNCEL Level Or Lower Level    object=desiredTddFrameConf    level=*/CBSDCEL_A-*
        IF  '${desiredtddframeconf[${item}]}'!='None'    List Should Contain Value
        ...    ${desiredtddframeconf}    ${heartbeatrequest_log[${item}][0]['groupInfo']['cbrsAllianceInfo']['desiredTddConfig']['ulDLConfig']}
        ${desiredtddspecsubfconf}   Get Parameter From LNCEL Level Or Lower Level    object=desiredTddSpecSubfConf    level=*/CBSDCEL_A-*
        IF  '${desiredtddspecsubfconf[${item}]}'!='None'  List Should Contain Value
        ...    ${desiredtddspecsubfconf}    ${heartbeatrequest_log[${item}][0]['groupInfo']['cbrsAllianceInfo']['desiredTddConfig']['ssfConfig']}
        ${fallbtddframeconf}   Get Parameter From LNCEL Level Or Lower Level    object=fallBTddFrameConf    level=*/CBSDCEL_A-*
        IF  '${fallbtddframeconf[${item}]}'!='None'    List Should Contain Value
        ...    ${fallbtddframeconf}    ${heartbeatrequest_log[${item}][0]['groupInfo']['cbrsAllianceInfo']['fallbackTddConfig']['ulDLConfig']}
        ${fallbtddspecsubfconf}   Get Parameter From LNCEL Level Or Lower Level    object=fallBTddSpecSubfConf    level=*/CBSDCEL_A-*
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

Get Parameter From LNCEL Level Or Lower Level
    [Arguments]    ${object}    ${level}=*
    [Documentation]    This kw return list of values of indicated parameter via ${object} variable on LNCEL level or
    ...                under if this is specified by ${level}
    ${list}   Create List
    ${dict}   IF  '${object}'=='phyCellId'    Create Dictionary
    ${lncel_object}   ute_admin_infomodel.Query Infomodel
    ...    query=get list /MRBTS-*/RAT-*/BTS_L-*/BTS_CONF-*/NP-*/SCF-*/MRBTS_A-*/LNBTS_A-*/LNCEL_A-${level}    alias=${ims_alias}
    FOR    ${item}    IN    @{lncel_object}
        Append To List    ${list}    ${item.${object}}
        IF  '${object}'=='phyCellId'    Set to Dictionary    ${dict}    ${item.lcrId}    ${item.${object}}
    END
    Return From Keyword If    '${object}'=='phyCellId'    ${list}    ${dict}
    RETURN    ${list}

Set The Binary Form Of ECGI
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
        ${mnc}   Fill With Zero    ${mnc}    12
        ${mcc}   Fill With Zero    ${mcc}    12
        ${eutracellid}   Fill With Zero    ${eutracellid}    28
        ${ecgi_bin}   Set Variable    ${mcc}${mnc}${eutracellid}
        ${phycellid}   Get From Dictionary    ${pci_dict}    ${item}
        Set To Dictionary    ${ecgi_cell_dict}    ${phycellid}    ${ecgi_bin}
    END
    RETURN    ${ecgi_bin}    ${ecgi_cell_dict}

Fill With Zero
    [Arguments]    ${object}    ${length}
    FOR    ${item}    IN RANGE    ${length}
        ${current_length}   Get Length    ${object}
        Exit For Loop If    ${current_length}==${length}
        ${object}   Set Variable    0${object}
    END
    RETURN    ${object}
