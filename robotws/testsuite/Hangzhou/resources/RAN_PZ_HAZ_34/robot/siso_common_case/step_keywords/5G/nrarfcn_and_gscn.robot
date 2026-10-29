*** Settings ***
Documentation    This is common keywords for siso RRH related cases
...              Please do not modify the file without notification to author
...              Author: tingting.zhong
...              Contact: tingting.zhong@nokia-sbell.com
...              Squard: HZ SG4

Library      XML   WITH NAME    ParseXML
Library      taf.selenium.sbts    WITH NAME    selenium_coam
Library      ../../lib/made_lib.py
Resource     ./basic/bpf.robot
Resource     ./basic/bts_selenium.robot
Resource     ./basic/bts_coam.robot
Resource     ./basic/pre_analysis.robot
Resource     ./basic/scf_operation.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/simple_keyword.robot

*** Keywords ***
Get NR Frequencies Info
    [Arguments]  ${bandwidth}  ${scs}  ${ssb}
    ${output}  get RF configuration from webui
    ${band_type}  set variable  ${output[5]}
    ${filter}  set variable  ${band_type}_${bandwidth}_${scs}_${ssb}
    ${Information}  get from dictionary  ${NR_Frequencies}  ${filter}
    ${NRB}  get from dictionary  ${Information}  NRB
    ${Min_guard}  get from dictionary  ${Information}  Min_guard
    ${NrarfcnStep_3gpp}  get from dictionary  ${Information}  NrarfcnStep_3gpp
    [Return]  ${NRB}  ${Min_guard}  ${NrarfcnStep_3gpp}

Get MinFreq And MaxFreq From BPF
    [Arguments]  ${band_num}  ${ru_index}=1  ${variable_from_CFAM}=${Variables_CFAM}
    ${bpf_content}   verify content of BPF file    variable_from_CFAM=${variable_from_CFAM}    ru_index=${ru_index}
    ${Freq_bpf_list}   Get regexp matches    ${bpf_content}
    ...    <complex><p Name="Band">${band_num}</p><p Name="Min.Frequency">(\\d+\.?\\d)</p><p Name="Max.Frequency">(\\d+\.?\\d)</p></complex>
    ...    1    2
    ${Freq_Min_Max}    set variable    ${Freq_bpf_list}[0]
    set test variable    ${MinFreq_bpf}    ${Freq_Min_Max[0]}
    set test variable    ${MaxFreq_bpf}    ${Freq_Min_Max[1]}

get nrarfcn boudary values
    [Arguments]  ${radio_type}=${ru_type_init}  ${variable_from_CFAM}=${Variables_CFAM}
    Log to console    radio_type: ${radio_type}
    log to console    \n***get nrarfcn boudary values***
    ${band_minNrarfcn}  ${band_maxNrarfcn}  get nrarfcn range band boundary frequency
    ${minNrarfcn_pbf}  ${maxNrarfcn_pbf}  ${NrarfcnStep_3gpp}  get nrarfcn range from TX/RX frequency
    ...    band_num=${band_num}  radio_type=${ru_type_init}  variable_from_CFAM=${variable_from_CFAM}
    ${band_minNrarfcn}  ${band_maxNrarfcn}  ${minNrarfcn_validateErr}  ${maxNrarfcn_validateErr}
    ...    get nrarfcn out of band boundary from 3gpp
    ...    band_minNrarfcn=${band_minNrarfcn}  band_maxNrarfcn=${band_maxNrarfcn}  NrarfcnStep_3gpp=${NrarfcnStep_3gpp}
    ${minNrarfcn_1900}  ${maxNrarfcn_1900}  get nrarfcn out of TX/RX frequency range
    ...    minNrarfcn_pbf=${minNrarfcn_pbf}  maxNrarfcn_pbf=${maxNrarfcn_pbf}  NrarfcnStep_3gpp=${NrarfcnStep_3gpp}
    set test variable  ${band_minNrarfcn}
    set test variable  ${band_maxNrarfcn}
    set test variable  ${minNrarfcn_validateErr}
    set test variable  ${maxNrarfcn_validateErr}
    set test variable  ${minNrarfcn_1900}
    set test variable  ${maxNrarfcn_1900}
    set test variable  ${NrarfcnStep_3gpp}

