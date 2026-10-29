*** Settings ***
Documentation
...  author: Jiang Shengyuan
...  contact: shengyuan.jiang@nokia-sbell.com

Resource   ../Resource/Common.robot

*** Variables ***

*** Keywords ***
Classical_SA_DU_PCMD_reporting_after_BB_card_restart_And_DU_continue_PCMD_reporting_during_unimpacted_BB_card_restart
    [Arguments]  ${ue_cell_identity_filter}=${ue_cell_identity_filter}   ${PLMN_IDENTITY}=${PLMN_IDENTITY}   ${LOCAL_SSH_ADDR}=${LOCAL_SSH_ADDR}
    Log To Console   DU PCMD Reporting after BB Card Restart
    DU PCMD Reporting after BB Card Restart
    ...   cellIdentity_Filter=${ue_cell_identity_filter}   plmn_Identity=${PLMN_IDENTITY}

#    Run Keyword And Continue On Failure   Run Keyword Unless   ${status}   Run Keywords   Save gNB Snapshot   host=${LOCAL_SSH_ADDR}   alias=master
#    ...   AND   Fail
#
#    Log To Console   Reset Site
#    Wait Until Keyword Succeeds   10m   1m   COAM Login
#    Run Keyword And Ignore Error   COAM Reset Site
#    Wait Until Keyword Succeeds   25m   1m   COAM Check All Cells Onair
#    Sleep   5min
#
    Log To Console   DU Continue PCMD Reporting During Unimpacted BB Card Restart
    DU Continue PCMD Reporting During Unimpacted BB Card Restart
    ...   cellIdentity_Filter=${ue_cell_identity_filter}   plmn_Identity=${PLMN_IDENTITY}

DU PCMD Reporting after BB Card Restart
    [Arguments]  ${cellIdentity_Filter}   ${plmn_Identity}   ${BBMOD_index}=1   ${command}=tcpdump -i any tcp port 49148 or sctp port 38472
#    ${tcpdump_file}   Catch Tcpdump during BBMOD Rest   BBMOD_index=${BBMOD_index}   eth=${True}   l3call=${False}   command=None
    ${tcpdump_file}   Catch Tcpdump during BBMOD Rest   BBMOD_index=${BBMOD_index}   eth=${True}   l3call=${False}   command=${command}
    ${emil_last_file}   Get Latest Trace File Name By BTSID
    Set Test Variable   ${emil_last_file}
    Log To Console   Make L3call
    Make L3CALL And Get ALL PCMD MSG   command=${command}
    Log To Console   Chekc PCMD Message
    ${traceId}   Get hexadecimal traceId
    Check Trace Session or Recording Session   tcpdump=${tcpdump_file}   cellIdentity_Filter=${cellIdentity_Filter}
    ...   plmn_Identity=${plmn_Identity}   traceId=${traceId}   sessionStatus=stop
    Check Trace Session or Recording Session   tcpdump=${tcpdump_file}   cellIdentity_Filter=${cellIdentity_Filter}
    ...   plmn_Identity=${plmn_Identity}   traceId=${traceId}   sessionStatus=start
    Check Trace Session or Recording Session   tcpdump=${tcpdump_file}   cellIdentity_Filter=${cellIdentity_Filter}
    ...   plmn_Identity=${plmn_Identity}   traceId=${traceId}   sessionStatus=stopRecording
    Check DU records   tcpdump=${TCPDUMP_PATH}   txt_msg=${ALL_PCMD_MSG}

DU Continue PCMD Reporting During Unimpacted BB Card Restart
    [Arguments]  ${cellIdentity_Filter}   ${plmn_Identity}   ${BBMOD_index}=2   ${command}=tcpdump -i any tcp port 49148 or sctp port 38472
    ${emil_last_file}   Get Latest Trace File Name By BTSID
    ${tcpdump_file}   Catch Tcpdump during BBMOD Rest   BBMOD_index=${BBMOD_index}   eth=${False}   l3call=${True}   command=${command}
    ${txt_file}   ${all_pcmd_msg}   Get Emil File and ALL PCMD Records   emil_last_file=${emil_last_file}
#    ${traceId}   Get hexadecimal traceId
#    Check Trace Session or Recording Session   tcpdump=${tcpdump_file}   cellIdentity_Filter=${cellIdentity_Filter}
#    ...   plmn_Identity=${plmn_Identity}   traceId=${traceId}   sessionStatus=stopRecording
#    ${StartRecordingStatus}   Run Keyword And Return Status   Check Trace Session or Recording Session   tcpdump=${tcpdump_file}
#    ...   cellIdentity_Filter=${cellIdentity_Filter}   plmn_Identity=${plmn_Identity}   traceId=${traceId}   sessionStatus=startRecording
#    Run Keyword If   '${gNB}'=='843'   Should Be True   ${StartRecordingStatus}
#    Run Keyword If   ${StartRecordingStatus}   Log To Console   StartRecordingSession is reported, please check loop
#    ...   ELSE   Log To Console   StartRecordingSession is not reported, please check loop
    Check DU records   tcpdump=${tcpdump_file}   txt_msg=${all_pcmd_msg}   periodic_check=${false}

Check Trace Session or Recording Session
    [Arguments]  ${tcpdump}   ${cellIdentity_Filter}   ${plmn_Identity}   ${traceId}   ${sessionStatus}=stop
    ${Filter}   Run Keyword If   '${sessionStatus}'=='stop'
    ...   Set Variable   nsetapx.TraceMessage == 3 && nsetapx.cellIdentity == ${cellIdentity_Filter}
    ...   ELSE IF   '${sessionStatus}'=='start'   Set Variable   nsetapx.TraceMessage == 2 && nsetapx.cellIdentity == ${cellIdentity_Filter}
    ...   ELSE IF   '${sessionStatus}'=='stopRecording'   Set Variable   nsetapx.TraceMessage == 5
    ...   ELSE IF   '${sessionStatus}'=='startRecording'   Set Variable   nsetapx.TraceMessage == 4
    ...     ELSE   Fail   msg=invalid argument
    Load Pcap File with Filter any Expression
    ...                        pcap_file=${tcpdump}
    ...                        any_expression=${Filter}
    ...                        filter=tcp.dstport==49148

#    ${release}   Get gnb release   host=${host}
#    ${DU_xpath}   Set Variable If   '${release}'>='SBTS23R4'
#    ...   .//nsetapx.${sessionStatus}Session_element/nsetapx.nodeType/nsetapx.gnb_du_Ids_element/nsetapx.gnb_Id_element/nsetapx.plmn_Identity
#    ...   .//nsetapx.${sessionStatus}Session_element/nsetapx.nodeType/nsetapx.gnb_du_Ids_element/nsetapx.gnb_Id_element/nsetapx.plmn_Identity

    ${DU_plmn_Identity}   wireshark.get_field_value_by_xpath
    ...    xpath=.//nsetapx.${sessionStatus}Session_element/nsetapx.nodeType/nsetapx.gnb_du_Ids_element/nsetapx.gnb_Id_element/nsetapx.plmn_Identity
    ${CU_plmn_Identity}   wireshark.get_field_value_by_xpath
    ...    xpath=.//nsetapx.${sessionStatus}Session_element/nsetapx.nodeType/nsetapx.gnb_cu_Id_element/nsetapx.plmn_Identity
    ${plmn_Identity_inCell}   wireshark.get_field_value_by_xpath
    ...    xpath=.//nsetapx.${sessionStatus}Session_element/nsetapx.cellId/nsetapx.nrcgi_element/nsetapx.plmn_Identity
    ${cellIdentity}   wireshark.get_field_value_by_xpath
    ...    xpath=.//nsetapx.${sessionStatus}Session_element/nsetapx.cellId/nsetapx.nrcgi_element/nsetapx.cellIdentity
    ${traceId_in session}   wireshark.get_field_value_by_xpath
    ...    xpath=.//nsetapx.${sessionStatus}Session_element/nsetapx.traceReference_element/nsetapx.traceId
    Log To Console   check trace session
    Should Be Equal   ${DU_plmn_Identity[0].replace(':', '')}   ${plmn_Identity}
    Should Be Equal   ${CU_plmn_Identity[0].replace(':', '')}   ${plmn_Identity}
    ${plmn_Identity_inCell_length}     Get Length   ${plmn_Identity_inCell}
    FOR   ${index}    IN RANGE    ${plmn_Identity_inCell_length}
        Should Be Equal   ${plmn_Identity_inCell[${index}].replace(':', '')}   ${plmn_Identity}
        Should Be Equal   ${traceId_in session[${index}].replace(':', '')}   ${traceId}
        Run keyword If  '${sessionStatus}'=='stopRecording'   Should Be Equal   ${cellIdentity[${index}]}   ${cellIdentity_Filter}
    END
    ${traceId_length}     Get Length   ${traceId_in session}
    #    set CUUP flag flase, so stopRecording and startRecording in cuup will not reported
    Run Keyword If   '${sessionStatus}'=='startRecording' or '${sessionStatus}'=='stopRecording'   Should Be True   ${traceId_length}>=2
    ...   ELSE   Should Be True   ${traceId_length}==2
#    set CUUP flag flase, so stopRecording and startRecording in cuup will not reported
#    Run keyword If  '${sessionStatus}'=='stopRecording' or '${sessionStatus}'=='startRecording'
#    ...   Should Be True   '${traceId_length}'=='3' and ${traceId_in session[2].replace(':', '')}==${traceId}
#    ...   ELSE   Should Be True   '${traceId_length}'=='2'


Check DU records
    [Arguments]  ${tcpdump}   ${txt_msg}   ${periodic_check}=${true}
    Log To Console   Check DU records
    Load Pcap File with Filter any Expression
    ...                        pcap_file=${tcpdump}
    ...                        any_expression=nsetapx.DuVendorExtensionRecordDataType == 16 && nsetapx.result == 0
    ...                        filter=tcp.dstport==49148
    ${crnti}   wireshark.get_field_value_by_xpath   xpath=.//nsetapx.crnti
    ${crnti}   Remove Duplicates   ${crnti}
    ${length}   Get Length   ${crnti}
