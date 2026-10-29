*** Settings ***
Documentation
...    = Author =
...    _jakub.klein@nokia.com_
...    = Maintainer =
...    _aleksandra.chudzik@nokia.com_
...    = Reviewer =
...    _albert.sakowicz@nokia.com_
...    _artur.czainski@nokia.com
...    _lukasz.lechowicz@nokia.com
...    = Pre - Requirements =
...    _robotlte/config/<testline name>/__init__.py and site specific keyword_

*** Keywords ***
CBRS_LTE5703_FeVe_21_SAS_Heartbeat_procedure_responseCode_100
    [Documentation]    This scenario verifies CBSD reaction for responseCode = 100.
    ...                eNB should report failure and start deregistrationProcedure.
    ...                Tested Requirement: OM_GEN_SFS_CBRS.298

    Set Suite Variable             ${ims_alias}    RAT_1ST
    ${enb_id}                    Set Variable    ${testlines.${testline_id}.enb_id}
    ${pci_list}                  Get Parameter From LNCEL Or Under    object=phyCellId
    ${chbw_list}                 Get Parameter From LNCEL Or Under    object=chBw    level=*/LNCEL_TDD_A-*
    ${ecgi}    ${ecgi_cell_id}   Set The Binary Form Of ECGI For HB100    ${enb_id}    ${pci_list}
    ${userid_default}            Get Parameter From Infomodel    /MRBTS-1/RAT-1//MRBTS_A-${enb_id}/LNBTS_A-${enb_id}/CBSD_A-1
    ...                                                            userId

    Disable CBRS Feature On eNB
    Kill All SAS Processes

    Log To Console    Start SAS processes, set preconditions in eNB configuration
    ${sas_pid}    ${sas_log}   Start SAS Process    alias=LTE5703_HB100    config=${CURDIR}/Data/FeVe_21/SAS_Sim.conf

    Replace Variables In File    file_path=${CURDIR}/Data/FeVe_21/enb_preconditions.json
    ...                          file_destination=${OUTPUT_DIR}/enb_preconditions.json
    ...                          enb_id=${enb_id}
    ...                          cbrsaGroupIdIcg=testICG
    ...                          cbrsaGroupIdCcg=testCCG
    ...                          userId=test_user
    ...                          sasUserGroupList=1
    Replace Variables In File    file_path=${CURDIR}/Data/FeVe_21/enb_postconditions.json
    ...                          file_destination=${OUTPUT_DIR}/enb_postconditions.json
    ...                          enb_id=${enb_id}
    ...                          userId=${userid_default}
    Wait Until Keyword Succeeds    6x    10s    Run Keywords
    ...    Wait Until BTS Is Not Busy    AND
    ...    Perform Delta Recommissioning    ${OUTPUT_DIR}/enb_preconditions.json    connection=${ims_alias}

    ${start_time}   Get Time
    Start Watchdog Alarm Detection

    Log To Console    Enable CBRS feature on eNB
    Wait Until BTS Is Not Busy
    Enable CBRS Feature On eNB
    Watchdog Check For Failures

    #Waiting for CBSD reaction for responseCode = 100
    Wait For All Cells To Be OnAir

    ${earfcn}    ${num_of_cell}   List Earfcn Values For All Cells    ${enb_id}
    ${cbsdid}   Get CBSDID From Infomodel

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

###Step 1###
    Log To Console    Checking whether parameters in heartbeatRequest meassage have similar value as on eNB
    Compare parameters between heartbeat message and eNB for HB100    ${num_of_cell}    ${pci_list}    ${chbw_list}
    ...                                                               ${ecgi_cell_id}    ${heartbeatrequest_log}

###Step 2###
    Log To Console    Checking whether heartbeat message with responseCode: 100 is presented in heartbeatResponse
    FOR    ${item}    IN RANGE    ${num_of_cell}
        Should Be Equal As Strings    ${heartbeatresponse_log[${item}]['responseCode']}    100
        Should Be Equal As Strings    ${heartbeatresponse_log[${item}]['responseMessage']}
        ...    SAS protocol version used by CBSD is not supported by SAS
    END

###Step 3###
    Log To Console    Checking whether deregistration Request is presented in SAS_Sim.log
    ${deregistrationrequest}   Run    grep -i -m1 "deregistrationRequest" ${sas_log}
    ${deregistrationrequest}   Replace String    ${deregistrationrequest}    ${SPACE}    ${EMPTY}
    Should Be Equal As Strings    {"deregistrationRequest":[{"cbsdId":"${cbsdid}"}]}    ${deregistrationrequest}

    ${deregistrationresponse}   Run    grep -i -m1 "deregistrationResponse" ${sas_log}
    Check If deregistrationResponse From SAS Contains Required Logs    ${deregistrationresponse}    ${cbsdid}

    [Teardown]    Run Keywords    Stop Watchdog Alarm Detection And Check For Failures    AND
    ...                           Kill All SAS Processes    AND
    ...                           Get SAS Logs To Logs Dir    alias=LTE5703_HB100    AND
    ...                           Wait Until BTS Is Not Busy    AND
    ...                           Wait Until Keyword Succeeds    10x    10s    Perform Delta Recommissioning
    ...                               ${OUTPUT_DIR}/enb_postconditions.json    connection=${ims_alias}


