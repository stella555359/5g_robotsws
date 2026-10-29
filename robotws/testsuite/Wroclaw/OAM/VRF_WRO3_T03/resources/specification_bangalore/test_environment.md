### **1. Test Environment and Configuration Specification**

The test execution will be conducted from dedicated virtual machines (VMs). The test framework will establish an SSH connection to the target server to execute commands and gather information. 

#### **1.1. Initialization and Environment Discovery on UTE**

Before test execution, the framework automatically discovers and initializes key environment variables from the test line configuration data structure. 

**Note:** The `${tl}` object represents the test line configuration data structure provided by the test environment  __init__.py file.

```
# Namespace discovery for vDU and vCU
vdu_namespace = tl.gnbs[0].dus[0].cloud_deployment.cloud_hosting.namespace
vcu_namespace = tl.gnbs[0].cloud_deployment.cloud_hosting.namespace

# SSH connection details for the master nodes
vdu_master_node_ip = tl.gnbs[0].dus[0].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.addr
vcu_master_node_ip = tl.gnbs[0].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.addr
```

#### **1.2. Initialization and Environment Discovery on non UTE env***

In case of non UTE env the basic input should be provided by user, it could be provided as dictionary:
![[Pasted image 20260316140305.png]]

The following parameters must be defined by the user to configure the test run. These are divided into core settings and settings specific to the MantaRay NMS environment.

---

#### **1.2.1. Core Configuration**

These parameters define the fundamental aspects of the test, including software builds, test execution control, and credentials.

- **`customer_list`**:
    
    - **Description**: A list of specific customer configurations to be tested.
    - **Default**: `['generic']`
    - **Example**: `['TMO', 'Bell Canada']`
- **`initial_vcu_build` / `initial_vdu_build`**:
    
    - **Description**: The path or identifier for the initial software build before the upgrade.
    - **Type**: `string`
- **`candidate_vcu_build` / `candidate_vdu_build`**:
    
    - **Description**: The path or identifier for the new candidate software build to be deployed.
    - **Type**: `string`
- **`iteration_count`**:
    
    - **Description**: The number of times the test cycle should be repeated.
    - **Type**: `integer`
    - **Default**: `1`
- **`log_directory_path`**:
    
    - **Description**: The absolute path on the VM where test logs will be saved.
    - **Type**: `string`
    - **Default**: `'/home/ute/logs'`
- **`log_collection_policy`**:
    
    - **Description**: A flag to control log collection behavior. Defines whether to collect logs from every iteration or only from passed.
    - **Type**: `bool`, or `string`
    - **Options**: `'all_iterations'`, `'single_iteration', or `true` = logs from all iterations, `false` = logs from single passed iteration.
- **`on_air_timeout_seconds`**:
    
    - **Description**: The timeout in seconds for the hardware to become fully operational ("On Air") after a configuration change or reboot.
    - **Type**: `integer`
    - **Default**: `900`
- **Alarm Lists**:
    
    - **`custom_expected_alarms`**: A list of specific alarms that are expected to be present during the test.
    - **`temporarily_allowed_alarms`**: A list of alarms that can be ignored for the duration of the test run.
    - **`critical_alarms`**: A list of critical alarms that, if raised, should immediately fail the test case.
- **Credentials**:
    
    - **`oam_username` / `oam_password`**: Credentials for accessing the OAM interface.
    - **`ssh_username` / `ssh_password`**: Credentials for establishing an SSH connection to the servers.

## **Unit Tests**

The documentation should preferably include unit tests that can be executed before introducing any changes to the codebase. Such tests help verify that existing functionality remains unaffected and ensure that modifications do not introduce regressions.

## **Ongoin Documentation**

As a developer of rfrl, you should provide clear continuously documentation that reflects ongoing changes, with examples of usage.

 **Used TAF libraries:**
 >- taf.gnb.oam.coam.cu - https://taf-gnb-oam-coam-cu.docs.taf.ute.nsn-rdnet.net/en/latest/interfaces/interface.html
> - taf.gnb.oam.coam.vdu - https://taf-gnb-oam-coam-vdu.docs.taf.ute.nsn-rdnet.net/en/latest/interfaces/interface.html
> - taf.nms.netact - https://taf-nms-netact.docs.taf.ute.nsn-rdnet.net/en/latest/interfaces/interface.html
> - taf.sw.reporting_portal - https://taf-sw-reporting-portal.docs.taf.ute.nsn-rdnet.net/en/latest/interfaces/interface.html
> - taf.ul.vdu.helm - https://taf-ul-vdu-helm.docs.taf.ute.nsn-rdnet.net/en/latest/interfaces/interface.html
> - taf.transport.ssh.interface - https://taf-transport-ssh.docs.taf.ute.nsn-rdnet.net/en/latest/robot_index.html
> - taf.ul.alarms-watchdog - [taf.ul.alarms-watchdog — taf.ul.alarms-watchdog 1.8.1 documentation](https://taf-ul-alarms-watchdog.docs.taf.ute.nsn-rdnet.net/en/latest/)

<font color="#ff0000">Important: Please do not use selenium during library development.</font>