#    ${crnti_list}   Run Keyword If   '${length}'>'1' and '${length}'<'3'   Get Slice From List   ${crnti}   1
#    ...   ELSE IF   '${length}'>='3'   Get Slice From List   ${crnti}   2
#    ...   ELSE   Set Variable   ${crnti}
    ${crnti_list}   Create List   ${crnti[-1]}
    Run Keyword And Continue On Failure   Check ueCtxSetupRecord   ${tcpdump}   ${crnti_list}
    Run Keyword And Continue On Failure   Check TimingAdvanceRecord   ${tcpdump}
    Run Keyword And Continue On Failure   Check gNB Du rrcSetupRecord   ${tcpdump}   ${crnti_list}
    Run Keyword And Continue On Failure   Check Du BearRecord   ${tcpdump}
    Run Keyword If   ${periodic_check}   Run Keywords   Run Keyword And Continue On Failure   Check UlSchedulingRecord   ${txt_msg}   ${crnti_list}
    ...   AND   Run Keyword And Continue On Failure   Check dlRbRlcMeasRecord   ${txt_msg}   ${crnti_list}
    ...   AND   Run Keyword And Continue On Failure   Check ulRbRlcMeasRecord   ${txt_msg}   ${crnti_list}
    ...   AND   Run Keyword And Continue On Failure   Check DlSchedulingRecord   ${txt_msg}   ${crnti_list}
    ...   AND   Run Keyword And Continue On Failure   Check BeamUsageRecord   ${txt_msg}   ${crnti_list}

Check BeamUsageRecord
    [Arguments]  ${ALL_PCMD_MSG}   ${CRNTI_LIST}
    Log To Console   Check BeamUsageRecord
    ${exist}  Set Variable  ${False}
    FOR   ${crnti}   IN   @{CRNTI_LIST}
        ${exist}  Run Keyword And Return Status   Dictionary Should Contain Key   ${ALL_PCMD_MSG['${crnti}']}   beamUsageRecord
        run keyword if  not ${exist}   Fail
#        Continue For Loop If  not ${exist}
#        ${beamUsageRecord}   Set Variable   ${ALL_PCMD_MSG['${crnti}']}
#        Check Sangle BeamUsageRecord Value   beamUsageRecord=${beamUsageRecord}
    END
    run keyword if  not ${exist}   Fail   Message Not Found!

Check Sangle BeamUsageRecord Value
    [Arguments]   ${beamUsageRecord}
    ${beamUsageRecord_length}=  Get Length  ${beamUsageRecord['beamUsageRecord']}
    FOR  ${idx}  IN RANGE  0  ${beamUsageRecord_length}
        ${ConfigBeamData}  Set Variable   ${beamUsageRecord['beamUsageRecord'][${idx}]['beamData'].keys()}[0]
        ${Failed}  Set Variable  ${beamUsageRecord['beamUsageRecord'][${idx}]['beamData']['${ConfigBeamData}']['numOfFailedBeamChanges']}
        ${Success}  Set Variable  ${beamUsageRecord['beamUsageRecord'][${idx}]['beamData']['${ConfigBeamData}']['numOfSuccessfulBeamRecoveries']}
        ${TotalChanges}  Set Variable  ${beamUsageRecord['beamUsageRecord'][${idx}]['beamData']['${ConfigBeamData}']['numOfTotalBeamChanges']}
        ${TotalRecoveries}  Set Variable  ${beamUsageRecord['beamUsageRecord'][${idx}]['beamData']['${ConfigBeamData}']['numOfTotalBeamRecoveries']}
        ${recordCollectionDuration}  Set Variable  ${beamUsageRecord['beamUsageRecord'][${idx}]['recordCollectionDuration']}
        ${beamIdUsageCount}  Set Variable  ${beamUsageRecord['beamUsageRecord'][${idx}]['beamData']['${ConfigBeamData}']['beamIdUsageCount']}
        ${endMarker}  Set Variable  ${beamUsageRecord['beamUsageRecord'][${idx}]['endMarker']}
        Run Keyword If   '${endMarker}'=='TRUE'
        ...   Run Keywords   Should Be True   -1<${recordCollectionDuration}<131073
        ...   AND   Should Be True   -1<${TotalChanges}<32769
        ...   AND   Should Be True   -1<${Failed}<32769
        ...   AND   Should Be True   -1<${TotalRecoveries}<32769
        ...   AND   Should Be True   -1<${Success}<32769
        ...   AND   Check Single beamIdUsageCount in beamUsageRecord   ${beamIdUsageCount}   0   32768
        ...   ELSE IF   ${idx}==0
        ...   Run Keywords   Should Be True   -1<${recordCollectionDuration}<134273
        ...   AND   Should Be True   -1<${TotalChanges}<33569
        ...   AND   Should Be True   -1<${Failed}<33569
        ...   AND   Should Be True   -1<${TotalRecoveries}<33569
        ...   AND   Should Be True   -1<${Success}<33569
        ...   AND   Check Single beamIdUsageCount in beamUsageRecord   ${beamIdUsageCount}   0   33569
        ...   ELSE IF   '${endMarker}'=='FALSE' and '${beamUsageRecord['beamUsageRecord'][${idx}-1]['endMarker']}'=='TRUE'
        ...   Run Keywords   Should Be True   -1<${recordCollectionDuration}<134273
        ...   AND   Should Be True   -1<${TotalChanges}<33569
        ...   AND   Should Be True   -1<${Failed}<33569
        ...   AND   Should Be True   -1<${TotalRecoveries}<33569
        ...   AND   Should Be True   -1<${Success}<33569
        ...   AND   Check Single beamIdUsageCount in beamUsageRecord   ${beamIdUsageCount}   0   33569
        ...   ELSE
        ...   Run Keywords   Should Be True   ${recordCollectionDuration}==131072
        ...   AND   Should Be True   -1<${TotalChanges}<32769
        ...   AND   Should Be True   -1<${Failed}<32769
        ...   AND   Should Be True   -1<${TotalRecoveries}<32769
        ...   AND   Should Be True   -1<${Success}<32769
        ...   AND   Check Single beamIdUsageCount in beamUsageRecord   ${beamIdUsageCount}   0   32769
    END

Check Single beamIdUsageCount in beamUsageRecord
    [Arguments]  ${beamIdUsageCount}   ${minValue}   ${maxValue}
    FOR  ${value}  IN  @{beamIdUsageCount}
        Should Be True   ${minValue}-1<${value}<${maxValue}+1
    END

Check DlSchedulingRecord
    [Arguments]  ${ALL_PCMD_MSG}   ${CRNTI_LIST}
    Log To Console   Check DlSchedulingRecord
    ${exist}  Set Variable  ${False}
    FOR   ${crnti}   IN   @{CRNTI_LIST}
        ${exist}  Run Keyword And Return Status   Dictionary Should Contain Key   ${ALL_PCMD_MSG['${crnti}']}   dlSchedulingRecord
        run keyword if  not ${exist}   Fail
#        Continue For Loop If  not ${exist}
#        ${dlSchedulingRecord}   Set Variable   ${ALL_PCMD_MSG['${crnti}']}
#        Check Single DlSchedulingRecord Value   dlSchedulingRecord=${dlSchedulingRecord}
    END
    run keyword if  not ${exist}   Fail   Message Not Found!

