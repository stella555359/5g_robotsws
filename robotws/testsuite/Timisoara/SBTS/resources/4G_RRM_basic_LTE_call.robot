*** Settings ***
Documentation     [PURPOSE] RRM call from HZ
Library           taf.sbts.oam.coam.admin
Library           ute_admin_infomodel
##Library           hran_logging
Library           XML  use_lxml=${TRUE}
Library           OperatingSystem
Resource          hran_admin.robot
Resource          hran_frame_sbts.robot
Resource          hran_infomodel.robot
Resource          hran_uem.robot


*** Keywords ***
Basic LTE call
    [Documentation]
    ...  KW performs basic LTE call with defined paramteres.
    ...  UEs used in the KW are taken from the list given in argument, not from .yaml file.
    ...  *AUTHOR*
    ...  krzysztof.1.kowalski@nokia.com
    [Arguments]    ${ue_list}  ${bw}=100M  ${dl_max}=95000000  ${dl_min}=100000  ${ul_max}=35000000  ${ul_min}=350000
    Log   LTE call will be executed console=True
    Register UE PC  UEPC  ${UEPC['ip']}  ${UEPC['pyro_port']}  ${UEPC['username']}  ${UEPC['password']}
    Register FTP  FTP  ${FTP_1['ip']}  ${FTP_1['user']}  ${FTP_1['password']}
    @{ue_list}=  split string  ${ue_list}
    FOR  ${ue_serial}  IN  @{ue_list}
        Register UE  ${ue_serial}  ${ue_serial}  UEPC
        Recover UE  ${ue_serial}  UEPC
        Restart airplane mode on UE  ${ue_serial}
        ${cell_attached} =  Get cell ID  ${ue_serial}
        ${lnbts_id} =  Evaluate  ${cell_attached}/256
        ${lcrid} =  Evaluate  ${cell_attached}%256
        Log  Cell ID= ${cell_attached}  console=True
        Log  LNBTS ID= ${lnbts_id}  console=True
        Log  Cell number= ${lcrid}  console=True
        Make PS call  ${ue_serial}  10  UDP  ${bw}  ${dl_max}  ${dl_min}  ${ul_max}  ${ul_min}
    END
