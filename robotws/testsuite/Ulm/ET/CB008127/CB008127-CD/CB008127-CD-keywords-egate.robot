*** Settings ***
Documentation   This is a keyword file for CB008127 part egate
...             Team: 'MN RAN RD VRF ULM6'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

*** Variables ***

${WIRESHARK_RUNNING}     false

*** Keywords ***


update gscn in iphy file
    [Documentation]    [PRIVATE]    update gscn in iphy file
    ...       :Autor: Sylvia Schneider
    log to console    setting GSCN for cell2 to value 7995 in /ffs/run/simmode/new_iphy.xml
    ${ACU_alias}    Connect to Airphone Common Unit
    ssh.execute    cp /ffs/run/simmode/new_iphy.xml /ffs/run/simmode/new_iphy_orig.xml    connection=${ACU_alias}
    ssh.Download File    /rom/simmode/new_iphy.xml    ${resultBaseDir}/new_iphy.xml    connection=${ACU_alias}
    ${contents}    Get File    ${resultBaseDir}/new_iphy.xml
    ${all_parts}    Split String      ${contents}     </RE>
    ${upd1}    Replace String Using Regexp          ${all_parts}[1]         GSCN>.*<\/GSCN>   GSCN>7995<\/GSCN>
    ${new contents}      catenate         SEPARATOR=</RE>   ${all_parts}[0]            ${upd1}
    ${new contents}      catenate         SEPARATOR=</RE>   ${new contents}    ${all_parts}[2]
    ${new contents}      catenate         SEPARATOR=</RE>   ${new contents}    ${all_parts}[3]
    ${new contents}      catenate         SEPARATOR=</RE>   ${new contents}    ${all_parts}[4]
    Create File    ${resultBaseDir}/new_iphy_upd.xml    ${new contents}
    ssh.Upload File       ${resultBaseDir}/new_iphy_upd.xml    /rom/simmode/new_iphy.xml   connection=${ACU_alias}


check wts in active state
    [Documentation]    [PRIVATE]    check that wts is in state active
    ...       :Autor: Sylvia Schneider
    Log To Console    \ncheck if wts in active state
    Wait Until Keyword Succeeds    5 min    20 sec    check wts state
    Log To Console    check if wts in active state ended


check wts state
    [Documentation]    [PRIVATE]    check that wts is in state active
    ...       :Autor: Sylvia Schneider
    ute_wtssim.execute egate command and wait for data
    ...    cmd=sim_state_disp
    ...    pass_regexp=The state is ACTIVE   alias=ap_egate


attach UE and sgnbAddition and disp meas
    [Documentation]    [PRIVATE]    attach UE and sgnbAddition and disp meas
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${ue_id}
    Attach UE to LTE    ue_id=${ue_id}
    Sleep    2s
    ${output}   Trigger LTE-NR dual connectivity for bearers    ue_id=${ue_id}    bearer_id=2   target_cells=1
    Create File    ${resultDir}/sgNBadd_UE${ue_id}.txt    ${output}
    sleep    3s
    display measurements of UE    ue_id=${ue_id}   log=_1
    Sleep    2s


attach UE and sgnbAddition and disp meas for 3 UEs
    [Documentation]    [PRIVATE]    attach UE and sgnbAddition and disp meas for 3 UEs
    ...       :Autor: Sylvia Schneider
    FOR   ${ue_id}   IN   101    102   103
        attach UE and sgnbAddition and disp meas   ue_id=${ue_id}
    END
    sleep     2s
    FOR   ${ue_id}   IN   101    102   103
        Detach UE from LTE   ue_id=${ue_id}
    END


display measurements of UE
    [Documentation]    [PRIVATE]    display measurements of UE
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}  ${log}=${EMPTY}
    ${cmd}     set variable    ue_meas_disp id=${ue_id}
    Log To Console   execute on wts: ${cmd}
    sleep     2s
    ${output_egate}   ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    alias=ap_egate
    Create File    ${resultDir}/disp_meas_UE${ue_id}${log}.txt    ${output_egate}