Compare parameters between heartbeat message and eNB for HB100
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

        ${usedtddconfig}   Get Parameter From LNCEL Or Under    object=tddFrameConf    level=*/LNCEL_TDD_A-*
        IF  '${usedtddconfig[${item}]}'!='None'    List Should Contain Value
        ...    ${usedtddconfig}    ${heartbeatrequest_log[${item}][0]['groupInfo']['cbrsAllianceInfo']['usedTddConfig']['ulDLConfig']}
        ${usedtddspecsubfconf}   Get Parameter From LNCEL Or Under    object=tddSpecSubfConf    level=*/LNCEL_TDD_A-*
        IF  '${usedtddspecsubfconf[${item}]}'!='None'    List Should Contain Value
        ...    ${usedtddspecsubfconf}    ${heartbeatrequest_log[${item}][0]['groupInfo']['cbrsAllianceInfo']['usedTddConfig']['ssfConfig']}
        ${desiredtddframeconf}   Get Parameter From LNCEL Or Under    object=desiredTddFrameConf    level=*/CBSDCEL_A-*
        IF  '${desiredtddframeconf[${item}]}'!='None'    List Should Contain Value
        ...    ${desiredtddframeconf}    ${heartbeatrequest_log[${item}][0]['groupInfo']['cbrsAllianceInfo']['desiredTddConfig']['ulDLConfig']}
        ${desiredtddspecsubfconf}   Get Parameter From LNCEL Or Under    object=desiredTddSpecSubfConf    level=*/CBSDCEL_A-*
        IF  '${desiredtddspecsubfconf[${item}]}'!='None'    List Should Contain Value
        ...    ${desiredtddspecsubfconf}    ${heartbeatrequest_log[${item}][0]['groupInfo']['cbrsAllianceInfo']['desiredTddConfig']['ssfConfig']}
        ${fallbtddframeconf}   Get Parameter From LNCEL Or Under    object=fallBTddFrameConf    level=*/CBSDCEL_A-*
        IF  '${fallbtddframeconf[${item}]}'!='None'    List Should Contain Value
        ...    ${fallbtddframeconf}    ${heartbeatrequest_log[${item}][0]['groupInfo']['cbrsAllianceInfo']['fallbackTddConfig']['ulDLConfig']}
        ${fallbtddspecsubfconf}   Get Parameter From LNCEL Or Under    object=fallBTddSpecSubfConf    level=*/CBSDCEL_A-*
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

Get Parameter From LNCEL Or Under
    [Arguments]    ${object}    ${level}=*
    [Documentation]    This kw return list of values of indicated parameter via ${object} variable on LNCEL level or
    ...                under if this is specified by ${level}
    ${list}  Create List
    ${lncel_object}   ute_admin_infomodel.Query Infomodel
    ...    query=get list /MRBTS-*/RAT-*/BTS_L-*/BTS_CONF-*/NP-*/SCF-*/MRBTS_A-*/LNBTS_A-*/LNCEL_A-${level}    alias=${ims_alias}
    FOR    ${item}    IN    @{lncel_object}
        Append To List    ${list}    ${item.${object}}
    END
    RETURN    ${list}

Set The Binary Form Of ECGI For HB100
    [Arguments]    ${enb_id}    ${pci}
    [Documentation]    This kw return list of binary form of ECGI and dictionary in form: "pci:binary form of ECGI"
    ${ecgi_cell_dict}   Create Dictionary
    FOR    ${item}    IN    @{pci}
        ${mnc}   Get Parameter From Infomodel    /MRBTS-1/RAT-1//MRBTS_A-${enb_id}/LNBTS_A-${enb_id}    mnc    alias=${ims_alias}
        ${mnc}   Convert To Binary    ${mnc}
        ${mcc}   Get Parameter From Infomodel    /MRBTS-1/RAT-1//MRBTS_A-${enb_id}/LNBTS_A-${enb_id}    mcc    alias=${ims_alias}
        ${mcc}   Convert To Binary    ${mcc}
        ${eutracellid}   Get Parameter From Infomodel    /MRBTS-1/RAT-1//LNBTS_R-${enb_id}/LNCEL_R-${item}    eutraCelId    alias=${ims_alias}
        ${eutracellid}   Convert To Binary    ${eutracellid}
        ${mnc}   Fill With Zero For HB100    ${mnc}    12
        ${mcc}   Fill With Zero For HB100    ${mcc}    12
        ${eutracellid}   Fill With Zero For HB100    ${eutracellid}    28
        ${ecgi_bin}   Set Variable    ${mcc}${mnc}${eutracellid}
        Set To Dictionary    ${ecgi_cell_dict}    ${item}    ${ecgi_bin}
    END
    RETURN    ${ecgi_bin}    ${ecgi_cell_dict}

Fill With Zero For HB100
    [Arguments]    ${object}    ${length}
    FOR    ${item}    IN RANGE    ${length}
        ${current_length}   Get Length    ${object}
        Exit For Loop If    ${current_length}==${length}
        ${object}   Set Variable    0${object}
    END
    RETURN    ${object}

Check If deregistrationResponse From SAS Contains Required Logs
    [Arguments]    ${deregistrationresponse}    ${cbsdid}
    [Documentation]    KW checks if SAS Log contains all required messages.
    Should Contain     ${deregistrationresponse}    "cbrsaVersion": "v2.0"
    Should Contain     ${deregistrationresponse}    "responseMessage": "CBSD request is approved by SAS"
    Should Contain     ${deregistrationresponse}    "responseCode": 0
    Should Contain     ${deregistrationresponse}    "cbsdId": "${cbsdid}"
