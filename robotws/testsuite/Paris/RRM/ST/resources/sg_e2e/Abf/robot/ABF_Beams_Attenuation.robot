*** Settings ***
Documentation   Suite description

Library         OperatingSystem
Library         Process
Library         Collections
Library         String
Library         DateTime

Resource        ${CURDIR}/../../beamKeyword.robot


*** variables ***

&{beamid_vs_ssbid}              4=0      5=1      6=2      7=3      12=4    13=5     14=6     15=7
...                            20=8     21=9     22=10    23=11    28=12    29=13    30=14    31=15
...                            36=16    37=17    38=18    39=19    44=20    45=21    46=22    47=23
...                            52=24    53=25    54=26    55=27    60=28    61=29    62=30    63=31

&{ssbid_vs_beamid}             0=4    1=5    2=6    3=7    4=12    5=13    6=14    7=15    8=20
...                            9=21    10=22    11=23    12=28    13=29    14=30    15=31    16=36
...                            17=37    18=38    19=39    20=44    21=45    22=46    23=47    24=52
...                            25=53    26=54    27=55    28=60    29=61    30=62    31=63

*** Keywords ***
Get Custom BeamId Attenuation Pattern
    [Documentation]    This keyword will apply attenuate :
    ...             of ${beamId_att} on beam with ${beamId} Id number with
    ...             of ${bemIdx_att} on others beamids except in list  ${beamId_list_to_off}
    ...             of \\xFF on  beamids in list  ${beamId_list_to_off}
    [Arguments]   ${beamId}    ${beamId_att}=\\x00     ${attenuation}=\\x00   ${beamId_list_to_off}=@{EMPTY}
    ${beam_attenuation_pattern}    Set variable    ${EMPTY}

    # Attenuate the BeamId with ${attenuation} or \\xFF dB
    ${beamId}    Evaluate   ${beamid}
    FOR    ${id}   IN RANGE    ${beamid}
           ${att}    Set variable if    '${id}' in @{beamId_list_to_off}    \\xFF    ${attenuation}
          ${beam_attenuation_pattern}=    Catenate    SEPARATOR=    ${beam_attenuation_pattern}    ${att}
    END
    # Activate the BeamId
    ${beams_attenuation_pattern}=    Catenate    SEPARATOR=    ${beam_attenuation_pattern}    ${beamId_att}
    # Attenuate the BeamId with ${attenuation} or \\xFF dB
    ${beamId}    Evaluate   ${beamid} + 1
    FOR    ${id}   IN RANGE   ${beamid}    32
           ${att}    Set variable if    '${id}' in @{beamId_list_to_off}    \\xFF    ${attenuation}
          ${beam_attenuation_pattern}=    Catenate    SEPARATOR=    ${beam_attenuation_pattern}    ${att}
    END
    [Return]    ${beam_attenuation_pattern}


Get Custom 32b Attenuation Pattern
    [Documentation]    This keyword will apply attenuate :
    ...             Get attenuation pattern of alls beams except of ${beamId_list}
    [Arguments]   ${attenuation}=\\xFF   ${beamId_list}=@{EMPTY}
    log     ${ssbid_vs_beamid}
    ${beam_attenuation_pattern}    Set variable    ${EMPTY}
    FOR    ${id}   IN RANGE    32
          ${id}=      convert to string    ${id}
          ${ssbid}=     Get from dictionary    ${ssbid_vs_beamid}    ${id}
          ${att}    Set variable if    '${ssbid}' in @{beamId_list}    \\x00    ${attenuation}
          ${beam_attenuation_pattern}=    Catenate    SEPARATOR=    ${beam_attenuation_pattern}    ${att}
    END
    [Return]    ${beam_attenuation_pattern}

Get BeamId List of Module
    [Documentation]    This keyword return Beam Id List of Module
    ...                AM1: Main Module        <==> ${module_num}=1
    ...                AM2: Extension Module 1 <==> ${module_num}=2
    ...                AM3: Extension Module 2 <==> ${module_num}=3
    [Arguments]        ${beamset}    ${module_num}
    ${module_num}    Evaluate   ${module_num}
    #Get beamSet infos
    ${cmd}      catenate
    ...         cat ${CURDIR}/ABF_BeamSet_Pattern_SSBIndex_deployment_use_case
    ...         | grep -E ${beamSet}
    ${res}      Run       ${cmd}
    @{lines}    Split To Lines      ${res}
    @{bs}       Split String    @{lines}[0]    separator=:
    @{bm}       Split String    @{bs}[${module_num}]    separator=;
    ${ln}       Get length      ${bm}
    @{beamIdx}    Create list
    FOR    ${id}    IN RANGE    1     ${ln}
           ${key}    Set variable    @{bm}[${id}]
           ${elm}    Set variable    &{beamid_vs_ssbid}[${key}]
           Append to list    ${beamIdx}    ${elm}
    END
    [Return]     ${beamIdx}

Get SSBId List of Module
    [Documentation]    This keyword return Beam Id List of Module
    ...                AM1: Main Module        <==> ${module_num}=1
    ...                AM2: Extension Module 1 <==> ${module_num}=2
    ...                AM3: Extension Module 2 <==> ${module_num}=3
    [Arguments]        ${beamset}    ${module_num}
    ${module_num}    Evaluate   ${module_num}
    #Get beamSet infos
    ${cmd}      catenate
    ...         cat ${CURDIR}/ABF_BeamSet_Pattern_SSBIndex_deployment_use_case
    ...         | grep -E ${beamSet}
    ${res}      Run       ${cmd}
    @{lines}    Split To Lines      ${res}
    @{bs}       Split String    @{lines}[0]    separator=:
    @{bm}       Split String    @{bs}[${module_num}]    separator=;
    [Return]     ${bm}
