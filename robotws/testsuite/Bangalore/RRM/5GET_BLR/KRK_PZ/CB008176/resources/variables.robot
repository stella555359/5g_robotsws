*** Variables ***
@{tshark_options}    -o    ntrstr.defragment:TRUE    -o    ntrstr.port:49148

&{ue_mapping_SA}
...    first_ue_with_location=${11}
...    first_ue_without_location=${1}
...    second_ue_with_location=${12}
...    second_ue_without_location=${2}
...    first_ue_without_sinr=${13}

&{ue_mapping_NSA}
...    first_ue_with_location=${111}
...    first_ue_without_location=${101}
...    second_ue_with_location=${112}
...    second_ue_without_location=${102}

&{periodic_MDT_cellTrace_no_location}
...    trace_name=nr-rrc.measurementReport_element
...    measResults.*measId=3    MeasResultServMO.*physCellId=50
...    measResultServingCell.*rsrp=30    measResultServingCell.*rsrq=30    measResultServingCell.*sinr=30
...    ResultsPerSSB_Index.*rsrp=50    ResultsPerSSB_Index.*rsrq=50    ResultsPerSSB_Index.*sinr=50

&{periodic_MDT_cellTrace_no_location_no_sinr}
...    trace_name=nr-rrc.measurementReport_element
...    measResults.*measId=3    MeasResultServMO.*physCellId=50
...    measResultServingCell.*rsrp=30    measResultServingCell.*rsrq=30
...    ResultsPerSSB_Index.*rsrp=50    ResultsPerSSB_Index.*rsrq=50

&{periodic_MDT_cellTrace_with_location}
...    trace_name=nr-rrc.measurementReport_element
...    measResults.*measId=3    MeasResultServMO.*physCellId=50
...    measResultServingCell.*rsrp=30    measResultServingCell.*rsrq=30    measResultServingCell.*sinr=30
...    ResultsPerSSB_Index.*rsrp=50    ResultsPerSSB_Index.*rsrq=50    ResultsPerSSB_Index.*sinr=50
...    locationInfo_r16.*commonLocationInfo.*gnss_TOD_msec_r16=.*

&{periodic_MDT_record_for_SA_UE_no_sinr}
...    record_name=ueMeasRecord
...    carrierFreq=636576    triggerType=6    purpose=3
...    measResultServingMos=1    measResultSsbIndexes=1
...    servCellId=0    pci=50   pcell=1    ssbCellResult.*rsrp=30    ssbCellResult.*rsrq=30
...    ssbIndex=0    measResultSsb.*rsrp=50    measResultSsb.*rsrq=50

&{rrmEvent_MDT_record_for_SA_UE_no_location}
...    record_name=ueMeasRecord
...    carrierFreq=636576    triggerType=2    purpose=0    pci=50
...    measResultNeighCellsNR=1
...    ssbCellRsrp=51    ssbCellRsrq=51

&{periodic_MDT_record_for_SA_UE}
...    record_name=ueMeasRecord
...    carrierFreq=636576    triggerType=6    purpose=3
...    measResultServingMos=1    measResultSsbIndexes=1
...    servCellId=0    pci=50   pcell=1    ssbCellResult.*rsrp=30    ssbCellResult.*rsrq=30    ssbCellResult.*sinr=30
...    ssbIndex=0    measResultSsb.*rsrp=50    measResultSsb.*rsrq=50    measResultSsb.*sinr=50

&{periodic_MDT_record_for_NSA_UE}
...    record_name=ueMeasRecord
...    carrierFreq=636576    triggerType=6    purpose=3
...    measResultServingMos=1    measResultSsbIndexes=1
...    servCellId=8    pci=50   pcell=1    ssbCellResult.*rsrp=30    ssbCellResult.*rsrq=30    ssbCellResult.*sinr=30
...    ssbIndex=0    measResultSsb.*rsrp=50    measResultSsb.*rsrq=50    measResultSsb.*sinr=50

&{periodic_MDT_record_for_SA_UE_no_location}
...    record_name=ueMeasRecord    carrierFreq=636576
...    triggerType=6    purpose=3    pci=50
...    pcell=1    ssbCellResult.*rsrp=30    ssbCellResult.*rsrq=30
...    ssbCellResult.*sinr=30    ssbIndex=0    measResultSsb.*rsrp=50    measResultSsb.*rsrq=50
...    measResultSsb.*sinr=50

&{rrmEvent_MDT_cellTrace_no_location}
...    trace_name=nr-rrc.measurementReport_element
...    measurementReport_element=.*
...    measResults.*measId=1    MeasResultServMO.*physCellId=50
...    measResultServingCell.*rsrp=50    measResultServingCell.*rsrq=50
...    resultsSSB_Cell_element.*rsrp=51    resultsSSB_Cell_element.*rsrq=51

