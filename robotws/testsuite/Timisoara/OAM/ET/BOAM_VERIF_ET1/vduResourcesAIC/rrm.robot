*** Settings ***
Documentation
...

*** Variables ***


*** Keywords ***
############################## LTE RRM Start ##############################
====== LTE RRM Start ======
     log to console  \n*** only used for readable ***
Adjust Enb
    [Arguments]    ${index}
    [Documentation]   Adjust Enb
    ...    *AUTHOR* eahsuan,xuan@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | index | yes | the value of defaultLnRelGnbCellId that you want to set |
    ...    *RETURN VALUE*
    ...  None
    ...    Example
    ...    |  Adjust Enb | 0 |
    ...
    ${mrbts_id}=  Get MRBTS Id From vDU SCF
    ${dist_name}  set variable  MRBTS-${mrbts_id}/LNBTS-${mrbts_id}/LNCEL-1
    ${parameter}  set variable  defaultLnRelGnbCellId
    ${value}  set variable  ${index}
    Connect and Modify the parameter on enblte
    ...    dist_name=${dist_name}
    ...    parameter=${parameter}
    ...    value=${value}


############################## LTE RRM End ##############################
====== LTE RRM End ======
     log to console  \n*** only used for readable ***


############################## CU RRM Start ##############################
====== CU RRM Start ======
     log to console  \n*** only used for readable ***


############################## CU RRM End ##############################
====== CU RRM End ======
     log to console  \n*** only used for readable ***


############################## vDU RRM Start ##############################
====== vDU RRM Start ======
     log to console  \n*** only used for readable ***

Online Modify DU Parameter actInternalTrace to be True
    [arguments]    ${MO_DN}
    vDU Rest Login
    ${actInternalTrace}=    Get VDU Parameter Value Online    ${MO_DN}    actInternalTrace
    ${added_dict}    Create Dictionary    actInternalTrace=true
    run keyword if    '${actInternalTrace}' != 'true'    VDU Online Change Parameters By Delta Plan REST
    ...    mo_dn=${MO_DN}    updated_paras_list=${added_dict}    auto_lock_cells=${False}    wait_vdu_up=${true}


############################## vDU RRM End ##############################
====== vDU RRM End ======
     log to console  \n*** only used for readable **

############################## FHGW RRM Start ##############################
====== FHGW RRM Start ======
     log to console  \n*** only used for readable ***

############################## FHGW RRM End ##############################
====== FHGW RRM End ======
     log to console  \n*** only used for readable **