get RF configuration from M-Plane (OAM)
    [Arguments]  ${ru_index}=1
    log to console    \n get RF configuration from M-Plane (OAM)
    &{hw_info}       coam.get_detected_hw_info    connection=GNB_OAM
    ${rmod_info}    set variable    ${hw_info.radioModules.rmod}
    ${rmod_num}    get length  ${rmod_info}
    FOR  ${rmod_index}    IN RANGE    ${rmod_num}
        log to console    ${rmod_info[${rmod_index}].id.configuration}
        ${status}  run keyword and return status    should contain    ${rmod_info[${rmod_index}].id.configuration}    RMOD-${ru_index}
        exit for loop if  ${status}
    END
    ${pCode_oam}    set variable    ${hw_info.radioModules.rmod[${rmod_index}].productCode}    # 474877A.X21
    ${pName_oam}    set variable    ${hw_info.radioModules.rmod[${rmod_index}].productName}    # AWHQG
    ${serNum_oam}   set variable    ${hw_info.radioModules.rmod[${rmod_index}].serialNumber}   # EB193764266
    @{tmp}          split string    ${pCode_oam}    separator=.
    ${hwVer_oam}    set variable    ${tmp}[-1]       # X21
    [Return]  ${pCode_oam}  ${pName_oam}  ${serNum_oam}  ${hwVer_oam}

get RF configuration from spec
    [Arguments]  ${ru_index}=1
    ${bpf_content}   verify content of BPF file   variable_from_CFAM=${Variables_CFAM}    ru_index=${ru_index}
    ${xml handler}=    ParseXML.Parse Xml    ${bpf_content}
    @{prodCode_tmp}    ParseXML.Get Elements Texts    ${xml handler}
    ...    xpath=.//p[@Name="Visible.Product.Code"]
    @{prodCode_tmp2}    ParseXML.Get Elements Texts    ${xml handler}
    ...    xpath=.//complex[@Name="Visible.Product.Code"]/p
    ${prodCode_num}   Get Length   ${prodCode_tmp}
    ${prodCode}   set variable if      ${prodCode_num}!=${0}    ${prodCode_tmp}[0]    ${prodCode_tmp2}[0]
    @{unitType_tmp}    ParseXML.Get Elements Texts    ${xml handler}
    ...    xpath=.//unitType
    @{variant_tmp}    ParseXML.Get Elements Texts    ${xml handler}
    ...    xpath=.//variant
    ${pName_expect}    Catenate   SEPARATOR=   ${unitType_tmp[0]}    ${variant_tmp[0]}
    @{NRFreqBand_expect}    ParseXML.Get Elements Texts    ${xml handler}
    ...    xpath=.//list[@Name="NR.Frequency.Band"]/p
    @{NRFreqBands}    Create List
    FOR    ${NRFreqBand}    IN    @{NRFreqBand_expect}
           ${NRFreqBand_expect}    Catenate   SEPARATOR=   n   ${NRFreqBand}
           Append To List    ${NRFreqBands}    ${NRFreqBand_expect}
    END
    [Return]  ${prodCode}  ${pName_expect}  ${NRFreqBands}

generate nrarfcn gscn modify parameters
    [Arguments]  ${nrarfcn}  ${gscn}  ${cell_id}=1
    ${stream}    get stream from version    ${Active_SW_version}
    ${gscn_filter}=    Set Variable If     '${stream}'=='SBTS21B'    Global synchronization channel number
    ...     Synchronization channel number
    ${gscn_pname}=    Set Variable If     '${stream}'=='SBTS21B'    gscn    gscnOrSsPbchArfcn
    ${modify_params}  create list
    ${item}  create dictionary  dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-${cell_id}
    ...    filter_param=NR Absolute radio frequency channel number  p_name=nrarfcn  value=${nrarfcn}
    append to list  ${modify_params}  ${item}
    ${item}  create dictionary  dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-${cell_id}
    ...    filter_param=${gscn_filter}  p_name=${gscn_pname}  value=${gscn}
    append to list  ${modify_params}  ${item}
    [Return]  ${modify_params}

get nrarfcn range band boundary frequency
#    ${band_minNrarfcn}     Evaluate    (${Min_band}-${FREF_Offs})*1000/${Delta_F_Global}+${NREF_Offs}
#    ${band_maxNrarfcn}     Evaluate    (${Max_Band}-${FREF_Offs})*1000/${Delta_F_Global}+${NREF_Offs}
    ${band_minNrarfcn}     calculate_N    F_REF=${Min_band}    global_frequency_raster=${global_frequency_raster}
    ${band_maxNrarfcn}     calculate_N    F_REF=${Max_Band}    global_frequency_raster=${global_frequency_raster}
    ${band_minNrarfcn}=    Evaluate    math.ceil(${band_minNrarfcn})   math  #round up
    ${band_maxNrarfcn}=    Evaluate    math.floor(${band_maxNrarfcn})   math  #round up
    ${band_minNrarfcn}=    Evaluate    int(${band_minNrarfcn})
    ${band_maxNrarfcn}=    Evaluate    int(${band_maxNrarfcn})
    log to console       \nrarfcn in band range: ${band_minNrarfcn} .. ${band_maxNrarfcn}
    [Return]  ${band_minNrarfcn}  ${band_maxNrarfcn}

