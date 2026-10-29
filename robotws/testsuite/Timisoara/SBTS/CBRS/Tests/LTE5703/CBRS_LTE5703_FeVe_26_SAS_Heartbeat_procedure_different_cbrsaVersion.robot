*** Settings ***
Documentation
...    = Author =
...    _jakub.klein@nokia.com_
...    = Maintainer =
...    _aleksandra.chudzik@nokia.com_
...    = Reviewer =
...    katarzyna.olszewska@nokia.com
...    lukasz.lechowicz@nokia.com
...    piotr.lukaszewicz@nokia.com

*** Keywords ***
CBRS_LTE5703_FeVe_26_SAS_Heartbeat_procedure_different_cbrsaVersion
    [Documentation]     This scenario verifies CBSD reaction for different cbrsVersion in a request.
    ...                 eNB should report failure and start Grant Relinquish procedure. Tested Requirement: OM_GEN_SFS_CBRS.298

    [Timeout]    25min

    Set Suite Variable              ${ims_alias}      RAT_1ST
    ${enb_root_user}              Set Variable      toor4nsn
    ${enb_root_pass}              Set Variable      oZPS0POrRieRtu
    @{expected_alarms}            Create List       SAS Heartbeat Failure
    ${enb_id}                     Set Variable      ${testlines.${testline_id}.enb_id}
    ${pci_list}    ${pci_per_cell}                  Get Parameter From LNCEL Or Under For cbrsaVersion       object=phyCellId
    ${chbw_list}                  Get Parameter From LNCEL Or Under For cbrsaVersion       object=chBw    level=*/LNCEL_TDD_A-*
    ${ecgi}    ${ecgi_cell_id}    Set The Binary Form Of ECGI For cbrsaVersion             ${enb_id}    ${pci_per_cell}
    ${config}                     Set Variable      ${CURDIR}/Data/FeVe_26/SAS_Sim.conf
    ${config}                     OperatingSystem.Get File    ${config}

    Disable CBRS Feature On eNB
    Kill All SAS Processes

    Log    Start SAS processes, set preconditions in eNB configuration   console=true
    ${sas_pid}    ${sas_log}      Start SAS Process       alias=LTE5703_diff
    ...                                                     port=4433
    ...                                                     config=${CURDIR}/Data/FeVe_26/SAS_Sim.conf

    Replace Variables In File       file_path=${CURDIR}/Data/FeVe_26/enb_preconditions.json
    ...                             file_destination=${OUTPUT_DIR}/enb_preconditions.json
    ...                             enb_id=${enb_id}
    ...                             cbrsaGroupIdIcg=testICG
    ...                             cbrsaGroupIdCcg=testCCG
    ...                             userId=test_user
    ...                             sasUserGroupList=1
    Replace Variables In File       file_path=${CURDIR}/Data/FeVe_26/enb_postconditions.json
    ...                             file_destination=${OUTPUT_DIR}/enb_postconditions.json
    ...                             enb_id=${enb_id}
    ...                             userId=2

    Wait Until BTS Is Not Busy
    Perform Delta Recommissioning    ${OUTPUT_DIR}/enb_preconditions.json    connection=RAT_1ST

    Log    Start Time    console=True
    ${start_time}   Get Time

    Log    Enable CBRS feature on eNB    console=True
    Enable CBRS Feature On eNB
    Start Capturing Historical Alarms
    ute_admin_infomodel.Wait For Infomodel Event    change /MRBTS-*/RAT-*/SYSADAPTER-*/CBRS-*/CBSD-*/GRANT_INFO-* [reason]
    ...    timeout=300    alias=${ims_alias}
    ${grant_info_list}            ute_admin_infomodel.Query Infomodel
    ...                             query=get list /MRBTS-*/RAT-*/SYSADAPTER-*/CBRS-*/CBSD-*/GRANT_INFO-*    alias=${ims_alias}

    ${cbsdid}                     Get CBSDID From Infomodel

    ute_admin_infomodel.Query Infomodel
    ...                    query=every /MRBTS-*/RAT-*/SYSADAPTER-*/CBRS-*/CBSD-*/GRANT_INFO-* is [reason=empty]
    ...                    timeout=360
    ...                    alias=${ims_alias}
    ${grant_info_list_2}          ute_admin_infomodel.Query Infomodel
    ...                             query=get list /MRBTS-*/RAT-*/SYSADAPTER-*/CBRS-*/CBSD-*/GRANT_INFO-*    alias=${ims_alias}
    Wait For All Cells To Be OnAir
    Wait Until Keyword Succeeds    20x    3s    Wait For One NP Object    alias=${ims_alias}
    ${earfcn}    ${num_of_cell}   List Earfcn Values For All Cells    ${enb_id}

    Log    End Time    console=True
    ${end_time}   Get Time

    ${parsed_log_file}             Parse Sas Log File             log_file_name=${sas_log}
    ...                                                             date_start=${start_time}
    ...                                                             date_stop=${end_time}
    ${heartbeatrequest_log}        Extract Values From Sas Log    log_name=${parsed_log_file}
    ...                                                             parameter=groupingParam
    ...                                                             data_type=heartbeatRequest
    ${heartbeatresponse_log}       Extract Values From Sas Log    log_name=${parsed_log_file}
    ...                                                             parameter=cbrsaVersion
    ...                                                             data_type=heartbeatResponse

    ${cbrsaversion_change_sequence}   Get Regexp Matches    ${config}    (?<=cbrsaVersion_change_sequence = ).*
    ${sequence_number}    ${new_cbrsaversion}   Split String    ${cbrsaversion_change_sequence[0]}  ,

