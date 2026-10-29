*** Settings ***
Documentation     author: shasha liu
...               Group: HGZ_SG5
...               contact: shasha.liu@nokia-sbell.com

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot

*** Variables ***

*** Keywords ***
General_Feature_Micro-DTX_deactivate_microDtxEnabled_false
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test is to verify Micro-DTX deactivation
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 28.12.2020 - - Created
    ...    *******************
    ...    Owner_shasha.liu@nokia-sbell.com
    log to console   \n*** set precondition: Micro-DTX activate ***
    Modify RMOD Power Parameter    power_status=true
    sleep  20
    Wait until keyword succeeds    10min    30s    Expect Fault Should Absent    faultId=4308
    log to console   \n*** Micro-DTX deactivate ***
    Modify RMOD Power Parameter    power_status=false
    sleep  20
    Wait until keyword succeeds    10min    30s    Expect Fault Should Absent    faultId=4308
    Connect to gnb coam via ssl
    ${ru_index_list}  Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        Connect to Common Unit Master
        Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}
        ${soap_path}    Download soap Log from RU    ru_alias=RU_${ru_index}
        Check SOAP message Micro-DTX status    soapLog_path=${soap_path}    microDtxEnabled=${FALSE}
        ${soap_file_path}    Run Keyword And Ignore Error    OperatingSystem.Copy File    ${soap_path}    ${SAVE LOG DIRECTORY}
        csn.Disconnect    connection=ASIK Master
    END

General_Feature_Micro-DTX_activate_microDtxEnabled_true
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test is to verify Micro-DTX activation
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 28.12.2020 - - Created
    ...    *******************
    ...    Owner_shasha.liu@nokia-sbell.com
    log to console   \n*** set precondition: Micro-DTX deactivate ***
    Modify RMOD Power Parameter    power_status=false
    sleep  20
    Wait until keyword succeeds    10min    30s    Expect Fault Should Absent    faultId=4308
    log to console   \n*** Micro-DTX activate ***
    Modify RMOD Power Parameter    power_status=true
    sleep  20
    Wait until keyword succeeds    10min    30s    Expect Fault Should Absent    faultId=4308
    Connect to gnb coam via ssl
    ${ru_index_list}  Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        Connect to Common Unit Master    alias=ASIK Master
        Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}
        ${soap_path}    Download soap Log from RU    ru_alias=RU_${ru_index}
        Check SOAP message Micro-DTX status    soapLog_path=${soap_path}    microDtxEnabled=${TRUE}
        ${soap_file_path}    Run Keyword And Ignore Error    OperatingSystem.Copy File    ${soap_path}    ${SAVE LOG DIRECTORY}
        csn.Disconnect    connection=ASIK Master
    END

Check SOAP message Micro-DTX status
    [Arguments]   ${soapLog_path}    ${microDtxEnabled}=${TRUE}
    log to console  \n*** Check Micro-DTX statusk in SOAP message ***
    soapp.check_soapmsg_parvaluechangeind    log_path=${soapLog_path}    class_value=TxArray
    ...     parameterName=microDtxEnabled    newValue=${microDtxEnabled}

