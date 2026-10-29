*** Settings ***
Documentation    This is common keywords for siso RRH related cases
...              Please do not modify the file without notification to author
...              Author: tingting.zhong
...              Contact: tingting.zhong@nokia-sbell.com
...              Squard: HZ SG4

Library        taf.selenium.sbts        WITH NAME        selenium_coam
Library        testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/modify_bsrs_csrs.py
Resource       testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource       testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource       testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/coam_check_status.robot
Resource       testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/pre_analysis.robot

*** Variables ***
${MRBTS_ID}                  ${tl.gnbs[0].instance_id}
${NRBTS_ID}                  ${tl.gnbs[0].global_bts_id}
&{support_cellTechnology}    5GC002200=TDD    5GC001086=TDD    CB007597=TDD

*** Keywords ***
NR Feature 5GC002200 ON via webem
    [Documentation]  Auther: tingting.zhong@nokia-sbell.com
    [Arguments]  ${cell_id}=1    ${is_activate}=${True}    ${modify_params}=@{EMPTY}
    log to console    \nNR cell${cell_id} Modify 5GC002200 ON via webem
    ${cell_dist_name}    set variable    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
    ${item}    create dictionary    dist_name=${cell_dist_name}
    ...    filter_param=Downlink MIMO Mode
    ...    p_name=dlMimoMode
    ...    value=8x4 Closed Loop Spatial Multiplexing
    append to list    ${modify_params}    ${item}
    ${item}    create dictionary    dist_name=${cell_dist_name}
    ...    filter_param=Number of CSI-RS resource period in one CSI report period
    ...    p_name=sNumberWithinReportPeriod_Set1
    ...    value=3
    append to list    ${modify_params}    ${item}
    ${item}    create dictionary    dist_name=${cell_dist_name}
    ...    filter_param=Number of CSI-RS resource period in one CSI report period
    ...    p_name=sNumberWithinReportPeriod_Set1
    ...    value=3
    append to list    ${modify_params}    ${item}
    ${ssPbchBlockPower}    Get Parameter Via Webem    dist_name=${cell_dist_name}    filter_param=SS PBCH Block Power
    ${item}    create dictionary    dist_name=${cell_dist_name}
    ...    filter_param=CSI-RS power
    ...    p_name=csirsPower
    ...    value=${ssPbchBlockPower}
    append to list    ${modify_params}    ${item}
    ${item}    create dictionary    dist_name=${cell_dist_name}
    ...    filter_param=Maximum CSI-RS number
    ...    p_name=maxCsirsNumber
    ...    value=4
    append to list    ${modify_params}    ${item}
    Modify Parameters On Webem    modify_params=${modify_params}    is_activate=${is_activate}

NR Feature 5GC001086 ON via webem
    [Documentation]  Auther: tingting.zhong@nokia-sbell.com
    [Arguments]  ${cell_id}=1    ${is_activate}=${True}    ${modify_params}=@{EMPTY}
    log to console    \nNR cell${cell_id} Modify 5GC001086 ON via webem
    ${cell_dist_name}    set variable    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
    ${chbw}    Get Parameter Via Webem    dist_name=${cell_dist_name}    filter_param=Channel bandwidth
    ${chbw}    get regexp matches    ${chbw}    [0-9]+
    ${modify_params}    generate_srs_modify_params    cell_band=${chBw[0]}    dist_name=${cell_dist_name}
    ${item}    create dictionary    dist_name=${cell_dist_name}
    ...    filter_param=Activate uplink SRS based beam management
    ...    p_name=actUlSrsBm
    ...    value=true
    append to list    ${modify_params}    ${item}
    ${item}    create dictionary    dist_name=${cell_dist_name}
    ...    filter_param=Lower Cell Edge Angle
    ...    p_name=lowerEdgeAngle
    ...    value=120
    append to list    ${modify_params}    ${item}
    ${item}    create dictionary    dist_name=${cell_dist_name}
    ...    filter_param=Upper Cell Edge Angle
    ...    p_name=upperEdgeAngle
    ...    value=60
    append to list    ${modify_params}    ${item}
    ${item}    create dictionary    dist_name=${cell_dist_name}
    ...    filter_param=Massive MIMO Antenna Array Mod
    ...    p_name=mMimoAntArrayMode
    ...    value=Full 32TRX Array (2x8x2)
    append to list    ${modify_params}    ${item}
    ${item}    create dictionary    dist_name=${cell_dist_name}
    ...    filter_param=SRS periodicity of UE transmission
    ...    p_name=srsUePeriodicity
    ...    value=slots40
    append to list    ${modify_params}    ${item}
    Modify Parameters On Webem    modify_params=${modify_params}    is_activate=${is_activate}

