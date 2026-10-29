*** Settings ***
Documentation
...    author: Qingqing Wang / Qing Kang
...    contact: qingqing.1.wang@nokia-sbell.com / qing.kang.ext@nokia-sbell.com
...    squad group: SG_08
...    feature : CB006896

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/BW_common_case/lib/BW_step_keywords.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
Library    ./made_l.py
Variables  ./made_v.py
Variables  ./CB006896_variables.py

*** Keywords ***
Get RU AHPF Uptime Result
    [Arguments]    ${ru_alias}=RU
    ${server_time}    robot.libraries.DateTime.get current date
    ${time_temp}   csn.execute    uptime    connection=${ru_alias}
    ${pattern}   Set Variable    up\\s{1,2}(.*?),\\s{2}
    ${up_time}    Get Regexp Matches     ${time_temp}    ${pattern}    1
    ${uptime1}   Set Variable    ${up_time}[0]
    [Return]      ${server_time}    ${uptime1}

General_SiSo_NR-ARFCN_check_AHPF
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] This case is to test SiSo_NR-ARFCN_check
    ...    ******************
    [Arguments]  ${cell_id}=1
    Selenium Login And Disable Screen Lock
    Get Parameters From NR_Frequencies_Band_AHPF
    get nrarfcn boudary values_AHPF  radio_type=${ru_type_init}
    ${nrarfcnUl}  ${nrarfcnDl}  ${gscn}  get origin nraradcn and gscn_AHPF    cell_id=${cell_id}
    set test variable    ${nrarfcnUl}
	set test variable    ${nrarfcnDl}
	set test variable    ${gscn}
    ${origin_paramsul}  generate nrarfcn gscn modify parameters_AHPF
    ...    nrarfcn=${nrarfcnUl}   gscn=${gscn}    cell_id=${cell_id}   type=ul
    ${origin_paramsdl}  generate nrarfcn gscn modify parameters_AHPF
    ...    nrarfcn=${nrarfcnDl}   gscn=${gscn}    cell_id=${cell_id}   type=dl
    verify nrarfcn out of TX/RX range_AHPF  cell_id=${cell_id}
    Close Start Up View    timeout=60
    ${origin_params}=    calculate_list    origin_paramsul=${origin_paramsul}    origin_paramsdl=${origin_paramsdl}
    modify parameters on webem  modify_params=${origin_params}
    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type='${gNb_CuType}'
    [Teardown]  Selenium Logout And Close Browser

get gscn align with nrarfcn from 3gpp FR1_AHPF
    [Arguments]    ${nrarfcn}
    ${F_REF}=    calculate_F_AHPF    N_REF=${nrarfcn}    global_frequency_raster=${global_frequency_raster}
    ${gscn}=    calculate_gscn_AHPF    ss_ref=${F_REF}    fomular=${global_frequency_raster.GSCN_Fomular}
    [Return]    ${gscn}

Download Scf And Make New_AHPF
    Connect to gnb coam via ssl
    ${scf_file}  COAM Download scf from cluster  scf_dir_path=${SAVE LOG DIRECTORY}
    ${scf_file_name}    Fetch from right    ${scf_file}    /
    ${file_name_without_extention}    String.Replace string    ${scf_file_name}    .xml    ${EMPTY}
    ${time}  get time  epoch
    ${scf_name_for_update}    catenate    SEPARATOR=${EMPTY}    ${file_name_without_extention}
    ...    ${time}.xml
    ${scf_file_update_path}    set variable    ${SAVE LOG DIRECTORY}/${scf_name_for_update}
    [Return]  ${scf_file}  ${scf_file_update_path}

Modify Parameters In SCF From Webem And Commission_AHPF
    [Arguments]  ${modify_params}
    ${scf_file}    ${scf_file_update_path}    Download Scf And Make New_AHPF
    scf.Load scf    ${scf_file}
    FOR  ${item}  IN  @{modify_params}
        ${list_name}    set variable
        ${status}   ${output}   run keyword and ignore error  get from dictionary    ${item}    list_name
        ${list_name}    set variable if    '${status}'=='FAIL'    ${None}    ${output}
        scf.modify_scf_element  dist_name=${item}[dist_name]    list_name=${list_name}
        ...    p_name=${item}[p_name]    value=${item}[value]
    END
    scf.Save scf    ${scf_file_update_path}
    COAM Commission with scf file    scf_file_path=${scf_file_update_path}    timeout=600
    ...  is_pdl_checking_needed=${if_pdl_check}

