*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == AUTHORS C-PLANE ==
...       - Paulina Jedras <paulina.jedras@nokia.com>
...       - Maciej Madej <maciej.madej@nokia.com>
...      == MAINTAINER ==
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>

Resource    CB008745-common_keywords.robot
Library     taf.sw.scout    WITH NAME    scout
Library     BuiltIn
Library     Collections
Library     DateTime
Library     FtpLibrary
Library     OperatingSystem
Library     Process
Library     String


*** Variables ***
${lbpsLastCellSOEnabled_def}    False
${lbpsLoadCalcMethod_def}       'Max(G_N_combined, P)'
${lbpsMaxLoad_def}              10
${lbpsMinLoad_def}              5
${lbpsPdcchLoadOffset_def}      100
${lbpsMonWinForCellSOff_def}    60
${lbpsMonWinForCellSOn_def}     60
${lbpsSOffTrRule_def}           MaxValueMethod
${lbpsSOnTrRule_def}            MinValueMethod
@{lbpsCellSOOrder_def}          1  2

${1_NRPGRP_2_cells} =       ${CURDIR}/../config/yaml_config/1_NRPGRP_2_cells.yaml
${2_NRPGRP_2_cells} =       ${CURDIR}/../config/yaml_config/2_NRPGRP_2_cells.yaml

*** Keywords ***
Set NRPGRP-${id} parameters
    Log To Console   ${id}
    Set default or defined in TC precondition value for attribute NRPGRP-1.lbpsLastCellSOEnabled
    Set default or defined in TC precondition value for attribute NRPGRP-1.lbpsLoadCalcMethod
    Set default or defined in TC precondition value for attribute NRPGRP-1.lbpsMaxLoad
    Set default or defined in TC precondition value for attribute NRPGRP-1.lbpsMinLoad
    Set default or defined in TC precondition value for attribute NRPGRP-1.lbpsPdcchLoadOffset
    Set default or defined in TC precondition value for attribute NRPGRP-1.lbpsMonWinForCellSOff
    Set default or defined in TC precondition value for attribute NRPGRP-1.lbpsMonWinForCellSOn
    Set default or defined in TC precondition value for attribute NRPGRP-1.lbpsSOffTrRule
    Set default or defined in TC precondition value for attribute NRPGRP-1.lbpsSOnTrRule
    Set default or defined in TC precondition value for attributes NRPGRP-1.lbpsCellList.lbpsCellSOOrder

Set default or defined in TC precondition value for attribute ${MO}.${attribute}
    ${value}    get variable value      ${${MO}.${attribute}}  ${${attribute}_def}
    set enb parameter value
    ...  param_path=${MO}.${attribute}
    ...  value=${value}
    ...  bts_id=1

Set default or defined in TC precondition value for attributes ${MO}.${list}.${attribute}
    @{values}    get variable value      @{${MO}.${attribute}}  @{${attribute}_def}
    ${length}  get length  ${values}
    FOR  ${i}  IN RANGE  0  ${length}
      ${path}=  catenate  SEPARATOR=  ${MO}.${list}.${attribute}  [${i}]

      set enb parameter value
      ...  param_path=${path}
      ...  value=${values}[${i}]
      ...  bts_id=1
    END

Prepare test environment B_2
    Set NRPGRP-1 parameters
    Configure  ${1_NRPGRP_2_cells}  node_id=1

Prepare test environment B_3
    Set test variable    ${NRPGRP-1.lbpsLoadCalcMethod}     'Max(G, C, P)'
    Set test variable    ${NRPGRP-1.lbpsSOffTrRule}         SlidingAverageMethod
    Set test variable    ${NRPGRP-1.lbpsSOnTrRule}          SlidingAverageMethod
    Set NRPGRP-1 parameters
    Configure  ${1_NRPGRP_2_cells}  node_id=1

Prepare test environment B_4
    Set test variable    ${NRPGRP-1.lbpsMaxLoad}             40
    Set test variable    ${NRPGRP-1.lbpsMinLoad}             20
    Set test variable    ${NRPGRP-1.lbpsMonWinForCellSOff}   200
    Set test variable    ${NRPGRP-1.lbpsMonWinForCellSOn}    200
    Set test variable    ${NRPGRP-1.lbpsSOffTrRule}          SlidingAverageMethod
    Set test variable    ${NRPGRP-1.lbpsSOnTrRule}           SlidingAverageMethod
    Set NRPGRP-1 parameters
    Configure  ${1_NRPGRP_2_cells}  node_id=1

