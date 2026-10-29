*** Settings ***
Documentation
...    author: Marcin Usielski, Tomasz Kacza
...    contact: Marcin Usielski, Tomasz Kacza
...    Description: FGCR-1024 Firewall

Resource   taf/rfrl/bts/robot/gnb.robot
Resource   taf/rfrl/ue/robot/REAL_UE.robot
Resource   taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot

Resource    ./5GC001024_resources.robot
Library     testsuite/Krakow/TRS/resources/Firewall.py
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Force Tags    STATE_GNB_NOT_COMMISSIONED    CLOUD_5G_QC_ASIKR_ABILB4_AEUB

Suite Setup       1024 Suite Setup
Suite Teardown    1024 Suite Teardown
Test Setup        1024 Test Setup
Test Teardown     1024 Test Teardown


*** Test Cases ***
5GC001024_A_000_SyVe_UC04_icmpResponseEnabled_flag_CU_OAM
    Wait For Site To Be Onair
    ${flag}  Check Current Flag State On Cu
    check connection with interface when icmpResponseEnabled is set on flag  OAM  ${flag}
    ${flag}  switch flag  ${flag}
    Wait For Site To Be Onair
    Change all icmpResponseEnabled value  ${flag}
    check connection with interface when icmpResponseEnabled is set on flag  OAM  ${flag}

5GC001024_A_000_SyVe_UC04_icmpResponseEnabled_flag_CU_CPIF
    Wait For Site To Be Onair
    ${flag}  Check Current Flag State On Cu
    check connection with interface when icmpResponseEnabled is set on flag  X2  ${flag}
    ${flag}  switch flag  ${flag}
    Wait For Site To Be Onair
    Change all icmpResponseEnabled value  ${flag}
    check connection with interface when icmpResponseEnabled is set on flag  X2  ${flag}

5GC001024_A_000_SyVe_UC04_icmpResponseEnabled_flag_CU_UPUE
    Wait For Site To Be Onair
    ${flag}  Check Current Flag State On Cu
    check connection with interface when icmpResponseEnabled is set on flag  BACKHAUL  ${flag}
    ${flag}  switch flag  ${flag}
    Wait For Site To Be Onair
    Change all icmpResponseEnabled value  ${flag}
    check connection with interface when icmpResponseEnabled is set on flag  BACKHAUL  ${flag}

5GC001024_A_000_SyVe_no_aclrules_for_CU_VMs_with_internal_IFs_only
    no_aclrules_for_cu_vms_with_internal_ifs_only   bts_id=0

5GC001024_A_000_SyVe_UC01_stateful_filtering_for_gNB_initiated_traffic_allowed_ports_CU_OAM
    stateful_filtering_for_gnb_initiated_traffic    bts_id=0   state=OAM

5GC001024_A_000_SyVe_UC01_stateful_filtering_for_gNB_initiated_traffic_allowed_ports_CU_CPIF
    stateful_filtering_for_gnb_initiated_traffic    bts_id=0   state=CPIF

5GC001024_A_000_SyVe_UC01_stateful_filtering_for_gNB_initiated_traffic_allowed_ports_CU_UPUE
    stateful_filtering_for_gnb_initiated_traffic    bts_id=0   state=UPUE

5GC001024_A_000_SyVe_parse_aclrule_list_for_CU_OAM
    compare_aclrules    bts_id=0    state=OAM

5GC001024_A_000_SyVe_parse_aclrule_list_for_CU_CPIF
    compare_aclrules    bts_id=0    state=CPIF

5GC001024_A_000_SyVe_parse_aclrule_list_for_CU_UPUE
    compare_aclrules    bts_id=0    state=UPUE

5GC001024_A_000_SyVe_firewall_iwf_classifier_CU_UPUE
    firewall_iwf_classifier    bts_id=0    state=UPUE

5GC001024_A_000_SyVe_Firewall_rule_for_NTP
    firewall_ntp     bts_id=0

5GC001024_A_000_SyVe_Firewall_rule_for_DNS
    firewall_dns      bts_id=0

5GC001024_A_000_SyVe_Firewall_syslog_streaming
    firewall_syslog_streaming    bts_id=0