verify nrarfcn out of TX/RX_AHPF
    [Arguments]  ${Nrarfcn_1807}  ${cell_id}=1   ${type}=ul
    ${gscn}  get gscn align with nrarfcn from 3gpp FR1_AHPF  nrarfcn=${Nrarfcn_1807}
    ${modify_params}  generate nrarfcn gscn modify parameters_AHPF
    ...    nrarfcn=${Nrarfcn_1807}  gscn=${gscn}  cell_id=${cell_id}  type=${type}
    Modify Parameters In SCF From Webem And Commission_AHPF  modify_params=${modify_params}
    sleep   60s
    log to console    \nCheck fault 1900
    Wait Until Keyword Succeeds    5 min    5 sec    Connect to gnb coam via ssl
    Wait For Expect Fault Present  faultId=1900   timeout=1200
    Cell Should Be Disabled
    ${origin_paramsul}  generate nrarfcn gscn modify parameters_AHPF
    ...    nrarfcn=${nrarfcnUl}   gscn=${gscn}    cell_id=${cell_id}   type=ul
    ${origin_paramsdl}  generate nrarfcn gscn modify parameters_AHPF
    ...    nrarfcn=${nrarfcnDl}   gscn=${gscn}    cell_id=${cell_id}   type=dl
    Close Start Up View    timeout=60
    ${origin_params}=    calculate_list    origin_paramsul=${origin_paramsul}    origin_paramsdl=${origin_paramsdl}
    modify parameters on webem  modify_params=${origin_params}
    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type='${gNb_CuType}'
    sleep   60s
    Wait Until Keyword Succeeds    5 min    5 sec    Connect to gnb coam via ssl
    Wait For Expect Fault To Disappear  faultId=1900   timeout=1200
    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type='${gNb_CuType}'

verify nrarfcn out of TX/RX range_AHPF
    [Arguments]  ${cell_id}=1
    log to console    \n***verify nrarfcn out of TX/RX range***
    ######### ul out of min NRARFCN ##########
    log to console   \n ul out of min NRARFCN: ${ulminNrarfcn_1807}..${ulmaxNrarfcn_1807}
    verify nrarfcn out of TX/RX_AHPF  Nrarfcn_1807=${ulminNrarfcn_1807}   min_or_max=min
    ...     NrarfcnStep_3gpp=${NrarfcnStep_3gpp}    cell_id=${cell_id}   type=ul
    ########## ul out of max NRARFCN ##########
    log to console   \n ul out of max NRARFCN: ${ulminNrarfcn_1807}..${ulmaxNrarfcn_1807}
    verify nrarfcn out of TX/RX_AHPF  Nrarfcn_1807=${ulmaxNrarfcn_1807}   min_or_max=max
    ...    NrarfcnStep_3gpp=${NrarfcnStep_3gpp}    cell_id=${cell_id}   type=ul
    ######### dl out of min NRARFCN ##########
    log to console   \n dl out of min NRARFCN: ${dlminNrarfcn_1807}
    verify nrarfcn out of TX/RX_AHPF  Nrarfcn_1807=${dlminNrarfcn_1807}  min_or_max=min
    ...     NrarfcnStep_3gpp=${NrarfcnStep_3gpp}    cell_id=${cell_id}  type=dl
    ########## dl out of max NRARFCN ##########
    log to console   \n dl out of max NRARFCN: ${dlmaxNrarfcn_1807}
    verify nrarfcn out of TX/RX_AHPF  Nrarfcn_1807=${dlmaxNrarfcn_1807}  min_or_max=max
    ...     NrarfcnStep_3gpp=${NrarfcnStep_3gpp}     cell_id=${cell_id}  type=dl

generate nrarfcn gscn modify parameters_AHPF
    [Arguments]  ${nrarfcn}  ${gscn}  ${cell_id}=1  ${type}=ul
    ${stream}    get stream from version    ${Active_SW_version}
    ${gscn_filter}    Set Variable    Synchronization channel number
    ${gscn_pname}    Set Variable    gscnOrSsPbchArfcn
    ${modify_params}  create list
    ${param}   set variable if    '${type}'=='dl'    downlink    uplink
    ${p_name}   set variable if    '${type}'=='dl'    nrarfcnDl      nrarfcnUl
    ${item}  create dictionary  dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-${cell_id}/NRCELL_FDD-1
    ...    filter_param=NR Absolute radio frequency channel number in ${param}  p_name=${p_name}  value=${nrarfcn}
    append to list   ${modify_params}  ${item}
    ${item}  create dictionary  dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-${cell_id}
    ...    filter_param=${gscn_filter}  p_name=${gscn_pname}  value=${gscn}
    append to list   ${modify_params}  ${item}
    [Return]  ${modify_params}

get origin nraradcn and gscn_AHPF
    [Arguments]  ${cell_id}=1
    ${stream}    get stream from version    ${Active_SW_version}
    ${gscn_filter}    Set Variable    Synchronization channel number
    ${gscn}    selenium_coam.Get Parameter Value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_id}
    ...    filter_param=${gscn_filter}
    ${nrarfcnDl}    selenium_coam.Get Parameter Value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_id}/NRCELL_FDD-1
    ...    filter_param=NR Absolute radio frequency channel number in downlink
    ${nrarfcnUl}    selenium_coam.Get Parameter Value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_id}/NRCELL_FDD-1
    ...    filter_param=NR Absolute radio frequency channel number in uplink
    [Return]  ${nrarfcnUl}  ${nrarfcnDl}  ${gscn}

