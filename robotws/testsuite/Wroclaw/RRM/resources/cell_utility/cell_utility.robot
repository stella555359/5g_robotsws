*** Settings ***
Resource   testsuite/Wroclaw/RRM/resources/all_ues/ue.robot
Library    testsuite/Wroclaw/RRM/resources/cell_utility/cell_utility_backend.py
Library    testsuite/Wroclaw/RRM/resources/webUI_operations.py
Resource   testsuite/Wroclaw/RRM/resources/logs.robot


*** Keywords ***
Get cell ids
    [Documentation]  Commiting cell lock-unlock to trigger cell setup. Binds relevant cell ids together and returns
    ...              them as list of cell_info objects
    [Arguments]  ${asik_cell_setup_file}=${NONE}
    run keyword if  '${asik_cell_setup_file}' == '${NONE}'   Get cell setup tcpdump logs
    ${cell_structs}=   Get cell ids from cell setup_pcap   ${asik_cell_setup_file}
    Find global cell ids given physical cell ids   ${cell_structs}
    Log cell structs   ${cell_structs}
    [Return]  ${cell_structs}


Get cell ids and set them as suite variable
    [Documentation]  Wrapper keyword which is safe to use in suite setup. Name of the suite variable is 'all_cells'
    [Arguments]  ${cell_setup_file}=${NONE}
    ${cells}=  Get cell ids   ${cell_setup_file}
    Set suite variable   ${all_cells}   ${cells}


Determine primary and secondary cells
    [Documentation]  This keywords determines primary and secondary cells from cell ids structs returned from
    ...              "Get cell ids" keyword. Please be aware, that this keyword should be provided with attach pcap
    ...              containing log from attaching ONLY ONE UE at the time. Keyword can be used multiple times on
    ...              multiple attach logs, but it is up to user to remember which cell is primary to which ue.
    ...              Arguments are:
    ...                  known_cells = list of cell ids structures (as returned from "get cell ids" keyword)
    ...                  attach_pcap = path to attach pcap. If left as None, default path shall be used (testname.pcap)
    ...              Returns 2 things: 1st one being primary cell and and 2nd being LIST of secondary cells
    [Arguments]  ${known_cells}
    ...          ${attach_pcap}=${NONE}
    ${prim_and_sec_phy_ids}=  Get primary and secondary physcellids from attach pcap   ${attach_pcap}
    ${prim_and_sec_cells}=  Determine prim and sec cells  ${known_cells}  ${prim_and_sec_phy_ids}
    [Return]    ${prim_and_sec_cells[0]}   ${prim_and_sec_cells[1]}


Get physical id of attached cell
    [Arguments]  ${lte_attach_pcap}
    ${prim_and_sec_phy_ids}=  Get primary and secondary physcellids from attach pcap   ${lte_attach_pcap}
    [Return]  ${prim_and_sec_phy_ids[0]}


Get global id of attached cell
    [Arguments]  ${lte_attach_pcap}
    ${physical_id}=  Get physical id of attached cell   ${lte_attach_pcap}
    ${cell}=  Get new cell struct   physical_id=${physical_id}
    Find global cell ids given physical cell ids   ${cell}
    [Return]  ${cell['global_id']}