###Step 1###
    Log    Checking whether parameters in heartbeatRequest message have similar value as on eNB   console=True
    Compare Parameters Between Heartbeat Message And ENB For cbrsaVersion    ${num_of_cell}    ${pci_list}    ${chbw_list}
    ...                                                     ${ecgi_cell_id}    ${heartbeatrequest_log}


###Step 2###
    Log    Checking whether cbrsaVersion in heartbeatResponse in SAS_Sim log is v1.2 for defined number in conf    console=True
    ${iteration}   Evaluate    ${sequence_number}-1
    Should Contain X Times    container=${heartbeatresponse_log}    item=v1.2    count=${iteration}
    FOR    ${item}    IN RANGE    ${iteration}
        Should Be Equal As Strings    v1.2    ${heartbeatresponse_log[${item}]}
    END

###Step 3###
    Log    Checking CBSD status in InfoModel under GRANT_INFO    console=True
    ${grant_info_list}   Convert To String    ${grant_info_list}
    ${reason}   Get Regexp Matches    ${grant_info_list}    \\b(?<=reason': u').*?(?=')
    ${reasoningstatus}   Get Regexp Matches    ${grant_info_list}    \\b(?<=reasoningStatus': .u').*?(?=')
    FOR    ${item}    IN    @{reason}
        Should Be Equal As Strings    ${item}    cbrsaVersion conflicts between CBSD and SAS
    END
    FOR    ${item}    IN    @{reasoningstatus}
        Should Be Equal As Strings    ${item}    SasHeartbeatFailure
    END

###Step 4###
    Log    Checking whether CBSD relinquished GRANT_ID with v1.2 cbrsaVersion    console=True
    ${hearbeatresponse_run}   Run    grep 'heartbeatResponse' ${sas_log} | head -1
    ${impacted_grant_id}   Get Regexp Matches    ${hearbeatresponse_run}    (?<=v1.2"}},."grantId":.").*?(?=", "meas)
    FOR    ${item}    IN    @{impacted_grant_id}
        ${grep_log}   Run    grep 'relinquishmentRequest.*${item}' ${sas_log}
        Should Be Equal As Strings    ${grep_log}    {"relinquishmentRequest":[{"cbsdId":"${cbsdid}","grantId":"${item}"}]}
        ${grep_log_response}   Run    grep 'relinquishmentResponse.*${item}' ${sas_log}
        ${msg}   Catenate    SEPARATOR=${SPACE}
        ...    {"relinquishmentResponse": [{"response": {"responseMessage": "CBSD request is approved by SAS",
        ...    "responseCode": 0}, "grantId": "${item}", "cbsdId": "${cbsdid}"}]}
        Should Be Equal As Strings    ${grep_log_response}     ${msg}
    END

###Step 5####
    Log    Checking whether grantState is IDLE    console=True
    ${grant_info_string}   Convert To String    ${grant_info_list}
    ${grantstate}   Get Regexp Matches    ${grant_info_string}    Idle
    Should Contain X Times    container=${grantstate}    item=Idle    count=2

###Step 6###
    Log    Checking whether CBSD resend SpectrumInquiryRequest    console=True
    ${spectruminquiryreq2}   Run    grep -n 'spectrumInquiryRequest' ${sas_log} | cut -d : -f 1
    @{string}   Split String    ${spectruminquiryreq2}    \n
    ${length}   Get Length    ${string}
    Should Be Equal As Numbers    ${length}    2

###Step 7###
    Log    Checking whether cbrsaVersion in heartbeatResponse for new GRANT_ID is v2.0 and responseCode: 0    console=True
    ${grep_grant_response}   Run    grep 'grantResponse' ${sas_log} | sed -n 2p
    ${status_of_new_grant}   Get Regexp Matches    ${grep_grant_response}    (?<="responseMessage": ").+?(?=")
    FOR    ${item}    IN    @{status_of_new_grant}
        Should Be Equal As Strings    ${item}    CBSD request is approved by SAS
    END
    ${new_grant_id}   Get Regexp Matches    ${grep_grant_response}    (?<=grantId":.").+?(?=",."meas)
    ${hbresponse_after_new_grant}   Run    tail -n +479 ${sas_log} | grep -m1 'heartbeatResponse'
    FOR    ${item}    IN    @{new_grant_id}
        ${cbrsaversion_new_grant}   Get Regexp Matches    ${hbresponse_after_new_grant}    v2.0(?!.*v2.0)
        Should Be Equal As Strings    v2.0    ${cbrsaversion_new_grant[0]}
    END

###Step 8###
#After fully migration to python3 improve regex ${ifs_of_new_grant}
    Log    Checking in InfoModel whether grantState is Authorized    console=True
    ${grant_info_2_string}   Convert To String    ${grant_info_list_2}
    FOR    ${item}    IN    @{new_grant_id}
        ${ifs_of_new_grant}   Get Regexp Matches    ${grant_info_2_string}    (?<='dist_name').+?(?<=grantMaxEirp)
        ${ifs_of_new_grant}   Convert To String     ${ifs_of_new_grant}
        ${ifs_of_new_grant}   Get Regexp Matches    ${ifs_of_new_grant}    ((?='grantState': ').+('${item}'))|((?='${item}').+(?<='grantState).+)
        ${ifs_of_new_grant}   Get Regexp Matches    ${ifs_of_new_grant[0]}    ((?<='grantState':.').+?\\b)|((?<=grantState':..').+?\b)
        Should Be Equal As Strings    ${ifs_of_new_grant[0]}    Authorized
    END

    [Teardown]    Run Keywords    Wait Until BTS Is Not Busy    AND
    ...                           Wait Until Keyword Succeeds    10x    10s     Perform Delta Recommissioning
    ...                           ${OUTPUT_DIR}/enb_postconditions.json    connection=${ims_alias}    AND
    ...                           Save And Check Historical Alarms    expected_alarms=@{expected_alarms}    AND
    ...                           Kill All SAS Processes    AND
    ...                           Get SAS Logs To Logs Dir    alias=LTE5703_diff

##############
###Keywords###
##############
Compare Parameters Between Heartbeat Message And ENB For cbrsaVersion
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
        IF  ${IS_TRUNK}
            Should Be Equal As Strings
            ...    ${heartbeatrequest_log[${item}][0]['groupInfo']['cbrsAllianceInfo']['cbrsaGroupingParam'][1]['cbrsaGroupId']}    test_usertestICG
        ELSE
            Should Be Equal As Strings
            ...    ${heartbeatrequest_log[${item}][0]['groupInfo']['cbrsAllianceInfo']['cbrsaGroupingParam'][1]['cbrsaGroupId']}    test_user testICG
        END
        IF  ${IS_TRUNK}
            Should Be Equal As Strings
            ...    ${heartbeatrequest_log[${item}][0]['groupInfo']['cbrsAllianceInfo']['cbrsaGroupingParam'][0]['cbrsaGroupId']}    test_usertestCCG
        ELSE
            Should Be Equal As Strings
            ...    ${heartbeatrequest_log[${item}][0]['groupInfo']['cbrsAllianceInfo']['cbrsaGroupingParam'][0]['cbrsaGroupId']}    test_user testCCG
        END
        #NEW SAS SIM SYNTAX FIX IFOLOGY

        ${usedtddconfig}   Get Parameter From LNCEL Or Under For cbrsaVersion    object=tddFrameConf    level=*/LNCEL_TDD_A-*
        IF  '${usedtddconfig[${item}]}'!='None'  List Should Contain Value
        ...    ${usedtddconfig}  ${heartbeatrequest_log[${item}][0]['groupInfo']['cbrsAllianceInfo']['usedTddConfig']['ulDLConfig']}
        ${usedtddspecsubfconf}   Get Parameter From LNCEL Or Under For cbrsaVersion    object=tddSpecSubfConf    level=*/LNCEL_TDD_A-*
        IF  '${usedtddspecsubfconf[${item}]}'!='None'    List Should Contain Value
        ...    ${usedtddspecsubfconf}    ${heartbeatrequest_log[${item}][0]['groupInfo']['cbrsAllianceInfo']['usedTddConfig']['ssfConfig']}
        ${desiredtddframeconf}   Get Parameter From LNCEL Or Under For cbrsaVersion    object=desiredTddFrameConf    level=*/CBSDCEL_A-*
        IF  '${desiredtddframeconf[${item}]}'!='None'  List Should Contain Value
        ...    ${desiredtddframeconf}  ${heartbeatrequest_log[${item}][0]['groupInfo']['cbrsAllianceInfo']['desiredTddConfig']['ulDLConfig']}
        ${desiredtddspecsubfconf}   Get Parameter From LNCEL Or Under For cbrsaVersion    object=desiredTddSpecSubfConf    level=*/CBSDCEL_A-*
        IF  '${desiredtddspecsubfconf[${item}]}'!='None'    List Should Contain Value
        ...    ${desiredtddspecsubfconf}    ${heartbeatrequest_log[${item}][0]['groupInfo']['cbrsAllianceInfo']['desiredTddConfig']['ssfConfig']}
        ${fallbtddframeconf}   Get Parameter From LNCEL Or Under For cbrsaVersion    object=fallBTddFrameConf    level=*/CBSDCEL_A-*
        IF  '${fallbtddframeconf[${item}]}'!='None'    List Should Contain Value
        ...    ${fallbtddframeconf}  ${heartbeatrequest_log[${item}][0]['groupInfo']['cbrsAllianceInfo']['fallbackTddConfig']['ulDLConfig']}
        ${fallbtddspecsubfconf}   Get Parameter From LNCEL Or Under For cbrsaVersion    object=fallBTddSpecSubfConf    level=*/CBSDCEL_A-*
        IF  '${fallbtddspecsubfconf[${item}]}'!='None'    List Should Contain Value
        ...    ${fallbtddspecsubfconf}  ${heartbeatrequest_log[${item}][0]['groupInfo']['cbrsAllianceInfo']['fallbackTddConfig']['ssfConfig']}

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

Get Parameter From LNCEL Or Under For cbrsaVersion
    [Arguments]    ${object}    ${level}=*
    [Documentation]    This kw return list of values of indicated parameter via ${object} variable on LNCEL level or
    ...                under if this is specified by ${level}
    ${list}  Create List
    ${dict}  IF  '${object}'=='phyCellId'    Create Dictionary
    ${lncel_object}   ute_admin_infomodel.Query Infomodel
    ...    query=get list /MRBTS-*/RAT-*/BTS_L-*/BTS_CONF-*/NP-*/SCF-*/MRBTS_A-*/LNBTS_A-*/LNCEL_A-${level}    alias=${ims_alias}
    FOR    ${item}    IN    @{lncel_object}
        Append To List   ${list}  ${item.${object}}
        IF  '${object}'=='phyCellId'    Set To Dictionary    ${dict}      ${item.lcrId}    ${item.${object}}
    END
    Return From Keyword If    '${object}'=='phyCellId'    ${list}    ${dict}
    RETURN    ${list}

Set The Binary Form Of ECGI For cbrsaVersion
    [Arguments]    ${enb_id}    ${pci_dict}
    [Documentation]    This kw return list of binary form of ECGI and dictionary in form:  "pci:binary form of ECGI"
    ${ecgi_cell_dict}   Create Dictionary
    ${pci}   Get Dictionary Values    ${pci_dict}
    FOR    ${item}    IN    @{pci}
        ${mnc}   Get Parameter From Infomodel    /MRBTS-1/RAT-1//MRBTS_A-${enb_id}/LNBTS_A-${enb_id}    mnc    alias=${ims_alias}
        ${mnc}   Convert To Binary    ${mnc}
        ${mcc}   Get Parameter From Infomodel    /MRBTS-1/RAT-1//MRBTS_A-${enb_id}/LNBTS_A-${enb_id}    mcc    alias=${ims_alias}
        ${mcc}   Convert To Binary    ${mcc}
        ${eutracellid}   Get Parameter From Infomodel    /MRBTS-1/RAT-1//LNBTS_R-${enb_id}/LNCEL_R-${item}    eutraCelId    alias=${ims_alias}
        ${eutracellid}   Convert To Binary    ${eutracellid}
        ${mnc}   Fill With Zero For cbrsaVersion    ${mnc}    12
        ${mcc}   Fill With Zero For cbrsaVersion    ${mcc}    12
        ${eutracellid}   Fill With Zero For cbrsaVersion    ${eutracellid}    28
        ${ecgi_bin}   Set Variable    ${mcc}${mnc}${eutracellid}
        Set To Dictionary    ${ecgi_cell_dict}    ${item}    ${ecgi_bin}
    END
    RETURN    ${ecgi_bin}    ${ecgi_cell_dict}

Fill With Zero For cbrsaVersion
    [Arguments]    ${object}    ${length}
    FOR    ${item}    IN RANGE    ${length}
        ${current_length}   Get Length    ${object}
        Exit For Loop If    ${current_length}==${length}
        ${object}   Set Variable    0${object}
    END
    RETURN    ${object}