Check Single DlSchedulingRecord Value
    [Arguments]   ${dlSchedulingRecord}
    ${SDlSchedulingTraceRecord_length}=  Get Length  ${dlSchedulingRecord['dlSchedulingRecord']}
    FOR  ${idx}    IN RANGE    0  ${SDlSchedulingTraceRecord_length}
        ${numOfWbCqiSamples_SDlSched}  Set Variable  ${dlSchedulingRecord['dlSchedulingRecord'][${idx}]['avgTb0WbCqi']['numOfWbCqiSamples']}
        ${sumOfWbCqi_SDlSched}  Set Variable  ${dlSchedulingRecord['dlSchedulingRecord'][${idx}]['avgTb0WbCqi']['sumOfWbCqi']}
        ${recordCollectionDuration_SDlSched}  Set Variable  ${dlSchedulingRecord['dlSchedulingRecord'][${idx}]['recordCollectionDuration']}
        ${numOf1stMacPduTx_SDlSched}  Set Variable  ${dlSchedulingRecord['dlSchedulingRecord'][${idx}]['numOf1stMacPduTx']}
        ${numOfBad1stMacPduTx_SDlSched}  Set Variable   ${dlSchedulingRecord['dlSchedulingRecord'][${idx}]['numOfBad1stMacPduTx']}
        ${numOfBadLastMacPduTx_SDlSched}  Set Variable  ${dlSchedulingRecord['dlSchedulingRecord'][${idx}]['numOfBadLastMacPduTx']}
        ${numOfPdschTxWithRank1_SDlSched}  Set Variable  ${dlSchedulingRecord['dlSchedulingRecord'][${idx}]['numOfPdschTxWithRank1']}
        ${numOfPdschTxWithRank2_SDlSched}  Set Variable  ${dlSchedulingRecord['dlSchedulingRecord'][${idx}]['numOfPdschTxWithRank2']}
        ${numOfPdschTxWithRank3_SDlSched}  Set Variable  ${dlSchedulingRecord['dlSchedulingRecord'][${idx}]['numOfPdschTxWithRank3']}
        ${numOfPdschTxWithRank4_SDlSched}  Set Variable  ${dlSchedulingRecord['dlSchedulingRecord'][${idx}]['numOfPdschTxWithRank4']}
        ${timeOfUeSched_SDlSched}  Set Variable  ${dlSchedulingRecord['dlSchedulingRecord'][${idx}]['timeOfUeSched']}
        ${endMarker}  Set Variable  ${dlSchedulingRecord['dlSchedulingRecord'][${idx}]['endMarker']}
        Run Keyword If   '${endMarker}'=='TRUE'
        ...   Run Keywords   Should Be True   0<${recordCollectionDuration_SDlSched}<131073 or ${recordCollectionDuration_SDlSched}==0
        ...   AND   Should Be True   0<${numOf1stMacPduTx_SDlSched}<65537 or ${numOf1stMacPduTx_SDlSched}==0
        ...   AND   Should Be True   0<${numOfBad1stMacPduTx_SDlSched}<65537 or ${numOfBad1stMacPduTx_SDlSched}==0
        ...   AND   Should Be True   0<${numOfBadLastMacPduTx_SDlSched}<65537 or ${numOfBadLastMacPduTx_SDlSched}==0
        ...   AND   Should Be True   0<${sumOfWbCqi_SDlSched}<491521 or ${sumOfWbCqi_SDlSched}==0
        ...   AND   Should Be True   0<${numOfWbCqiSamples_SDlSched}<32769 or ${numOfWbCqiSamples_SDlSched}==0
        ...   AND   Should Be True   0<${numOfPdschTxWithRank1_SDlSched}<32769 or ${numOfPdschTxWithRank1_SDlSched}==0
        ...   AND   Should Be True   0<${numOfPdschTxWithRank2_SDlSched}<32769 or ${numOfPdschTxWithRank2_SDlSched}==0
        ...   AND   Should Be True   0<${numOfPdschTxWithRank3_SDlSched}<32769 or ${numOfPdschTxWithRank3_SDlSched}==0
        ...   AND   Should Be True   0<${numOfPdschTxWithRank4_SDlSched}<32769 or ${numOfPdschTxWithRank4_SDlSched}==0
        ...   ELSE IF   ${idx}==0
        ...   Run Keywords   Should Be True   0<${recordCollectionDuration_SDlSched}<134273 or ${recordCollectionDuration_SDlSched}==0
        ...   AND   Should Be True   0<${numOf1stMacPduTx_SDlSched}<76137 or ${numOf1stMacPduTx_SDlSched}==0
        ...   AND   Should Be True   0<${numOfBad1stMacPduTx_SDlSched}<76137 or ${numOfBad1stMacPduTx_SDlSched}==0
        ...   AND   Should Be True   0<${numOfBadLastMacPduTx_SDlSched}<76137 or ${numOfBadLastMacPduTx_SDlSched}==0
        ...   AND   Should Be True   0<${sumOfWbCqi_SDlSched}<503521 or ${sumOfWbCqi_SDlSched}==0
        ...   AND   Should Be True   0<${numOfWbCqiSamples_SDlSched}<33569 or ${numOfWbCqiSamples_SDlSched}==0
        ...   AND   Should Be True   0<${numOfPdschTxWithRank1_SDlSched}<33569 or ${numOfPdschTxWithRank1_SDlSched}==0
        ...   AND   Should Be True   0<${numOfPdschTxWithRank2_SDlSched}<33569 or ${numOfPdschTxWithRank2_SDlSched}==0
        ...   AND   Should Be True   0<${numOfPdschTxWithRank3_SDlSched}<33569 or ${numOfPdschTxWithRank3_SDlSched}==0
        ...   AND   Should Be True   0<${numOfPdschTxWithRank4_SDlSched}<33569 or ${numOfPdschTxWithRank4_SDlSched}==0
        ...   ELSE IF   '${endMarker}'=='FALSE' and '${dlSchedulingRecord['dlSchedulingRecord'][${idx-1}]['endMarker']}'=='TRUE'
        ...   Run Keywords   Should Be True   0<${recordCollectionDuration_SDlSched}<134273 or ${recordCollectionDuration_SDlSched}==0
        ...   AND   Should Be True   0<${numOf1stMacPduTx_SDlSched}<76137 or ${numOf1stMacPduTx_SDlSched}==0
        ...   AND   Should Be True   0<${numOfBad1stMacPduTx_SDlSched}<76137 or ${numOfBad1stMacPduTx_SDlSched}==0
        ...   AND   Should Be True   0<${numOfBadLastMacPduTx_SDlSched}<76137 or ${numOfBadLastMacPduTx_SDlSched}==0
        ...   AND   Should Be True   0<${sumOfWbCqi_SDlSched}<503521 or ${sumOfWbCqi_SDlSched}==0
        ...   AND   Should Be True   0<${numOfWbCqiSamples_SDlSched}<33569 or ${numOfWbCqiSamples_SDlSched}==0
        ...   AND   Should Be True   0<${numOfPdschTxWithRank1_SDlSched}<33569 or ${numOfPdschTxWithRank1_SDlSched}==0
        ...   AND   Should Be True   0<${numOfPdschTxWithRank2_SDlSched}<33569 or ${numOfPdschTxWithRank2_SDlSched}==0
        ...   AND   Should Be True   0<${numOfPdschTxWithRank3_SDlSched}<33569 or ${numOfPdschTxWithRank3_SDlSched}==0
        ...   AND   Should Be True   0<${numOfPdschTxWithRank4_SDlSched}<33569 or ${numOfPdschTxWithRank4_SDlSched}==0
        ...   ELSE
        ...   Run Keywords   Should Be True   ${recordCollectionDuration_SDlSched}==131072
        ...   AND   Should Be True   0<${numOf1stMacPduTx_SDlSched}<65537 or ${numOf1stMacPduTx_SDlSched}==0
        ...   AND   Should Be True   0<${numOfBad1stMacPduTx_SDlSched}<65537 or ${numOfBad1stMacPduTx_SDlSched}==0
        ...   AND   Should Be True   0<${numOfBadLastMacPduTx_SDlSched}<65537 or ${numOfBadLastMacPduTx_SDlSched}==0
        ...   AND   Should Be True   0<${sumOfWbCqi_SDlSched}<491521 or ${sumOfWbCqi_SDlSched}==0
        ...   AND   Should Be True   0<${numOfWbCqiSamples_SDlSched}<32769 or ${numOfWbCqiSamples_SDlSched}==0
        ...   AND   Should Be True   0<${numOfPdschTxWithRank1_SDlSched}<32769 or ${numOfPdschTxWithRank1_SDlSched}==0
        ...   AND   Should Be True   0<${numOfPdschTxWithRank2_SDlSched}<32769 or ${numOfPdschTxWithRank2_SDlSched}==0
        ...   AND   Should Be True   0<${numOfPdschTxWithRank3_SDlSched}<32769 or ${numOfPdschTxWithRank3_SDlSched}==0
        ...   AND   Should Be True   0<${numOfPdschTxWithRank4_SDlSched}<32769 or ${numOfPdschTxWithRank4_SDlSched}==0

        Should Be True  0<${timeOfUeSched_SDlSched}<${recordCollectionDuration_SDlSched}+1 or ${timeOfUeSched_SDlSched}==0
    END

Check ulRbRlcMeasRecord
    [Arguments]  ${ALL_PCMD_MSG}   ${CRNTI_LIST}
    Log To Console   Check ulRbRlcMeasRecord
    ${exist}  Set Variable  ${False}
    FOR   ${crnti}   IN   @{CRNTI_LIST}
        ${exist}  Run Keyword And Return Status   Dictionary Should Contain Key   ${ALL_PCMD_MSG['${crnti}']}  ulRbRlcMeasRecord
        run keyword if  not ${exist}   Fail
#        Continue For Loop If  not ${exist}
#        ${ulRbRlcMeasRecord}   Set Variable   ${ALL_PCMD_MSG['${crnti}']}
#        Check Sangle ulRbRlcMeasRecord Value   ulRbRlcMeasRecord=${ulRbRlcMeasRecord}
    END
    run keyword if  not ${exist}   Fail   Message Not Found!

