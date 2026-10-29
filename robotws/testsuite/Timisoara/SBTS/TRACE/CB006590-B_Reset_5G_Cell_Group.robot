*** Settings ***
Documentation     [PURPOSE]
Library      ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/M2M.py
Library		Collections
Library     DateTime
Library     taf.gnb.oam.coam.cu     WITH NAME   CU


*** Variables ***
#${vdu_mplane_ip}   	10.108.195.130      #BTS-11322
#${vdu_mplane_ip}   10.108.194.162         #BTS-11084
#${cu_mplane_ip}   	10.110.83.133       #BTS-11322
#${vdu_mplane_ip}   	10.108.195.82      #BTS-11087
${NR_CELL_PLAN_UNAVAIL_SAMPLES}       M55601C01001
${NR_CELL_PLAN_UNAVAIL_CHNG_TO}       M55601C01002
${vdu_username}     Nemuadmin
#${vdu_password}     N0kia@dmin56
${vdu_password}     Nokia@123
${cu_username}     Nemuadmin
#${vdu_password}     N0kia@dmin56
${cu_password}     Nokia@123
${alias}            default


*** Keywords ***
CB006590 Setup For AIC CU
    [Documentation]    Short description.
    Log To Console      ${EMPTY}
	${cu}=     get_cu_state   ${cu_mplane_ip}    username=${vdu_username}     password=${vdu_password}
	Log Dictionary      ${cu}
	${software_version}=    Set Variable        ${cu}[softwareVersion]
	Log To Console      CU version: ${software_version}
    All Cells Are Onair CU

CB006590 Setup For AIC vDU
    [Documentation]    Short description.
    Log To Console      ${EMPTY}
	${vdu}=     get_vdu_state   ${vdu_mplane_ip}    username=${vdu_username}     password=${vdu_password}
	Log Dictionary      ${vdu}
	${software_version}=    Set Variable        ${vdu}[softwareVersion]
	Log To Console      vDU version: ${software_version}
    All Cells Are Onair vDU

#Connect To CU
#    CU.connect to
#    ...  host=${cu_mplane_ip}
#    ...  port=443
#    ...  username=${cu_username}
#    ...  password=${cu_password}
#    ...  secure=True
#    ...  connection_name=${alias}
#
#Get CU Cells Status
#    ${cells}=     CU.get_cells_statuses
#    Log List    ${cells}
#    [RETURN]    ${cells}

Reset 5G Cell Group And Check Down Time vDU
    [Documentation]    Short description.
    ${cell_groups}=     reset_vdu_cell_groups
    ...     host=${vdu_mplane_ip}	username=${vdu_username}     password=${vdu_password}
	${cell_groups_count}=   Get Length  ${cell_groups}
	${taget_downtime}=  evaluate    40*${cell_groups_count}
	Wait Until Keyword Succeeds    60s  1s   Not All Cells Are Onair vDU
	${start} =	Get Current Date
	Wait Until Keyword Succeeds    ${taget_downtime}s  1s   All Cells Are Onair vDU
	${end} =	Get Current Date
	${downtime}=    Subtract Date From Date     ${end}      ${start}
	Log To Console  Downtime: ${downtime}s
	Should Be True  ${downtime}<=${taget_downtime}

Reset 5G Cell Group And Check Down Time CU
    [Documentation]    Short description.
    ${cell_groups}=     reset_cu_cell_groups
    ...     host=${cu_mplane_ip}	username=${vdu_username}     password=${vdu_password}
    Log To Console      Cell Group Reset Done
	${cell_groups_count}=   Get Length  ${cell_groups}
	${taget_downtime}=  evaluate    40*${cell_groups_count}
	Wait Until Keyword Succeeds    10s  1s   Not All Cells Are Onair CU
	${start} =	Get Current Date
	Wait Until Keyword Succeeds    ${taget_downtime}s  1s   All Cells Are Onair vDU
	${end} =	Get Current Date
	${downtime}=    Subtract Date From Date     ${end}      ${start}
	Log To Console  Downtime: ${downtime}s
	Should Be True  ${downtime}<=${taget_downtime}

Reset 5G Cell Group For ${count} Times vDU
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${count}: <description>
    FOR     ${index}    IN RANGE    0   ${count}
        Reset 5G Cell Group And Check Down Time vDU
    END