&{rrmEvent_MDT_cellTrace_no_location_no_sinr}
...    trace_name=nr-rrc.measurementReport_element
...    measResults.*measId=1    MeasResultServMO.*physCellId=50
...    measResultServingCell.*rsrp=50    measResultServingCell.*rsrq=50
...    ResultsPerSSB_Index.*rsrp=51    ResultsPerSSB_Index.*rsrq=51

&{rrmEvent_MDT_cellTrace_with_location}
...    trace_name=nr-rrc.measurementReport_element
...    measResults.*measId=1    MeasResultServMO.*physCellId=50
...    measResultServingCell.*rsrp=50    measResultServingCell.*rsrq=50
...    MeasResultNR.*physCellId=50    MeasResultNR.*rsrp=51    MeasResultNR.*rsrq=51
...    locationInfo_r16.*commonLocationInfo.*gnss_TOD_msec_r16=.*

&{rrmEvent_MDT_record_for_SA_UE_no_sinr}
...    record_name=ueMeasRecord
...    carrierFreq=636576    triggerType=2    purpose=0
...    servCellId=0    pci=50   pcell=1    ssbCellResult.*rsrp=30    ssbCellResult.*rsrq=30
...    ssbIndex=0    measResultSsb.*rsrp=50    measResultSsb.*rsrq=50

# do poprawy
&{rrmEvent_MDT_record_for_SA_UE}
...    record_name=ueMeasRecord
...    carrierFreq=636576    triggerType=2    purpose=1
...    MeasResultServingMo.*pci=50    MeasResultServingMo.*pcell=1
...    MeasResultServingMo.*rsrp=50    MeasResultServingMo.*rsrq=50
...    measResultNeighCellsNR=1
...    MeasResultNeighCellNR.*pci=50    MeasResultNeighCellNR.*rsrp=51    MeasResultNeighCellNR.*rsrq=51

&{rrmEvent_MDT_record_for_NSA_UE}
...    record_name=ueMeasRecord
...    carrierFreq=636576    triggerType=2    purpose=0
...    measResultNeighCellsNR=1
...    pci=50    ssbCellRsrp=51    ssbCellRsrq=51

@{internal_count_prints_1_UE_attach_detach}
...    allocated with mdt, current list size of UEs with MDT enabled is 1
...    allocated with mdt, current list size of UEs with MDT enabled is 1
...    deallocated with mdt, current list size of UEs with MDT enabled is 0

@{internal_count_prints_1_NSA_UE_attach_detach}
...    allocated with mdt, current list size of UEs with MDT enabled is 1
...    deallocated with mdt, current list size of UEs with MDT enabled is 0

@{internal_count_prints_1_UE_attach_detach_twice}
...    allocated with mdt, current list size of UEs with MDT enabled is 1
...    deallocated with mdt, current list size of UEs with MDT enabled is 0
...    allocated with mdt, current list size of UEs with MDT enabled is 1
...    deallocated with mdt, current list size of UEs with MDT enabled is 0

@{internal_count_prints_2_UEs_attach_detach}
...    allocated with mdt, current list size of UEs with MDT enabled is 1
...    allocated with mdt, current list size of UEs with MDT enabled is 2
...    deallocated with mdt, current list size of UEs with MDT enabled is 1
...    deallocated with mdt, current list size of UEs with MDT enabled is 0

@{internal_count_prints_2_UEs_attach_detach_and_1_UE}
...    allocated with mdt, current list size of UEs with MDT enabled is 1
...    allocated with mdt, current list size of UEs with MDT enabled is 2
...    deallocated with mdt, current list size of UEs with MDT enabled is 1
...    deallocated with mdt, current list size of UEs with MDT enabled is 0
...    allocated with mdt, current list size of UEs with MDT enabled is 1
...    deallocated with mdt, current list size of UEs with MDT enabled is 0

@{internal_count_prints_2_UEs_attach_1_UE_detach_attach}
...    allocated with mdt, current list size of UEs with MDT enabled is 1
...    allocated with mdt, current list size of UEs with MDT enabled is 1
...    allocated with mdt, current list size of UEs with MDT enabled is 2
...    allocated with mdt, current list size of UEs with MDT enabled is 2
...    deallocated with mdt, current list size of UEs with MDT enabled is 1
...    allocated with mdt, current list size of UEs with MDT enabled is 2
...    allocated with mdt, current list size of UEs with MDT enabled is 2
...    allocated with mdt, current list size of UEs with MDT enabled is 1
...    deallocated with mdt, current list size of UEs with MDT enabled is 0
