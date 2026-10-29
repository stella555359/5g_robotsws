*** Settings ***
Documentation
...  common KW



*** Variables ***


*** Keywords ***
OAM Precondition Cell Should Be Onair
    [Arguments]   ${gnb_index}=0
    [Documentation]  Do some common thing for every precondition of cases
    ...             any case should include it in test case setup
    ...             it will do following actions
    ...             1) check cell should be onair
    ...             2) initial global test varible
    ...   *Author*: xianbiao.cheng@nokia-sbell.com
    ...   *History Change*
    ...   | date | who | what and how |
    ...   | 2022-1-14 | chris.l.cao | remove 'CU Get Cells ID list' to save cell id information |
    ...   | 2022-1-22 | chris.l.cao | remove unused variable ${BACKUP_SCF_PATH_ON_CU} to shorten dryrun time |
    ...   | 2022-4-6 | hongysun | update documentation |
    ...   *Arguments Description*
    ...   | Input Parameters | Man. | Description |
    ...   None
    ...   *Return*
    ...   None
    ...   *Example*
    ...   | OAM Precondition Cell Should Be Onair |
    log to console  \n*** OAM Precondition Cell Should Be Onair ... ***
    ${vdu_numbers}   Get DU Numbers   ${gnb_index}
    FOR   ${vdu_index}   IN RANGE   ${vdu_numbers}
        All DUs Container Status Should Be Normal    gnb_index=${gnb_index}   vdu_index=${vdu_index}
    END
    CU Verify All Cells Status Are Onair   gnb_index=${gnb_index}
    vDU Verify All Cells Status Should Be Onair For All DUs    gnb_index=${gnb_index}

   #    Should Have Power On All RUs

    set test variable  ${ACTIVE_ALARM_LST_PRE_DU}       tbd
    set test variable  ${ACTIVE_ALARM_LST_PRE_FHGW}     tbd


OAM Postcondition Cell Should Be Onair
    [Arguments]   ${gnb_index}=0
    [Documentation]    Do some common thing for every postcondition of cases
    ...    any case should include it in test case setup
    ...    it will do following actions
    ...    1) check cell should be onair
    ...    2) close resources
    ...    *AUTHOR* xianbiao.cheng@nokia-sbell.com
    ...   history change
    ...    modified by:        <28-Jul-2020>, <pelin>, <Initial creation>
    ...    -31.03.2023,lingting.sun@nokia-sbell.com,modify KW to trigger log collection if failed in teardown
    ...    -29.07.2020,peng.ling@nokia-sbell.com,modify KW according to review finding
    ...    -30.05.2020,xianbiao.cheng@nokia-sbell.com,new KW add
    ...    -5.7.2023,rui.3.li@nokia-sbell.com, support multiple cu
    ...    | Input Parameters | Man. | Description |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    | OAM Postcondition Cell Should Be Onair | |
    ${is_in_teardown}=    Is Run In TearDown
    run keyword if   "${is_in_teardown}"=="${False}"   _Cell Should Be Onair In Case   gnb_index=${gnb_index}
    ...   ELSE IF    "${is_in_teardown}"=="${True}"  _Cell Should Be Onair In Case Teardown   gnb_index=${gnb_index}


_Cell Should Be Onair In Case
    [Arguments]   ${gnb_index}=0
    log to console  \n*** OAM Postcondition Cell Should Be Onair ... ***
    ${vdu_numbers}   Get DU Numbers   ${gnb_index}
    FOR   ${vdu_index}   IN RANGE   ${vdu_numbers}
        All DUs Container Status Should Be Normal    gnb_index=${gnb_index}   vdu_index=${vdu_index}
    END
    CU Verify All Cells Status Are Onair    gnb_index=${gnb_index}
    vDU Verify All Cells Status Should Be Onair For All DUs    gnb_index=${gnb_index}


