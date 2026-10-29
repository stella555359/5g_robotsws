# # #*** Settings ***
# # #Force Tags    PY36
# # #Documentation
# # #...    Author: shushu
# # #...    Contact: shushu.huang@nokia-sbell.com
# # #...    squad group: 5G_PZ_MMW_HZ_3_SG
# # #...    Feature CB007600_5GC002177
# # #
# # #Suite Setup       Suite setup
# # #Suite Teardown    Suite teardown
# # #Test Timeout         300 min
# # #
# # #Resource     Resources/CB007403_C-keyword.robot
# # #Resource    ../../../resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# # #
# # #
# # #*** Variables ***
# # #${x2logname}    2177_x2.pcap
# # #${ue_type}    ${tl.ues[0].capabilities[1]}
# # #
# # #*** Test Cases ***
# # #[1]CB007403_5GC002177_A_01_SgNB_release_based_on_A2_without_SRB3
# # #    [Documentation]    Author: Zhu Xinran
# # #    ...    Description: this case is to verify NSA L3 call with askey
# # #    [Setup]
# # #     Step1: Check GNB cell on air
# # #     Step2: Connect and Modify the parameter on enblte skip errors
# # #     Step3: Set parameter for A2 release feature
# # #     Step4: Start Capture Classical x2_WS Logs
# # #     Step5: UE attach
# # #     Step6: Stop and Save Logs
# # #     Step7: Analysis capture log
# # #    [Teardown]    teardown
# # #
# # #*** Keywords ***
# # #Step1: Check GNB cell on air
# # #    Log    \nStep1:Check GNB cell on air    console=yes
# # #    Check GNB cell on air
# # #
# # #Step2: Connect and Modify the parameter on enblte skip errors
# # #    log to console    change MRBTS-239/LNBTS-239/LNCEL-1 defaultLnRelGnbCellId to 7 and check
# # #    enb_lte.Connect to eNB via ssl
# # #    Set parameter defaultLnRelGnbCellId to 7    key=defaultLnRelGnbCellId    value=${7}
# # #
# # #Step3: Set parameter for A2 release feature
# # #    Log    \nStep2: Set parameter for A2 release feature    console=yes
# # #    Modify actA2SgnbRelease    true
# # #    Set parameter    key=a2MeasReleaseEnabled    value=rsrp
# # #    Modify srb3SupportEnabled    false
# # #    set a2MeasReleaseSsbRsrp list    a2HysteresisReleaseSsbRsrp=0    a2ThresholdReleaseSsbRsrp=100    a2TimeToTriggerReleaseSsbRsrp=ms320
# # #
# # #Step4: Start Capture Classical x2_WS Logs
# # #    Log    \nStep3: Start Capture Classical x2_WS Logs    console=yes
# # #    Start Capture Classical x2_WS Logs    x2logname=${x2logname}
# # #    sleep    5s
# # #
# # #Step5: UE attach
# # #    Log    \nStep4: UE attach    console=yes
# # #    power_ue.Prepare UE    ue_index=${0}    ue_type=${ue_type}
# # #    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${0}    ue_type=${ue_type}    log_type=Aasyslog
# # #
# # #Step6: Stop and Save Logs
# # #    Log    \nStep5: Stop and Save Logs    console=yes
# # #    Stop and Save Logs    x2logname=${x2logname}
# # #
# # #Step7: Analysis capture log
# # #    Log    \nStep6: Analysis capture log    console=yes
# # #    #Analysis capture log for case1    x2log=${x2logname}
# # #    Analysis X2 Log
# # #