*** Settings ***
Documentation    Author: yonna.yao@nokia-sbell.com
...              \n AIC AP operate keywords.
Library    OperatingSystem

*** Variables ***

*** Keywords ***	
AIC AP Setup
    [Arguments]    ${iphy_xml}=${CONFIG_DIR_PATH}/${VDU_SW_BRANCH}/WTS/${AIRPHONE_NAME}
    ...    ${enb_ip}=${MASTER_VDU.hostname}    ${enb_user}=core     ${enb_pwd}=system123
    Log    Airphone setup
    Airphone Setup
    Get Airphone Software Version
    Get WTS Version
    ${iphy_xml}    Normalize Path     ${iphy_xml}
    ${iphy_xml2}    Normalize Path     ${CONFIG_DIR_PATH}/${AIRPHONE_NAME}
    ${status}    ${msg}     Run Keyword And Ignore Error    File Should Exist     ${iphy_xml}
    ${iphy_xml}     Set Variable If    '${status}'=='PASS'    ${iphy_xml}     ${iphy_xml2}
    change_vlan_id_in_iphy_xml     ${iphy_xml} 
    change_iphy_rru_version    ${iphy_xml}     enb_ip=${enb_ip}    enb_user=${enb_user}    enb_pwd=${enb_pwd}


AIC Get and Update BSR File
     [Arguments]      ${par_of_bsr_name}=BSR_AEQE_6_H6_ALN60
     Run    cd ${PRIVATE_LOCAL_PATH}/BSR_FILE;rm *.xml;rm *.tar;rm *.json
     ${bsr_file_path}     get BSR file name      ${par_of_bsr_name}
     Run    cd ${PRIVATE_LOCAL_PATH}/BSR_FILE/;unzip -o ${bsr_file_path}
     ${files}     List Files In Directory      ${PRIVATE_LOCAL_PATH}/BSR_FILE/        TargetBD*.xml
     VDU Login
     vdu.Trigger Sw Update     ${PRIVATE_LOCAL_PATH}/BSR_FILE/       ${files[0]} 
     ...     sw_update_type=BSR
     VDU Logout