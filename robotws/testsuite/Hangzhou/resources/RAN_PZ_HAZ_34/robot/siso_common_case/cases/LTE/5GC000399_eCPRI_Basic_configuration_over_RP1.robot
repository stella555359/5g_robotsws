*** Settings ***
Documentation     author: Bijiajian
...               contact: Jiajian.bi@nokia-sbell.com
...               squad group: SG_02
Suite Setup       Suite Setup
Suite Teardown    Suite Teardown
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/LTE/basic/5GC000399_Keyword.robot

*** Variables ***

*** Keywords ***
5GC000399_eCPRI_Basic_configuration_over_RP1
    [Setup]    Test Setup
    ${ru_index_list}    Get All RU Index
	Connect to BBU
    FOR    ${ru_index}    IN    @{ru_index_list}
        Connect to RU With Allocated IP LTE    ru_index=${ru_index}    ru_alias=RU_${ru_index}
        ${ru_type}    get ru type    ru_index=${ru_index}
        ${PC_soap_path}    Download soap Log0 from RU    log_path=${CASE_LOG_PATH}    ru_alias=RU_${ru_index}
        csn.Disconnect    connection=RU_${ru_index}
        check basic configuration by soapmsg parvaluechangeind    PC_soap_path=${PC_soap_path}
    END
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
    [Teardown]    Test Teardown
