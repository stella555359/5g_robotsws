*** Settings ***
Resource          internal_upgrade.robot
Resource          common_gnb.robot
Resource          common_airphone.robot
Library           String
*** Variables ***

*** Keywords ***
upgrade gnb and check status
    [Arguments]    ${sw_build}=${GNB_SW_BUILD}
    set test variable    ${sw_build}    ${sw_build}
    Get GNB Software Version
    RUN keyword IF    '${SW_VERSION_TOTAL}'=='${sw_build}'    Return From Keyword
    gnb package download    ${sw_build}
    gnb check status
    gnb upgrade software with admin   
    gnb check status
    gnb check sw info
   	Get GNB Software Version 


upgrade ap and check status
    [Arguments]       ${ap_bd}=${AP_SW_BUILD}
    RUN keyword IF    '${ue_ip}'!='${ap_ip}'    Return From Keyword
    Get WTS Version
    Get Airphone Software Version   
    ${ap_bd}   	Replace String	   ${ap_bd}     5G_    ${EMPTY}
    run keyword IF    '${WTS_VERSION}'=='${ap_bd}'    Return From Keyword
    set test variable    ${ap_bd}    ${ap_bd}
    ap get hw type    
    ap packages download
    ap update with yaft
    ap dci link operation
    ap set domain id
    ap relink esimode to latest dir
    ap version check
    reboot_operate     ${ap_ip}










 