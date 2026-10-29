*** Settings ***
Documentation
...               Variables settings for 5GC002493 UE1

*** Variables ***

&{DICTONARY_SLOTYPEREQ_FDD_IE} 				    DlData_SlotTypeReq.SlotTypeReq.slotType=0x00000021
...           DlData_SlotTypeReq.pwrReductionPerSymb_dB.pwrReductionPerSymb_dB=00:00:00:00:00:00:00:00:00:00:00:00:00:00

&{DICTONARY_MEASUREMENT_REPORT_IND_IE} 	        itf_l2_ps_tm_cell_MeasurementReportInd.puschReport.reportRSSI=0x00000000



&{DICTONARY_PUSCHRECEIVEREQ_IE}                 UlData_PuschReceiveReq.grants_item_0.rnti=0x00000000
...                                             UlData_PuschReceiveReq.grants_item_0.ulDmrsConfigType=0x00000001
...    										    UlData_PuschReceiveReq.grants_item_0.ulDmrsLen=0x00000001
...    										    UlData_PuschReceiveReq.grants_item_0.ulDmrsTypeAPos=0x00000002
...    										    UlData_PuschReceiveReq.grants_item_0.startSymbol=0x00000000
...    										    UlData_PuschReceiveReq.grants_item_0.mcsTable=0x00000000
...    										    UlData_PuschReceiveReq.grants_item_0.codebookIndex=0x00000000
...    										    UlData_PuschReceiveReq.grants_item_0.nscId=0x00000000
...   										    UlData_PuschReceiveReq.grants_item_0.ulPtrsNumOfPorts=0x00000001
...    										    UlData_PuschReceiveReq.grants_item_0.ulPtrsResElemOffset=0x00000000
...    										    UlData_PuschReceiveReq.grants_item_0.numOfUciCsiPart1Bits=0x00000000
...    										    UlData_PuschReceiveReq.grants_item_0.numOfUciCsiPart1Symbols=0x00000000



&{DICTONARY_PUSCHRECEIVEREQ_G_FR1_A1_1_IE}      UlData_PuschReceiveReq.grants_item_7.tbSize_bits=0x00000868
...    										    UlData_PuschReceiveReq.grants_item_7.ulDmrsMappingType=0x00000000
...    										 	UlData_PuschReceiveReq.grants_item_7.ulDmrsAddPos=0x00000001
...    										    UlData_PuschReceiveReq.grants_item_7.numOfPuschSymbols=0x0000000e
...    									   	 	UlData_PuschReceiveReq.grants_item_7.numOfPrb=0x00000019
...   										 	UlData_PuschReceiveReq.grants_item_7.mcs=0x00000004
...    										 	UlData_PuschReceiveReq.grants_item_7.antPort=0x00008000
...    										    UlData_PuschReceiveReq.grants_item_7.spatialMode=0x00000000
...    										    UlData_PuschReceiveReq.grants_item_7.ulPtrsFlag=0x00000000
...    										    UlData_PuschReceiveReq.grants_item_7.ulPtrsTimeDensity=0x00000000
...    										    UlData_PuschReceiveReq.grants_item_7.ulPtrsFrequencyDensity=0x00000000
...   										 	UlData_PuschReceiveReq.grants_item_7.modulationOrder=0x00000002
...    										    UlData_PuschReceiveReq.grants_item_7.rvIndex=0x00000000
...    										    UlData_PuschReceiveReq.grants_item_7.k0divZ=0x00000000
...    										    UlData_PuschReceiveReq.grants_item_7.numOfLayers=0x00000001
...    										    UlData_PuschReceiveReq.grants_item_7.puschTransCoherence=0x00000002

&{DICTONARY_PUSCHRECEIVEREQ_G_FR1_A1_5_IE}      UlData_PuschReceiveReq.grants_item_0.tbSize_bits=0x00001100
...    										    UlData_PuschReceiveReq.grants_item_0.ulDmrsMappingType=0x00000000
...    										    UlData_PuschReceiveReq.grants_item_0.ulDmrsAddPos=0x00000001
...    										    UlData_PuschReceiveReq.grants_item_0.numOfPuschSymbols=0x0000000e
...    									   	    UlData_PuschReceiveReq.grants_item_0.numOfPrb=0x00000033
...   										    UlData_PuschReceiveReq.grants_item_0.mcs=0x00000004
...    										    UlData_PuschReceiveReq.grants_item_0.antPort=0x00008000
...    										    UlData_PuschReceiveReq.grants_item_0.spatialMode=0x00000000
...    										    UlData_PuschReceiveReq.grants_item_0.ulPtrsFlag=0x00000000
...    										    UlData_PuschReceiveReq.grants_item_0.ulPtrsTimeDensity=0x00000000
...    										    UlData_PuschReceiveReq.grants_item_0.ulPtrsFrequencyDensity=0x00000000
...   										    UlData_PuschReceiveReq.grants_item_0.modulationOrder=0x00000002
...    										    UlData_PuschReceiveReq.grants_item_0.rvIndex=0x00000000
...    										    UlData_PuschReceiveReq.grants_item_0.k0divZ=0x00000000
...    										    UlData_PuschReceiveReq.grants_item_0.numOfLayers=0x00000001
...    										    UlData_PuschReceiveReq.grants_item_0.puschTransCoherence=0x00000002

