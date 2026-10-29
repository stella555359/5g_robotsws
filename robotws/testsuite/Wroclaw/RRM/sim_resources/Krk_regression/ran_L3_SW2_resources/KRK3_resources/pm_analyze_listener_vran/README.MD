### **Define pm counters value yaml:**
You need to prepare yaml configs based on
`testsuite/Krakow/RRM/RAN_L3_SW2/KRK3/resources/pm_analyze_listener_vran/default_template_vcu.yaml` and
`testsuite/Krakow/RRM/RAN_L3_SW2/KRK3/resources/pm_analyze_listener_vran/default_template_vdu.yaml`
Both files must contain information about the local moid
and the object in which the counter is located, for example:
```
pm_counters:
    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1:
        NRRCC:
            M55124C00001:
                value: SA_UE_num
                name: NRRCC_RRC_RELEASE_SENT
```
Where 'local moid' is `PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1` and object is `NRRCC`

There are two ways:
- **basic (recommended)**\
change only `test_parameters` section:
```
***For vDU file***

test_parameters:
    NSA_UE_num: 0
    SA_UE_num: 1
```
```
***For vCU file***

test_parameters:
    NSA_UE_num: 0
    SA_UE_num: 1
    attach_with_DRX: False
    num_of_additional_rrc_reconfigurations: 0
    num_of_additional_NSA_bearers: 0
    num_of_5qi_1_rrc_num: 0
    XN_link_is_configured: False
    num_of_successful_XN_HO: 0
    num_of_positive_inter_ho_after_A5: 0
    num_of_positive_intra_ho_after_A5: 0
    num_of_non_GBR_DRB_admission_req_NSA_HO: 0
    num_of_non_GBR_DRB_admission_success_NSA_HO: 0
```

- **advance**\
make changes for counters with hardcoded values\
for example:
```
***Hardcoded version***

pm_counters:
    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1:
        M55124C00001:
            value: 10
            name: NRRCC_RRC_RELEASE_SENT
```
instead of the default configuration based on `test_parameters` section:
```
***Default config***

pm_counters:
    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1:
        M55124C00001:
            value: SA_UE_num
            name: NRRCC_RRC_RELEASE_SENT
```
### **How to use the pm counter listener in your test case:**
<span style="color: red">**Important:**</span> **Detach/Deregister UE keyword must be placed in `*** Test Cases ***` section or in `Test Teardown`**

Use the library as robot listener.\
You need to add the library `testsuite/Krakow/RRM/RAN_L3_SW2/KRK3/resources/pm_analyze_listener_vran/ListenerCloud.py`
in your test script with params:
- Path to yaml file with PM ounters values for vCU
- Path to yaml file with PM ounters values for vDU
- PM interval (recommended greater than or equal to 15min)
``
``
Like in the following example:
```
Library    testsuite/Krakow/RRM/RAN_L3_SW2/KRK3/resources/pm_analyze_listener_vran/ListenerCloud.py
...    testsuite/Krakow/RRM/RAN_L3_SW2/KRK3/resources/pm_analyze_listener_vran/default_template_vcu.yaml
...    testsuite/Krakow/RRM/RAN_L3_SW2/KRK3/resources/pm_analyze_listener_vran/default_template_vdu.yaml    15min   15min
```

### **Example Robot Testsuites:**
`testsuite/Krakow/RRM/RAN_L3_SW2/KRK3/resources/pm_analyze_listener_vran/PM_Analyze_Listener_VRAN_demo.robot`
