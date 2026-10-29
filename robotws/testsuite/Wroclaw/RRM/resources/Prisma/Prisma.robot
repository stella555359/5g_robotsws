*** Settings ***
Resource   resources/common/prisma_common_keywords.robot


*** Variables ***
${lsu_uu}               lsu_uu
${lsu_tstmuu}           tstm_uu
${sid_file_name}        5gnr-uesim_3_nsa_full_stack.sid
${yml_path}             ${CURDIR}/configs/prisma.yml
${scenario}             ${CURDIR}/scenarios/
${5g_cellid_expected}   50
${4g_cellid_expected}   2


*** Keywords ***
Prepare Prisma connection
    Prisma setup   ${yml_path}   ${tl.ues}
    Prisma start lsu uu
    Start airmosaic


Attach
    Cell setup
    Perform UE attach    ${sid_file_name}    ${scenario}
    wait until keyword succeeds    2 min    10 sec    Check Random access    1


Detach
    prisma.ue detach
    Wait Until Keyword Succeeds    2min    10s   Check detach status

Detach UE
    prisma.stop_tstm                node_name=${lsu_tstmuu}
    prisma.stop_lsu                 node_name=${lsu_uu}
    Teardown prisma

Check detach status
    ${response}=    prisma.get tstm log    node_name=${lsu_tstmuu}
    ...                                    expected_regex="DETACH SUCCESSFUL"
    ${UE DETACHED}=    Evaluate    "DETACH SUCCESSFUL" in """${response}"""
    Should be true    ${UE DETACHED}


Cell setup
    prisma.create_5g_cell   ${lsu_uu}   180
    #prisma.create_4g_cell   ${lsu_uu}   60
    wait until keyword succeeds   5 min   30 sec   Verify 5g cell   ${5g_cellid_expected}
    #wait until keyword succeeds   5 min   30 sec   Verify 4g cell   ${4g_cellid_expected}
    Sleep   10s
    Prisma start tstm uu


Verify 5g cell
    [Arguments]    ${5g_cellid_expected}
    ${5g_cellid}=    prisma.get_5g_cell_id    node_name=${lsu_uu}
    should be equal    ${5g_cellid[1]}    ${5g_cellid_expected}

Verify 4g cell
    [Arguments]    ${4g_cellid_expected}
    ${4g_cellid}=    prisma.get_4g_cell_id    node_name=${lsu_uu}
    should be equal    ${4g_cellid[1]}    ${4g_cellid_expected}