&{DICTONARY_PUSCHRECEIVEREQ_G_FR1_A1_7_IE}      UlData_PuschReceiveReq.grants_item_0.tbSize_bits=0x00000528
...    										    UlData_PuschReceiveReq.grants_item_0.ulDmrsMappingType=0x00000000
...    										    UlData_PuschReceiveReq.grants_item_0.ulDmrsAddPos=0x00000001
...    										    UlData_PuschReceiveReq.grants_item_0.numOfPuschSymbols=0x0000000e
...    									   	    UlData_PuschReceiveReq.grants_item_0.numOfPrb=0x0000000f
...   										    UlData_PuschReceiveReq.grants_item_0.mcs=0x00000004
...    										    UlData_PuschReceiveReq.grants_item_0.antPort=0x00008000
...    										    UlData_PuschReceiveReq.grants_item_0.spatialMode=0x00000000
...    										    UlData_PuschReceiveReq.grants_item_0.ulPtrsFlag=0x00000000
...    										    UlData_PuschReceiveReq.grants_item_0.ulPtrsTimeDensity=0x00000000
...    										    UlData_PuschReceiveReq.grants_item_0.ulPtrsFrequencyDensity=0x00000000
...   										    UlData_PuschReceiveReq.grants_item_0.modulationOrder=0x00000002
...    										    UlData_PuschReceiveReq.grants_item_0.rvIndex=0x00000000
...    										    UlData_PuschReceiveReq.grants_item_0.k0divZ=0x00000000
...    										    UlData_PuschReceiveReq.grants_item_0.numOfLayers=0x00000001
...    										    UlData_PuschReceiveReq.grants_item_0.puschTransCoherence=0x00000002

&{DICTONARY_PUSCHRECEIVEREQ_G_FR1_A2_5_IE}      UlData_PuschReceiveReq.grants_item_0.tbSize_bits=0x00004a10
...    										    UlData_PuschReceiveReq.grants_item_0.ulDmrsMappingType=0x00000000
...    						 		  		    UlData_PuschReceiveReq.grants_item_0.ulDmrsAddPos=0x00000001
...    										    UlData_PuschReceiveReq.grants_item_0.numOfPuschSymbols=0x0000000e
...    										    UlData_PuschReceiveReq.grants_item_0.numOfPrb=0x00000033
...                                             UlData_PuschReceiveReq.grants_item_0.mcs=0x00000010
...    										    UlData_PuschReceiveReq.grants_item_0.antPort=0x00008000
...    										    UlData_PuschReceiveReq.grants_item_0.spatialMode=0x00000000
...    										    UlData_PuschReceiveReq.grants_item_0.ulPtrsFlag=0x00000000
...    										    UlData_PuschReceiveReq.grants_item_0.ulPtrsTimeDensity=0x00000000
...    										    UlData_PuschReceiveReq.grants_item_0.ulPtrsFrequencyDensity=0x00000000
...                                             UlData_PuschReceiveReq.grants_item_0.modulationOrder=0x00000004
...    										    UlData_PuschReceiveReq.grants_item_0.rvIndex=0x00000000
...    										    UlData_PuschReceiveReq.grants_item_0.k0divZ=0x00000000
...    										    UlData_PuschReceiveReq.grants_item_0.numOfLayers=0x00000001
...    										    UlData_PuschReceiveReq.grants_item_0.puschTransCoherence=0x00000002

&{DICTONARY_PUSCHRECEIVEREQ_G_FR1_A3_1_IE}      UlData_PuschReceiveReq.grants_item_7.tbSize_bits=0x000005c8
...    										    UlData_PuschReceiveReq.grants_item_7.ulDmrsMappingType=0x00000000
...    						 		  		    UlData_PuschReceiveReq.grants_item_7.ulDmrsAddPos=0x00000000
...    										    UlData_PuschReceiveReq.grants_item_7.numOfPuschSymbols=0x0000000e
...    										    UlData_PuschReceiveReq.grants_item_7.numOfPrb=0x00000019
...                                             UlData_PuschReceiveReq.grants_item_7.mcs=0x00000002
...    										    UlData_PuschReceiveReq.grants_item_7.antPort=0x00008000
...    										    UlData_PuschReceiveReq.grants_item_7.spatialMode=0x00000000
...    										    UlData_PuschReceiveReq.grants_item_7.ulPtrsFlag=0x00000000
...    										    UlData_PuschReceiveReq.grants_item_7.ulPtrsTimeDensity=0x00000000
...    										    UlData_PuschReceiveReq.grants_item_7.ulPtrsFrequencyDensity=0x00000000
...                                             UlData_PuschReceiveReq.grants_item_7.modulationOrder=0x00000002
...    										    UlData_PuschReceiveReq.grants_item_7.numOfLayers=0x00000001
...    										    UlData_PuschReceiveReq.grants_item_7.puschTransCoherence=0x00000000

