*** Settings ***
Documentation    This is common keywords for siso energy_efficiency related cases
...              Please do not modify the file without notification to author
...              Author: tingting.zhong
...              Contact: tingting.zhong@nokia-sbell.com
...              Squard: HZ SG4

Library      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/energy_efficiency_time.py

*** Keywords ***
Update Parameter LbpsPeriodList With Current Time
    [Arguments]    ${NRPGRP_index}=1    ${lbpsDuration}=1440    ${lbpsSuspended}=notSuspended
    ${lbpsDayOfWeek}    ${lbpsStartTimeHour}    ${lbpsStartTimeMinute}    get_now_lbps_week_and_time
    ${tmp}    Set Parameter LbpsPeriodList Value    lbpsDayOfWeek=${lbpsDayOfWeek}
    ...    lbpsDuration=${lbpsDuration}    lbpsStartTimeHour=${lbpsStartTimeHour}
    ...    lbpsStartTimeMinute=${lbpsStartTimeMinute}    lbpsSuspended=${lbpsSuspended}
    ${lbpsPeriodList}      create dictionary
    ...    dist_name    MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-${NRPGRP_index}
    ...    parameter    lbpsPeriodList
    ...    value        ${tmp}
    ${parameters}    Create List    ${lbpsPeriodList}
    [Return]    ${parameters}

Set Parameter LbpsPeriodList Value
    [Arguments]    ${lbpsDayOfWeek}=Fri    ${lbpsDuration}=1440    ${lbpsStartTimeHour}=0    ${lbpsStartTimeMinute}=0
    ...    ${lbpsSuspended}=notSuspended
    log to console   set lbps Period duration:${lbpsDuration}, day:${lbpsDayOfWeek}, hour:${lbpsStartTimeHour}, min:${lbpsStartTimeMinute}
    ${tmp}    create dictionary
    ...    lbpsDayOfWeek    ${lbpsDayOfWeek}
    ...    lbpsDuration    ${lbpsDuration}
    ...    lbpsStartTimeHour    ${lbpsStartTimeHour}
    ...    lbpsStartTimeMinute    ${lbpsStartTimeMinute}
    ...    lbpsSuspended    ${lbpsSuspended}
    ${tmp}     Create List     ${tmp}
    [Return]    ${tmp}

Set CB010471 modify parameters list
    [Arguments]    ${actNrLBPowerSaving}=true  ${actNrLBmMimoRTXPowerSaving}=true      ${actNrMixedSOMethod}=true
    ...   ${lbpsSOMethod}=mixed switch off     ${actLbpsCtrlLogicEnh}=true  ${actNrExtCellSOMethod}=true
    ...   ${NRPGRP_index}=1   ${actCoordinated4g5gPowerSaving}=cellDeactAndReact
    log to console
    ...   start set CB010471 actNrLBPowerSaving:${actNrLBPowerSaving}, actNrLBmMimoRTXPowerSaving:${actNrLBmMimoRTXPowerSaving}
    ${modify_params}  create list
    ${actNrMixedSOMethod_dic}  create dictionary  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    filter_param=Activate mixed mode load-based power saving  p_name=actNrMixedSOMethod  value=${actNrMixedSOMethod}
    ${lbpsSOMethod_dic}  create dictionary  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-${NRPGRP_index}
    ...    filter_param=Load-based power saving switch off method  p_name=lbpsSOMethod  value=${lbpsSOMethod}
    ${actCoordinated4g5gPowerSaving_dic}  create dictionary  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...   filter_param=Activate coordinated 4G-5G power saving, 5G  p_name=actCoordinated4g5gPowerSaving  value=${actCoordinated4g5gPowerSaving}
    ${actNrLBPowerSaving_dic}  create dictionary  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    filter_param=Activate NR load-based power saving  p_name=actNrLBPowerSaving  value=${actNrLBPowerSaving}
    ${actNrLBmMimoRTXPowerSaving_dic}  create dictionary  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    filter_param=Activate NR load-based mMIMO TX power saving  p_name=actNrLBmMimoRTXPowerSaving  value=${actNrLBmMimoRTXPowerSaving}
    ${actLbpsCtrlLogicEnh_dic}  create dictionary  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    filter_param=Activate load-based PS control logic enhancement  p_name=actLbpsCtrlLogicEnh  value=${actLbpsCtrlLogicEnh}
    ${actNrExtCellSOMethod_dic}  create dictionary  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...   filter_param=Activate NR cell-level extended configurations for MIMO muting and cell switch off
    ...   p_name=actNrExtCellSOMethod  value=${actNrExtCellSOMethod}
    append to list    ${modify_params}    ${actNrLBPowerSaving_dic}    ${actLbpsCtrlLogicEnh_dic}    ${actNrExtCellSOMethod_dic}
    ...    ${actCoordinated4g5gPowerSaving_dic}    ${actNrLBmMimoRTXPowerSaving_dic}    ${actNrMixedSOMethod_dic}    ${lbpsSOMethod_dic}
    [Return]  ${modify_params}

Set energySavingMode and actNrLBPowerSaving
    [Arguments]    ${ru_index_list}    ${energySavingMode}=NORMAL    ${actNrLBPowerSaving}=false
    log to console    \nStart set actNrLBPowerSaving:${actNrLBPowerSaving}, energySavingMode:${energySavingMode}
    ${modify_params}    create list
    FOR    ${ru_index}    IN    @{ru_index_list}
        ${energySavingMode_dic}    create dictionary    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-${ru_index}
        ...    filter_param=Energy Saving Mode Activation    p_name=energySavingMode    value=${energySavingMode}
        Append To List    ${modify_params}    ${energySavingMode_dic}
    END
    ${actNrLBPowerSaving_dic}    create dictionary    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    filter_param=Activate NR load-based power saving    p_name=actNrLBPowerSaving    value=${actNrLBPowerSaving}
    Append To List    ${modify_params}    ${actNrLBPowerSaving_dic}
    [Return]  ${modify_params}
