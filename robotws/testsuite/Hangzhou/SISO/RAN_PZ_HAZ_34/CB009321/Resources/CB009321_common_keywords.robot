*** Settings ***


Documentation
...    author: Chen Shufei
...    contact: shufei.chen@nokia-sbell.com
...    Group: HGZ_SG8

*** Variables ***
${origrin_scf}    ${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/SCF_SBTS00.xml

*** Keywords ***
CB009321_General_SiSo_Cell_lock_and_unlock
    [Arguments]  ${with_call}=${True}  ${with_peak}=${False}    ${4G_check}=${False}
    Get X2 link shutdown waiting time
    ${cell_id_list}  Get All Cell Id
    ${cell_num}    get length  ${cell_id_list}
    Lock and Unlock Cells or Groups and L3  lock_list=${cell_id_list}  is_group=${False}  with_call=${with_call}
    ...    with_peak=${with_peak}    4G_check=${4G_check}
    Connect to gnb coam via ssl
    run keyword if  ${cell_num}>1  Lock and Unlock all Cells or Groups  lock_list=${cell_id_list}  is_group=${False}