Get Parameters From NR_Frequencies_Band_AHPF
    ${output}  get RF configuration from webui
    ${band_type}  set variable  ${output[5]}
    ${band_num}  get substring    ${band_type}    start=1
    ${frequency_parameters}    get_frequency_parameters_AHPF    band=${band_type}
    set test variable    ${band_num}
    Set Test Variable    ${ulMin_band}    ${frequency_parameters[0]}
    Set Test Variable    ${ulMax_Band}    ${frequency_parameters[1]}
	Set Test Variable    ${dlMin_band}    ${frequency_parameters[2]}
    Set Test Variable    ${dlMax_Band}    ${frequency_parameters[3]}
    set test variable    ${global_frequency_raster}    ${frequency_parameters[4]}

get nrarfcn boudary values_AHPF
    log to console    \n***get nrarfcn boudary values***
    ${band_ulminNrarfcn}  ${band_ulmaxNrarfcn}  ${band_dlminNrarfcn}  ${band_dlmaxNrarfcn}
    ...     get nrarfcn range band boundary frequency_AHPF
    ${ulminNrarfcn_pbf}  ${ulmaxNrarfcn_pbf}  ${dlminNrarfcn_pbf}  ${dlmaxNrarfcn_pbf}  ${NrarfcnStep_3gpp}
    ...     get nrarfcn range from TX/RX frequency_AHPF
    ...    band_num=${band_num}  radio_type=${ru_type_init}
    ${band_ulminNrarfcn}  ${band_ulmaxNrarfcn}  ${ulminNrarfcn_validateErr}  ${ulmaxNrarfcn_validateErr}
    ...    ${band_dlminNrarfcn}  ${band_dlmaxNrarfcn}  ${dlminNrarfcn_validateErr}  ${dlmaxNrarfcn_validateErr}
    ...    get nrarfcn out of band boundary from 3gpp_AHPF   band_ulminNrarfcn=${band_ulminNrarfcn}
    ...    band_ulmaxNrarfcn=${band_ulmaxNrarfcn}   band_dlminNrarfcn=${band_dlminNrarfcn}
    ...    band_dlmaxNrarfcn=${band_dlmaxNrarfcn}    NrarfcnStep_3gpp=${NrarfcnStep_3gpp}
    ${ulminNrarfcn_1807}  ${ulmaxNrarfcn_1807}  ${dlminNrarfcn_1807}  ${dlmaxNrarfcn_1807}
    ...    get nrarfcn out of TX/RX frequency range_AHPF
    ...    ulminNrarfcn_pbf=${ulminNrarfcn_pbf}  ulmaxNrarfcn_pbf=${ulmaxNrarfcn_pbf}
    ...    dlminNrarfcn_pbf=${dlminNrarfcn_pbf}  dlmaxNrarfcn_pbf=${dlmaxNrarfcn_pbf}
    ...    NrarfcnStep_3gpp=${NrarfcnStep_3gpp}
    set test variable  ${band_ulminNrarfcn}
    set test variable  ${band_ulmaxNrarfcn}
	set test variable  ${band_dlminNrarfcn}
    set test variable  ${band_dlmaxNrarfcn}
    set test variable  ${ulminNrarfcn_validateErr}
    set test variable  ${ulmaxNrarfcn_validateErr}
	set test variable  ${dlminNrarfcn_validateErr}
    set test variable  ${dlmaxNrarfcn_validateErr}
    set test variable  ${ulminNrarfcn_1807}
    set test variable  ${ulmaxNrarfcn_1807}
	set test variable  ${dlminNrarfcn_1807}
    set test variable  ${dlmaxNrarfcn_1807}
    set test variable  ${NrarfcnStep_3gpp}

get nrarfcn range band boundary frequency_AHPF
    ${band_ulminNrarfcn}     calculate_N_AHPF
    ...     F_REF=${ulMin_Band}    global_frequency_raster=${global_frequency_raster}
    ${band_ulmaxNrarfcn}     calculate_N_AHPF
    ...     F_REF=${ulMax_Band}    global_frequency_raster=${global_frequency_raster}
	${band_dlminNrarfcn}     calculate_N_AHPF
	...     F_REF=${dlMin_band}    global_frequency_raster=${global_frequency_raster}
    ${band_dlmaxNrarfcn}     calculate_N_AHPF
    ...     F_REF=${dlMax_Band}    global_frequency_raster=${global_frequency_raster}
    ${band_ulminNrarfcn}=    Evaluate    math.ceil(${band_ulminNrarfcn})   math  #round up
    ${band_ulmaxNrarfcn}=    Evaluate    math.floor(${band_ulmaxNrarfcn})   math  #round up
	${band_dlminNrarfcn}=    Evaluate    math.ceil(${band_dlminNrarfcn})   math  #round up
    ${band_dlmaxNrarfcn}=    Evaluate    math.floor(${band_dlmaxNrarfcn})   math  #round up
    ${band_ulminNrarfcn}=    Evaluate    int(${band_ulminNrarfcn})
    ${band_ulmaxNrarfcn}=    Evaluate    int(${band_ulmaxNrarfcn})
	${band_dlminNrarfcn}=    Evaluate    int(${band_dlminNrarfcn})
    ${band_dlmaxNrarfcn}=    Evaluate    int(${band_dlmaxNrarfcn})
    log to console       \nrarfcn in band range: ${band_ulminNrarfcn} .. ${band_ulmaxNrarfcn},
    ...     ${band_dlminNrarfcn} .. ${band_dlmaxNrarfcn}
    [Return]    ${band_ulminNrarfcn}    ${band_ulmaxNrarfcn}    ${band_dlminNrarfcn}    ${band_dlmaxNrarfcn}

