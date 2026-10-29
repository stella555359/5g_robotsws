*** Settings ***
Documentation    Author: leo.y.wang@nokia-sbell.com
...              \n GNB common operate keywords.
Library     BuiltIn
Library     String
Library     Telnet
Library     Collections
Library     OperatingSystem
Library     ute_fsmaccess
Library     taf.sbts.oam.coam.admin    WITH NAME   COAM
#Library     ../python/tak_gnb/tak_gnb/base.py     WITH NAME    GNB_BASE
#Library     ../python/tak_gnb/tak_gnb/commission.py     WITH NAME    GNB_COMMISSION
Library     taf.transport.ssh    WITH NAME    SSH
#Resource    base.robot
#Resource    internal_gnb.robot
#Variables   scripts/gnb_randd_parameters.py
#Resource    internal_ssh.robot


*** Keywords ***
Get and Update BSR File
     [Arguments]      ${bsr_file_path}=BSR_AEQE_6_H6_ALN60
#     ${bsr_file_path}     get BSR file name      ${par_of_bsr_name}
     COAM.setup admin
     ${ret}     COAM.Update Software      ${bsr_file_path}
     COAM.teardown admin

Update Vendor File
     [Arguments]      ${vendor_path}     /home/ute/logs/vendor_ini.xml
     COAM.Setup Admin
     ${vendor_path}    Set Variable    /home/ute/logs/vendor_ini.xml
     COAM.Download Vendor File    ${vendor_path}
     Modify Vendor betaec XML File    ${vendor_path}
     Modify Vendor xec XML File    ${vendor_path}
     Modify Vendor 72e XML File    ${vendor_path}
     COAM.Set Vendor File    ${vendor_path}

Modify Vendor 72e XML File
    [Arguments]    ${vendor_path}
    ${vendor_list72e}    Set Variable    text|${ECPRI72E}|//*[@name\="actEcpri72e"]
    Modify Xml    ${vendor_path}    ${vendor_path}    ${vendor_list72e}
Modify Vendor betaec XML File
    [Arguments]    ${vendor_path}
    ${vendor_listbetaec}    Set Variable    text|${BETAEC}|//*[@name\="betaEc"]
    Modify Xml    ${vendor_path}    ${vendor_path}    ${vendor_listbetaec}
Modify Vendor xec XML File
    [Arguments]    ${vendor_path}
    ${vendor_listxec}    Set Variable    text|${XEC}|//*[@name\="xEc"]
    Modify Xml    ${vendor_path}    ${vendor_path}    ${vendor_listxec}