Get Parameters From NR_Frequencies_Band
    ${output}  get RF configuration from webui
    ${band_type}  set variable  ${output[5]}
    ${band_num}  get substring    ${band_type}    start=1
    ${frequency_parameters}    get_frequency_parameters    band=${band_type}
    set test variable    ${band_num}
    Set Test Variable    ${Min_band}    ${frequency_parameters[0]}
    Set Test Variable    ${Max_Band}    ${frequency_parameters[1]}
    set test variable    ${global_frequency_raster}    ${frequency_parameters[2]}

get nrarfcn range from TX/RX frequency
    [Arguments]   ${band_num}  ${radio_type}=${ru_type_init}  ${variable_from_CFAM}=${Variables_CFAM}
    Get MinFreq And MaxFreq From BPF    ${band_num}    variable_from_CFAM=${variable_from_CFAM}
    ${MinFreq_bpf}=    Evaluate    math.ceil(${MinFreq_bpf})   math
    ${MaxFreq_bpf}=    Evaluate    math.ceil(${MaxFreq_bpf})   math
    ${bandwidth}  ${scs}  ${ssb}  get band scs ssb
    ${NRB}  ${Min_guard}  ${NrarfcnStep_3gpp}  Get NR Frequencies Info  ${bandwidth}  ${scs}  ${ssb}
    ${MinFreq}  ${MaxFreq}  calculate_maxfreq_and_minfreq  ${radio_type}  ${MinFreq_bpf}  ${MaxFreq_bpf}  ${NRB}  ${scs}  ${Min_guard}  ${bandwidth}

    ${minNrarfcn_pbf}     calculate_N    F_REF=${MinFreq}    global_frequency_raster=${global_frequency_raster}
    ${maxNrarfcn_pbf}     calculate_N    F_REF=${MaxFreq}    global_frequency_raster=${global_frequency_raster}
#    ${minNrarfcn_pbf}=    Evaluate    (${MinFreq}-3000)*1000/15+600000            #630666.67
#    ${maxNrarfcn_pbf}=    Evaluate    (${MaxFreq}-3000)*1000/15+600000            #638666.67
    log to console       \n${radio_type} accurate working nrarfcn range: ${minNrarfcn_pbf} .. ${maxNrarfcn_pbf}
    ${minNrarfcn_pbf}=    Evaluate    math.ceil(${minNrarfcn_pbf})   math  #round up   #630667.0
    ${maxNrarfcn_pbf}=    Evaluate    math.floor(${maxNrarfcn_pbf})   math  #round up   #638667.0
    ${maxNrarfcn_pbf}=    Evaluate    int(${maxNrarfcn_pbf})
    ${minNrarfcn_pbf}=    Evaluate    int(${minNrarfcn_pbf})
    log to console       \n${radio_type} refined working nrarfcn range: ${minNrarfcn_pbf} .. ${maxNrarfcn_pbf}
    [Return]  ${minNrarfcn_pbf}  ${maxNrarfcn_pbf}  ${NrarfcnStep_3gpp}