NR Get Parameter Name with Version
    [Documentation]  Auther: tingting.zhong@nokia-sbell.com
    [Arguments]  ${sw_version}=${Active_SW_version}
    ${stream}    get stream from version    version=${sw_version}
    ${parameter_name}    set variable if    '${stream}'=='SBTS23R1' or '${stream}'=='SBTS23R2'    Activate cell timing offset
    ...    Activate eCPRI cell timing offset
    [Return]  ${parameter_name}

Get Energy Saving Mode Param Name
    [Documentation]  Auto-detect energySavingMode parameter display name.
    ...              Try 'Energy Saving Mode control' first (new SW), fall back to 'Energy Saving Mode Activation' (old SW).
    ${status}    ${_}    Run Keyword And Ignore Error
    ...    Get Parameter Via Webem
    ...    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1
    ...    filter_param=Energy Saving Mode control
    Return From Keyword If    '${status}'=='PASS'    Energy Saving Mode control
    [Return]    Energy Saving Mode Activation

Check And Modify Energy Saving Mode On WebUI
    [Documentation]  Detect correct energySavingMode parameter name (version-aware) and modify it via WebUI.
    [Arguments]    ${dist_name}    ${new_value}=NORMAL
    ${esm_param}    Get Energy Saving Mode Param Name
    Check and Modify Single Parameter on WebUI    dist_name=${dist_name}
    ...    filter_param=${esm_param}    abbr=energySavingMode    new_value=${new_value}

NR Feature CB007597 ON via webem
    [Documentation]  Auther: tingting.zhong@nokia-sbell.com
    [Arguments]  ${cell_id}=1    ${is_activate}=${True}    ${modify_params}=@{EMPTY}    ${frameStartOffset}=3000
    ...    ${sfnOffset}=0
    log to console    \nNR cell${cell_id} Modify CB007597 ON via webem to frameStartOffset ${frameStartOffset} sfnOffset ${sfnOffset}
    ${dist_name}    set variable    MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ${filter_param}    NR Get Parameter Name with Version
    ${item}    create dictionary    dist_name=${dist_name}
    ...    filter_param=${filter_param}
    ...    p_name=actCellTimingOffset
    ...    value=true
    append to list    ${modify_params}    ${item}
    ${cell_dist_name}    set variable    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
    ${item}    create dictionary    dist_name=${cell_dist_name}
    ...    filter_param=Frame start offset
    ...    p_name=frameStartOffset
    ...    value=${frameStartOffset}
    append to list    ${modify_params}    ${item}
    ${item}    create dictionary    dist_name=${cell_dist_name}
    ...    filter_param=SFN offset
    ...    p_name=sfnOffset
    ...    value=${sfnOffset}
    append to list    ${modify_params}    ${item}
    Modify Parameters On Webem    modify_params=${modify_params}    is_activate=${is_activate}

NR Feature CB007597 On Check Parameter via webem
    [Documentation]  Auther: tingting.zhong@nokia-sbell.com
    [Arguments]  ${cell_id}=1    ${frameStartOffset}=3000    ${sfnOffset}=0
    ${dist_name}    set variable    MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ${filter_param}    NR Get Parameter Name with Version
    ${actCellTimingOffset}    Get Parameter Via Webem    dist_name=${dist_name}    filter_param=${filter_param}
    should be equal as strings    ${actCellTimingOffset}    true
    ${cell_dist_name}    set variable    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
    ${get_frameStartOffset}    Get Parameter Via Webem    dist_name=${cell_dist_name}    filter_param=Frame start offset
    should contain    ${get_frameStartOffset}    ${frameStartOffset}
    ${get_sfnOffset}    Get Parameter Via Webem    dist_name=${cell_dist_name}    filter_param=SFN offset
    should be equal as strings    ${get_sfnOffset}    ${sfnOffset}

