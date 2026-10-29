*** Settings ***
Resource   Common.robot

*** Variable ***
# ${param}  {"distName":"CELL_DN","operation":"update","parameters":[{"parameterName":"administrativeState","value":"Locked","operation":"update"}]}
${L3CALL_Record_File_Path}   ${OUTPUT_DIR}/../../../../../L3CALL_Record/target_L3CALL_FAILED

*** Keywords ***
UUF Target Packge L3CALL Process
    ${L3CALL_COMPASS_Record}    Create list   total cell number:${multitl_total_cellnum}
    Set suite variable    ${L3CALL_COMPASS_Record}
    ${L3CALL_COMPASS_Result}    Create list
    Set suite variable    ${L3CALL_COMPASS_Result}
    FOR  ${testline}  IN   @{UPGRADE_SEQUENCE}
        ${passed}    run keyword and return status    UUF L3CALL Single Testline    testline=${testline}
        run keyword if  ${passed}    Log To Console   | ${testline} Target Packge L3CALL Finished!
    END

    Convert L3CALL Result to COMPASS Format
    ${passed}    run keyword and return status    Should Not Contain Match    ${L3CALL_COMPASS_Result}    regexp=\\S+_\\d+_fail
    run keyword if  not ${passed}    run keywords    Create File    ${L3CALL_Record_File_Path}
    ...   AND   FAIL   msg=**** L3 CALL failed!****

    [Teardown]  UUF Save Execution Results JSON Dictionary   action=${UUF_PROCESS}   add_key=l3_call   add_value=${L3CALL_COMPASS_Record}


UUF Source Packge L3CALL Process
    ${not_exist}    run keyword and return status     Directory Should not Exist   ${OUTPUT_DIR}/../L3CALL_Record
    run keyword if  ${not_exist}   first L3CALL and Set Flag
    ...   ELSE   Judge first L3CALL Sucess or Fail

UUF L3CALL Single Testline
    [Arguments]   ${testline}
    [Timeout]    120min
    Log To Console   //TODO: UUF L3CALL Single Testline
    @{UUF_L3CALL_info}   Get Variable Value   ${UUF_L3Call["${TESTLINE_IDENTITY}"]["${testline}"]}    @{EMPTY}
    FOR  ${ue}   IN    @{UUF_L3CALL_info}
        L3CALL Single UE   L3CALL_cell_list=${ALL_CONFIG_L3CALL['${testline}']['UE${ue}_L3CALL_cell_list']}
        ...   ue_index=${ue}   tl_index=${testline}
    END

UUF L3CALL Check
     ${L3CALL_FAILED}   Run Keyword And Return Status   File Should Exist   ${L3CALL_Record_File_Path}
     Run Keyword If   ${L3CALL_FAILED}   Fatal Error   msg=target packge L3 CALL FAILED!

Judge first L3CALL Sucess or Fail
    ${exist}    run keyword and return status     File Should Exist     ${OUTPUT_DIR}/../L3CALL_Record/first_L3CALL_passed
    run keyword if  ${exist}    set suite variable   ${l3_call}    Y
    ...   ELSE   set suite variable   ${l3_call}    N


first L3CALL and Set Flag
    ${L3CALL_source_Result}    Create list
    Set suite variable    ${L3CALL_source_Result}
    L3CALL Testline LOOP
    ${passed}    run keyword and return status    Should Not Contain Match    ${L3CALL_source_Result}    regexp=\\S+_\\d+_fail
    run keyword if  ${passed}    run keywords    Create File    ${OUTPUT_DIR}/../L3CALL_Record/first_L3CALL_passed
    ...   AND    LOG TO CONSOLE     | source package L3CALL finished!
    ...   ELSE    run keywords    Create File    ${OUTPUT_DIR}/../L3CALL_Record/first_L3CALL_failed
    ...   AND   set suite variable   ${l3_call}    N
    ...   AND   LOG TO CONSOLE     | source package L3CALL failed!

