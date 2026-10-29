*** Settings ***
Documentation     Development test cases for future upgrade purposes. Targeting to be a CIT instance.
    ...  TOPOLOGY: CLOUD_5G_CLASSICAL_ANDROID_ATT_ASILL_ABILB1B2_2xAEQN_FRGY
    ...  VARIANTS: CB0013553 -> uplink CA is configured here

Resource  testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/multi_ue.robot
Resource  testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/logs_collection.robot
Resource  testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/ute_report.robot
Resource  testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/attenuators.robot

Test Setup  Run Keywords
...  get ues  ${ues}  REAL_ANDROID_MTK                      AND
...  Setup attenuators  atten_ip=${attenuator['ip']}
...                     att_api_port=3001
...                     atten_ports=${attenuator['ports']}
...                     atten_model=${attenuator['model']}  AND
...  Start syslog capture

Test Teardown  Run Keywords
...  Add Scout Data Info To Testcase  AND
...  Collect snapshot if test failed  AND
...  Stop syslog capture

*** Variables ***
&{attenuator}  ip=${tl.attenuators[1].ip_addr}
...            port=${tl.attenuators[1].port}
...            ports=${tl.attenuators[1].attenuator_ports}
...            model=${tl.attenuators[1].model}
@{ues}  ue1
@{cell_50_ports}  13  14  15  16
@{cell_81_ports}  5  6  7  8
${tput_duration}  10m

*** Test Cases ***
Uplink Call CIT
    [Documentation]    Basic Call test wiht 1UE and uplink CA
    detach ues from cell  ${ues}
    Set initial attenuation
    attach ues to cell  ${ues}
    Start UL for UEs  ${ues}  duration=${tput_duration}  protocol=tcp
    Make SCell Available
    ${tputs}  Await datatransfers finish
    Log To Console  ${tputs}

*** Keywords ***
Set initial attenuation
    Turn on attenuation
    Set attenuation and check  ${cell_50_ports}  0

Make SCell Available
    FOR  ${step}  IN RANGE  70  15  -5
        Set attenuation and check  ${cell_81_ports}  ${step}
        sleep  1s
    END