get nrarfcn range from TX/RX frequency_AHPF
    [Arguments]   ${band_num}  ${radio_type}=${ru_type_init}
    Get ulMinFreq And ulMaxFreq dlMinFreq And dlMaxFreq From BPF    ${band_num}
    ${ulMinFreq_bpf}=    Evaluate    math.ceil(${ulMinFreq_bpf})   math
    ${ulMaxFreq_bpf}=    Evaluate    math.ceil(${ulMaxFreq_bpf})   math
    ${dlMinFreq_bpf}=    Evaluate    math.ceil(${dlMinFreq_bpf})   math
    ${dlMaxFreq_bpf}=    Evaluate    math.ceil(${dlMaxFreq_bpf})   math
    ${ulbandwidth}  ${dlbandwidth}  ${scs}  ${ssb}  get band scs ssb_AHPF
    ${NRB}  ${Min_guard}  ${NrarfcnStep_3gpp}  Get NR Frequencies Info_AHPF  ${ulbandwidth}
    ...     ${dlbandwidth}  ${scs}  ${ssb}
    ${ulMinFreq}  ${ulMaxFreq}  ${dlMinFreq}  ${dlMaxFreq}  Calculate MaxFreq And MinFreq_AHPF
    ...   ${ulMinFreq_bpf}  ${ulMaxFreq_bpf}
    ...   ${dlMinFreq_bpf}  ${dlMaxFreq_bpf}
    ...   ${NRB}  ${scs}  ${Min_guard}  ${ulbandwidth}  ${dlbandwidth}
    ${ulminNrarfcn_pbf}     calculate_N_AHPF    F_REF=${ulMinFreq}    global_frequency_raster=${global_frequency_raster}
    ${ulmaxNrarfcn_pbf}     calculate_N_AHPF    F_REF=${ulMaxFreq}    global_frequency_raster=${global_frequency_raster}
    ${dlminNrarfcn_pbf}     calculate_N_AHPF    F_REF=${dlMinFreq}    global_frequency_raster=${global_frequency_raster}
    ${dlmaxNrarfcn_pbf}     calculate_N_AHPF    F_REF=${dlMaxFreq}    global_frequency_raster=${global_frequency_raster}
    log to console       \n${radio_type} accurate working nrarfcn range: ${ulminNrarfcn_pbf} .. ${ulmaxNrarfcn_pbf}
    ...   ${dlminNrarfcn_pbf} .. ${dlmaxNrarfcn_pbf}
    ${ulminNrarfcn_pbf}=    Evaluate    math.ceil(${ulminNrarfcn_pbf})   math  #round up   #630667.0
    ${ulmaxNrarfcn_pbf}=    Evaluate    math.floor(${ulmaxNrarfcn_pbf})   math  #round up   #638667.0
    ${dlminNrarfcn_pbf}=    Evaluate    math.ceil(${dlminNrarfcn_pbf})   math  #round up   #630667.0
    ${dlmaxNrarfcn_pbf}=    Evaluate    math.floor(${dlmaxNrarfcn_pbf})   math  #round up   #638667.0
    ${ulmaxNrarfcn_pbf}=    Evaluate    int(${ulmaxNrarfcn_pbf})
    ${ulminNrarfcn_pbf}=    Evaluate    int(${ulminNrarfcn_pbf})
    ${dlmaxNrarfcn_pbf}=    Evaluate    int(${dlmaxNrarfcn_pbf})
    ${dlminNrarfcn_pbf}=    Evaluate    int(${dlminNrarfcn_pbf})
    log to console       \n${radio_type} refined working nrarfcn range: ${ulminNrarfcn_pbf} .. ${ulmaxNrarfcn_pbf}
    ...   ${dlminNrarfcn_pbf} .. ${dlmaxNrarfcn_pbf}
    [Return]  ${ulminNrarfcn_pbf}  ${ulmaxNrarfcn_pbf}  ${dlminNrarfcn_pbf}  ${dlmaxNrarfcn_pbf}  ${NrarfcnStep_3gpp}

Calculate MaxFreq And MinFreq_AHPF
    [Arguments]  ${ulMinFreq_bpf}  ${ulMaxFreq_bpf}  ${dlMinFreq_bpf}  ${dlMaxFreq_bpf}
    ...   ${ulbandwidth}  ${dlbandwidth}
    ${ulMinFreq}=  run keyword if    ${ulMin_band}<3000    evaluate    ${ulMinFreq_bpf}+${ulbandwidth}/2
    ${ulMaxFreq}=  run keyword if    ${ulMax_band}<3000    evaluate    ${ulMaxFreq_bpf}-${ulbandwidth}/2
    ${dlMinFreq}=  run keyword if    ${dlMin_band}<3000    evaluate    ${dlMinFreq_bpf}+${dlbandwidth}/2
    ${dlMaxFreq}=  run keyword if    ${dlMax_band}<3000    evaluate    ${dlMaxFreq_bpf}-${dlbandwidth}/2
    [Return]  ${ulMinFreq}  ${ulMaxFreq}  ${dlMinFreq}  ${dlMaxFreq}

