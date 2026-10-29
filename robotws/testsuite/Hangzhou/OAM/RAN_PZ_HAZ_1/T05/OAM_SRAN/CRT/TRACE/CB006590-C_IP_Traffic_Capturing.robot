*** Settings ***
Documentation     [PURPOSE]
#Force Tags   CB006590   trunk   branch  CDRT
#Library      taf.sbts.oam.coam.admin	WITH NAME	admin
Library      Collections
Library      OperatingSystem
Library      String
Resource    ../../CRT/SWM/SWM__SW_download_and_activation__SBTS_to_SBTS.robot


*** Variables ***
${dl_nr_subcell_list}
${ul_nr_subcell_list}
#${USERNAME}     Nemuadmin
#${PASSWORD}=    nemuuser
${bts_ip}=    10.97.97.135
#${bts_ip}=    10.97.91.52
#${bts_ip}=    10.68.195.138
${PORT}=    443
${mrbts_id}
${outdoor}=     ${FALSE}
${technology}


*** Keywords ***
IP Traffic Capturing commands with WebEM Remote Tool
    [Documentation]    Short description.
	Step 1: IP Traffic Capturing Pre-condition
	Step 2: IP Traffic Capturing
    Step 3: IP Capture Streaming
#	Step 4: Post Check For IP traffic capturing

Step 1: IP Traffic Capturing Pre-condition
    [Documentation]    Short description.
    taf.sbts.oam.coam.admin.connect to	bts_host=${bts_ip}
	Log		Enable internal trace
	SMOD Check
    Egress Port Check

Step 2: IP Traffic Capturing
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${interval}: <description>
    ...        ${measurement_point}: <description>
    ...        ${uplane_capturing}: <description>
    ...        ${password}: <description>
    [Arguments]     ${interval}=30  ${measurement_point}=NE_Terminated
    ...     ${uplane_capturing}=${FALSE}    ${password}=${EMPTY}
    taf.sbts.oam.coam.admin.Start IP Capture File    measurement_point=${measurement_point}
    ...     uplane_capturing=${FALSE}    password=${EMPTY}
    Sleep      ${interval}
    taf.sbts.oam.coam.admin.Stop IP Capture File
    taf.sbts.oam.coam.admin.Generate IP Capture File
    ${year}    ${month}    ${day}    ${hour}    ${min}=    Get Time    format=year,month,day,hour,min
    ${timestamp}=    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    ${target_file_name}=    Set Variable    IP_Traffic_MRBTS-${mrbts_id}_${timestamp}.pcap.gz
    taf.sbts.oam.coam.admin.Download IP Capture File    target_file_name=${target_file_name}

SMOD Check
    [Documentation]    Short description.
    ${bts_info}= 	taf.sbts.oam.coam.admin.get_bts_info
    Set Test Variable   ${mrbts_id}    ${bts_info}[mrbtsID]
    ${smods}=   Set Variable    ${bts_info}[systemModules]
    FOR     ${smod}     IN  @{smods}
        ${outdoor}=     Run Keyword And Return Status   Should Match Regexp  ${smod}[productName]    ASO|FSMF
        Set Test Variable   ${outdoor}
        ${lmp_not_support}=     Run Keyword And Return Status   Should Match Regexp  ${smod}[productName]    ASO|ASIM|ASIL
        Set Test Variable   ${lmp_not_support}
    END

Egress Port Check
    [Documentation]    Short description.
    ${ethlk_dns}=   Create List
    ${ethlks}=    taf.sbts.oam.coam.admin.get_managed_objects     ETHLK_A
    Log List     ${ethlks}
    FOR     ${ethlk}    IN      @{ethlks}
        ${is_backhaul}=     Run Keyword and return status   Should Contain  ${ethlk}[parameters][connectorLabel]    EIF
        Continue For Loop If    ${is_backhaul}==${FALSE}
        ${partten}=     Set Variable    MRBTS_A-(\\d+)/TNLSVC_A-(\\d+)/TNL_A-(\\d+)/ETHSVC_A-(\\d+)/ETHLK_A-(\\d+)
        ${match}=   Get Regexp Matches     ${ethlk}[distName]   ${partten}
        ${dn}=  Replace String  ${match[0]}    _A  ${EMPTY}
        append to list    ${ethlk_dns}  ${dn}
    END
    log     ${ethlk_dns}
    ${len}=     Get Length  ${ethlk_dns}
    Should Be True  ${len}>0
    Set Test Variable   ${ethlk_dns}

Step 3: IP Capture Streaming
    [Documentation]    Short description.
    FOR     ${ethlk}    IN  @{ethlk_dns}
        IP Capture Streaming    egress_port_dn=${ethlk}
    END
    Run keyword If  ${lmp_not_support}      Return From Keyword
    Log To Console      IP Capture Streaming on LMP
    IP Capture Streaming

IP Capture Streaming
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${interval}: <description>
    ...        ${measurement_point}: <description>
    ...        ${uplane_capturing}: <description>
    ...        ${dst_mac_addr}: <description>
    ...        ${egress_port_dn}: <description>
   [Arguments]     ${interval}=30  ${measurement_point}=NE_Terminated
   ...  ${uplane_capturing}=${FALSE}    ${dst_mac_addr}=82:04:26:bf:db:ac    ${egress_port_dn}=${EMPTY}
    Log     IP Capture Streaming
    taf.sbts.oam.coam.admin.Start IP Capture Streaming      measurement_point=${measurement_point}
    ...     uplane_capturing=${uplane_capturing}    dst_mac_addr=${dst_mac_addr}   egress_port_dn=${egress_port_dn}
    Sleep      ${interval}
    taf.sbts.oam.coam.admin.Stop IP Capture Streaming

Step 4: Post Check For IP traffic capturing
    [Documentation]    Short description.
#    taf.sbts.oam.coam.admin.teardown_all_aliases_for_admin
    Log    Nothing

CB006590 Setup
    [Documentation]    Short description.
    Common Test Setup
    SW update to target build

CB006590 Teardown
    [Documentation]    Short description.
    Common Test Teardown
