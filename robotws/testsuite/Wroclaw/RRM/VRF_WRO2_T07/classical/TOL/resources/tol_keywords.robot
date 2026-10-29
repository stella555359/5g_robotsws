*** Settings ***
Documentation
...   maintainer: Bartosz Kozlowski
...   contact: bartosz.1.kozlwski@nokia.com
...   Keywords used in TOL automated tests

Library          ./tol_keywords.py
Library          testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_utils.AdminUtils    WITH NAME    AdminUtils
Library          testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/attenuator_keywords.py
Library          taf.ue



*** Keywords ***
Prepare Attenuator For Test
    [Arguments]    ${ports_to_nullify}
    Initialise Attenuator
    Attenuate All Ports
    Set Attenuation             value_string=0            port=${ports_to_nullify}

Collect Average Data Transfer
    Log To Console    Attaching UE and starting data transfer
    Attach UE     UE_1
    Start data transfer   dt_name=DT_DL               ue_alias=UE_1                     direction=dl       duration=60s
    ...                   packet_size=1200            throughput=10 Gbits/sec           protocol=udp
    ...                   iperf_version=3
    Await Data Transfer Finish    dt_name=DT_DL
    Log To Console     Transfer finished
    ${average_dl_tput}=    Get Average Throughput    dt_name=DT_DL
    Log To Console     Average tput: ${average_dl_tput}
    Detach Ue    UE_1
    [Return]    ${average_dl_tput}

Prepare List Of Modules For Test
    [Arguments]    ${module}
    @{modules}    Create List    ${module}
    [Return]    ${modules}
