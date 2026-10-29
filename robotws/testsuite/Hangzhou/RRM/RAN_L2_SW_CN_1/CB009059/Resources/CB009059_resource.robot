*** Settings ***


*** Keywords ***
Send Throuput over DRB1
    [Arguments]    ${ue_id}=1    ${pdu_id}=1
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=170 trf_id=1
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=170 trf_id=2
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=170 trf_id=3
    #Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=170 trf_id=4
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=100 trf_id=5
    sleep    10s    #sleep for stable traffic

Send Throuput over DRB2
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qfi}=2
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi} dir=dl mbps=170 trf_id=6
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi} dir=ul mbps=100 trf_id=7
    sleep    10s    #sleep for stable traffic

Send Throuput over DRB2 ULonly
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qfi}=2
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi} dir=ul mbps=100 trf_id=7
    sleep    10s    #sleep for stable traffic

Send Throuput over DRB2 DLonly
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qfi}=2
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi} dir=dl mbps=170 trf_id=6
    sleep    10s    #sleep for stable traffic

SA Stop Data Traffic Internal ForQfi2
    [Arguments]    ${ue_id}    ${pdu_id}    ${dir}=ul
    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_stop ue\=${ue_id} pdu\=${pdu_id} qfi=2 dir=${dir} trf_id=7

Verify Scell Deactivated
    ute_wtssim.Execute Egate Command    sim_log_set flush
    ${ret}=    OperatingSystem.Run    cat /opt/iphy/latest/egate_console.log
    Should Contain    ${ret}=    SCellIndex 1 deactivated successfully

Check DRB Infos
    [Arguments]    ${lc_id}=4    ${drb_id}=4
    ute_wtssim.Execute Egate Command    sim_log_set flush
    ${ret}=    OperatingSystem.Run    cat /opt/iphy/latest/egate_console.log
    Should Contain    ${ret}=    logicalChannelIdentity ${drb_id}
    Should Contain    ${ret}=    drb-Identity ${lc_id}

Check Traffic Of DRB For The Cell
    [Arguments]    ${ini_file}     ${log_dir}    ${dir}
    Log To Console    '\nCheck Drb info from ttitrace...\n'
    A2A_Check_CSV_Table    ${CURDIR}/../A2A/${ini_file}    output_${dir}.csv    ${log_dir}

Check DRB Traffic
    [Arguments]    ${casename}=BB01
    Check Traffic Of DRB For The Cell    CB009059_${casename}_DL_Drb.ini    ${TEST_LOG_DIRECTORY}/ttitrace/    dl
    Check Traffic Of DRB For The Cell    CB009059_${casename}_DL_Drb_abnormal.ini    ${TEST_LOG_DIRECTORY}/ttitrace/    dl
    Check Traffic Of DRB For The Cell    CB009059_${casename}_UL_Drb.ini    ${TEST_LOG_DIRECTORY}/ttitrace/    ul
    Check Traffic Of DRB For The Cell    CB009059_${casename}_UL_Drb_abnormal.ini    ${TEST_LOG_DIRECTORY}/ttitrace/    ul

Setup PDU2 Establish DRB3 Check CA Release
    ute_wtssim.Execute Egate Command And Wait For Data    cmd=ue_stats_nr id=1 type=pdsch scell=0-3    pass_regexp=CellIndex-2    timeout=3minutes 
    ute_wtssim.Execute Egate Command And Wait For Data    cmd=ue_stats_nr id=1 type=pusch scell=0-3    pass_regexp=CellIndex-1    timeout=3minutes

    #SA 5G PDU Session Setup    ${UE_ID}    pdu_id=2
    Execute Egate Command    cmd=ue_pdu_session_setup pdu=2 ue=1 nwslice=1 gw=1
    sleep    10s    #sleep for pdu	

    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=ue_pdu_session_modify ue=1 pdu=2 qosflows_to_add=3 by=amf    pass_regexp=QoS Routing Table   timeout=3minutes
    should contain    ${output}    drb-ToAddModList
    should contain    ${output}    pdu-Session 2
    should contain    ${output}    drb-Identity 8
    ${matchs}    String.Get Regexp Matches    ${output}    sCellToReleaseList[\\s\\S]*?{[\\s\\S]*?1,[\\s\\S]*?2[\\s\\S]*?}
    ${matchs2}    String.Get Regexp Matches    ${output}    logicalChannelIdentity 8,[\\s\\S]*?servedRadioBearer drb-Identity : 8
    Should Not Be Empty    ${matchs}    #match scells 1,2 release.
    Should Not Be Empty    ${matchs2}

