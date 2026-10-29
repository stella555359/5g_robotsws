*** Settings ***
Documentation    OCP logs collector keywords.
...              Authors:    Marek Starzyk
...              Contact:    marek.starzyk@nokia.com

Library         ./ocp_logs_collector.py

*** Keywords ***
#################################################### Main  Keywords ####################################################

Gather Logs From OCP And Send To VM
    [Documentation]
    ...  Description:  Collects various logs from an OpenShift (OCP) cluster and transfers them to a specified
    ...                virtual machine (VM) for further analysis.
    ...                Logs gathered include pod logs, pod descriptions, node logs, namespace inspection outputs,
    ...                and other relevant diagnostic data.
    ...                Collected logs are compressed into an archive before transfer.
    ...  Input:        namespace:        Name of the OCP namespace from which logs will be collected.
    ...                k8s_ip:           IP address of the OCP cluster.
    ...                destination_path: Local path where the logs archive will be downloaded.
    ...                k8s_user:         Username for accessing the OCP cluster (set if different from the 'core').
    ...                k8s_pass:         Password for accessing the OCP cluster (set if different from the 'system123').
    ...                nop_logs:         Default value is True. Set to False if you want to skip collecting logs from
    ...                                  ran-nic-sw-controller and nokia-sync-operator.
    ...  Author:       marek.starzyk@nokia.com
    [Arguments]    ${namespace}           ${k8s_ip}              ${destination_path}
    ...            ${k8s_user}=${None}    ${k8s_pass}=${None}    ${nop_logs}=${True}
    collect_logs_from_ocp_and_sent_to_vm
    ...  ${namespace}
    ...  ${k8s_ip}
    ...  ${destination_path}
    ...  ${k8s_user}
    ...  ${k8s_pass}
    ...  ${nop_logs}