NR Feature CB007597 OFF via webem
    [Documentation]  Auther: tingting.zhong@nokia-sbell.com
    [Arguments]   ${is_activate}=${True}    ${modify_params}=@{EMPTY}
    log to console    \nNR Modify CB007597 OFF via webem
    ${filter_param}    NR Get Parameter Name with Version
    ${dist_name}    set variable    MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ${item}    create dictionary    dist_name=${dist_name}
    ...    filter_param=${filter_param}
    ...    p_name=actCellTimingOffset
    ...    value=false
    append to list    ${modify_params}    ${item}
    Modify Parameters On Webem    modify_params=${modify_params}    is_activate=${is_activate}

NR Feature ON per Cell
    [Documentation]  Auther: tingting.zhong@nokia-sbell.com
    [Arguments]    ${feature_on_list}    ${cell_id}=1
    ${cell_dist_name}    set variable    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
    ${cellTechnology}    Get Parameter Via Webem    dist_name=${cell_dist_name}    filter_param=Cell technology
    FOR    ${feature}    IN    @{feature_on_list}
        run keyword if    '${cellTechnology}'=='${support_cellTechnology}[${feature}]' or '${support_cellTechnology}[${feature}]'=='BOTH'
        ...    NR Feature ${feature} ON via webem    cell_id=${cell_id}
    END

NR Feature ON via Webem
    [Documentation]  Auther: tingting.zhong@nokia-sbell.com
    [Arguments]    ${feature_on_list}
    ${cell_id_list}    Get All Cell Id
    FOR    ${cell_id}    IN    @{cell_id_list}
        NR Feature ON per Cell    feature_on_list=${feature_on_list}    cell_id=${cell_id}    is_activate=${False}
    END
    selenium_coam.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${False}    timeout=${300}

NR Feature CB007597 ON and Check
    [Documentation]  Auther: tingting.zhong@nokia-sbell.com
    [Arguments]  ${cell_id_list}    ${frameStartOffset}=3000    ${sfnOffset}=0
    ${modify_params}    create list
    FOR    ${cell_id}    IN    @{cell_id_list}
        NR Feature CB007597 ON via webem    cell_id=${cell_id}    is_activate=${False}    modify_params=${modify_params}
        ...    frameStartOffset=${frameStartOffset}    sfnOffset=${sfnOffset}
    END
    selenium_coam.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${False}    timeout=${300}
    sleep    1min
    Check All Components Status    operation_component=site    gnb_type=${gNb_CuType}
    FOR    ${cell_id}    IN    @{cell_id_list}
        NR Feature CB007597 On Check Parameter via webem    cell_id=${cell_id}    frameStartOffset=${frameStartOffset}    sfnOffset=${sfnOffset}
    END

NR Feature CB007597 OFF and Check
    [Documentation]  Auther: tingting.zhong@nokia-sbell.com
    ${modify_params}    create list
    NR Feature CB007597 OFF via webem    is_activate=${True}    modify_params=${modify_params}
    sleep    1min
    Check All Components Status    operation_component=no    gnb_type=${gNb_CuType}
    Check Parameters Modified Successfully    modify_params=${modify_params}

NR update power saving mode via webem
    [Documentation]  Auther: zhihao.shi@nokia-sbell.com
    [Arguments]  ${energySavingMode}=DEEPSLEEP    ${actNrLBPowerSaving}=true    ${ru_index}=1
    log to console    \n update energySavingMode to ${energySavingMode} and actNrLBPowerSaving to ${actNrLBPowerSaving}
    ${esm_param}    Get Energy Saving Mode Param Name
    ${modify_params}  create list
    ${item}    create dictionary    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-${ru_index}
    ...    filter_param=${esm_param}
    ...    p_name=energySavingMode
    ...    value=${energySavingMode}
    append to list    ${modify_params}    ${item}
    ${item}    create dictionary    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    filter_param=Activate NR load-based power saving
    ...    p_name=actNrLBPowerSaving
    ...    value=${actNrLBPowerSaving}
    append to list    ${modify_params}    ${item}
    Modify Parameters On Webem    modify_params=${modify_params}