Delete PDU2 CA Active
    sleep    10s    #sleep for traffic
    ute_wtssim.Execute Egate Command And Wait For Data    cmd=ue_stats_nr id=1 type=pdsch scell=0-3    pass_regexp=CellIndex-0    timeout=3minutes
    ute_wtssim.Execute Egate Command And Wait For Data    cmd=ue_stats_nr id=1 type=pusch scell=0-3    pass_regexp=CellIndex-0    timeout=3minutes

    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=ue_pdu_session_release ue=1 pdu=2   pass_regexp=SCellIndex 1 activated successful    timeout=3minutes
    sleep    10s    #sleep for egateconsole log print
    ute_wtssim.Execute Egate Command    sim_log_set flush
    ${matchs}    Run    tail -20 /opt/iphy/latest/egate_console.log.001|grep "SCellIndex 2 activated successful"
    Should Not Be Empty    ${matchs}

    sleep    10s    #sleep for traffic
    ute_wtssim.Execute Egate Command And Wait For Data    cmd=ue_stats_nr id=1 type=pdsch scell=0-3    pass_regexp=CellIndex-2    timeout=3minutes 
    ute_wtssim.Execute Egate Command And Wait For Data    cmd=ue_stats_nr id=1 type=pusch scell=0-3    pass_regexp=CellIndex-1    timeout=3minutes

Setup PDU Session
    [Arguments]    ${ue_id}=1    ${pdu_id}=1
    Log To Console    start 5G PDU Session Setup...
    ${command}    Set Variable    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} nwslice=1 gw=${pdu_id}
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}    pass_regexp=PDU SESSION ID-${pdu_id} setup/reestablishment complete    timeout=3minutes
    #${output}    String.Get Lines Matching Regexp    ${output}    Initial Context Setup Successful    partial_match=${true}
    Log To Console    ${output}

Check PDU And DRB Infos
    [Arguments]    ${pdu_drb_info}    ${egate_file}=/opt/iphy/latest/egate_console.log
    ute_wtssim.Execute Egate Command    sim_log_set flush
    ${content}    OperatingSystem.Get File    path=${egate_file}
    ${regexp}    Set Variable    drb-ToAddModList[\\s+\\S+]*?pdu-Session\\s(?P<pduId>\\d+)[\\s+\\S+]*?drb-Identity\\s(?P<drbId>\\d+)
    ${ret}    String.Get Regexp Matches    ${content}    ${regexp}    pduId    drbId
    BuiltIn.Log    ${ret}
    ${new_ret}=    Convert To String    ${ret}
    BuiltIn.Log    ${new_ret}
    Should Contain    ${new_ret}    ${pdu_drb_info}

Check Whether UE In CA Mode
    [Arguments]    ${UE_ID}=1    ${ca_num}=1
    ${output}=    ute_wtssim.Execute Egate Command And Wait For Data     cmd=ue_stats_nr id\=${UE_ID} type=pdsch scell=0-31    pass_regexp=EGATE
    Log    ${output}
    Should Contain X Times    ${output}    CellIndex-    ${ca_num}   msg=UE is not in ${ca_num} CC mode

Traffic Display
    Run Keyword And Ignore Error    ute_wtssim.Execute Egate Command And Wait For Data    cmd=ue_stats_nr id=1 type=pdsch scell=0-4
    ...    pass_regexp=CellIndex-0    timeout=60s
    sleep    5s    #for traffic
    Run Keyword And Ignore Error    ute_wtssim.Execute Egate Command And Wait For Data    cmd=ue_stats_nr id=1 type=pusch scell=0-4
    ...    pass_regexp=CellIndex-0    timeout=60s

Check DRB On The Cell
    [Arguments]    ${cell_id}    ${drb_id}    ${dir}=dl    ${log_path}=${TEST_LOG_DIRECTORY}/ttitrace
    ${list}    Run Keyword If    '${dir}'=='dl'
    ...    Ttitrace Filter Source Column Return Other Column    ${log_path}/output_dl.csv
    ...    physCellId     ["${cell_id}"]    include    dlFlowControlData.lchId    yes
    ...    ELSE
    ...    Ttitrace Filter Source Column Return Other Column    ${log_path}/output_ul.csv
    ...    physCellId     ["${cell_id}"]    include    ulPduDemuxData.rcvdBearers[0].lcId    yes
    Should Contain    ${list}    ${drb_id}

Check DRB Not On The Cell
    [Arguments]    ${cell_id}    ${drb_id}    ${dir}=dl    ${log_path}=${TEST_LOG_DIRECTORY}/ttitrace
    ${list}    Run Keyword If    '${dir}'=='dl'
    ...    Ttitrace Filter Source Column Return Other Column    ${log_path}/output_dl.csv
    ...    physCellId     ["${cell_id}"]    include    dlFlowControlData.lchId    yes
    ...    ELSE
    ...    Ttitrace Filter Source Column Return Other Column    ${log_path}/output_ul.csv
    ...    physCellId     ["${cell_id}"]    include    ulPduDemuxData.rcvdBearers[0].lcId    yes
    Should Not Contain    ${list}    ${drb_id}

UE Tput Status
    [Arguments]    ${UE_ID}=1
    sleep    10s    #sleep for traffic
    ute_wtssim.Execute Egate Command And Wait For Data    cmd=ue_stats_nr id\=${UE_ID} type=pdsch scell=0-3
    ...    pass_regexp=CellIndex-0    timeout=3minutes
    ute_wtssim.Execute Egate Command And Wait For Data    cmd=ue_stats_nr id\=${UE_ID} type=pusch scell=0-3
    ...    pass_regexp=CellIndex-0    timeout=3minutes