initiate SgNB modification
    [Documentation]    [PRIVATE]    initiate SgNB modification
    ...       :Autor: Sylvia Schneider
    prepare setting of candidate cell    ue_id=101    candidate_cell_id=092787002198
    ${cmd}  set variable   ue_ho id=101 ho_mode=INTRA_LTE enb=1 cell=2
    ${check}   set variable   UE101: Intra-eNB handover from ENB-1.1 to ENB-1.2 performed
    Log To Console    execute on wts: ${cmd}
    Log To Console    check on wts: ${check}
    sleep     2s
    ${output_egate}   ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    pass_regexp=${check}
    ...    alias=ap_egate
    Create File    ${resultDir}/egate_log_SgNB_modify.txt    ${output_egate}
    sleep     2s


prepare setting of candidate cell
    [Documentation]    [PRIVATE]    prepare setting of candidate cell
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${ue_id}   ${candidate_cell_id}
    ${cmd}  set variable   enb_cell_param enb=1 id=2 allow_endc=on
    Log To Console    execute on wts: ${cmd}
    ute_wtssim.execute egate command
    ...    cmd=${cmd}
    ...    alias=ap_egate
    sleep     2s

    ${cmd}  set variable   ue_enb_endc_param id=${ue_id} candidate_cells_mn_hex_for_menb_ho=${candidate_cell_id}
    Log To Console    execute on wts: ${cmd}
    ute_wtssim.execute egate command
    ...    cmd=${cmd}
    ...    alias=ap_egate
    sleep     2s


start intra LTE handover without PSCell change and update allowed BC list MRDC
    [Documentation]    [PRIVATE]    start intra LTE handover without PSCell change and update allowed BC list MRDC
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${ue_id}   ${allowed_bc_list_mrdc}
    prepare setting of candidate cell     ue_id=${ue_id}    candidate_cell_id=0926DA802190
    update BC list and start intra lte handover    ue_id=${ue_id}    allowed_bc_list_mrdc=${allowed_bc_list_mrdc}


send measurement gap info
    [Documentation]    [PRIVATE]    send measurement gap info
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${ue_id}
    ${cmd}  set variable   ue_enb_param id=${ue_id} measurement_gap=gp0:0 mgta=ms0 gap_purpose=perUE gap_trigger=gnb_triggered
    Log To Console    execute on wts: ${cmd}
    ute_wtssim.execute egate command
    ...    cmd=${cmd}
    ...    alias=ap_egate
    sleep     2s


send A2 twice and disp meas t3
    [Documentation]    [PRIVATE]    send A2 twice and disp meas
    ...       :Autor: Sylvia Schneider
    send A2 no profile change   ue_id=101   meas_id=3    srsrp_nr=80    srsrq_nr=90
    send A2                     ue_id=101   meas_id=3    srsrp_nr=80    srsrq_nr=80
    display measurements of UE    ue_id=101   log=_2
    Sleep    2s


send A2 twice and disp meas t5
    [Documentation]    [PRIVATE]    send A2 twice and disp meas
    ...       :Autor: Sylvia Schneider
    send A2 no profile change   ue_id=104   meas_id=7    srsrp_nr=90    srsrq_nr=85
    send A2                     ue_id=104   meas_id=7    srsrp_nr=85    srsrq_nr=85
    display measurements of UE    ue_id=104   log=_3
    Sleep    2s


send A2 no profile change
    [Documentation]    [PRIVATE]    send A2 no profile change
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${ue_id}   ${meas_id}    ${srsrp_nr}    ${srsrq_nr}
    ${cmd}  set variable
    ...   ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr} srs_result=0:11:11:0
    Log To Console    execute on wts: ${cmd}
    sleep     2s
    ${output_egate}   ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    alias=ap_egate
    Create File    ${resultDir}/egate_A2_noProfileChange.txt    ${output_egate}
    sleep     2s