NR Feature CB007511 OFF and Check
    [Arguments]    ${actNrLBPowerSaving}=false  ${actNrLBmMimoRTXPowerSaving}=false      ${actNrMixedSOMethod}=false
    ...   ${lbpsSOMethod}=cell switch off     ${actLbpsCtrlLogicEnh}=false  ${actNrExtCellSOMethod}=false
    ...   ${NRPGRP_index}=1   ${actCoordinated4g5gPowerSaving}=disabled  ${energySavingMode}=NORMAL  ${RMOD_index}=1
    ...   ${powerSavingAvoidanceForPACalls}=PA avoidance disabled
    log to console
    ...   start set 5GC000431 and CB007511 actNrLBPowerSaving:${actNrLBPowerSaving}, energySavingMode:${energySavingMode}
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
    ${esm_param}    Get Energy Saving Mode Param Name
    ${energySavingMode_dic}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-${RMOD_index}
    ...   filter_param=${esm_param}
    ...   p_name=energySavingMode  value=${energySavingMode}
    ${powerSavingAvoidanceForPACalls_dic}  create dictionary  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...   filter_param=Power saving avoidance options for priority access calls
    ...   p_name=powerSavingAvoidanceForPACalls  value=${powerSavingAvoidanceForPACalls}
    append to list  ${modify_params}  ${actNrLBPowerSaving_dic}
    append to list  ${modify_params}  ${actLbpsCtrlLogicEnh_dic}
    append to list  ${modify_params}  ${actNrExtCellSOMethod_dic}
    append to list  ${modify_params}  ${actCoordinated4g5gPowerSaving_dic}
    append to list  ${modify_params}  ${actNrLBmMimoRTXPowerSaving_dic}
    append to list  ${modify_params}  ${actNrMixedSOMethod_dic}
    append to list  ${modify_params}  ${lbpsSOMethod_dic}
    append to list  ${modify_params}  ${energySavingMode_dic}
    append to list  ${modify_params}  ${powerSavingAvoidanceForPACalls_dic}
    Modify Parameters On Webem    modify_params=${modify_params}
    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type='${gNb_CuType}'

NR Feature 5GC000430 Set and Check
    [Arguments]    ${actMicroDTXAdvanced}=false  ${actMicroDTX}=false
    log to console
    ...   start set 5GC000430:${actMicroDTX}
    ${modify_params}  create list
    ${actMicroDTXAdvanced_dic}  create dictionary  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    filter_param=Activate micro discontinued transmission advanced  p_name=actMicroDTXAdvanced  value=${actMicroDTXAdvanced}
    ${actMicroDTX_dic}  create dictionary  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    filter_param=Activate micro discontinued transmission  p_name=actMicroDTX  value=${actMicroDTX}
    append to list  ${modify_params}  ${actMicroDTXAdvanced_dic}
    append to list  ${modify_params}  ${actMicroDTX_dic}
    Modify Parameters On Webem    modify_params=${modify_params}
    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type='${gNb_CuType}'

NR Feature 5GC000431 ON and Check
    [Arguments]    ${lbpsLastCellSOEnabled}=true  ${actNrLBPowerSaving}=true  ${NRPGRP_index}=1
    log to console
    ...   start set 5GC000431 actNrLBPowerSaving:${actNrLBPowerSaving}
    ${modify_params}  create list
    ${lbpsLastCellSOEnabled_dic}  create dictionary  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-${NRPGRP_index}
    ...   filter_param=Load-based power saving last cell switch off enabled  p_name=lbpsLastCellSOEnabled  value=${lbpsLastCellSOEnabled}
    ${actNrLBPowerSaving_dic}  create dictionary  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    filter_param=Activate NR load-based power saving  p_name=actNrLBPowerSaving  value=${actNrLBPowerSaving}
    append to list  ${modify_params}  ${actNrLBPowerSaving_dic}
    append to list  ${modify_params}  ${lbpsLastCellSOEnabled_dic}
    Modify Parameters On Webem    modify_params=${modify_params}
    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type='${gNb_CuType}'

NR Feature CB007511 ON and Check
    [Arguments]    ${energySavingMode}=DEEPSLEEP  ${RMOD_index}=1
    log to console
    ...   start set 5GC000431 actNrLBPowerSaving:${energySavingMode}
    ${esm_param}    Get Energy Saving Mode Param Name
    ${modify_params}  create list
    ${energySavingMode_dic}  create dictionary  dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-${RMOD_index}
    ...   filter_param=${esm_param}  p_name=energySavingMode  value=${energySavingMode}
    append to list  ${modify_params}  ${energySavingMode_dic}
    Modify Parameters On Webem    modify_params=${modify_params}
    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type='${gNb_CuType}'
