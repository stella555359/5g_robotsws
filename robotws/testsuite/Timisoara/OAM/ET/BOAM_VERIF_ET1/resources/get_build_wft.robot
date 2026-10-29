*** Settings ***
Documentation
...     Author: dan.moldovan@nokia.com
...     Description: Get promoted build for classical or vDU via Jenkins


Library    OperatingSystem
Library    Collections
Library    String
Library    ../resources/python/Get_latest_build_name.py           WITH NAME    wft
Library    ../resources/python/Get_latest_build_name_vdu.py       WITH NAME    wftvdu

*** Variables ***
${TEST_LOG_DIR}=    /home/ute

*** Keywords ***

Get last CIT promotion Build

     ${CIT_software_Promoted}    Get SRAN latest build by wft link with promotion_tags    branch=${BRANCH_from_JENKINS}
     ...                                                                              promotion_tags=RAN_5G_CIT
#      ...                                                                              promotion_tags=RAN_5G_CUSTOMER
     Set Global Variable  ${CIT_software_Promoted}

Get SRAN latest build by wft link with promotion_tags
    [Arguments]    ${branch}    ${release_prefix}=${branch}_ENB    ${suffix}=A54
    ...            ${promotion_tags}=RAN_MRAT_CRT    ${target_dir}=/home/ute/Downloads
    [Documentation]    Author: Yang Mengli
    ...                Updates: Dan Moldovan
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                This kw is used to get sran latest promotion build by wft and download sw build by command
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${branch} | Yes | The SWB branch, E.g. SBTS00, SBTS22R1 |
    ...    | ${release_prefix} | No | The SWB version's prefix, E.g. SBTS00_ENB. Suggest use the default value |
    ...    | ${suffix} | No | The SWB version's suffix, Default value is A54 |
    ...    | ${promotion_tags} | No | The SWB promotion tags, default is RAN_MRAT_CRT |
    ...    | ${target_dir} | No | The SWB store folder after download, default is /home/ute/Downloads |
    ...
    ...    | Return Value | Description |
    ...    | ${latest_build_name} | The latest SWB version for the given branch and promotion tags |
    ...
    ...    Example
    ...    | ${latest_promotion_swb}= | Get SRAN latest build by wft link with promotion_tags | branch=SBTS00 |
    ...
    ${package_states}    Create List    RELEASED    RELEASED_WITH_RESTRICTIONS
    ${latest_build_name}    wft.get_name_of_latest_build    branch=${branch}
    ...                          release_prefix=${release_prefix}
    ...                          package_states=${package_states}
    ...                          promotion_tags=${promotion_tags}
    Log To Console    ${latest_build_name}
    [Return]    ${latest_build_name}

Get last CIT promotion Build vDU

#    ${CIT_software_Promoted}    Get SRAN latest build by wft link with promotion_tags    branch=SBTS22R1
#    ...                                                                              promotion_tags=RAN_5G_CIT
#    ${CIT_software_Promoted}    Get SRAN latest build by wft link with promotion_tags    branch=VDU22R2
#    ...                                                                              promotion_tags=RAN_5G_CIT
#    ...                                                                               release_prefix=vDUCNF22R2
    ${release_prefix_branch}    Set Variable If    '${BRANCH_from_JENKINS}' == 'master_vDU'    0
    ...                                            '${BRANCH_from_JENKINS}' == 'vDU22R2'    14
    ...                                             '${BRANCH_from_JENKINS}' == 'vDUCNF22R4'    16

    ${CIT_software_Promoted}    Get SRAN latest build by wft link with promotion_tags_vdu    branch=${BRANCH_from_JENKINS}
    ...                                                                              promotion_tags=RAN_5G_CIT
    ...                                                                              release_prefix=${release_prefix_branch}
    Log To Console  ${CIT_software_Promoted}
    Set Global Variable  ${CIT_software_Promoted}

    Run Keyword If  '${BRANCH_from_JENKINS}' == 'master_vDU'
    ...                      Run  command=echo ${CIT_software_Promoted} > ~/jenkins/lastTrunk.txt
    ...   ELSE IF  '${BRANCH_from_JENKINS}' == 'vDU22R3'
    ...                      Run  command=echo ${CIT_software_Promoted} > ~/jenkins/last22R3.txt
    ...   ELSE IF  '${BRANCH_from_JENKINS}' == 'vDU22R2'
    ...                      Run  command=echo ${CIT_software_Promoted} > ~/jenkins/last22R2.txt
    ...   ELSE IF  '${BRANCH_from_JENKINS}' == 'vDUCNF22R4'
    ...                      Run  command=echo ${CIT_software_Promoted} > ~/jenkins/last22R4.txt
    ...   ELSE IF  '${BRANCH_from_JENKINS}' == 'CUCNF22R2'
    ...                      Run  command=echo ${CIT_software_Promoted} > ~/jenkins/last22R2.txt
    ...   ELSE     Fail

    ${CIT_software_Promoted}=    Split String
    ...                          string=${CIT_software_Promoted}
    ...                          separator=_
    ...                          max_split=2

    ${vDU_VERSION}=   Get from list         ${CIT_software_Promoted}    1

    Log To Console  ${vDU_VERSION}
    Set Global Variable  ${vDU_VERSION}


Get SRAN latest build by wft link with promotion_tags_vdu
    [Arguments]    ${branch}    ${release_prefix}=0    ${suffix}=300
    ...            ${promotion_tags}=RAN_MRAT_CRT    ${target_dir}=/home/ute/Downloads
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                This kw is used to get sran latest promotion build by wft and download sw build by command
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${branch} | Yes | The SWB branch, E.g. SBTS00, SBTS22R1 |
    ...    | ${release_prefix} | No | The SWB version's prefix, E.g. SBTS00_ENB. Suggest use the default value |
    ...    | ${suffix} | No | The SWB version's suffix, Default value is A54 |
    ...    | ${promotion_tags} | No | The SWB promotion tags, default is RAN_MRAT_CRT |
    ...    | ${target_dir} | No | The SWB store folder after download, default is /home/ute/Downloads |
    ...
    ...    | Return Value | Description |
    ...    | ${latest_build_name} | The latest SWB version for the given branch and promotion tags |
    ...
    ...    Example
    ...    | ${latest_promotion_swb}= | Get SRAN latest build by wft link with promotion_tags | branch=SBTS00 |
    ...
    ${package_states}    Create List    RELEASED    RELEASED_WITH_RESTRICTIONS
    ${latest_build_name}    wftvdu.get_name_of_latest_build_vdu    branch=${branch}
    ...                          release_prefix=${release_prefix}
    ...                          package_states=${package_states}
    ...                          promotion_tags=${promotion_tags}
    Log To Console    ${latest_build_name}
    [Return]    ${latest_build_name}
