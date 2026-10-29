*** Settings ***
Documentation  PANO test cases on vDU.

Resource    /home/ute/MN/UTE/robotws/testsuite/Timisoara/CBTS/PM/test_resources/PM__vDU__Check_PM_File_On_Pano_Server.robot
Resource    /home/ute/MN/UTE/robotws/testsuite/Timisoara/CBTS/PM/test_resources/PM__vDU__3GPP_XML_Measurement_File_Enrichment_Reset_Site.robot
Resource    /home/ute/MN/UTE/robotws/testsuite/Timisoara/CBTS/PM/test_resources/PM__vDU__Break_Connection_To_Pano.robot


*** Variables ***
${VDU_OAM_IP}  10.15.218.42
${VDU_MRBTS_ID}  11131
${VDU_MRBTS_NAME}  vdu36
${VDU_NRBTS_ID}  14
${BTS_FILES}  /home/ute/logs/pm_file_enrich_vdu
${VM_WITH_PANO_IP}  10.5.47.47
${VM_WITH_PANO_USR}  ute
${VM_WITH_PANO_PASSWD}  UTE.debian12
${VDU_SSH_IP}  10.15.218.2
${VDU_SSH_USERNAME}  core
${VDU_SSH_PASSWORD}  system123
${VDU_CRAN}  cran1


*** Test Cases ***
vDU__Check_PM_File_On_Pano_Server
    [Setup]  Run Keywords
    ...  Connect To VDU  host=${VDU_OAM_IP}
    ...  AND  Turn ON Pano And Check If Is Connected
    ...  AND  Modify Resource Search Order  PM__vDU__Check_PM_File_On_Pano_Server

    TC__PM__vDU__Check_PM_File_On_Pano_Server

    [Teardown]  Run Keywords
    ...  Turn OFF Pano And Check If Is Disconnected
    ...  AND  vdu.Disconnect


vDU__3GPP_XML_Measurement_File_Enrichment_Reset_Site
    [Setup]  Run Keywords
    ...  Connect To VDU  host=${VDU_OAM_IP}
    ...  AND  Turn ON Pano And Check If Is Connected
    ...  AND  Modify Resource Search Order  PM__vDU__3GPP_XML_Measurement_File_Enrichment_Reset_Site

    TC__PM__vDU__3GPP_XML_Measurement_File_Enrichment_Reset_Site

    [Teardown]  Run Keywords
    ...  Restore Original Names
    ...  AND  Turn OFF Pano And Check If Is Disconnected
    ...  AND  vdu.Disconnect


vDU__Break_Connection_To_Pano
    [Setup]  Run Keywords
    ...  Connect To VDU  host=${VDU_OAM_IP}
    ...  AND  Turn ON Pano And Check If Is Connected
    ...  AND  Modify Resource Search Order  PM__vDU__Break_Connection_To_Pano

    TC__PM__vDU__Break_Connection_To_Pano

    [Teardown]  Run Keywords
    ...  Turn OFF Pano And Check If Is Disconnected
    ...  AND  vdu.Disconnect
