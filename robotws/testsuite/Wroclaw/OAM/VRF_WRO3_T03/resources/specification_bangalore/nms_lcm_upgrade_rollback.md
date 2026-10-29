## Mantaray LCM Upgrade/Rollback
### **1. Description:**

Upgrade of a software application deployed via MantaRay with LCM Operator on a Kubernetes cluster. The scenario will handle the download and import sw package into MantaRay lab.
### **2. Pre-conditions:**

- The Kubernetes cluster is running and accessible.
- All required pre-conditions for MantaRay environment  are accomplished (firewall, deployment part).
- The user has the necessary credentials and permissions to access the Kubernetes cluster and MantaRay lab.
- LCM operator downloaded and deployed via MantaRay.
- **vCU and vDU are already deployed via MantaRay with LCM Operator and operational.**
- Watchdog should be active during whole test execution and the verification should be performed at the end of execution.

### **3. Step-by-step Process:**

#### **Step 1: Download And Import Software Package In To MantaRay Lab**

- **Description:** The first step is to download the software package from a given URL or a repository, sw package should be downloaded and imported to MantaRay Lab.
- **Actions:**
    - The test should download sw from hardcoded artifactory link, or from user input, then import it into MantaRayLab.
    - Error handling should be in place for cases where the download or import fails (e.g., due to network issues or incorrect URL).
- **Usefull link for MantaRay keywords:**
	[taf.nms.netact.interface — taf.nms.netact 1.70.0 documentation](https://taf-nms-netact.docs.taf.ute.nsn-rdnet.net/en/latest/interfaces/interface.html#module-taf.nms.netact.interface)
	
```
	#example of usage of function

import_build(_build_or_file_path_, _mo_type='MRBTS'_, _version_id=None_, _release=None_, _alias=None_, _clean_temp_storage=False_, _ccr=None_)[¶](https://taf-nms-netact.docs.taf.ute.nsn-rdnet.net/en/latest/interfaces/interface.html#taf.nms.netact.interface.netact.import_build "Link to this definition")
```

- **Post-condition:** The software package is successfully downloaded and imported to the NSM Lab.

#### **Step 2: Perform LCM Upgrade Via NMS**

- **Description:** Based on the upgrade methods, you should execute them, used methods are listed below:
	- *prepare_sw_upgrade_plan_rancnf_blue_green*
	- *rollback_sw_rancnf_blue_green*
	- *upgrade_rancnf_one_button*
	- *upgrade_sw_rancnf_blue_green*


#### **Step 3: Verify the Upgrade**

- **Description:** After the upgrade, it's crucial to verify that the application is running correctly.
- **Actions:**
    - The test should check the status of the pods in the application's namespace.
    - It should wait for all pods to be in a `Running` or `Completed` state.
    - In case of **blue-green upgrade/rollback** pods from green instance are mandatory to be checked, blue instance should be removed.
- **Example Commands:**
    
    ```bash
    # Check pod status
    kubectl get pods -n <name_of_namespace>
    
    # Check logs of a specific pod
    kubectl logs <pod-name> -n <name_of_namespace>
    
    # Check the status of the Helm release
    helm status <release-name> -n <name_of_namespace>
    ```
    
- **Post-condition:** The application is running the new version, and all its components are healthy.

### **4. Post-conditions for Successful Upgrade:**

- The application is running the new version of the software.
- All Kubernetes pods for the application are in a `Running` and healthy state.
- All cells on Air state, no unexpected alarms are visible.
- Watchdog verification did not catch any unexpected alarms.

### **5. Failure Handling:**

The library should be designed to handle failures at each step of the process:

- **Download And Import Failure:** If the software package cannot be downloaded or imported, the process should be aborted with an appropriate error message.
- **Verification Failure:** If the application's pods do not become healthy after the upgrade, the upgrade should be considered a failure.