L3CALL Testline LOOP
    FOR  ${testline}  IN   @{UPGRADE_SEQUENCE}
         run keyword if  ${l3_call.count('Y')}>0   UUF L3CALL Single Testline   testline=${testline}
    END

Get L3CALL Network_mode
    [Arguments]   ${testline}
    ${X2_Type}   Get Variable Value   ${ALL_CONFIG_SCF["${testline}"]["X2_Type"]}
    ${SA_Type}   Get Variable Value   ${ALL_CONFIG_SCF["${testline}"]["SA_Type"]}
    ${network_mode}    Set Variable if  '${X2_Type}'=='${True}' and '${SA_Type}'=='${False}'   NR5GNSA    NR5GSA
    [Return]   ${network_mode}

L3CALL Single UE
    [Arguments]   ${L3CALL_cell_list}   ${ue_index}    ${tl_index}
    ${network_mode}    Get L3CALL Network_mode    testline=${tl_index}
    Set Test Variable   ${ue_${ue_index}_required}   ${False}
    FOR   ${cell}   IN   @{L3CALL_cell_list}
        ${l3call_celldn}   Set Variable   ${cell['celldn']}
        ${l3call_pci}   Set Variable   ${cell['pci']}
        ${l3call_arfcn}   Set Variable   ${cell['arfcn']}
        ${l3call_band}   Set Variable   ${cell['band']}
        ${l3call_narrowbandIotMode}    Set Variable   ${cell['narrowbandIotMode']}

        ${l3call_cell}    Set Variable if  '${network_mode}'=='NR5GNSA'   ${cell['nrCellIdentity']}    None
        ${nrCellIdentity_list}    Create List    ${l3call_cell}

        ${ue_reboot}    Set Variable   ${UUF_L3Call["${TESTLINE_IDENTITY}"]["${tl_index}"]["${ue_index}"]["ue_reboot"]}
        ${attach_only}    Set Variable   ${UUF_L3Call["${TESTLINE_IDENTITY}"]["${tl_index}"]["${ue_index}"]["attach_only"]}
        ${dl_tp}    Set Variable   ${UUF_L3Call["${TESTLINE_IDENTITY}"]["${tl_index}"]["${ue_index}"]["dl_tp"]}
        ${dl_tp_ratio}    Set Variable   ${UUF_L3Call["${TESTLINE_IDENTITY}"]["${tl_index}"]["${ue_index}"]["dl_tp_ratio"]}
        ${ul_tp}    Set Variable  ${UUF_L3Call["${TESTLINE_IDENTITY}"]["${tl_index}"]["${ue_index}"]["ul_tp"]}
        ${ul_tp_ratio}    Set Variable   ${UUF_L3Call["${TESTLINE_IDENTITY}"]["${tl_index}"]["${ue_index}"]["ul_tp_ratio"]}
        ${duration}    Set Variable   ${UUF_L3Call["${TESTLINE_IDENTITY}"]["${tl_index}"]["${ue_index}"]["duration"]}
        ${actImgGeneration}    Set Variable   ${UUF_L3Call["${TESTLINE_IDENTITY}"]["${tl_index}"]["${ue_index}"]["actImgGeneration"]}


        ${direction}    Get L3CALL Traffic Direction   dl_tp=${dl_tp}   ul_tp=${ul_tp}

        Log To Console   | L3CALL TestLine: ${tl_index}
        Log To Console   | L3CALL UE Index: ${ue_index}
        Log To Console   | L3CALL celldn: ${l3call_celldn}
        Log To Console   | L3CALL pci: ${l3call_pci}
        Log To Console   | L3CALL arfcn: ${l3call_arfcn}
        Log To Console   | L3CALL band: ${l3call_band}
        Log To Console   | L3CALL attach_only: ${attach_only}
        Log To Console   | L3CALL input dl_tp: ${dl_tp}
        Log To Console   | L3CALL input dl_tp_ratio: ${dl_tp_ratio}
        Log To Console   | L3CALL input ul_tp: ${ul_tp}
        Log To Console   | L3CALL input ul_tp_ratio: ${ul_tp_ratio}
        Log To Console   | L3CALL input duration: ${duration}
        Log To Console   | L3CALL input direction: ${direction}
        Log To Console   | L3CALL input actImgGeneration: ${actImgGeneration}



        Log To Console   | L3CALL Start
        ${status}    run keyword and return status    Wait Until Keyword Succeeds   3x   5s   Common L3CALL with Power UE
        ...   cells=${nrCellIdentity_list}
        ...   ue_index=${ue_index}
        ...   duration=${duration}
        ...   direction=${direction}
        ...   dl_tp=${dl_tp}
        ...   ul_tp=${ul_tp}
        ...   dl_tp_ratio=${dl_tp_ratio}
        ...   ul_tp_ratio=${ul_tp_ratio}
        ...   attach_only=${attach_only}
        ...   actImgGeneration=${actImgGeneration}
        ...   pci=${l3call_pci}
        ...   arfcn=${l3call_arfcn}
        ...   band=${l3call_band}
        ...   network_mode=${network_mode}
        ${status}    run keyword if  '${status}'=='${FALSE}' and ${l3call_narrowbandIotMode.count('guardband')}>0
        ...   IOT Cell L3CALL Progress
        ...   tl_index=${tl_index}
        ...   nrCellIdentity_list=${nrCellIdentity_list}
        ...   ue_index=${ue_index}
        ...   duration=${duration}
        ...   direction=${direction}
        ...   dl_tp=${dl_tp}
        ...   ul_tp=${ul_tp}
        ...   dl_tp_ratio=${dl_tp_ratio}
        ...   ul_tp_ratio=${ul_tp_ratio}
        ...   attach_only=${attach_only}
        ...   actImgGeneration=${actImgGeneration}
        ...   l3call_pci=${l3call_pci}
        ...   network_mode=${network_mode}
        ...   ELSE    set variable    ${status}
        ${l3call_result}    set variable if   ${status}   pass   fail
        ${output}    get variable value   ${L3CALL_COMPASS_Result}
        run keyword if   $output!=${None}    Append to list    ${L3CALL_COMPASS_Result}    ${l3call_band}_${l3call_pci}_${l3call_result}
        ${output}    get variable value   ${L3CALL_source_Result}
        run keyword if   $output!=${None}    Append to list    ${L3CALL_source_Result}    ${l3call_band}_${l3call_pci}_${l3call_result}
        Log To Console   | L3CALL Finished
    END

