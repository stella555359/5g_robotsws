*** Settings ***
Documentation
...               NR-ARFCN CHECK DEDICATE FOR considering filterBandwidth

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot

*** Variables ***
${filterBandwidth}    1   #Unit: MHz

*** Keywords ***
General_SiSo_NR-ARFCN_check_with_filterBandwidth
    [Arguments]  ${cell_id}=1  ${radio_type}=${ru_type_init}
    Selenium Login And Disable Screen Lock
    ${nrarfcn}  ${gscn}  get origin nraradcn and gscn    cell_id=${cell_id}
    set test variable  ${nrarfcn}
    set test variable  ${gscn}
    ${origin_params}  generate nrarfcn gscn modify parameters   nrarfcn=${nrarfcn}   gscn=${gscn}    cell_id=${cell_id}
    Get Parameters From NR_Frequencies_Band
    get nrarfcn boudary values_with_filterBandwidth  radio_type=${ru_type_init}
    verify nrarfcn out of band boundary range  cell_id=${cell_id}
    verify nrarfcn out of TX/RX range  cell_id=${cell_id}
    Close Start Up View    timeout=60
    modify parameters on webem  modify_params=${origin_params}
    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type='${gNb_CuType}'
    [Teardown]  Selenium Logout And Close Browser

get nrarfcn boudary values_with_filterBandwidth
    [Arguments]  ${radio_type}=${ru_type_init}
    log to console    \n***get nrarfcn boudary values***
    ${band_minNrarfcn}  ${band_maxNrarfcn}  get nrarfcn range band boundary frequency
    ${minNrarfcn_pbf}  ${maxNrarfcn_pbf}  ${NrarfcnStep_3gpp}  get nrarfcn range from TX/RX frequency_with_filterBandwidth
    ...    band_num=${band_num}  radio_type=${ru_type_init}
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

get nrarfcn range from TX/RX frequency_with_filterBandwidth
    [Arguments]   ${band_num}  ${radio_type}=${ru_type_init}
    Get MinFreq And MaxFreq From BPF    ${band_num}
    ${MinFreq_bpf}=    Evaluate    math.ceil(${MinFreq_bpf})   math
    ${MaxFreq_bpf}=    Evaluate    math.ceil(${MaxFreq_bpf})   math
    ${bandwidth}  ${scs}  ${ssb}  get band scs ssb
    ${NRB}  ${Min_guard}  ${NrarfcnStep_3gpp}  Get NR Frequencies Info  ${bandwidth}  ${scs}  ${ssb}
    ${MinFreq}  ${MaxFreq}  Calculate MaxFreq And MinFreq  ${radio_type}  ${MinFreq_bpf}  ${MaxFreq_bpf}  ${NRB}  ${scs}
    ...    ${Min_guard}  ${bandwidth}

#   Do alignment with filterBandwidth but not HW Cap. (i.e. MinFreq==3749(3699+50) which is less than min HW cap. 3700-50=3749MHz)
#    ${MinHWCentFreq}=    Evaluate    ${MinFreq_bpf}+${bandwidth}/2
#    ${MaxHWCentFreq}=    Evaluate    ${MaxFreq_bpf}-${bandwidth}/2
#    ${MinFreq}    set variable if    "${MinFreq}" < "${MinHWCentFreq}"    ${MinHWCentFreq}    ${MinFreq}
#    ${MaxFreq}    set variable if    "${MaxFreq}" > "${MaxHWCentFreq}"    ${MaxHWCentFreq}    ${MaxFreq}

    ${MinFreq_filterBW}=    Evaluate    ${MinFreq}-${filterBandwidth}
    ${MaxFreq_filterBW}=    Evaluate    ${MaxFreq}+${filterBandwidth}
    set test variable    ${MinFreq}    ${MinFreq_filterBW}
    set test variable    ${MaxFreq}    ${MaxFreq_filterBW}

    ${minNrarfcn_pbf}     calculate_N    F_REF=${MinFreq}    global_frequency_raster=${global_frequency_raster}
    ${maxNrarfcn_pbf}     calculate_N    F_REF=${MaxFreq}    global_frequency_raster=${global_frequency_raster}
#    ${minNrarfcn_pbf}=    Evaluate    (${MinFreq}-3000)*1000/15+600000            #630666.67
#    ${maxNrarfcn_pbf}=    Evaluate    (${MaxFreq}-3000)*1000/15+600000            #638666.67
    log to console       \n${radio_type} accurate working nrarfcn range: ${minNrarfcn_pbf} .. ${maxNrarfcn_pbf}
    ${minNrarfcn_pbf}=    Evaluate    math.ceil(${minNrarfcn_pbf})   math  #round up   #630667.0
    ${maxNrarfcn_pbf}=    Evaluate    math.floor(${maxNrarfcn_pbf})   math  #round down   #638666.0
    ${maxNrarfcn_pbf}=    Evaluate    int(${maxNrarfcn_pbf})
    ${minNrarfcn_pbf}=    Evaluate    int(${minNrarfcn_pbf})
    log to console       \n${radio_type} refined working nrarfcn range: ${minNrarfcn_pbf} .. ${maxNrarfcn_pbf}
    [Return]  ${minNrarfcn_pbf}  ${maxNrarfcn_pbf}  ${NrarfcnStep_3gpp}
