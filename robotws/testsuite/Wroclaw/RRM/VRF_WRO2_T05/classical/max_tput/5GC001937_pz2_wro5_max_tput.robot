**** Settings ***
Documentation  Test suite for reporting of max TCP and UDP data throughputs to Reporting Portal as KPIs.
Library     ute_ue
Library     taf.sw.reporting_portal
Library     taf.rfrl.common_resources.python.report_to_rep
Library     taf.hw.rf_attenuator    WITH NAME    att
Resource    taf/rfrl/ue/robot/REAL_UE.robot
Resource    testsuite/Wroclaw/RRM/resources/logs.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/Commissioning_preparation/PreparingTestline.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/common_keywords.robot
Resource    testsuite/Wroclaw/RRM/resources/preconditions.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC000900/resources/keywords.robot

Force Tags      CA_5G_RRM   5G_RAN   5G_RAN_FDD_MP  RAN_5G  RAN_5G_FDD   RAN_5G_FDD_MP_CUSTOMER  RAN_5G_MP  STATE_SW_UPLOADED   CDRT
...   PY36      CLOUD_5G_CLASSICAL_QC_ASIBL_ABILB1_3xAHCA_ENB    SBTS00

Suite Setup     Run keywords
...             Connect to Coam    AND
...             Prepare and check TL   AND
...             Disconnect coam    AND
...             Connect to Coam    AND
...             Reserve UE SA   AND
...             logs.Upload GnbMirroring Script To ASIK   AND
...             Setup attenuators   AND
...             Commission with scf file   ${SCF_path}      is_pdl_checking_needed=${True}  AND
...             Wait until keyword succeeds    20 min    1 min    Verify all cells are onair with admin     AND
...             Wait until keyword succeeds    10 min    1 min      X2-C is available   AND
...             Disconnect coam

Test Teardown   Run Keyword
...             Run Keyword and Ignore Error  Detach UE SA

*** Variables ***
${tput_DL_bandwith}     41 Mbits/sec
${tput_UL_bandwith}     17 Mbits/sec
${tput_deviation}       10%
${tput_duration}        300s
${Packet_Size}          1450
${LOG_PATH}             /home/ute/tput/robotws/
@{lines_gNB_157_AHCA_1}        1   2   3   4
@{lines_gNB_157_AHCA_2}        5   6   7   8
@{lines_gNB_157_AHCA_3}        9   10   11   12
@{lines_LTE_157}               21    22
@{lines_gNB_159_AHCA_1}        13   14   15   16
@{lines_gNB_159_AHCA_2}        17   18
@{lines_gNB_159_AHCA_3}        19   20
@{lines_LTE_159}               23    24
${atten_ip}                  ${tl.attenuators[0].ip_addr}
${att_api_port}              ${tl.attenuators[0].port}
${atten_ports}               ${tl.attenuators[0].attenuator_ports}
${atten_model}               ${tl.attenuators[0].model}
${atten_vendor}              JFW
${max_attenuation_value}     ${90}
${SCF_path}       testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/max_tput/resources/7_16_UTE5GCLOUDT157_max_tput_scg.xml
*** Test Cases ***
[1]Bi-Directional_Throughput_noDss_NsaSa_TputSaUDP_AhcaS1_DL4x4CL_UL2x2CL_Bw5MhzAr178000
    Set initial attenuation AhcaS1
    Attach UE SA
    sleep  5s
    Start ULDL UDP   UE_1
    sleep  5
    ute_ue.Await Data Transfer Finish                 DT_UL
    ute_ue.Await Data Transfer Finish                 DT_DL
	Detach UE SA
    [Teardown]  Run Keywords
    ...         Run Keyword and Ignore Error    Add scout external execution id to the reporting portal  AND
    ...         Run Keyword and Ignore Error    Report KPIs and Configuration to Reporting Portal
    ...         logs_dir=${LOG_PATH}/data_transfer  ue_alias=UE_1
    ...         tput_dl=${tput_DL_bandwith}  tput_ul=${tput_UL_bandwith}  protocol=udp  deviation=${tput_deviation}
