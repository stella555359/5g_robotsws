*** Settings ***
Documentation    This file contains examples of the keywords defined in ttitrace.robot

Resource  ./../ttitrace.robot
Resource  ./../btslog.robot

*** Test Cases ***
Capture TTI Trace for a given amount of time
    [Documentation]  Author : Srihari Janardhan | This is an example test case.
    [Tags]  Example1
    ...  tti_trace_path -> Location to store the collected tti traces, if empty the traces will be stored under
    ...  default test case directory
    ...  tti_trace_duration ->  TTI trace capture duration in seconds
    ...  pci -> Physical Cell Identifier of the cell for which the TTI trace is required
    ...  gnb_id, du_id, common_unit_id are by default 0
    Wait until Node to be onair state
    Collect TTI Traces in Streaming mode  tti_trace_path=${OUTPUT_DIR}/new_test
    ...  tti_trace_duration=2
    ...  gnb_id=0
    ...  du_id=0
    ...  tti_trace_filename=example_tti_trace


Capture TTI Trace with Start and Stop keywords
    [Documentation]  Author : Srihari Janardhan | This is an example test case. Documentation of example 1 applies here
    ...  If necessary please refer to the documentation of the keywords used below
    [Tags]  Example2
#    btslog.Start Btslog
    Wait until Node to be onair state
    Start TTI Traces in Streaming mode  tti_trace_filename=myttitrace
    Sleep  5s
    ###  Attach Detach or other operations can go here  ###
    Stop TTI Traces in Streaming mode
    ...  tti_trace_path=${OUTPUT_DIR}/tti_test  tti_trace_filename=myttitrace
#    btslog.Stop Btslog    target_dir=${OUTPUT_DIR}/tti_test

