*** Settings ***

Documentation
...    The purpose of this suite to run basic test for Debug Purpose
...     AUTHOR (I&V-1):
...         Abderrahmane NEZROUK

Test Setup      Action Test Setup
Test Teardown   Action Test Teardown

Library         ${CURDIR}/../../../../../resources/ST/python/LK_manager.py    WITH NAME    LK
Library         ${CURDIR}/../../../../../resources/ST/python/LK_handler.py

Resource        ${CURDIR}/../QCT_androidUe_useful_keywords.robot

*** Variable ***
${Ue_Alias}              UE_1
${filter_file_path}      ${CURDIR}/../qCatFilter.txt
${DL_Tput}               520Mbits/sec
${UL_Tput}               110Mbits/sec
${duration}              40s
${margin}                8
${logs_path}             ${OUTPUTDIR}

*** Test Cases ***
DL Traffic Test with Ue Log Collection
    ${stats_DT_1}    ${stats_DT_2}=    Perform Ue Attach Detach Traffic with statictics and Collect logs    ${Ue_Alias}
    ...                    direction=DL    duration=${duration}
    ...                    DL_Tput=${DL_Tput}    margin=${margin}
    ...                    filter_file_path=${filter_file_path}    local_dir=${logs_path}/Ue_logs

UL Traffic Test with Ue Log Collection
    ${stats_DT_1}    ${stats_DT_2}=    Perform Ue Attach Detach Traffic with statictics and Collect logs   ${Ue_Alias}    direction=UL
    ...                    duration=${duration}    UL_Tput=${UL_Tput}    margin=${margin}
    ...                    filter_file_path=${filter_file_path}    local_dir=${logs_path}/Ue_logs

DLUL Traffic Test with Ue Log Collection
    ${stats_DT_1}    ${stats_DT_2}=    Perform Ue Attach Detach Traffic with statictics and Collect logs    ${Ue_Alias}    direction=DLUL
    ...                    duration=${duration}    DL_Tput=${DL_Tput}    UL_Tput=${UL_Tput}    margin=${margin}
    ...                    filter_file_path=${filter_file_path}    local_dir=${logs_path}/Ue_logs


*** Keywords ***
Action Test Setup
    ${ue_config_file}=    Set variable    %{ABSTRACT_LIB_CONFIG}
    import variables    ${ue_config_file}
    LK_handler.connect  hostname=${UE_POOLS.AndroidUePool.inline_config.UE_1.CONSTRUCTOR_PARAMETERS.configuration.ue_pc_ip}
    LK_handler.qcat_5g_get_licence    retry=10    # Reservation Of Qcat Licence
    Prepare lib and Ue    ${Ue_Alias}

Action Test Teardown
    LK_handler.qcat_5g_release_licence    retry=10
    #Log out and Disconnect from Licence Keeper Client application
    LK_handler.disconnect