Check Sangle ulRbRlcMeasRecord Value
    [Arguments]   ${ulRbRlcMeasRecord}
    ${ulRbRlcMeasRecord_length}  Get Length  ${ulRbRlcMeasRecord['ulRbRlcMeasRecord']}
    ${rbData_length_list}    create list
    ${rbData_length_1_idex_list}    create list
    ${rbData_length_2_idex_list}    create list
    FOR  ${idx}  IN RANGE  0  ${ulRbRlcMeasRecord_length}
        ${rbData_length}  Get Length  ${ulRbRlcMeasRecord['ulRbRlcMeasRecord'][${idx}]['rbData']}
        Append to list  ${rbData_length_list}  ${rbData_length}
        Run keyword if  ${rbData_length}==2  Append to list  ${rbData_length_2_idex_list}  ${idx}
        Run keyword if  ${rbData_length}==1  Append to list  ${rbData_length_1_idex_list}  ${idx}
    END
    FOR  ${idx}  IN RANGE  0  ${rbData_length_list}[0]
         ${first_dataCollectionDuration}  Set Variable  ${ulRbRlcMeasRecord['ulRbRlcMeasRecord'][0]['rbData'][${idx}]['dataCollectionDuration']}
         Should Be True  0<${first_dataCollectionDuration}<134273 or ${first_dataCollectionDuration}==0
    END
    Log To Console    first value of recordCollectionDuration is OK
    FOR  ${var}  IN  @{rbData_length_2_idex_list}
        ${var_1}   set variable   ${var}
        ${drb-Id_ulRbRlcMeasRecord_0}  Set Variable  ${ulRbRlcMeasRecord['ulRbRlcMeasRecord'][${var}]['rbData'][0]['drb-Id']}
        ${drb-Id_ulRbRlcMeasRecord_1}  Set Variable  ${ulRbRlcMeasRecord['ulRbRlcMeasRecord'][${var}]['rbData'][1]['drb-Id']}
        ${sumOfRlcPduRxBytes_ulRbRlcMeasRecord_0}  Set Variable  ${ulRbRlcMeasRecord['ulRbRlcMeasRecord'][${var}]['rbData'][0]['sumOfRlcPduRxBytes']}
        ${sumOfRlcPduRxBytes_ulRbRlcMeasRecord_1}  Set Variable  ${ulRbRlcMeasRecord['ulRbRlcMeasRecord'][${var}]['rbData'][1]['sumOfRlcPduRxBytes']}
        ${timeOfUePduRx_ulRbRlcMeasRecord_0}  Set Variable  ${ulRbRlcMeasRecord['ulRbRlcMeasRecord'][${var}]['rbData'][0]['timeOfUePduRx']}
        ${timeOfUePduRx_ulRbRlcMeasRecord_1}  Set Variable  ${ulRbRlcMeasRecord['ulRbRlcMeasRecord'][${var}]['rbData'][1]['timeOfUePduRx']}
        ${recordCollectionDuration_0}  Set Variable  ${ulRbRlcMeasRecord['ulRbRlcMeasRecord'][${var}]['rbData'][0]['dataCollectionDuration']}
        ${recordCollectionDuration_1}  Set Variable  ${ulRbRlcMeasRecord['ulRbRlcMeasRecord'][${var}]['rbData'][1]['dataCollectionDuration']}
        Should Be True   0<${drb-Id_ulRbRlcMeasRecord_0}<33 and 0<${drb-Id_ulRbRlcMeasRecord_1}<33
        Should Be True   0<${sumOfRlcPduRxBytes_ulRbRlcMeasRecord_0}<114395448 or ${sumOfRlcPduRxBytes_ulRbRlcMeasRecord_0}==0
        Should Be True   0<${sumOfRlcPduRxBytes_ulRbRlcMeasRecord_1}<114395448 or ${sumOfRlcPduRxBytes_ulRbRlcMeasRecord_1}==0
        Should Be True   0<${timeOfUePduRx_ulRbRlcMeasRecord_0}<${recordCollectionDuration_0} or ${timeOfUePduRx_ulRbRlcMeasRecord_0}==0
        Should Be True   0<${timeOfUePduRx_ulRbRlcMeasRecord_1}<${recordCollectionDuration_1} or ${timeOfUePduRx_ulRbRlcMeasRecord_1}==0

        ${endMarker_current_0}  Set Variable  ${ulRbRlcMeasRecord['ulRbRlcMeasRecord'][${var}]['rbData'][0]['endMarker']}
        Run Keyword if  '${var}'=='0'
        ...   Should Be True  0<${recordCollectionDuration_0}<131073 or ${recordCollectionDuration_0}==0
        ...   ELSE IF   '${ulRbRlcMeasRecord['ulRbRlcMeasRecord'][${var-1}]['rbData'][0]['endMarker']}'=='TRUE' or '${endMarker_current_0}'=='TRUE'
        ...  Should Be True  0<${recordCollectionDuration_0}<131073 or ${recordCollectionDuration_0}==0
        ...  ELSE  Should Be True   ${recordCollectionDuration_0}==131072

        ${endMarker_current_1}  Set Variable  ${ulRbRlcMeasRecord['ulRbRlcMeasRecord'][${var}]['rbData'][1]['endMarker']}
        ${datelength}   Get Length   ${ulRbRlcMeasRecord['ulRbRlcMeasRecord'][${var-1}]['rbData']}
        ${endMarker_previous_1}  Set Variable If   '${datelength}'=='2'
        ...   ${ulRbRlcMeasRecord['ulRbRlcMeasRecord'][${var-1}]['rbData'][1]['endMarker']}
        ...   ${ulRbRlcMeasRecord['ulRbRlcMeasRecord'][${var-1}]['rbData'][0]['endMarker']}
        Run Keyword if  '${var}'=='0'
        ...   Should Be True  0<${recordCollectionDuration_1}<131073 or ${recordCollectionDuration_1}==0
        ...   ELSE IF   '${endMarker_previous_1}'=='TRUE' or '${endMarker_current_1}'=='TRUE'
        ...  Should Be True  0<${recordCollectionDuration_1}<131073 or ${recordCollectionDuration_1}==0
        ...  ELSE  Should Be True   ${recordCollectionDuration_1}==131072
    END
    ${rbData_length_1}   Get Length  ${rbData_length_1_idex_list}
    Pass Execution if   ${rbData_length_1}==0    No more data need to check!
    FOR  ${var}  IN  @{rbData_length_1_idex_list}
        ${drb-Id_ulRbRlcMeasRecord_0}  Set Variable  ${ulRbRlcMeasRecord['ulRbRlcMeasRecord'][${var}]['rbData'][0]['drb-Id']}
        ${sumOfRlcPduRxBytes_ulRbRlcMeasRecord_0}  Set Variable  ${ulRbRlcMeasRecord['ulRbRlcMeasRecord'][${var}]['rbData'][0]['sumOfRlcPduRxBytes']}
        ${timeOfUePduRx_ulRbRlcMeasRecord_0}  Set Variable  ${ulRbRlcMeasRecord['ulRbRlcMeasRecord'][${var}]['rbData'][0]['timeOfUePduRx']}
        ${recordCollectionDuration_0}  Set Variable  ${ulRbRlcMeasRecord['ulRbRlcMeasRecord'][${var}]['rbData'][0]['dataCollectionDuration']}
        Should Be True   0<${drb-Id_ulRbRlcMeasRecord_0}<33
        Should Be True   0<${sumOfRlcPduRxBytes_ulRbRlcMeasRecord_0}<114395448 or ${sumOfRlcPduRxBytes_ulRbRlcMeasRecord_0}==0
        Should Be True   -1<${timeOfUePduRx_ulRbRlcMeasRecord_0}<${recordCollectionDuration_0}
        ${endMarker_current_0}  Set Variable  ${ulRbRlcMeasRecord['ulRbRlcMeasRecord'][${var}]['rbData'][0]['endMarker']}
        Run Keyword if  '${var}'=='0'
        ...  Should Be True  0<${recordCollectionDuration_0}<131073 or ${recordCollectionDuration_0}==0
        ...   ELSE IF   '${ulRbRlcMeasRecord['ulRbRlcMeasRecord'][${var-1}]['rbData'][0]['endMarker']}'=='TRUE' or '${endMarker_current_0}'=='TRUE'
        ...  Should Be True  0<${recordCollectionDuration_0}<131073 or ${recordCollectionDuration_0}==0
        ...  ELSE  Should Be True   ${recordCollectionDuration_0}==131072
    END

Check dlRbRlcMeasRecord
    [Arguments]  ${ALL_PCMD_MSG}   ${CRNTI_LIST}
    Log To Console   Check dlRbRlcMeasRecord
    ${exist}  Set Variable  ${False}
    FOR   ${crnti}   IN   @{CRNTI_LIST}
        ${exist}  Run Keyword And Return Status   Dictionary Should Contain Key   ${ALL_PCMD_MSG['${crnti}']}  dlRbRlcMeasRecord
        run keyword if  not ${exist}   Fail
#        Continue For Loop If  not ${exist}
#        ${dlRbRlcMeasRecord}   Set Variable   ${ALL_PCMD_MSG['${crnti}']}
#        Check Sangle DLRLCTraceRecord Value   dlRbRlcMeasRecord=${dlRbRlcMeasRecord}
    END
    run keyword if  not ${exist}   Fail   Message Not Found!

