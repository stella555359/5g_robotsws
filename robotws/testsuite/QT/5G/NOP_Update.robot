*** Settings ***
Force Tags    PY39    RF50
Documentation     This suite is used to update the NOPs in the system
Suite Setup       NOP Update Suite Setup
Suite Teardown    NOP Update Suite Teardown
Library           taf.ul.vdu.helm    WITH NAME    helm
Library           taf.transport.ssh.interface.ssh    WITH NAME    ssh
Library           OperatingSystem
Library           Collections
Library           String
Library           json
Library           ${CURDIR}/../SRAN/resources/python/QTListener.py
Library           ${CURDIR}/../SRAN/resources/python/TestCaseRequirement.py
Resource          ${CURDIR}/../SRAN/resources/robot/AIC_common_keywords.robot
Resource          ${CURDIR}/../SRAN/resources/robot/common.robot
Resource          ${CURDIR}/../SRAN/resources/robot/common_variables.robot

Test Timeout      2 hour

*** Test Cases ***
RAN NIC SW update
    [Tags]   rannic_update
    Download NOP
    ...    nop_file=${rannic_sw_controller_file}    nop_name=ran-nic-sw-controller
    Install NOP    nop_name=ran-nic-sw-controller

Nokia Sync Operator update
    [Tags]  sync_operator
    Download NOP
    ...    nop_file=${sync_operator_file}    nop_name=nokia-sync-operator
    Install NOP    nop_name=nokia-sync-operator

Koredump Operator Update
    [Tags]    koredump_operator
    Download NOP
    ...    nop_file=${koredump_operator_file}    nop_name=koredump-operator
    Install NOP    nop_name=koredump-operator

CNF LCM Operator Update
    [Tags]    cnf_lcm_operator
    Download NOP
    ...    nop_file=${cnf_lcm_operator_file}    nop_name=cnf-lcm-operator
    Install NOP    nop_name=cnf-lcm-operator