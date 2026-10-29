*** Settings ***
Documentation   This is a keyword file for dcap, emil tracing
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------


Resource        ../../../resources/Common/dcap.robot


*** Variables ***
@{profile_for_dcap}    cp_5g


*** Keywords ***

Prepare For Dcap Tracing
    [Documentation]    [PRIVATE]    prepare for dcap tracing
    ...       :Autor: Sylvia Schneider
    Log To Console    \nstart dcap for all nodes
    Start DCAP Container For All Nodes
    Log To Console    \ndone - start dcap for all nodes


Dcap Tracing Start
    [Documentation]    [PRIVATE]    dcap tracing start
    ...       :Autor: Sylvia Schneider
    ...       value for custom_profile  cp_5g   emil
    ...       value for custom_profile  bip_interface_mirroring  gnb bip trace
    Log To Console    \nstart dcap tracing using
    FOR   ${single_trace}   IN   @{profile_for_dcap}
       Log To Console    ${single_trace}
    END

    ${node_num}   Get Length   ${tl.gnbs}
    FOR   ${node_id}   IN RANGE   ${node_num}
       ${output}    Start DCAP Tracing     node_id=${node_id}   custom_profile=@{profile_for_dcap}
       Log To Console    \ndone - start dcap tracing on node ${node_id}, trace running
    END


Dcap Tracing Stop
    [Documentation]    [PRIVATE]    dcap tracing stop
    ...       :Autor: Sylvia Schneider
    Log To Console    \nstop dcap tracing
    ${node_num}   Get Length   ${tl.gnbs}
    FOR   ${node_id}   IN RANGE   ${node_num}
       Run Keyword And Warn On Failure  dcap.Stop DCAP Tracing   node_id=${node_id}
       Log To Console    \ndone - stop dcap tracing on node ${node_id}
    END


End Dcap Tracing And Collect Traces
    [Documentation]    [PRIVATE]    end dcap tracing and collect traces
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${out_dir}=${resultDir}
    Log To Console    \nend dcap tracing and collect traces
    ${node_num}   Get Length   ${tl.gnbs}
    FOR   ${node_id}   IN RANGE   ${node_num}
       Run Keyword And Warn On Failure  dcap.Collect DCAP Traces  node_id=${node_id}   target_dir=${out_dir}
       Log To Console    \ndone - collect traces on node ${node_id}
    END
    Run Keyword And Warn On Failure  Stop DCAP Container For All Nodes
    Log To Console    \ndone - stop dcap for all nodes