Check Sangle DLRLCTraceRecord Value
    [Arguments]   ${dlRbRlcMeasRecord}
    ${dlRbRlcMeasRecord_length}  Get Length  ${dlRbRlcMeasRecord['dlRbRlcMeasRecord']}
    ${rbData_length_list}    create list
    ${rbData_length_1_idex_list}    create list
    ${rbData_length_2_idex_list}    create list
    FOR  ${idx}  IN RANGE  0  ${dlRbRlcMeasRecord_length}
        ${rbData_length}  Get Length  ${dlRbRlcMeasRecord['dlRbRlcMeasRecord'][${idx}]['rbData']}
        Append to list  ${rbData_length_list}  ${rbData_length}
        Run keyword if  ${rbData_length}==2  Append to list  ${rbData_length_2_idex_list}  ${idx}
        Run keyword if  ${rbData_length}==1  Append to list  ${rbData_length_1_idex_list}  ${idx}
    END
    FOR  ${idx}  IN RANGE  0  ${rbData_length_list}[0]
         ${first_dataCollectionDuration}  Set Variable  ${dlRbRlcMeasRecord['dlRbRlcMeasRecord'][0]['rbData'][${idx}]['dataCollectionDuration']}
         Should Be True  0<${first_dataCollectionDuration}<134273 or ${first_dataCollectionDuration}==0
    END
    Log To Console    first value of recordCollectionDuration is OK
    FOR  ${var}  IN  @{rbData_length_2_idex_list}
        ${var_1}   set variable   ${var}
        ${drb-Id_dlRbRlcMeasRecord_0}  Set Variable  ${dlRbRlcMeasRecord['dlRbRlcMeasRecord'][${var}]['rbData'][0]['drb-Id']}
        ${drb-Id_dlRbRlcMeasRecord_1}  Set Variable  ${dlRbRlcMeasRecord['dlRbRlcMeasRecord'][${var}]['rbData'][1]['drb-Id']}
        ${sumOfRlcPduTxBytes_dlRbRlcMeasRecord_0}  Set Variable  ${dlRbRlcMeasRecord['dlRbRlcMeasRecord'][${var}]['rbData'][0]['sumOfRlcPduTxBytes']}
        ${sumOfRlcPduTxBytes_dlRbRlcMeasRecord_1}  Set Variable  ${dlRbRlcMeasRecord['dlRbRlcMeasRecord'][${var}]['rbData'][1]['sumOfRlcPduTxBytes']}
        ${timeOfUePduTx_dlRbRlcMeasRecord_0}  Set Variable  ${dlRbRlcMeasRecord['dlRbRlcMeasRecord'][${var}]['rbData'][0]['timeOfUePduTx']}
        ${timeOfUePduTx_dlRbRlcMeasRecord_1}  Set Variable  ${dlRbRlcMeasRecord['dlRbRlcMeasRecord'][${var}]['rbData'][1]['timeOfUePduTx']}
        ${recordCollectionDuration_dlRbRlc_0}  Set Variable  ${dlRbRlcMeasRecord['dlRbRlcMeasRecord'][${var}]['rbData'][0]['dataCollectionDuration']}
        ${recordCollectionDuration_dlRbRlc_1}  Set Variable  ${dlRbRlcMeasRecord['dlRbRlcMeasRecord'][${var}]['rbData'][1]['dataCollectionDuration']}
        Should Be True   0<${drb-Id_dlRbRlcMeasRecord_0}<33 and 0<${drb-Id_dlRbRlcMeasRecord_1}<33
        Should Be True   0<${sumOfRlcPduTxBytes_dlRbRlcMeasRecord_0}<688766189 or ${sumOfRlcPduTxBytes_dlRbRlcMeasRecord_0}==0
        Should Be True   0<${sumOfRlcPduTxBytes_dlRbRlcMeasRecord_1}<688766189 or ${sumOfRlcPduTxBytes_dlRbRlcMeasRecord_1}==0
        Should Be True   0<${timeOfUePduTx_dlRbRlcMeasRecord_0}<${recordCollectionDuration_dlRbRlc_0} or ${timeOfUePduTx_dlRbRlcMeasRecord_0}==0
        Should Be True   0<${timeOfUePduTx_dlRbRlcMeasRecord_1}<${recordCollectionDuration_dlRbRlc_1} or ${timeOfUePduTx_dlRbRlcMeasRecord_1}==0

        ${endMarker_current_0}  Set Variable  ${dlRbRlcMeasRecord['dlRbRlcMeasRecord'][${var}]['rbData'][0]['endMarker']}
        Run Keyword if  '${var}'=='0'
        ...   Should Be True  0<${recordCollectionDuration_dlRbRlc_0}<131073 or ${recordCollectionDuration_dlRbRlc_0}==0
        ...   ELSE IF   '${dlRbRlcMeasRecord['dlRbRlcMeasRecord'][${var-1}]['rbData'][0]['endMarker']}'=='TRUE' or '${endMarker_current_0}'=='TRUE'
        ...  Should Be True  0<${recordCollectionDuration_dlRbRlc_0}<131073 or ${recordCollectionDuration_dlRbRlc_0}==0
        ...  ELSE  Should Be True   ${recordCollectionDuration_dlRbRlc_0}==131072

        ${endMarker_current_1}  Set Variable  ${dlRbRlcMeasRecord['dlRbRlcMeasRecord'][${var}]['rbData'][1]['endMarker']}
        ${datelength}   Get Length   ${dlRbRlcMeasRecord['dlRbRlcMeasRecord'][${var-1}]['rbData']}
        ${endMarker_previous_1}  Set Variable If   '${datelength}'=='2'
        ...   ${dlRbRlcMeasRecord['dlRbRlcMeasRecord'][${var-1}]['rbData'][1]['endMarker']}
        ...   ${dlRbRlcMeasRecord['dlRbRlcMeasRecord'][${var-1}]['rbData'][0]['endMarker']}
        Run Keyword if  '${var}'=='0'
        ...   Should Be True  0<${recordCollectionDuration_dlRbRlc_1}<131073 or ${recordCollectionDuration_dlRbRlc_1}==0
        ...   ELSE IF   '${endMarker_previous_1}'=='TRUE' or '${endMarker_current_1}'=='TRUE'
        ...  Should Be True  0<${recordCollectionDuration_dlRbRlc_1}<131073 or ${recordCollectionDuration_dlRbRlc_1}==0
        ...  ELSE  Should Be True   ${recordCollectionDuration_dlRbRlc_1}==131072
    END
    ${rbData_length_1}   Get Length  ${rbData_length_1_idex_list}
    Pass Execution if   ${rbData_length_1}==0    No more data need to check!
    FOR  ${var}  IN  @{rbData_length_1_idex_list}
        ${drb-Id_dlRbRlcMeasRecord_0}  Set Variable  ${dlRbRlcMeasRecord['dlRbRlcMeasRecord'][${var}]['rbData'][0]['drb-Id']}
        ${sumOfRlcPduTxBytes_dlRbRlcMeasRecord_0}  Set Variable  ${dlRbRlcMeasRecord['dlRbRlcMeasRecord'][${var}]['rbData'][0]['sumOfRlcPduTxBytes']}
        ${timeOfUePduTx_dlRbRlcMeasRecord_0}  Set Variable  ${dlRbRlcMeasRecord['dlRbRlcMeasRecord'][${var}]['rbData'][0]['timeOfUePduTx']}
        ${recordCollectionDuration_dlRbRlc_0}  Set Variable  ${dlRbRlcMeasRecord['dlRbRlcMeasRecord'][${var}]['rbData'][0]['dataCollectionDuration']}
        Should Be True   0<${drb-Id_dlRbRlcMeasRecord_0}<33
        Should Be True   0<${sumOfRlcPduTxBytes_dlRbRlcMeasRecord_0}<688766189 or ${sumOfRlcPduTxBytes_dlRbRlcMeasRecord_0}==0
        Should Be True   -1<${timeOfUePduTx_dlRbRlcMeasRecord_0}<${recordCollectionDuration_dlRbRlc_0}
        ${endMarker_current_0}  Set Variable  ${dlRbRlcMeasRecord['dlRbRlcMeasRecord'][${var}]['rbData'][0]['endMarker']}
        Run Keyword if  '${var}'=='0'
        ...  Should Be True  0<${recordCollectionDuration_dlRbRlc_0}<131073 or ${recordCollectionDuration_dlRbRlc_0}==0
        ...   ELSE IF   '${dlRbRlcMeasRecord['dlRbRlcMeasRecord'][${var-1}]['rbData'][0]['endMarker']}'=='TRUE' or '${endMarker_current_0}'=='TRUE'
        ...  Should Be True  0<${recordCollectionDuration_dlRbRlc_0}<131073 or ${recordCollectionDuration_dlRbRlc_0}==0
        ...  ELSE  Should Be True   ${recordCollectionDuration_dlRbRlc_0}==131072
    END

Check UlSchedulingRecord
    [Arguments]  ${ALL_PCMD_MSG}   ${CRNTI_LIST}
    Log To Console   Check UlSchedulingRecord
    Log To Console   ${CRNTI_LIST}
    ${exist}  Set Variable  ${False}
    FOR   ${crnti}   IN   @{CRNTI_LIST}
        ${exist}  Run Keyword And Return Status   Dictionary Should Contain Key   ${ALL_PCMD_MSG['${crnti}']}   ulSchedulingRecord
        run keyword if  not ${exist}   Fail
#        ${ulSchedulingRecord}   Set Variable   ${ALL_PCMD_MSG['${crnti}']}
#        Check Single UlSchedulingRecord Value   ulSchedulingRecord=${ulSchedulingRecord}
    END
    run keyword if  not ${exist}   Fail   Message Not Found!

Check Single UlSchedulingRecord Value
    [Arguments]   ${ulSchedulingRecord}
    ${SUlSchedulingTraceRecord_length}  Get Length  ${ulSchedulingRecord['ulSchedulingRecord']}
    FOR  ${idx}    IN RANGE    0  ${SUlSchedulingTraceRecord_length}
        ${recordCollectionDuration_SUlSched}  Set Variable  ${ulSchedulingRecord['ulSchedulingRecord'][${idx}]['recordCollectionDuration']}
        ${numOf1stMacPduTx_SUlSched}  Set Variable  ${ulSchedulingRecord['ulSchedulingRecord'][${idx}]['numOf1stMacPduTx']}
        ${numOfBad1stMacPduTx_SUlSched}  Set Variable  ${ulSchedulingRecord['ulSchedulingRecord'][${idx}]['numOfBad1stMacPduTx']}
        ${numOfBadLastMacPduTx_SUlSched}  Set Variable  ${ulSchedulingRecord['ulSchedulingRecord'][${idx}]['numOfBadLastMacPduTx']}
        ${numOfPuschTxWithRank1_SUlSched}  Set Variable  ${ulSchedulingRecord['ulSchedulingRecord'][${idx}]['numOfPuschTxWithRank1']}
        ${numOfPuschTxWithRank2_SUlSched}  Set Variable  ${ulSchedulingRecord['ulSchedulingRecord'][${idx}]['numOfPuschTxWithRank2']}
        ${timeOfUeSched_SUlSched}  Set Variable  ${ulSchedulingRecord['ulSchedulingRecord'][${idx}]['timeOfUeSched']}
        ${sumOfSinrSamples_SUlSched}  Set Variable  ${ulSchedulingRecord['ulSchedulingRecord'][${idx}]['avgSinr']['sumOfSinrSamples']}
        ${numOfSinrSamples_SUlSched}  Set Variable  ${ulSchedulingRecord['ulSchedulingRecord'][${idx}]['avgSinr']['numOfSinrSamples']}
        ${endMarker}  Set Variable  ${ulSchedulingRecord['ulSchedulingRecord'][${idx}]['endMarker']}
        Run Keyword If   '${endMarker}'=='TRUE'
        ...   Run Keywords   Should Be True   0<${recordCollectionDuration_SUlSched}<131073 or ${recordCollectionDuration_SUlSched}==0
        ...   AND   Should Be True   0<${numOf1stMacPduTx_SUlSched}<65537 or ${numOf1stMacPduTx_SUlSched}==0
        ...   AND   Should Be True   0<${numOfBad1stMacPduTx_SUlSched}<65537 or ${numOfBad1stMacPduTx_SUlSched}==0
        ...   AND   Should Be True   0<${numOfBadLastMacPduTx_SUlSched}<65537 or ${numOfBadLastMacPduTx_SUlSched}==0
        ...   AND   Should Be True   0<${numOfPuschTxWithRank1_SUlSched}<32769 or ${numOfPuschTxWithRank1_SUlSched}==0
        ...   AND   Should Be True   0<${numOfPuschTxWithRank2_SUlSched}<32769 or ${numOfPuschTxWithRank2_SUlSched}==0
        ...   AND   Should Be True   0<${numOfSinrSamples_SUlSched}<32769 or ${numOfSinrSamples_SUlSched}==0
        ...   ELSE IF   ${idx}==0
        ...   Run Keywords   Should Be True   0<${recordCollectionDuration_SUlSched}<134273 or ${recordCollectionDuration_SUlSched}==0
        ...   AND   Should Be True   0<${numOf1stMacPduTx_SUlSched}<67137 or ${numOf1stMacPduTx_SUlSched}==0
        ...   AND   Should Be True   0<${numOfBad1stMacPduTx_SUlSched}<67137 or ${numOfBad1stMacPduTx_SUlSched}==0
        ...   AND   Should Be True   0<${numOfBadLastMacPduTx_SUlSched}<76137 or ${numOfBadLastMacPduTx_SUlSched}==0
        ...   AND   Should Be True   0<${numOfPuschTxWithRank1_SUlSched}<33569 or ${numOfPuschTxWithRank1_SUlSched}==0
        ...   AND   Should Be True   0<${numOfPuschTxWithRank2_SUlSched}<33569 or ${numOfPuschTxWithRank2_SUlSched}==0
        ...   AND   Should Be True   0<${numOfSinrSamples_SUlSched}<33569 or ${numOfSinrSamples_SUlSched}==0
        ...   ELSE IF   '${endMarker}'=='FALSE' and '${ulSchedulingRecord['ulSchedulingRecord'][${idx-1}]['endMarker']}'=='TRUE'
        ...   Run Keywords   Should Be True   0<${recordCollectionDuration_SUlSched}<134273 or ${recordCollectionDuration_SUlSched}==0
        ...   AND   Should Be True   0<${numOf1stMacPduTx_SUlSched}<67137 or ${numOf1stMacPduTx_SUlSched}==0
        ...   AND   Should Be True   0<${numOfBad1stMacPduTx_SUlSched}<67137 or ${numOfBad1stMacPduTx_SUlSched}==0
        ...   AND   Should Be True   0<${numOfBadLastMacPduTx_SUlSched}<76137 or ${numOfBadLastMacPduTx_SUlSched}==0
        ...   AND   Should Be True   0<${numOfPuschTxWithRank1_SUlSched}<33569 or ${numOfPuschTxWithRank1_SUlSched}==0
        ...   AND   Should Be True   0<${numOfPuschTxWithRank2_SUlSched}<33569 or ${numOfPuschTxWithRank2_SUlSched}==0
        ...   AND   Should Be True   0<${numOfSinrSamples_SUlSched}<33569 or ${numOfSinrSamples_SUlSched}==0
        ...   ELSE
        ...   Run Keywords   Should Be True   ${recordCollectionDuration_SUlSched}==131072
        ...   AND   Should Be True   0<${numOf1stMacPduTx_SUlSched}<65537 or ${numOf1stMacPduTx_SUlSched}==0
        ...   AND   Should Be True   0<${numOfBad1stMacPduTx_SUlSched}<65537 or ${numOfBad1stMacPduTx_SUlSched}==0
        ...   AND   Should Be True   0<${numOfBadLastMacPduTx_SUlSched}<65537 or ${numOfBadLastMacPduTx_SUlSched}==0
        ...   AND   Should Be True   0<${numOfPuschTxWithRank1_SUlSched}<32769 or ${numOfPuschTxWithRank1_SUlSched}==0
        ...   AND   Should Be True   0<${numOfPuschTxWithRank2_SUlSched}<32769 or ${numOfPuschTxWithRank2_SUlSched}==0
        ...   AND   Should Be True   0<${numOfSinrSamples_SUlSched}<32769 or ${numOfSinrSamples_SUlSched}==0

        Should Be True   -1<${timeOfUeSched_SUlSched}<${recordCollectionDuration_SUlSched}+1
        Should Be True   101<${sumOfSinrSamples_SUlSched}<34373632001
    END