Get NR Frequencies Info_AHPF
    [Arguments]  ${ulbandwidth}  ${dlbandwidth}  ${scs}  ${ssb}
    ${output}  get RF configuration from webui
    ${band_type}  set variable  ${output[5]}
    ${filter}  set variable  ${band_type}_${ulbandwidth}_${dlbandwidth}_${scs}_${ssb}
    ${Information}  get from dictionary  ${NR_Frequencies_FDD}  ${filter}
    ${NRB}  get from dictionary  ${Information}  NRB
    ${Min_guard}  get from dictionary  ${Information}  Min_guard
    ${NrarfcnStep_3gpp}  get from dictionary  ${Information}  NrarfcnStep_3gpp
    [Return]  ${NRB}  ${Min_guard}  ${NrarfcnStep_3gpp}

Get Band SCS SSB_AHPF
    [Arguments]  ${cell_id}=1
    ${chBwUl}    selenium_coam.Get Parameter Value
    ...    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-${cell_id}/NRCELL_FDD-1
    ...    filter_param=Channel bandwidth in uplink
    ${chBwUl}    get regexp matches  ${chBwUl}  [0-9]+
    ${chBwDl}    selenium_coam.Get Parameter Value
    ...    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-${cell_id}/NRCELL_FDD-1
    ...    filter_param=Channel bandwidth in downlink
    ${chBwDl}    get regexp matches  ${chBwDl}  [0-9]+
    ${scs}     selenium_coam.Get Parameter Value    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELLGRP-0
    ...    filter_param=SCS
    ${scs}    get regexp matches  ${scs}  [0-9]+
    ${ssb}     selenium_coam.Get Parameter Value    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-${cell_id}
    ...    filter_param=SS Block Subcarrier Spacing
    ${ssb}    get regexp matches  ${ssb}  [0-9]+
    [Return]    ${chbwUL[0]}  ${chbwDL[0]}  ${scs[0]}  ${ssb[0]}

Get ulMinFreq And ulMaxFreq dlMinFreq And dlMaxFreq From BPF
    [Arguments]    ${band_num}    ${variable_from_CFAM}=${Variables_CFAM}    ${ru_index}=1
    ${bpf_content}    verify content of BPF file    variable_from_CFAM=${variable_from_CFAM}    ru_index=${ru_index}
    ${Freq_bpf_list}   Get regexp matches    ${bpf_content}
    ...    <complex><p Name="Band">${band_num}</p><p Name="Min.Frequency">(\\d+\.?\\d)</p><p Name="Max.Frequency">(\\d+\.?\\d)</p></complex>
    ...    1    2
    ${ulFreq_Min_Max}    set variable    ${Freq_bpf_list}[0]
    ${dlFreq_Min_Max}    set variable    ${Freq_bpf_list}[1]
    set test variable    ${ulMinFreq_bpf}    ${ulFreq_Min_Max[0]}
    set test variable    ${ulMaxFreq_bpf}    ${ulFreq_Min_Max[1]}
    set test variable    ${dlMinFreq_bpf}    ${dlFreq_Min_Max[0]}
    set test variable    ${dlMaxFreq_bpf}    ${dlFreq_Min_Max[1]}

