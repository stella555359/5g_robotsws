*** Settings ***
Documentation  TTI trace collector and decoder


Library     tti.py
Library     taf.transport.ssh    WITH NAME    ssh

*** Keywords ***
Start TTI trace streaming
    tti.start_tti_traces_in_streaming_mode

Stop TTI trace
    [Arguments]  ${output_file_format}=json  ${decoded_output_file}=${None}
    tti.stop_tti_traces_in_streaming_mode  output_file_format=${output_file_format}  decoded_output_file=${decoded_output_file}

Check bler based on ttitrace legacycsv
    [Arguments]  ${bler_percent}=10
    ${output}=  tti.check_bler  ${bler_percent}
    Should Be True  ${output}

Check number of layers legacycsv
    [Arguments]  ${numOfLayersUl}=2   ${numOfLayersDl}=4
    ${output}=  tti.check_numOfLayers  ${numOfLayersUl}  ${numOfLayersDl}
    Should Be True  ${output}

Check mcs on tti legacycsv
    [Arguments]  ${mcs_level}=21
    ${output}=  tti.check_mcs   ${mcs_level}
    Should Be True  ${output}

Check modulation on tti legacycsv
    [Arguments]  ${expected_modulation}=256  ${traffic_type}=uldl
    ${output}=  tti.check_modulation  ${expected_modulation}  ${traffic_type}
    Should Be True  ${output}

Check bler based on ttitrace
    [Arguments]  ${threshold}=10  ${traffic_type}=uldl  ${decoded_output_file}=${None}
    ${output}=  tti.check_bler_json  ${threshold}  ${traffic_type}  ${decoded_output_file}
    Should Be True  ${output}

Check number of layers
    [Arguments]  ${numOfLayersUl}=2   ${numOfLayersDl}=4  ${treshold_dl}=80  ${traffic_type}=uldl
    ${output}=  tti.check_num_of_layers_json  ${numOfLayersUl}  ${numOfLayersDl}  ${treshold_dl}  ${traffic_type}
    Should Be True  ${output}

Check mcs on tti
    [Arguments]  ${treshold_ul}=90  ${treshold_dl}=95  ${traffic_type}=uldl  ${mcs_level}=21
    ${output}=  tti.check_mcs_json  ${treshold_ul}  ${treshold_dl}  ${traffic_type}  ${mcs_level}
    Should Be True  ${output}

Check modulation on tti
    [Arguments]  ${expected_modulation}=256  ${threshold}=95  ${traffic_type}=uldl
    ${output}=  tti.check_modulation_json  ${expected_modulation}  ${threshold}  ${traffic_type}
    Should Be True  ${output}

Check rach based on ttitrace
    [Arguments]  ${decoded_output_file}=None
    ${output}=  tti.check_rach_based_on_ttitrace_json  ${decoded_output_file}
    Should Be True  ${output}

Check beam pattern based on ttitrace
    [Arguments]  ${beam_template}=${None}  ${decoded_output_file}=${None}  ${lower_treshold}=${37}  ${higher_treshold}=${46}
    ${output}=  tti.check_beam_pattern_based_on_ttitrace_json  ${beam_template}  ${decoded_output_file}  ${lower_treshold}  ${higher_treshold}
    Should Be True  ${output}

Check muMimoSchedData
    [Arguments]   ${should_exist}=True
    ${should_exist}=  Convert To Boolean  ${should_exist}
    ${output}=  tti.check_muMimoSchedData_exist  ${should_exist}
    Should Be True  ${output}

Check prb
    [Arguments]   ${actDlMuMimo}=False  ${numOfUEs}=2
    ${actDlMuMimo}=  Convert To Boolean  ${actDlMuMimo}
    ${output}=  tti.check_prb_json  ${actDlMuMimo}  ${numOfUEs}
    Should Be True  ${output}

Chack ue paired
    ${output}=  tti.check_ue_paired
    Should Be True  ${output}

Check beamId for rntis and verified
    ${output}=  tti.check_beamId_for_rntis
    Should Be True  ${output}

Check dlfdscheddata mupair exist ttitrace
    [Arguments]  ${decoded_output_file}=${None}
    ${output}=  tti.check_dlfdscheddata_mupair_exist_in_ttitrace  ${decoded_output_file}
    Should Be True  ${output}  Lack of MUPAIR value in messages dlFdSchedData.muStatus

Check dlfdscheddata mupair not exist ttitrace
    [Arguments]  ${decoded_output_file}=${None}
    ${output}=  tti.check_dlfdscheddata_mupair_exist_in_ttitrace  ${decoded_output_file}
    Should Be True  not ${output}  MUPAIR value exist in messages dlFdSchedData.muStatus

Check selected BeamId
    [Arguments]  ${best}=33  ${second}=25
    ${output}=  tti.check_selected_BeamId_tti  ${best}   ${second}
    Should Be True  ${output}

Check ulSrsBm BestBeamPatternId
    ${output}=  tti.check_ulSrsBm_tti
    Should Be True  ${output}
