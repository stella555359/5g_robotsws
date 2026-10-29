*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == AUTHORS C-PLANE ==
...       - Tomasz Pyrek <tomasz.pyrek@nokia.com>
...       - Konrad Bem <konrad.bem@nokia.com>
...      == MAINTAINER ==
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>

Resource    ../../../resources/Robot/common_settings.robot
Library     ./nrpgrp_configuration.py

*** Variables ***
# CB008392
${actNrLBRTXPowerSaving_def}        False
# 5GC000431
${actNrLBPowerSaving_def}           False
# CB008133 - 64TRX, CB010471 - 32TRX
${actNrLBmMimoRTXPowerSaving_def}   True

${lbpsSOMethod_def}                 'Tx switch off'
${lbpsLastCellSOEnabled_def}        True
${lbpsRTXMaxLoad_def}               60
${lbpsRTXMinLoad_def}               20
${lbpsRTXSOffTime_def}              30
${lbpsRTXSOnTime_def}               30
${lbpsRTXCellCapOffset_def}         80
${lbpsLastCellRTXMinLoad_def}       0
@{lbpsCellSOOrder_def}              1  2
@{nrCellId_def}                     1  2
${offset_def}                       0
${lbpsDuration_def}                 1440
${lbpsSuspended_def}                'notSuspended'

# 5GC000431 specific parameters
${lbpsMaxLoad_def}                  60
${lbpsMinLoad_def}                  20

*** Keywords ***
Set NRPGRP-${id} parameters

    ${actNrLBmMimoRTXPowerSaving}    get variable value      ${NRBTS-1.actNrLBmMimoRTXPowerSaving}  ${actNrLBmMimoRTXPowerSaving_def}
    set enb parameter value
    ...  param_path=NRBTS-1.actNrLBmMimoRTXPowerSaving
    ...  value=${actNrLBmMimoRTXPowerSaving}
    ...  bts_id=1

    ${actNrLBPowerSaving}    get variable value      ${NRBTS-1.actNrLBPowerSaving}  ${actNrLBPowerSaving_def}
    set enb parameter value
    ...  param_path=NRBTS-1.actNrLBPowerSaving
    ...  value=${actNrLBPowerSaving}
    ...  bts_id=1

    ${actNrLBRTXPowerSaving}    get variable value      ${NRBTS-1.actNrLBRTXPowerSaving}  ${actNrLBRTXPowerSaving_def}
    set enb parameter value
    ...  param_path=NRBTS-1.actNrLBRTXPowerSaving
    ...  value=${actNrLBRTXPowerSaving}
    ...  bts_id=1

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

    # 5GC000431 specific parameters
    ${lbpsMaxLoad}    get variable value      ${NRPGRP-${id}.lbpsMaxLoad}  ${lbpsMaxLoad_def}
    set enb parameter value
    ...  param_path=NRPGRP-${id}.lbpsMaxLoad
    ...  value=${lbpsMaxLoad}
    ...  bts_id=1

    ${lbpsMinLoad}    get variable value      ${NRPGRP-${id}.lbpsMinLoad}  ${lbpsMinLoad_def}
    set enb parameter value
    ...  param_path=NRPGRP-${id}.lbpsMinLoad
    ...  value=${lbpsMinLoad}
    ...  bts_id=1

Set time period with ${offset} minutes offset for NRPGRP-${id}
    @{time_params}=    get time with offset   ${offset}
    Set Test Variable       ${NRPGRP-${id}.lbpsDayOfWeek}           @{time_params}[0]
    Set Test Variable       ${NRPGRP-${id}.lbpsStartTimeHour}       @{time_params}[1]
    Set Test Variable       ${NRPGRP-${id}.lbpsStartTimeMinute}     @{time_params}[2]

