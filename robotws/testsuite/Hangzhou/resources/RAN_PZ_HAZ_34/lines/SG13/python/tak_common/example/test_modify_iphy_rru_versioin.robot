*** Settings ***
Resource     ../../../robot/common_resource.robot
Library      ute_fsmaccess
*** Variables ***
${fsm_control_pc_ip}=
${fsm_trs_ip}=
${fsm_hw_type}=

*** Test Cases ***
test clean up env
    Setup Wts Fsm Access     prompt= >     fallback_prompt=#
    Get Wts Config File    ${CURDIR}${/}iphy_local.xml
    change_iphy_rru_version    ${CURDIR}${/}iphy_local.xml    
    change_iphy_rru_version    ${CURDIR}${/}iphy_local.xml    remote_host=127.0.0.1    wts_ip=192.168.200.1
    ${ret}    Execute Command On Wts    ls /ffs/run/simmode -l
    log   ${ret}
    Teardown Wts Fsm Access
