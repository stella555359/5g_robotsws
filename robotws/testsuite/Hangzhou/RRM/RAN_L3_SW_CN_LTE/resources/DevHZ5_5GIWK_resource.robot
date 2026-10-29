*** Settings ***
Documentation     5GIWK (ENDC) cases resource
...               2020.3.3 absoluteFrequencySSB calculation formula: 600032 + 96 * floor((nrarfcn - 599984) / 96)
...               2020.3.6 revert to complicated algorithm and R&D not answer
...               2020.3.23 update for new 3GPP specification that based on gscn, and the nrarfcn just calculate the absolutefrequencyPointA
...               2020.3.24 prepare a knife wherein absence of gscn parameter in set_cell means legacy computation of ssbFrequency would be used

*** Variables ***
${GSCN6640}  531170  #${NRARFCN??????}
${GSCN6637}  530930
${GSCN2356}  188450
${GSCN7812}  630048
${GSCN4600}  367970
${GSCN22325}  2036539
${GSCN6551}  524170
${GSCN7881}  636672
${GSCN8020}  650016
${GSCN1843}  147410
${NRARFCN531198}  531232  #531200  ${GSCN????}
${NRARFCN531000}  531040  #531008
${NRARFCN188500}  188512  #188480
${NRARFCN630000}  629984
${NRARFCN368000}  368032  #368000
${NRARFCN2036667}  2036672
${NRARFCN524100}  524128  #524096
${NRARFCN636666}  636704
${NRARFCN650000}  650048
${NRARFCN147500}  147520  #147488
${NRARFCN633440}  633440

*** Keywords ***
Get Gnb Cell Ssb From Nrarfcn
    [Arguments]  ${nrarfcn}
#  Run Keyword And Return  Evaluate  int(600032 + 96 * math.floor((${nrarfcn} - 599984) / 96))  math
    Return From Keyword  ${NRARFCN${nrarfcn}}

Get Gnb Cell Ssb From Gscn
    [Arguments]  ${gscn}
    ${gscnFreq}=  Run Keyword If  ${gscn} % 3 == 0 and 2 < ${gscn} <= 7498  Evaluate  1200 * (${gscn} / 3) + 150
    ...  ELSE IF  ${gscn} % 3 == 1 and 2 < ${gscn} <= 7498  Evaluate  1200 * (${gscn} / 3) + 250
    ...  ELSE IF  ${gscn} % 3 == 2 and 2 < ${gscn} <= 7498  Evaluate  1200 * (${gscn} / 3 + 1) + 50
    ...  ELSE IF  7499 <= ${gscn} <= 22255  Evaluate  3000000 + 1440 * (${gscn} - 7499)
    ...  ELSE IF  22256 <= ${gscn} <= 26639  Evaluate  24250080 + 17280 * (${gscn} - 22256)
    ...  ELSE  Return From Keyword  out_of_range
    ${absoluteFrequencySSB}=  Run Keyword If  ${gscn} <= 7498  Evaluate  ${gscnFreq} / 5
    ...  ELSE IF  7498 < ${gscn} <= 22255  Evaluate  600000 + (${gscnFreq} - 3000000) / 15
    ...  ELSE IF  ${gscn} > 22255  Evaluate  2016667 + (${gscnFreq} - 24250080) / 60
    [Return]  ${absoluteFrequencySSB}
