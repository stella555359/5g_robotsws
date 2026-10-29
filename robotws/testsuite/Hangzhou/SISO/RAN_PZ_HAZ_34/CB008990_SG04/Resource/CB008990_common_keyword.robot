*** Settings ***
Documentation    These are common keywords for CB008990 related cases
...              Please do not modify the file without notification to author
...              Contact: kaihui.fan@nokia-sbell.com
...              Squard: HZ SG4

Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/nr_feature_on.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/recommissioning_and_make_throughput.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_operation.robot
Library     random

*** Variables ***

*** Keywords ***
General_SiSo_Ecpri_RU_DFE-Beamer_link_fault_activation
    [Arguments]    ${connection}=GNB_OAM    ${ru_index}=${1}   ${with_call}=${False}  ${with_peak}=${False}  ${duration}=${30}
    ${made1_dict}=    Create Dictionary   ip=192.168.101.2   alias=made1
    ${made2_dict}=    Create Dictionary   ip=192.168.101.3   alias=made2
    ${made3_dict}=    Create Dictionary   ip=192.168.101.4   alias=made3
    ${made4_dict}=    Create Dictionary   ip=192.168.101.5   alias=made4
    ${made_list}=       Create List   ${made1_dict}   ${made2_dict}    ${made3_dict}   ${made4_dict}
    ${made_1103_index}  Set Variable  ${0}
    FOR   ${made_dict}   IN   @{made_list}
        Log   Dictionary:${made_dict}
        ${made_1103_index}=   Evaluate              ${made_1103_index}+1
        ${made_ip}=          get from dictionary    ${made_dict}   ip
        ${made_alias}=       get from dictionary    ${made_dict}   alias
        Trigger Fault 1103 And Cancel Within 30s On Single Made    ru_index=${ru_index}   ip=${made_ip}
        ...             alias=${made_alias}   proxy=RU_${ru_index}   count_fault1103=${made_1103_index}
    END
    ${made_1904_index}  Set Variable  ${0}
    ${made_fault1904_list}=    Evaluate  random.sample(${made_list}, 3)    random
    FOR  ${made_dict}   IN   @{made_fault1904_list}
        Log   Dictionary:${made_dict}
        ${made_1904_index}=   Evaluate   ${made_1904_index}+1
        ${made_ip}=    get from dictionary    ${made_dict}   ip
        ${made_alias}=    get from dictionary    ${made_dict}   alias
#        ${alarmId}   Set Variable  1981
        Trigger Fault 1904/1981 And Check On WEBEM  ru_index=${ru_index}   ip=${made_ip}   alias=${made_alias}
        ...       proxy=RU_${ru_index}   count_history_fault=${made_1904_index}    connection=${connection}
    END
    ${cell_list}    Get All Cell Id    ${ru_index}    connection=${connection}
    run keyword if  ${with_call}  Get UE From Init File and Make call  cell_list=${cell_list}
    ...    with_peak=${with_peak}  duration=${duration}    connection=${connection}
    [Teardown]  run keywords    run keyword and ignore error   csn.disconnect    connection=RU_${ru_index}
    ...                    AND    run keyword and ignore error    csn.Disconnect  connection=ASIK Master

