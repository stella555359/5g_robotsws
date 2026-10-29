*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE
...           CONFIGURED    CRT    RAN_5G_TDD    RAN_5G    SBTS00

Documentation    :copyright: Nokia
...              :authors: Mateusz Bilewicz
...              :contact: mateusz.bilewicz@nokia.com

Resource    ../resources/5G_SW_WRO_Keywords.robot
Resource    ../CB009086/resources/9086_keywords.robot
Resource    resources/CB008367-A_keywords.robot
Library    CB008367.py
Library    ../resources/Python/webem_alarms.py
Library    ../CB008697/CB008697_keywords.py
Library    ../CB009086/resources/9086_keywords.py
Resource     ../resources/configuration_id.robot


*** Test Cases ***
KONWERTER
    Convert TTI trace from pcap to excelCsv
