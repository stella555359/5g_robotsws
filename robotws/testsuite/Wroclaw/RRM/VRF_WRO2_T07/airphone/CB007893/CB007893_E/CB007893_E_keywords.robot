*** Settings ***

Documentation    :copyright: Nokia

Library     ta5g_enb
Library     ta5g_commissioning
Library     ta5g_setups_and_teardowns
Library     ta5g_iphy

*** Variables ***
${dist_name}    MRBTS-1/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-1

*** Keywords ***
Setup Inter Env
    Update Iphy Configuration And Modify Swconfig    iphy_xml_filepath=${CURDIR}/config/BOO_AP_LOO/inter/3cc_7893_inter_iphy.xml
    Get Scfc File    output_filepath=${CURDIR}/config/BOO_AP_LOO/inter/_scf.xml
    Send Full Commissioning    input_filepath=${CURDIR}/config/BOO_AP_LOO/inter/3cc_7893_inter_scf.xml
    ${vlanId}=    Get Value From Scf    dist_name=${dist_name}    parameter_name=vlanId    scfc_filepath=${CURDIR}/config/BOO_AP_LOO/inter/_scf.xml
    check radios availability
    Perform Parameter Commissioning    dist_name=MRBTS-1/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-1    parameter=vlanId    value=${vlanId}


Setup Intra Env
    Update Iphy Configuration And Modify Swconfig    iphy_xml_filepath=${CURDIR}/config/BOO_AP_LOO/intra/3cc_7893_intra_iphy.xml
    Get Scfc File    output_filepath=${CURDIR}/config/BOO_AP_LOO/intra/_scf.xml
    send full commissioning    input_filepath=${CURDIR}/config/BOO_AP_LOO/intra/3cc_7893_intra_scf.xml
    ${vlanId}=    Get Value From Scf    dist_name=${dist_name}   parameter_name=vlanId    scfc_filepath=${CURDIR}/config/BOO_AP_LOO/intra/_scf.xml
    check radios availability
    Perform Parameter Commissioning    dist_name=MRBTS-1/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-1    parameter=vlanId    value=${vlanId}