_Cell Should Be Onair In Case Teardown
    [Arguments]   ${gnb_index}=0
    log to console  \n*** OAM Postcondition Cell Should Be Onair In Case Teardown... ***
    ${exist}    Run Keyword And Return Status    Variable Should Exist     ${POST_CELL_STATUS}
    run keyword if   "${exist}"=="${False}"   set test variable   ${POST_CELL_STATUS}    ${False}
    ${vdu_numbers}   Get DU Numbers   ${gnb_index}
    FOR   ${vdu_index}   IN RANGE   ${vdu_numbers}
        ${r1}    Run Keyword And Return Status    All DUs Container Status Should Be Normal    gnb_index=${gnb_index}
        ...   vdu_index=${vdu_index}
        run keyword and continue on failure     Should Be True   ${r1}
        ...  msg=please check the result of KW [All DUs Container Status Should Be Normal]
        Exit For Loop If   ${r1}==${False}
    END

    ${r2}    Run Keyword And Return Status    CU Verify All Cells Status Are Onair    gnb_index=${gnb_index}
    run keyword and continue on failure     Should Be True   ${r2}
    ...  msg=please check the result of KW [CU Verify All Cells Status Are Onair]

    FOR   ${vdu_index}   IN RANGE   ${vdu_numbers}
        ${r3}    Run Keyword And Return Status    vDU Verify All Cells Status Should Be Onair
        run keyword and continue on failure     Should Be True   ${r3}
        ...  msg=please check the result of KW [vDU Verify All Cells Status Should Be Onair]
        Exit For Loop If   ${r3}==${False}
    END
    ${r_tmp}     evaluate    ${r1} & ${r2} & ${r3}
    ${POST_CELL_STATUS}   evaluate    ${POST_CELL_STATUS} or ${r_tmp}
    set test variable   ${POST_CELL_STATUS}


vCU vDU FHGW ID Should Be Unified For NMS Integration
    [Documentation]    vCU vDU FHGW ID Should Be Unified For NMS Integration
    ...   It will check MRBTS_ID or FHGW_ID conflit when Integrate to NOM or Netact
    ...   *Author:* rui.3.li@nokia-sbell.com
    ...   *Change History*
    ...   | date | who | what or how |
    ...   | 2022-3-3 | r3li | init create |
    ...   *Example*
    ...   | vCU vDU FHGW ID Should Be Unified For NMS Integration |
    ${gnb_numbers}    Get Gnb Numbers
    FOR   ${i}   IN RANGE   ${gnb_numbers}
         ${du_numbers}    _Check MRBTS ID is Conflict both DU and CU    ${i}
         _Check FHGW ID is Conflict in DU    ${i}   ${du_numbers}
    END


_Check FHGW ID is Conflict in DU
    [Arguments]   ${gnb_index}    ${du_numbers}
    FOR  ${i}  IN RANGE   ${du_numbers}
        _Check FHGW ID is Conflict    ${gnb_index}    ${i}
    END


_Check FHGW ID is Conflict
    [Arguments]   ${gnb_index}=0   ${vdu_index}=0
    [Documentation]   _Check FHGW ID is Conflict
    ...   *Author:* rui.3.li@nokia-sbell.com
    ...   *Change History*
    ...   | date | who | what or how |
    ...   | 2022-3-3 | r3li | init create |
    ...   *Argument Description*
    ...   | Input Arg | Main | description |
    ...   | gnb_index | NO | int,gnb index, default is 0 |
    ...   | vdu_index | NO | int,vdu index, default is 0 |
    ...   *Example*
    ...   | _Check FHGW ID is Conflict |
    log to console   Check FHGW ID is Conflict
    ${fhgw_numbers}    Get FHGW Numbers
    ${fhgw_id_list}    Create List
    ${flag}    set variable   ${1}
    FOR  ${fhgw_index}  IN RANGE   ${fhgw_numbers}
        ${fhgw_alias}=   get unique id
        Connect to FHGW With Root   gnb_index=${gnb_index}   vdu_index=${vdu_index}   fhgw_index=${fhgw_index}    alias=${fhgw_alias}
        ${out}   issh.Execute   command=cat /etc/fhgwID  check_result=${False}   alias=${fhgw_alias}
        ${fhgw_id}    Strip String   ${out}
        ${next_id}   set variable    ${fhgw_id}${flag}
        ${tips}    set variable    fhgw mrbts id confilict, suggest use fhgw${next_id} as mrbts id for FHGW ${fhgw_index}
        List Should Not Contain Value   ${fhgw_id_list}   ${fhgw_id}   ${tips}
        Append to List    ${fhgw_id_list}    ${fhgw_id}
    END