get nrarfcn out of band boundary from 3gpp_AHPF
    [Arguments]  ${band_ulminNrarfcn}  ${band_ulmaxNrarfcn}
    ...    ${band_dlminNrarfcn}  ${band_dlmaxNrarfcn}
    ...    ${NrarfcnStep_3gpp}
    ${ulminNrarfcn_3gpp_tmp}=    Evaluate    ${band_ulminNrarfcn}/${NrarfcnStep_3gpp}    # 620000/20= 31000
    ${ulmaxNrarfcn_3gpp_tmp}=    Evaluate    ${band_ulmaxNrarfcn}/${NrarfcnStep_3gpp}    # 653332/20= int(32666.6)=32666
    ${dlminNrarfcn_3gpp_tmp}=    Evaluate    ${band_dlminNrarfcn}/${NrarfcnStep_3gpp}
    ${dlmaxNrarfcn_3gpp_tmp}=    Evaluate    ${band_dlmaxNrarfcn}/${NrarfcnStep_3gpp}
    ${ulmod_min_3gpp}=    Evaluate        ${band_ulminNrarfcn}-${ulminNrarfcn_3gpp_tmp}*${NrarfcnStep_3gpp}
    ${ulmod_max_3gpp}=    Evaluate        ${band_ulmaxNrarfcn}-${ulmaxNrarfcn_3gpp_tmp}*${NrarfcnStep_3gpp}
    ${dlmod_min_3gpp}=    Evaluate        ${band_dlminNrarfcn}-${dlminNrarfcn_3gpp_tmp}*${NrarfcnStep_3gpp}
    ${dlmod_max_3gpp}=    Evaluate        ${band_dlmaxNrarfcn}-${dlmaxNrarfcn_3gpp_tmp}*${NrarfcnStep_3gpp}
    ${ulmod_min_3gpp_zero}=       Evaluate      ${band_ulminNrarfcn}-${NrarfcnStep_3gpp}
    ${ulmod_min_3gpp_nonzero}=    Evaluate      ${band_ulminNrarfcn}-${ulmod_min_3gpp}
    ${ulmod_max_3gpp_zero}=       Evaluate      ${band_ulmaxNrarfcn}+${NrarfcnStep_3gpp}
    ${ulmod_max_3gpp_nonzero}=    Evaluate      ${band_ulmaxNrarfcn}+(${NrarfcnStep_3gpp}-${ulmod_max_3gpp})

    ${dlmod_min_3gpp_zero}=       Evaluate      ${band_dlminNrarfcn}-${NrarfcnStep_3gpp}
    ${dlmod_min_3gpp_nonzero}=    Evaluate      ${band_dlminNrarfcn}-${dlmod_min_3gpp}
    ${dlmod_max_3gpp_zero}=       Evaluate      ${band_dlmaxNrarfcn}+${NrarfcnStep_3gpp}
    ${dlmod_max_3gpp_nonzero}=    Evaluate      ${band_dlmaxNrarfcn}+(${NrarfcnStep_3gpp}-${dlmod_max_3gpp})

    run keyword if    '${ulmod_min_3gpp}' == '0'
    ...    set test variable    ${ulminNrarfcn_validateErr}    ${ulmod_min_3gpp_zero}    #############  619998
    ...    ELSE    set test variable    ${ulminNrarfcn_validateErr}    ${ulmod_min_3gpp_nonzero}
    run keyword if    '${ulmod_max_3gpp}' == '0'
    ...    set test variable    ${ulmaxNrarfcn_validateErr}    ${ulmod_max_3gpp_zero}    #############  653334
    ...    ELSE    set test variable    ${ulmaxNrarfcn_validateErr}    ${ulmod_max_3gpp_nonzero}

    run keyword if    '${dlmod_min_3gpp}' == '0'
    ...    set test variable    ${dlminNrarfcn_validateErr}    ${dlmod_min_3gpp_zero}    #############  619998
    ...    ELSE    set test variable    ${dlminNrarfcn_validateErr}    ${dlmod_min_3gpp_nonzero}
    run keyword if    '${dlmod_max_3gpp}' == '0'
    ...    set test variable    ${dlmaxNrarfcn_validateErr}    ${dlmod_max_3gpp_zero}    #############  653334
    ...    ELSE    set test variable    ${dlmaxNrarfcn_validateErr}    ${dlmod_max_3gpp_nonzero}

    ${band_ulminNrarfcn}    evaluate    ${ulminNrarfcn_validateErr}+${NrarfcnStep_3gpp}
    ${band_ulmaxNrarfcn}    evaluate    ${ulmaxNrarfcn_validateErr}-${NrarfcnStep_3gpp}
    ${band_dlminNrarfcn}    evaluate    ${dlminNrarfcn_validateErr}+${NrarfcnStep_3gpp}
    ${band_dlmaxNrarfcn}    evaluate    ${dlmaxNrarfcn_validateErr}-${NrarfcnStep_3gpp}

    [Return]    ${band_ulminNrarfcn}  ${band_ulmaxNrarfcn}  ${ulminNrarfcn_validateErr}  ${ulmaxNrarfcn_validateErr}
    ...    ${band_dlminNrarfcn}  ${band_dlmaxNrarfcn}  ${dlminNrarfcn_validateErr}  ${dlmaxNrarfcn_validateErr}

