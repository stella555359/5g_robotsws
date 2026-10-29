*** Settings ***

Documentation    :copyright: Nokia

*** Variables ***
${dlRbPdcpThroughputRecord_VOL_UE_TPUT_TOT}    M55350C07001
${dlRbPdcpThroughputRecord_TIME_UE_TPUT}       M55350C08001
${ulRbRlcThroughputRecord_VOL_UE_TPUT_TOT}     M55349C03001
${ulRbRlcThroughputRecord_TIME_UE_TPUT}        M55349C04001

@{tshark_options}       -o    ntrstr.defragment:TRUE    -o    ntrstr.port:49148

&{ulRbPdcpMeasRecord_EM0}
...    record_name=ulRbPdcpMeasRecord
...    endMarker=0
...    drb_Id=4
...    dataCollectionDuration=\\d{1,}
...    sumOfPdcpSduRxBytes=\\d{1,}
...    sumOfPdcpSduRxBytesDiscarded=\\d{1,}

&{ulRbPdcpMeasRecord_EM1}
...    record_name=ulRbPdcpMeasRecord
...    endMarker=1
...    drb_Id=4
...    dataCollectionDuration=\\d{1,}
...    sumOfPdcpSduRxBytes=\\d{1,}
...    sumOfPdcpSduRxBytesDiscarded=\\d{1,}

&{dlRbPdcpMeasRecord_EM0}
...    record_name=dlRbPdcpMeasRecord
...    endMarker=0
...    drb_Id=4
...    dataCollectionDuration=\\d{1,}
...    sumOfPdcpSduTxBytes=\\d{1,}
...    sumOfPdcpSduTxBytesDiscarded=\\d{1,}

&{dlRbPdcpMeasRecord_EM1}
...    record_name=dlRbPdcpMeasRecord
...    endMarker=1
...    drb_Id=4
...    dataCollectionDuration=\\d{1,}
...    sumOfPdcpSduTxBytes=\\d{1,}
...    sumOfPdcpSduTxBytesDiscarded=\\d{1,}

&{dlRbPdcpThroughputRecord_EM0}
...    record_name=dlRbPdcpThroughputRecord
...    endMarker=0
...    drb_Id=4
...    dataCollectionDuration=\\d{1,}
...    timeOfUeDataBurstTx=\\d{1,}
...    sumOfPdcpSduTxDataBurstBytes=\\d{1,}

&{dlRbPdcpThroughputRecord_EM1}
...    record_name=dlRbPdcpThroughputRecord
...    endMarker=1
...    drb_Id=4
...    dataCollectionDuration=\\d{1,}
...    timeOfUeDataBurstTx=\\d{1,}
...    sumOfPdcpSduTxDataBurstBytes=\\d{1,}

&{ulRbRlcThroughputRecord_EM0}
...    record_name=ulRbRlcThroughputRecord
...    endMarker=0
...    drb_Id=4
...    dataCollectionDuration=\\d{1,}
...    timeOfUeDataBurstRx=\\d{1,}
...    sumOfRlcSduRxDataBurstBytes=\\d{1,}

&{ulRbRlcThroughputRecord_EM1}
...    record_name=ulRbRlcThroughputRecord
...    endMarker=1
...    drb_Id=4
...    dataCollectionDuration=\\d{1,}
...    timeOfUeDataBurstRx=\\d{1,}
...    sumOfRlcSduRxDataBurstBytes=\\d{1,}