Check Du BearRecord
    [Arguments]  ${tcpdump}
    Log To Console   Check Du BearRecord
#    ${Setup_BearerInfo_F1ap}   Get Bearer Info From F1ap   tcpdump=${tcpdump}   f1apId=35
#    ${modify_BearerInfo_F1ap}   Get Bearer Info From F1ap   tcpdump=${tcpdump}   f1apId=37
#    :FOR   ${item}   IN   @{crnti}
#        ${Setup_BearerRecord_Info}   Get Info From Du BearerRecord   tcpdump=${tcpdump}   triggerType=1
#
#        ${modify_BearerRecord_Info}   Get Info From Du BearerRecord   tcpdump=${tcpdump}   triggerType=2
        Log To Console   check result
#        ${length}   Get Length   ${Setup_BearerRecord_Info['drbId']}
#        :FOR   ${index}   IN RANGE   ${length}
#            Run Keyword If   0< ${Setup_BearerRecord_Info['drbId'][${index}]} <33 and 0<= ${Setup_BearerRecord_Info['qli'][${index}]} <64
#            ...   Log To Console   drbId and qli are ok
#            ...   ELSE   Fail
#
#            Run Keyword If   0< ${modify_BearerRecord_Info['drbId'][${index}]} <33 and 0<= ${modify_BearerRecord_Info['qli'][${index}]} <64
#            ...   Log To Console   drbId and qli are ok
#            ...   ELSE   Fail
#        END
#        Dictionaries Should Be Equal   ${Setup_BearerRecord_Info}   ${Setup_BearerInfo_F1ap}
#        Dictionaries Should Be Equal   ${modify_BearerRecord_Info}   ${modify_BearerInfo_F1ap}
##    END
    Load Pcap File with Filter any Expression
    ...                        pcap_file=${tcpdump}
    ...                        any_expression=nsetapx.DuVendorExtensionRecordDataType == 13 && nsetapx.trigger == 1
    ...                        filter=tcp.dstport==49148

    ${trigger}   wireshark.get_field_value_by_xpath
    ...    xpath=.//nsetapx.bearerRecord/nsetapx.data_r1_element/nsetapx.trigger

    Should Not Be Empty   ${trigger}

    Load Pcap File with Filter any Expression
    ...                        pcap_file=${tcpdump}
    ...                        any_expression=nsetapx.DuVendorExtensionRecordDataType == 13 && nsetapx.trigger == 2
    ...                        filter=tcp.dstport==49148

    ${trigger}   wireshark.get_field_value_by_xpath
    ...    xpath=.//nsetapx.bearerRecord/nsetapx.data_r1_element/nsetapx.trigger

    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}

    Run Keyword If   '${ue_type}'!='nokia_fastmile'   Should Not Be Empty   ${trigger}

Get Bearer Info From F1ap
    [Arguments]  ${tcpdump}   ${f1apId}
    Load Pcap File with Filter any Expression
    ...                        pcap_file=${tcpdump}
    ...                        any_expression=f1ap.id == ${f1apId}
    ...                        filter=sctp.dstport==38472

    ${f1ap_xpath}   Set Variable If   '${f1apId}'=='37'   f1ap.UEContextModificationRequest_element   f1ap.UEContextSetupRequest_element
    ${xpath}   Set Variable If   '${f1apId}'=='37'   SetupMod   Setup
    ${xpath1}   Set Variable   .//${f1ap_xpath}/f1ap.protocolIEs//f1ap.ProtocolIE_Field_element/f1ap.value_element/
    ${xpath2}   Set Variable   ${xpath1}f1ap.DRBs_ToBe${xpath}_List//f1ap.ProtocolIE_SingleContainer_element/f1ap.value_element/
    ${xpath3}   Set Variable   ${xpath2}f1ap.DRBs_ToBe${xpath}_Item_element
    ${xpath4}   Set Variable   ${xpath3}/f1ap.qoSInformation/f1ap.choice_extension_element/f1ap.value_element/f1ap.DRB_Information_element
    ${dRB}   wireshark.get_field_value_by_xpath   xpath=${xpath3}/f1ap.dRBID
    ${dRB}   Remove Duplicates   ${dRB}

    ${fiveQI}   wireshark.get_field_value_by_xpath
    ...    xpath=${xpath4}/f1ap.dRB_QoS_element/f1ap.qoS_Characteristics/f1ap.non_Dynamic_5QI_element/f1ap.fiveQI

    ${priorityLevel}   wireshark.get_field_value_by_xpath
    ...    xpath=${xpath4}/f1ap.dRB_QoS_element/f1ap.nGRANallocationRetentionPriority_element/f1ap.priorityLevel

    ${preemptionCapability}   wireshark.get_field_value_by_xpath
    ...    xpath=${xpath4}/f1ap.dRB_QoS_element/f1ap.nGRANallocationRetentionPriority_element/f1ap.pre_emptionCapability   attribute_name=showname

    ${preemptionVulnerability}   wireshark.get_field_value_by_xpath
    ...    xpath=${xpath4}/f1ap.dRB_QoS_element/f1ap.nGRANallocationRetentionPriority_element/f1ap.pre_emptionVulnerability   attribute_name=showname

    ${sST}   wireshark.get_field_value_by_xpath   xpath=${xpath4}/f1ap.sNSSAI_element/f1ap.sST

    ${sD}   wireshark.get_field_value_by_xpath   xpath=${xpath4}/f1ap.sNSSAI_element/f1ap.sD

    ${xpath5}   Set Variable   ${xpath4}/f1ap.flows_Mapped_To_DRB_List//f1ap.Flows_Mapped_To_DRB_Item_element/f1ap.qoSFlowLevelQoSParameters_element/

    ${qli}   wireshark.get_field_value_by_xpath
    ...    xpath=${xpath4}/f1ap.flows_Mapped_To_DRB_List//f1ap.Flows_Mapped_To_DRB_Item_element/f1ap.qoSFlowIdentifier

    ${fiveQI2}   wireshark.get_field_value_by_xpath
    ...    xpath=${xpath5}f1ap.qoS_Characteristics/f1ap.non_Dynamic_5QI_element/f1ap.fiveQI

    ${priorityLevel2}   wireshark.get_field_value_by_xpath
    ...    xpath=${xpath5}f1ap.nGRANallocationRetentionPriority_element/f1ap.priorityLevel

    ${preemptionCapability2}   wireshark.get_field_value_by_xpath
    ...    xpath=${xpath5}f1ap.nGRANallocationRetentionPriority_element/f1ap.pre_emptionCapability   attribute_name=showname

    ${preemptionVulnerability2}   wireshark.get_field_value_by_xpath
    ...    xpath=${xpath5}f1ap.nGRANallocationRetentionPriority_element/f1ap.pre_emptionVulnerability   attribute_name=showname
    ${length}   Get Length   ${preemptionCapability}
    FOR   ${index}   IN RANGE   ${length}
        Log To Console   ${preemptionCapability[${index}]}
        Set List Value   ${preemptionCapability}   ${index}   ${preemptionCapability[${index}].replace('-','').lower()}
        Set List Value   ${preemptionVulnerability}   ${index}   ${preemptionVulnerability[${index}].replace('-','').lower()}
        Set List Value   ${preemptionCapability2}   ${index}   ${preemptionCapability2[${index}].replace('-','').lower()}
        Set List Value   ${preemptionVulnerability2}   ${index}   ${preemptionVulnerability2[${index}].replace('-','').lower()}
    END

    ${BearerInfo_F1ap}    Create Dictionary
    ...   drbId=${dRB}
    ...   fiveQi=${fiveQI}
    ...   priorityLevel=${priorityLevel}
    ...   preemptionCapability=${preemptionCapability}
    ...   preemptionVulnerability=${preemptionVulnerability}
    ...   sst=${sST}
    ...   sd=${sD}
    ...   qli=${qli}
    ...   fiveQi2=${fiveQI2}
    ...   priorityLevel2=${priorityLevel2}
    ...   preemptionCapability2=${preemptionCapability2}
    ...   preemptionVulnerability2=${preemptionVulnerability2}
    [Return]  ${BearerInfo_F1ap}

