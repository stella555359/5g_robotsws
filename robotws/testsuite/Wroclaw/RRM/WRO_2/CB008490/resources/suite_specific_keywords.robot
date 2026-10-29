*** Settings ***
Documentation
...   author: Piotr Brzezicki
...   contact: dawid.rusek@nokia.com
...   maintainer: dawid.rusek@nokia.com

Library    DateTime                                                     WITH NAME    dt
Library    taf.ue                                                       WITH NAME    ue
Library    ute_fsmaccess
Library    ta5g_pm_counters                                             WITH NAME    pmcount
Library    taf.rfrl.bts.commissioning                                   WITH NAME    commission
Library    taf.rfrl.bts.devices.du.logs_collecting.basic_logs.GnbLog    WITH NAME    gnb_log
Library    ./suite_specific_keywords.py                                 WITH NAME    sskpy
Library    ./common_keywords.py                                         WITH NAME    ckpy
Library    ./KeywordNameLogger.py                                       WITH NAME    kwlog
Library    taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations    WITH NAME    gnbcell
Library    taf.rfrl.bts.devices.du.commissioning.GnbCommissioning       WITH NAME    gnbscf

Resource    taf/rfrl/ue/robot/REAL_UE.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    ./common_keywords.robot

Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py

*** Keywords ***
# CB008490_LD_ET_alt6
Verify PUCCH Multiplexing in SCG - Two CSI Process, Four CSI Report Group
    [Documentation]    KW verifies PUCCH Multiplexing in SCG - Two CSI Process, Four CSI Report Groups

    kwlog.Log Parent Keyword Name To Console
    sskpy.verify_pucch_mux_two_process_four_report_groups  pcap_file=${LOG_PATH}/${pcap_file}

# CB008490_LD_ET_alt7
Verify PUCCH Multiplexing in SCG - Two CSI Process, Three CSI Report Group
    [Documentation]    KW verifies PUCCH Multiplexing in SCG - Two CSI Process, Four CSI Report Groups

    kwlog.Log Parent Keyword Name To Console
    sskpy.verify_pucch_mux_two_process_three_report_groups  pcap_file=${LOG_PATH}/${pcap_file}

# CB008490_LD_ET_alt8
Verify PUCCH Multiplexing in SCG - Single CSI Process And Report Group From Xnap
    [Documentation]    KW verifies that adioLinkMonitoringConfig IE is not present in all SCG cells

    kwlog.Log Parent Keyword Name To Console
    sskpy.verify_single_csi_process_and_report_group_from_xnap    pcap_file=${LOG_PATH}/${pcap_file}
