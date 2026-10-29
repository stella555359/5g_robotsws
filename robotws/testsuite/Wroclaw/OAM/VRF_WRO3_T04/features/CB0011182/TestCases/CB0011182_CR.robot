*** Settings ***
Documentation
...  author:      Klaudyna Piechocka
...  contact:     klaudyna.piechocka@nokia.com
...  description: TC for CB013411. CB013411 verifies if there are restrictions for parameters when BTS is in India.
Resource   ../../../../cloud_common_resources/connections/connections.robot
Library     taf.transport.ssh    WITH NAME    ssh

*** Keywords ***

CB011182-CR-G_Kubernetes_API_Access_Control_RANNIC_SW_Controller_Secret_Access
    Log    Step 1: Login to vDU OCP    console=true
    ${ssh_conn}=    Connect to K8s via SSH      hw_type=vDU
    Log    Step 2: Verify clusterroles for RANNIC controller
    ${agent}=    SSHLibrary.Execute Command    kubectl get clusterrole ran-nic-agent-clusterrole -o yaml    connection=${ssh_conn}
    Should Not Contain    ${agent}    secrets
    ${controller}    SSHLibrary.Execute Command    kubectl get clusterrole ran-nic-clusterrole -clusterrole -o yaml     connection=${ssh_conn}
    Should Not Contain    ${controller}    secrets
    [Teardown]    Disconnect from K8s via SSH
