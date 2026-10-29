*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

#Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/nrarfcn_and_gscn.robot
Library    Process
Library      XML   WITH NAME    ParseXML
Library      taf.selenium.sbts    WITH NAME    selenium_coam
Library      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/made_lib.py
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G//basic/bpf.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G//basic/bts_coam.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G//basic/pre_analysis.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G//basic/scf_operation.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/simple_keyword.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/recommissioning_and_make_throughput.robot

*** Variables ***

*** Keywords ***
Manual_SiSo_Validating_max_allowed_power_on_RU
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this case is to validate RF module Pmax related alarm/fault handling and recovery.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 04.15.2024 - - Created ticket:https://jiradc.ext.net.nokia.com/browse/LEOPARD-1902
    ...    *******************
    ...    Owner_kaihui.fan@nokia-sbell.com
    [Arguments]  ${ru_index}=1    ${variable_from_CFAM}=${Variables_CFAM}   ${connection}=GNB_OAM
    ...   ${technology_dist_name}=MRBTS-${mrbtsId}/MNL-1/MNLENT-1/BBADM-1/BBPOOL-11
    ...  ${with_call}=${False}  ${with_peak}=${False}  ${duration}=${60}    ${ue_num_each_call}=1
    Selenium Login And Disable Screen Lock
    ${orig_value_technology}    selenium_coam.get_parameter_value  dist_name=${technology_dist_name}
    ...  filter_param=Baseband pool technology
    ${cell_type}   Run Keyword If   '${orig_value_technology}'=='5G'   Set Variable   nr
    ...   ELSE IF   '${orig_value_technology}'=='LTE'   Set Variable   lte
    ...   ELSE  log to console   not support ${orig_value_technology} type
    ${cell_id_list}    Get All Cell Id    ${ru_index}    cell_type=${cell_type}

    ${faultId}   Run Keyword If   '${orig_value_technology}'=='5G'   Set Variable   1900
    ...   ELSE IF   '${orig_value_technology}'=='LTE'   Set Variable   4008
    ...   ELSE  log to console   not support ${orig_value_technology} type
    ${pmax_distname_prefix}   Run Keyword If   '${orig_value_technology}'=='5G'   Set Variable   MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL
    ...   ELSE IF   '${orig_value_technology}'=='LTE'   Set Variable   MRBTS-${mrbtsId}/LNBTS-${nrbtsId}/LNCEL
    ...   ELSE  log to console   not support ${orig_value_technology} type
    log to console    \nmodify pmax exceed to max pmax,trigger fault 1900/4008
    Run Keyword If   '${orig_value_technology}'=='LTE'  Set Test Variable   ${SAVE LOG DIRECTORY}   ${CASE_LOG_PATH}
    ${exceed_pmax_modify_params}  create list
    FOR   ${cell_id}  IN  @{cell_id_list}
        ${origin_params}  ${origin_pmax_value}  ${new_modify_params}  Modify pMax And Generate Parameter    cell_id=${cell_id}
        ...   ru_index=${ru_index}  variable_from_CFAM=${variable_from_CFAM}
        ...   dist_name=${pmax_distname_prefix}-${cell_id}
        ${exceed_pmax_modify_params}    Combine Lists    ${exceed_pmax_modify_params}    ${new_modify_params}
    END
    Modify Parameters On Webem  ${exceed_pmax_modify_params}    despite_errors=${True}
    Wait Until Keyword Succeeds    10min    30s    Expect Fault Should Present    faultId=${faultId}    connection=${connection}
    log to console    \nmodify pmax origin value,clear fault 1900/4008
    ${modify_params}  create list
    FOR   ${cell_id}  IN  @{cell_id_list}
        ${item}  create dictionary  dist_name=${pmax_distname_prefix}-${cell_id}  filter_param=Maximum output power
        ...  p_name=pMax  value=${origin_pmax_value}
        append to list  ${modify_params}  ${item}
    END
    Modify Parameters On Webem  ${modify_params}    despite_errors=${False}
    Wait For Expect Fault To Disappear  faultId=${faultId}    timeout=600   connection=${connection}
    Run Keyword If   '${orig_value_technology}'=='5G'    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type='${gNb_CuType}'
    ...   ELSE IF   '${orig_value_technology}'=='LTE'
    ...   Wait Until Keyword Succeeds    10min    30s     Verify all cells should be onair    cell_type=${cell_type}
    ...   ELSE  log to console    \nnot support technology
    Run Keyword If    ${with_call}    Get UE From Init File and Make call    cell_list=${cell_id_list}
    ...    with_peak=${with_peak}    duration=${duration}    ue_num_each_call=${ue_num_each_call}
    [Teardown]  run keywords    Close Start Up View    timeout=60    AND
    ...    Selenium Logout And Close Browser   AND
    ...    run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}   AND
    ...    run keyword and ignore error    csn.Disconnect    connection=ASIK Master

Modify pMax And Generate Parameter
    [Arguments]  ${cell_id}=1    ${ru_index}=1    ${variable_from_CFAM}=${Variables_CFAM}
    ...   ${dist_name}=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-${cell_id}
    log to console    \n***Modify pMax to tirgger fault***
    ${modify_params}  create list
    Connect to gnb coam via ssl
    ${bpf_content}   verify content of BPF file    variable_from_CFAM=${variable_from_CFAM}    ru_index=${ru_index}
    ${xml handler}=    ParseXML.Parse Xml    ${bpf_content}
    ${MaxPapower_list}    ParseXML.Get Elements Texts    ${xml handler}
    ...    xpath=.//list[@Name="Tx.Carrier.Max.Pa.Power"]/p
    Collections.Sort List    ${MaxPapower_list}
    set test variable    ${MaxPower}    ${MaxPapower_list}[-1]
    ${MaxPapower_list_5G}    ParseXML.Get Elements Texts    ${xml handler}
    ...    xpath=.//list[@Name="Tx.Carrier.Max.Pa.Power.5G"]/p
    Collections.Sort List    ${MaxPapower_list_5G}
    ${Len}=    Get Length    ${MaxPapower_list_5G}
    ${MaxPower}    Set Variable If    '${len}'!='0'    ${MaxPapower_list_5G}[-1]    ${MaxPower}
    ${MaxPower} =    Evaluate    ${MaxPower} + 0.1
    set test variable    ${MinPower}    ${MaxPapower_list}[0]
    ${pMax_modify_f} =    Evaluate    ${MaxPower} + 0.1
    ${pMax_modify}    convert to string    ${pMax_modify_f}
    ${modify_params}  create list
    ${item}  create dictionary  dist_name=${dist_name}  filter_param=Maximum output power
    ...  p_name=pMax  value=${pMax_modify}
    append to list  ${modify_params}  ${item}
    ${orig_value}    Get Pmax Value For 5G And LTE  dist_name=${dist_name}
    ${origin_params}  create list
    ${new_item}  create dictionary  dist_name=${item}[dist_name]
    ...    filter_param=${item}[filter_param]  p_name=${item}[p_name]  value=${orig_value}
    append to list  ${origin_params}  ${new_item}
    [Return]  ${origin_params}  ${orig_value}  ${modify_params}

Get Pmax Value For 5G And LTE
    [Arguments]    ${dist_name}=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-${cell_id}
    ${orig_value_temp}    selenium_coam.get_parameter_value  dist_name=${dist_name}
    ...  filter_param=Maximum output power
    ${pattern}   Set Variable    (\\d*\.?\\d).*
    ${orig_value_list}    Get Regexp Matches     ${orig_value_temp}    ${pattern}    1
    ${orig_value}    set variable     ${orig_value_list}[0]
    [Return]  ${orig_value}
