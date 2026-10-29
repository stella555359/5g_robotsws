*** Settings ***
Documentation   This is a keyword file for CB008127 part egate
...             Team: 'MN RAN RD VRF ULM6'
...             Author: Shruthi Shivaprasad
#-------------------------------------------------------------------------------------------------------------

*** Variables ***

${WIRESHARK_RUNNING}     false

*** Keywords ***

update gscn in iphy file
    [Documentation]    [PRIVATE]    update gscn in iphy file
    ...       :Autor: Shruthi Shivaprasad
    log to console    setting GSCN for cell1 to value 7845 in /ffs/run/simmode/new_iphy.xml
    ${ACU_alias}    Connect to Airphone Common Unit
    ssh.execute    cp /ffs/run/simmode/new_iphy.xml /ffs/run/simmode/new_iphy_orig.xml    connection=${ACU_alias}
    ssh.Download File    /rom/simmode/new_iphy.xml    ${resultBaseDir}/new_iphy.xml    connection=${ACU_alias}
    ${contents}    Get File    ${resultBaseDir}/new_iphy.xml
    ${all_parts}    Split String      ${contents}     </RE>
    ${upd1}    Replace String Using Regexp          ${all_parts}[0]         GSCN>.*<\/GSCN>   GSCN>7845<\/GSCN>
    ${new contents}      catenate         SEPARATOR=</RE>   ${upd1}            ${all_parts}[1]
    ${new contents}      catenate         SEPARATOR=</RE>   ${new contents}    ${all_parts}[2]
    ${new contents}      catenate         SEPARATOR=</RE>   ${new contents}    ${all_parts}[3]
    ${new contents}      catenate         SEPARATOR=</RE>   ${new contents}    ${all_parts}[4]
    Create File    ${resultBaseDir}/new_iphy_upd.xml    ${new contents}
    ssh.Upload File       ${resultBaseDir}/new_iphy_upd.xml    /rom/simmode/new_iphy.xml   connection=${ACU_alias}


check wts in active state
    [Documentation]    [PRIVATE]    check that wts is in state active
    ...       :Autor: Shruthi Shivaprasad
    Log To Console    \ncheck if wts in active state
    Wait Until Keyword Succeeds    5 min    20 sec    check wts state
    Log To Console    check if wts in active state ended


check wts state
    [Documentation]    [PRIVATE]    check that wts is in state active
    ...       :Autor: Shruthi Shivaprasad
    ute_wtssim.execute egate command and wait for data
    ...    cmd=sim_state_disp
    ...    pass_regexp=The state is ACTIVE   alias=ap_egate


attach UE and sgnbAddition and disp meas
    [Documentation]    [PRIVATE]    attach UE and sgnbAddition and disp meas
    ...       :Autor: Shruthi Shivaprasad
    [Arguments]   ${ue_id}
    Attach UE to LTE    ue_id=${ue_id}
    Sleep    2s
    ${output}   Trigger LTE-NR dual connectivity for bearers    ue_id=${ue_id}    bearer_id=2   target_cells=1
    Create File    ${resultDir}/sgNBadd_UE${ue_id}.txt    ${output}
    sleep    3s
    display measurements of UE    ue_id=${ue_id}   log=_1
    Sleep    2s


attach UE and sgnbAddition and disp meas for UE103
    [Documentation]    [PRIVATE]    attach UE and sgnbAddition and disp meas for UE103
    ...       :Autor: Shruthi Shivaprasad
    FOR   ${ue_id}   IN   103
        attach UE and sgnbAddition and disp meas   ue_id=${ue_id}
    END
    sleep     2s
    FOR   ${ue_id}   IN   103
        Detach UE from LTE   ue_id=${ue_id}
    END

attach UE and sgnbAddition and disp meas for UE102
    [Documentation]    [PRIVATE]    attach UE and sgnbAddition and disp meas for UE102
    ...       :Autor: Shruthi Shivaprasad
    FOR   ${ue_id}   IN   102
        attach UE and sgnbAddition and disp meas   ue_id=${ue_id}
    END
    sleep     2s
    FOR   ${ue_id}   IN   102
        Detach UE from LTE   ue_id=${ue_id}
    END

display measurements of UE
    [Documentation]    [PRIVATE]    display measurements of UE
    ...       :Autor: Shruthi Shivaprasad
    [Arguments]     ${ue_id}  ${log}=${EMPTY}
    ${cmd}     set variable    ue_meas_disp id=${ue_id}
    Log To Console   execute on wts: ${cmd}
    sleep     2s
    ${output_egate}   ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    alias=ap_egate
    Create File    ${resultDir}/disp_meas_UE${ue_id}${log}.txt    ${output_egate}