Get Info From Du BearerRecord
    [Arguments]  ${tcpdump}   ${triggerType}
    ${filter}   Set Variable   nsetapx.DuVendorExtensionRecordDataType == 13 && nsetapx.trigger == ${triggerType}
    Load Pcap File with Filter any Expression
    ...                        pcap_file=${tcpdump}
    ...                        any_expression=${filter}
    ...                        filter=tcp.dstport==49148

    ${drbId}   wireshark.get_field_value_by_xpath
    ...    xpath=.//nsetapx.bearerRecord/nsetapx.data_r1_element/nsetapx.setupBearers//nsetapx.DuBearerDataSetupItem_element/nsetapx.drb_Id

    ${xpath1}   Set Variable   .//nsetapx.bearerRecord/nsetapx.data_r1_element/nsetapx.setupBearers//nsetapx.DuBearerDataSetupItem_element/
    ${xpath2}   Set Variable   nsetapx.qosInformation/nsetapx.nr_Qos_element
    ${fiveQi}   wireshark.get_field_value_by_xpath
    ...    xpath=${xpath1}${xpath2}/nsetapx.drbLevelQos_element/nsetapx.qosCharacteristics/nsetapx.nonDynamicFiveQiDescriptor_element/nsetapx.fiveQi

    ${priorityLevel}   wireshark.get_field_value_by_xpath
    ...    xpath=${xpath1}${xpath2}/nsetapx.drbLevelQos_element/nsetapx.arp_element/nsetapx.priorityLevel

    ${preemptionCapability}   wireshark.get_field_value_by_xpath
    ...    xpath=${xpath1}${xpath2}/nsetapx.drbLevelQos_element/nsetapx.arp_element/nsetapx.preemptionCapability   attribute_name=showname

    ${preemptionVulnerability}   wireshark.get_field_value_by_xpath
    ...    xpath=${xpath1}${xpath2}/nsetapx.drbLevelQos_element/nsetapx.arp_element/nsetapx.preemptionVulnerability   attribute_name=showname

    ${sst}   wireshark.get_field_value_by_xpath
    ...    xpath=${xpath1}${xpath2}/nsetapx.snssai_element/nsetapx.sst

    ${sd}   wireshark.get_field_value_by_xpath
    ...    xpath=${xpath1}${xpath2}/nsetapx.snssai_element/nsetapx.sd

    ${qli}   wireshark.get_field_value_by_xpath
    ...    xpath=${xpath1}${xpath2}/nsetapx.qosFlowsMappedToBearer//nsetapx.DuQosFlowMappedToBearerItem_element/nsetapx.qfi

    ${xpath3}   Set Variable   /nsetapx.qosFlowsMappedToBearer//nsetapx.DuQosFlowMappedToBearerItem_element/nsetapx.qosParameters_element
    ${fiveQi2}   wireshark.get_field_value_by_xpath
    ...    xpath=${xpath1}${xpath2}${xpath3}/nsetapx.qosCharacteristics/nsetapx.nonDynamicFiveQiDescriptor_element/nsetapx.fiveQi

    ${priorityLevel2}   wireshark.get_field_value_by_xpath
    ...    xpath=${xpath1}${xpath2}${xpath3}/nsetapx.arp_element/nsetapx.priorityLevel

    ${preemptionCapability2}   wireshark.get_field_value_by_xpath
    ...    xpath=${xpath1}${xpath2}${xpath3}/nsetapx.arp_element/nsetapx.preemptionCapability   attribute_name=showname

    ${preemptionVulnerability2}   wireshark.get_field_value_by_xpath
    ...    xpath=${xpath1}${xpath2}${xpath3}/nsetapx.arp_element/nsetapx.preemptionVulnerability   attribute_name=showname

    ${length}   Get Length   ${preemptionCapability}
    FOR   ${index}   IN RANGE   ${length}
        Log To Console   ${preemptionCapability[${index}]}
        Set List Value   ${preemptionCapability}   ${index}   ${preemptionCapability[${index}].lower()}
        Set List Value   ${preemptionVulnerability}   ${index}   ${preemptionVulnerability[${index}].lower()}
        Set List Value   ${preemptionCapability2}   ${index}   ${preemptionCapability2[${index}].lower()}
        Set List Value   ${preemptionVulnerability2}   ${index}   ${preemptionVulnerability2[${index}].lower()}
    END

    ${BearerRecord_Info}    Create Dictionary
    ...   drbId=${drbId}
    ...   fiveQi=${fiveQi}
    ...   priorityLevel=${priorityLevel}
    ...   preemptionCapability=${preemptionCapability}
    ...   preemptionVulnerability=${preemptionVulnerability}
    ...   sst=${sst}
    ...   sd=${sd}
    ...   qli=${qli}
    ...   fiveQi2=${fiveQi2}
    ...   priorityLevel2=${priorityLevel2}
    ...   preemptionCapability2=${preemptionCapability2}
    ...   preemptionVulnerability2=${preemptionVulnerability2}
    [Return]  ${BearerRecord_Info}

Check gNB Du rrcSetupRecord
    [Arguments]  ${tcpdump}   ${crnti}   ${host}=${WEBUI_ADDR}
    Log To Console   check rrcSetupRecord
    FOR   ${index}   IN   @{crnti}
        Load Pcap File with Filter any Expression
        ...                        pcap_file=${tcpdump}
        ...                        any_expression=nsetapx.DuVendorExtensionRecordDataType == 16 && nsetapx.crnti == ${index}
        ...                        filter=tcp.dstport==49148

#        ${triggerRcvTimeSecond}   wireshark.get_field_value_by_xpath
#        ...    xpath=.//nsetapx.rrcSetupRecord/nsetapx.data_element/nsetapx.rrcConnReqTriggerRcvTime_element/nsetapx.seconds
#
#        ${triggerRcvTimeUsecond}   wireshark.get_field_value_by_xpath
#        ...    xpath=.//nsetapx.rrcSetupRecord/nsetapx.data_element/nsetapx.rrcConnReqTriggerRcvTime_element/nsetapx.useconds
        ${release}   Get gnb release   host=${host}
        ${xpath}   Set Variable If   '${release}'>='SBTS23R4'   .//nsetapx.rrcSetupRecord/nsetapx.data_r1_element/nsetapx.result
        ...   .//nsetapx.rrcSetupRecord/nsetapx.data_element/nsetapx.result
        ${result}   wireshark.get_field_value_by_xpath
        ...    xpath=${xpath}   attribute_name=showname

#        ${cause}   wireshark.get_field_value_by_xpath
#        ...    xpath=.//nsetapx.rrcSetupRecord/nsetapx.data_element/nsetapx.establishmentCauseType/nsetapx.establishmentCause
#        ...   attribute_name=showname
#
#        ${CmpRcvSecond}   wireshark.get_field_value_by_xpath
#        ...    xpath=.//nsetapx.rrcSetupRecord/nsetapx.data_element/nsetapx.rrcConnSetupCmplRcvTime_element/nsetapx.seconds
#
#        ${CmpRcvUsecond}   wireshark.get_field_value_by_xpath
#        ...    xpath=.//nsetapx.rrcSetupRecord/nsetapx.data_element/nsetapx.rrcConnSetupCmplRcvTime_element/nsetapx.useconds

#        Log to Console   RRC Setup Request
#        Load Pcap File with Filter any Expression
#        ...                        pcap_file=${tcpdump}
#        ...                        any_expression=nsetapx.asn1_MsgId == 26 && nsetapx.crnti == ${index}
#        ...                        filter=sctp.dstport==38472
#
#        ${rrccause}   wireshark.get_field_value_by_xpath
#        ...    xpath=.//nr-rrc.c1/nr-rrc.rrcSetupRequest_element/nr-rrc.rrcSetupRequest_element/nr-rrc.establishmentCause   attribute_name=showname
#
#        ${rrc_setup_request_seconds}=   wireshark.get_field_value_by_xpath   xpath=.//nsetapx.timestamp_element/nsetapx.seconds
#        ${rrc_setup_request_useconds}=   wireshark.get_field_value_by_xpath   xpath=.//nsetapx.timestamp_element/nsetapx.useconds

        Log to Console   Check result
#        Should Contain X Times   ${result}   result: success (0)   1
        Should Contain   ${result}   result: success (0)

#        ${cause}   Remove String Using Regexp   ${cause}[0]   \\d+
#        ${rrccause}   Remove String Using Regexp   ${rrccause[0].replace('-','')}   \\d+
#        Should Be Equal   ${cause}   ${rrccause}
#        Should Not Be Empty   ${triggerRcvTimeSecond}
#        Should Not Be Empty   ${triggerRcvTimeUsecond}
#        Should Not Be Empty   ${CmpRcvSecond}
#        Should Not Be Empty   ${CmpRcvUsecond}
#        ${rrc_setup_request_timestamp}   Remove Duplicates   ${rrc_setup_request_seconds}
##        List Should Be Equal   ${triggerRcvTimeSecond}   ${rrc_setup_request_timestamp}
#        ${time}   Evaluate   ${triggerRcvTimeSecond[0]}-${rrc_setup_request_timestamp[0]}
#        Run Keyword If   -1<= ${time} <=1
#        ...   Log To Console   timestamp is ok
#        ...   ELSE   Fail
##        Should Contain   ${cause}   establishmentCause: moSignalling
    END


