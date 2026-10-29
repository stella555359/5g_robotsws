*** Settings ***



*** Variables ***
${MRBTS_ID}       ${tl.gnbs[0].instance_id}

*** Keywords ***
Set Variables for Adding Cell
    [Arguments]   ${cell_index}
    ${cell_dict}=  create dictionary   nrdu=1  lcrId=${cell_index}  nrcellgrpId=${cell_index}
    ...   physCellId=${${${MRBTS_ID}}+${${cell_index}}-${1}}  rmod_id=${cell_index}
    ${CHANNEL_list_1}  create list  1  2  3  4  5  6  7  8
    ${CHANNEL_list_2}  create list
    ${channel_group}   create list  ${CHANNEL_list_1}   ${CHANNEL_list_2}
    [Return]   ${cell_dict}     ${channel_group}



