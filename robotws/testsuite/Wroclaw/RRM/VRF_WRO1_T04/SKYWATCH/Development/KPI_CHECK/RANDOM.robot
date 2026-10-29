*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE
...           CONFIGURED    CRT    RAN_5G_TDD    RAN_5G    SBTS00

Documentation    :copyright: Nokia
...              :authors: Mateusz Bilewicz
...              :contact: mateusz.bilewicz@nokia.com

Variables    ta5g_global_var
Resource    resources/5G_SW_WRO_Keywords.robot
Resource    resources/Skywatch_keywords.robot
Resource    resources/KPI_related_keywords.robot
Library    resources/KPI_related_keywords.py
Library    resources/tput_scen.py
Library    resources/Python/webem_alarms.py
Library    ta5g_admin_operations
#Resource     resources/configuration_id.robot

*** Variables ***
@{SWCONFIG_FLAGS}=      0x5808FF=2

${list_of_mocs}    NRPMCCP_A  NRBTS_A
*** Test Cases ***
NR_5101b_CHECK
    ${list_of_reest_ues}=    Create List
    ${list_of_all_ues}=    Create Ues List
    ...  ue_start=${1}
    ...  ue_stop=${40}

    ${value}=    Get Admin Object Parameter Value
                 ...  moc=NRPMCCP_A
                 ...  parameter_name=cfgTAcounters

    Log to console    ${value}
#    Start TTI trace
#    Sleep    1s
#    Stop TTI trace
#    Convert TTI trace from pcap to excelCsv

#    Deregister 40 UEs
