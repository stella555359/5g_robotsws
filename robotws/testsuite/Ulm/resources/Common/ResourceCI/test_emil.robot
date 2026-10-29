*** Settings ***

Documentation
...   This is a test suite used in KW resourceCI running against real AP TL.
...   It verifies proper function of KWs in dcap.robot.


Library     Process
Library     taf.config.scf          WITH NAME    scf

Resource    ../dcap.robot
Resource    ../commissioning.robot
Resource    ../gnb.robot
Resource    ../scf_checks.robot

Suite Setup     Prepare DCAP Tests
Suite Teardown  Stop DCAP Container For All Nodes


*** Test Cases ***

Test DCAP Emil trace on local gnb without profile argument
    [TAGS]               DCAP    EMIL
    Start DCAP Tracing
    Sleep                10s
    Stop DCAP Tracing
    Collect DCAP Traces

Test DCAP Emil trace on local gnb with profile argument
    [TAGS]               DCAP    EMIL
    @{my_profile}        Create List  cp_5g  SCF5g
    Start DCAP Tracing   custom_profile=${my_profile}
    Sleep                10s
    Stop DCAP Tracing
    Collect DCAP Traces

Test DCAP Emil trace on remote gnb
    [TAGS]                DCAP    EMIL
    ${number_of_gnbs}     Get Length                 ${tl.gnbs}
    Pass Execution If     ${number_of_gnbs} < ${2}   no second gNB, test skipped
    Connect To Test PC Proxy For Node   1
    Start DCAP Tracing    node_id=1
    Sleep                 10s
    Stop DCAP Tracing     node_id=1
    Collect DCAP Traces   node_id=1
    Stop Dcap Container   node_id=1

*** Keywords ***
Prepare DCAP Tests
   ${scf_file}          gnb.Get SCF From GNB
   Set Suite Variable   ${orig_scf_file}  ${scf_file}
   scf.Load Scf       ${orig_scf_file}
   ${internal_trace}  scf.Get Value From SCF   dist_name=MRBTS-1/MNL-1/MNLENT-1/TRBLCADM-1   p_name=actInternalTrace
   ${parameter1}      Create Dictionary   value=true   dist_name=MRBTS-1/MNL-1/MNLENT-1/TRBLCADM-1   p_name=actInternalTrace
   ${param_list}      Create List   ${parameter1}
   ${delta_scf}       commissioning.Generate Delta Commissioning File   ${orig_scf_file}   ${param_list}
   commissioning.Execute Delta Commissioning   ${delta_scf}   resultDir=/tmp
   Start DCAP Container For All Nodes   retry_counter=${5}




