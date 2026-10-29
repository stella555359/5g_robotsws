*** Settings ***
Documentation    Suite demonstrating usage of 'Gather Logs From OCP And Send To VM'
...              Authors:    Marek Starzyk
...              Contact:    marek.starzyk@nokia.com

Resource      ./ocp_logs_collector.robot

*** Variables ***
${namespace}           cran999
${k8s_ip}              xxx.xxx.xxx.xxx
${destination_path}    /home/ute/test_results/ocp_logs
${k8s_user}            ${None}
${k8s_pass}            ${None}
${nop_logs}            ${True}

*** Test Cases ***
Test
    Gather Logs From OCP And Send To VM
    ...   ${namespace}
    ...   ${k8s_ip}
    ...   ${destination_path}
    ...   ${k8s_user}
    ...   ${k8s_pass}
    ...   ${nop_logs}