send A2
    [Documentation]    [PRIVATE]    send A2
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${ue_id}   ${meas_id}    ${srsrp_nr}    ${srsrq_nr}
    ${cmd}  set variable
    ...   ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr} srs_result=0:11:11:0
    ${check}   set variable   rrcConnectionReconfigurationComplete
    Log To Console    execute on wts: ${cmd}
    Log To Console    check on wts: ${check}
    sleep     2s
    ${output_egate}   ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    pass_regexp=${check}
    ...    alias=ap_egate
    Create File    ${resultDir}/egate_A2.txt    ${output_egate}
    sleep     2s


send A1 twice and disp meas
    [Documentation]    [PRIVATE]    send A1 twice and disp meas
    ...       :Autor: Sylvia Schneider
    send A1 no profile change
    send A1
    display measurements of UE    ue_id=101   log=_3
    Sleep    2s


send A1 no profile change
    [Documentation]    [PRIVATE]    send A1 no profile change
    ...       :Autor: Sylvia Schneider
    ${cmd}  set variable   ue_measurement_send_nr id=101 meas_id=5 event=A1 srsrp_nr=95 srsrq_nr=90
    Log To Console    execute on wts: ${cmd}
    sleep     2s
    ${output_egate}   ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    alias=ap_egate
    Create File    ${resultDir}/egate_A1_noProfileChange.txt    ${output_egate}
    sleep     2s


send A1
    [Documentation]    [PRIVATE]    send A1
    ...       :Autor: Sylvia Schneider
    ${cmd}  set variable  ue_measurement_send_nr id=101 meas_id=5 event=A1 srsrp_nr=95 srsrq_nr=95
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


send A1 for A4 measurement configuration
    [Documentation]    [PRIVATE]    send A1 for A4 measurement configuration
    ...       :Autor: Sylvia Schneider
    ${cmd}  set variable  ue_measurement_send_nr id=104 meas_id=9 event=A1 srsrp_nr=100 srsrq_nr=107 srs_result=0:11:11:0
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


send endc param
    [Documentation]    [PRIVATE]    send endc param
    ...       :Autor: Sylvia Schneider
    ${cmd}  set variable   ue_enb_endc_param id=101 candidate_cells_mn_hex_for_menb_ho=092787002198
    Log To Console    execute on wts: ${cmd}
    ute_wtssim.execute egate command
    ...    cmd=${cmd}
    ...    alias=ap_egate
    sleep     2s


send intra lte handover
    [Documentation]    [PRIVATE]    send intra lte handover
    ...       :Autor: Sylvia Schneider
    ${cmd}  set variable  ue_ho id=101 ho_mode=INTRA_LTE enb=9 cell=9
    ${check}   set variable   rrcConnectionReconfigurationComplete
    Log To Console    execute on wts: ${cmd}
    Log To Console    check on wts: ${check}
    sleep     2s
    ${output_egate}   ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    pass_regexp=${check}
    ...    alias=ap_egate
    Create File    ${resultDir}/egate_intraLteHo.txt    ${output_egate}
    sleep     2s


send A3 with phycell_id and check
    [Documentation]    [PRIVATE]    send A3 with phycell_id and check
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${phycell_id}   ${check}   ${log}
    ${cmd}  set variable       ue_measurement_send_nr id=104 meas_id=1 event=A3 srsrp_nr=19 phycell_id=${phycell_id} nrsrp_nr=30
    Log To Console    execute on wts: ${cmd}
    Log To Console    check on wts: ${check}
    sleep     2s
    ${output_egate}   ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    pass_regexp=${check}
    ...    alias=ap_egate
    Create File    ${resultDir}/egate_A3_${log}.txt    ${output_egate}
    sleep     2s


send two times A3 with phycell_id 48 and 50 and disp meas
    [Documentation]    [PRIVATE]    send two times A3 with phycell_id 48 and 50 and disp meas
    ...       :Autor: Sylvia Schneider
    send A3 with phycell_id and check    phycell_id=48   check=Proxy .eNB 3 cell 1. reported successful RA   log=1
    send A3 with phycell_id and check    phycell_id=50   check=Proxy .eNB 2 cell 1. reported successful RA   log=2
    display measurements of UE    ue_id=104   log=_2


