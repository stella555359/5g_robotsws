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
# # #Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# # #
# # #*** Variables ***
# # #${x2logname}    2177_x2.pcap
# # #${ue_type}    ${tl.ues[0].capabilities[1]}
# # #
# # #*** Test Cases ***
# # #[1]CB007403_5GC002177_A_03_SgNB_release_based_on_A2_with_SRB3
# # #    [Documentation]    Author: Zhu Xinran
# # #    ...    Description: this case is to verify NSA L3 call with askey
# # #    [Setup]
# # #     Step1: Check GNB cell on air
# # #     Step2: Set parameter for A2 release feature
# # #     Step3: Start Capture Classical x2_WS Logs
# # #     Step4: UE attach
# # #     Step5: Stop and Save Logs
# # #     Step6: Analysis capture log
# # #    [Teardown]    teardown
# # #
# # #*** Keywords ***
# # #Step1: Check GNB cell on air
# # #    Log    \nStep1:Check GNB cell on air    console=yes
# # #    Check GNB cell on air
# # #
# # #Step2: Set parameter for A2 release feature
# # #    Log    \nStep2: Set parameter for A2 release feature    console=yes
# # #    Modify actA2SgnbRelease    true
# # #    Set parameter    key=a2MeasReleaseEnabled    value=rsrp
# # #    Modify srb3SupportEnabled    true
# # #    set a2MeasReleaseSsbRsrp list    a2HysteresisReleaseSsbRsrp=0    a2ThresholdReleaseSsbRsrp=80    a2TimeToTriggerReleaseSsbRsrp=ms320
# # #
# # #Step3: Start Capture Classical x2_WS Logs
# # #    Log    \nStep3: Start Capture Classical x2_WS Logs    console=yes
# # #    Start Capture Classical x2_WS Logs    x2logname=${x2logname}
# # #    sleep    5s
# # #
# # #Step4: UE attach
# # #    Log    \nStep4: UE attach    console=yes
# # #    power_ue.Prepare UE    ue_index=${0}    ue_type=${ue_type}
# # #    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${0}    ue_type=${ue_type}    log_type=Aasyslog
# # #
# # #Step5: Stop and Save Logs
# # #    Log    \nStep5: Stop and Save Logs    console=yes
# # #    Stop and Save Logs    x2logname=${x2logname}
# # #
# # #Step6: Analysis capture log
# # #    Log    \nStep6: Analysis capture log    console=yes
# # #    Analysis capture log for Case3    x2log=${x2logname}