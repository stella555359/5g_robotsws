*** Settings ***
Documentation
...    Description: Keywords for CB007404
...    Author: krzysztof.domino@nokia.com


Library  Collections
Library    testsuite.Krakow.OAM.regression.RAN_PZ_KRK3.CB007404.resources.CB007404.RunTime  WITH NAME  runtime
Resource    taf/rfrl/bts/robot/common/gnb_scf.robot
Resource    taf/rfrl/bts/robot/common/gnb_cell.robot


*** Variables ***
${NRBTS_ID}    ${tl.gnbs[0].instance_id}
${MRBTS_ID}    ${tl.gnbs[0].global_bts_id}

*** Keywords ***
Check if cell is disabled
    [Arguments]  ${result}
    ${cell_info}=  admin.get_parameters  dist_name=${result}/NRBTS_R-${NRBTS_ID}/NRCELL_R-1  pattern=operationalState
    ${state}=  GET from dictionary  ${cell_info}  operationalState
    should be equal  ${state}  disabled

Check if cell is enabled
    [Arguments]  ${result}
    ${cell_info}=  admin.get_parameters  dist_name=${result}/NRBTS_R-${NRBTS_ID}/NRCELL_R-1  pattern=operationalState
    ${state}=  GET from dictionary  ${cell_info}  operationalState
    should be equal  ${state}  enabled

Preconditions_7404
     admin.connect_to    bts_host=${gNB_IP_MPLANE_LOCAL}     bts_port=${gNB_MPLANE_IF_PORT}
     Setup Logs Collectors
     ${gNB_branch}  Get gnb sw branch
     ${scf_path}  Set variable    ${CURDIR}/config-${MRBTSID}_${gNB_branch}.xml
     admin.perform_commissioning  ${scf_path}
     wait until keyword succeeds     20 min  4 min  Download and update same SW version
     wait until keyword succeeds     15 min  1 min  Verify gNB Cell is onAir
     ${result}=  runtime.get_runtime_info
     Set Suite Variable  ${result}

Get gnb sw branch
     ${gnb_sw_version}=    Get gNB SW version
     @{gNB_branch}=        Split String From Right    ${gnb_sw_version}    _    4
     [Return]    @{gNB_branch}[0]