Reset 5G Cell Group For ${count} Times CU
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${count}: <description>
    FOR     ${index}    IN RANGE    0   ${count}
        Reset 5G Cell Group And Check Down Time CU
    END

CB006590-B Reset 5G Cell Group vDU
    [Documentation]    Short description.
    Reset 5G Cell Group For 1 Times vDU
	Counters Are Updated vDU

CB006590-B Reset 5G Cell Group CU
    [Documentation]    Short description.
    Reset 5G Cell Group For 2 Times CU
	Counters Are Updated CU

Counters Are Updated vDU
    [Documentation]    Short description.
    log to console  Check counters update vDU
    ${vdu_cells}    get_vdu_cells_dn    host=${vdu_mplane_ip}	username=${vdu_username}     password=${vdu_password}
    FOR     ${cell}     IN  @{vdu_cells}
        M2M.counter_is_updated   host=${vdu_mplane_ip}	username=${vdu_username}     password=${vdu_password}
        ...     counter_id=${NR_CELL_PLAN_UNAVAIL_SAMPLES}   mo_dn=${cell}
        M2M.counter_is_updated   host=${vdu_mplane_ip}	username=${vdu_username}     password=${vdu_password}
        ...     counter_id=${NR_CELL_PLAN_UNAVAIL_CHNG_TO}   mo_dn=${cell}
    END

Counters Are Updated CU
    [Documentation]    Short description.
    log to console  Check counters update CU
    ${cu_cells}    get_cu_cells_dn    host=${cu_mplane_ip}	username=${vdu_username}     password=${vdu_password}
    FOR     ${cell}     IN  @{cu_cells}
        M2M.counter_is_updated   host=${cu_mplane_ip}	username=${vdu_username}     password=${vdu_password}
        ...     counter_id=${NR_CELL_PLAN_UNAVAIL_SAMPLES}   mo_dn=${cell}
        M2M.counter_is_updated   host=${cu_mplane_ip}	username=${vdu_username}     password=${vdu_password}
        ...     counter_id=${NR_CELL_PLAN_UNAVAIL_CHNG_TO}   mo_dn=${cell}
    END

Not All Cells Are Onair vDU
    [Documentation]    Short description.
    ${vdu_cells_summary}=   vdu.get_vdu_cells_summary   ${vdu_mplane_ip}
    ...     username=${vdu_username}     password=${vdu_password}
    log dictionary      ${vdu_cells_summary}
    ${off_line_cell_count}=     Set Variable    ${vdu_cells_summary}[availabilityStatus][off line]
    Should Be True  ${off_line_cell_count}>0

Not All Cells Are Onair CU
    [Documentation]    Short description.
    ${cu_cells}=    get_cu_cells    ${cu_mplane_ip}
    ...     username=${vdu_username}     password=${vdu_password}
    Log     ${cu_cells}
    ${cu_cells_summary}=   get_cu_cells_summary   ${cu_mplane_ip}
    ...     username=${vdu_username}     password=${vdu_password}
    log dictionary      ${cu_cells_summary}
    ${off_line_cell_count}=     Set Variable    ${cu_cells_summary}[basicCellsSummary][operationalState][disabled]
    Should Be True  ${off_line_cell_count}>0

All Cells Are Onair vDU
    [Documentation]    Short description.
    ${vdu_cells_summary}=   vdu.get_vdu_cells_summary   ${vdu_mplane_ip}
    ...     username=${vdu_username}     password=${vdu_password}
    log dictionary      ${vdu_cells_summary}
    ${off_line_cell_count}=     Set Variable    ${vdu_cells_summary}[availabilityStatus][off line]
    Should Be True  ${off_line_cell_count}==0

All Cells Are Onair CU
    [Documentation]    Short description.
    Log To Console      All Cells Are Onair CU
    ${cu_cells_summary}=   get_cu_cells_summary   ${cu_mplane_ip}
    ...     username=${vdu_username}     password=${vdu_password}
    log dictionary      ${cu_cells_summary}
    ${off_line_cell_count}=     Set Variable    ${cu_cells_summary}[basicCellsSummary][operationalState][disabled]
    Should Be True  ${off_line_cell_count}==0

CB006590 Teardown For AIC
    [Documentation]    Short description.
	All Cells Are Onair vDU
