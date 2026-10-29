*** Settings ***
Documentation     [PURPOSE]
#Library     taf.sbts.oam.coam.admin	WITH NAME	admin
Library     Collections
Library     OperatingSystem
Library     String
Resource     ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Trace/UeHandler.robot


*** Variables ***
${dl_nr_subcell_list}
${ul_nr_subcell_list}
#${USERNAME}     Nemuadmin
#${PASSWORD}=    nemuuser
#${bts_ip}=    10.97.97.135
${bts_ip}=    10.97.97.135
#${bts_ip}=    10.68.195.138
${PORT}=    443
${mrbts_id}
${outdoor}=         ${FALSE}
${technology}
${counter_id_1}     M55308C02000
${counter_id_2}     M55308C02002
${UE}               Mate_30_Pro_5G
${eutraCelId}       183123974
@{nr_cell_id_list}
#${eutraCelId}       1295366


*** Keywords ***
ActiveUEs with WebEM Remote Tool
    [Documentation]    Short description.
#    Import Test Line Variable
	Step 1: Get ActiveUEs Pre-condition
	Step 2: Make A Call To Trigger Counters Update
	Step 3: Get Cell list
#	Step 4: Post Check For ActiveUEs

Step 1: Get ActiveUEs Pre-condition
    [Documentation]    Short description.
    Log Variables
    taf.sbts.oam.coam.admin.connect to	bts_host=${bts_ip}
    Get Couter value form IM
#    Update miNrCellUtilization
    Update miNrUeQuan
    Set Up UE       ${UE}
	${bts_info}= 	taf.sbts.oam.coam.admin.get_bts_info
    Set Test Variable   ${mrbts_id}   ${bts_info}[mrbtsID]
    ${rats}=    Get Dictionary Keys    ${bts_info}[ratState]
    ${nr_deployed}=     Run Keyword And Return Status   Should Contain      ${rats}     nr
    Run Keyword If  ${nr_deployed}==${FALSE}    Log To Console  NR is not configured!!!
    Should Be True  ${nr_deployed}==${TRUE}
    Set Test Variable   ${nrbts_id}   ${bts_info}[nrBtsId]
    ActveUEs Exist in Cells Info      ${bts_info}[cells][nr]

ActveUEs Exist in Cells Info
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${nr_cells}: <description>
    ...
    ...    Returns:
    ...        ${total}: <description>
    [Arguments]     ${nr_cells}
    taf.sbts.oam.coam.admin.reset_admin
    ${total}=   Set Variable    ${0}
    FOR     ${cell}     IN  @{nr_cells}
        ${keys}=    Get Dictionary Keys    ${cell}
        Should Contain  ${keys}     counters
        ${keys}=    Get Dictionary Keys    ${cell}[counters]
        Should Contain  ${keys}     activeUEs
        ${activeUEs}=   Set Variable    ${cell}[counters][activeUEs]
        ${total}=   Evaluate    ${total}+${activeUEs}
    END
    [RETURN]    ${total}

Step 2: Make A Call To Trigger Counters Update
    [Documentation]    Short description.
    Log     Make a call to trigger counters update.
    ${attached_cell_id}=    Attach UE And Start ICMP Ping		UE_alias=${UE}		required_ue=${UE}   ping_count=999
    UE attached to BTS    ${attached_cell_id}
    Wait Until Keyword Succeeds  15min     30s    Counter Is Updated
    Detach UE And Stop Traffic      ${UE}

Step 3: Get Cell list
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${interval}: <description>
    [Arguments]     ${interval}=30
    ${cell_list}=   taf.sbts.oam.coam.admin.Get Cell List
    Log     ${cell_list}
    ActveUEs Exist in Cells Info    ${cell_list}[cells][nr]

Step 4: Post Check For ActiveUEs
    [Documentation]    Short description.
    taf.sbts.oam.coam.admin.teardown_all_aliases_for_admin

UE attached to BTS
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${attached_cell_id}: <description>
    [Arguments]     ${attached_cell_id}
    ${target_nrbts_id}=    Evaluate    int(${attached_cell_id}/16384)
    Should Be True    '${nrbts_id}'=='${target_nrbts_id}'

Get Latest Counter Vaule With Counter ID And Cell
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${counter_id}: <description>
    ...        ${cell}: <description>
    ...
    ...    Returns:
    ...        ${latest_value}: <description>
    [Arguments]     ${counter_id}   ${cell}
    taf.sbts.oam.coam.admin.reset_admin
    ${counters}=    taf.sbts.oam.coam.admin.Get PM Counters   counter_ids=${counter_id}
    ${counter_of_cell}=    Set Variable    ${counters}[BTS][CELLS][${cell}][NCELA][${counter_id}]
    Log Dictionary  ${counter_of_cell}
    ${keys_timestamp}=      Get Dictionary Keys     ${counter_of_cell}    sort_keys=${TRUE}
    Log List    ${keys_timestamp}
    ${latest_timestamp}=    Set Variable    ${keys_timestamp}[-1]
    ${latest_value}=      Set Variable    ${counter_of_cell}[${latest_timestamp}]
    [RETURN]    ${latest_value}

Counter Is Updated
    [Documentation]    Short description.
    log to console      Check couter update
    Get Couter value form IM
    ${bts_info}= 	taf.sbts.oam.coam.admin.get_bts_info
    ${total}=       ActveUEs Exist in Cells Info    ${bts_info}[cells][nr]
    Should Be True  ${total}>0

Get Couter value form IM
    [Documentation]    Short description.
    ${objs}=        taf.sbts.oam.coam.admin.get_managed_objects     NRCELL_R
    FOR     ${cell}     IN      @{objs}
        ${AVG_ACTIVE_UE_DU}=      taf.sbts.oam.coam.admin.get_parameters  ${cell}[distName]/COUNTERS-1      AVG_ACTIVE_UE_DU
    END

Update miNrCellUtilization
    [Documentation]    Short description.
    # For CB006590
    Log     Update miNrCellUtilization to 5min
    ${objs}=        taf.sbts.oam.coam.admin.get_managed_objects     NRPMRNL_A
    ${dist_name}=     Set Variable            ${objs}[0][distName]
    ${match}=    Get Regexp Matches    $${dist_name}   MRBTS_A-(\\d+)/NRBTS_A-(\\d+)/NRPMRNL_A-(\\d+)
    Log     ${match}
    ${dn}=  replace string  ${match}[0]    _A  ${EMPTY}
    taf.sbts.oam.coam.admin.perform_parameter_recommissioning    ${dn}   miNrCellUtilization   update  5min

Update miNrUeQuan
    [Documentation]    Short description.
    # For CB010545
    Log     Update miNrUeQuan to 5min
    ${objs}=        taf.sbts.oam.coam.admin.get_managed_objects     NRPMRNL_A
    ${dist_name}=     Set Variable            ${objs}[0][distName]
    ${match}=    Get Regexp Matches    $${dist_name}   MRBTS_A-(\\d+)/NRBTS_A-(\\d+)/NRPMRNL_A-(\\d+)
    Log     ${match}
    ${dn}=  replace string  ${match}[0]    _A  ${EMPTY}
    taf.sbts.oam.coam.admin.perform_parameter_recommissioning    ${dn}   miNrUeQuan   update  5min