send measurement gap info
    [Documentation]    [PRIVATE]    send measurement gap info
    ...       :Autor: Shruthi Shivaprasad
    [Arguments]    ${ue_id}
    ${cmd}  set variable   ue_enb_param id=${ue_id} measurement_gap=gp0:0 mgta=ms0 gap_purpose=perUE gap_trigger=gnb_triggered
    Log To Console    execute on wts: ${cmd}
    ute_wtssim.execute egate command
    ...    cmd=${cmd}
    ...    alias=ap_egate
    sleep     2s

send A2
    [Documentation]    [PRIVATE]    send A2
    ...       :Autor: Shruthi Shivaprasad
    [Arguments]    ${ue_id}   ${meas_id}
    ${cmd}  set variable
    ...   ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srs_result=0:11:11:0
    ${check}   set variable   rrcConnectionReconfigurationComplete
    Log To Console    execute on wts: ${cmd}
    Log To Console    check on wts: ${check}
    sleep     2s
    ${output_egate}   ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    pass_regexp=${check}
    ...    alias=ap_egate
    Create File    ${resultDir}/egate_A2_${ue_id}.txt    ${output_egate}
    sleep     2s

send A2 srsrp_srsrq
    [Documentation]    [PRIVATE]    send A2
    ...       :Autor: Shruthi Shivaprasad
    [Arguments]    ${ue_id}   ${meas_id}   ${srsrp}   ${srsrq}
    ${cmd}  set variable
    ...   ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=${srsrp} srsrq_nr=${srsrq}
    ${check}   set variable   rrcConnectionReconfigurationComplete
    Log To Console    execute on wts: ${cmd}
    Log To Console    check on wts: ${check}
    sleep     2s
    ${output_egate}   ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    pass_regexp=${check}
    ...    alias=ap_egate
    Create File    ${resultDir}/egate_A2_UE104.txt    ${output_egate}
    sleep     2s

set spid for UE
    [Documentation]    [PRIVATE]    set spid before attach in wts
    ...     :Autor: Shruthi Shivaprasad
    ...     :param ${ue_id}:   number of UE
    ...     :param ${spid}:    spid value to be set
    [Arguments]     ${ue_id}     ${spid}
    sleep     2s
    ${cmd}   set variable   ue_enb_param id=${ue_id} spid=${spid}
    Log To Console    execute on wts: ${cmd}
    ute_wtssim.execute egate command
    ...    cmd=${cmd}
    ...    alias=ap_egate

send A1
    [Documentation]    [PRIVATE]    send A1
    ...       :Autor: Shruthi Shivaprasad
    ${cmd}  set variable  ue_measurement_send_nr id=101 meas_id=5 event=A1
    ${check}   set variable   rrcConnectionReconfigurationComplete
    Log To Console    execute on wts: ${cmd}
    Log To Console    check on wts: ${check}
    sleep     2s
    ${output_egate}   ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    pass_regexp=${check}
    ...    alias=ap_egate
    Create File    ${resultDir}/egate_A1.txt    ${output_egate}
    sleep     2s

send A1 UE103
    [Documentation]    [PRIVATE]    send A1
    ...       :Autor: Shruthi Shivaprasad
    [Arguments]     ${ue_id}
    ${cmd}  set variable  ue_measurement_send_nr id=${ue_id} meas_id=5 event=A1
    ${check}   set variable   rrcConnectionReconfigurationComplete
    Log To Console    execute on wts: ${cmd}
    Log To Console    check on wts: ${check}
    sleep     2s
    ${output_egate}   ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    pass_regexp=${check}
    ...    alias=ap_egate
    Create File    ${resultDir}/egate_A1_${ue_id}.txt    ${output_egate}
    sleep     2s

send A1 UE104
    [Documentation]    [PRIVATE]    send A1
    ...       :Autor: Shruthi Shivaprasad
    [Arguments]    ${srsrp}   ${srsrq}
    ${cmd}  set variable  ue_measurement_send_nr id=104 meas_id=5 event=A1 srsrp_nr=${srsrp} srsrq_nr=${srsrq}
    ${check}   set variable   rrcConnectionReconfigurationComplete
    Log To Console    execute on wts: ${cmd}
    Log To Console    check on wts: ${check}
    sleep     2s
    ${output_egate}   ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    pass_regexp=${check}
    ...    alias=ap_egate
    Create File    ${resultDir}/egate_A1_UE104.txt    ${output_egate}
    sleep     2s

send endc param
    [Documentation]    [PRIVATE]    send endc param
    ...       :Autor: Shruthi Shivaprasad
    ${cmd}  set variable   ue_enb_endc_param id=101 candidate_cells_mn_hex_for_menb_ho=092787002198
    Log To Console    execute on wts: ${cmd}
    ute_wtssim.execute egate command
    ...    cmd=${cmd}
    ...    alias=ap_egate
    sleep     2s
