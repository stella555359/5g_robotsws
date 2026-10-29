*** Settings ***
Documentation
...            author:       Marcin Duplaga, marcin.duplaga@nokia.com
...                          Paulina Karpf Matoga, paulina.karpf_matoga@nokia.com
...            maintainer:   Marcin Duplaga, marcin.duplaga@nokia.com
...                          Paulina Karpf Matoga, paulina.karpf_matoga@nokia.com

*** Variables ***
@{tshark_options}    -o    ntrstr.defragment:TRUE    -o    ntrstr.port:49148

${CB012207_UE_CAPABILITY}    SEPARATOR=
...    23800000020008000001B004804200200010000001400420880841D0000000000608041046D08004000000DE00000000000004E800020000
...    0000020023B4000004008010
${CB012207_UE_CAPABILITY_WITH_LOCATION}    SEPARATOR=
...    23A00000020008000001B004804200200010000001400420880841D0000000000608041046D08004000000DE00000000000004E800020000
...    0000020023B400000400801020528000200100
${CB012207_UE_CAPABILITY_UNSUPPORTED_BAND}    SEPARATOR=
...    03800000020008000001A00080020620001000000101083A0600000200100000037800000000000013A000080000000008008ED0000010020040

&{ue_mapping_SA}
...    first_ue_with_location=${2}
...    second_ue_without_location=${3}

&{periodic_MDT_cellTrace_with_location}
...    trace_name=nr-rrc.measurementReport_element
...    measResults.*measId=3    MeasResultServMO.*physCellId=50
...    measResultServingCell.*rsrp=30    measResultServingCell.*rsrq=30    measResultServingCell.*sinr=30
...    ResultsPerSSB_Index.*rsrp=50    ResultsPerSSB_Index.*rsrq=50    ResultsPerSSB_Index.*sinr=50
...    locationInfo_r16.*commonLocationInfo.*gnss_TOD_msec_r16=.*

@{internal_count_prints_1_UE_attach_detach}
...    allocated with mdt, current list size of UEs with MDT enabled is 1
...    allocated with mdt, current list size of UEs with MDT enabled is 1
...    deallocated with mdt, current list size of UEs with MDT enabled is 0

&{ecidMeasRecord}
...      record_name=ueMeasRecord
...      carrierFreq$=2077723    triggerType=6    purpose=8
...      measResultServing.*pci=50    measResultServing.*servCellId=0    measResultServing.*pcell=1
...      measResultServing.*ssbCellResult.*rsrp=40    measResultServing.*ssbCellResult.*rsrq=50

&{ecidMeasCellTrace}
...    trace_name=nr-rrc.measurementReport_element
...    measResults.*measId=3    MeasResultServMO.*servCellId=0    MeasResultServMO.*physCellId=50
...    measResultServingCell.*rsrp=40    measResultServingCell.*rsrq=50

&{ecidMeasurementInitiationRequest}
...    trace_name=nrppa.E_CIDMeasurementInitiationRequest_element
...    nrppa.E_CIDMeasurementInitiationRequest.*nrppa.ReportCharacteristics=0
...    nrppa.E_CIDMeasurementInitiationRequest.*MeasurementQuantities.*Item 0.*measurementQuantitiesValue=6
...    nrppa.E_CIDMeasurementInitiationRequest.*MeasurementQuantities.*Item 1.*measurementQuantitiesValue=7

&{ecidMeasurementInitiationResponse}
...    trace_name=nrppa.E_CIDMeasurementInitiationResponse_element
...    nrppa.E_CIDMeasurementInitiationResponse.*E_CID_MeasurementResult.*servingCell_ID.*pLMN_Identity=13:41:98
...    nrppa.E_CIDMeasurementInitiationResponse.*servingCellTAC=200
...    nrppa.E_CIDMeasurementInitiationResponse.*measuredResults=2
...    nrppa.E_CIDMeasurementInitiationResponse.*measuredResults_tree.*Item 0.*nR_PCI=50
...    nrppa.E_CIDMeasurementInitiationResponse.*measuredResults_tree.*Item 0.*nR_ARFCN=2077819
...    nrppa.E_CIDMeasurementInitiationResponse.*measuredResults_tree.*Item 0.*valueSS_RSRP_Cell=40
...    nrppa.E_CIDMeasurementInitiationResponse.*measuredResults_tree.*Item 0.*sSB_Index=0
...    nrppa.E_CIDMeasurementInitiationResponse.*measuredResults_tree.*Item 1.*nR_PCI=50
...    nrppa.E_CIDMeasurementInitiationResponse.*measuredResults_tree.*Item 1.*nR_ARFCN=2077819
...    nrppa.E_CIDMeasurementInitiationResponse.*measuredResults_tree.*Item 1.*valueSS_RSRQ_Cell=50
...    nrppa.E_CIDMeasurementInitiationResponse.*measuredResults_tree.*Item 1.*sSB_Index=0

&{ecidMeasurementInitiationFailure}
...    trace_name=nrppa.E_CIDMeasurementInitiationFailure_element
...    nrppa.E_CIDMeasurementInitiationFailure.*Cause.*radioNetwork=1