send A3 with srsrq_nr and nrsrq_nr and no profile change
    [Documentation]    [PRIVATE]    send A3 no profile change
    ...       :Autor: Sylvia Schneider
    ${cmd}  set variable       ue_measurement_send_nr id=104 meas_id=2 event=A3 srsrp_nr=29 srsrq_nr=19 phycell_id=51 nrsrp_nr=30 nrsrq_nr=30
    Log To Console    execute on wts: ${cmd}
    sleep     2s
    ${output_egate}   ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    alias=ap_egate
    Create File    ${resultDir}/egate_A3_noProfileChange.txt    ${output_egate}
    sleep     2s

send A3 with srsrq_nr and nrsrq_nr and check
    [Documentation]    [PRIVATE]    send A3 with srsrq_nr and nrsrq_nr and check
    ...       :Autor: Sylvia Schneider
    ${cmd}    set variable    ue_measurement_send_nr id=104 meas_id=2 event=A3 srsrp_nr=19 srsrq_nr=19 phycell_id=51 nrsrp_nr=30 nrsrq_nr=30
    ${check}   set variable   Proxy .eNB 2 cell 2. reported successful RA
    Log To Console    execute on wts: ${cmd}
    Log To Console    check on wts: ${check}
    sleep     2s
    ${output_egate}   ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    pass_regexp=${check}
    ...    alias=ap_egate
    Create File    ${resultDir}/egate_A3_3.txt    ${output_egate}
    sleep     2s


send two times A3 with srsrq_nr and nrsrq_nr and disp meas
    [Documentation]    [PRIVATE]    send two times A3 with phycell_id 48 and 50 and disp meas
    ...       :Autor: Sylvia Schneider
    send A3 with srsrq_nr and nrsrq_nr and no profile change
    send A3 with srsrq_nr and nrsrq_nr and check
    display measurements of UE    ue_id=104   log=_4


send A4 and disp meas
    [Documentation]    [PRIVATE]    send A1 for A4 measurement configuration and send A4 and disp meas
    ...       :Autor: Sylvia Schneider
    send A4 and check
    display measurements of UE    ue_id=104   log=_2


send A4 and check
    [Documentation]    [PRIVATE]    send A4 and check
    ...       :Autor: Sylvia Schneider
    ${cmd}    set variable    ue_measurement_send_nr id=104 meas_id=10 event=A4 srsrp_nr=11 srsrq_nr=11 phycell_id=51 nrsrp_nr=40 nrsrq_nr=30
    ${check}   set variable   Proxy .eNB 2 cell 2. reported successful RA
    Log To Console    execute on wts: ${cmd}
    Log To Console    check on wts: ${check}
    sleep     2s
    ${output_egate}   ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    pass_regexp=${check}
    ...    alias=ap_egate
    Create File    ${resultDir}/egate_A4.txt    ${output_egate}
    sleep     2s


update BC list and start intra lte handover
    [Documentation]    [PRIVATE]    update BC list and start intra lte handover
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${ue_id}   ${allowed_bc_list_mrdc}
    ${cmd}    set variable    enb_endc_param id=1 allowed_bc_list_mrdc=${allowed_bc_list_mrdc}
    Log To Console    execute on wts: ${cmd}
    ute_wtssim.execute egate command
    ...    cmd=${cmd}
    ...    alias=ap_egate
    sleep     2s

    ${cmd}    set variable    ue_ho id=${ue_id} ho_mode=INTRA_LTE enb=1 cell=2
    ${check}   set variable   Intra-eNB handover from ENB-1.1 to ENB-1.2 performed
    Log To Console    execute on wts: ${cmd}
    Log To Console    check on wts: ${check}
    sleep     2s
    ${output_egate}   ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    pass_regexp=${check}
    ...    alias=ap_egate
    Create File    ${resultDir}/intra_HO.txt    ${output_egate}
    sleep     2s