&{DICTONARY_PUSCHRECEIVEREQ_G_FR1_A3_7_IE}      UlData_PuschReceiveReq.grants_item_7.tbSize_bits=0x00003f08
...    										    UlData_PuschReceiveReq.grants_item_7.ulDmrsMappingType=0x00000000
...    						 		  		    UlData_PuschReceiveReq.grants_item_7.ulDmrsAddPos=0x00000000
...    										    UlData_PuschReceiveReq.grants_item_7.numOfPuschSymbols=0x0000000e
...    										    UlData_PuschReceiveReq.grants_item_7.numOfPrb=0x00000111
...                                             UlData_PuschReceiveReq.grants_item_7.mcs=0x00000002
...    										    UlData_PuschReceiveReq.grants_item_7.antPort=0x00008000
...    										    UlData_PuschReceiveReq.grants_item_7.spatialMode=0x00000000
...    										    UlData_PuschReceiveReq.grants_item_7.ulPtrsFlag=0x00000000
...    										    UlData_PuschReceiveReq.grants_item_7.ulPtrsTimeDensity=0x00000000
...    										    UlData_PuschReceiveReq.grants_item_7.ulPtrsFrequencyDensity=0x00000000
...                                             UlData_PuschReceiveReq.grants_item_7.modulationOrder=0x00000002
...    										    UlData_PuschReceiveReq.grants_item_7.numOfLayers=0x00000001
...    										    UlData_PuschReceiveReq.grants_item_7.puschTransCoherence=0x00000000

&{DICTONARY_PUSCHRECEIVEREQ_G_FR1_A3_5_IE}      UlData_PuschReceiveReq.grants_item_7.tbSize_bits=0x00000ba0
...    										    UlData_PuschReceiveReq.grants_item_7.ulDmrsMappingType=0x00000000
...    						 		  		    UlData_PuschReceiveReq.grants_item_7.ulDmrsAddPos=0x00000000
...    										    UlData_PuschReceiveReq.grants_item_7.numOfPuschSymbols=0x0000000e
...    										    UlData_PuschReceiveReq.grants_item_7.numOfPrb=0x00000033
...                                             UlData_PuschReceiveReq.grants_item_7.mcs=0x00000002
...    										    UlData_PuschReceiveReq.grants_item_7.antPort=0x8000
...    										    UlData_PuschReceiveReq.grants_item_7.spatialMode=0x00000002
...    										    UlData_PuschReceiveReq.grants_item_7.ulPtrsFlag=0x00000000
...    										    UlData_PuschReceiveReq.grants_item_7.ulPtrsTimeDensity=0x00000000
...    										    UlData_PuschReceiveReq.grants_item_7.ulPtrsFrequencyDensity=0x00000000
...                                             UlData_PuschReceiveReq.grants_item_7.modulationOrder=0x00000002
...    										    UlData_PuschReceiveReq.grants_item_7.numOfLayers=0x00000001
...    										    UlData_PuschReceiveReq.grants_item_7.puschTransCoherence=0x00000000

&{DICTONARY_PUSCHRECEIVEREQ_G_FR2_A1_2_IE}      UlData_PuschReceiveReq.grants_item_7.tbSize_bits=0x00000ae8
...    										    UlData_PuschReceiveReq.grants_item_7.ulDmrsMappingType=0x00000000
...    						 		  		    UlData_PuschReceiveReq.grants_item_7.ulDmrsAddPos=0x00000001
...    										    UlData_PuschReceiveReq.grants_item_7.numOfPuschSymbols=0x0000000e
...    										    UlData_PuschReceiveReq.grants_item_7.numOfPrb=0x00000020
...                                             UlData_PuschReceiveReq.grants_item_7.mcs=0x00000004
...    										    UlData_PuschReceiveReq.grants_item_7.antPort=0x00008000
...    										    UlData_PuschReceiveReq.grants_item_7.spatialMode=0x00000000
...    										    UlData_PuschReceiveReq.grants_item_7.freshHarqTrans=0x00000001
...    										    UlData_PuschReceiveReq.grants_item_7.ulPtrsFlag=0x00000000
...    										    UlData_PuschReceiveReq.grants_item_7.ulPtrsTimeDensity=0x00000000
...    										    UlData_PuschReceiveReq.grants_item_7.ulPtrsFrequencyDensity=0x00000000
...    										    UlData_PuschReceiveReq.grants_item_7.rvIndex=0x00000000
...    										    UlData_PuschReceiveReq.grants_item_7.k0divZ=0x00000000
...                                             UlData_PuschReceiveReq.grants_item_7.modulationOrder=0x00000002
...    										    UlData_PuschReceiveReq.grants_item_7.numOfLayers=0x00000001
...    										    UlData_PuschReceiveReq.grants_item_7.puschTransCoherence=0x00000002

