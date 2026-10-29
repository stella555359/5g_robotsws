*** Settings ***

Documentation
...   This is a test suite used in KW resourceCI running against real classical TL.
...   It verifies proper function of KWs in gnb.robot for classical deployments.
...   The tests are dedicated to multi node Tls as used by fSYVE but can run on single node TLs too.


Resource    ../gnb.robot

*** Test Cases ***
Test Wait until node to be onair state for all eNBs
  [TAGS]      GNB
  ${node_type}=  Set Variable  enb
  IF     '${tl.${node_type}s}'!='${None}'
        ${node_num}     Get Length  ${tl.${node_type}s}
  ELSE
        ${node_num}     Set Variable   ${0}
  END
  Log To Console   \nTL has '${node_num}' ${node_type}s!
  FOR   ${node_id}  IN RANGE    ${node_num}
    IF  '${tl.${node_type}s[${node_id}].__class__.__name__}'!='RealEnb'   CONTINUE
    gnb.Wait Until Node To Be Onair State  node_type=${node_type}    node_id=${node_id}
  END


Test Wait until node to be onair state for all gNBs
  [TAGS]      GNB
  ${node_type}=  Set Variable  gnb
  ${node_num}=   Get Length    ${tl.${node_type}s}
  IF     '${tl.${node_type}s}'!='${None}'
        ${node_num}     Get Length  ${tl.${node_type}s}
  ELSE
        ${node_num}     Set Variable   ${0}
  END
  Log To Console   \nTL has '${node_num}' ${node_type}s!
  FOR   ${node_id}  IN RANGE    ${node_num}
    gnb.Wait Until Node To Be Onair State  node_type=${node_type}    node_id=${node_id}
  END

