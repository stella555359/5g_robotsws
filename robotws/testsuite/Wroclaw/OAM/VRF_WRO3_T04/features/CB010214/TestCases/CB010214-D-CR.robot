*** Settings ***
Documentation
...  author:      Marta Gal
...  contact:     marta.gal@nokia.com
...  description: The test cases about testing the CB010214-D additional scope

Resource    taf/rfrl/cbts/utilities/init_variables.robot
Resource    ../../../../cloud_common_resources/accounts/accounts.robot
Resource    ../../../../cloud_common_resources/parameters/parameters.robot
Resource    ../../../../cloud_common_resources/logs/logs.robot
Resource    ../../../../cloud_common_resources/resets/resets.robot
Resource    ../../../../cloud_common_resources/accounts/accounts.robot
Resource    ../../../cloud_common_resources/rest_api/rest_api.robot
Resource    ../../../cloud_common_resources/mantaray/mantaray.robot

*** Variables ***
${dcuser_wrong_password}=     ZGN1c2VyOlFBd3MxMjMhQF4=
${exp_token1}=      eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3NjQ1OTQ5MzIsImlhdCI6MTc2NDU5MzEzMiwianRpIjoiMzgx
${exp_t_2}=         NiIsImNpcCI6IjEwLjQ0LjE0OS41MyIsImlhdF9pbl9ucyI6IjE3NjQ1OTMxMzI0NjUwNDI2NjUiLCJ0aWQiOiI0MTMwMTI1N
${exp_t_3}=         jQyIn0.LhCLfHhY969aa1QxUeEEQ7GOM52DBRSr05tldeD0jjk

${GET}=     curl -k -X GET https://
${POST}=    curl -k -X POST https://
${PUT}=     curl -k -X PUT https://

${option_1}=    -H "accept: application/json" -H "Content-Type: application/json" -H "Authorization: Bearer
${option_2}=    -H "accept: */*" -H "Content-Type: application/json" -H "Authorization: Bearer
${option_3}=    -H "accept: */*" -H "Authorization: Bearer

${ip_traffic}=   -d "{\\"captureType\\":\\"all\\",\\"planeType\\":[\\"uplane\\",\\"others\\"],
...              \\"podNames\\":[\\"string\\"],\\"measurementPoint\\":\\"NE_Terminated\\"}"
${snapshot}=     -d "{\\"filterRegx\\":\\"/([A-Z])\\\\\\w+/\\",\\"reason\\":\\"Collect log to check issue.\\",
...              \\"coverage\\":\\"full\\",\\"originator\\":\\"M2M\\",\\"heartbeat\\":true,\\"snapshotType\\":\\"local\\"}"
${syslog}=       -d "{\\"server\\":\\"10.42.54.11\\",\\"port\\":6515,\\"protocol\\":\\"TLS\\",
...              \\"format\\":\\"RFC5424\\",\\"dscp\\":0,\\"duration\\":1}"
${deb_par}=      -d "{\\"domainName\\":\\"OamFmService\\",\\"paramName\\":\\"FmServiceFms_PrintLog\\",
...              \\"nonDefaultOnly\\":false}"
${screls}=       -d "{\\"reason\\":\\"Collect log to check issue.\\",\\"coverage\\":\\"screl\\",
...              \\"originator\\":\\"M2M\\",\\"heartbeat\\":true,\\"screlType\\":\\"local\\"}"

*** Keywords ***