get nrarfcn out of band boundary from 3gpp
    [Arguments]    ${band_minNrarfcn}  ${band_maxNrarfcn}  ${NrarfcnStep_3gpp}
    ${minNrarfcn_3gpp_tmp}=    Evaluate    int(${band_minNrarfcn}/${NrarfcnStep_3gpp})    # 620000/2= 310000
    ${maxNrarfcn_3gpp_tmp}=    Evaluate    int(${band_maxNrarfcn}/${NrarfcnStep_3gpp})    # 653332/2= 326666
    ${mod_min_3gpp}=    Evaluate        int(${band_minNrarfcn}-${minNrarfcn_3gpp_tmp}*${NrarfcnStep_3gpp})
    ${mod_max_3gpp}=    Evaluate        int(${band_maxNrarfcn}-${maxNrarfcn_3gpp_tmp}*${NrarfcnStep_3gpp})
    ${mod_min_3gpp_zero}=       Evaluate      int(${band_minNrarfcn}-${NrarfcnStep_3gpp})
    ${mod_min_3gpp_nonzero}=    Evaluate      int(${band_minNrarfcn}-${mod_min_3gpp})
    ${mod_max_3gpp_zero}=       Evaluate      int(${band_maxNrarfcn}+${NrarfcnStep_3gpp})
    ${mod_max_3gpp_nonzero}=    Evaluate      int(${band_maxNrarfcn}+(${NrarfcnStep_3gpp}-${mod_max_3gpp}))
    run keyword if    '${mod_max_3gpp}' == '0'
    ...    set test variable    ${maxNrarfcn_validateErr}    ${mod_max_3gpp_zero}    #############  653334
    ...    ELSE    set test variable    ${maxNrarfcn_validateErr}    ${mod_max_3gpp_nonzero}
    run keyword if    '${mod_min_3gpp}' == '0'
    ...    set test variable    ${minNrarfcn_validateErr}    ${mod_min_3gpp_zero}    #############  619998
    ...    ELSE    set test variable    ${minNrarfcn_validateErr}    ${mod_min_3gpp_nonzero}
    ${band_minNrarfcn}    evaluate    int(${minNrarfcn_validateErr}+${NrarfcnStep_3gpp})
    ${band_maxNrarfcn}    evaluate    int(${maxNrarfcn_validateErr}-${NrarfcnStep_3gpp})
    [Return]    ${band_minNrarfcn}    ${band_maxNrarfcn}    ${minNrarfcn_validateErr}    ${maxNrarfcn_validateErr}

get nrarfcn out of TX/RX frequency range
    [Arguments]    ${minNrarfcn_pbf}    ${maxNrarfcn_pbf}    ${NrarfcnStep_3gpp}
    #adjust range of min/max to meet 'min/max nrarfcn out of range'
    ${maxNrarfcn_pbf}=    Evaluate    int(${maxNrarfcn_pbf}+1)     #One more than max   #638668
    ${minNrarfcn_pbf}=    Evaluate    int(${minNrarfcn_pbf}-1)     #One less than min   #630666
    #In case of mod(nrarfcn,2) != 0
    ${maxNrarfcn_pbf_tmp}=    Evaluate    int(${maxNrarfcn_pbf}/${NrarfcnStep_3gpp})    # 638668/2= 319334
    ${minNrarfcn_pbf_tmp}=    Evaluate    int(${minNrarfcn_pbf}/${NrarfcnStep_3gpp})    # 630666/2= 315333
    ${mod_max}=    Evaluate        int(${maxNrarfcn_pbf}-${maxNrarfcn_pbf_tmp}*${NrarfcnStep_3gpp})
    ${mod_min}=    Evaluate        int(${minNrarfcn_pbf}-${minNrarfcn_pbf_tmp}*${NrarfcnStep_3gpp})
    ${mod_max_zero}    set variable      ${maxNrarfcn_pbf}
    ${mod_max_nonzero}=    Evaluate      int(${maxNrarfcn_pbf}+(${NrarfcnStep_3gpp}-${mod_max}))
    ${mod_min_zero}    set variable      ${minNrarfcn_pbf}
    ${mod_min_nonzero}=    Evaluate      int(${minNrarfcn_pbf}-${mod_min})
    run keyword if    '${mod_max}' == '0'
    ...    set test variable    ${maxNrarfcn_1900}    ${mod_max_zero}    #############   638662
    ...    ELSE    set test variable    ${maxNrarfcn_1900}    ${mod_max_nonzero}
    run keyword if    '${mod_min}' == '0'
    ...    set test variable    ${minNrarfcn_1900}    ${mod_min_zero}
    ...    ELSE    set test variable    ${minNrarfcn_1900}    ${mod_min_nonzero}    #############  630666
    [Return]    ${minNrarfcn_1900}  ${maxNrarfcn_1900}

get gscn align with nrarfcn from 3gpp FR1
    [Arguments]    ${nrarfcn}
    ${F_REF}=    calculate_F    N_REF=${nrarfcn}    global_frequency_raster=${global_frequency_raster}
#   ${gscn}=    calculate_gscn    ss_ref=${F_REF}    fomular=${global_frequency_raster.GSCN_Fomular}
#to do alignment for n41 AWHHD
    ${gscn}=   Run keyword If   '${ru_type_init}'=='AWHHD'    calculate_gscn    ss_ref=${F_REF}    fomular=3*((ss_ref*1000-M*50)/1200)+(M-3)/2
    ...    ELSE    calculate_gscn    ss_ref=${F_REF}    fomular=${global_frequency_raster.GSCN_Fomular}