Check TimingAdvanceRecord
    [Arguments]  ${tcpdump}
    Log To Console   Check TimingAdvanceRecord
#    :FOR   ${index}   IN   @{crnti}
    Load Pcap File with Filter any Expression
    ...                        pcap_file=${tcpdump}
    ...                        any_expression=nsetapx.DuVendorExtensionRecordDataType == 15
    ...                        filter=tcp.dstport==49148
    ${initial}   wireshark.get_field_value_by_xpath
    ...    xpath=.//nsetapx.DuVendorExtensionRecordDataType/nsetapx.timingAdvanceRecord/nsetapx.data_element/nsetapx.taData/nsetapx.initial

    Log To Console   check results
    FOR   ${item}   IN   @{initial}
        Should Be True   ${item}>=0
    END
#    END

Check ueCtxSetupRecord
    [Arguments]  ${tcpdump}   ${crnti}
    Log To Console   Check ueCtxSetupRecord
#    Load Pcap File with Filter any Expression
#    ...                        pcap_file=${tcpdump}
#    ...                        any_expression=f1ap.procedureCode == 5
#    ...                        filter=sctp.dstport==38472
#    ${f1ap_frame_list}   Check Field Value By Xpath    xpath=.//frame.number
#
#    ${f1ap-gnb-cu-ue-f1ap-id}   wireshark.get_field_value_by_xpath
#    ...    xpath=.//f1ap.UEContextSetupRequest_element/f1ap.protocolIEs//f1ap.ProtocolIE_Field_element/f1ap.value_element/f1ap.GNB_CU_UE_F1AP_ID
#    ...   attribute_name=showname
#
#    ${f1ap-gnb-du-ue-f1ap-id}   wireshark.get_field_value_by_xpath
#    ...    xpath=.//f1ap.UEContextSetupRequest_element/f1ap.protocolIEs//f1ap.ProtocolIE_Field_element/f1ap.value_element/f1ap.GNB_DU_UE_F1AP_ID
#    ...   attribute_name=showname
#    ${measConfig_xpath1}   set variable   .//f1ap.UEContextSetupRequest_element/f1ap.protocolIEs//f1ap.ProtocolIE_Field_element/f1ap.value_element
#    ${measConfig_xpath2}   set variable   /f1ap.CUtoDURRCInformation_element/f1ap.measConfig/nr-rrc.MeasConfig_element/nr-rrc.measObjectToAddModList
#    ${measConfig_xpath3}   set variable   //nr-rrc.MeasObjectToAddMod_element/nr-rrc.measObject/nr-rrc.measObjectNR_element
#    ${f1ap-ssbSubcarrierSpacing}   wireshark.get_field_value_by_xpath
#    ...    xpath=${measConfig_xpath1}${measConfig_xpath2}${measConfig_xpath3}/nr-rrc.ssbSubcarrierSpacing   attribute_name=showname
#    ${f1ap-absoluteFrequencySsb}   wireshark.get_field_value_by_xpath
#    ...    xpath=${measConfig_xpath1}${measConfig_xpath2}${measConfig_xpath3}/nr-rrc.ssbFrequency   attribute_name=showname

    ${length}   Get Length   ${crnti}
    FOR   ${index}   IN RANGE   ${length}
        Load Pcap File with Filter any Expression
        ...                        pcap_file=${tcpdump}
        ...                        any_expression=nsetapx.ueCtxSetupRecord == 1 && nsetapx.crnti == ${crnti}[${index}]
        ...                        filter=tcp.dstport==49148

        ${record_frame_list}   Check Field Value By Xpath    xpath=.//frame.number

        ${result}   wireshark.get_field_value_by_xpath
        ...    xpath=.//nsetapx.ueCtxSetupRecord/nsetapx.data_r1_element/nsetapx.result   attribute_name=showname
#        ${gnb-cu-ue-f1ap-id}   wireshark.get_field_value_by_xpath
#        ...    xpath=.//nsetapx.ueCtxSetupRecord/nsetapx.data_r1_element/nsetapx.gnb_cu_ue_f1ap_Id   attribute_name=showname
#        ${gnb-du-ue-f1ap-id}   wireshark.get_field_value_by_xpath
#        ...    xpath=.//nsetapx.ueCtxSetupRecord/nsetapx.data_r1_element/nsetapx.gnb_du_ue_f1ap_Id   attribute_name=showname
#        ${ssbSubcarrierSpacing}   wireshark.get_field_value_by_xpath
#        ...    xpath=.//nsetapx.ueCtxSetupRecord/nsetapx.data_r1_element/nsetapx.ssbSubcarrierSpacing   attribute_name=showname
#        ${dlCarrierBandWidthTdd}   wireshark.get_field_value_by_xpath
#        ...    xpath=.//nsetapx.ueCtxSetupRecord/nsetapx.data_r1_element/nsetapx.dlCarrierBandwidthTdd   attribute_name=showname
#        ${absoluteFrequencySsb}   wireshark.get_field_value_by_xpath
#        ...    xpath=.//nsetapx.ueCtxSetupRecord/nsetapx.data_r1_element/nsetapx.absoluteFrequencySsb   attribute_name=showname
#        ${initialtime_second}   wireshark.get_field_value_by_xpath
#        ...    xpath=.//nsetapx.ueCtxSetupRecord/nsetapx.data_r1_element/nsetapx.initialUeRrcMessageTransferSndTime_element/nsetapx.seconds
#        ...   attribute_name=showname
#        ${initialtime_usecond}   wireshark.get_field_value_by_xpath
#        ...    xpath=.//nsetapx.ueCtxSetupRecord/nsetapx.data_r1_element/nsetapx.initialUeRrcMessageTransferSndTime_element/nsetapx.useconds
#        ...   attribute_name=showname
#        ${reqrcvtime_second}   wireshark.get_field_value_by_xpath
#        ...    xpath=.//nsetapx.ueCtxSetupRecord/nsetapx.data_r1_element/nsetapx.ueCtxSetupReqRcvTime_element/nsetapx.seconds
#        ...   attribute_name=showname
#        ${reqrcvtime_usecond}   wireshark.get_field_value_by_xpath
#        ...    xpath=.//nsetapx.ueCtxSetupRecord/nsetapx.data_r1_element/nsetapx.ueCtxSetupCmplSndTime_element/nsetapx.useconds
#        ...   attribute_name=showname
#        ${cmplsndtime_second}   wireshark.get_field_value_by_xpath
#        ...    xpath=.//nsetapx.ueCtxSetupRecord/nsetapx.data_r1_element/nsetapx.ueCtxSetupCmplSndTime_element/nsetapx.seconds
#        ...   attribute_name=showname
#        ${cmplsndtime_usecond}   wireshark.get_field_value_by_xpath
#        ...    xpath=.//nsetapx.ueCtxSetupRecord/nsetapx.data_r1_element/nsetapx.ueCtxSetupCmplSndTime_element/nsetapx.useconds
#        ...   attribute_name=showname

        Log To Console   check results
#        ${neaby_list}    find_nearby_frame    ${f1ap_frame_list}    ${record_frame_list[-1]}
#        ${frame_index}   Get Index From List   ${f1ap_frame_list}   ${neaby_list}

        Should Contain   ${result}   result: success (0)
#        Should Contain X Times   ${result}   result: success (0)   2
#        ${f1aprecord}   Convert To Lower Case   ${f1ap-gnb-cu-ue-f1ap-id}[${frame_index}]
#    #    ${gnb-cu-ue-f1ap-id}   Convert To Lower Case   ${gnb-cu-ue-f1ap-id}
#        Should Contain X Times   ${gnb-cu-ue-f1ap-id}   ${f1aprecord.replace('i','I')}   2
#    #    ${f1ap-gnb-du-ue-f1ap-id}   Convert To Lower Case   ${f1ap-gnb-cu-ue-f1ap-id}[0]
#        ${f1aprecord}   Convert To Lower Case   ${f1ap-gnb-du-ue-f1ap-id}[${frame_index}]
#        Should Contain X Times   ${gnb-du-ue-f1ap-id}   ${f1aprecord.replace('i','I')}   2
#        Should Contain X Times   ${ssbSubcarrierSpacing}   ${f1ap-ssbSubcarrierSpacing}[${frame_index}]   2
#        ${f1aprecord}   set variable   ${f1ap-absoluteFrequencySsb}[${frame_index}]
#        Should Contain X Times   ${absoluteFrequencySsb}   ${f1aprecord.replace('ssbFrequency','absoluteFrequencySsb')}   2
#        Should Be Equal   ${dlCarrierBandWidthTdd}[0]   ${dlCarrierBandWidthTdd}[1]
#        ${initialtime_second_num}   Should Match Regexp   ${initialtime_second}[0]   \\d+
#        Should Not Be Empty   ${initialtime_second_num}
#        ${initialtime_usecond_num}   Should Match Regexp   ${initialtime_usecond}[0]   \\d+
#        Should Not Be Empty   ${initialtime_usecond_num}
#        ${reqrcvtime_second_num}   Should Match Regexp   ${reqrcvtime_second}[0]   \\d+
#        Should Not Be Empty   ${reqrcvtime_second_num}
#        ${reqrcvtime_usecond_num}   Should Match Regexp   ${reqrcvtime_usecond}[0]   \\d+
#        Should Not Be Empty   ${reqrcvtime_usecond_num}
#        ${cmplsndtime_second_num}   Should Match Regexp   ${cmplsndtime_second}[0]   \\d+
#        Should Not Be Empty   ${cmplsndtime_second_num}
#        ${cmplsndtime_usecond_num}   Should Match Regexp   ${cmplsndtime_usecond}[0]   \\d+
#        Should Not Be Empty   ${cmplsndtime_usecond_num}
    END
