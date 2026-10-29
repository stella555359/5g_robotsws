*** Settings ***
Documentation
...     [Documentation]
...     [Author]                        "Spandana N"
...     [Maintenance]                   "TRS I & V Tools Bangalore Team"

variables       ta_e2e_bts_trs_fw



***Keywords***
Verify FSTSCH_BE counters
    Pm Counters Start     analysis=verify_BE_counters       counter_analysis_file=${counter_analysis_file_name_LTE4944}
    sleep       30
    Set Suite Variable      ${Count}               1..10000000
    Verify Pm Counters      analysis=verify_BE_counters       counter_analysis_file=${counter_analysis_file_name_LTE4944}


Verify FSTSCH_EF1 counters
    Perform Recommissioning     type=param  param_path=${Change_EF1}    operation=update    value=EF1     timeout=300

    Pm Counters Start     analysis=verify_EF1_counters       counter_analysis_file=${counter_analysis_file_name_LTE4944}
    sleep       30
    Set Suite Variable      ${Count}               1..10000000
    Verify Pm Counters      analysis=verify_EF1_counters       counter_analysis_file=${counter_analysis_file_name_LTE4944}


Verify FSTSCH_EF2 counters
    Perform Recommissioning     type=param  param_path=${Change_EF2}    operation=update    value=EF2     timeout=300
    Pm Counters Start     analysis=verify_EF2_counters       counter_analysis_file=${counter_analysis_file_name_LTE4944}
    sleep       30
    Set Suite Variable      ${Count}               1..10000000
    Verify Pm Counters      analysis=verify_EF2_counters       counter_analysis_file=${counter_analysis_file_name_LTE4944}


Verify FSTSCH_EF3 counters
    Perform Recommissioning     type=param  param_path=${Change_EF3}    operation=update    value=EF3     timeout=300
    Pm Counters Start     analysis=verify_EF3_counters       counter_analysis_file=${counter_analysis_file_name_LTE4944}
    sleep       30
    Set Suite Variable      ${Count}               1..10000000
    Verify Pm Counters      analysis=verify_EF3_counters       counter_analysis_file=${counter_analysis_file_name_LTE4944}

Verify FSTSCH_AF1 counters
    Perform Recommissioning     type=param  param_path=${Change_AF1}    operation=update    value=AF1     timeout=300
    Pm Counters Start     analysis=verify_AF1_counters       counter_analysis_file=${counter_analysis_file_name_LTE4944}
    sleep       30
    Set Suite Variable      ${Count}               1..10000000
    Verify Pm Counters      analysis=verify_AF1_counters       counter_analysis_file=${counter_analysis_file_name_LTE4944}

Verify FSTSCH_AF2 counters
    Perform Recommissioning     type=param  param_path=${Change_AF2}    operation=update    value=AF2     timeout=300
    Pm Counters Start     analysis=verify_AF2_counters       counter_analysis_file=${counter_analysis_file_name_LTE4944}
    sleep       30
    Set Suite Variable      ${Count}               1..100000000000
    Verify Pm Counters      analysis=verify_AF2_counters       counter_analysis_file=${counter_analysis_file_name_LTE4944}

Verify FSTSCH_AF3 counters
    Perform Recommissioning     type=param  param_path=${Change_AF3}    operation=update    value=AF3     timeout=300

    Pm Counters Start     analysis=verify_AF3_counters       counter_analysis_file=${counter_analysis_file_name_LTE4944}
    sleep       30
    Set Suite Variable      ${Count}               1..100000000000
    Verify Pm Counters      analysis=verify_AF3_counters       counter_analysis_file=${counter_analysis_file_name_LTE4944}

Verify FSTSCH_AF4 counters
    Perform Recommissioning     type=param  param_path=${Change_AF4}    operation=update    value=AF4     timeout=300

    Pm Counters Start     analysis=verify_AF4_counters       counter_analysis_file=${counter_analysis_file_name_LTE4944}
    sleep       30
    Set Suite Variable      ${Count}               1..10000000000
    Verify Pm Counters      analysis=verify_AF4_counters       counter_analysis_file=${counter_analysis_file_name_LTE4944}

