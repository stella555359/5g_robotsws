*** Settings ***
Documentation
...  author: Pawel Zabawczuk
...  contact: pawel.k.zabawczuk@nokia.com
...
...  Below keyword allow to add objects needed to set up xn link/s online in WebUI, activate Xn link on neighboring gnB/s
...  and check its status.
...  To use these keywords some settings for neighboring gNB/s must de defined in TL config file, eg. 7_16_CLOUDT097.
...  Below variables must be defined for neighboring gNB/s:
...   - instance_id
...   - global_bts_id
...   - xnc ip addres
...   - backhaul_site_oam_ip  - it must be ip accessible from lab - not lmp ip address
...
...  Sample of usage keywords to set up xn link to one gNB
...
...     Add relation to neighboring gNB/s
...         <here you can start tracing>
...     (De)Activate incoming Xn link   true
...     Wait for Xn link to be in given state   available
...         <here you can stop tracing>


Library             OperatingSystem
Library             BuiltIn
Library             String
Library             Collections
Library             ./xn_link.py


*** Keywords ***

Add relation to neighboring gNB/s
    [Documentation]   Add NRADJGNB and XNLINK objects for one or more gNBs.
    ...               Neighboring gNB/s must be defined in config file for given TL.
    [Arguments]       ${number of neighboring gNBs}=1
    Change NRADJGNB and XNLINK objects   create   ${number of neighboring gNBs}

Remove relation to neighboring gNB/s
    [Documentation]   Remove NRADJGNB and XNLINK objects for neighboring gNB/s.
    [Arguments]       ${number of neighboring gNBs}=1
    Change NRADJGNB and XNLINK objects   delete   ${number of neighboring gNBs}

(De)Activate incoming Xn link
    [Documentation]   Activate or Deactivate Xn link status on own or neighboring gNB/s.
    ...               For own gNB id is '0', for neighboring gNB/s starts from '1' - neighboring gNB/s must be defined in config file.
    ...               Xn link status is 'true' or 'false'
    [Arguments]       ${xn link state}   ${gNB id}=1
    Update xn link status   ${xn link state}   ${gNB id}

Check Xn link/s state
    [Documentation]   Check if reuested xn link ref id is in requested status.
    ...               Possible values to ask: available / unavailable
    [Arguments]       ${requested state}   ${xn link ref id}    ${id_length}
    &{xn link status}=   check xn link status    ${id_length}
    Log               {Xn_ref_id : status}: ${xn link status}
    ${checked state}=    Get From Dictionary   ${xn link status}   ${xn link ref id}
    should be equal as strings     ${requested state}     ${checked state}

Wait for Xn link to be in given state
   [Documentation]   Check for 5 minutes if xn link is in requested state
   [Arguments]       ${requested state}   ${xn link ref id}=1    ${id_length}=1
   Wait until keyword succeeds   300s
   ...                           30s
   ...                           Check Xn link/s state   ${requested state}   ${xn link ref id}    ${id_length}