&{DICTONARY_PUSCHRECEIVEREQ_G_FR2_A1_3_IE}      UlData_PuschReceiveReq.grants_item_7.tbSize_bits=0x00001600
...    										    UlData_PuschReceiveReq.grants_item_7.ulDmrsMappingType=0x00000000
...    						 		  		    UlData_PuschReceiveReq.grants_item_7.ulDmrsAddPos=0x00000001
...    										    UlData_PuschReceiveReq.grants_item_7.numOfPuschSymbols=0x0000000e
...    										    UlData_PuschReceiveReq.grants_item_7.numOfPrb=0x00000042
...                                             UlData_PuschReceiveReq.grants_item_7.mcs=0x00000004
...    										    UlData_PuschReceiveReq.grants_item_7.antPort=0x00008000
...    										    UlData_PuschReceiveReq.grants_item_7.spatialMode=0x00000000
...    										    UlData_PuschReceiveReq.grants_item_7.freshHarqTrans=0x00000001
...    										    UlData_PuschReceiveReq.grants_item_7.ulPtrsFlag=0x00000000
...    										    UlData_PuschReceiveReq.grants_item_7.ulPtrsTimeDensity=0x00000000
...    										    UlData_PuschReceiveReq.grants_item_7.ulPtrsFrequencyDensity=0x00000000
...    										    UlData_PuschReceiveReq.grants_item_7.rvIndex=0x00000000
...    										    UlData_PuschReceiveReq.grants_item_7.k0divZ=0x00000000
...                                             UlData_PuschReceiveReq.grants_item_7.modulationOrder=0x00000002
...    										    UlData_PuschReceiveReq.grants_item_7.numOfLayers=0x00000001
...    										    UlData_PuschReceiveReq.grants_item_7.puschTransCoherence=0x00000002

&{DICTONARY_PUSCHRECEIVEREQ_G_FR2_A3_4_IE}      UlData_PuschReceiveReq.grants_item_7.tbSize_bits=0x00000a68
...    										    UlData_PuschReceiveReq.grants_item_7.ulDmrsMappingType=0x00000001
...    						 		  		    UlData_PuschReceiveReq.grants_item_7.ulDmrsAddPos=0x00000000
...    										    UlData_PuschReceiveReq.grants_item_7.numOfPuschSymbols=0x0000000a
...    										    UlData_PuschReceiveReq.grants_item_7.numOfPrb=0x00000042
...                                             UlData_PuschReceiveReq.grants_item_7.mcs=0x00000002
...    										    UlData_PuschReceiveReq.grants_item_7.antPort=0x00008000
...    										    UlData_PuschReceiveReq.grants_item_7.spatialMode=0x00000000
...    										    UlData_PuschReceiveReq.grants_item_7.ulPtrsFlag=0x00000001
...    										    UlData_PuschReceiveReq.grants_item_7.ulPtrsTimeDensity=0x00000001
...    										    UlData_PuschReceiveReq.grants_item_7.ulPtrsFrequencyDensity=0x00000002
...                                             UlData_PuschReceiveReq.grants_item_7.modulationOrder=0x00000002
...    										    UlData_PuschReceiveReq.grants_item_7.numOfLayers=0x00000001
...    										    UlData_PuschReceiveReq.grants_item_7.puschTransCoherence=0x00000000

&{DICTONARY_PUSCHRECEIVERESPHARQD_IE}           UlData_PuschReceiveRespHarqU.grants_item_7.crc=0x00000001
...                                             UlData_PuschReceiveRespHarqU.grants_item_7.dtx=0x00000001

&{DICTONARY_PUCCHRECEIVEREQ_IE}           	    *.subcells-.Length=0x00000001
...											    3gpp.subcells_item_0.subcellId=0x00000000
...											    *.pucchResources-.Length=0x00000001
...											    3gpp.pucchResources_item_0.rnti=0x00000000
...											    UlData_PucchReceiveReq.pucchResources_item_0.numOfLayers=0x00000001
...											    UlData_PucchReceiveReq.pucchResources_item_0.numOfAntennaPorts=0x00000001
...											    UlData_PucchReceiveReq.pucchResources_item_0.harqProcessIndex=0x00000000
...											    UlData_PucchReceiveReq.pucchResources_item_0.initialCyclicShift=0x00000000
...											    UlData_PucchReceiveReq.pucchResources_item_0.numCeAxCIndex=0x0000002
...                                             UlData_PucchReceiveReq.pucchResources_item_0.timeDomainOcc=0x00000000
...                                             UlData_PucchReceiveReq.pucchResources_item_0.numOfSymbols=0x0000000e
...                                             UlData_PucchReceiveReq.pucchResources_item_0.firstSymbol=0x00000000
...                                             UlData_PucchReceiveReq.pucchResources_item_0.frequencyHopping=0x00000001
...                                             UlData_PucchReceiveReq.pucchResources_item_0.modulationType=0x00000001


