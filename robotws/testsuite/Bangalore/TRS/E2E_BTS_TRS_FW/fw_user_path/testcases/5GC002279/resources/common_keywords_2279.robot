*** Settings ***
Documentation
...     [Author]        "pooja"
...     [Maintenance]   "TRS I & V Tools Bangalore Team"

Resource        ${CURDIR}/../../resources/common_Cloud_keywords.robot


*** Keywords ***

Creates Additional Routing Table And Policy Rules For UP And CPRT POD

        Setup Oamops    dut=vdu_1        timeout=100      alias=vdu
        Perform Commissioning      scf_file=${add_IPRT-2}      timeout=600      dut=vdu_1        alias=vdu
        BuiltIn.Sleep         200


Add A Source Base Routing Policy For Cprt Pod Tracing Network Via Delta Scf

        Setup Oamops    dut=vdu_1        timeout=100      alias=vdu
        Perform Commissioning      scf_file=${add_RTPOL}      timeout=600      dut=vdu_1        alias=vdu
        BuiltIn.Sleep         200


Delete Added Route And Policy

      Setup Oamops    dut=vdu_1        timeout=100      alias=vdu
      Perform Commissioning      scf_file=${delete_IPRT_route}      timeout=600      dut=vdu_1        alias=vdu
      BuiltIn.Sleep         200