[1]Bi-Directional_Throughput_noDss_NsaSa_TputSaTCP_AhcaS1_DL4x4CL_UL2x2CL_Bw5MhzAr178000
    Set initial attenuation AhcaS1
    Attach UE SA
    sleep  5s
    Start ULDL TCP   UE_1
    sleep  5s
    ute_ue.Await Data Transfer Finish                 DT_UL
    ute_ue.Await Data Transfer Finish                 DT_DL
    Detach UE SA
    [Teardown]  Run Keywords
    ...         Run Keyword and Ignore Error    Add scout external execution id to the reporting portal  AND
    ...         Run Keyword and Ignore Error    Report KPIs and Configuration to Reporting Portal
    ...         logs_dir=${LOG_PATH}/data_transfer   ue_alias=UE_1
    ...         tput_dl=${tput_DL_bandwith}  tput_ul=${tput_UL_bandwith}  protocol=tcp  deviation=${tput_deviation}
[1]Bi-Directional_Throughput_noDss_NsaSa_TputSaTCP_AhcaS2_DL4x4CL_UL2x2CL_Bw5MhzAr178000
    Set initial attenuation AhcaS2
    Attach UE SA
    sleep  5s
    Start ULDL TCP   UE_1
    sleep  5s
    ute_ue.Await Data Transfer Finish                 DT_UL
    ute_ue.Await Data Transfer Finish                 DT_DL
    Detach UE SA
    [Teardown]  Run Keywords
    ...         Run Keyword and Ignore Error    Add scout external execution id to the reporting portal  AND
    ...         Run Keyword and Ignore Error    Report KPIs and Configuration to Reporting Portal
    ...         logs_dir=${LOG_PATH}/data_transfer   ue_alias=UE_1
    ...         tput_dl=${tput_DL_bandwith}  tput_ul=${tput_UL_bandwith}  protocol=tcp  deviation=${tput_deviation}
[1]Bi-Directional_Throughput_noDss_NsaSa_TputSaTCP_AhcaS3_DL4x4CL_UL2x2CL_Bw5MhzAr178000
     Set initial attenuation AhcaS3
     Attach UE SA
     sleep  5s
     Start ULDL TCP   UE_1
     sleep  5s
     ute_ue.Await Data Transfer Finish                 DT_UL
     ute_ue.Await Data Transfer Finish                 DT_DL
     Detach UE SA
    [Teardown]  Run Keywords
    ...         Run Keyword and Ignore Error    Add scout external execution id to the reporting portal  AND
    ...         Run Keyword and Ignore Error    Report KPIs and Configuration to Reporting Portal
    ...         logs_dir=${LOG_PATH}/data_transfer   ue_alias=UE_1
    ...         tput_dl=${tput_DL_bandwith}  tput_ul=${tput_UL_bandwith}  protocol=tcp  deviation=${tput_deviation}
*** Keywords ***
Reserve UE SA
    ute_ue.Require Ue    UE_1    capabilities=REAL_ANDROID_UE_SA
Attach UE SA
    ute_ue.Attach Ue   UE_1
Detach UE SA
    ute_ue.Detach Ue  UE_1
Reserve UE NSA
    ute_ue.Require Ue    UE_2    capabilities=REAL_ANDROID_UE_NSA
Attach UE NSA
    ute_ue.Attach Ue   UE_2
Detach UE NSA
    ute_ue.Detach Ue  UE_2
Start ULDL UDP
    [Arguments]   ${ue_id}
    ute_ue.Start Data Transfer  dt_name=DT_DL  ue_alias=${ue_id}  direction=dl  duration=${tput_duration}
    ...                  throughput=${tput_DL_bandwith}              protocol=udp	   packet_size=${Packet_Size}
    ute_ue.Start Data Transfer  dt_name=DT_UL  ue_alias=${ue_id}  direction=ul  duration=${tput_duration}
    ...                  throughput=${tput_UL_bandwith}              protocol=udp
    Sleep                10s
    ute_ue.Check Data Transfer Is Alive               DT_UL
    ute_ue.Check Data Transfer Is Alive               DT_DL