&{DICTONARY_PUCCHRECEIVEREQ_F0_IE}  UlData_PucchReceiveReq.pucchResources_item_0.srBitDetection=0x00000000


&{DICTONARY_PUCCHRECEIVEREQ_F1_IE}  UlData_PucchReceiveReq.pucchResources_item_0.srBitDetection=0x00000000
...											    UlData_PucchReceiveReq.pucchResources_item_0.firstSymbol=0x00000000
...											    UlData_PucchReceiveReq.pucchResources_item_0.frequencyHopping=0x00000001
...                                             UlData_PucchReceiveReq.pucchResources_item_0.additionalDmrs=0x00000000
...                                             UlData_PucchReceiveReq.pucchResources_item_0.timeDomainOcc=0x00000000
...                                             UlData_PucchReceiveReq.pucchResources_item_0.modulationType=0x00000001

&{DICTONARY_PUCCHRECEIVEREQ_F2_ACK_IE}  UlData_PucchReceiveReq.pucchResources_item_0.srBitDetection=0x00000002


&{DICTONARY_PUCCHRECEIVEREQ_F2_UCI_IE}  UlData_PucchReceiveReq.pucchResources_item_0.srBitDetection=0x00000002


&{DICTONARY_PUCCHRECEIVEREQ_F3_IE}  UlData_PucchReceiveReq.pucchResources_item_0.srBitDetection=0x00000000
...											    UlData_PucchReceiveReq.pucchResources_item_0.firstSymbol=0x00000000
...											    UlData_PucchReceiveReq.pucchResources_item_0.frequencyHopping=0x00000001
...                                             UlData_PucchReceiveReq.pucchResources_item_0.timeDomainOcc=0x00000000
...                                             UlData_PucchReceiveReq.pucchResources_item_0.modulationType=0x00000001

&{DICTONARY_PUCCHRECEIVEREQ_F0_F2_firstSymbol_freqhopping_1}    UlData_PucchReceiveReq.pucchResources_item_0.firstSymbol=0x0000000d
...                                             UlData_PucchReceiveReq.pucchResources_item_0.frequencyHopping=0x00000000

&{DICTONARY_PUCCHRECEIVEREQ_F0_F2_firstSymbol_freqhopping_2}    UlData_PucchReceiveReq.pucchResources_item_0.firstSymbol=0x00000000c
...                                             UlData_PucchReceiveReq.pucchResources_item_0.frequencyHopping=0x00000001

&{DICTONARY_PUCCHRECEIVEREQ_nANPucch}   UlData_PucchReceiveReq.pucchResources_item_0.nANPucch=0x00000000

&{DICTONARY_PUCCHRECEIVERESPHARQD_IE}          UlData_PucchReceiveRespHarqD.pucchResources_item_0.dtx=0x00000001
...                                            UlData_PucchReceiveRespHarqD.ackNack.ackNack=00:00:00:00:00:00:00

&{DICTONARY_PRACHRECEIVEREQ_IE}                UlData_PrachReceiveReq.subcells-Length=0x00000001
...								               UlData_PrachReceiveReq.subcells_item_0.subcellId=0x00000000
...								               UlData_PrachReceiveReq.subcells_item_0.prachPrbOffset=0x00000000
...								               UlData_PrachReceiveReq.occasions_item_23.numCeAxCIndex=2


&{DICTONARY_PDSCHSENDREQ_IE}                   DlData_PdschSendReq.grants_item_0.dlDmrsConfigType=1
...                                            DlData_PdschSendReq.grants_item_0.dlDmrsLen=1
...                                            DlData_PdschSendReq.grants_item_0.dlDmrsMappingType=0
...                                            DlData_PdschSendReq.grants_item_0.dlDmrsAddPos=0x00000001
...                                            DlData_PdschSendReq.grants_item_0.dlDmrsTypeAPos=0x00000002
...                                            DlData_PdschSendReq.grants_item_0.numOfDmrsCdmGroupWithoutData=0x00000001
...                                            DlData_PdschSendReq.grants_item_0.nscId=0x00000000
...                                            DlData_PdschSendReq.grants_item_0.offsetRbDmrs=0x00000000
...                                            DlData_PdschSendReq.grants_item_0.startSymbol=0x00000000
...                                            DlData_PdschSendReq.grants_item_0.antPort=0x00008000
...                                            DlData_PdschSendReq.grants_item_0.spatialMode=2
...                                            DlData_PdschSendReq.grants_item_0.codebookIndex=0
...                                            DlData_PdschSendReq.grants_item_0.dlPtrsFlag=0
...                                            DlData_PdschSendReq.grants_item_0.dlPtrsTimeDensity=0
...                                            DlData_PdschSendReq.grants_item_0.dlPtrsFrequencyDensity=0
...                                            DlData_PdschSendReq.grants_item_0.dlPtrsNumOfPorts=0x00000001
...                                            DlData_PdschSendReq.grants_item_0.dlPtrsResElemOffset=0x00000000
...                                            DlData_PdschSendReq.grants_item_0.rvIndex=0x00000000
...                                            DlData_PdschSendReq.grants_item_0.k0divZ=0x00000000
...                                            DlData_PdschSendReq.grants_item_0.numOfLayers=0x00000001
...                                            DlData_PdschSendReq.grants_item_0.pdschPrecodingOption4x4=0
...                                            DlData_PdschSendReq.grants_item_0.numCeAxCIndex=0x00000002

