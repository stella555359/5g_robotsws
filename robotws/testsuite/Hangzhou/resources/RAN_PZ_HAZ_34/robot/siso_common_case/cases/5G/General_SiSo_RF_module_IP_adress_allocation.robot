*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
*** Variables ***

*** Keywords ***
General_SiSo_RF_module_IP_adress_allocation
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] The purpose of the case is to check RU module IP address allocation and to check optical ports.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 01.16.2019 - - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    Connect to Common Unit Master
    ${ru_index_list}  Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        Connect to RU With Allocated IP  ru_index=${ru_index}  ru_alias=RU_${ru_index}
        csn.Disconnect  connection=RU_${ru_index}
    END
    [Teardown]  csn.Disconnect  connection=ASIK Master
