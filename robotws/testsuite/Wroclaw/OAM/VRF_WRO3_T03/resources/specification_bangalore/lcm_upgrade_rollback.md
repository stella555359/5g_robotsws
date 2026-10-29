## LCM UPGRADE/ROLLBACK

### **1. Description:**

Upgrade of a software application deployed via LCM Operator on a Kubernetes cluster. The scenario will handle the download and unpacking of the software package, onboarding of container images to a Harbor registry, and the execution of the upgrade.
### **2. Pre-conditions:**

- The Kubernetes cluster is running and accessible.
- The user has the necessary credentials and permissions to access the Kubernetes cluster and the Harbor registry.
- LCM operator downloaded and deployed.
- **vCU and vDU are already deployed via LCM Operator and operational.**
- Watchdog should be active during whole test execution and the verification should be performed at the end of execution.

### **3. Step-by-step Process:**

#### **Step 1: Download Software Package**

- **Description:** The first step is to download the software package from a given URL or a repository, sw package should be downloaded to ocp server, regarding rollback scenario both sw packages are required to be pushed to ccr repository (initial and target).
- **Actions:**
    - The test should download sw from hardcoded artifactory link, or from user input.
    - It should then download the package to a local, temporary directory on ocp server.
    - Error handling should be in place for cases where the download fails (e.g., due to network issues or incorrect URL).
- **Example Commands:**
    
    ```bash
    # Using wget
    wget -O /tmp/software-package.tar.gz http://<repository-url>/path/to/software-package.tar.gz
    
    # Using curl
    curl -o /tmp/software-package.tar.gz http://<repository-url>/path/to/software-package.tar.gz
    ```
    
- **Post-condition:** The software package is successfully downloaded to the local filesystem on ocp server.

#### **Step 2: Unpack Software Package**

- **Description:** Once downloaded, the software package needs to be unpacked to access its contents.
- **Actions:**
    - The test will extract the contents of the downloaded `.tar.gz` file.
    - The unpacked contents should include container images.
- **Example Command:**
    
    ```bash
    tar -xzvf /tmp/software-package.tar.gz -C /tmp/unpacked-software
    ```
    
- **Post-condition:** The contents of the software package are extracted and accessible in the local filesystem.

#### **Step 3: Onboard Images to Harbor**

- **Description:** The container images included in the software package must be pushed to the Harbor registry so that Kubernetes can pull them during the deployment.
- **Actions:**
    - The test should identify the container images within the unpacked package.
    - It will then tag the images appropriately for the target Harbor registry.
    - The test will log in to the Harbor registry using the provided credentials.
    - Finally, it will push the images to the registry.
- **Example Commands:**
    
    ```bash
    # Log in to Harbor
    podman login <link_to_ccr> --username=<usernane> --password=<pasword> cert-dir=<path_to_directory_with_certificates>
    
    # Tag the image
    podman tag <image_id> <repository_name>/<image_name>:<tag>
    
    # Push the image
    
    podman push <harbor-registry-url>/<project>/<image-name>:<tag>
    ```
    
- **Post-condition:** All container images are successfully pushed to the Harbor registry.

**Supplementary information:**

- **Links to harbor ccrs:**
    - [ccr-wg-vrf-vcu](https://ccr-wg-vrf-vcu-01.wroclaw.nsn-rdnet.net/account/sign-in?redirect_url=%2Fharbor%2Fprojects)
    - [ccr-wg-vrf-vdu](https://ccr-wg-vrf-vdu-01.wroclaw.nsn-rdnet.net/harbor/projects)
    - [ccr-wl-vrf-vcu](https://ccr-wl-vrf-vcu-01.wroclaw.nsn-rdnet.net/account/sign-in?redirect_url=%2Fharbor%2Fprojects)
    - [ccr-wl-vrf-vdu](https://ccr-wl-vrf-vdu-01.wroclaw.nsn-rdnet.net/account/sign-in?redirect_url=%2Fharbor%2Fprojects)
- **Credentials:**
    - **username:** `admin`
    - **password:** `ItDs@3dE0j16DHMf`

#### **Step 5: Perform LCM Upgrade**

- **Description:** With the images available in the registry, the Helm upgrade can be performed.
- **Actions:**
    - Prepare yaml cnf file based on upgrade type (upgrade type should be changed to proper one)
    - The test will execute the `CNF upgrade via LCM Operator` command. (rancnf aply -)
    - In case of blue-green upgrade is mandatory to create secret on green instance with sw upgrade password, details could be found under the link:
      https://gitlabe2.ext.net.nokia.com/cloudinfra-ext/cnf-lcm-operator/-/blob/master/docs/source/user_guide/create_cnf.md?ref_type=heads#2-create-a-password-secret-for-green-cnf, and set password for 'swmupgrade' account on the blue instance.
    
- **Example Command:**
    
    ```bash
    kubectl apply -f rancnf_vdu_sample.yaml
    ```
    
- **Helpful links:**
    - [User Guide — CNF LCM Operator documentation](https://cloudinfra-ext.gitlabe2-pages.ext.net.nokia.com/cnf-lcm-operator/master/user_guide/index.html)
    - [docs/source/user_guide/create_cnf.md · master · cloudinfra-ext / cnf-lcm-operator · GitLab](https://gitlabe2.ext.net.nokia.com/cloudinfra-ext/cnf-lcm-operator/-/blob/master/docs/source/user_guide/create_cnf.md?ref_type=heads#install-cnf)
- **Post-condition:** From the output of the command `kubectl get rancnf -n {namespace} -o yaml`, the following conditions must be met:
    - `cr_operation_status` == **"Succeed"**
    - `cr_phase` == **"Running"**

#### **Step 6: Verify the Upgrade**

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

- **Download Failure:** If the software package cannot be downloaded, the process should be aborted with an appropriate error message.
- **Unpacking Failure:** If the package is corrupted and cannot be unpacked, the process should be aborted.
- **Image Onboarding Failure:** If any of the container images cannot be pushed to Harbor, the process should be aborted. A rollback of any already pushed images might be considered.
- **LCM Upgrade Failure: **  If yaml fail is not configured as expected the process should be aborted with an appropriate error message.
- **Verification Failure:** If the application's pods do not become healthy after the upgrade, the upgrade should be considered a failure.

<font color="#f79646">*During rollback In rancnf_vCU.yaml change sw_version.*</font>

```
 kubectl apply -f rancnf_vCU.yaml
```
