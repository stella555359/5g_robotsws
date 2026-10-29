*** Settings ***
Documentation
...            KRK3 Test templates for vran deployment
...            author:       Bartosz Bednarczyk, bartosz.bednarczyk@nokia.com
...            maintainer:   Bartosz Bednarczyk, bartosz.bednarczyk@nokia.com

Resource    main_vran.robot

Suite Setup       Testline Setup
Suite Teardown    Testline Teardown

Test Teardown     Test Case Teardown     pod_logs=yes    oam_logs=yes

*** Variables ***
# Config files
@{IP_ADDR_EXAMPLE}    eth3:10.0.12.100/24    eth3:10.0.11.100/24
&{CONFIG_EXAMPLE}     ip_addr=${IP_ADDR_EXAMPLE}   delta_vcu=${DELTA_VCU}   delta_vdu=${DELTA_VDU}
${DELTA_VCU}     ${CURDIR}/configs/delta_vcu.xml
${DELTA_VDU}     ${CURDIR}/configs/delta_vdu.json

*** Test Cases ***
01_vRAN_with_AP_SA_L3_Call
    [Documentation]    Example test with L3 Call of SA UEs with traffic verification.
    ...                Using default WTS config and expecting two SA UEs.
    ...                UE-1 is using default throughput (10mbps DL/UL) and UE-2 is using parametrized throughput.
    [Setup]    Test Case Setup    reach_on_air=without_x2_link   config=&{CONFIG_EXAMPLE}   reboot_after_config=no
    Start SA L3 Call    ue_id=1
    Start SA L3 Call    ue_id=2    dl_tput=500kbps    ul_tput=OFF
    Verify SA UE Traffic Using Bearer Stats    ue_id=1    wait=10s
    Verify SA UE Traffic Using Bearer Stats    ue_id=2    dl_tput=500kbps    ul_tput=OFF
    Stop SA L3 Call    ue_id=1
    Stop SA L3 Call    ue_id=2