CB010214-D-REST_APIs_for_dcuser_vCU_vDU
    @{CRAN}    Create List
    Append To List    ${CRAN}    vDU
    FOR    ${i}    IN    @{CRAN}
        Change Service Account Password    username=dcuser    new_password=QAws123!@#
        ...                                old_password=QAws123!@#    hw_type=${i}
        ${MPLANE_IP}     Set Variable If    '${i}'=='vCU'    ${LMP_VCU_IP}    ${LMP_VDU_IP}
        Log              Step 1: Login to ${i} as dcuser    console=True
        ${login_1}=      rest_api.Perform REST login    ${DCUSER_PASS}    ${i}
        ${token}=        rest_api.Get Token Value    ${login_1}
        Log              Check Active Alarms    console=True
        ${output}=       Run     ${GET}${MPLANE_IP}/api/licensed/v2/alarms/active ${option_1} ${token}"
        Should Contain      ${output}     alarms

        Log              Check SW version    console=True
        ${output}=       Run     ${GET}${MPLANE_IP}/ext/api/swm/v1/software ${option_1} ${token}"
        Should Contain      ${output}     Current BTS software version

        Log         Start IP traffic capturing    console=True
        ${output}=  Run  ${POST}${MPLANE_IP}/api/licensed/v1/ip-traffic-capture/start ${ip_traffic} ${option_2} ${token}"
        Should Not Contain  ${output}     code
        Sleep       60s      reason=Wait for iptraffic

        Log         Check IP traffic capturing status    console=True
        ${output}=  Run  ${GET}${MPLANE_IP}/api/licensed/v1/ip-traffic-capture/status ${option_1} ${token}"
        Should Contain      ${output}     capturing

        Log         Stop IP traffic capturing    console=True
        ${output}=  Run  ${POST}${MPLANE_IP}/api/licensed/v1/ip-traffic-capture/stop ${option_3} ${token}"
        Should Not Contain  ${output}     code
        Sleep       60s      reason=Wait for iptraffic

        Log         Check IP traffic capturing status    console=True
        ${output}=  Run  ${GET}${MPLANE_IP}/api/licensed/v1/ip-traffic-capture/status ${option_1} ${token}"
        Should Contain      ${output}     captureCompleted

        Log         Check the server snapshot status    console=True
        ${output}=  Run  ${GET}${MPLANE_IP}/api/licensed/v1/snapshot ${option_1} ${token}"
        Should Contain      ${output}     idle

        Log         Start snapshot collection   console=True
        ${output}=  Run  ${POST}${MPLANE_IP}/api/licensed/v1/snapshot/operations ${snapshot} ${option_1} ${token}"
        Should Contain      ${output}     operationId

        Log         Start Syslog streming    console=True
        ${output}=  Run  ${PUT}${MPLANE_IP}/api/licensed/v1/syslog-streaming ${syslog} ${option_2} ${token}"
        Should Not Contain  ${output}     error

        ${output}=    Run     ${GET}${MPLANE_IP}/api/licensed/v1/syslog-streaming ${option_1} ${token}"
        Should Contain      ${output}     streamParams

        Log         Get data decoder file    console=True
        ${output}=  Run  ${GET}${MPLANE_IP}/api/licensed/v1/traces/data-decoder ${option_1} ${token}" -o tracedata
       Should Not Contain   ${output}     summary

        Log         Async fetch all available debug R&D SW domains    console=True
        ${output}=  Run  ${POST}${MPLANE_IP}/api/licensed/v1/rads/debug-domains/operations/fetches ${option_1} ${token}"
        Should Contain      ${output}     operationId

        Log         Async fetch R&D debug params    console=True
        ${output}=  Run  ${POST}${MPLANE_IP}/api/licensed/v1/rads/debug-params/operations/fetches ${deb_par} ${option_1} ${token}"
        Should Contain      ${output}     operationId

        Log         Check the SystemCriticalEventLog service availability    console=True
        ${output}=  Run  ${GET}${MPLANE_IP}/api/licensed/v1/screls/availability ${option_1} ${token}"
        Should Contain      ${output}     status

        Log         Trigger a SystemCriticalEventLog     console=True
        ${output}=  Run  ${POST}${MPLANE_IP}/api/licensed/v1/screls ${screls} ${option_1} ${token}"
        Should Contain      ${output}     ongoing

        Log         Check if activation status of internal trace is on or off     console=True
        ${output}=  Run  ${GET}${MPLANE_IP}/api/licensed/v1/traces/activation-status ${option_2} ${token}"
        Should Contain     ${output}      value

        Log              Step robustness 1: Try to trigger vDU reset as dcuser    console=True
        ${output}=  Run  ${POST}${MPLANE_IP}/api/licensed/v1/vdu/operations/resets ${option_1} ${token}"
        Should Contain      ${output}     HTTP method not allowed for read-write session

        Log              Step robustness 2: Login to ${i} as dcuser with wrong credentials   console=True
        ${output}=        rest_api.Perform REST login    ${dcuser_wrong_password}    ${i}
        Should Contain      ${output}        Authentication failed

        Log              Step robustness 3: Check Active Alarms when token is expired   console=True
        ${output}=     Run    ${GET}${MPLANE_IP}/api/licensed/v2/alarms/active ${option_1} ${exp_token1}${exp_t_2}${exp_t_3}"
        Should Contain      ${output}     Unauthorized access attempted. Token expired or invalid

        rest_api.Perform REST logout      ${token}   ${i}
    END
    [Teardown]    Run Keywords
    ...           Run Keyword And Ignore Error    rest_api.Perform REST logout   ${token}    vCU
    ...    AND    Run Keyword And Ignore Error    rest_api.Perform REST logout   ${token}    vDU
