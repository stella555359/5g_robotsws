*** Settings ***
Documentation     author: Dong Tingting
...               contact: tingting.dong@nokia-sbell.com
...               squad group: MMW_02


*** Variables ***
${ru_ip_addr}    ${tl.gnbs[0].dus[0].rus[0].default_ssh_connection_details.addr}
${ProdFile}           /mnt/factory/configs/unit/core_assembly_product_code.txt
${Origin_ProdFile}    /mnt/factory/configs/unit/Origin_core_assembly_product_code.txt
# ${Variant_ProdFile}    Variant_core_assembly_product_code

${MRBTS_id}      ${tl.gnbs[0].instance_id}

*** Keywords ***
HW_Product_Code_Change_and_Check_Onair
    [Arguments]    ${prodc_Origin}    ${prodc_Variant}
    log to console    \n HW Product Code Change
    Connect to Common Unit Master
    Connect to RU With Allocated IP  ru_index=${1}  ru_alias=RU_${1}
    sleep    2s
    ${status}    run keyword and return status    check_current_product_code    expect_product_code=${prodc_Variant}    connection=RU_${1}
    run keyword if  not ${status}    Run Keywords
    ...    Modify_File_On_RU_Unit    current_name=${ProdFile}    new_name=${Origin_ProdFile}    AND
    ...    sleep    1s    AND
    ...    New_File_On_RU_Unit    new_prodc=${prodc_Variant}    new_name=${ProdFile}    AND
    ...    sleep    1s    AND
    ...    check_current_product_code    expect_product_code=${prodc_Variant}    connection=RU_${1}    AND
    ...    sleep    1s    AND
    ...    csn.reset_cache
    sleep    5s
    set_RU_prodCodePlanned    prodc=${prodc_Variant}
    sleep    5s
    Perform BTS Site Reset    download_dir=${SAVE LOG DIRECTORY}
    log to console    \n Performed BTS Site Reset
    sleep    120s
    coam wait gnb and cells ready    timeout=20min    gnb_type='${gNb_CuType}'

check_current_product_code
    [Arguments]    ${expect_product_code}    ${connection}=RU_${1}
    csn.send_command    command=cat ${ProdFile}    connection=${connection}
    ${result}    csn.read_output    connection=${connection}
    Should contain   ${result}   ${expect_product_code}
    log to console  \n***check_current_product_code:${expect_product_code}***

Modify_File_On_RU_Unit
    [Arguments]    ${current_name}    ${new_name}    ${ru_conn}=RU_${1}
    ${mv_cmd}    Set Variable    mv -f ${current_name} ${new_name};mv -f ${current_name}.md5 ${new_name}.md5;
    csn.send_command    command=${mv_cmd}    connection=${ru_conn}
    sleep    2s
    log to console  \n***Modified_"${current_name}"_to_"${new_name}"_on_Unit***

New_File_On_RU_Unit
    [Arguments]    ${new_prodc}    ${new_name}    ${ru_conn}=RU_${1}
    ${new_cmd}    Set Variable    echo ${new_prodc}.101 > ${new_name};md5sum ${new_name} > ${new_name}.md5
    csn.send_command    command=${new_cmd}    connection=${ru_conn}
    sleep    2s  
    log to console  \n***newed_"${new_prodc}"_to_"${new_name}"_on_Unit***

set_RU_prodCodePlanned
    [Arguments]    ${prodc}    ${ru_index}=1
    selenium login and disable screen lock
    selenium_coam.set_parameter_value
    ...    dist_name=MRBTS-${MRBTS_id}/EQM-1/APEQM-1/RMOD-${ru_index}    filter_param=Product code planned    new_value=${prodc}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${True}
    log to console  \n *** RU prodCodePlanned has been changed to ${prodc} ***
    [Teardown]  Selenium Logout And Close Browser
