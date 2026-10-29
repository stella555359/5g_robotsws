*** Settings ***
Resource   prisma_common_keywords.robot
Library    prisma_resources.py


*** Variables ***
${lsu_uu}               lsu_uu
${lsu_tstmuu}           tstm_uu
${sid_file_name}        5gnr-uesim_3_nsa_full_stack.sid
${yml_path}             ${CURDIR}/Prisma/configs/prisma.yml
${scenario}             ${CURDIR}/Prisma/scenarios/
${5g_cellid_expected}   51
${4g_cellid_expected}   1


*** Keywords ***
Prepare Prisma connection
    Prisma setup   ${yml_path}   ${tl.ues}
    log to console  Starting lsu uu
    Prisma start lsu uu
    Start airmosaic
    log to console  Decoding cells
    Cell setup

Attach
    log to console  Attach
    Perform UE attach    ${sid_file_name}    ${scenario}
    wait until keyword succeeds    2 min    5 sec    Check Random access    1
    log to console  Attach OK


Detach
    prisma.ue detach
    Wait Until Keyword Succeeds    2min    10s   Check detach status


Check detach status
    ${response}=    prisma.get tstm log    node_name=${lsu_tstmuu}
    ...                                    expected_regex="DETACH SUCCESSFUL"
    ${UE DETACHED}=    Evaluate    "DETACH SUCCESSFUL" in """${response}"""
    Should be true    ${UE DETACHED}


Cell setup
    prisma.create_5g_cell   ${lsu_uu}   180
    prisma.create_4g_cell   ${lsu_uu}   60
    wait until keyword succeeds   5 min   30 sec   Verify 5g cell   ${5g_cellid_expected}
    wait until keyword succeeds   5 min   30 sec   Verify 4g cell   ${4g_cellid_expected}
    #Sleep   10s
    #Prisma start tstm uu


Verify 5g cell
    [Arguments]    ${5g_cellid_expected}
    ${5g_cellid} =  get_5g_cell_id_v2
    should be equal    ${5g_cellid}    ${5g_cellid_expected}

Verify 4g cell
    [Arguments]    ${4g_cellid_expected}
    ${4g_cellid} =  get_4g_cell_id_v2
    should be equal    ${4g_cellid}    ${4g_cellid_expected}

Prepare Prisma connection v2
    [Arguments]  ${yml_path}
    Prisma setup   ${yml_path}   ${tl.ues}
    log to console  Starting lsu uu
    Prisma start lsu uu
    Start airmosaic
    log to console  Decoding cells
    Cell setup

Attach v2
    [Arguments]   ${sid_file_name}    ${scenario}
    log to console  Attach
    Perform UE attach    ${sid_file_name}    ${scenario}
    wait until keyword succeeds    2 min    5 sec    Check Random access    1

Prepare Prisma connection without cell restart
    [Arguments]  ${yml_path}
    Prisma setup   ${yml_path}   ${tl.ues}
    prisma.stop_tstm    node_name=${lsu_tstmuu}
    prisma.clean_lsu    node_name=${lsu_uu}
    Cell setup
    Prisma start tstm uu
    Start airmosaic

