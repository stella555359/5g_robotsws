*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/soap.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ru_soap_log.robot
*** Variables ***

*** Keywords ***
General_SiSo_U-plane_Fast-C-Plane_message_reception_NetActNIDD_PM_measurement_5G_eCPRI_RU_reporting_update
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] Purpose of this case is to verify RAU/RU eCPRI U-plane & Fast-C-Plane message reception NetAct/NIDD PM counters
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 01.28.2021 - - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    [Arguments]  ${miNrEcpriUpFCp}=5min
    Modify miNrEcpriUpFCp Parameters via API  miNrEcpriUpFCp=${miNrEcpriUpFCp}
    Connect to Common Unit Master
    ${ru_index_list}  Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        Connect to RU With Allocated IP    ru_index=${ru_index}  ru_alias=RU_${ru_index}
        Enable capture soap msg flag on RU    ru_alias=RU_${ru_index}
        sleep  20s
        ${PC_soap_path}    Download soap msg from RU    ru_alias=RU_${ru_index}    log_path=${SAVE LOG DIRECTORY}
        csn.Disconnect    connection=RU_${ru_index}
        Check ECpriReceptionMonitor SOAP message    PC_soap_path=${PC_soap_path}    change_interval=${miNrEcpriUpFCp}
    END
    [Teardown]      run keywords    csn.Disconnect  connection=ASIK Master    AND
    ...    Modify miNrEcpriUpFCp Parameters via API  miNrEcpriUpFCp=disabled