&{DICTONARY_PDSCHSENDREQ_TM_1.1_FDD_FR1_IE}    DlData_PdschSendReq.grants_item_0.rnti=0x00000000
...                                            DlData_PdschSendReq.grants_item_0.mcs=0x00000000
...                                            DlData_PdschSendReq.grants_item_0.mcsTable=1
...                                            DlData_PdschSendReq.grants_item_0.startPrb=0x00000000
...                                            DlData_PdschSendReq.grants_item_0.modulationOrder=2
...                                            DlData_PdschSendReq.grants_item_0.rat0Bitmap=0x00000000
...                                            DlData_PdschSendReq.grants_item_0.tbIndex=0x00000000
...                                            DlData_PdschSendReq.grants_item_0.tbStartOffset_bits=0x00000000


&{DICTONARY_PDSCHSENDREQ_TM_1.1_TDD_FR1_IE}    DlData_PdschSendReq.grants_item_0.rnti=0x00000000
...                                            DlData_PdschSendReq.grants_item_0.mcs=0x00000000
...                                            DlData_PdschSendReq.grants_item_0.modulationOrder=0x00000002
...                                            DlData_PdschSendReq.grants_item_0.mcsTable=0x00000001
...                                            DlData_PdschSendReq.grants_item_0.tbIndex=0x00000000
...                                            DlData_PdschSendReq.grants_item_0.tbStartOffset_bits=0x00000000
...                                            DlData_PdschSendReq.grants_item_0.startPrb=0x00000003
...                                            DlData_PdschSendReq.grants_item_0.rat0Bitmap=0x00000000


&{DICTONARY_PDSCHSENDREQ_TM_1.2_TDD_FR1_IE}    DlData_PdschSendReq.grants_item_0.rnti=0x00000000
...                                            DlData_PdschSendReq.grants_item_0.startSymbol=0x00000000
...                                            DlData_PdschSendReq.grants_item_0.mcs=0x00000000
...                                            DlData_PdschSendReq.grants_item_0.modulationOrder=0x00000002
...                                            DlData_PdschSendReq.grants_item_0.mcsTable=0x00000001
...                                            DlData_PdschSendReq.grants_item_0.startPrb=0x00000004

&{DICTONARY_PDSCHSENDREQ_TM_TDD_1.1_FR1_IE}    DlData_PdschSendReq.grants_item_0.rnti=0x00000000
...                                            DlData_PdschSendReq.grants_item_0.startSymbol=0x00000000
...                                            DlData_PdschSendReq.grants_item_0.mcs=0x00000000
...                                            DlData_PdschSendReq.grants_item_0.modulationOrder=0x00000002
...                                            DlData_PdschSendReq.grants_item_0.mcsTable=0x00000001
...                                            DlData_PdschSendReq.grants_item_0.startPrb=0x00000003
...                                            DlData_PdschSendReq.grants_item_0.numOfPrb=0x00000030

&{DICTONARY_PDSCHSENDREQ_TM_FDD_1.1_FR1_IE}    DlData_PdschSendReq.grants_item_0.rnti=0x00000000
...                                            DlData_PdschSendReq.grants_item_0.startSymbol=0x00000000
...                                            DlData_PdschSendReq.grants_item_0.mcs=0x00000000
...                                            DlData_PdschSendReq.grants_item_0.modulationOrder=0x00000002
...                                            DlData_PdschSendReq.grants_item_0.mcsTable=0x00000001
...                                            DlData_PdschSendReq.grants_item_0.startPrb=0x00000003
...                                            DlData_PdschSendReq.grants_item_0.numOfPrb=0x00000016

&{DICTONARY_PDSCHSENDREQ_TM_TDD_3.1_FR1_IE}    DlData_PdschSendReq.grants_item_0.rnti=0x00000000
...                                            DlData_PdschSendReq.grants_item_0.startSymbol=0x00000000
...                                            DlData_PdschSendReq.grants_item_0.mcs=0x0000000b
...                                            DlData_PdschSendReq.grants_item_0.modulationOrder=0x00000006
...                                            DlData_PdschSendReq.grants_item_0.mcsTable=0x00000001
...                                            DlData_PdschSendReq.grants_item_0.startPrb=0x00000003


