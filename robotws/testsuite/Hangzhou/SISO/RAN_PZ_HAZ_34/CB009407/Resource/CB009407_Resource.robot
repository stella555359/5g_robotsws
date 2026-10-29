*** Settings ***
Library     taf.selenium.gnb.oam.coam.classical      WITH NAME    selenium_coam
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource          ../../../../RRM/RAN_PZ_HAZ_34/5GC000496_C/Resources/L3Call.robot
*** Variables ***
${WEBUI_IP}        ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${WEBUI_USERNAME}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}           ${tl.gnbs[0].cu.oam_http_connection_details.password}
${WEBUI_URL}                https://${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}

${MRBTS_ID}            ${tl.gnbs[0].instance_id}
${NRBTS_ID}            ${tl.gnbs[0].global_bts_id}

*** Keywords ***
TC.CB009407-A_10_MicroDTX_interwork_with_CB008238
    MultiUE.PrepareUE    UECFG=${TLCommonConfig['MultiUECFG']}
    MultiUE.Attach    UECFG=${TLCommonConfig['MultiUECFG']}
    MultiUE.StartULTraffic    UECFG=${TLCommonConfig['MultiUECFG']}
    MultiUE.StartDLTraffic    UECFG=${TLCommonConfig['MultiUECFG']}
    MultiUE.CheckThoughput    UECFG=${TLCommonConfig['MultiUECFG']}

    COAM_WebEM.Login
    COAM_WebEM.SetParameterValue    distName=${MRBTS_ID}/${NRBTS_ID}
    ...    Abbreviation=actMicroDTX    abbr=Activate micro discontinued transmission    value=false
    COAM_WebEM.SetParameterValue    distName=${MRBTS_ID}/${NRBTS_ID}
    ...    Abbreviation=actMicroDTXAdvanced    abbr=Activate micro discontinued transmission advanced    value=false
    COAM_WebEM.SetParameterValue    distName=${MRBTS_ID}/${NRBTS_ID}/NRCELL-${CASE_INPUT_CB009407["cell_index"]}
    ...    Abbreviation=actDtxOptimizedScheduler    abbr=Activate micro DTX optimized scheduler    value=false
    COAM_WebEM.ValidateAndActiveParameters
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=nr
    sleep    5min

    ${measurements_disable_DTX}    selenium_coam.get_real_time_measurements    object_names=RMOD
    log    ${measurements_disable_DTX}
    ${measurements_disable_DTX}    get dictionary values   ${measurements_disable_DTX['RMOD/RMOD_R-${CASE_INPUT_CB009407["ru_index"]}']}
    ${measurements_disable_DTX}    set variable    ${measurements_disable_DTX[-1]['Power']}

    COAM_WebEM.SetParameterValue    distName=${MRBTS_ID}/${NRBTS_ID}
    ...    Abbreviation=actMicroDTX    abbr=Activate micro discontinued transmission    value=true
    COAM_WebEM.SetParameterValue    distName=${MRBTS_ID}/${NRBTS_ID}/NRCELL-${CASE_INPUT_CB009407["cell_index"]}
    ...    Abbreviation=actDtxOptimizedScheduler    abbr=Activate micro DTX optimized scheduler    value=true
    COAM_WebEM.ValidateAndActiveParameters
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=nr
    sleep    5min

    ${measurements_enable_DTX}    selenium_coam.get_real_time_measurements    object_names=RMOD
    log    ${measurements_enable_DTX}
    ${measurements_enable_DTX}     get dictionary values   ${measurements_enable_DTX['RMOD/RMOD_R-${CASE_INPUT_CB009407["ru_index"]}']}
    ${measurements_enable_DTX}    set variable    ${measurements_enable_DTX[-1]['Power']}

    MultiUE.StopDLTraffic        UECFG=${TLCommonConfig['MultiUECFG']}
    MultiUE.Detach               UECFG=${TLCommonConfig['MultiUECFG']}

    ${result}    Evaluate    ${measurements_disable_DTX} - ${measurements_enable_DTX}
    ${result}    Evaluate    ${result} / ${measurements_disable_DTX}
    should be true    ${result} > 0.2
    COAM_WebEM.Logout


TC.CB009407-A_03_MicroDTX_deactivate
    COAM_WebEM.Login
    COAM_WebEM.SetParameterValue    distName=${MRBTS_ID}/${NRBTS_ID}
    ...    Abbreviation=actMicroDTX    abbr=Activate micro discontinued transmission    value=false
    COAM_WebEM.SetParameterValue    distName=${MRBTS_ID}/${NRBTS_ID}
    ...    Abbreviation=actMicroDTXAdvanced    abbr=Activate micro discontinued transmission advanced    value=false
    COAM_WebEM.SetParameterValue    distName=${MRBTS_ID}/${NRBTS_ID}/NRCELL-${CASE_INPUT_CB009407["cell_index"]}
    ...    Abbreviation=actDtxOptimizedScheduler    abbr=Activate micro DTX optimized scheduler    value=false
    COAM_WebEM.ValidateAndActiveParameters
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=nr
    sleep    8min

    ${measurements_disable_DTX}    selenium_coam.get_real_time_measurements    object_names=RMOD
    log    ${measurements_disable_DTX}
    ${measurements_disable_DTX}    get dictionary values   ${measurements_disable_DTX['RMOD/RMOD_R-${CASE_INPUT_CB009407["ru_index"]}']}
    ${measurements_disable_DTX}    set variable    ${measurements_disable_DTX[-1]['Power']}

    COAM_WebEM.SetParameterValue    distName=${MRBTS_ID}/${NRBTS_ID}
    ...    Abbreviation=actMicroDTX    abbr=Activate micro discontinued transmission    value=true
    COAM_WebEM.SetParameterValue    distName=${MRBTS_ID}/${NRBTS_ID}/NRCELL-${CASE_INPUT_CB009407["cell_index"]}
    ...    Abbreviation=actDtxOptimizedScheduler    abbr=Activate micro DTX optimized scheduler    value=true
    COAM_WebEM.ValidateAndActiveParameters
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair    type=nr
    sleep    8min

    ${measurements_enable_DTX}    selenium_coam.get_real_time_measurements    object_names=RMOD
    log    ${measurements_enable_DTX}
    ${measurements_enable_DTX}     get dictionary values   ${measurements_enable_DTX['RMOD/RMOD_R-${CASE_INPUT_CB009407["ru_index"]}']}
    ${measurements_enable_DTX}    set variable    ${measurements_enable_DTX[-1]['Power']}

    ${result}    Evaluate    ${measurements_disable_DTX} - ${measurements_enable_DTX}
    ${result}    Evaluate    ${result} / ${measurements_disable_DTX}
    should be true    ${result} > 0.2

    COAM_WebEM.Logout