IOT Cell L3CALL Progress
    [Arguments]     ${tl_index}    ${nrCellIdentity_list}   ${ue_index}    ${duration}   ${direction}   ${dl_tp}   ${ul_tp}
    ...   ${dl_tp_ratio}   ${ul_tp_ratio}    ${attach_only}    ${actImgGeneration}    ${l3call_pci}    ${network_mode}
    ${l3call_arfcn}   Set Variable    ${UUF_L3Call["${TESTLINE_IDENTITY}"]["${tl_index}"]["${ue_index}"]["arfcn_${l3call_pci}"]}
    ${l3call_band}   Set Variable    ${UUF_L3Call["${TESTLINE_IDENTITY}"]["${tl_index}"]["${ue_index}"]["band_${l3call_pci}"]}
    Log To Console   | L3CALL cell is NB-IOT, try to another arfcn to do ue attach!
    Log To Console   | L3CALL pci: ${l3call_pci}
    Log To Console   | L3CALL arfcn: ${l3call_arfcn}
    Log To Console   | L3CALL band: ${l3call_band}
    ${status}    run keyword and return status    Wait Until Keyword Succeeds   3x   5s   Common L3CALL with Power UE
        ...   cells=${nrCellIdentity_list}
        ...   ue_index=${ue_index}
        ...   duration=${duration}
        ...   direction=${direction}
        ...   dl_tp=${dl_tp}
        ...   ul_tp=${ul_tp}
        ...   dl_tp_ratio=${dl_tp_ratio}
        ...   ul_tp_ratio=${ul_tp_ratio}
        ...   attach_only=${attach_only}
        ...   actImgGeneration=${actImgGeneration}
        ...   pci=${l3call_pci}
        ...   arfcn=${l3call_arfcn}
        ...   band=${l3call_band}
        ...   network_mode=${network_mode}
    [Return]     ${status}


