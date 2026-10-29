## Mandatory Logs

### **1. Log Collection Scenarios**

This section defines the automated log collection procedures for different test outcomes and deployment models. The goal is to ensure that relevant diagnostic data is captured efficiently for both successful and failed test runs.

#### **1.1. Successful Test Scenario (PASS)**

- **Action**:
    
    - Collect snapshots from each node involved in the test (e.g., vCU, vDU).
- **Behavior in Iterative Tests**:
    
    - When a test is configured to run in multiple iterations, logs will, by default, be collected **only during the first successful iteration**.
    - A configuration flag will be available to override this behavior, enabling log collection for **every single iteration** if required for more detailed analysis.

#### **1.2. Failed Test Scenario (FAIL)**

- **Action**:
    
    - In the event of any test failure, a comprehensive log collection process is automatically triggered to capture a full diagnostic snapshot of the environment at the time of the error.
- **Log Sources**:
    
    - **LCM Operator**: Collect all relevant logs from the Lifecycle Management (LCM) operator to debug the deployment or upgrade process itself.
    - **Network Operations Platforms (NOPs)**: Collect logs from the associated NOPs to analyze network-related issues.
    - **vCU and vDU Namespaces**: Collect all logs from the Kubernetes namespaces where the vCU and vDU are deployed, including logs from all pods and relevant events.

#### **1.3. Blue-Green Deployment Scenario**

- **Action**:
    
    - In a blue-green deployment model, the log collection mechanism must gather data from both the active (`blue`) and inactive (`green`) environments.
- **Behavior**:
    
    - The log collector tool will be invoked to target and retrieve logs simultaneously from both the **`blue`** and **`green`** instances.
    - This ensures that a complete state of both deployments is captured, which is critical for validating the new `green` environment before traffic is switched and for troubleshooting any issues that may arise during the transition.