&{DICTONARY_PDSCHSENDREQ_TM_2_FDD_FR1_IE}      DlData_PdschSendReq.grants_item_0.rnti=0x00000000
...                                            DlData_PdschSendReq.grants_item_0.mcs=0x00000011
...                                            DlData_PdschSendReq.grants_item_0.numOfPrb=0x00000001
...                                            DlData_PdschSendReq.grants_item_0.pdschBundleSize=0x00000001
...                                            DlData_PdschSendReq.grants_item_0.modulationOrder=0x00000006
...                                            DlData_PdschSendReq.grants_item_0.mcsTable=0x00000000
...                                            DlData_PdschSendReq.grants_item_0.tbIndex=0x00000000
...                                            DlData_PdschSendReq.grants_item_0.tbStartOffset_bits=0x00000000
...                                            DlData_PdschSendReq.grants_item_0.rat0Bitmap=0x00000000



&{DICTONARY_PDSCHSENDREQ_TM_3.1_TDD_FR1_IE}     DlData_PdschSendReq.grants_item_0.rnti=0x00000000
...                                            DlData_PdschSendReq.grants_item_0.mcs=0x0000000b
...                                            DlData_PdschSendReq.grants_item_0.modulationOrder=0x00000006
...                                            DlData_PdschSendReq.grants_item_0.mcsTable=0x00000001
...                                            DlData_PdschSendReq.grants_item_0.startPrb=0x00000000
...                                            DlData_PdschSendReq.grants_item_0.rat0Bitmap=0x00000000
...                                            DlData_PdschSendReq.grants_item_0.tbIndex=0x00000000
...                                            DlData_PdschSendReq.grants_item_0.tbStartOffset_bits=0x00000000


&{DICTONARY_PDSCHSENDREQ_TM3_1A_TDD_FR1_IE}    DlData_PdschSendReq.grants_item_0.rnti=0x00000000
...                                            DlData_PdschSendReq.grants_item_0.mcs=0x00000014
...                                            DlData_PdschSendReq.grants_item_0.modulationOrder=0x00000008
...                                            DlData_PdschSendReq.grants_item_0.mcsTable=0x00000001
...                                            DlData_PdschSendReq.grants_item_0.startPrb=0x00000003
...                                            DlData_PdschSendReq.grants_item_0.rat0Bitmap=0x00000000
...                                            DlData_PdschSendReq.grants_item_0.tbIndex=0x00000000
...                                            DlData_PdschSendReq.grants_item_0.tbStartOffset_bits=0x00000000

&{DICTONARY_PDSCHSENDREQ_TM_3.2_FDD_FR1_IE}     DlData_PdschSendReq.grants_item_0.rnti=0x00000000
...                                            DlData_PdschSendReq.grants_item_0.startSymbol=0x00000000
...                                            DlData_PdschSendReq.grants_item_0.mcs=0x00000000
...                                             DlData_PdschSendReq.grants_item_0.mcsTable=0x00000000
...                                            DlData_PdschSendReq.grants_item_0.startPrb=0x00000003

&{DICTONARY_PDSCHSENDREQ_TM_TDD_3.3_FR1_IE}     DlData_PdschSendReq.grants_item_0.mcsTable=0x00000001

&{DICTONARY_PDSCHSENDREQ_TM_FDD_3.3_FR1_IE}    DlData_PdschSendReq.grants_item_0.rnti=0x00000000
...                                            DlData_PdschSendReq.grants_item_0.startSymbol=0x00000000
...                                            DlData_PdschSendReq.grants_item_0.mcs=0x0000000A
...                                            DlData_PdschSendReq.grants_item_0.modulationOrder=0x00000004
...                                            DlData_PdschSendReq.grants_item_0.mcsTable=0x00000000
...                                            DlData_PdschSendReq.grants_item_0.startPrb=0x00000003

&{DL_PDSCHSENDREQ_TM3.1A_TDD_UE1_5GC002493_C_90MHz}    DlData_PdschSendReq.grants_item_0.rnti=0x00000000
...                                            DlData_PdschSendReq.grants_item_0.pdschTbTransmitPower=-0x165
...                                            DlData_PdschSendReq.grants_item_0.numOfPrb=0x000000f2

&{DL_PDSCHSENDREQ_TM1.1-3.1_TDD_UE1_C_90MHz}    DlData_PdschSendReq.grants_item_0.rnti=0x00000000
...                                            DlData_PdschSendReq.grants_item_0.pdschTbTransmitPower=-0x165
...                                            DlData_PdschSendReq.grants_item_0.numOfPrb=0x000000f2

&{DL_PDSCHSENDREQ_TM3.2_TDD_UE1_C_90MHz}    DlData_PdschSendReq.grants_item_0.rnti=0x00000001
...                                            DlData_PdschSendReq.grants_item_0.startPrb=0x00000010
...                                            DlData_PdschSendReq.grants_item_0.pdschTbTransmitPower=-0x183
...                                            DlData_PdschSendReq.grants_item_0.numOfPrb=0x00000080
...                                            DlData_PdschSendReq.grants_item_0.rbgSize=0x00000010
...                                            DlData_PdschSendReq.grants_item_0.rbgSizeFirst=0x00000010

