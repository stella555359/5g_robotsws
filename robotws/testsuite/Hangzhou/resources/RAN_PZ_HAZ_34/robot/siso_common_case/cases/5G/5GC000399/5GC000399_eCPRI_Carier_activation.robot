*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/soap.robot
*** Variables ***

*** Keywords ***
5GC000399_eCPRI_Carier_activation
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] The purpose of this test is to verify carrier configuration and activation using eLLF RU over RP1
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 30.9.2020 - - Created
    ...    *******************
    ...    Owner_lanwen.cai@nokia-sbell.com
    Connect to Common Unit Master
    ${ru_index_list}  Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        Connect to RU With Allocated IP    ru_index=${ru_index}  ru_alias=RU_${ru_index}
        ${ru_type}    get ru type    ru_index=${ru_index}
        ${PC_soap_path}    Download soap Log0 from RU    log_path=${SAVE LOG DIRECTORY}    ru_alias=RU_${ru_index}
        csn.Disconnect    connection=RU_${ru_index}
        check carier activation by soapmsg parvaluechangeind    PC_soap_path=${PC_soap_path}
    END
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
    [Teardown]  csn.Disconnect  connection=ASIK Master