#to do alignment with 'GscnStep_3gpp'
    run keyword and ignore error    selenium_coam.refresh_page
    run keyword and ignore error    selenium_coam.disable_message_box
    run keyword and ignore error    selenium_coam.disable_screen_lock
    Sleep    20s
    ${output}  get RF configuration from webui
    ${bandType}  set variable  ${output[5]}
    ${GscnStep_3gpp}    Set variable if    '${bandType}'=='n41'    3
    ...    '${bandType}'=='n79'    16    1
#    ${GscnStep_3gpp}    Set variable if    '${band_num}'=='41'    3
#    ...    '${band_num}'=='79'    16    1
    ${gscn}=    Evaluate    math.floor(${gscn})    math
    ${mod_gscn}=    Evaluate    ${gscn}%${GscnStep_3gpp}
    ${mod_gscn}    Convert To Integer    ${mod_gscn}
    ${gscn_mod_nozero}=    Evaluate    ${gscn}-${mod_gscn}
    ${gscn}    Set variable if     '${mod_gscn}'=='0'     ${gscn}    ${gscn_mod_nozero}
    ${gscn}    convert to integer    ${gscn}
    [Return]    ${gscn}

get origin nraradcn and gscn
    [Arguments]  ${cell_id}=1
    ${stream}    get stream from version    ${Active_SW_version}
    ${gscn_filter}=    Set Variable If
    ...     '${stream}'=='SBTS21B'        Global synchronization channel number
    ...     Synchronization channel number
    ${gscn}    selenium_coam.Get Parameter Value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_id}
    ...    filter_param=${gscn_filter}
    ${nrarfcn}    selenium_coam.Get Parameter Value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_id}
    ...    filter_param=NR Absolute radio frequency channel number
    [Return]  ${nrarfcn}  ${gscn}

verify nrarfcn out of band boundary range
    [Arguments]  ${cell_id}=1
    log to console    \n***verify nrarfcn out of band boundary range***
    ######### out of min Band ##########
    log to console    \n***minNrarfcn_validateErr: ${minNrarfcn_validateErr}
    verify nrarfcn out of band boundary  Nrarfcn_validateErr=${minNrarfcn_validateErr}  band_Nrarfcn=${band_minNrarfcn}  cell_id=${cell_id}
    ######### out of max Band ##########
    log to console    \n***maxNrarfcn_validateErr: ${maxNrarfcn_validateErr}
    verify nrarfcn out of band boundary  Nrarfcn_validateErr=${maxNrarfcn_validateErr}  band_Nrarfcn=${band_maxNrarfcn}  cell_id=${cell_id}

verify nrarfcn out of TX/RX range
    [Arguments]  ${cell_id}=1    ${expected_faultid}=1900
    log to console    \n***verify nrarfcn out of TX/RX range***
    ######### out of min NRARFCN ##########
    log to console   \nout of min NRARFCN: ${minNrarfcn_1900}
    verify nrarfcn out of TX/RX  Nrarfcn_1900=${minNrarfcn_1900}  min_or_max=min  NrarfcnStep_3gpp=${NrarfcnStep_3gpp}  cell_id=${cell_id}
    ...    expected_faultid=${expected_faultid}
    ########## out of max NRARFCN ##########
    log to console   \nout of max NRARFCN: ${maxNrarfcn_1900}
    verify nrarfcn out of TX/RX  Nrarfcn_1900=${maxNrarfcn_1900}  min_or_max=max  NrarfcnStep_3gpp=${NrarfcnStep_3gpp}  cell_id=${cell_id}
    ...    expected_faultid=${expected_faultid}

verify nrarfcn out of band boundary
    [Arguments]    ${Nrarfcn_validateErr}    ${band_Nrarfcn}    ${cell_id}=1
    ${gscn}  get gscn align with nrarfcn from 3gpp FR1  nrarfcn=${Nrarfcn_validateErr}
    ${modify_params}  generate nrarfcn gscn modify parameters  nrarfcn=${Nrarfcn_validateErr}  gscn=${gscn}  cell_id=${cell_id}
    Modify Parameters On Webem  modify_params=${modify_params}  is_activate=${False}
    ${relErrs_dic}    run keyword and continue on failure    selenium_coam.get_relation_errors
    ${relErrs_str}    convert to string    ${relErrs_dic}
    ${nrarfcnRang_list}    Get Regexp matches    ${relErrs_str}    \\d+
    ${band_Nrarfcn}     convert to string  ${band_Nrarfcn}
    List Should Contain Value    ${nrarfcnRang_list}    ${band_Nrarfcn}
    selenium_coam.undo_changes