&{DL_PDSCHSENDREQ_TM2_2a_TDD_UE1_C_90MHz_startPrb1}    DlData_PdschSendReq.grants_item_0.rnti=0x00000002
...                                            DlData_PdschSendReq.grants_item_0.startPrb=0x00000000
...                                            DlData_PdschSendReq.grants_item_0.pdschTbTransmitPower=-0x165

&{DL_PDSCHSENDREQ_TM2_2a_TDD_UE1_C_90MHz_startPrb2}    DlData_PdschSendReq.grants_item_0.rnti=0x00000002
...                                            DlData_PdschSendReq.grants_item_0.startPrb=0x0000007a
...                                            DlData_PdschSendReq.grants_item_0.pdschTbTransmitPower=-0x165

&{DL_PDSCHSENDREQ_TM2_2a_TDD_UE1_C_90MHz_startPrb3}    DlData_PdschSendReq.grants_item_0.rnti=0x00000002
...                                            DlData_PdschSendReq.grants_item_0.startPrb=0x000000f4
...                                            DlData_PdschSendReq.grants_item_0.pdschTbTransmitPower=-0x165

&{DL_PDSCHSENDREQ_TM1.2_TDD_UE1_C_90MHz}    DlData_PdschSendReq.grants_item_0.rnti=0x00000000
...                                            DlData_PdschSendReq.grants_item_0.startPrb=0x00000010
...                                            DlData_PdschSendReq.grants_item_0.pdschTbTransmitPower=-0x147
...                                            DlData_PdschSendReq.grants_item_0.numOfPrb=0x00000060
...                                            DlData_PdschSendReq.grants_item_0.rbgSize=0x00000010
...                                            DlData_PdschSendReq.grants_item_0.rbgSizeFirst=0x00000010

&{DL_PDSCHSENDREQ_TM3.3_TDD_UE1_C_90MHz}    DlData_PdschSendReq.grants_item_0.rnti=0x00000001
...                                            DlData_PdschSendReq.grants_item_0.startPrb=0x00000010
...                                            DlData_PdschSendReq.grants_item_0.pdschTbTransmitPower=-0x1a1
...                                            DlData_PdschSendReq.grants_item_0.numOfPrb=0x00000070
...                                            DlData_PdschSendReq.grants_item_0.rbgSize=0x00000010
...                                            DlData_PdschSendReq.grants_item_0.rbgSizeFirst=0x00000010

&{DICTONARY_PDCCHSENDREQ_IE}                   DlData_PdcchSendReq.PdcchSendReq.beamId=0x00000000
...                                            DlData_PdcchSendReq.dciInfo-.Offset"=0x00000008
...                                            DlData_PdcchSendReq.dciInfo-.Length=0x00000001
...                                            DlData_PdcchSendReq.dciInfo_item_0.rnti=0x00000000
...                                            DlData_PdcchSendReq.dciInfo_item_0.startSymbolNumber=0x00000000
...                                            DlData_PdcchSendReq.dciInfo_item_0.numOfSymbols=0x00000002
...                                            DlData_PdcchSendReq.dciInfo_item_0.startCce=0x00000000
...                                            DlData_PdcchSendReq.dciInfo_item_0.aggregationLevel=1
...                                            DlData_PdcchSendReq.dciInfo_item_0.dmrsReferencePoint=0
...                                            DlData_PdcchSendReq.dciInfo_item_0.pdcchPrecodingOption4x4=0
...                                            DlData_PdcchSendReq.dciInfo_item_0.coresetFreqDomain=0x8000000000000000
...                                            DlData_PdcchSendReq.dciInfo_item_0.cceRegMappingType=1
...                                            DlData_PdcchSendReq.dciInfo_item_0.pdcchPrecodingOption4x4=0x00000000
...                                            DlData_PdcchSendReq.dciInfo_item_0.nShiftModNumOfRegBundles=0x00000000
...                                            DlData_PdcchSendReq.dciInfo_item_0.interleaverRows=2
...                                            DlData_PdcchSendReq.dciInfo_item_0.regBundleSize=6
...                                            DlData_PdcchSendReq.dciInfo_item_0.precoderGranularity=0x00000000
...                                            DlData_PdcchSendReq.dciInfo_item_0.coresetFreqDomainRbShift=0x00000000
...                                            DlData_PdcchSendReq.dciInfo_item_0.dciSize=0x00000030
...                                            DlData_PdcchSendReq.dciInfo_item_0.numCeAxCIndex=2


&{DICTONARY_PDSCHPAYLOADTBSENDREQ_IE}          DlData_PdschPayloadTbSendReq.PdschPayloadTbSendReq.rnti=0x00000000
...                                            DlData_PdschPayloadTbSendReq.PdschPayloadTbSendReq.tbIndex=0x00000000

&{DICTONARY_PDSCHPAYLOADTBSENDREQ_FR1_TM2a_IE}    DlData_PdschPayloadTbSendReq.PdschPayloadTbSendReq.rnti=0x00000002

${BIP_capture_File_Name}    BIP_ASIK_Slave
${BIP_capture_Path}         ${EMPTY}