Get L3CALL Traffic Direction
    [Arguments]    ${dl_tp}=100    ${ul_tp}=100
    ${direction}    Run Keyword if      '${dl_tp}'=='0'     set variable   ul
    ...    ELSE IF    '${ul_tp}'=='0'    set variable    dl
    ...    ELSE    set variable     BOTH
    [Return]   ${direction}

Convert L3CALL Result to COMPASS Format
    ${NR_L3CALL_cell}    Create List
    ${NR_L3CALL_pass}    Create List
    ${LTE_L3CALL_cell}    Create List
    ${LTE_L3CALL_pass}    Create List
    FOR  ${cell}   IN    @{L3CALL_COMPASS_Result}
        ${band}    Get Regexp Matches    ${cell.lower()}    (n\\d+|b\\d+)_   1
        ${band}    Set Variable    ${band[0]}
        run keyword if  ${band.lower().count('n')}>0   Append to List    ${NR_L3CALL_cell}   ${cell}
        run keyword if  ${band.lower().count('n')}>0 and ${cell.count('pass')}>0   Append to List    ${NR_L3CALL_pass}   ${cell}
        run keyword if  ${band.lower().count('b')}>0   Append to List    ${LTE_L3CALL_cell}   ${cell}
        run keyword if  ${band.lower().count('b')}>0 and ${cell.count('pass')}>0   Append to List    ${LTE_L3CALL_pass}   ${cell}
    END
    Log    ${NR_L3CALL_cell}
    Log    ${NR_L3CALL_pass}
    Log    ${LTE_L3CALL_cell}
    Log    ${LTE_L3CALL_pass}
    ${NRcell_pass_num}    Evaluate    len(${NR_L3CALL_pass})
    ${NRcell_total_num}    Evaluate   len(${NR_L3CALL_cell})
    ${LTEcell_pass_num}    Evaluate    len(${LTE_L3CALL_pass})
    ${LTEcell_total_num}    Evaluate    len(${LTE_L3CALL_cell})
    Append to List    ${L3CALL_COMPASS_Record}    NRCELL: ${NRcell_pass_num}/${NRcell_total_num} passed
    Append to List    ${L3CALL_COMPASS_Record}    LTECELL: ${LTEcell_pass_num}/${LTEcell_total_num} passed




#UUF L3CALL Single Testline
#    [Arguments]   ${testline}
#    Log To Console   //TODO: UUF L3CALL Single Testline
##    @{UUF_L3CALL_info}   Get Variable Value   ${UUF_L3Call["${TESTLINE_IDENTITY}"]["${testline}"}   @{EMPTY}
#    :For  ${ue}   IN    @{UUF_L3Call["${TESTLINE_IDENTITY}"]["${testline}"].keys()}
#        L3CALL Single UE   L3CALL_cell_list=${ALL_CONFIG_OTHERS['${testline}']['L3CALL_cell_list']}
#        ...   ue_index=${ue}   tl_index=${testline}
#    END



#UUF L3CALL ALL
#    # ${L3Call_Status_List}   Create List
#    ${L3Call_Flag}   Run Keyword And Return Status   Dictionary Should Contain Key   ${UUF_L3Call}   ${bts_id}
#    ${TL_Info}   Run Keyword If  ${L3call_Flag}   Set Variable   &{UUF_L3Call}[${bts_id}]
#    :FOR   ${rmod_sn}   IN   @{TL_Info.keys()}
#        Log To Console   RMOD_SN: ${rmod_sn}
#        L3CALL Single RMOD   rmod_env=${TL_Info['${rmod_sn}']}
#        # ${status}   Run Keyword And Return Status   L3CALL Single RMOD   rmod_env=${TL_Info['${rmod_sn}']}
#        # ${L3call_status}   Set Variable If   ${status}   ${rmod_sn} pass   ${rmod_sn} fail
#        # Append To List   ${L3Call_Status_List}   ${L3Call_Status}
#    END
    # Run Keyword And Ignore Error   add_json_to_file   l3_call   ${L3Call_Status_List}
    # ...   ${OUTPUT_DIR}/execution_results.json   upgrade
    # Should Not Contain Match   ${L3Call_Status_List}   fail