get nrarfcn out of TX/RX frequency range_AHPF
    [Arguments]  ${ulminNrarfcn_pbf}  ${ulmaxNrarfcn_pbf}  ${dlminNrarfcn_pbf}  ${dlmaxNrarfcn_pbf}  ${NrarfcnStep_3gpp}
    #adjust range of min/max to meet 'min/max nrarfcn out of range'
    ${ulmaxNrarfcn_pbf}=    Evaluate    ${ulmaxNrarfcn_pbf}+0     #One more than max   #638668
    ${ulminNrarfcn_pbf}=    Evaluate    ${ulminNrarfcn_pbf}-${NrarfcnStep_3gpp}     #One less than min   #630666
    ${dlmaxNrarfcn_pbf}=    Evaluate    ${dlmaxNrarfcn_pbf}+0     #One more than max   #638668
    ${dlminNrarfcn_pbf}=    Evaluate    ${dlminNrarfcn_pbf}-${NrarfcnStep_3gpp}     #One less than min   #630666
    #In case of mod(nrarfcn,2) != 0
    ${ulmaxNrarfcn_pbf_tmp}=    Evaluate    ${ulmaxNrarfcn_pbf}/${NrarfcnStep_3gpp}    # 638668/2= 319334
    ${ulminNrarfcn_pbf_tmp}=    Evaluate    ${ulminNrarfcn_pbf}/${NrarfcnStep_3gpp}    # 630666/2= 315333
    ${dlmaxNrarfcn_pbf_tmp}=    Evaluate    ${dlmaxNrarfcn_pbf}/${NrarfcnStep_3gpp}    # 638668/2= 319334
    ${dlminNrarfcn_pbf_tmp}=    Evaluate    ${dlminNrarfcn_pbf}/${NrarfcnStep_3gpp}    # 630666/2= 315333

    ${ulmod_max}=    Evaluate        ${ulmaxNrarfcn_pbf}-${ulmaxNrarfcn_pbf_tmp}*${NrarfcnStep_3gpp}
    ${ulmod_min}=    Evaluate        ${ulminNrarfcn_pbf}-${ulminNrarfcn_pbf_tmp}*${NrarfcnStep_3gpp}
    ${dlmod_max}=    Evaluate        ${dlmaxNrarfcn_pbf}-${dlmaxNrarfcn_pbf_tmp}*${NrarfcnStep_3gpp}
    ${dlmod_min}=    Evaluate        ${dlminNrarfcn_pbf}-${dlminNrarfcn_pbf_tmp}*${NrarfcnStep_3gpp}

    ${ulmod_max_zero}    set variable      ${ulmaxNrarfcn_pbf}
    ${ulmod_max_nonzero}=    Evaluate      ${ulmaxNrarfcn_pbf}+(${NrarfcnStep_3gpp}-${ulmod_max})
    ${ulmod_min_zero}    set variable      ${ulminNrarfcn_pbf}
    ${ulmod_min_nonzero}=    Evaluate      ${ulminNrarfcn_pbf}-${ulmod_min}
    ${dlmod_max_zero}    set variable      ${dlmaxNrarfcn_pbf}
    ${dlmod_max_nonzero}=    Evaluate      ${dlmaxNrarfcn_pbf}+(${NrarfcnStep_3gpp}-${dlmod_max})
    ${dlmod_min_zero}    set variable      ${dlminNrarfcn_pbf}
    ${dlmod_min_nonzero}=    Evaluate      ${dlminNrarfcn_pbf}-${dlmod_min}

    run keyword if    '${ulmod_min}' == '0'
    ...    set test variable    ${ulminNrarfcn_1807}    ${ulmod_min_zero}
    ...    ELSE    set test variable    ${ulminNrarfcn_1807}    ${ulmod_min_nonzero}    #############  630666
    run keyword if    '${ulmod_max}' == '0'
    ...    set test variable    ${ulmaxNrarfcn_1807}    ${ulmod_max_zero}    #############   638662
    ...    ELSE    set test variable    ${ulmaxNrarfcn_1807}    ${ulmod_max_nonzero}

    run keyword if    '${dlmod_min}' == '0'
    ...    set test variable    ${dlminNrarfcn_1807}    ${dlmod_min_zero}
    ...    ELSE    set test variable    ${dlminNrarfcn_1807}    ${dlmod_min_nonzero}    #############  630666
    run keyword if    '${dlmod_max}' == '0'
    ...    set test variable    ${dlmaxNrarfcn_1807}    ${dlmod_max_zero}    #############   638662
    ...    ELSE    set test variable    ${dlmaxNrarfcn_1807}    ${dlmod_max_nonzero}

    [Return]    ${ulminNrarfcn_1807}  ${ulmaxNrarfcn_1807}  ${dlminNrarfcn_1807}  ${dlmaxNrarfcn_1807}

Get MinFreq And MaxFreq From BPF
    [Arguments]  ${band_num}  ${ru_index}=1
    ${bpf_content}   verify content of BPF file    varaible_from_CFAM=${Variables_CFAM}    ru_index=${ru_index}
    ${Freq_bpf_list}   Get regexp matches    ${bpf_content}
    ...    <complex><p Name="Band">${band_num}</p><p Name="Min.Frequency">(\\d+\.?\\d)</p><p Name="Max.Frequency">(\\d+\.?\\d)</p></complex>
    ...    1    2
    ${ulFreq_Min_Max}    set variable    ${ulFreq_bpf_list}[0]
	${dlFreq_Min_Max}    set variable    ${dlFreq_bpf_list}[1]
    set test variable    ${ulMinFreq_bpf}    ${Freq_Min_Max[0]}
    set test variable    ${ulMaxFreq_bpf}    ${Freq_Min_Max[1]}
	set test variable    ${dlMinFreq_bpf}    ${Freq_Min_Max[0]}
    set test variable    ${dlMaxFreq_bpf}    ${Freq_Min_Max[1]}