General_SiSo_Ecpri_RU_DFE_no_TX_Data_fault_activation
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test is to verify triger fault 1981
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 01.02.2024 - - Created
    ...    - 25.03.2024 - - update by Fan Kaihui  ticket :https://jiradc.ext.net.nokia.com/browse/LEOPARD-1900
    ...    *******************
    ...    Owner_kaihui.fan@nokia-sbell.com
    [Arguments]    ${connection}=GNB_OAM    ${ru_index}=${1}   ${with_call}=${False}  ${with_peak}=${False}  ${duration}=${30}
    Commissioning SCF And Check On Air      scf_path=${SCF_Path}
    Selenium Login And Disable Screen Lock
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1
    ...    filter_param=Recovery reset delay  abbr=recoveryResetDelay    new_value=10
    ${carrier_name_list}   Get RU Carrier Name
    ${made1_dict}=    Create Dictionary   ip=192.168.101.2   alias=made1  carrier_name=${carrier_name_list[1]}  path_name=antenna1a
    ${made2_dict}=    Create Dictionary   ip=192.168.101.3   alias=made2  carrier_name=${carrier_name_list[1]}  path_name=antenna9a
    ${made3_dict}=    Create Dictionary   ip=192.168.101.4   alias=made3  carrier_name=${carrier_name_list[0]}  path_name=antenna17a
    ${made4_dict}=    Create Dictionary   ip=192.168.101.5   alias=made4  carrier_name=${carrier_name_list[0]}  path_name=antenna25a
    ${made_list}=    Create List   ${made1_dict}   ${made2_dict}    ${made3_dict}   ${made4_dict}
    ${made_1981_index}  Set Variable  ${0}
    ${made_fault1981_list}=    Evaluate  random.sample(${made_list}, 3)   random
    FOR  ${made_dict}   IN   @{made_fault1981_list}
        Log   Dictionary:${made_dict}
        ${made_1981_index}=   Evaluate      ${made_1981_index}+1
        ${made_ip}=            get from dictionary    ${made_dict}   ip
        ${made_alias}=         get from dictionary    ${made_dict}   alias
        ${made_carrier_name}=  get from dictionary    ${made_dict}   carrier_name
        ${made_path_name}=    get from dictionary     ${made_dict}   path_name
        Trigger Fault 1981 And Check On WEBEM    ru_index=${ru_index}   ip=${made_ip}   alias=${made_alias}
        ...         proxy=RU_${ru_index}  carrier_name=${made_carrier_name}   path_name=${made_path_name}
        ...         count_history_fault=${made_1981_index}  connection=${connection}
    END
    ${cell_list}    Get All Cell Id    ${ru_index}    connection=${connection}
    run keyword if  ${with_call}  Get UE From Init File and Make call  cell_list=${cell_list}
    ...    with_peak=${with_peak}  duration=${duration}    connection=${connection}
    [Teardown]    run keywords    run keyword and ignore error   csn.disconnect    connection=RU_${ru_index}
    ...    AND      Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1
    ...    filter_param=Recovery reset delay  abbr=recoveryResetDelay    new_value=0
    ...    AND   run keyword and ignore error   csn.Disconnect  connection=ASIK Master
    ...   AND   Selenium Logout And Close Browser


Get RU Carrier Name
    [Arguments]    ${ru_index}=1    ${asik_alias}=ASIK Master
    log to console    Get carrier name from RU
    Connect to Common Unit Master    alias=${asik_alias}
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}    asik_alias=${asik_alias}
    ${output}    csn.execute    command=sudo bfcali -stat    connection=RU_${ru_index}
    ${output_str}=   Remove String  ${output}  ${SPACE}  ${EMPTY}
    ${output_list}   Split String   ${output_str}  \r\n\r\n
    Log Many   ${output_list}
    Remove From List   ${output_list}   0
    Remove From List   ${output_list}   -1
    ${output_list0}   Split String   ${output_list[0]}  \r\n
    ${output_list1}   Split String   ${output_list[1]}  \r\n
    ${content_list}   Combine Lists   ${output_list0}  ${output_list1}
    Log Many  ${content_list}
    ${carrier_name_list}   Create List
    FOR  ${sub_output}   IN  @{content_list}
        ${stripped_line}=   Remove String  ${sub_output}    ${SPACE}  ${EMPTY}
        ${list_line}   Split String   ${stripped_line}   :
        ${len_str_line}   Get Length   ${list_line}
        Run Keyword If   '${len_str_line}'=='1'   Append To List    ${carrier_name_list}  ${list_line[0]}
        ...   ELSE IF   '${list_line[0]}'=='Carriername'   Append To List    ${carrier_name_list}  ${list_line[1]}
        ...   ELSE   log   no append to carrier list
    END
    Reverse List   ${carrier_name_list}
    Log Many   ${carrier_name_list}
    csn.disconnect    connection=RU_${ru_index}
    [Return]    ${carrier_name_list}
    [Teardown]    csn.disconnect    connection=ASIK Master
