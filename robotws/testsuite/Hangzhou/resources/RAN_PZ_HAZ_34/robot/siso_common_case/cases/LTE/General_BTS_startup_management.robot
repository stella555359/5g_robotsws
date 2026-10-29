*** Settings ***
Documentation    This is common keywords for LTE siso related cases
...              Please do not modify the file without notification to author

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/LTE/basic/ru_operation.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/scf_comm_operation.robot

*** Variables ***
${SCF_PATH}    commissionings/HGZ/${testline_name}/SCF_SBTS00.xml

*** Keywords ***
General_BTS_startup_management
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test is to verify BTS startup management
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 2020.6.1 - - Created
    ...    *******************
    ...    Owner_jiayi.tang@nokia-sbell.com
    ${ru_index_list}  Get All RU Index
    FOR	${i}	IN RANGE	3
      Perform RAC and RAU Power Off LTE  ${ru_index_list}
      Perform RAC Power On LTE  ${ru_index_list}
      Power On RU_and_check RF Delayed Startup LTE  ${ru_index_list}
      Commissioning SCF And Check On Air for Common      scf_path=${SCF_PATH}
    END
