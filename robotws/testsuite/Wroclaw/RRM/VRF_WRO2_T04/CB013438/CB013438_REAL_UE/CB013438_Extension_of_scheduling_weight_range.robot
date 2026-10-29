*** Settings ***
Documentation
...   author: Mateusz Bury
...   contact: mateusz.bury@nokia.com

Resource    ./resources/keywords_13438.robot


*** Keywords ***
CB013438-A-A1-A3_Online_modification_of_scheduling_weight_with_extended_range_and_parameter_avgDataRateReinitProhibitTimer
    Set Attenuation  90dB  ${ATTENUATOR['AHFII_1']['ports']}  confirm=${TRUE}
    Set Attenuation  90dB  ${ATTENUATOR['AHLOB_1']['ports']}  confirm=${TRUE}
    block_nr_cell   cell_id=400

    Show Text on Console
    ...   Use schedulWeight for given 5QIs 6,7,9 with values 40,20,10
    Require UEs

    Show Text on Console   Attach 2 of 3 UEs with given 5QIs
    Attach UEs To Preferred Cell  UE_1  UE_3
    Start Data Transfer In Given Direction      UE_1  UE_3   direction=DLUL  duration=600s
    Verify Average Tput in Next Few Seconds     UE_1  UE_3

    Show Text on Console
    ...   Reconfigure schedulWeight for given 5QIs 6,7,9 with values 100,500,200
    bts_reconfiguration     100    500    200

    Show Text on Console   Attach 3rd UE with new schedulWeight, first 2 UEs have old values
    Update Schedulweight for UEs   UE_4=${100}
    Attach UEs To Preferred Cell   UE_4
    Start Data Transfer In Given Direction  UE_4   direction=DLUL  duration=300s
    Verify Average Tput in Next Few Seconds     @{ue_list}

    Show Text on Console   Detach all UEs and attach again all with new schedulWeight values
    Detach UEs and stop data transfer
    Update Schedulweight for UEs   UE_1=${500}  UE_3=${200}  UE_4=${100}
    Attach UEs To Preferred Cell  @{ue_list}
    Start Data Transfer In Given Direction      @{ue_list}   direction=DLUL  duration=600s
    Verify Average Tput in Next Few Seconds     @{ue_list}

    Show Text on Console   Set avgDataRateReinitProhibitTimer parameter to minimum value and verify tput
    Update Parameter
    ...     distname=${bts_prefix}/NRCELL-${serving_cell}
    ...     param=avgDataRateReinitProhibitTimer
    ...     value=1
    Verify Average Tput in Next Few Seconds     @{ue_list}   stabilisation_period=0s

    Show Text on Console   Set avgDataRateReinitProhibitTimer parameter to maximum value and verify tput
    Update Parameter
    ...     distname=${bts_prefix}/NRCELL-${serving_cell}
    ...     param=avgDataRateReinitProhibitTimer
    ...     value=1000
    Verify Average Tput in Next Few Seconds     @{ue_list}   stabilisation_period=0s

    [Teardown]   Run keywords
    ...          Detach UEs and stop data transfer
    ...   AND    Set Attenuation  0dB  ${ATTENUATOR['SECTOR_${sector_no}']['ports']}  confirm=${TRUE}
    ...   AND    bts_reconfiguration
    ...   AND    unblock_nr_cell   cell_id=400
    ...   AND    Update Parameter
    ...              distname=${bts_prefix}/NRCELL-${serving_cell}
    ...              param=avgDataRateReinitProhibitTimer
    ...              value=10
