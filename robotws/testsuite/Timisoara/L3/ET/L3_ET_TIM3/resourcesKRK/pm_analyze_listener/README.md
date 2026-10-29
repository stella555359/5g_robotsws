### **Define pm counters value yaml:**
You need to prepare yaml config based on
`testsuite/Timisoara/L3/ET/L3_ET_TIM3/resourcesKRK/pm_analyze_listener/default_template.yaml` with expected pm values.
There are two ways:
- **basic (recommended)**\
change only `test_parameters` section: 
```
test_parameters:
    NSA_UE_num: 1
    SA_UE_num: 0
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
#hardcoded version
pm_counters:
    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1:
        M55124C00001:
            value: 10
            name: NRRCC_RRC_RELEASE_SENT
```
instead default configuration based on `test_parameters` section:
```
#default config
pm_counters:
    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1:
        M55124C00001:
            value: SA_UE_num
            name: NRRCC_RRC_RELEASE_SENT
```
### **How to use the pm counter listener in your test case:**
<span style="color: red">**Important:**</span> **Detach/Deregister UE keyword must be placed in `*** Test Cases ***` section or in `Test Teardown`**

Use the library as robot listener.\
You need to add the library `testsuite/Timisoara/L3/ET/L3_ET_TIM3/resourcesKRK/pm_analyze_listener/listener.py`
in your test script with params:
- path to pm counters value yaml
- pm interval (recommended greater or equal 15min)


Like in the following example:
```
*** Settings ***
Library    testsuite/Timisoara/L3/ET/L3_ET_TIM3/resourcesKRK/pm_analyze_listener/listener.py
...    testsuite/Timisoara/L3/ET/L3_ET_TIM3/resourcesKRK/pm_analyze_listener/default_template.yaml    15min
```

### **Example Robot Testsuites:**
- SA\
`testsuite/Timisoara/L3/ET/L3_ET_TIM3/resourcesKRK/pm_analyze_listener/demo.robot`
- NSA\
`testsuite/Timisoara/L3/ET/L3_ET_TIM3/resourcesKRK/pm_analyze_listener/demo_NSA.robot`