Start ULDL TCP
    [Arguments]   ${ue_id}
    ute_ue.Start Data Transfer  dt_name=DT_DL  ue_alias=${ue_id}  direction=dl  duration=${tput_duration}
    ...                  throughput=${tput_DL_bandwith}              protocol=tcp	   packet_size=${Packet_Size}
    ute_ue.Start Data Transfer  dt_name=DT_UL  ue_alias=${ue_id}  direction=ul  duration=${tput_duration}
    ...                  throughput=${tput_UL_bandwith}              protocol=tcp
    Sleep                10s
    ute_ue.Check Data Transfer Is Alive               DT_UL
    ute_ue.Check Data Transfer Is Alive               DT_DL
Setup attenuators
    att.Setup attenuator    ip_addr=${atten_ip}    port=${att_api_port}
    ...    attenuation_port_numbers=${atten_ports}    max_attenuation=${max_attenuation_value}    vendor=${atten_vendor}
    ...    model=${atten_model}
Set attenuation and check
    [Arguments]      ${lines}    ${value}
    FOR    ${line}    IN    @{lines}
        att.Set attenuation     port=${${line}}     value=${${value}}
        ${value_port}    att.Read attenuation    port=${${line}}
        Should be equal    ${value_port}    ${${value}}
    END
Set initial attenuation AhcaS1
    Set attenuation and check  lines=${lines_gNB_157_AHCA_1}   value=0
    Set attenuation and check  lines=${lines_gNB_157_AHCA_2}   value=90
    Set attenuation and check  lines=${lines_gNB_157_AHCA_3}   value=90
    Set attenuation and check  lines=${lines_gNB_159_AHCA_1}   value=90
    Set attenuation and check  lines=${lines_gNB_159_AHCA_2}   value=90
    Set attenuation and check  lines=${lines_gNB_159_AHCA_3}   value=90
    Set attenuation and check  lines=${lines_LTE_157}   value=0
    Set attenuation and check  lines=${lines_LTE_159}   value=90
Set initial attenuation AhcaS2
    Set attenuation and check  lines=${lines_gNB_157_AHCA_1}   value=90
    Set attenuation and check  lines=${lines_gNB_157_AHCA_2}   value=0
    Set attenuation and check  lines=${lines_gNB_157_AHCA_3}   value=90
    Set attenuation and check  lines=${lines_gNB_159_AHCA_1}   value=90
    Set attenuation and check  lines=${lines_gNB_159_AHCA_2}   value=90
    Set attenuation and check  lines=${lines_gNB_159_AHCA_3}   value=90
    Set attenuation and check  lines=${lines_LTE_157}   value=0
    Set attenuation and check  lines=${lines_LTE_159}   value=90
Set initial attenuation AhcaS3
    Set attenuation and check  lines=${lines_gNB_157_AHCA_1}   value=90
    Set attenuation and check  lines=${lines_gNB_157_AHCA_2}   value=90
    Set attenuation and check  lines=${lines_gNB_157_AHCA_3}   value=0
    Set attenuation and check  lines=${lines_gNB_159_AHCA_1}   value=90
    Set attenuation and check  lines=${lines_gNB_159_AHCA_2}   value=90
    Set attenuation and check  lines=${lines_gNB_159_AHCA_3}   value=90
    Set attenuation and check  lines=${lines_LTE_157}   value=0
    Set attenuation and check  lines=${lines_LTE_159}   value=90
Commission with scf file
    [Arguments]  ${scf_file_path}    ${connection}=cOAM    ${timeout}=300    ${is_pdl_checking_needed}=${True}
    &{result}    coam.perform_commissioning    scf_file=${scf_file_path}
    ...    timeout=${timeout}    skip_parameter_relation_errors=${True}    connection=${connection}
    Should be equal as strings    ${result['commissioningResult']['activationResult']['resultNode']['parameters']['result']}    Success
    ...    msg=Commissioned with error exists, activation result is not in success status.    ignore_case=${True}
    Should be equal as strings    ${result['validationResult']['niddValidationResult']['status']}    OK
    ...    msg=Commissioned with error exists, nidd validation result is not in OK status    ignore_case=${True}
    Run keyword if    ${is_pdl_checking_needed}==${True}
    ...    Should be equal as strings    ${result['validationResult']['pdlValidationResult']['status']}    OK
    ...        msg=Commissioned with error exists, pdl validation result is not in OK status.    ignore_case=${True}
    [Return]  ${result}
