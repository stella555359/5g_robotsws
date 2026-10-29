*** Settings ***
Documentation     [SUITE PURPOSE]   TC of CB011127-A feature

...
...               Test Case Scenario author   : adrien.hervat@nokia.com

...               Creation Date               : 24-12-2024
...               Version History    Date           Author                      Notes
...               1.0                29-07-2025     adrien.hervat@nokia.com     First delivery



Variables         ./resources/python/Constants-CB011127.py

Library           OperatingSystem
Library           Collections
Library           ArchiveLibrary

Resource          ./resources/robot/CB011127-Keywords.robot


Suite Setup                 Suite Setup for CB011127     custom_bsr_update=${params.setup}

Suite Teardown              Suite Teardown



*** Variables ***

&{params}                   duration=2
...                         deviation=100
...                         setup=0


# ue's settings

&{dict_ue_1}                originalCell=1
...                         DL_throughput=2
...                         UL_throughput=2
...                         DL_throughput_GBR=0
...                         UL_throughput_GBR=0
...                         ue_nr_capa=${SA_TDD_RANK4}

&{dict_ue_2}                originalCell=2
...                         DL_throughput=2
...                         UL_throughput=2
...                         DL_throughput_GBR=0
...                         UL_throughput_GBR=0
...                         ue_nr_capa=${SA_TDD_RANK4}

&{dict_ue_3}                originalCell=3
...                         DL_throughput=2
...                         UL_throughput=2
...                         DL_throughput_GBR=0
...                         UL_throughput_GBR=0
...                         ue_nr_capa=${SA_TDD_RANK4}

&{dict_ue_4}                originalCell=4
...                         DL_throughput=2
...                         UL_throughput=2
...                         DL_throughput_GBR=0
...                         UL_throughput_GBR=0
...                         ue_nr_capa=${SA_TDD_RANK4}

&{dict_ue_5}                originalCell=5
...                         DL_throughput=2
...                         UL_throughput=2
...                         DL_throughput_GBR=0
...                         UL_throughput_GBR=0
...                         ue_nr_capa=${SA_TDD_RANK4}

&{dict_ue_6}                originalCell=6
...                         DL_throughput=2
...                         UL_throughput=2
...                         DL_throughput_GBR=0
...                         UL_throughput_GBR=0
...                         ue_nr_capa=${SA_TDD_RANK4}


@{dict_UEs_4}               ${dict_ue_1}
...                         ${dict_ue_2}
...                         ${dict_ue_3}
...                         ${dict_ue_4}

@{dict_UEs_6}               ${dict_ue_1}
...                         ${dict_ue_2}
...                         ${dict_ue_3}
...                         ${dict_ue_4}
...                         ${dict_ue_5}
...                         ${dict_ue_6}

${TC_B_001}                 ${CURDIR}/config/delta_scf/Delta_Configuration_TC_B_001.json

${Constraint_File_ASOE}     ${CURDIR}/config/counter/constraint/CB011127_ASOE_B_001.csv

@{RIM_cell_B_001}=     1   2   3   4

@{RD_Min_Val}=       100   100   100   100
@{RD_Max_Val}=       130   130   130   130


*** Test Cases ***

[1]CB011127-SR-B_001_Interworking_with_CB009022_Half_ASOE_4_Cells_8DL8UL_with_PRB_pooling
    TC_CB011127_RI_Detection_ASOE_B_001    params=${params}    dict_ues=${dict_UEs_4}
    [Teardown]       Setup.Test Teardown



*** Keywords ***

TC_CB011127_RI_Detection_ASOE_B_001

    [Arguments]           ${params}    ${dict_ues}
    Set Suite Variable    ${params}
    Init Sequence         ${params}
    Step                  Set RAD Params for 11127
    Step                  Get Vendor File
    Step                  Update RIM Profile for all cells and bbmodBoardConfigType    TC_json=${TC_B_001}
    Step                  Set 11127 Context TDD
    Step                  Restart.F1 Wait Link Classical
    ${listOfUes}          Build UEs list SA Multi UEs         dict_ues=${dict_ues}
    Step                  Set SA UE_Capa Context_WTS CFG      listOfUes=${listOfUes}
    Step                  Start Syslogs 11127
    Step                  Multi Cells Setup SA for 11127      listOfUes=${listOfUes}
    Step                  SA Register PDU setup               listOfUes=${listOfUes}
    Step                  Start Traffic Multi UEs NonGBR      listOfUes=${listOfUes}
    Step                  Set Remote Interference Test Mode
    Step                  Set RimRs Test Mode Framework 1
    Step                  Get Remote Interference Alarm       fault_id=7525    list_cell=${RIM_cell_B_001}
    Step                  Get Remote Interference Alarm       fault_id=7527    info=Both RIM RS1 and RS2 are detected    list_cell=${RIM_cell_B_001}
    Step                  Stop Syslogs 11127
    Step                  Check Counters KPI                  Constraint_File=${Constraint_File_ASOE}
    Step                  Check R&D Counters                  Min=${RD_Min_Val}    Max=${RD_Max_Val}
    Step                  Get TTI Logs
    Step                  Get L1L2 Logs
    Step                  Start Traffic Multi UEs NonGBR      listOfUes=${listOfUes}
    Step                  SA DeRegister Multi UEs             listOfUes=${listOfUes}
    Step                  Get Snaphot Sos Report
    Step                  Get Iphy.xml
    Step                  Get Egate Console Log
    [Teardown]            Display diagnosis