#Group L3CALL Cell List
#    [Arguments]   ${L3CALL_cell_list}    ${tl_index}    ${ue_index}
#    ${band_cell_mapping_dic}    Create Dictionary
#    :For  ${band}   IN   @{UUF_L3Call["${TESTLINE_IDENTITY}"]["${tl_index}"]["${ue_index}"]["L3CALL_band"]}
#        ${one_band_cell_list}    Group L3CALL Cell List by Band    ${band}    L3CALL_cell_list=${L3CALL_cell_list}
#        Set To Dictionary   ${band_cell_mapping_dic}    ${band}=${one_band_cell_list}
#    END
#
#
#    ${network_cell_mapping_dic}    Create Dictionary
#    ${lte_band_cell_list}    create List
#    ${nr_band_cell_list}    create List
#    :For    ${band}    IN    @{band_cell_mapping_dic}
#        Run keyword If    ${band.upper().count('B')} >0
#        ...   ${lte_band_cell_list}    Combine Lists   ${lte_band_cell_list}    ${band_cell_mapping_dic['${band}']}
#        ...   ELSE IF    ${band.upper().count('N')} >0
#        ...   ${nr_band_cell_list}    Combine Lists    ${nr_band_cell_list}    ${band_cell_mapping_dic['${band}']}
#    END
#
#    Set To Dictionary    ${network_cell_mapping_dic}      LTE=${lte_band_cell_list}   NR5GSA=${nr_band_cell_list}
#
#    [Return]    ${network_cell_mapping_dic}
#
#
#Group L3CALL Cell List by Band
#    [Arguments]   ${band}    ${L3CALL_cell_list}
#    ${one_band_cell_list}   Create List
#    :FOR   ${cell}   IN   @{L3CALL_cell_list}
#        run keyword if   '${cell['band'].upper()}'=='${band}'
#        ...   Append to List    ${one_band_cell_list}    ${cell}
#    END
#    [Return]    ${one_band_cell_list}


#L3CALL Single UE
#    [Arguments]   ${L3CALL_cell_list}    ${ue_index}    ${tl_index}
#    ${network_cell_mapping_dic}    Group L3CALL Cell List    L3CALL_cell_list=${L3CALL_cell_list}
#    ...   ue_index=${ue_index}    tl_index=${tl_index}
#    Set Test Variable   ${ue_${ue_index}_required}   ${False}
#    ${ue_type}     translate power ue type from testline    ${ue_index}
#    Set Suite Variable   ${ue_${ue_index}_type}    ${ue_type}
#    UE precondition with Power UE     ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}
#    :For    ${network_mode}    IN    @{network_cell_mapping_dic}
#        Lock Network Technology from UE    ue_index=${ue_index}    network_mode=${network_mode}
#        L3CALL Single Network Mode    L3CALL_cell_list=${network_cell_mapping_dic['${network_mode}']}
#        ...    ue_index=${ue_index}   tl_index=${tl_index}
#    END

#L3CALL Single Network Mode
#    [Arguments]   ${band_cell_mapping_dic}   ${ue_index}    ${tl_index}
#    :FOR   ${band}    IN   @{band_cell_mapping_dic}
#        Lock band from UE   ue_index=${ue_index}   band=${band}
#        L3CALL Single Band    L3CALL_cell_list=${band_cell_mapping_dic['${band}']}   ue_index=${ue_index}   tl_index=${tl_index}
#    END