Prepare test environment B_5
    Set test variable    ${NRPGRP-1.lbpsMaxLoad}            20
    Set test variable    ${NRPGRP-1.lbpsMinLoad}            10
    Set test variable    ${NRPGRP-1.lbpsMonWinForCellSOff}  120
    Set test variable    ${NRPGRP-1.lbpsMonWinForCellSOn}   100
    Set NRPGRP-1 parameters
    Configure  ${1_NRPGRP_2_cells}  node_id=1

Prepare test environment B_6
    Set test variable    ${NRPGRP-1.lbpsLoadCalcMethod}     'Max(G, C, P)'
    Set test variable    ${NRPGRP-1.lbpsMaxLoad}            25
    Set test variable    ${NRPGRP-1.lbpsMinLoad}            20
    Set NRPGRP-1 parameters
    Configure  ${1_NRPGRP_2_cells}  node_id=1

Prepare test environment B_7
    Set test variable    ${NRPGRP-1.lbpsMaxLoad}             10
    Set test variable    ${NRPGRP-1.lbpsMinLoad}             5
    Set test variable    ${NRPGRP-1.lbpsMonWinForCellSOff}   60
    Set test variable    ${NRPGRP-1.lbpsMonWinForCellSOn}    160
    Set test variable    ${NRPGRP-1.lbpsLoadCalcMethod}      'Max(G, C, P)'
    Set NRPGRP-1 parameters
    Configure  ${1_NRPGRP_2_cells}  node_id=1

Prepare test environment B_8
    Set test variable    ${NRPGRP-1.lbpsMaxLoad}             10
    Set test variable    ${NRPGRP-1.lbpsMinLoad}             5
    Set test variable    ${NRPGRP-1.lbpsPdcchLoadOffset}     0
    Set test variable    ${NRPGRP-1.lbpsMonWinForCellSOff}   60
    Set test variable    ${NRPGRP-1.lbpsMonWinForCellSOn}    140
    Set test variable    ${NRPGRP-1.lbpsLoadCalcMethod}      'Max(G, C, P)'
    Set NRPGRP-1 parameters
    Configure  ${1_NRPGRP_2_cells}  node_id=1

Prepare test environment B_9
    Configure  ${2_NRPGRP_2_cells}  node_id=1

Cleanup after test B_4
    Run keyword if test failed    Unlock nrCellId=1
    Basic cleanup

Basic cleanup
    stop collecting syslog
    Detach and kill UEs from 1 to 20
    Remove NRPGRPs and deactivate Power Saving feature
    Get Hostname
    Link SCOUT SCF to Configuration ID for Reporting

Get Hostname
    ${rc}  ${hostname_tmp}=  Run And Return Rc And Output  hostname
    ${hostname_tmp}=  Replace String  ${hostname_tmp}  -  _
    ${hostname_tmp}=  Convert To String  ${hostname_tmp}
    ${hostname_part}=  Split String  ${hostname_tmp}  _
    ${hostname_combined}=  Catenate  ${hostname_part[0]}_${hostname_part[1]}_${hostname_part[2]}
    Set Test Variable  ${HOSTNAME}  ${hostname_combined}

Request Scout SCF
    [Arguments]   ${scout_testline_name}
    [Documentation]    :Author: Michele
    ...    Request Scout SCF used inside Link SCOUT SCF to Configuration ID for Reporting KW.
    scout.setup_scout  scout_testline_name=${scout_testline_name}
    ${external_scf_id}=   scout.request_scf   use_scout_internal_id=True
    scout.teardown_scout_api
    [Return]   ${external_scf_id}


Link SCOUT SCF to Configuration ID for Reporting
    [Documentation]
    ...    Associate the SCF to the Configuration ID in Reporting Portal using SCOUT.
    ...
    ...    Example:
    ...     |  Link SCOUT SCF to Configuration ID for Reporting    node_id=${0}    node_type=enb
    ...
    ...     |param node_id | (default=0) Id/Number of Node (eNB or gNB) |
    ...     |param node_type | (default=gnb) Node type; possible values: gnb or enb |

    [Arguments]    ${node_id}=${0}    ${node_type}=enb    ${tl_name_only}=${HOSTNAME}
    Log To Console    ${node_id}
    ${node_type_Name}        Run Keyword If  "${node_type}"=="gnb"   Set Variable  gNB
    ...     ELSE IF     "${node_type}"=="enb"                   Set Variable  eNB
    ...     ELSE        Fail    Wrong node_type '${node_type}'! allowed: enb|gnb


    Log To Console    ${\n}SCOUT Test Line Name: ${tl_name_only}

    ${scout_testline_name}=    Set Variable    ${tl_name_only}
    ${external_scf_id}=   Request Scout SCF   ${scout_testline_name}
    ${TC_ID}=    Set Variable    ute:id:${external_scf_id}
    Set Tags  ${TC_ID}