verify nrarfcn out of TX/RX
    [Arguments]  ${Nrarfcn_1900}  ${min_or_max}=min  ${NrarfcnStep_3gpp}=2  ${cell_id}=1    ${expected_faultid}=1900
    ${gscn}  get gscn align with nrarfcn from 3gpp FR1  nrarfcn=${Nrarfcn_1900}
    ${modify_params}  generate nrarfcn gscn modify parameters  nrarfcn=${Nrarfcn_1900}  gscn=${gscn}  cell_id=${cell_id}
    Modify Parameters In SCF From Webem And Commission  modify_params=${modify_params}
    sleep   60s
    #Check fault 1900(${expected_faultid}) on WebUI
    log to console    \nCheck fault ${expected_faultid}
    Wait Until Keyword Succeeds    5 min    5 sec    Connect to gnb coam via ssl
    Wait For Expect Fault Present  faultId=${expected_faultid}   timeout=1200
    Cell Should Be Disabled
    #recover with right NRARFCN
    ${Nrarfcn_recover}    run keyword if    '${min_or_max}' == 'min'    Evaluate     ${Nrarfcn_1900}+${NrarfcnStep_3gpp}
    ...                             ELSE    Evaluate     ${Nrarfcn_1900}-${NrarfcnStep_3gpp}
    ${Nrarfcn_recover_gscn}     get gscn align with nrarfcn from 3gpp FR1   nrarfcn=${Nrarfcn_1900}
    log to console    \nrecover with ${min_or_max} NRARFCN: ${Nrarfcn_recover} and gscn: ${Nrarfcn_recover_gscn}
    Close Start Up View    timeout=60
    ${modify_params}  generate nrarfcn gscn modify parameters  nrarfcn=${Nrarfcn_recover}  gscn=${Nrarfcn_recover_gscn}
    modify parameters on webem  modify_params=${modify_params}    timeout=180
    sleep   60s
    Wait Until Keyword Succeeds    5 min    5 sec    Connect to gnb coam via ssl
    Wait For Expect Fault To Disappear  faultId=${expected_faultid}   timeout=1200
    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type='${gNb_CuType}'

Get snapshot and return parsed RD files
    [Arguments]  ${connection}=GNB_OAM
    ${time}=    robot.libraries.DateTime.Get Current Date    result_format=%Y%m%d-%H%M%S
    set suite variable    ${snapshot_path}    /home/ute/Downloads/s${time}/Snapshot_${time}.zip
    set suite variable    ${unzipped}    /home/ute/Downloads/s${time}
    set suite variable    ${unzipped_PM}    ${unzipped}/PM
    coam.get_snapshot    target_file_name=${snapshot_path}   timeout=480    connection=${connection}
    OperatingSystem.Run    unzip ${snapshot_path} -d ${unzipped}
    ${files}=    OperatingSystem.Run    ls /home/ute/Downloads/s${time}/ | grep _1011_part_
    @{files_list}=    Split String    ${files}    \n
    ${num_of_files}    Get Length    ${files_list}
    ${PM_file}=    Get Lines Containing String    ${files}    _1011_part_${num_of_files}
    OperatingSystem.Run    unzip ${unzipped}/${PM_file} -d ${unzipped_PM}
    ${RD_files}=    OperatingSystem.Run    ls ${unzipped}/PM | grep RD.BTS
    @{RD_files_list}=    Split String    ${RD_files}    \n
    ${parsed_files}=    Extract and parse RD files    ${RD_files_list}    ${unzipped_PM}
    [Return]     ${parsed_files}

Extract and parse RD files
    [Arguments]    ${RD_files_list}    ${unzipped_PM}
    FOR    ${file}    IN    @{RD_files_list}
        Run    gzip -d ${unzipped_PM}/${file}
        ${extracted_file}    Fetch From Left    ${file}    .gz
        ${parsed_files}    ParseXML.Parse Xml    ${unzipped_PM}/${extracted_file}
    END
    [Return]    ${parsed_files}

Check counters from SFP monitoring- file iteration
    [Arguments]    ${parsed_files}    ${MOD_SFP_dict}    ${measurementType}
    FOR    ${file}    IN    @{parsed_files}
        ${MOD_list}    Get Dictionary Keys    ${MOD_SFP_dict}
        Check counters from SFP monitoring- MOD iteration    ${MOD_SFP_dict}    ${MOD_list}    ${file}    ${measurementType}
    END

