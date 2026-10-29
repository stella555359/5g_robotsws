*** Settings ***
Documentation
...     [Author]        "pooja"
...     [Maintenance]   "TRS I & V Tools Bangalore Team"


Resource        ${CURDIR}/../../resources/common_keywords.robot


***Keywords***

Vlan Id Is Displayed Under MOC And IP Addresses Will Be Collected

       Setup Oamops    dut=vdu_1        timeout=100      alias=vdu
       Perform Commissioning      scf_file=${vdu_base_scf}      timeout=600      dut=vdu_1
       BuiltIn.Sleep   200



Re-commissioning SCF Which Contains Unspecific VLAN Interface Name

        Setup Oamops    dut=vdu_1        timeout=100      alias=vdu
        Perform Commissioning      scf_file=${Invalid_vlan_interface}      timeout=600      dut=vdu_1        alias=vdu
        BuiltIn.Sleep         60


       Wait Until Keyword Succeeds   8 min    30      Verify Alarm         dut=vdu_1         faultid=61653
       ...     occurrences=1      should_exist=${True}          alias=vdu


Re-commissioning SCF Which Contains VLAN Interface Name

          Setup Oamops    dut=vdu_1        timeout=100      alias=vdu
          Perform Commissioning      scf_file=${Valid_vlan_interface}      timeout=600      dut=vdu_1        alias=vdu
          BuiltIn.Sleep        80

         Wait Until Keyword Succeeds    5 min    30      Verify Alarm         dut=vdu_1         faultid=61653
        ...     occurrences=1      should_exist=${False}          alias=vdu





