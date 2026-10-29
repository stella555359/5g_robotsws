

*** Settings ***
Documentation
...   Author: tracy.zheng@nokia-sbell.com
...   Contact: tracy.zheng@nokia-sbell.com
...   Description: This user scenario describes



Suite Setup       Common Suite Setup For RRM
Test Setup        Common Test Setup For RRM
Suite Teardown    Common Suite Teardown For RRM
Test Teardown     Case Common Teardown

Test Timeout    120 minutes

Resource          ../../Resources/Classical/RRM_Common_Resource.robot
Library    BuiltIn
Library    String
Library    Collections
Library    re
Library    OperatingSystem
Library    Process

*** Variables ***
${MRBTS_ID}   1
${NRBTS_ID}   1
${ruleDL_GDPUT1}     Distname: MRBTS-1/NRBTS-1/NRCELL-1/NRPMQAP-1/GRQP;
...    Counter: M55392C00001;
...    Counter rule: avg(M55392C00001)>=0
${ruleDL_GDPUT2}     Distname: MRBTS-1/NRBTS-1/NRCELL-1/NRPMQAP-1/GRQP;
...    Counter: M55392C00002;
...    Counter rule: avg(M55392C00002)>=0
${ruleDL_GDPUT3}    Distname: MRBTS-1/NRBTS-1/NRCELL-1/NRPMQAP-1/GRQP;
...    Counter: M55392C00003;
...    Counter rule: avg(M55392C00003)>=0
${ruleDL_GDPUT4}    Distname: MRBTS-1/NRBTS-1/NRCELL-1/NRPMQAP-1/GRQP;
...    Counter: M55392C00004;
...    Counter rule: avg(M55392C00004)>=0
${ruleDL_GDPUT5}    Distname: MRBTS-1/NRBTS-1/NRCELL-1/NRPMQAP-1/GRQP;
...    Counter: M55392C00005;
...    Counter rule: avg(M55392C00005)>=0
${ruleDL_GDPUT6}    Distname: MRBTS-1/NRBTS-1/NRCELL-1/NRPMQAP-1/GRQP;
...    Counter: M55392C00006;
...    Counter rule: avg(M55392C00006)>=0
${ruleUL_GDPUT1}    Distname: MRBTS-1/NRBTS-1/NRCELL-1/NRPMQAP-1/GRQP;
...    Counter: M55392C00007;
...    Counter rule: avg(M55392C00007)>=0
${ruleUL_GDPUT2}    Distname: MRBTS-1/NRBTS-1/NRCELL-1/NRPMQAP-1/GRQP;
...    Counter: M55392C00008;
...    Counter rule: avg(M55392C00008)>=0
${ruleUL_GDPUT3}    Distname: MRBTS-1/NRBTS-1/NRCELL-1/NRPMQAP-1/GRQP;
...    Counter: M55392C00009;
...    Counter rule: avg(M55392C00009)>=0
${ruleUL_GDPUT4}    Distname: MRBTS-1/NRBTS-1/NRCELL-1/NRPMQAP-1/GRQP;
...    Counter: M55392C00010;
...    Counter rule: avg(M55392C00010)>=0
${ruleUL_GDPUT5}    Distname: MRBTS-1/NRBTS-1/NRCELL-1/NRPMQAP-1/GRQP;
...    Counter: M55392C00011;
...    Counter rule: avg(M55392C00011)>=0
${ruleUL_GDPUT6}    Distname: MRBTS-1/NRBTS-1/NRCELL-1/NRPMQAP-1/GRQP;
...    Counter: M55392C00012;
...    Counter rule: avg(M55392C00012)>=0
${rule_DL_RTT_SAMPLE}    Distname: MRBTS-1/NRBTS-1/NRCELL-1/NRPMQAP-1/GRQP;
...    Counter: M55392C00013;
...    Counter rule: avg(M55392C00013)>=0
${rule_DL_RTT}    Distname: MRBTS-1/NRBTS-1/NRCELL-1/NRPMQAP-1/GRQP;
...    Counter: M55392C00014;
...    Counter rule: avg(M55392C00014)>=0
${rule_DL_RTT_SAMOver}    Distname: MRBTS-1/NRBTS-1/NRCELL-1/NRPMQAP-1/GRQP;
...    Counter: M55392C00015;
...    Counter rule: avg(M55392C00015)>=0
${rule_UL_RTT_SAMPLE}    Distname: MRBTS-1/NRBTS-1/NRCELL-1/NRPMQAP-1/GRQP;
...    Counter: M55392C00016;
...    Counter rule: avg(M55392C00016)>=0
${rule_UL_RTT}    Distname: MRBTS-1/NRBTS-1/NRCELL-1/NRPMQAP-1/GRQP;
...    Counter: M55392C00017;
...    Counter rule: avg(M55392C00017)>=0
${rule_UL_RTT_SAMOver}    Distname: MRBTS-1/NRBTS-1/NRCELL-1/NRPMQAP-1/GRQP;
...    Counter: M55392C00018;
...    Counter rule: avg(M55392C00018)>=0
${ruleDL_Jitt}    Distname: MRBTS-1/NRBTS-1/NRCELL-1/NRPMQAP-1/GRQP;
...    Counter: M55392C00019;
...    Counter rule: avg(M55392C00019)>=0
${ruleDL_Jitt_SAMPLE}    Distname: MRBTS-1/NRBTS-1/NRCELL-1/NRPMQAP-1/GRQP;
...    Counter: M55392C00020;
...    Counter rule: avg(M55392C00020)>=0
${ruleUL_Jitt}    Distname: MRBTS-1/NRBTS-1/NRCELL-1/NRPMQAP-1/GRQP;
...    Counter: M55392C00021;
...    Counter rule: avg(M55392C00021)>=0
${ruleUL_Jitt_SAMPLE}    Distname: MRBTS-1/NRBTS-1/NRCELL-1/NRPMQAP-1/GRQP;
...    Counter: M55392C00022;
...    Counter rule: avg(M55392C00022)>=0
${UL_RLC_VOL_UE_TPUT_TOT}
...    Distname: MRBTS-1/NRBTS-1/NRCELL-1/NHRRC;
...    Counter: M55349C03001;
...    Counter rule: avg(M55349C03001)>=0
${UL_RLC_TIME_UE_TPUT}
...    Distname: MRBTS-1/NRBTS-1/NRCELL-1/NHRRC;
...    Counter: M55349C00012;
...    Counter rule: avg(M55349C00012)>=0
${DL_PDCP_VOL_UE_TPUT_QOS_12}
...    Distname: MRBTS-1/NRBTS-1/NRCELL-1/PDCPC;
...    Counter: M55350C01012;
...    Counter rule: avg(M55350C01012)>=0
${DL_PDCP_TIME_UE_TPUT_QOS_12}
...    Distname: MRBTS-1/NRBTS-1/NRCELL-1/PDCPC;
...    Counter: M55350C00012;
...    Counter rule: avg(M55350C00012)>=0
&{DPI_Config}      ueIp=10.12   otherPMQAP=10.12.2.2   dpiFirstMilliseconds=0    dpiInactivityDetectionTime=20
...     dpiMaxDlFirstPackets=2000
...    dpiMaxUlFirstPackets=2000     dpiMaxDrbs=5     dpiMaxTcpFlows=30    dpiMinTrafficVolThreshold=2000
...    dpiRttMaxDlThreshold=100      dpiRttMaxUlThreshold=100    dpiTcpWaitTime=700
...    miNrGdpRtJitpmqap=0       dpiGoodputScale=1     dpiGoodputScaleMax=50000    dpiGoodputScaleMin=100
...    fileName=short.csv      actDpiGoodput=true     actDpiRtt=true
${BTSLOG_FILTER}    ERR/L2-PS/src|goodput\{size:[1-9][0-9]*
${btslog_name}    ${EMPTY}
*** Test Cases ***
Prepare env
    Case Precondition  operation=env_setup_sa   tag=CLOUD_5G_I_BOO_AP_LOO
    Install pandas with pip

TC47
#CB013978-SR-A_1_Basic_TCP_goodput_measurement_scenario_SA_Linear_BIN6: add for EDA_05426021
    [Tags]    QC_319488    QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Author: jiana.song@nokia.com
    ...    history change: 2/5/2024,Qin zhixia,initial version
    ...    3.5.2026,jiana.song@nokia.com, modify for EDA_05426021
     Log To Console    loss 50% --- INFO ---
     Start Btslog Collect    names=btslog47
    #  Airphone Operation    edaemon_egate_setup    gnb    tag=CLOUD_5G_I_BOO_AP_LOO
     #Step 1: change SCF
    #  Coam gNB Online Modify multi By Rest    delta_file=${CURDIR}/config/TC47.json
     #Step 2: change the counter rule
     Start Check RTT And GOODPUT COUNTERS
     #Step 3: UE traffic as TC designed
     Start Ip Traffic Capture
     ${ue_ip}=     UE Register And PDU Session Setup    ue_id=83    pass_regexp=QoS Routing Table
     Configure Network Emulation     operation=del
     Configure Network Emulation     operation=del     interface=tunUPF
     #Configure Network Emulation     operation=looseACK
     #Configure Network Emulation     operation=looseACK     interface=tunUPF
     Configure Network Emulation     operation=add      loss=40%
     Configure Network Emulation     operation=add     interface=tunUPF
     Start Iperf Server On UTE
     Start Iperf Client On UTE     server_ip=${ue_ip}     duration=60     Process=5
     Start Iperf Client On UTE     server_ip=72.23.0.1    duration=60    Process=5
     sleep    10s
     UE Check TPUT     UE_id=83
     sleep    50s
     ${detailed_output}=    Set Variable    ${False}
     ${Iptrafficfile}     Stop Ip Traffic Capture    detailed_output=${detailed_output}
     Log    The output file name is: ${Iptrafficfile}
     UE Deregister From gNB
     ${btslog_name}    Stop Btslog Collect    names=btslog47
     Set Test Variable    ${btslog_name}
     Sleep Until Next Target Minute
     ${counter_file}=    Stop Collect Mutli Counter
     Run Keyword And Ignore Error    Calculate UL RTT FROM Counters    value1=${counter_file}
     Run Keyword And Ignore Error    Calculate DL RTT FROM Counters    value1=${counter_file}
     #Step 4: Calcuate using script
     Set To Dictionary    ${DPI_Config}    ueIp=${ue_ip}
    [Teardown]     Case Common Teardown

TC48
    #EDA_05426021 with corrupt
    [Tags]    QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Author: jiana.song@nokia.com
    ...    history change: 2/5/2024,Qin zhixia,initial version
    ...    3.5.2026,jiana.song@nokia.com, modify for EDA_05426021
     Log To Console    corrupt 5% --- INFO ---
     Start Btslog Collect    names=btslog48
    #  Airphone Operation    edaemon_egate_setup    gnb    tag=CLOUD_5G_I_BOO_AP_LOO
     #Step 1: change SCF
     Coam gNB Online Modify multi By Rest    delta_file=${CURDIR}/config/TC48.json
     #Step 2: change the counter rule
     Start Check RTT And GOODPUT COUNTERS
     #Step 3: UE traffic as TC designed
     Start Ip Traffic Capture
     ${ue_ip}=     UE Register And PDU Session Setup    ue_id=83    pass_regexp=QoS Routing Table
     Configure Network Emulation extend     operation=del
     Configure Network Emulation extend     operation=del     interface=tunUPF
     #Configure Network Emulation     operation=looseACK
     #Configure Network Emulation     operation=looseACK     interface=tunUPF
     Configure Network Emulation extend     operation=corrupt      loss=40%
     Configure Network Emulation extend     operation=corrupt     interface=tunUPF      loss=40%
     Start Iperf Server On UTE
     Start Iperf Client On UTE     server_ip=${ue_ip}     duration=60     Process=5
     Start Iperf Client On UTE     server_ip=72.23.0.1    duration=60    Process=5
     sleep    10s
     UE Check TPUT     UE_id=83
     sleep    50s
     ${detailed_output}=    Set Variable    ${False}
     ${Iptrafficfile}     Stop Ip Traffic Capture    detailed_output=${detailed_output}
     Log    The output file name is: ${Iptrafficfile}
     UE Deregister From gNB
     ${btslog_name}    Stop Btslog Collect    names=btslog48
     Set Test Variable    ${btslog_name}
     Sleep Until Next Target Minute
     ${counter_file}=    Stop Collect Mutli Counter
     Run Keyword And Ignore Error    Calculate UL RTT FROM Counters    value1=${counter_file}
     Run Keyword And Ignore Error    Calculate DL RTT FROM Counters    value1=${counter_file}
     #Step 4: Calcuate using script
     Set To Dictionary    ${DPI_Config}    ueIp=${ue_ip}
    [Teardown]     Case Common Teardown

TC49
    #EDA_05426021 with jitter
    [Tags]    QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Author: jiana.song@nokia.com
    ...    history change: 2/5/2024,Qin zhixia,initial version
    ...    3.5.2026,jiana.song@nokia.com, modify for EDA_05426021
     Log To Console    jitter 100ms 150ms --- INFO ---
     Start Btslog Collect    names=btslog49
    #  Airphone Operation    edaemon_egate_setup    gnb    tag=CLOUD_5G_I_BOO_AP_LOO
     #Step 1: change SCF
    #  Coam gNB Online Modify multi By Rest    delta_file=${CURDIR}/config/TC48.json
     #Step 2: change the counter rule
     Start Check RTT And GOODPUT COUNTERS
     #Step 3: UE traffic as TC designed
     Start Ip Traffic Capture
     ${ue_ip}=     UE Register And PDU Session Setup    ue_id=83    pass_regexp=QoS Routing Table
     Configure Network Emulation extend     operation=del
     Configure Network Emulation extend     operation=del     interface=tunUPF
     #Configure Network Emulation     operation=looseACK
     #Configure Network Emulation     operation=looseACK     interface=tunUPF
     Configure Network Emulation extend     operation=jitter
     Configure Network Emulation extend     operation=jitter     interface=tunUPF
     Start Iperf Server On UTE
     Start Iperf Client On UTE     server_ip=${ue_ip}     duration=60     Process=5
     Start Iperf Client On UTE     server_ip=72.23.0.1    duration=60    Process=5
     sleep    10s
     UE Check TPUT     UE_id=83
     UE Check TPUT     UE_id=83
     sleep    50s
     ${detailed_output}=    Set Variable    ${False}
     ${Iptrafficfile}     Stop Ip Traffic Capture    detailed_output=${detailed_output}
     Log    The output file name is: ${Iptrafficfile}
     UE Deregister From gNB
     ${btslog_name}    Stop Btslog Collect    names=btslog49
     Set Test Variable    ${btslog_name}
     Sleep Until Next Target Minute
     ${counter_file}=    Stop Collect Mutli Counter
     Run Keyword And Ignore Error    Calculate UL RTT FROM Counters    value1=${counter_file}
     Run Keyword And Ignore Error    Calculate DL RTT FROM Counters    value1=${counter_file}
     #Step 4: Calcuate using script
     Set To Dictionary    ${DPI_Config}    ueIp=${ue_ip}
    [Teardown]     Case Common Teardown

TC50
    #EDA_05426021 with jitter
    [Tags]    QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Author: jiana.song@nokia.com
    ...    history change: 2/5/2024,Qin zhixia,initial version
    ...    3.5.2026,jiana.song@nokia.com, modify for EDA_05426021
     Log To Console    repeat 40% --- INFO ---
     Start Btslog Collect    names=btslog50
    #  Airphone Operation    edaemon_egate_setup    gnb    tag=CLOUD_5G_I_BOO_AP_LOO
     #Step 1: change SCF
    #  Coam gNB Online Modify multi By Rest    delta_file=${CURDIR}/config/TC48.json
     #Step 2: change the counter rule
     Start Check RTT And GOODPUT COUNTERS
     #Step 3: UE traffic as TC designed
     Start Ip Traffic Capture
     ${ue_ip}=     UE Register And PDU Session Setup    ue_id=83    pass_regexp=QoS Routing Table
     Configure Network Emulation extend     operation=del
     Configure Network Emulation extend     operation=del     interface=tunUPF
     #Configure Network Emulation     operation=looseACK
     #Configure Network Emulation     operation=looseACK     interface=tunUPF
     Configure Network Emulation extend     operation=repeat     loss=40%
     Configure Network Emulation extend     operation=repeat     interface=tunUPF     loss=40%
     Start Iperf Server On UTE
     Start Iperf Client On UTE     server_ip=${ue_ip}     duration=60     Process=5
     Start Iperf Client On UTE     server_ip=72.23.0.1    duration=60    Process=5
     sleep    10s
     UE Check TPUT     UE_id=83
     UE Check TPUT     UE_id=83
     sleep    50s
     ${detailed_output}=    Set Variable    ${False}
     ${Iptrafficfile}     Stop Ip Traffic Capture    detailed_output=${detailed_output}
     Log    The output file name is: ${Iptrafficfile}
     UE Deregister From gNB
     ${btslog_name}    Stop Btslog Collect    names=btslog50
     Set Test Variable    ${btslog_name}
     Sleep Until Next Target Minute
     ${counter_file}=    Stop Collect Mutli Counter
     Run Keyword And Ignore Error    Calculate UL RTT FROM Counters    value1=${counter_file}
     Run Keyword And Ignore Error    Calculate DL RTT FROM Counters    value1=${counter_file}
     #Step 4: Calcuate using script
     Set To Dictionary    ${DPI_Config}    ueIp=${ue_ip}
    [Teardown]     Case Common Teardown

TC51
    #EDA_05426021 with reorder
    [Tags]    QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Author: jiana.song@nokia.com
    ...    history change: 2/5/2024,Qin zhixia,initial version
    ...    3.5.2026,jiana.song@nokia.com, modify for EDA_05426021
     Log To Console    reorder --- INFO ---
     Start Btslog Collect    names=btslog51
    #  Airphone Operation    edaemon_egate_setup    gnb    tag=CLOUD_5G_I_BOO_AP_LOO
     #Step 1: change SCF
    #  Coam gNB Online Modify multi By Rest    delta_file=${CURDIR}/config/TC48.json
     #Step 2: change the counter rule
     Start Check RTT And GOODPUT COUNTERS
     #Step 3: UE traffic as TC designed
     Start Ip Traffic Capture
     ${ue_ip}=     UE Register And PDU Session Setup    ue_id=83    pass_regexp=QoS Routing Table
     Configure Network Emulation extend     operation=del
     Configure Network Emulation extend     operation=del     interface=tunUPF
     #Configure Network Emulation     operation=looseACK
     #Configure Network Emulation     operation=looseACK     interface=tunUPF
     Configure Network Emulation extend     operation=reorder
     Configure Network Emulation extend     operation=reorder     interface=tunUPF
     Start Iperf Server On UTE
     Start Iperf Client On UTE     server_ip=${ue_ip}     duration=60     Process=5
     Start Iperf Client On UTE     server_ip=72.23.0.1    duration=60    Process=5
     sleep    10s
     UE Check TPUT     UE_id=83
     sleep    50s
     ${detailed_output}=    Set Variable    ${False}
     ${Iptrafficfile}     Stop Ip Traffic Capture    detailed_output=${detailed_output}
     Log    The output file name is: ${Iptrafficfile}
     UE Deregister From gNB
     ${btslog_name}    Stop Btslog Collect    names=btslog51
     Set Test Variable    ${btslog_name}
     Sleep Until Next Target Minute
     ${counter_file}=    Stop Collect Mutli Counter
     Run Keyword And Ignore Error    Calculate UL RTT FROM Counters    value1=${counter_file}
     Run Keyword And Ignore Error    Calculate DL RTT FROM Counters    value1=${counter_file}
     #Step 4: Calcuate using script
     Set To Dictionary    ${DPI_Config}    ueIp=${ue_ip}
    [Teardown]     Case Common Teardown

TC52
    #EDA_05426021 with reorder
    [Tags]    QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Author: jiana.song@nokia.com
    ...    history change: 2/5/2024,Qin zhixia,initial version
    ...    3.5.2026,jiana.song@nokia.com, modify for EDA_05426021
     Log To Console    2PDU --- INFO ---
     Start Btslog Collect    names=btslog52
    #  Airphone Operation    edaemon_egate_setup    gnb    tag=CLOUD_5G_I_BOO_AP_LOO
     #Step 1: change SCF
    #  Coam gNB Online Modify multi By Rest    delta_file=${CURDIR}/config/TC48.json
     #Step 2: change the counter rule
     Start Check RTT And GOODPUT COUNTERS
     #Step 3: UE traffic as TC designed
     Start Ip Traffic Capture
     Configure Network Emulation extend     operation=del
     Configure Network Emulation extend     operation=del     interface=tunUPF
     ${ue_ip}=     UE Register And PDU Session Setup    ue_id=83    pass_regexp=QoS Routing Table
     ${ue_ip8}=    UE Register And PDU Session Setup 2nd PDU    ue_id=83    pass_regexp=QoS Routing Table    pdu=8
     ...    gw=12
     Configure Network Emulation extend     operation=reorder
     Configure Network Emulation extend     operation=reorder     interface=tunUPF
     Start Iperf Server On UTE
     Start Iperf Client On UTE     server_ip=${ue_ip}     duration=120     Process=5
     Start Iperf Client On UTE     server_ip=72.23.0.1    duration=120    Process=5
     Start Iperf Client On UTE     server_ip=72.23.11.1    duration=120    Process=5
     Start Iperf Client On UTE     server_ip=${ue_ip8}     duration=120     Process=5
     sleep    15s
     UE Check TPUT     UE_id=83
     UE Delete 2nd PDU Session    ue_id=83    pdu=8
     sleep    60s
     UE Check TPUT     UE_id=83
     ${detailed_output}=    Set Variable    ${False}
     ${Iptrafficfile}     Stop Ip Traffic Capture    detailed_output=${detailed_output}
     Log    The output file name is: ${Iptrafficfile}
     UE Deregister From gNB
     ${btslog_name}    Stop Btslog Collect    names=btslog52
     Set Test Variable    ${btslog_name}
     Sleep Until Next Target Minute
     ${counter_file}=    Stop Collect Mutli Counter
     Run Keyword And Ignore Error    Calculate UL RTT FROM Counters    value1=${counter_file}
     Run Keyword And Ignore Error    Calculate DL RTT FROM Counters    value1=${counter_file}
     #Step 4: Calcuate using script
     Set To Dictionary    ${DPI_Config}    ueIp=${ue_ip}
    [Teardown]     Case Common Teardown

# TC90
#      [Tags]    QC_235965       QCD_MN_RAN      QCP_RAN_VRF
#      [Documentation]
#      #Airphone Operation    edaemon_egate_setup    gnb    tag=CLOUD_5G_I_BOO_AP_LOO
#      #round 1, 2 UEs
#      ReplaceSwconfig    local_path=${CURDIR}/config/swconfig_TC59.txt
#      ...                remote_path=/ffs/run/swconfig.txt
#      Coam gNB Online Modify multi By Rest    delta_file=${CURDIR}/config/TC59.json
#      COAM_Admin.ResetSite
#      Check site on air
#      sleep      300s
#      #Step X: common step, define the counter rule, for GOODPUT and RTT/Jitter
#      ${ruleDL_GDPUT7}    Catenate
#      ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1/NRPMQAP-1/GRQP;
#      ...    Counter: M55392C00006;
#      ...    Counter rule: latest(M55392C00006)==0
#      ${rule_DL_RTT_SAMPLE}    Catenate
#      ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1/NRPMQAP-1/GRQP;
#      ...    Counter: M55392C00013;
#      ...    Counter rule: latest(M55392C00013)==0
#      ${rule_DL_RTT}    Catenate
#      ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1/NRPMQAP-1/GRQP;
#      ...    Counter: M55392C00014;
#      ...    Counter rule: latest(M55392C00014)==0
#      ${rule_DL_RTT_SAMOver}    Catenate
#      ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1/NRPMQAP-1/GRQP;
#      ...    Counter: M55392C00015;
#      ...    Counter rule: latest(M55392C00015)==0
#      ${rule_UL_RTT_SAMPLE}    Catenate
#      ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1/NRPMQAP-1/GRQP;
#      ...    Counter: M55392C00016;
#      ...    Counter rule: latest(M55392C00016)==0
#      ${rule_UL_RTT}    Catenate
#      ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1/NRPMQAP-1/GRQP;
#      ...    Counter: M55392C00017;
#      ...    Counter rule: latest(M55392C00017)==0
#      ${rule_UL_RTT_SAMOver}    Catenate
#      ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1/NRPMQAP-1/GRQP;
#      ...    Counter: M55392C00018;
#      ...    Counter rule: latest(M55392C00018)==0
#      ${ruleDL_Jitt}     Catenate
#      ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1/NRPMQAP-1/GRQP;
#      ...    Counter: M55392C00019;
#      ...    Counter rule: latest(M55392C00019)==0
#      ${ruleDL_Jitt_SAMPLE}    Catenate
#      ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1/NRPMQAP-1/GRQP;
#      ...    Counter: M55392C00020;
#      ...    Counter rule: latest(M55392C00020)==0
#      ${ruleUL_Jitt}    Catenate
#      ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1/NRPMQAP-1/GRQP;
#      ...    Counter: M55392C00021;
#      ...    Counter rule: latest(M55392C00021)==0
#      ${ruleUL_Jitt_SAMPLE}    Catenate
#      ...    Distname: MRBTS-1/NRBTS-1/NRCELL-1/NRPMQAP-1/GRQP;
#      ...    Counter: M55392C00022;
#      ...    Counter rule: latest(M55392C00022)==0
#      ${rule_list}     Create List    ${ruleDL_GDPUT1}    ${ruleDL_GDPUT2}    ${ruleDL_GDPUT3}    ${ruleDL_GDPUT4}
#     ...     ${ruleDL_GDPUT5}    ${ruleDL_GDPUT6}    ${ruleUL_GDPUT1}    ${ruleUL_GDPUT2}    ${ruleUL_GDPUT3}
#     ...     ${ruleUL_GDPUT4}
#     ...     ${ruleUL_GDPUT5}    ${ruleUL_GDPUT6}    ${rule_DL_RTT_SAMPLE}   ${rule_DL_RTT}  ${rule_DL_RTT_SAMOver}
#     ...     ${rule_UL_RTT_SAMPLE}    ${rule_UL_RTT}  ${rule_UL_RTT_SAMOver}   ${ruleDL_Jitt}  ${ruleDL_Jitt_SAMPLE}
#     ...     ${ruleUL_Jitt}    ${ruleUL_Jitt_SAMPLE}
#      Start Collect Mutli Counters For Normal Release     rule_list=${rule_list}
#      #Get Required Logs   start  syslog   gnb
#      Start Ip Traffic Capture
#      ${ue_ip}=     UE Register And PDU Session Setup    ue_id=83    pass_regexp=QoS Routing Table
#      #Coam gNB Online Modify multi By Rest    delta_file=${CURDIR}/config/TC76_1.json
#      #sleep      180s
#      Start Iperf Server On UTE
#      Start Iperf Client On UTE     server_ip=${ue_ip}     duration=120     Process=1
#      Start Iperf Client On UTE     server_ip=72.23.0.1    duration=120    Process=1
#      sleep    10s
#      UE Check TPUT     UE_id=83
#      sleep    110s
#      ${detailed_output}=    Set Variable    ${False}
#      ${Iptrafficfile}     Stop Ip Traffic Capture    detailed_output=${detailed_output}   timeout=60
#      Log    The output file name is: ${Iptrafficfile}
#      UE Deregister From gNB
#      #Run Keyword And Ignore Error      Get Required Logs   stop_and_download   syslog   gnb
#      #Step 4: Calcuate using script
#      Sleep Until Next Target Minute
#      Stop Collect Mutli Counter
#     #[Teardown]     TC59 Teardown

*** Keywords ***
Configure Network Emulation
    [Arguments]    ${interface}=tunUE83PDU1    ${loss}=5%    ${operation}=add
    ${delete_command}=    Catenate    sudo tc qdisc del dev ${interface} root
    ${delete_looseACK_command}=    Catenate    sudo iptables -D OUTPUT -p tcp --tcp-flags ACK ACK -j MARK --set-mark 1
    ${add_command}=    Catenate    sudo tc qdisc add dev ${interface} root netem loss ${loss}
    ${delay_command}=    Catenate    sudo tc qdisc add dev ${interface} root netem delay 200ms
    ${looseACK_command1}=    Catenate    sudo iptables -A OUTPUT -p tcp --tcp-flags ACK ACK -j MARK --set-mark 1
    ${looseACK_command2}=    Catenate    sudo tc qdisc add dev ${interface} root handle 1: prio
    ${looseACK_command3}=    Catenate    sudo tc filter add dev ${interface} protocol ip parent 1:0 prio 1 handle 1 fw flowid 1:1
    ${looseACK_command4}=    Catenate    sudo tc qdisc add dev ${interface} parent 1:1 handle 10: netem loss ${loss}
    Run Keyword If    '${operation}' == 'del'    Execute Command    ${delete_command}
    Run Keyword If    '${operation}' == 'del'    Execute Command    ${delete_looseACK_command}
    Run Keyword If    '${operation}' == 'add'    Execute Command    ${add_command}
    Run Keyword If    '${operation}' == 'delay'    Execute Command    ${delay_command}
    Run Keyword If    '${operation}' == 'looseACK'    Execute Command    ${looseACK_command1}
    Run Keyword If    '${operation}' == 'looseACK'    Execute Command    ${looseACK_command2}
    Run Keyword If    '${operation}' == 'looseACK'    Execute Command    ${looseACK_command3}
    Run Keyword If    '${operation}' == 'looseACK'    Execute Command    ${looseACK_command4}

Configure Network Emulation extend
    [Arguments]    ${interface}=tunUE83PDU1    ${loss}=5%    ${operation}=add
    ${delete_command}=    Catenate    sudo tc qdisc del dev ${interface} root
    ${delete_looseACK_command}=    Catenate    sudo iptables -D OUTPUT -p tcp --tcp-flags ACK ACK -j MARK --set-mark 1
    ${add_command}=    Catenate    sudo tc qdisc add dev ${interface} root netem loss ${loss}
    ${delay_command}=    Catenate    sudo tc qdisc add dev ${interface} root netem delay 200ms
    ${jitter_command}=    Catenate    sudo tc qdisc add dev ${interface} root netem delay 100ms 150ms distribution normal
    ${repeat_command}=    Catenate    sudo tc qdisc add dev ${interface} root netem duplicate ${loss}
    ${corrupt_command}=    Catenate    sudo tc qdisc add dev ${interface} root netem corrupt ${loss}
    ${ratelimit_command}=    Catenate    sudo tc qdisc add dev ${interface} root handle 1: tbf rate 1mbit burst 10kb latency 3ms
    ${reorder_command}=    Catenate    sudo tc qdisc add dev ${interface} root netem delay 50ms reorder 50% 50%
    ${looseACK_command1}=    Catenate    sudo iptables -A OUTPUT -p tcp --tcp-flags ACK ACK -j MARK --set-mark 1
    ${looseACK_command2}=    Catenate    sudo tc qdisc add dev ${interface} root handle 1: prio
    ${looseACK_command3}=    Catenate    sudo tc filter add dev ${interface} protocol ip parent 1:0 prio 1 handle 1 fw flowid 1:1
    ${looseACK_command4}=    Catenate    sudo tc qdisc add dev ${interface} parent 1:1 handle 10: netem loss ${loss}
    Run Keyword If    '${operation}' == 'del'    Execute Command    ${delete_command}
    Run Keyword If    '${operation}' == 'del'    Execute Command    ${delete_looseACK_command}
    Run Keyword If    '${operation}' == 'add'    Execute Command    ${add_command}
    Run Keyword If    '${operation}' == 'delay'    Execute Command    ${delay_command}
    Run Keyword If    '${operation}' == 'jitter'    Execute Command    ${jitter_command}
    Run Keyword If    '${operation}' == 'repeat'    Execute Command    ${repeat_command}
    Run Keyword If    '${operation}' == 'corrupt'    Execute Command    ${corrupt_command}
    Run Keyword If    '${operation}' == 'ratelimit'    Execute Command    ${ratelimit_command}
    Run Keyword If    '${operation}' == 'reorder'    Execute Command    ${reorder_command}
    Run Keyword If    '${operation}' == 'looseACK'    Execute Command    ${looseACK_command1}
    Run Keyword If    '${operation}' == 'looseACK'    Execute Command    ${looseACK_command2}
    Run Keyword If    '${operation}' == 'looseACK'    Execute Command    ${looseACK_command3}
    Run Keyword If    '${operation}' == 'looseACK'    Execute Command    ${looseACK_command4}

Execute Command
    [Arguments]    ${command}
    ${output}=    Process.Run Process    ${command}    shell=true    stdout=PIPE    stderr=PIPE
    Log    Command Output (stdout): ${output.stdout}
    Log    Command Output (stderr): ${output.stderr}


Modify json file value
     [Arguments]    ${param_dict}=none   ${json_file_name}=dpi_0.json    ${new_file_name}=dpi.json
     ...   ${target_operation}=create   ${new_distname}=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
     basic.modify_json_file   json_file_path=${case_path}/config/${json_file_name}
     ...     new_distname=${new_distname}
     ...     param_updates=${param_dict}    new_file_name=${new_file_name}   target_operation=${target_operation}

Start Collect Mutli Counters For Normal Release
    [Arguments]    ${rule_list}
    Counter Operation    operation=start_collect_counter    product_type=gnb
    ...                                                     bts_index=0
    ...                                                     counter_rule=${rule_list}
#    ...                                                     pm_type=rd

Stop Collect Mutli Counter
    ${value1}    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    bts_index=0
    ...    cudu_index=0
    [Return]    ${value1}
    #...    pm_type=rd

Case Common Teardown
    Configure Network Emulation     operation=del
    Configure Network Emulation     operation=del     interface=tunUPF
    Run Keyword If    '${btslog_name}' != '${EMPTY}'    Analyze Btslog Err Wrn    ${btslog_name}    max_lines=30
    ...    filter_text=${BTSLOG_FILTER}
    Common Test Teardown For RRM
    Stop Iperf Server On UTE
    Run Keyword And Ignore Error      Stop Ip Traffic Capture
    UE Deregister From gNB
    Run Keyword And Ignore Error    Collect Coam Snapshot

#Calcuate GDPUT And RTT
#    [Arguments]    ${detailed_output}     ${DPI_Config}
#    ${folder}=    Evaluate    os.path.dirname("${detailed_output}")
#    ${newfile}=    Evaluate    os.path.splitext("${detailed_output}")[0]
#    ${result}=    Set Variable    result.csv
#    # Step 1: Change directory to the folder of ${detailed_output}
#    ${command_cd}=    Catenate
#    ...    cd ${folder}
#    ${output_cd}=    Process.Run Process    ${command_cd}    shell=true    stdout=PIPE    stderr=PIPE
#    Log    Change directory output (stdout): ${output_cd.stdout}
#    Log    Change directory output (stderr): ${output_cd.stderr}
#    # Step 2: Unzip ${detailed_output} to ${newfile}
#    ${command_unzip}=    Catenate
#    ...    gunzip -c "${detailed_output}" > "${newfile}"
#    ${output_unzip}=    Process.Run Process    ${command_unzip}    shell=true    stdout=PIPE    stderr=PIPE
#    Log    Unzip output (stdout): ${output_unzip.stdout}
#    Log    Unzip output (stderr): ${output_unzip.stderr}
#    # Step 3: Copy files to the folder of ${detailed_output}
#    ${converted}=    Convert Dict Values For JSON    ${DPI_Config}    output_file=${CURDIR}/TCP/dpi.json
#    ${command_cp}=    Catenate
#    ...    cp ${CURDIR}/TCP/* ${folder}
#    ${output_cp}=    Process.Run Process    ${command_cp}    shell=true    stdout=PIPE    stderr=PIPE
#    Log    Copy files output (stdout): ${output_cp.stdout}
#    Log    Copy files output (stderr): ${output_cp.stderr}
#    # Step 4: Run Python script convert-csv.py on ${newfile}
#    ${command_convert}=    Catenate
#    ...    cd ${folder} && python convert-csv.py "${newfile}"
#    ${output_convert}=    Process.Run Process    ${command_convert}    shell=true    stdout=PIPE    stderr=PIPE
#    Log    Convert CSV output (stdout): ${output_convert.stdout}
#    Log    Convert CSV output (stderr): ${output_convert.stderr}
#    # Step 5: Run Python script w.py on short.csv to generate ${result}
#    ${result}    Run Process    python   Calc_GDPUT_RTT.py    shell=True    stdout=PIPE    stderr=PIPE
#    ...     cwd=${folder}
#    Log    return code: ${result.rc}
#    Log    stdout: ${result.stdout}
#    Log    stderr: ${result.stderr}

Case Precondition
    [Arguments]   ${operation}=env_setup_sansa   ${tag}=${NONE}   ${customer}=${NONE}
    Airphone Operation  edaemon_egate_setup  gnb  tag=${tag}
    Airphone Operation  ${operation}  gnb  tag=${tag}   customer=${customer}
    OperatingSystem.Run     DCAP_Basic_controller start


Create Temporary File
    [Arguments]    ${suffix}=.txt
    ${temp_file}=    OperatingSystem.Create File    ${suffix}
    [Return]    ${temp_file}

Install pandas with pip
    ${command}=    Set Variable    source /home/ute/test_repo/bin/activate && pip install pandas
    ${command2}=    Set Variable    source /home/ute/test_repo/bin/activate && pip install robotframework-jsonlibrary
    ${output}      Process.Run Process    ${command}    shell=true     stdout=PIPE    stderr=PIPE
    ${output}      Process.Run Process    ${command2}    shell=true     stdout=PIPE    stderr=PIPE
    Log    Iperf Client Output (stdout): ${output.stdout}
    Log    Iperf Client Output (stderr): ${output.stderr}
    ${command}=    Set Variable    pip install pandas
    ${command2}=    Set Variable    pip install robotframework-jsonlibrary
    ${output}      Process.Run Process    ${command}    shell=true     stdout=PIPE    stderr=PIPE
    ${output}      Process.Run Process    ${command2}    shell=true     stdout=PIPE    stderr=PIPE
    Log    Iperf Client Output (stdout): ${output.stdout}
    Log    Iperf Client Output (stderr): ${output.stderr}

UE Deregister From gNB
    Airphone Execute Egate Command   cmd=ue_deregister id=1-106 ue_deregister_type=switch_off
    sleep   15s

SWconfig Modify
     ReplaceSwconfig    local_path=${CURDIR}/config/swconfig.txt
     ...                remote_path=/ffs/run/swconfig.txt
     COAM_Admin.ResetSite
     sleep        300s


UE Check TPUT
    [Arguments]    ${UE_id}=83
     ${output1}    ute_wtssim.Execute Egate Command And Wait For Data    cmd=ue_stats_nr id=${UE_id}
     ...                                                                return_output=True
     ...                                                                pass_regexp=cell
     Log To Console    ${output1}
     ${output2}    ute_wtssim.Execute Egate Command And Wait For Data    cmd=ue_stats_nr type=pusch id=${UE_id}
     ...                                                                return_output=True
     ...                                                                pass_regexp=cell
     Log To Console   ${output2}

Sleep Until Next Target Minute
    ${current_time}=    Get Current Date    result_format=%H:%M:%S
    Log    Current time: ${current_time}
    ${current_minute}=    Evaluate    int(${current_time.split(':')[1].lstrip('0')})
    ${target_minutes}=    Create List    1    6    11    16    21    26    31    36    41    46    51    56
    ${next_minute}        Catenate
    ...      min([int(minute) for minute in ${target_minutes}
    ...      if int(minute) > ${current_minute}] or [int(${target_minutes}[0])])
    ${next_target_minute}=    Evaluate      ${next_minute}
    ${sleep_s}        Catenate
    ...      (${next_target_minute} - ${current_minute}) * 60
    ...      if ${next_target_minute} > ${current_minute} else (60 - ${current_minute} + ${next_target_minute}) * 60
    ${sleep_seconds}=    Evaluate       ${sleep_s}
    Log    Sleeping for ${sleep_seconds} seconds until next target minute: ${next_target_minute}
    Sleep    ${sleep_seconds}

Commissioning scf and wait on air
   [Arguments]         ${scf_file_path}=${CURDIR}/config/TC01.xml
   COAM Commission with scf file    scf_file_path=${scf_file_path}
   Check site on air

Check site on air
    wait until keyword succeeds   3x   1min    COAM_Admin.Login
    wait until keyword succeeds    10 min    30 sec    Verify 5G cells should be onair
    [Teardown]    Run Keyword And Ignore Error    COAM_Admin.Logout

UE Register And PDU Session Setup
    [Arguments]    ${ue_id}=1  ${gnb_id}=2  ${cell_id}=1  ${pass_regexp}=QoS Routing Table  ${pdu}=1
    ${cmd}    catenate    ue_change_location id=${ue_id} enb=${gnb_id} cell=${cell_id}
    Airphone Operation   operation=send_common_command   product_type=${None}    cmd=${cmd}     pass_regexp=${None}
    ${cmd}    catenate    ue_register id=${ue_id}
    Airphone Operation   operation=send_common_command   product_type=${None}    cmd=${cmd}
    ...       pass_regexp=UE now in NG RM Register
    ${cmd}    catenate    set_pdu_param ue=${ue_id} pdu=1 trf_type=external
    Airphone Operation   operation=send_common_command   product_type=${None}    cmd=${cmd}
    ${cmd}    catenate    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${pdu}
    ${result}    Airphone Operation   operation=send_common_command   product_type=${None}    cmd=${cmd}
    ...     pass_regexp=${pass_regexp}
    ...     timeout=30s
    ${ue_ip}=    Extract UE-IP    LOG_TEXT=${result}
    [Return]     ${ue_ip}

UE Register And PDU Session Setup other 5QI
    [Arguments]    ${ue_id}=1  ${gnb_id}=2  ${cell_id}=1  ${pass_regexp}=QoS Routing Table  ${pdu}=2
    ${cmd}    catenate    ue_change_location id=${ue_id} enb=${gnb_id} cell=${cell_id}
    Airphone Operation   operation=send_common_command   product_type=${None}    cmd=${cmd}     pass_regexp=${None}
    ${cmd}    catenate    ue_register id=${ue_id}
    Airphone Operation   operation=send_common_command   product_type=${None}    cmd=${cmd}
    ...     pass_regexp=UE now in NG RM Register
    #set 5qi 7 as default pdu
    ${cmd}    catenate    set_pdu_param ue=${ue_id} pdu=${pdu} trf_type=external default_qos_flow=${pdu}
    Airphone Operation   operation=send_common_command   product_type=${None}    cmd=${cmd}
    ${pdu2}=    Evaluate    ${pdu} + 2
    ${cmd}    catenate    ue_pdu_session_setup ue=${ue_id} pdu=${pdu} nwslice=1 gw=${pdu2}
    ${result}    Airphone Operation   operation=send_common_command   product_type=${None}    cmd=${cmd}
    ...     pass_regexp=${pass_regexp}
    ...     timeout=30s
    #${cmd}    catenate    ue_pdu_session_release ue=${ue_id} pdu=1 by=amf
    #Airphone Operation   operation=send_common_command   product_type=${None}    cmd=${cmd}     pass_regexp=Release
    #...     timeout=30s
    ${ue_ip}=    Extract UE-IP    LOG_TEXT=${result}
    [Return]     ${ue_ip}

UE Register And PDU Session Setup 2nd PDU
    [Arguments]    ${ue_id}=1  ${gw}=9  ${pass_regexp}=QoS Routing Table  ${pdu}=6
#    ${cmd}    catenate    set_pdu_param ue=${ue_id} pdu=${pd} trf_type=external
#    Airphone Operation   operation=send_common_command   product_type=${None}    cmd=${cmd}
#    #${pdu2}=    Evaluate    ${pdu} + 3
#    ${cmd}    catenate    ue_pdu_session_setup ue=${ue_id} pdu=${pd} nwslice=1 gw=${gw}
#    ${result}    Airphone Operation   operation=send_common_command   product_type=${None}    cmd=${cmd}
#    ...     pass_regexp=${pass_regexp}     timeout=30s
#    ${cmd}    catenate    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=${pdu} by=amf
#    Airphone Operation   operation=send_common_command   product_type=${None}    cmd=${cmd}     pass_regexp=Release
#    ...     timeout=30
#    ${ue_ip}=    Extract UE-IP    LOG_TEXT=${result}
#    [Return]     ${ue_ip}
    ${cmd}    catenate    set_pdu_param ue=${ue_id} pdu=${pdu} trf_type=external
    Airphone Operation   operation=send_common_command   product_type=${None}    cmd=${cmd}
    ${cmd}    catenate    ue_pdu_session_setup ue=${ue_id} pdu=${pdu} nwslice=1 gw=${gw}
    ${result}    Airphone Operation   operation=send_common_command   product_type=${None}    cmd=${cmd}
    ...     pass_regexp=${pass_regexp}     timeout=30s
    ${ue_ip}=    Extract UE-IP    LOG_TEXT=${result}
    [Return]     ${ue_ip}

UE Delete 2nd PDU Session
    [Arguments]    ${ue_id}=1    ${pdu}=1
    ${cmd}    Catenate    ue_pdu_session_release ue=${ue_id} pdu=${pdu} by=amf
    ${result}    Airphone Operation   operation=send_common_command   product_type=${None}    cmd=${cmd}
    ...     pass_regexp=Release    timeout=30
    [Return]    ${result}

Extract UE-IP
    [Arguments]    ${LOG_TEXT}
    ${ip_match}=    Evaluate    re.search(r'UE-IP:(\\d+\\.\\d+\\.\\d+\\.\\d+)', '''${LOG_TEXT}''')    re
    Run Keyword If    ${ip_match}    Log    Found UE-IP: ${ip_match.group(1)}
    [Return]    ${ip_match.group(1)}

Get Required Logs
   [Arguments]    ${operation}=start  ${log_type}=syslog  ${product_type}=gnb  ${bts_index}=${0}
   ${local_file_path}   Log Collection    operation=${operation}   log_type=${log_type}
   ...   product_type=${product_type}    bts_index=${bts_index}    cudu_index=${0}
   [Return]      ${local_file_path}

Coam gNB Online Modify multi By Rest
    [Arguments]    ${delta_file}
    [Documentation]    Author: gcao
    ...                Contact: ge.cao@nokia-sbell.com
    ...                The kw is used to online delete mo by rest.
    ...    | Input Parameters | Man. | Description |
    ...    | ${delta_file} | Yes |  Delta JSON or path to JSON file. |
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example                                          | ${value}
    ...    | coam.perform_delta_recommissioning | ${delta_file}=/home/ute/a.json |
    coam.setup_admin    alias=update_mo
    ${res}=    coam.perform_delta_recommissioning    delta_file=${delta_file}
    ...                                              should_activate=${true}
    ...                                              timeout=${600}
    ...                                              connection=update_mo
    [Teardown]    coam.teardown    connection=update_mo

Online Update parameter gNB
    [Arguments]      ${DST_FOR_FRM_T}=MRBTS-1/NRBTS-1/NRDRB-12    ${parameter}=actDpiRtt      ${value}=true
    wait until keyword succeeds   3x   1min    COAM_Admin.Login      bts_host=192.168.255.129
    COAM_Admin.set parameter value    dist_name=${DST_FOR_FRM_T}    parameter=${parameter}   new_value=${value}
    [Teardown]    Run Keyword And Ignore Error    COAM_Admin.Logout

Start Iperf Server On UTE
    [Arguments]    ${port}=7070    ${interval}=1    ${bind_ip}=10.0.2.1    ${protocol}=tcp
    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${command_tcp}=    Catenate
    ...   iperf -s -p ${port} -i ${interval} -B ${bind_ip} > ${TEST_LOG_DIRECTORY}/iperf_server_${timestamp}.log &
    ${command_udp}=    Catenate
    ...   iperf -s -u -p ${port} -i ${interval} -B ${bind_ip} > ${TEST_LOG_DIRECTORY}/iperf_serverudp_${timestamp}.log &
    Run Keyword If    '${protocol}' == 'tcp'
    ...           Process.Run Process    ${command_tcp}    shell=true    stdout=PIPE    stderr=PIPE
    Run Keyword If    '${protocol}' == 'udp'
    ...           Process.Run Process    ${command_udp}    shell=true    stdout=PIPE    stderr=PIPE
    Log    Running command: ${command_tcp} or ${command_udp}

Stop Iperf Server On UTE
    [Arguments]    ${wait_time}=60
    Sleep    ${wait_time}
    ${command}=    Set Variable    pkill iperf
    Process.Run Process    ${command}    shell=true

Start Iperf Client On UTE
    [Arguments]    ${server_ip}=10.12.2.2    ${duration}=30    ${bandwidth}=10M    ${port}=7070    ${interval}=1
    ...      ${bind_ip}=10.0.2.1    ${mtu}=1360     ${Process}=1    ${protocol}=tcp    ${buffer_len}=131072
    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${command_tcp}=    Catenate
    ...    iperf -c ${server_ip} -p ${port} -M ${mtu} -i ${interval} -t ${duration} -l ${buffer_len}
    ...    -B ${bind_ip} -b ${bandwidth} -P ${Process} > ${TEST_LOG_DIRECTORY}/${server_ip}iperf_${timestamp}.log &
    ${command_udp}=    Catenate
    ...    iperf -c ${server_ip} -u -p ${port} -b ${bandwidth} -i ${interval} -t ${duration}
    ...    -l 1400 > ${TEST_LOG_DIRECTORY}/${server_ip}iperfudp_${timestamp}.log &
    Run Keyword If    '${protocol}' == 'tcp'
    ...    Process.Run Process    ${command_tcp}    shell=true    stdout=PIPE    stderr=PIPE
    Run Keyword If    '${protocol}' == 'udp'
    ...    Process.Run Process    ${command_udp}    shell=true     stdout=PIPE    stderr=PIPE
    #Log to console     ${output.stdout}
    #Log to console     ${output.stderr}

Coam gNB Online Create MO By Rest
    [Arguments]     ${dist_name}    ${parameter_list}    ${skip_parameter_relation_errors}=${True}
             ...    ${should_activate}=${True}
    coam.setup_admin    alias=create_mo
    ${res}=    coam.perform_object_recommissioning    dist_name=${dist_name}
    ...       parameter=${parameter_list}    operation=create
    ...       skip_parameter_relation_errors=${skip_parameter_relation_errors}    should_activate=${should_activate}
    ...      timeout=${600}   connection=create_mo
    [Teardown]    coam.teardown    connection=create_mo

Coam gNB Online Delete MO By Rest
    [Arguments]    ${dist_name}    ${skip_parameter_relation_errors}=${True}
    coam.setup_admin    alias=delete_mo
    ${res}=    coam.perform_object_recommissioning    dist_name=${dist_name}
    ...    operation=delete    skip_parameter_relation_errors=${skip_parameter_relation_errors}
    ...    parameter=@{empty}    timeout=${600}    connection=delete_mo
    [Teardown]    coam.teardown    connection=delete_mo

Analyze Btslog Err Wrn
    [Arguments]    ${btslog_dir}    ${max_lines}=20    ${filter_text}=
    ${tgz_files}=    List Files In Directory    ${btslog_dir}    pattern=*.tgz
    ${tgz_count}=    Get Length    ${tgz_files}
    Run Keyword If    ${tgz_count} == 0    Fail    No tgz file found in ${btslog_dir}
    ${btslog_archive}=    Join Path    ${btslog_dir}    ${tgz_files}[0]
    ${btslog_dir}=    Join Path    ${btslog_dir}    _tgz_unzip
    OperatingSystem.Run    command=mkdir -p ${btslog_dir}
    OperatingSystem.Run    command=tar -xzf ${btslog_archive} -C ${btslog_dir}
    # 找到 btslog 里的主日志文件（按常见 .LOG / .log）
    @{log_files}=    List Files In Directory    ${btslog_dir}    pattern=*.LOG
    ${log_count}=    Get Length    ${log_files}
    Run Keyword If    ${log_count} == 0    @{log_files}=    List Files In Directory    ${btslog_dir}    pattern=*.log
    ${log_count}=    Get Length    ${log_files}
    Run Keyword If    ${log_count} == 0    Fail    No btslog file found in ${btslog_dir}
 
     ${log_file}=    Join Path    ${btslog_dir}    ${log_files}[0]

     ${err_count}=    Process.Run Process    bash    -lc    grep -i -c 'err/' "${log_file}"    stdout=PIPE    stderr=PIPE
     ${wrn_count}=    Process.Run Process    bash    -lc    grep -i -c 'wrn/' "${log_file}"    stdout=PIPE    stderr=PIPE

     Log To Console    \n[BTSLOG] err/ count: ${err_count.stdout}
     Log To Console    [BTSLOG] wrn/ count: ${wrn_count.stdout}

     ${err_head}=    Process.Run Process    bash    -lc    grep -i -m ${max_lines} 'err/' "${log_file}"    stdout=PIPE    stderr=PIPE
     ${wrn_head}=    Process.Run Process    bash    -lc    grep -i -m ${max_lines} 'wrn/' "${log_file}"    stdout=PIPE    stderr=PIPE

     Log To Console    \n[BTSLOG] err/ first ${max_lines} lines:\n${err_head.stdout}
     Log To Console    \n[BTSLOG] wrn/ first ${max_lines} lines:\n${wrn_head.stdout}

    IF    '${filter_text}' != ''
        ${filter_count}=    Process.Run Process    bash    -lc    grep -i -c -E "${filter_text}" "${log_file}"    stdout=PIPE    stderr=PIPE
        ${filter_head}=    Process.Run Process    bash    -lc    grep -i -m ${max_lines} -E "${filter_text}" "${log_file}"    stdout=PIPE
        ...    stderr=PIPE
        Log To Console    \n[BTSLOG] filter "${filter_text}" first ${max_lines} lines:\n${filter_head.stdout}
    END

Get Counter Value From Result
    [Arguments]    ${result}    ${counter_rule}    ${timestamp}=${EMPTY}
    ${value_dict}=    Get From Dictionary    ${result}    value
    ${distname}=    Parse Distname From Counter Rule    ${counter_rule}
    ${counter_name}=    Parse Counter Name From Counter Rule    ${counter_rule}
    ${distname_key}=    Build Result Distname Key    ${distname}
    ${dist_dict}=    Get From Dictionary    ${value_dict}    ${distname_key}
    ${counter_dict}=    Get From Dictionary    ${dist_dict}    ${counter_name}
    ${selected_timestamp}=    Set Variable If    '${timestamp}' != '${EMPTY}'    ${timestamp}    ${None}
    IF    '${selected_timestamp}' == '${None}'
        ${timestamp_list}=    Get Dictionary Keys    ${counter_dict}
        ${selected_timestamp}=    Evaluate    sorted($timestamp_list)[-1]
    END
    ${counter_value}=    Get From Dictionary    ${counter_dict}    ${selected_timestamp}
    [Return]    ${counter_value}

Get Counter Values From Result
    [Arguments]    ${result}    @{counter_rules}
    &{counter_values}=    Create Dictionary
    FOR    ${counter_rule}    IN    @{counter_rules}
        ${counter_name}=    Parse Counter Name From Counter Rule    ${counter_rule}
        ${counter_value}=    Get Counter Value From Result    ${result}    ${counter_rule}
        Set To Dictionary    ${counter_values}    ${counter_name}=${counter_value}
    END
    [Return]    ${counter_values}

Calculate Counter Expression
    [Arguments]    ${counter_values}    ${expression}
    ${formula}=    Set Variable    ${expression}
    @{counter_names}=    Get Dictionary Keys    ${counter_values}
    FOR    ${counter_name}    IN    @{counter_names}
        ${counter_value}=    Get From Dictionary    ${counter_values}    ${counter_name}
        ${counter_value_str}=    Convert To String    ${counter_value}
        ${formula}=    Replace String    ${formula}    ${counter_name}    ${counter_value_str}
    END
    ${status}    ${result_or_error}=    Run Keyword And Ignore Error    Evaluate    ${formula}
    Run Keyword If    '${status}' != 'PASS'    Fail    Counter expression failed: ${formula}. Error: ${result_or_error}
    ${calculated_result}=    Set Variable    ${result_or_error}
    [Return]    ${calculated_result}

Calculate And Compare Counter Values
    [Arguments]    ${result}    ${expression}    ${comparator}    ${expected_value}    ${should_fail}=${True}    @{counter_rules}
    ${counter_values}=    Get Counter Values From Result    ${result}    @{counter_rules}
    ${calculated_result}=    Calculate Counter Expression    ${counter_values}    ${expression}
    ${compare_result}=    Evaluate    ${calculated_result} ${comparator} ${expected_value}
    Log    counter_values=${counter_values}
    Log    calculated_result=${calculated_result}, compare=${compare_result}, condition=${calculated_result} ${comparator} ${expected_value}
    ${error_message}=    Set Variable    Counter comparison failed: ${calculated_result} ${comparator} ${expected_value}
    Run Keyword If    ${should_fail} and not ${compare_result}    Log To Console    ${error_message}
    Run Keyword If    ${should_fail} and not ${compare_result}    Fail    ${error_message}
    [Return]    ${calculated_result}    ${compare_result}

Parse Distname From Counter Rule
    [Arguments]    ${counter_rule}
    @{parts}=    Split String    ${counter_rule}    ;
    ${distname_part}=    Strip String    ${parts}[0]
    ${distname}=    Replace String    ${distname_part}    Distname:    ${EMPTY}
    ${distname}=    Strip String    ${distname}
    [Return]    ${distname}

Parse Counter Name From Counter Rule
    [Arguments]    ${counter_rule}
    @{parts}=    Split String    ${counter_rule}    ;
    ${counter_part}=    Strip String    ${parts}[1]
    ${counter_name}=    Replace String    ${counter_part}    Counter:    ${EMPTY}
    ${counter_name}=    Strip String    ${counter_name}
    [Return]    ${counter_name}

Build Result Distname Key
    [Arguments]    ${distname}
    @{dist_parts}=    Split String    ${distname}    /
    ${distname_key}=    Set Variable    ['BTS']
    FOR    ${dist_part}    IN    @{dist_parts}
        ${distname_key}=    Catenate    SEPARATOR=    ${distname_key}    ['${dist_part}']
    END
    [Return]    ${distname_key}

Start Check RTT And GOODPUT COUNTERS
     Sleep Until Next Target Minute
     ${rule_list}     Create List
     ...    ${UL_RLC_TIME_UE_TPUT}    ${UL_RLC_VOL_UE_TPUT_TOT}    ${DL_PDCP_VOL_UE_TPUT_QOS_12}    ${DL_PDCP_TIME_UE_TPUT_QOS_12}
     ...    ${ruleDL_GDPUT1}    ${ruleDL_GDPUT2}    ${ruleDL_GDPUT3}    ${ruleDL_GDPUT4}    ${ruleDL_GDPUT5}    ${ruleDL_GDPUT6}
     ...    ${rule_UL_GDPUT1}    ${rule_UL_GDPUT2}    ${rule_UL_GDPUT3}    ${rule_UL_GDPUT4}    ${rule_UL_GDPUT5}    ${rule_UL_GDPUT6}
     ...    ${rule_DL_RTT_SAMPLE}    ${rule_DL_RTT}    ${rule_DL_RTT_SAMOver}     
     ...    ${rule_UL_RTT_SAMPLE}    ${rule_UL_RTT}    ${rule_UL_RTT_SAMOver}
     ...    ${ruleDL_Jitt}    ${ruleDL_Jitt_SAMPLE}    ${ruleUL_Jitt}    ${ruleUL_Jitt_SAMPLE}
     Start Collect Mutli Counters For Normal Release     rule_list=${rule_list}

Calculate UL RTT FROM Counters
    [Arguments]    ${value1}
    ${calc_result}    ${compare_result}=    Calculate And Compare Counter Values
    ...    ${value1}
    ...    M55392C00017 / M55392C00016
    ...    <
    ...    80000
    ...    ${True}
    ...    ${rule_UL_RTT}
    ...    ${rule_UL_RTT_SAMPLE}
    Log To Console    UL RTT calc=${calc_result}, compare=${compare_result}

Calculate DL RTT FROM Counters
    [Arguments]    ${value1}
    ${calc_result}    ${compare_result}=    Calculate And Compare Counter Values
    ...    ${value1}
    ...    M55392C00014 / M55392C00013
    ...    <
    ...    80000
    ...    ${True}
    ...    ${rule_DL_RTT}
    ...    ${rule_DL_RTT_SAMPLE}
    Log To Console    DL RTT calc=${calc_result}, compare=${compare_result}