Check counters from SFP monitoring- MOD iteration
    [Arguments]    ${MOD_SFP_dict}    ${MOD_list}    ${file}    ${measurementType}
    FOR    ${MOD}    IN    @{MOD_list}
        @{SFP_list}    Get From Dictionary    ${MOD_SFP_dict}    ${MOD}
        Check counters from SFP monitoring- SFP iteration    ${MOD_SFP_dict}    ${MOD}    ${file}    ${measurementType}    ${SFP_list}
    END

Check counters from SFP monitoring- SFP iteration
    [Arguments]    ${MOD_SFP_dict}    ${MOD}    ${file}    ${measT}    ${SFP_list}
    Log to console    MOD_SFP_dict: ${MOD_SFP_dict}
    FOR    ${SFP}    IN    @{SFP_list}
        ${TEMPERATURE}    ParseXML.Get Element Text    ${file}
        ...    //*[*/DN/text()="PLMN-PLMN/${MOD}/${SFP}"]/*[@measurementType="${measT}"]/${measT}_TEMPERATURE
        ${XCVR_TX_SUPPLY_VOLTAGE}    ParseXML.Get Element Text    ${file}
        ...    //*[*/DN/text()="PLMN-PLMN/${MOD}/${SFP}"]/*[@measurementType="${measT}"]/${measT}_XCVR_TX_SUPPLY_VOLTAGE
        ${XCVR_TX_BIAS_CURRENT}    ParseXML.Get Element Text    ${file}
        ...    //*[*/DN/text()="PLMN-PLMN/${MOD}/${SFP}"]/*[@measurementType="${measT}"]/${measT}_XCVR_TX_BIAS_CURRENT
        ${XCVR_TX_PWR}    ParseXML.Get Element Text    ${file}
        ...    //*[*/DN/text()="PLMN-PLMN/${MOD}/${SFP}"]/*[@measurementType="${measT}"]/${measT}_XCVR_TX_PWR
        ${XCVR_RX_OPT_PWR}    ParseXML.Get Element Text    ${file}
        ...    //*[*/DN/text()="PLMN-PLMN/${MOD}/${SFP}"]/*[@measurementType="${measT}"]/${measT}_XCVR_RX_OPT_PWR
        Should Be True    -128<=${TEMPERATURE}<=128
        Should Be True    0<=${XCVR_TX_SUPPLY_VOLTAGE}<=100
        Should Be True    0<=${XCVR_TX_BIAS_CURRENT}<1000
        Should Be True    -100<=${XCVR_TX_PWR}<=100
        Should Be True    -100<=${XCVR_RX_OPT_PWR}<=100
    END

Modify pMax to tirgger fault
    [Arguments]  ${cell_id}=1    ${ru_index}=1    ${variable_from_CFAM}=${Variables_CFAM}
    log to console    \n***Modify pMax to tirgger fault***
    ${modify_params}  create list
    Connect to gnb coam via ssl
    ${bpf_content}   verify content of BPF file    variable_from_CFAM=${variable_from_CFAM}    ru_index=${ru_index}
    ${xml handler}=    ParseXML.Parse Xml    ${bpf_content}
    ${MaxPapower_list}    ParseXML.Get Elements Texts    ${xml handler}
    ...    xpath=.//list[@Name="Tx.Carrier.Max.Pa.Power"]/p
    Collections.Sort List    ${MaxPapower_list}
    set test variable    ${MaxPower}    ${MaxPapower_list}[-1]
    ${MaxPapower_list_5G}    ParseXML.Get Elements Texts    ${xml handler}
    ...    xpath=.//list[@Name="Tx.Carrier.Max.Pa.Power.5G"]/p
    Collections.Sort List    ${MaxPapower_list_5G}
    ${Len}=    Get Length    ${MaxPapower_list_5G}
    ${MaxPower}    Set Variable If    '${len}'!='0'    ${MaxPapower_list_5G}[-1]    ${MaxPower}
    #PowerAllocated <= 10*log10(PowerRated*1000)+DLPowerAccuracy; DLPowerAccuracy is set 0.1dB #PR509046
    ${MaxPower} =    Evaluate    ${MaxPower} + 0.1
    set test variable    ${MinPower}    ${MaxPapower_list}[0]
    ${pMax_modify_f} =    Evaluate    ${MaxPower} + 0.1
    ${pMax_modify}    convert to string    ${pMax_modify_f}
    ${modify_params}  create list
    ${item}  create dictionary  dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-${cell_id}  filter_param=Maximum output power
    ...  p_name=pMax  value=${pMax_modify}
    append to list  ${modify_params}  ${item}
    ${orig_value}    get origin pmax    cell_id=${cell_id}
    ${origin_params}  create list
    ${new_item}  create dictionary  dist_name=${item}[dist_name]
    ...    filter_param=${item}[filter_param]  p_name=${item}[p_name]  value=${orig_value}
    append to list  ${origin_params}  ${new_item}
    Modify Parameters On Webem  ${modify_params}    despite_errors=${True}
    [Return]  ${origin_params}

