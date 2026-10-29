*** Settings ***
Resource    ../gnb.robot

*** Variables  ***

*** Test Cases ***
Test Wait until node to be onair state for all eNBs
  [TAGS]      GNB
  ${node_type}=  set variable  enb
  ${node_num}=   Run Keyword If  '${tl.${node_type}s}'!='${None}'
  ...            Get Length  ${tl.${node_type}s}
  ...   ELSE     Set Variable   ${0}
  log to console   \nTL has '${node_num}' ${node_type}s!
  FOR   ${node_id}  IN RANGE    ${node_num}
    Continue For Loop If  '${tl.${node_type}s[${node_id}].__class__.__name__}'!='RealEnb'
    gnb.Wait until node to be onair state  node_type=${node_type}    node_id=${node_id}
  END


Test Wait until node to be onair state for all gNBs
  [TAGS]      GNB
  ${node_type}=  set variable  gnb
  ${node_num}=   Get Length    ${tl.${node_type}s}
  ${node_num}=   Run Keyword If  '${tl.${node_type}s}'!='${None}'    Get Length  ${tl.${node_type}s}
  ...   ELSE     Set Variable   ${0}
  log to console   \nTL has '${node_num}' ${node_type}s!
  FOR   ${node_id}  IN RANGE    ${node_num}
    gnb.Wait until node to be onair state  node_type=${node_type}    node_id=${node_id}
  END

