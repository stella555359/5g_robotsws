*** Settings ***
Documentation
...  author: Jiang Johnny
...  contact: johnny.1.jiang@nokia-sbell.com  jingmin.he@nokia-sbell.com
Resource      taf_coam.robot

*** Variable ***
${ENB_ADDR}   ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${ENB_WEBUI_USERNAME}   Nemuadmin
${ENB_WEBUI_PASSWORD}   nemuuser
${CELL_ATTACH_PARAM}   Default NR cell for dual connectivity

*** Keywords ***