_Check MRBTS ID is Conflict both DU and CU
    [Arguments]    ${gnb_inex}=0
    [Documentation]   _Check FHGW ID is Conflict
    ...   *Author:* rui.3.li@nokia-sbell.com
    ...   *Change History*
    ...   | date | who | what or how |
    ...   | 2022-3-3 | r3li | init create |
    ...   *Argument Description*
    ...   | Input Arg | Main | description |
    ...   | gnb_index | NO | int,gnb index, default is 0 |
    ...   *Example*
    ...   | _Check MRBTS ID is Conflict both DU and CU |
    [Return]   ${du_numbers}
    log to console    Check MRBTS ID is Conflict both DU and CU
    ${cu_mrbts_id}   Get MRBTS Id From vCU SCF
    ${du_numbers}    Get DU Numbers    ${gnb_inex}
    ${mrbts_id_list}    Create List    ${cu_mrbts_id}
    ${flag}   set variable   ${1}
    FOR   ${du_number}   IN RANGE   ${du_numbers}
         ${du_mrbts_id}    Get MRBTS Id From vDU SCF   ${gnb_inex}    ${du_number}
         ${next_id}   set variable    ${cu_mrbts_id}${flag}
         ${tips}    set variable    du mrbts id confilict, suggest use MRBTS_${next_id} as mrbts id for DU ${du_number}
         List Should Not Contain Value    ${mrbts_id_list}  ${du_mrbts_id}   ${tips}
         Append to List     ${mrbts_id_list}    ${du_mrbts_id}
    END


Get DU Numbers
    [Arguments]   ${gnb_index}=0
    [Documentation]   Get DU Numbers
    ...   *Author:* rui.3.li@nokia-sbell.com
    ...   *Change History*
    ...   | date | who | what or how |
    ...   | 2022-3-3 | r3li | init create |
    ...   *Argument Description*
    ...   | Input Arg | Main | description |
    ...   | gnb_index | NO | int,gnb index, default is 0 |
    ...   *Example*
    ...   | Get DU Numbers |
    ...   *Return*
    ...   - int, du numbers
    ${all_vdu_info}    set variable   ${tl.gnbs[${gnb_index}].dus}
    ${du_numbers}    set variable    ${all_vdu_info.__len__()}
    [Return]    ${du_numbers}


Get FHGW Numbers
    [Arguments]   ${gnb_index}=0   ${vdu_index}=0
    [Documentation]   Get FHGW Numbers
    ...   *Author:* rui.3.li@nokia-sbell.com
    ...   *Change History*
    ...   | date | who | what or how |
    ...   | 2022-3-3 | r3li | init create |
    ...   *Argument Description*
    ...   | Input Arg | Main | description |
    ...   | gnb_index | NO | int, gnb index, default is 0 |
    ...   | vdu_index | NO | int, vdu index, default is 0 |
    ...   *Example*
    ...   | Get FHGW Numbers |
    ...   *Return*
    ...   - int, fhgw numbers
    ${all_fhgw_info}    set variable   ${tl.gnbs[${gnb_index}].dus[${vdu_index}].fhgws}
    ${fhgw_numbers}    set variable    ${all_fhgw_info.__len__()}
    [Return]   ${fhgw_numbers}

Get Gnb Numbers
    [Documentation]   Get Gnb Numbers
    ...   *Author:* rui.3.li@nokia-sbell.com
    ...   *Change History*
    ...   | date | who | what or how |
    ...   | 2022-3-3 | r3li | init create |
    ...   *Example*
    ...   | Get Gnb Numbers |
    ...   *Return*
    ...   - int, gnb numbers
    ${all_gnb_info}    set variable   ${tl.gnbs}
    ${gnb_numbers}    set variable    ${all_gnb_info.__len__()}
    [Return]    ${gnb_numbers}
