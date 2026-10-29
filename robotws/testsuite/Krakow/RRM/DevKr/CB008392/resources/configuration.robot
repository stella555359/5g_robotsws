*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == AUTHORS C-PLANE ==
...       - Tomasz Pyrek <tomasz.pyrek@nokia.com>
...       - Paulina Jedras <paulina.jedras@nokia.com>
...       - Maciej Madej <maciej.madej@nokia.com>
...      == MAINTAINER ==
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>

Resource    ../../../resources/Robot/common_settings.robot

Library     ./nrpgrp_configuration.py

*** Variables ***
${lbpsSOMethod_def}            'Tx switch off'
${lbpsLastCellSOEnabled_def}    True
${lbpsRTXMaxLoad_def}           60
${lbpsRTXMinLoad_def}           20
${lbpsRTXSOffTime_def}          30
${lbpsRTXSOnTime_def}           30
${lbpsRTXCellCapOffset_def}     80
${lbpsLastCellRTXMinLoad_def}   0
@{lbpsCellSOOrder_def}          1  2  3  4
@{nrCellId_def}                 1  2  3  4
${offset_def}                   0
${lbpsDuration_def}             1400
${lbpsSuspended_def}            'notSuspended'

*** Keywords ***
Set NRPGRP-${id} parameters

    ${lbpsSOMethod}    get variable value      ${NRPGRP-${id}.lbpsSOMethod}  ${lbpsSOMethod_def}
    set enb parameter value
    ...  param_path=NRPGRP-${id}.lbpsSOMethod
    ...  value=${lbpsSOMethod}
    ...  bts_id=1

    ${lbpsLastCellSOEnabled}    get variable value      ${NRPGRP-${id}.lbpsLastCellSOEnabled}  ${lbpsLastCellSOEnabled_def}
    set enb parameter value
    ...  param_path=NRPGRP-${id}.lbpsLastCellSOEnabled
    ...  value=${lbpsLastCellSOEnabled}
    ...  bts_id=1

    ${lbpsRTXMaxLoad}    get variable value      ${NRPGRP-${id}.lbpsRTXMaxLoad}  ${lbpsRTXMaxLoad_def}
    set enb parameter value
    ...  param_path=NRPGRP-${id}.lbpsRTXMaxLoad
    ...  value=${lbpsRTXMaxLoad}
    ...  bts_id=1

    ${lbpsRTXMinLoad}    get variable value      ${NRPGRP-${id}.lbpsRTXMinLoad}  ${lbpsRTXMinLoad_def}
    set enb parameter value
    ...  param_path=NRPGRP-${id}.lbpsRTXMinLoad
    ...  value=${lbpsRTXMinLoad}
    ...  bts_id=1

    ${lbpsRTXSOffTime}    get variable value      ${NRPGRP-${id}.lbpsRTXSOffTime}  ${lbpsRTXSOffTime_def}
    set enb parameter value
    ...  param_path=NRPGRP-${id}.lbpsRTXSOffTime
    ...  value=${lbpsRTXSOffTime}
    ...  bts_id=1

    ${lbpsRTXSOnTime}    get variable value      ${NRPGRP-${id}.lbpsRTXSOnTime}  ${lbpsRTXSOnTime_def}
    set enb parameter value
    ...  param_path=NRPGRP-${id}.lbpsRTXSOnTime
    ...  value=${lbpsRTXSOnTime}
    ...  bts_id=1

    ${lbpsLastCellRTXMinLoad}    get variable value      ${NRPGRP-${id}.lbpsLastCellRTXMinLoad}  ${lbpsLastCellRTXMinLoad_def}
    set enb parameter value
    ...  param_path=NRPGRP-${id}.lbpsLastCellRTXMinLoad
    ...  value=${lbpsLastCellRTXMinLoad}
    ...  bts_id=1

    ${lbpsRTXCellCapOffset}    get variable value      ${NRPGRP-${id}.lbpsRTXCellCapOffset}  ${lbpsRTXCellCapOffset_def}
    set enb parameter value
    ...  param_path=NRPGRP-${id}.lbpsRTXCellCapOffset
    ...  value=${lbpsRTXCellCapOffset}
    ...  bts_id=1

    @{lbpsCellSOOrder}    get variable value      @{NRPGRP-${id}.lbpsCellSOOrder}   @{lbpsCellSOOrder_def}
    set enb parameter value
    ...  param_path=NRPGRP-${id}.lbpsCellSOOrder[0]
    ...  value=@{lbpsCellSOOrder}[0]
    ...  bts_id=1

    @{nrCellId}    get variable value      @{NRPGRP-${id}.nrCellId}   @{nrCellId_def}
    set enb parameter value
    ...  param_path=NRPGRP-${id}.nrCellId[0]
    ...  value=@{nrCellId}[0]
    ...  bts_id=1

    ${cells_list_length}=  Get length    ${nrCellId}
    Run Keyword IF  ${cells_list_length} >= 2
    ...  set enb parameter value
    ...    param_path=NRPGRP-${id}.lbpsCellSOOrder[1]
    ...    value=@{lbpsCellSOOrder}[1]
    ...    bts_id=1
    Run Keyword IF  ${cells_list_length} >= 2
    ...  set enb parameter value
    ...    param_path=NRPGRP-${id}.nrCellId[1]
    ...    value=@{nrCellId}[1]
    ...    bts_id=1
    Run Keyword IF  ${cells_list_length} >= 3
    ...  set enb parameter value
    ...    param_path=NRPGRP-${id}.lbpsCellSOOrder[2]
    ...    value=@{lbpsCellSOOrder}[2]
    ...    bts_id=1
    Run Keyword IF  ${cells_list_length} >= 3
    ...  set enb parameter value
    ...    param_path=NRPGRP-${id}.nrCellId[2]
    ...    value=@{nrCellId}[2]
    ...    bts_id=1
    Run Keyword IF  ${cells_list_length} >= 4
    ...  set enb parameter value
    ...    param_path=NRPGRP-${id}.lbpsCellSOOrder[3]
    ...    value=@{lbpsCellSOOrder}[3]
    ...    bts_id=1
    Run Keyword IF  ${cells_list_length} >= 4
    ...  set enb parameter value
    ...    param_path=NRPGRP-${id}.nrCellId[3]
    ...    value=@{nrCellId}[3]
    ...    bts_id=1

    ${offset}    get variable value      ${NRPGRP-${id}.offset}   ${offset_def}
    Set time period with ${offset} minutes offset for NRPGRP-${id}

    ${lbpsDuration}    get variable value      ${NRPGRP-${id}.lbpsDuration}  ${lbpsDuration_def}
    set enb parameter value
    ...  param_path=NRPGRP-${id}.lbpsDuration
    ...  value=${lbpsDuration}
    ...  bts_id=1

    set enb parameter value
    ...  param_path=NRPGRP-${id}.lbpsDayOfWeek
    ...  value=${NRPGRP-${id}.lbpsDayOfWeek}
    ...  bts_id=1

    set enb parameter value
    ...  param_path=NRPGRP-${id}.lbpsStartTimeHour
    ...  value=${NRPGRP-${id}.lbpsStartTimeHour}
    ...  bts_id=1

    set enb parameter value
    ...  param_path=NRPGRP-${id}.lbpsStartTimeMinute
    ...  value=${NRPGRP-${id}.lbpsStartTimeMinute}
    ...  bts_id=1

    ${lbpsSuspended}    get variable value      ${NRPGRP-${id}.lbpsSuspended}  ${lbpsSuspended_def}
    set enb parameter value
    ...  param_path=NRPGRP-${id}.lbpsSuspended
    ...  value=${lbpsSuspended}
    ...  bts_id=1

Set time period with ${offset} minutes offset for NRPGRP-${id}
    @{time_params}=    get time with offset   ${offset}
    Set Test Variable       ${NRPGRP-${id}.lbpsDayOfWeek}           @{time_params}[0]
    Set Test Variable       ${NRPGRP-${id}.lbpsStartTimeHour}       @{time_params}[1]
    Set Test Variable       ${NRPGRP-${id}.lbpsStartTimeMinute}     @{time_params}[2]

