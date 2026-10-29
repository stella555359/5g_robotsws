*** Settings ***
Documentation     [PURPOSE]
Library      ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/M2M.py
Library		Collections
Resource     ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Trace/UeHandler.robot


*** Variables ***
#${vdu_mplane_ip}   10.71.173.82         #BTS-5460
#${cu_mplane_ip}   10.110.29.134         #BTS-5460
#${vdu_mplane_ip}   10.56.105.194        #BTS-110767
#${vdu_mplane_ip}   10.56.104.226         #BTS-110766
#${vdu_mplane_ip}   10.108.195.130         #BTS-11322
#${vdu_mplane_ip}   10.108.195.82         #BTS-11087
#${vdu_mplane_ip}   10.108.194.162         #BTS-11084
#${cu_mplane_ip}   10.110.83.143         #BTS-11083

${vdu_username}     Nemuadmin
#${vdu_password}     N0kia@dmin56
${vdu_password}     Nokia@123
${counter_id_1}       M55308C02000
${counter_id_2}       M55308C02002
${UE}               xiaomi_12
${eutraCelId}       185499649
${cell_dn}


*** Keywords ***
CB006590-B Get active Ues
    [Documentation]    Short description.
#    Step 1: Make A Call To Trigger Counters Update
    Step 2: Get Vdu Cells Status

Step 2: Get Vdu Cells Status
    [Documentation]    Short description.
    ${cells}=   get_vdu_cells   host=${vdu_mplane_ip}   username=${vdu_username}     password=${vdu_password}
    log list    ${cells}

    FOR     ${cell}     IN      @{cells}
        ${cell_info}=   get_vdu_cell_with_id	host=${vdu_mplane_ip}	cell_id=${cell}[basicCell][id]
        ...     username=${vdu_username}     password=${vdu_password}
        Log Dictionary	${cell_info}
        Log Dictionary	${cell_info}[activeUEs]
        Log To Console  activeUEs: ${cell_info}[activeUEs]

        ${dn}=  Set Variable    ${cell}[basicCell][distNames][config]
        ${cell_dn}=     set Variable If     ${cell}[basicCell][nrCellIdentity]==${eutraCelId}   ${dn}

        ${counters_1}=	M2M.Get Counter		host=${vdu_mplane_ip}	counter_id=${counter_id_1}	mo_dn=${dn}
        ...     username=${vdu_username}     password=${vdu_password}
        Log Dictionary 	${counters_1}
        Log List	${counters_1}[${counter_id_1}:PLMN-PLMN/${dn}]
        ${latest_value_1}=    Set Variable    ${counters_1}[${counter_id_1}:PLMN-PLMN/${dn}][-1][value]
        Should Be True  '${cell_info}[activeUEs][DL]'=='${latest_value_1}'

        ${counters_2}=	M2M.Get Counter		host=${vdu_mplane_ip}	counter_id=${counter_id_2}	mo_dn=${dn}
        ...     username=${vdu_username}     password=${vdu_password}
        Log Dictionary 	${counters_2}
        Log List	${counters_2}[${counter_id_2}:PLMN-PLMN/${dn}]
        ${latest_value_2}=    Set Variable    ${counters_2}[${counter_id_2}:PLMN-PLMN/${dn}][-1][value]
        Should Be True  '${cell_info}[activeUEs][UL]'=='${latest_value_2}'
    END

Step 1: Make A Call To Trigger Counters Update
    [Documentation]    Short description.
    Log     Make a call to trigger counters update.
    UE RRC ACTIVE   interval=10		UE_alias=${UE}		required_ue=${UE}
#    Wait Until Keyword Succeeds  30min     30s    Counter Is Updated     ${counter_id_1}
    M2M.counter_is_updated   host=${vdu_mplane_ip}	username=${vdu_username}     password=${vdu_password}
        ...     counter_id=${counter_id_1}   mo_dn=${cell_dn}
