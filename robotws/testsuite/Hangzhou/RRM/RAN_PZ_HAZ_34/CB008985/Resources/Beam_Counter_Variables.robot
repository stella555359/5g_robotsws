*** Settings ***
Documentation    This is about common variables used for 8985 feature.

*** Variables ***
#Following Counter is not defined by CB008985 Feature, Just Follow Legacy.
# miNrBeamforming also need to be setted as 5min
#switch to subcell-0
${BEAM_CHANGE_0_0_PM}=            M55305C03001
#subcell-1 switch to subcell-0
${BEAM_CHANGE_1_0_PM}=            M55305C03002
${BEAM_CHANGE_2_0_PM}=            M55305C03003

#switch to subcell-1
${BEAM_CHANGE_0_1_PM}=            M55305C03009
${BEAM_CHANGE_1_1_PM}=            M55305C03010
${BEAM_CHANGE_2_1_PM}=            M55305C03011

#switch to subcell-2
${BEAM_CHANGE_0_2_PM}=            M55305C03017
${BEAM_CHANGE_1_2_PM}=            M55305C03018
${BEAM_CHANGE_2_2_PM}=            M55305C03019

#subcell0 switch to subcell5
${BEAM_CHANGE_0_5_PM}=            M55305C03041

#serving subcell counters
${DL_SERV_BEAM_ID_BEAM_0_PM}=   M55305C00001
${UL_SERV_BEAM_ID_BEAM_0_PM}=   M55305C01001

${DL_SERV_BEAM_ID_BEAM_1_PM}=   M55305C00002
${DL_SERV_BEAM_ID_BEAM_2_PM}=   M55305C00003
${DL_SERV_BEAM_ID_BEAM_3_PM}=   M55305C00004

${UL_SERV_BEAM_ID_BEAM_1_PM}=   M55305C01002
${UL_SERV_BEAM_ID_BEAM_2_PM}=   M55305C01003
${UL_SERV_BEAM_ID_BEAM_3_PM}=   M55305C01004
