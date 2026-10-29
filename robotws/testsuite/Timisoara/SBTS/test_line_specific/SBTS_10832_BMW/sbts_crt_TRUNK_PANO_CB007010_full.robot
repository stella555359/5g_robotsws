*** Settings ***
Force Tags        QCD_MN_RAN    QCP_RAN_ST    CRT    CLOUD_SRAN    SBTS00
Library           XML  use_lxml=True
Resource          ../../ONAP/CB007010-G_Check_PM_files.robot

*** Variables ***
${SCF_ID}         01
${COMMISSIONING_PATH}
    ...    /home/ute/MN/UTE/robotws/testsuite/Wroclaw/OAM/RAN_PZ_WRO3_SG05/test_line_specific/SBTS_8087_Paracopter/commissioning/SCF_01_TRUNK.xml

${VM_WITH_PANO_IP}       10.44.157.22
${VM_WITH_PANO_USR}      ute
${VM_WITH_PANO_PASSWD}   Ut3pa5s#1be1
${VES_PORT}              30510
${TL_REPO_PATH}          /home/ute/MN/UTE/robotws/testsuite/Wroclaw/OAM/RAN_PZ_WRO3_SG05/test_line_specific/SBTS_8087_Paracopter/commissioning

*** Test Cases ***
[1]CB007010-G_Check_PM_files
    [Setup]    Run Keywords    CB007010-G_Check_PM_files.TC Setup
    ...    AND    Modify Resource Search Order    CB007010-G_Check_PM_files
    ...    AND    Set Library Search Order    CB007010-G_Check_PM_files
    [Timeout]    14400
    TC__CB007010-G_Check_PM_files
    [Teardown]    Run Keywords    CB007010-G_Check_PM_files.TC Teardown
    ...    AND    Restore Resource Search Order

*** Keywords ***

