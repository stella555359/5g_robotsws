
Note:This script for print each robot case keyword step during case exection by "--listener" argument.

Example_1: this example with default keyword_logger.py, that will print robot case step but not print nested keywords.
robot --listener /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_L3_SW_CN_HZ/tools/keyword_logger/keyword_logger.py -L TRACE -d log_path_xx Debug_xx.robot

Output from console:
==============================================================================
Debug_xx                                                                       
==============================================================================
Suite_Setup_
Case_debug_1                                                          Test_Setup
.Clear Counter Files
.Attach UE And Verify DRX Relevant PM Counter
.Set Parameters For DataUsageRep
.Verify Traffic And Trigger NSA Inactivity
.Check Data Usage Report And PM Counter
.Test_Teardown
Case_debug_1                                                          | PASS |
------------------------------------------------------------------------------
Suite_Teardown
Debug_xx                                                                | PASS |
1 critical test, 1 passed, 0 failed
1 test total, 1 passed, 0 failed
==============================================================================


Example_2:this example with "keyword_logger.py:True" or "keyword_logger.py:logger_nested_kw_flag=True", that will print robot case step with all nested keywords with timestamps.
robot --listener /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_L3_SW_CN_HZ/tools/keyword_logger/keyword_logger.py:True -L TRACE -d log_path_yy Debug_yy.robot

Output from console:
==============================================================================
Debug_yy                                                                        
==============================================================================
Suite_Setup
Case_debug_2 :: 1. This user scenario describes successful slice m... Test_Setup
    nested_kw1
    nested_kw2
    nested_kw3
        nested_kw3.1
.Clear Counter Files
    nested_kw4
    nested_kw5
      nested_kw5.1
.Attach UE And Verify DRX Relevant PM Counter
    nested_kw6
    nested_kw7
.Set Parameters For DataUsageRep
    nested_kw8
.Verify Traffic And Trigger NSA Inactivity
    nested_kw9
      nested_kw9.1
.Check Data Usage Report And PM Counter
    nested_kw10
.Test_Teardown_ss4
    nested_kw11
    nested_kw12
      nested_kw12.1
Case_debug_2 :: 1. This user scenario describes successful slice m... | PASS |
------------------------------------------------------------------------------
Suite_Teardown
Debug_yy                                                              | PASS |
1 critical test, 1 passed, 0 failed
1 test total, 1 passed, 0 failed
==============================================================================

