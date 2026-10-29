*** Settings ***
Documentation
...     [Author]        "pooja"
...     [Maintenance]   "TRS I & V Tools Bangalore Team"


variables       ta_e2e_bts_trs_fw
Resource        taf/rfrl/trs_e2e_fw/setup/framework.robot
Resource        ${CURDIR}/../../resources/common_keywords.robot


***Keywords***

Vcu Deploy Successfully, All Pods/Containers Startup Normally

       Setup Oamops    dut=vcu_1        timeout=100      alias=vcu
       Perform Commissioning      scf_file=${vcu_base_scf}      timeout=600      dut=vcu_1
       BuiltIn.Sleep   200

Alarm 61661 VLAN_MATCHING_FAILURE Is Not Raised

      Wait Until Keyword Succeeds   10 min    30      Verify Alarm         dut=vcu_1         faultid=61661
      ...    occurrences=1      should_exist=${False}          alias=vcu

Re-commissioning SCF Which Contains Unspecific Vlan Interface Name and verifying alarm

      Setup Oamops    dut=vcu_1        timeout=100      alias=vcu
      Perform Commissioning      scf_file=${Invalid_vlan_interface_vcu}      timeout=400      dut=vcu_1         alias=vcu
      BuiltIn.Sleep         60

      Wait Until Keyword Succeeds   8 min    30      Verify Alarm         dut=vcu_1         faultid=61661
     ...    occurrences=1      should_exist=${True}          alias=vcu


Re-commissioning SCF Which Contains valid VLAN Interface Name and verifying alarm

       Setup Oamops    dut=vcu_1        timeout=100      alias=vcu
       Perform Commissioning      scf_file=${Valid_vlan_interface_vcu}      timeout=400      dut=vcu_1          alias=vcu
       BuiltIn.Sleep         60

      Wait Until Keyword Succeeds   8 min    30      Verify Alarm         dut=vcu_1         faultid=61661
      ...   occurrences=0      should_exist=${False}          alias=vcu


verify Ping connectivity for reachable IP

    Test Ipconnectivity     dut=vcu_1     destination_ip=172.16.1.102    payload_size=16     dscp=10
    ...      source_interface_name=CPIF_po-cran33-cpif-0_extc_F1-C    source_ip=172.16.1.103     alias=vcu



verify Ping connectivity for Unreachable IP

        Test Ipconnectivity     dut=vcu_1     destination_ip=1.1.1.1    payload_size=16     dscp=10
        ...    source_interface_name=CPIF_po-cran33-cpif-0_extc_F1-C    source_ip=172.16.1.103     alias=vcu
