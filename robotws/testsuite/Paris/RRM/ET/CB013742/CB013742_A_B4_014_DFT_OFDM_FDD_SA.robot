*** Settings ***
Documentation     [SUITE PURPOSE]   TC of CB013742-A feature

...
...               Test Case Scenario author   : adrien.hervat@nokia.com

...               Creation Date               : 10-09-2024
...               Version History    Date           Author                      Notes
...               0.1                10-09-2024     adrien.hervat@nokia.com     Creation
...               1.0                16-06-2025     adrien.hervat@nokia.com     First Delivery
...               1.1                23-06-2025     adrien.hervat@nokia.com     PRB Randomization new algo addition



Variables         ./resources/python/Constants-CB013742.py

Library           OperatingSystem
Library           Collections
Library           ArchiveLibrary

Resource          ./resources/robot/CB013742-Keywords.robot


Suite Setup                 Suite Setup for CB013742     custom_bsr_update=${params.setup}

Suite Teardown              Suite Teardown



*** Variables ***

&{params}                   duration=1
...                         deviation=20
...                         setup=0

# ue's settings

&{dict_ue_1}                originalCell=1
...                         DL_throughput=0
...                         DL_throughput_GBR=0
...                         UL_throughput=1
...                         ue_nr_capa=${SA_FDD}

&{dict_ue_2}                originalCell=1
...                         DL_throughput=0
...                         DL_throughput_GBR=0
...                         UL_throughput=1
...                         ue_nr_capa=${SA_FDD}



@{dict_settings_all}        ${dict_ue_1}
...                         ${dict_ue_2}

# Cells parameters

@{subcell1}=    0   2
@{subcell2}=    1   3


&{Cell1_Conf}                         CellId=50
...                                   SubCellId=${subcell1}

&{Cell2_Conf}                         CellId=51
...                                   SubCellId=${subcell2}

@{List_Cells}                         ${Cell1_Conf}
...                                   ${Cell2_Conf}



*** Test Cases ***

[1]CB013742-SR-A-B4_014_PUSCH start PRB randomization during transient phase triggered by dynamic transform precoder switching - FDD
    TC_CB013742-A-SA-FDD    params=${params}    dict_ues=${dict_settings_all}
    [Teardown]       Setup.Test Teardown



*** Keywords ***

TC_CB013742-A-SA-FDD

    [Arguments]            ${params}    ${dict_ues}
    Set Suite Variable     ${params}
    Init Sequence          ${params}
    Step                   Set RAD Params for 13742
    Step                   Set 13742 Context FDD
    Step                   Restart.F1 Wait Link Classical
    ${listOfUes}           Build UEs list SA Multi UEs          dict_ues=${dict_ues}
    Step                   Set SA UE_Capa Context_WTS CFG       listOfUes=${listOfUes}
    Step                   Start Syslogs 13742
    Step                   Multi Cells Setup SA for 13742       listOfUes=${listOfUes}
    Step                   SA Register PDU setup                listOfUes=${listOfUes}
    Step                   Start L1L2 Logs
    Step                   Start TTI Logs 13742
    Step                   Start Traffic Multi UEs NonGBR       listOfUes=${listOfUes}
    Step                   Decrease SINR TO Trigger TransformPrecoder Enabled    pathloss=130    ue_id=1
    Step                   Increase SINR TO Trigger TransformPrecoder Disabled    ue_id=1
    Step                   Decrease SINR TO Trigger TransformPrecoder Enabled    pathloss=130    ue_id=2
    Step                   Increase SINR TO Trigger TransformPrecoder Disabled    ue_id=2
    Step                   Stop TTI Logs 13742
    Step                   Stop L1L2 Logs
    Step                   Start Traffic Multi UEs NonGBR       listOfUes=${listOfUes}
    Step                   Check DCI UL_0_0_FORCE is not used
    Step                   Check PRB randomization on PUSCH during RRC Reconfiguration DFT
    Step                   Stop Syslogs 13742
    Step                   SA DeRegister Multi UEs              listOfUes=${listOfUes}
    Step                   Get Snaphot Sos Report
    Step                   Get Iphy.xml
    Step                   Get Egate Console Log
    [Teardown]             Display diagnosis