General_SiSo_RF_module_reset_triggered_by_user_as_part_of_BTS_reset_AHPF
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test case is to verify Reset site shouldn't be performed after RU power reset
    Connect to Common Unit Master
    ${ru_index_list}  Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        ${RU_online_status}    Run Keyword And Return Status    Connect to RU With Allocated IP    ru_alias=RU_${ru_index}
        Should be True    ${RU_online_status}
    END
    COAM Check GNB RU status
    COAM Check GNB ABIL status
    COAM Check GNB ASIK status
    ${start_server_times}    Create Dictionary
    FOR  ${ru_index}  IN  @{ru_index_list}
        ${start_server_time}  ${start_uptime}    Get RU AHPF Uptime Result    ru_alias=RU_${ru_index}
        Set To Dictionary    ${start_server_times}    ${ru_index}    ${start_server_time}
    END
    Perform BTS Site Reset    download_dir=${SAVE LOG DIRECTORY}
    sleep  60
    Wait Until Keyword Succeeds    5 min    5 sec    Connect to gnb coam via ssl
    FOR  ${ru_index}  IN  @{ru_index_list}
        Wait until keyword succeeds    5 min    5 sec    RU Should Be Offline    ru_index=${ru_index}
        ${RU_offline_status}    Run Keyword And Return Status    Connect to RU With Allocated IP    ru_alias=RU_${ru_index}
        Should not be True    ${RU_offline_status}
    END
    COAM Wait gnb And Cells ready    timeout=20 min    gnb_type='${gNb_CuType}'
    Connect to Common Unit Master
    FOR  ${ru_index}  IN  @{ru_index_list}
        ${RU_recovery_status}    Run Keyword And Return Status    Connect to RU With Allocated IP    ru_alias=RU_${ru_index}
        Should be True    ${RU_recovery_status}
        ${end_server_time}    ${end_uptime}    Get RU AHPF Uptime Result    ru_alias=RU_${ru_index}
        ${start_server_time}    Get From Dictionary    ${start_server_times}    ${ru_index}
        RU Should Be Restart    start_server_time=${start_server_time}    end_server_time=${end_server_time}
        ...    uptime=${end_uptime}
        csn.Disconnect  connection=RU_${ru_index}
    END
    [Teardown]  csn.Disconnect  connection=ASIK Master


RU Should Be Restart
    [Arguments]    ${start_server_time}    ${end_server_time}    ${uptime}
#    ${end_server_time}    Replace String    ${end_server_time}   \r\n    ${EMPTY}
#    ${start_server_time}    Replace String    ${start_server_time}   \r\n    ${EMPTY}
    ${reset_recovery_time}    Subtract Date From Date    ${end_server_time}    ${start_server_time}
    ${reset_recovery_time}    Convert Time    ${reset_recovery_time}
    ${uptime}    Convert Time    ${uptime}
    should be true    ${uptime}<=${reset_recovery_time}


General_SiSo_Fault_4008_EFaultId_FrConfiguringFailed_PMAX
    [Documentation]    *****************
    ...    Basic information
    ...    *****************
    ...    Description in reStructuredText format on what is tested
    ...    *****************
    ...    - [TEST PURPOSE] To verify that 5G BTS can report fault 3800: EFaultId_FrConfiguringFailed
    ...      after configuring pmax to out of range value of supported power.
    [Arguments]  ${cell_id}=1
    Selenium Login And Disable Screen Lock
    ${origin_params}  Modify pMax to tirgger fault    cell_id=${cell_id}
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    Wait For Expect Fault Present  faultId=1900   timeout=1200
    Close Start Up View    timeout=60
    Modify Parameters On Webem  ${origin_params}
    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type='${gNb_CuType}'
    [Teardown]  Selenium Logout And Close Browser

RMOD_reset_and_check_cell_status
    COAM Reset ALL RMOD SG8    connection=GNB_OAM
    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type=${gNb_CuType}

BBMOD_reset_and_check_cell_status
    ${bbmod_info_list}    Get BBMODs info SG8    alias=GNB_OAM
    COAM Reset BBMOD    dist_name=${bbmod_info_list[0]['internal']}    connection=GNB_OAM
    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type=${gNb_CuType}

Get BBMODs info SG8
    [Arguments]   ${alias}=COAM
    ${hw_info}   coam.get_detected_hw_info   connection=${alias}
    ${bbmod_info_list}   Create List
    FOR   ${bbmod}   IN   @{hw_info['basebandModules']}
       ${bbmod_info}   Create Dictionary
       Continue For Loop If   'configuration' not in @{bbmod['id'].keys()}
       Set To Dictionary   ${bbmod_info}   internal=${bbmod['id']['internal']}   configuration=${bbmod['id']['configuration']}
    ...   product_name=${bbmod['productName'].split()[0]}
       Append To List   ${bbmod_info_list}   ${bbmod_info}
    END
    #${alarm_info}   coam.get_active_alarms   connection=${alias}
    [Return]   ${bbmod_info_list}

COAM Reset ALL RMOD SG8
    [Documentation]   COAM Reset RMOD
    [Arguments]   ${connection}=COAM
    ${release}   COAM Get SW Release   connection=${connection}
    ${rmods}   coam.get_frm   connection=${connection}
    ${rf_num}   Get Length   ${rmods}
    FOR   ${index}    IN RANGE    ${rf_num}
        ${distname}   Set Variable   ${rmods[${index}]['id']['configuration']}
        ${status}   Set Variable   ${rmods[${index}]['status']['operationalState']}
        ${reset_status}   Run Keyword And Return Status   Run Keyword If  '${status.lower()}'=='enabled'
        ...   coam.reset_unit   dist_name=${distname}   timeout=${1200}   connection=${connection}
        run keyword if  not ${reset_status}   COAM Reset RMOD   dist_name=${distname}   connection=${connection}
    END
    Wait Until Keyword Succeeds   5m   1m   COAM Check All Radio Modules Status    connection=${connection}