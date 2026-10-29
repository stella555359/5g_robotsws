*** Settings ***
Documentation     [SUITE PURPOSE]   TC of CB014613 feature

...
...               Test Case Scenario author   : adrien.hervat@nokia.com

...               Creation Date               : 11-24-2025
...               Version History    Date           Author                      Notes
...               0.1                11-24-2025     adrien.hervat@nokia.com     Creation
...               1.0                02-13-2026     adrien.hervat@nokia.com     First delivery
...               1.1                03-03-2026     adrien.hervat@nokia.com     Update static threshold due to RJIO variant modification


Variables         ./resources/python/Constants-CB014613.py

Library           OperatingSystem
Library           Collections
Library           ArchiveLibrary

Resource          ./resources/robot/CB014613-Keywords.robot


Suite Setup                 Suite Setup for CB014613
Suite Teardown              Suite Teardown



*** Variables ***

&{params}                   feature=CB014613
...                         setup=0
...                         Alarm_RI=1   (2=alarm 7525 / 1=RIState in NRRIMINFO)
...                         duration=2
...                         deviation=20
...                         rdAutoRiThres=15


# ue's settings

&{dict_ue_1}                originalCell=1
...                         DL_throughput=2
...                         UL_throughput=2
...                         DL_throughput_GBR=0
...                         UL_throughput_GBR=0
...                         ue_nr_capa=${SA_TDD_RANK4}

&{dict_ue_2}                originalCell=1
...                         DL_throughput=2
...                         UL_throughput=2
...                         DL_throughput_GBR=0
...                         UL_throughput_GBR=0
...                         ue_nr_capa=${SA_TDD_RANK4}

&{dict_ue_3}                originalCell=2
...                         DL_throughput=2
...                         UL_throughput=2
...                         DL_throughput_GBR=0
...                         UL_throughput_GBR=0
...                         ue_nr_capa=${SA_TDD_RANK4}

&{dict_ue_4}                originalCell=2
...                         DL_throughput=2
...                         UL_throughput=2
...                         DL_throughput_GBR=0
...                         UL_throughput_GBR=0
...                         ue_nr_capa=${SA_TDD_RANK4}

&{dict_ue_5}                originalCell=3
...                         DL_throughput=2
...                         UL_throughput=2
...                         DL_throughput_GBR=0
...                         UL_throughput_GBR=0
...                         ue_nr_capa=${SA_TDD_RANK4}

&{dict_ue_6}                originalCell=3
...                         DL_throughput=2
...                         UL_throughput=2
...                         DL_throughput_GBR=0
...                         UL_throughput_GBR=0
...                         ue_nr_capa=${SA_TDD_RANK4}


@{dict_UEs_6}               ${dict_ue_1}
...                         ${dict_ue_2}
...                         ${dict_ue_3}
...                         ${dict_ue_4}
...                         ${dict_ue_5}
...                         ${dict_ue_6}


${Json_Fwk1_RJIO}           ${CURDIR}/config/delta_scf/Delta_Configuration_ASOE_Fwk1_TC15.json

${Constraint_File}          ${CURDIR}/config/counter/constraint/CB014613_2symbols_RI.csv

@{RI_Cells}=       1   2   3

@{riThresBasePerSubband_val1}=      -108    -108    -108    -108    -108
@{riThresBasePerSubband_val2}=       -96     -96     -96     -96     -96
@{riThresBasePerSubband_val3}=       -82     -82     -82     -82     -82


&{dico_RI_ON}               nrRimInfoId=1
...                         riState=RI detected
...                         riThresBasePerSubband=${riThresBasePerSubband_val1}

&{dico_RI_OFF}              nrRimInfoId=1
...                         riState=no RI
...                         riThresBasePerSubband=${riThresBasePerSubband_val2}

&{dico_RI_ON2}              nrRimInfoId=1
...                         riState=RI detected
...                         riThresBasePerSubband=${riThresBasePerSubband_val3}


*** Test Cases ***

[1]CB014613_RJIO_CVR-15-Check_Adjusted_RI_Detection_Thres_Per_Subband_Dynamically_Updated_FrameStructure
    TC_CB014613    params=${params}    dict_ues=${dict_UEs_6}
    [Teardown]     Setup.Test Teardown



*** Keywords ***

TC_CB014613

    [Arguments]           ${params}    ${dict_ues}
    Set Suite Variable    ${params}
    Init Sequence         ${params}
    Step                  Set RAD Params
    Step                  Get Vendor File
    Step                  Download BSR file
    Step                  Update of RIM Profiles               TC_json=${Json_Fwk1_RJIO}
    Step                  Set SCF Context
    Step                  Restart.F1 Wait Link Classical
    ${listOfUes}          Build UEs list SA Multi UEs          dict_ues=${dict_ues}
    Step                  Set SA UE_Capa Context_WTS CFG       listOfUes=${listOfUes}
    Step                  Start Syslogs
    Step                  Multi Cells Setup SA                 listOfUes=${listOfUes}
    Step                  SA Register PDU setup                listOfUes=${listOfUes}
    Step                  Start Traffic Multi UEs NonGBR       listOfUes=${listOfUes}
    Step                  Set Remote Interference Test Mode    list_cell=${RI_Cells}    ProfileAct=3
    Step                  Get NRRIMINFO or get RI Alarm        dico=${dico_RI_ON}       list_nrcell=${RI_Cells}
    Step                  Get NRRIMINFO or get RI Alarm        dico=${dico_RI_OFF}      list_nrcell=${RI_Cells}
    Step                  Set Remote Interference Test Mode    list_cell=${RI_Cells}    ProfileAct=1    ProfileDeact=3
    Step                  Get NRRIMINFO or get RI Alarm        dico=${dico_RI_ON2}      list_nrcell=${RI_Cells}
    Step                  Check Counters KPI                   Constraint_File=${Constraint_File}
    Step                  Stop Syslogs
    Step                  Start Traffic Multi UEs NonGBR       listOfUes=${listOfUes}
    Step                  SA DeRegister Multi UEs              listOfUes=${listOfUes}
    Step                  Get Snapshot Egate Iphy
    [Teardown]            Display diagnosis