Modify_Three_Parameter_for_CB007331
    [Arguments]    ${gnb_index}=${0}     ${carriermode}=true    ${iqcompression}=9bits    ${actdownsampling}=true
    ...    ${connection}=GNB_OAM
    Selenium Login And Disable Screen Lock    gnb_index=${gnb_index}
    ${cables_info_list}    Get Cablink Info List    connection=${connection}
    ${cell_info_list}    Get All Cells Status Info    cell_type=nr    connection=${connection}
    ${modify_params}    Get CB007331 modify parameters list    cables_info_list=${cables_info_list}
    ...    cell_info_list=${cell_info_list}     carriermode=${carriermode}    iqcompression=${iqcompression}
    ...    actdownsampling=${actdownsampling}
    Modify Parameters On Webem    modify_params=${modify_params}
    [Teardown]  Selenium Logout And Close Browser

unlock Baseband module via WEBUI
    [Arguments]  ${bbmod_index_list}
    FOR  ${bbmod_index}  IN  @{bbmod_index_list}
        selenium_coam.unlock_baseband    baseband_idx=${bbmod_index}
        Wait Until Keyword Succeeds    5min    10s    bbmod Should Be unLocked    bbmod_index=${bbmod_index}
    END

update_parameter_manualFrameTimingAdjustment
    [Documentation]    Author: lanwen.cai@nokia-sbell.com
    [Arguments]   ${dist_name}=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/SYNC-1    ${filter_param}=Manual frame timing adjustment
    ...    ${new_value}=${1948.96}    ${download_dir}=${TS_CASE_LOG_PATH}
    Log to console    Update parameter manualFrameTimingAdjustment
    COAM Navigate to login page via webUI    download_dir=${download_dir}
    Close Start Up View    timeout=60
    Log to console    Update manualFrameTimingAdjustment value to ${new_value}
    selenium_coam.set_parameter_value    dist_name=${dist_name}    filter_param=${filter_param}     new_value=${new_value}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${True}
    sleep    10s
    wait until keyword succeeds    10 min    2sec    Connect to gnb coam via ssl
    Wait until keyword succeeds    10 min    5sec    COAM Check GNB RU status
    Wait until keyword succeeds    15 min    20 sec   verify all cells should be onair
    [Teardown]    Selenium Logout And Close Browser

Gnb Cpri Ecpri Switch
    [Documentation]    Auther: tingting.zhong@nokia-sbell.com
    [Arguments]    ${current_pkg}
    selenium login and disable screen lock
    Delete CMD Object If Exist
    ${ru_index_list}  Get All RU Index
    ${link_speed}    ${radio_protocol_type}    Get Cpri Ecpri Switch Params
    Add PRTCLCHGRES Object Via Webem   ru_index_list=${ru_index_list}   link_speed=${link_speed}
    ...    radio_protocol_type=${radio_protocol_type}
    log to console  start check fault 23 appear
    Wait For Expect Fault Present    faultId=23   timeout=600
    log to console  upload current version package and activate: ${current_pkg}
    Perform SW Update  ${SAVE LOG DIRECTORY}${current_pkg}
    sleep  360
    Wait Until Keyword Succeeds    10min    360s    Check HW modules detection
    log to console  start check fault 23 disappear
    Wait For Expect Fault To Disappear  faultId=23   timeout=600
    Validate Check on WebUI
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
    Check Protocol Change Result Via Webem
    Delete CMD Object If Exist
    Selenium Logout And Close Browser
    ${radio_protocol_after_switch}    get_radio_protocal_via_admin
    ${scf_file_backup}    COAM Download scf from cluster  scf_dir_path=${SAVE LOG DIRECTORY}
    log to console  after swicth to ${radio_protocol_after_switch},back up SCF PATH:${scf_file_backup}
    ${5793_SCF2}   run keyword if    '${radio_protocol_after_switch}'=='CPRI'
    ...    Replace String    ${Case_SCF_Path}    .xml    _5793_CPRI.xml
    run keyword if    '${radio_protocol_after_switch}'=='CPRI'
    ...    run keywords  COAM Commission with scf file  scf_file_path=${5793_SCF2}    AND
    ...    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
