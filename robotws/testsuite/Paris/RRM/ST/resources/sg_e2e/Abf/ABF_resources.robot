*** Settings ***
Library         String
Library         Collections
Library         ${CURDIR}/../../myLib_maths.py

*** Keywords ***
SSB Auto Mapping
    [Documentation]  Find SSB BeamSet configuration for beamforming traces analysis
    [Tags]    DEBUG
    [Arguments]      ${beamSetAbf}=beamSetAbf_32A

    @{SSB_id}    Create list    0x00000001    0x00000003    0x00000005    0x00000007    0x0000000b    0x0000000d    0x0000000f    0x00000011

    ${cmd}      catenate
    ...         cat ${CURDIR}/ABF_BeamSet_PatternID
    ...         | grep -E ${beamSetAbf}
    ${res}      Run       ${cmd}
    @{lines}    Split To Lines      ${res}
    @{bss}      Split String    @{lines}[0]    separator=;
    @{bs}       Create List

    :FOR    ${index}    IN RANGE    7    39
    \     ${var}=    myLib_maths.formated_hex_string_v2    @{bss}[${index}]
	\     Append To List    ${bs}    ${var}
    log     ${bs}
    # ${pb}       set variable        7

    :FOR    ${index}    IN RANGE    0    8
    \     ${pb}       Evaluate       ${index}*4
    \     ${cmd}      catenate      SEPARATOR=          cat ${logs_path}/pcapprocessedPatterns.txt | grep -E 'ICOM_5G/
          ...         DlData_PatternConfigReq,@{SSB_id}[${index}],((.*)(@{bs}[${pb}]){2}){2}((.*)(@{bs}[${${pb}+1}]){2}){2}((.*)
          ...         (@{bs}[${${pb}+2}]){2}){2}((.*)(@{bs}[${${pb}+3}]){2}){2}' -c
    \     ${nb_pattern_specific}      Run      ${cmd}
    \     ${nb_pattern_specific}      Convert to Number   ${nb_pattern_specific}  2
    \     log to console      ${nb_pattern_specific} SSB slot @{SSB_id}[${index}] -> @{bs}[${pb}], @{bs}[${${pb}+1}], @{bs}[${${pb}+2}],
          ...             @{bs}[${${pb}+3}]
    \     ${cmd}      catenate      SEPARATOR=    cat ${logs_path}/pcapprocessedPatterns.txt | grep -E 'ICOM_5G/DlData_PatternConfigReq,
          ...           @{SSB_id}[${index}]     ,' -c
    \     ${nb_pattern}               Run      ${cmd}
    \     ${nb_pattern}      Convert to Number   ${nb_pattern}  2
    \     ${result}                   Evaluate   ${nb_pattern}/${nb_pattern_specific}
    \     Should Be True              1.8 < ${result} < 2.2


pRACH Auto Mapping
    [Documentation]  check patternId during pRACH slot every SFN During 8 SFN to cover 32 patternId for every
    ...              for beamforming
    [Tags]    DEBUG
    [Arguments]      ${beamSetAbf}=beamSetAbf_32A

    @{pRach}    Create list    0x00000009  0x00000013  0x0000001d  0x00000027  0x00000031  0x0000003b  0x00000045  0x0000004f  0x00000009
    ...                        0x00000013  0x0000001d

    ${cmd}      catenate
    ...         cat ${CURDIR}/ABF_BeamSet_PatternID
    ...         | grep -E ${beamSetAbf}
    ${res}      Run       ${cmd}
    @{lines}    Split To Lines      ${res}
    @{bss}      Split String    @{lines}[0]    separator=;
    @{bs}       Create List

    :FOR    ${index}    IN RANGE    7    39
    \     ${var}=    myLib_maths.formated_hex_string_v2    @{bss}[${index}]
	\     Append To List    ${bs}    ${var}

	Append To List    ${bs}    ffff
    log     ${bs}

    :FOR   ${index}    IN RANGE    0    11
    \     ${pb}       Evaluate       ${index}*3
    \     ${cmd}      catenate      SEPARATOR=          cat ${logs_path}/pcapprocessedPatterns.txt | grep -E 'ICOM_5G/
          ...         DlData_PatternConfigReq,@{pRach}[${index}],((@{bs}[${pb}]){2}(ff){12},){4}((@{bs}[${${pb}+1}]){2}(ff){12},){4}
          ...         ((@{bs}[${${pb}+2}]){2}(ff){12},){4}' -c
    \     ${nb_pattern_specific}      Run      ${cmd}
    \     ${nb_pattern_specific}      Convert to Number   ${nb_pattern_specific}  2
    \     log to console      ${nb_pattern_specific} RACH slot @{pRach}[${index}] -> @{bs}[${pb}], @{bs}[${${pb}+1}], @{bs}[${${pb}+2}],
    \     ${cmd}      catenate      SEPARATOR=    cat ${logs_path}/pcapprocessedPatterns.txt | grep -E 'ICOM_5G/
          ...         DlData_PatternConfigReq,@{pRach}[${index}],' -c
    \     ${nb_pattern}               Run      ${cmd}
    \     ${nb_pattern}      Convert to Number   ${nb_pattern}  2
    \     ${result}                   Evaluate   ${nb_pattern}/${nb_pattern_specific}
    \     Should Be True              3.8 < ${result} < 4.2

