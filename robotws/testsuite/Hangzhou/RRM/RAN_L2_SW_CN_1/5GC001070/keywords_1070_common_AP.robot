*** Settings ***

*** Variables ***
${cbim_file_gNB}    /ffs/run/config/node_0xe000/config/cbim_repo.json
${pbim_file_gNB}    /ffs/run/config/node_0xe000/config/pbim_repo.json
${command_clear_logs_uecp}=    sudo journalctl --vacuum-size=2M
@{pattern_List}    <subcarrierSpacingSSB>.*</subcarrierSpacingSSB>    <dlUlTransmissionPeriodicity>.*</dlUlTransmissionPeriodicity>
...                <prachPreambleFormat>.*</prachPreambleFormat>    <prachConfigIndex>.*</prachConfigIndex>
...                <ssBurstSetPeriod>.*</ssBurstSetPeriod>    <numberOfTransmittedSsBlocks>.*</numberOfTransmittedSsBlocks>
...                <subcarrierSpacingSSB>.*</subcarrierSpacingSSB>    <tddFrameStructureType>.*</tddFrameStructureType>

@{new_values_4004}      <subcarrierSpacingSSB>30</subcarrierSpacingSSB>    <dlUlTransmissionPeriodicity>5</dlUlTransmissionPeriodicity>
...                     <prachPreambleFormat>6</prachPreambleFormat>    <prachConfigIndex>148</prachConfigIndex>
...                     <ssBurstSetPeriod>20</ssBurstSetPeriod>    <numberOfTransmittedSsBlocks>6</numberOfTransmittedSsBlocks>
...                     <subcarrierSpacingSSB>30</subcarrierSpacingSSB>    <tddFrameStructureType>1</tddFrameStructureType>

@{new_values_4008}      <subcarrierSpacingSSB>30</subcarrierSpacingSSB>    <dlUlTransmissionPeriodicity>5</dlUlTransmissionPeriodicity>
...                     <prachPreambleFormat>6</prachPreambleFormat>    <prachConfigIndex>160</prachConfigIndex>
...                     <ssBurstSetPeriod>20</ssBurstSetPeriod>    <numberOfTransmittedSsBlocks>4</numberOfTransmittedSsBlocks>
...                     <subcarrierSpacingSSB>30</subcarrierSpacingSSB>    <tddFrameStructureType>1</tddFrameStructureType>

@{new_values_4011}      <subcarrierSpacingSSB>30</subcarrierSpacingSSB>    <dlUlTransmissionPeriodicity>5</dlUlTransmissionPeriodicity>
...                     <prachPreambleFormat>6</prachPreambleFormat>    <prachConfigIndex>149</prachConfigIndex>
...                     <ssBurstSetPeriod>20</ssBurstSetPeriod>    <numberOfTransmittedSsBlocks>1</numberOfTransmittedSsBlocks>
...                     <subcarrierSpacingSSB>30</subcarrierSpacingSSB>    <tddFrameStructureType>1</tddFrameStructureType>

@{new_values_4012}      <subcarrierSpacingSSB>30</subcarrierSpacingSSB>    <dlUlTransmissionPeriodicity>5</dlUlTransmissionPeriodicity>
...                     <prachPreambleFormat>6</prachPreambleFormat>    <prachConfigIndex>151</prachConfigIndex>
...                     <ssBurstSetPeriod>20</ssBurstSetPeriod>    <numberOfTransmittedSsBlocks>2</numberOfTransmittedSsBlocks>
...                     <subcarrierSpacingSSB>30</subcarrierSpacingSSB>    <tddFrameStructureType>1</tddFrameStructureType>

@{new_values_4013}      <subcarrierSpacingSSB>30</subcarrierSpacingSSB>    <dlUlTransmissionPeriodicity>5</dlUlTransmissionPeriodicity>
...                     <prachPreambleFormat>6</prachPreambleFormat>    <prachConfigIndex>152</prachConfigIndex>
...                     <ssBurstSetPeriod>20</ssBurstSetPeriod>    <numberOfTransmittedSsBlocks>4</numberOfTransmittedSsBlocks>
...                     <subcarrierSpacingSSB>30</subcarrierSpacingSSB>    <tddFrameStructureType>1</tddFrameStructureType>


@{new_values_4019}      <subcarrierSpacingSSB>30</subcarrierSpacingSSB>    <dlUlTransmissionPeriodicity>5</dlUlTransmissionPeriodicity>
...                     <prachPreambleFormat>6</prachPreambleFormat>    <prachConfigIndex>94</prachConfigIndex>
...                     <ssBurstSetPeriod>20</ssBurstSetPeriod>    <numberOfTransmittedSsBlocks>6</numberOfTransmittedSsBlocks>
...                     <subcarrierSpacingSSB>30</subcarrierSpacingSSB>    <tddFrameStructureType>1</tddFrameStructureType>

@{new_values_4017}      <subcarrierSpacingSSB>30</subcarrierSpacingSSB>    <dlUlTransmissionPeriodicity>5</dlUlTransmissionPeriodicity>
...                     <prachPreambleFormat>6</prachPreambleFormat>    <prachConfigIndex>162</prachConfigIndex>
...                     <ssBurstSetPeriod>20</ssBurstSetPeriod>    <numberOfTransmittedSsBlocks>2</numberOfTransmittedSsBlocks>
...                     <subcarrierSpacingSSB>30</subcarrierSpacingSSB>    <tddFrameStructureType>1</tddFrameStructureType>

@{new_values_4018}      <subcarrierSpacingSSB>30</subcarrierSpacingSSB>    <dlUlTransmissionPeriodicity>5</dlUlTransmissionPeriodicity>
...                     <prachPreambleFormat>6</prachPreambleFormat>    <prachConfigIndex>93</prachConfigIndex>
...                     <ssBurstSetPeriod>20</ssBurstSetPeriod>    <numberOfTransmittedSsBlocks>4</numberOfTransmittedSsBlocks>
...                     <subcarrierSpacingSSB>30</subcarrierSpacingSSB>    <tddFrameStructureType>1</tddFrameStructureType>
@{new_values_4014}      <subcarrierSpacingSSB>30</subcarrierSpacingSSB>    <dlUlTransmissionPeriodicity>5</dlUlTransmissionPeriodicity>
...                     <prachPreambleFormat>6</prachPreambleFormat>    <prachConfigIndex>157</prachConfigIndex>
...                     <ssBurstSetPeriod>20</ssBurstSetPeriod>    <numberOfTransmittedSsBlocks>6</numberOfTransmittedSsBlocks>
...                     <subcarrierSpacingSSB>30</subcarrierSpacingSSB>    <tddFrameStructureType>1</tddFrameStructureType>
@{new_values_4016}      <subcarrierSpacingSSB>30</subcarrierSpacingSSB>    <dlUlTransmissionPeriodicity>5</dlUlTransmissionPeriodicity>
...                     <prachPreambleFormat>6</prachPreambleFormat>    <prachConfigIndex>161</prachConfigIndex>
...                     <ssBurstSetPeriod>20</ssBurstSetPeriod>    <numberOfTransmittedSsBlocks>1</numberOfTransmittedSsBlocks>
...                     <subcarrierSpacingSSB>30</subcarrierSpacingSSB>    <tddFrameStructureType>1</tddFrameStructureType>

@{new_values_4021}      <subcarrierSpacingSSB>30</subcarrierSpacingSSB>    <dlUlTransmissionPeriodicity>5</dlUlTransmissionPeriodicity>
...                     <prachPreambleFormat>6</prachPreambleFormat>    <prachConfigIndex>98</prachConfigIndex>
...                     <ssBurstSetPeriod>20</ssBurstSetPeriod>    <numberOfTransmittedSsBlocks>6</numberOfTransmittedSsBlocks>
...                     <subcarrierSpacingSSB>30</subcarrierSpacingSSB>    <tddFrameStructureType>1</tddFrameStructureType>

@{new_values_4023}      <subcarrierSpacingSSB>30</subcarrierSpacingSSB>    <dlUlTransmissionPeriodicity>5</dlUlTransmissionPeriodicity>
...                     <prachPreambleFormat>6</prachPreambleFormat>    <prachConfigIndex>94</prachConfigIndex>
...                     <ssBurstSetPeriod>20</ssBurstSetPeriod>    <numberOfTransmittedSsBlocks>2</numberOfTransmittedSsBlocks>
...                     <subcarrierSpacingSSB>30</subcarrierSpacingSSB>    <tddFrameStructureType>1</tddFrameStructureType>


${modify_APxml_4016}=    sed -i "s/rSpacingSSB>.*<\/subcarrierSpacingSSB>/rSpacingSSB>30<\/subcarrierSpacingSSB>/g" AirPhoneConfig*.xml;
...    sed -i "s/Periodicity>.*<\/dlUlTransmissionPeriodicity>/Periodicity>5<\/dlUlTransmissionPeriodicity>/g" AirPhoneConfig*.xml;
...    sed -i "s/<prachPreambleFormat>.*<\/prachPreambleFormat>/<prachPreambleFormat>6<\/prachPreambleFormat>/g" AirPhoneConfig*.xml;
...    sed -i "s/<prachConfigIndex>.*<\/prachConfigIndex>/<prachConfigIndex>161<\/prachConfigIndex>/g" AirPhoneConfig*.xml;
...    sed -i "s/<ssBurstSetPeriod>.*<\/ssBurstSetPeriod>/<ssBurstSetPeriod>20<\/ssBurstSetPeriod>/g" AirPhoneConfig*.xml;
...    sed -i "s/edSsBlocks>.*<\/numberOfTransmittedSsBlocks>/edSsBlocks>1<\/numberOfTransmittedSsBlocks>/g" AirPhoneConfig*.xml;
...    sed -i "s/<subcarrierSpacingSSB>.*<\/subcarrierSpacingSSB>/<subcarrierSpacingSSB>30<\/subcarrierSpacingSSB>/g" AirPhoneConfig*.xml
...    sed -i "s/<tddFrameStructureType>.*<\/tddFrameStructureType>/<tddFrameStructureType>1<\/tddFrameStructureType>/g" AirPhoneConfig*.xml

@{slottype_list_4004}    Slot:0,Type:DL:SLOT_TYPE_SSBURST
...    Slot:1,Type:DL:SLOT_TYPE_SSBURST
...    Slot:2,Type:DL:SLOT_TYPE_SSBURST
...    Slot:3,Type:DL:SLOT_TYPE_B2
...    Slot:4,Type:DL:SLOT_TYPE_C5
...    Slot:5,Type:DL:SLOT_TYPE_B0
...    Slot:6,Type:DL:SLOT_TYPE_B4
...    Slot:7,Type:DL:SLOT_TYPE_B2
...    Slot:8,Type:DL:SLOT_TYPE_C5
...    Slot:9,Type:DL:SLOT_TYPE_C5
...    Slot:10,Type:DL:SLOT_TYPE_B0
...    Slot:11,Type:DL:SLOT_TYPE_41
...    Slot:12,Type:DL:SLOT_TYPE_41
...    Slot:13,Type:DL:SLOT_TYPE_B2
...    Slot:14,Type:DL:SLOT_TYPE_C5
...    Slot:15,Type:DL:SLOT_TYPE_B0
...    Slot:16,Type:DL:SLOT_TYPE_B4
...    Slot:17,Type:DL:SLOT_TYPE_B2
...    Slot:18,Type:DL: SLOT_TYPE_C5
...    Slot:19,Type:DL: SLOT_TYPE_C5
...    Slot:0,Type:DL: SLOT_TYPE_B0
...    Slot:1,Type:DL: SLOT_TYPE_B0
...    Slot:2,Type:DL:SLOT_TYPE_B4
...    Slot:3,Type:DL:SLOT_TYPE_B2
...    Slot:4,Type:DL:SLOT_TYPE_C5
...    Slot:5,Type:DL:SLOT_TYPE_B0
...    Slot:6,Type:DL:SLOT_TYPE_B4
...    Slot:7,Type:DL:SLOT_TYPE_B2
...    Slot:8,Type:DL:SLOT_TYPE_C5
...    Slot:9,Type:DL:SLOT_TYPE_C5
...    Slot:10,Type:DL:SLOT_TYPE_B0
...    Slot:11,Type:DL:SLOT_TYPE_41
...    Slot:12,Type:DL:SLOT_TYPE_41
...    Slot:13,Type:DL:SLOT_TYPE_B2
...    Slot:14,Type:DL:SLOT_TYPE_C5
...    Slot:15,Type:DL:SLOT_TYPE_B0
...    Slot:16,Type:DL:SLOT_TYPE_B4
...    Slot:17,Type:DL:SLOT_TYPE_B2
...    Slot:18,Type:DL:SLOT_TYPE_C5
...    Slot:19,Type:DL:SLOT_TYPE_PRACH

@{slottype_list_4008}    Slot:0,Type:DL:SLOT_TYPE_SSBURST
...    Slot:1,Type:DL:SLOT_TYPE_SSBURST
...    Slot:2,Type:DL:SLOT_TYPE_B4
...    Slot:3,Type:DL:SLOT_TYPE_B2
...    Slot:4,Type:DL:SLOT_TYPE_C5
...    Slot:5,Type:DL:SLOT_TYPE_B0
...    Slot:6,Type:DL:SLOT_TYPE_B4
...    Slot:7,Type:DL:SLOT_TYPE_B2
...    Slot:8,Type:DL:SLOT_TYPE_C5
...    Slot:9,Type:DL:SLOT_TYPE_C5
...    Slot:10,Type:DL:SLOT_TYPE_B0
...    Slot:11,Type:DL:SLOT_TYPE_B0
...    Slot:12,Type:DL:SLOT_TYPE_41
...    Slot:13,Type:DL:SLOT_TYPE_41
...    Slot:14,Type:DL:SLOT_TYPE_C5
...    Slot:15,Type:DL:SLOT_TYPE_B0
...    Slot:16,Type:DL:SLOT_TYPE_B4
...    Slot:17,Type:DL:SLOT_TYPE_B2
...    Slot:18,Type:DL: SLOT_TYPE_C5
...    Slot:19,Type:DL: SLOT_TYPE_PRACH
...    Slot:0,Type:DL: SLOT_TYPE_B0
...    Slot:1,Type:DL: SLOT_TYPE_B0
...    Slot:2,Type:DL:SLOT_TYPE_B4
...    Slot:3,Type:DL:SLOT_TYPE_B2
...    Slot:4,Type:DL:SLOT_TYPE_C5
...    Slot:5,Type:DL:SLOT_TYPE_B0
...    Slot:6,Type:DL:SLOT_TYPE_B4
...    Slot:7,Type:DL:SLOT_TYPE_B2
...    Slot:8,Type:DL:SLOT_TYPE_C5
...    Slot:9,Type:DL:SLOT_TYPE_C5
...    Slot:10,Type:DL:SLOT_TYPE_B0
...    Slot:11,Type:DL:SLOT_TYPE_B0
...    Slot:12,Type:DL:SLOT_TYPE_41
...    Slot:13,Type:DL:SLOT_TYPE_41
...    Slot:14,Type:DL:SLOT_TYPE_C5
...    Slot:15,Type:DL:SLOT_TYPE_B0
...    Slot:16,Type:DL:SLOT_TYPE_B4
...    Slot:17,Type:DL:SLOT_TYPE_B2
...    Slot:18,Type:DL:SLOT_TYPE_C5
...    Slot:19,Type:DL:SLOT_TYPE_PRACH

@{slottype_list_4011}    Slot:0,Type:DL:SLOT_TYPE_SSBURST
...    Slot:1,Type:DL:SLOT_TYPE_41
...    Slot:2,Type:DL:SLOT_TYPE_B4
...    Slot:3,Type:DL:SLOT_TYPE_B2
...    Slot:4,Type:DL:SLOT_TYPE_C5
...    Slot:5,Type:DL:SLOT_TYPE_B0
...    Slot:6,Type:DL:SLOT_TYPE_B4
...    Slot:7,Type:DL:SLOT_TYPE_B2
...    Slot:8,Type:DL:SLOT_TYPE_C5
...    Slot:9,Type:DL:SLOT_TYPE_C5
...    Slot:10,Type:DL:SLOT_TYPE_B0
...    Slot:11,Type:DL:SLOT_TYPE_B0
...    Slot:12,Type:DL:SLOT_TYPE_B4
...    Slot:13,Type:DL:SLOT_TYPE_B2
...    Slot:14,Type:DL:SLOT_TYPE_C5
...    Slot:15,Type:DL:SLOT_TYPE_B0
...    Slot:16,Type:DL:SLOT_TYPE_B4
...    Slot:17,Type:DL:SLOT_TYPE_B2
...    Slot:18,Type:DL:SLOT_TYPE_C5
...    Slot:19,Type:DL:SLOT_TYPE_C5
...    Slot:0,Type:DL:SLOT_TYPE_41
...    Slot:1,Type:DL:SLOT_TYPE_41
...    Slot:2,Type:DL:SLOT_TYPE_B4
...    Slot:3,Type:DL:SLOT_TYPE_B2
...    Slot:4,Type:DL:SLOT_TYPE_C5
...    Slot:5,Type:DL:SLOT_TYPE_B0
...    Slot:6,Type:DL:SLOT_TYPE_B4
...    Slot:7,Type:DL:SLOT_TYPE_B2
...    Slot:8,Type:DL:SLOT_TYPE_C5
...    Slot:9,Type:DL:SLOT_TYPE_C5
...    Slot:10,Type:DL:SLOT_TYPE_B0
...    Slot:11,Type:DL:SLOT_TYPE_B0
...    Slot:12,Type:DL:SLOT_TYPE_B4
...    Slot:13,Type:DL:SLOT_TYPE_B2
...    Slot:14,Type:DL:SLOT_TYPE_C5
...    Slot:15,Type:DL:SLOT_TYPE_B0
...    Slot:16,Type:DL:SLOT_TYPE_B4
...    Slot:17,Type:DL:SLOT_TYPE_B2
...    Slot:18,Type:DL:SLOT_TYPE_C5
...    Slot:19,Type:DL:SLOT_TYPE_PRACH

@{slottype_list_4016}    Slot:0,Type:DL:SLOT_TYPE_SSBURST
...    Slot:1,Type:DL:SLOT_TYPE_41
...    Slot:2,Type:DL:SLOT_TYPE_B4
...    Slot:3,Type:DL:SLOT_TYPE_B2
...    Slot:4,Type:DL:SLOT_TYPE_C5
...    Slot:5,Type:DL:SLOT_TYPE_B0
...    Slot:6,Type:DL:SLOT_TYPE_B4
...    Slot:7,Type:DL:SLOT_TYPE_B2
...    Slot:8,Type:DL:SLOT_TYPE_C5
...    Slot:9,Type:DL:SLOT_TYPE_C5
...    Slot:10,Type:DL:SLOT_TYPE_B0
...    Slot:11,Type:DL:SLOT_TYPE_B0
...    Slot:12,Type:DL:SLOT_TYPE_B4
...    Slot:13,Type:DL:SLOT_TYPE_B2
...    Slot:14,Type:DL:SLOT_TYPE_C5
...    Slot:15,Type:DL:SLOT_TYPE_B0
...    Slot:16,Type:DL:SLOT_TYPE_B0
...    Slot:17,Type:DL:SLOT_TYPE_B2
...    Slot:18,Type:DL:SLOT_TYPE_PRACH
...    Slot:19,Type:DL:SLOT_TYPE_PRACH
...    Slot:0,Type:DL:SLOT_TYPE_41
...    Slot:1,Type: DL:SLOT_TYPE_41
...    Slot:2,Type:DL:SLOT_TYPE_B4
...    Slot:3,Type:DL:SLOT_TYPE_B2
...    Slot:4,Type:DL:SLOT_TYPE_C5
...    Slot:5,Type:DL:SLOT_TYPE_B0
...    Slot:6,Type:DL:SLOT_TYPE_B4
...    Slot:7,Type:DL:SLOT_TYPE_B2
...    Slot:8,Type:DL:SLOT_TYPE_C5
...    Slot:9,Type:DL:SLOT_TYPE_C5
...    Slot:10,Type:DL:SLOT_TYPE_B0
...    Slot:11,Type:DL:SLOT_TYPE_B0
...    Slot:12,Type:DL:SLOT_TYPE_B4
...    Slot:13,Type:DL:SLOT_TYPE_B2
...    Slot:14,Type:DL:SLOT_TYPE_C5
...    Slot:15,Type:DL:SLOT_TYPE_B0
...    Slot:16,Type:DL:SLOT_TYPE_B0
...    Slot:17,Type:DL:SLOT_TYPE_B2
...    Slot:18,Type:DL:SLOT_TYPE_PRACH
...    Slot:19,Type:DL:SLOT_TYPE_PRACH

@{slottype_list_4017}    Slot:0,Type:DL:SLOT_TYPE_SSBURST
...    Slot:1,Type:DL:SLOT_TYPE_B0
...    Slot:2,Type:DL:SLOT_TYPE_B4
...    Slot:3,Type:DL:SLOT_TYPE_B2
...    Slot:4,Type:DL:SLOT_TYPE_C5
...    Slot:5,Type:DL:SLOT_TYPE_B0
...    Slot:6,Type:DL:SLOT_TYPE_B4
...    Slot:7,Type:DL:SLOT_TYPE_B2
...    Slot:8,Type:DL:SLOT_TYPE_C5
...    Slot:9,Type:DL:SLOT_TYPE_PRACH
...    Slot:10,Type:DL:SLOT_TYPE_B0
...    Slot:11,Type:DL:SLOT_TYPE_B0
...    Slot:12,Type:DL:SLOT_TYPE_41
...    Slot:13,Type:DL:SLOT_TYPE_41
...    Slot:14,Type:DL:SLOT_TYPE_C5
...    Slot:15,Type:DL:SLOT_TYPE_B0
...    Slot:16,Type:DL:SLOT_TYPE_B4
...    Slot:17,Type:DL:SLOT_TYPE_B2
...    Slot:18,Type:DL:SLOT_TYPE_C5
...    Slot:19,Type:DL:SLOT_TYPE_PRACH
...    Slot:0,Type:DL:SLOT_TYPE_B0
...    Slot:1,Type:DL:SLOT_TYPE_B0
...    Slot:2,Type:DL:SLOT_TYPE_B4
...    Slot:3,Type:DL:SLOT_TYPE_B2
...    Slot:4,Type:DL:SLOT_TYPE_C5
...    Slot:5,Type:DL:SLOT_TYPE_B0
...    Slot:6,Type:DL:SLOT_TYPE_B4
...    Slot:7,Type:DL:SLOT_TYPE_B2
...    Slot:8,Type:DL:SLOT_TYPE_C5
...    Slot:9,Type:DL:SLOT_TYPE_PRACH
...    Slot:10,Type:DL:SLOT_TYPE_B0
...    Slot:11,Type:DL:SLOT_TYPE_B0
...    Slot:12,Type:DL:SLOT_TYPE_41
...    Slot:13,Type:DL:SLOT_TYPE_41
...    Slot:14,Type:DL:SLOT_TYPE_C5
...    Slot:15,Type:DL:SLOT_TYPE_B0
...    Slot:16,Type:DL:SLOT_TYPE_B4
...    Slot:17,Type:DL:SLOT_TYPE_B2
...    Slot:18,Type:DL:SLOT_TYPE_C5
...    Slot:19,Type:DL:SLOT_TYPE_PRACH



${modify_APxml_4014}=    sed -i "s/rSpacingSSB>.*<\/subcarrierSpacingSSB>/rSpacingSSB>30<\/subcarrierSpacingSSB>/g" AirPhoneConfig*.xml;
...    sed -i "s/Periodicity>.*<\/dlUlTransmissionPeriodicity>/Periodicity>5<\/dlUlTransmissionPeriodicity>/g" AirPhoneConfig*.xml;
...    sed -i "s/<prachPreambleFormat>.*<\/prachPreambleFormat>/<prachPreambleFormat>6<\/prachPreambleFormat>/g" AirPhoneConfig*.xml;
...    sed -i "s/<prachConfigIndex>.*<\/prachConfigIndex>/<prachConfigIndex>157<\/prachConfigIndex>/g" AirPhoneConfig*.xml;
...    sed -i "s/<ssBurstSetPeriod>.*<\/ssBurstSetPeriod>/<ssBurstSetPeriod>20<\/ssBurstSetPeriod>/g" AirPhoneConfig*.xml;
...    sed -i "s/edSsBlocks>.*<\/numberOfTransmittedSsBlocks>/edSsBlocks>6<\/numberOfTransmittedSsBlocks>/g" AirPhoneConfig*.xml;
...    sed -i "s/<subcarrierSpacingSSB>.*<\/subcarrierSpacingSSB>/<subcarrierSpacingSSB>30<\/subcarrierSpacingSSB>/g" AirPhoneConfig*.xml
...    sed -i "s/<tddFrameStructureType>.*<\/tddFrameStructureType>/<tddFrameStructureType>1<\/tddFrameStructureType>/g" AirPhoneConfig*.xml

@{slottype_list_4013}    Slot:0, Type:DL:SLOT_TYPE_SSBURST
...    Slot:1, Type:DL:SLOT_TYPE_SSBURST
...    Slot:2, Type:DL:SLOT_TYPE_B4
...    Slot:3, Type:DL:SLOT_TYPE_B2
...    Slot:4, Type:DL:SLOT_TYPE_C5
...    Slot:5, Type:DL:SLOT_TYPE_B0
...    Slot:6, Type:DL:SLOT_TYPE_B4
...    Slot:7, Type:DL:SLOT_TYPE_B2
...    Slot:8, Type:DL:SLOT_TYPE_C5
...    Slot:9, Type:DL:SLOT_TYPE_C5
...    Slot: 10, Type:DL:SLOT_TYPE_B0
...    Slot: 11, Type:DL:SLOT_TYPE_B0
...    Slot: 12, Type:DL:SLOT_TYPE_41
...    Slot: 13, Type:DL:SLOT_TYPE_41
...    Slot: 14, Type:DL:SLOT_TYPE_C5
...    Slot: 15, Type:DL:SLOT_TYPE_B0
...    Slot: 16, Type:DL:SLOT_TYPE_B4
...    Slot: 17, Type:DL:SLOT_TYPE_B2
...    Slot: 18, Type:DL:SLOT_TYPE_C5
...    Slot: 19, Type:DL:SLOT_TYPE_C5
...    Slot:0, Type:DL:SLOT_TYPE_B0
...    Slot:1, Type:DL:SLOT_TYPE_B0
...    Slot:2, Type:DL:SLOT_TYPE_B4
...    Slot:3, Type:DL:SLOT_TYPE_B2
...    Slot:4, Type:DL:SLOT_TYPE_C5
...    Slot:5, Type:DL:SLOT_TYPE_B0
...    Slot:6, Type:DL:SLOT_TYPE_B0
...    Slot:7, Type:DL:SLOT_TYPE_B2
...    Slot:8, Type:DL:SLOT_TYPE_PRACH
...    Slot:9, Type:DL:SLOT_TYPE_PRACH
...    Slot: 10, Type:DL:SLOT_TYPE_B0
...    Slot: 11, Type:DL:SLOT_TYPE_B0
...    Slot: 12, Type:DL:SLOT_TYPE_41
...    Slot: 13, Type:DL:SLOT_TYPE_41
...    Slot: 14, Type:DL:SLOT_TYPE_C5
...    Slot: 15, Type:DL:SLOT_TYPE_B0
...    Slot: 16, Type:DL:SLOT_TYPE_B0
...    Slot: 17, Type:DL:SLOT_TYPE_B2
...    Slot: 18, Type:DL:SLOT_TYPE_PRACH
...    Slot: 19, Type:DL:SLOT_TYPE_PRACH


@{slottype_list_4014}    Slot:0, Type:DL:SLOT_TYPE_SSBURST
...    Slot:1, Type:DL:SLOT_TYPE_SSBURST
...    Slot:2, Type:DL:SLOT_TYPE_SSBURST
...    Slot:3, Type:DL:SLOT_TYPE_B2
...    Slot:4, Type:DL:SLOT_TYPE_C5
...    Slot:5, Type:DL:SLOT_TYPE_B0
...    Slot:6, Type:DL:SLOT_TYPE_B4
...    Slot:7, Type:DL:SLOT_TYPE_B2
...    Slot:8, Type:DL:SLOT_TYPE_C5
...    Slot:9, Type:DL:SLOT_TYPE_PRACH
...    Slot: 10, Type:DL:SLOT_TYPE_B0
...    Slot: 11, Type:DL:SLOT_TYPE_41
...    Slot: 12, Type:DL:SLOT_TYPE_41
...    Slot: 13, Type:DL:SLOT_TYPE_B2
...    Slot: 14, Type:DL:SLOT_TYPE_C5
...    Slot: 15, Type:DL:SLOT_TYPE_B0
...    Slot: 16, Type:DL:SLOT_TYPE_B4
...    Slot: 17, Type:DL:SLOT_TYPE_B2
...    Slot: 18, Type:DL:SLOT_TYPE_C5
...    Slot: 19, Type:DL:SLOT_TYPE_C5
...    Slot:0, Type:DL:SLOT_TYPE_B0
...    Slot:1, Type:DL:SLOT_TYPE_B0
...    Slot:2, Type:DL:SLOT_TYPE_B4
...    Slot:3, Type:DL:SLOT_TYPE_B2
...    Slot:4, Type:DL:SLOT_TYPE_C5
...    Slot:5, Type:DL:SLOT_TYPE_B0
...    Slot:6, Type:DL:SLOT_TYPE_B4
...    Slot:7, Type:DL:SLOT_TYPE_B2
...    Slot:8, Type:DL:SLOT_TYPE_C5
...    Slot:9, Type:DL:SLOT_TYPE_PRACH
...    Slot: 10, Type:DL:SLOT_TYPE_B0
...    Slot: 11, Type:DL:SLOT_TYPE_41
...    Slot: 12, Type:DL:SLOT_TYPE_41
...    Slot: 13, Type:DL:SLOT_TYPE_B2
...    Slot: 14, Type:DL:SLOT_TYPE_C5
...    Slot: 15, Type:DL:SLOT_TYPE_B0
...    Slot: 16, Type:DL:SLOT_TYPE_B4
...    Slot: 17, Type:DL:SLOT_TYPE_B2
...    Slot: 18, Type:DL:SLOT_TYPE_C5
...    Slot: 19, Type:DL:SLOT_TYPE_C5


${modify_APxml_4018}=    sed -i "s/rSpacingSSB>.*<\/subcarrierSpacingSSB>/rSpacingSSB>30<\/subcarrierSpacingSSB>/g" AirPhoneConfig*.xml;
...    sed -i "s/Periodicity>.*<\/dlUlTransmissionPeriodicity>/Periodicity>5<\/dlUlTransmissionPeriodicity>/g" AirPhoneConfig*.xml;
...    sed -i "s/<prachPreambleFormat>.*<\/prachPreambleFormat>/<prachPreambleFormat>6<\/prachPreambleFormat>/g" AirPhoneConfig*.xml;
...    sed -i "s/<prachConfigIndex>.*<\/prachConfigIndex>/<prachConfigIndex>93<\/prachConfigIndex>/g" AirPhoneConfig*.xml;
...    sed -i "s/<ssBurstSetPeriod>.*<\/ssBurstSetPeriod>/<ssBurstSetPeriod>20<\/ssBurstSetPeriod>/g" AirPhoneConfig*.xml;
...    sed -i "s/edSsBlocks>.*<\/numberOfTransmittedSsBlocks>/edSsBlocks>4<\/numberOfTransmittedSsBlocks>/g" AirPhoneConfig*.xml;
...    sed -i "s/<subcarrierSpacingSSB>.*<\/subcarrierSpacingSSB>/<subcarrierSpacingSSB>30<\/subcarrierSpacingSSB>/g" AirPhoneConfig*.xml
...    sed -i "s/<tddFrameStructureType>.*<\/tddFrameStructureType>/<tddFrameStructureType>1<\/tddFrameStructureType>/g" AirPhoneConfig*.xml

@{slottype_list_4018}    Slot:0, Type:DL:SLOT_TYPE_SSBURST
...    Slot:1, Type:DL:SLOT_TYPE_SSBURST
...    Slot:2, Type:DL:SLOT_TYPE_B4
...    Slot:3, Type:DL:SLOT_TYPE_B2
...    Slot:4, Type:DL:SLOT_TYPE_C5
...    Slot:5, Type:DL:SLOT_TYPE_B0
...    Slot:6, Type:DL:SLOT_TYPE_B4
...    Slot:7, Type:DL:SLOT_TYPE_B2
...    Slot:8, Type:DL:SLOT_TYPE_C5
...    Slot:9, Type:DL:SLOT_TYPE_C5
...    Slot: 10, Type:DL:SLOT_TYPE_B0
...    Slot: 11, Type:DL:SLOT_TYPE_B0
...    Slot: 12, Type:DL:SLOT_TYPE_41
...    Slot: 13, Type:DL:SLOT_TYPE_41
...    Slot: 14, Type:DL:SLOT_TYPE_C5
...    Slot: 15, Type:DL:SLOT_TYPE_B0
...    Slot: 16, Type:DL:SLOT_TYPE_B4
...    Slot: 17, Type:DL:SLOT_TYPE_B2
...    Slot: 18, Type:DL:SLOT_TYPE_C5
...    Slot: 19, Type:DL:SLOT_TYPE_C5
...    Slot:0, Type:DL:SLOT_TYPE_B0
...    Slot:1, Type:DL:SLOT_TYPE_B0
...    Slot:2, Type:DL:SLOT_TYPE_B4
...    Slot:3, Type:DL:SLOT_TYPE_B2
...    Slot:4, Type:DL:SLOT_TYPE_C5
...    Slot:5, Type:DL:SLOT_TYPE_B0
...    Slot:6, Type:DL:SLOT_TYPE_B4
...    Slot:7, Type:DL:SLOT_TYPE_B2
...    Slot:8, Type:DL:SLOT_TYPE_C5
...    Slot:9, Type:DL:SLOT_TYPE_PRACH
...    Slot: 10, Type:DL:SLOT_TYPE_B0
...    Slot: 11, Type:DL:SLOT_TYPE_B0
...    Slot: 12, Type:DL:SLOT_TYPE_41
...    Slot: 13, Type:DL:SLOT_TYPE_41
...    Slot: 14, Type:DL:SLOT_TYPE_C5
...    Slot: 15, Type:DL:SLOT_TYPE_B0
...    Slot: 16, Type:DL:SLOT_TYPE_B4
...    Slot: 17, Type:DL:SLOT_TYPE_B2
...    Slot: 18, Type:DL:SLOT_TYPE_C5
...    Slot: 19, Type:DL:SLOT_TYPE_PRACH
...    Slot:0, Type:DL:SLOT_TYPE_SSBURST
...    Slot:1, Type:DL:SLOT_TYPE_SSBURST
...    Slot:2, Type:DL:SLOT_TYPE_B4
...    Slot:3, Type:DL:SLOT_TYPE_B2
...    Slot:4, Type:DL:SLOT_TYPE_C5
...    Slot:5, Type:DL:SLOT_TYPE_B0
...    Slot:6, Type:DL:SLOT_TYPE_B4
...    Slot:7, Type:DL:SLOT_TYPE_B2
...    Slot:8, Type:DL:SLOT_TYPE_C5
...    Slot:9, Type:DL:SLOT_TYPE_C5
...    Slot: 10, Type:DL:SLOT_TYPE_B0
...    Slot: 11, Type:DL:SLOT_TYPE_B0
...    Slot: 12, Type:DL:SLOT_TYPE_41
...    Slot: 13, Type:DL:SLOT_TYPE_41
...    Slot: 14, Type:DL:SLOT_TYPE_C5
...    Slot: 15, Type:DL:SLOT_TYPE_B0
...    Slot: 16, Type:DL:SLOT_TYPE_B4
...    Slot: 17, Type:DL:SLOT_TYPE_B2
...    Slot: 18, Type:DL:SLOT_TYPE_C5
...    Slot: 19, Type:DL:SLOT_TYPE_C5
...    Slot:0, Type:DL:SLOT_TYPE_B0
...    Slot:1, Type:DL:SLOT_TYPE_B0
...    Slot:2, Type:DL:SLOT_TYPE_B4
...    Slot:3, Type:DL:SLOT_TYPE_B2
...    Slot:4, Type:DL:SLOT_TYPE_C5
...    Slot:5, Type:DL:SLOT_TYPE_B0
...    Slot:6, Type:DL:SLOT_TYPE_B4
...    Slot:7, Type:DL:SLOT_TYPE_B2
...    Slot:8, Type:DL:SLOT_TYPE_C5
...    Slot:9, Type:DL:SLOT_TYPE_PRACH
...    Slot: 10, Type:DL:SLOT_TYPE_B0
...    Slot: 11, Type:DL:SLOT_TYPE_B0
...    Slot: 12, Type:DL:SLOT_TYPE_41
...    Slot: 13, Type:DL:SLOT_TYPE_41
...    Slot: 14, Type:DL:SLOT_TYPE_C5
...    Slot: 15, Type:DL:SLOT_TYPE_B0
...    Slot: 16, Type:DL:SLOT_TYPE_B4
...    Slot: 17, Type:DL:SLOT_TYPE_B2
...    Slot: 18, Type:DL:SLOT_TYPE_C5
...    Slot: 19, Type:DL:SLOT_TYPE_PRACH

${modify_APxml_4019}=    sed -i "s/rSpacingSSB>.*<\/subcarrierSpacingSSB>/rSpacingSSB>30<\/subcarrierSpacingSSB>/g" AirPhoneConfig*.xml;
...    sed -i "s/Periodicity>.*<\/dlUlTransmissionPeriodicity>/Periodicity>5<\/dlUlTransmissionPeriodicity>/g" AirPhoneConfig*.xml;
...    sed -i "s/<prachPreambleFormat>.*<\/prachPreambleFormat>/<prachPreambleFormat>6<\/prachPreambleFormat>/g" AirPhoneConfig*.xml;
...    sed -i "s/<prachConfigIndex>.*<\/prachConfigIndex>/<prachConfigIndex>94<\/prachConfigIndex>/g" AirPhoneConfig*.xml;
...    sed -i "s/<ssBurstSetPeriod>.*<\/ssBurstSetPeriod>/<ssBurstSetPeriod>20<\/ssBurstSetPeriod>/g" AirPhoneConfig*.xml;
...    sed -i "s/edSsBlocks>.*<\/numberOfTransmittedSsBlocks>/edSsBlocks>6<\/numberOfTransmittedSsBlocks>/g" AirPhoneConfig*.xml;
...    sed -i "s/<subcarrierSpacingSSB>.*<\/subcarrierSpacingSSB>/<subcarrierSpacingSSB>30<\/subcarrierSpacingSSB>/g" AirPhoneConfig*.xml
...    sed -i "s/<tddFrameStructureType>.*<\/tddFrameStructureType>/<tddFrameStructureType>1<\/tddFrameStructureType>/g" AirPhoneConfig*.xml

@{slottype_list_4019}    Slot:0, Type:DL:SLOT_TYPE_SSBURST
...    Slot:1, Type:DL:SLOT_TYPE_SSBURST
...    Slot:2, Type:DL:SLOT_TYPE_SSBURST
...    Slot:3, Type:DL:SLOT_TYPE_B2
...    Slot:4, Type:DL:SLOT_TYPE_C5
...    Slot:5, Type:DL:SLOT_TYPE_B0
...    Slot:6, Type:DL:SLOT_TYPE_B4
...    Slot:7, Type:DL:SLOT_TYPE_B2
...    Slot:8, Type:DL:SLOT_TYPE_C5
...    Slot:9, Type:DL:SLOT_TYPE_C5
...    Slot: 10, Type:DL:SLOT_TYPE_B0
...    Slot: 11, Type:DL:SLOT_TYPE_41
...    Slot: 12, Type:DL:SLOT_TYPE_41
...    Slot: 13, Type:DL:SLOT_TYPE_B2
...    Slot: 14, Type:DL:SLOT_TYPE_C5
...    Slot: 15, Type:DL:SLOT_TYPE_B0
...    Slot: 16, Type:DL:SLOT_TYPE_B4
...    Slot: 17, Type:DL:SLOT_TYPE_B2
...    Slot: 18, Type:DL:SLOT_TYPE_C5
...    Slot: 19, Type:DL:SLOT_TYPE_C5
...    Slot:0, Type:DL:SLOT_TYPE_B0
...    Slot:1, Type:DL:SLOT_TYPE_B0
...    Slot:2, Type:DL:SLOT_TYPE_B4
...    Slot:3, Type:DL:SLOT_TYPE_B2
...    Slot:4, Type:DL:SLOT_TYPE_C5
...    Slot:5, Type:DL:SLOT_TYPE_B0
...    Slot:6, Type:DL:SLOT_TYPE_B0
...    Slot:7, Type:DL:SLOT_TYPE_B2
...    Slot:8, Type:DL:SLOT_TYPE_PRACH
...    Slot:9, Type:DL:SLOT_TYPE_PRACH
...    Slot: 10, Type:DL:SLOT_TYPE_B0
...    Slot: 11, Type:DL:SLOT_TYPE_41
...    Slot: 12, Type:DL:SLOT_TYPE_41
...    Slot: 13, Type:DL:SLOT_TYPE_B2
...    Slot: 14, Type:DL:SLOT_TYPE_C5
...    Slot: 15, Type:DL:SLOT_TYPE_B0
...    Slot: 16, Type:DL:SLOT_TYPE_B0
...    Slot: 17, Type:DL:SLOT_TYPE_B2
...    Slot: 18, Type:DL:SLOT_TYPE_PRACH
...    Slot: 19, Type:DL:SLOT_TYPE_PRACH


@{slottype_list_4021}    Slot:0, Type:DL:SLOT_TYPE_SSBURST
...    Slot:1, Type:DL:SLOT_TYPE_SSBURST
...    Slot:2, Type:DL:SLOT_TYPE_SSBURST
...    Slot:3, Type:DL:SLOT_TYPE_B2
...    Slot:4, Type:DL:SLOT_TYPE_C5
...    Slot:5, Type:DL:SLOT_TYPE_B0
...    Slot:6, Type:DL:SLOT_TYPE_B4
...    Slot:7, Type:DL:SLOT_TYPE_B2
...    Slot:8, Type:DL:SLOT_TYPE_C5
...    Slot:9, Type:DL:SLOT_TYPE_C5
...    Slot: 10, Type:DL:SLOT_TYPE_B0
...    Slot: 11, Type:DL:SLOT_TYPE_41
...    Slot: 12, Type:DL:SLOT_TYPE_41
...    Slot: 13, Type:DL:SLOT_TYPE_B2
...    Slot: 14, Type:DL:SLOT_TYPE_C5
...    Slot: 15, Type:DL:SLOT_TYPE_B0
...    Slot: 16, Type:DL:SLOT_TYPE_B4
...    Slot: 17, Type:DL:SLOT_TYPE_B2
...    Slot: 18, Type:DL:SLOT_TYPE_C5
...    Slot: 19, Type:DL:SLOT_TYPE_C5
...    Slot:0, Type:DL:SLOT_TYPE_B0
...    Slot:1, Type:DL:SLOT_TYPE_B0
...    Slot:2, Type:DL:SLOT_TYPE_B4
...    Slot:3, Type:DL:SLOT_TYPE_B2
...    Slot:4, Type:DL:SLOT_TYPE_C5
...    Slot:5, Type:DL:SLOT_TYPE_B0
...    Slot:6, Type:DL:SLOT_TYPE_B4
...    Slot:7, Type:DL:SLOT_TYPE_B2
...    Slot:8, Type:DL:SLOT_TYPE_C5
...    Slot:9, Type:DL:SLOT_TYPE_C5
...    Slot: 10, Type:DL:SLOT_TYPE_B0
...    Slot: 11, Type:DL:SLOT_TYPE_41
...    Slot: 12, Type:DL:SLOT_TYPE_41
...    Slot: 13, Type:DL:SLOT_TYPE_B2
...    Slot: 14, Type:DL:SLOT_TYPE_C5
...    Slot: 15, Type:DL:SLOT_TYPE_B0
...    Slot: 16, Type:DL:SLOT_TYPE_B4
...    Slot: 17, Type:DL:SLOT_TYPE_B2
...    Slot: 18, Type:DL:SLOT_TYPE_C5
...    Slot: 19, Type:DL:SLOT_TYPE_PRACH


@{slottype_list_4023}    Slot:0, Type:DL:SLOT_TYPE_SSBURST
...    Slot:1, Type:DL:SLOT_TYPE_B0
...    Slot:2, Type:DL:SLOT_TYPE_B4
...    Slot:3, Type:DL:SLOT_TYPE_B2
...    Slot:4, Type:DL:SLOT_TYPE_C5
...    Slot:5, Type:DL:SLOT_TYPE_B0
...    Slot:6, Type:DL:SLOT_TYPE_B4
...    Slot:7, Type:DL:SLOT_TYPE_B2
...    Slot:8, Type:DL:SLOT_TYPE_C5
...    Slot:9, Type:DL:SLOT_TYPE_C5
...    Slot: 10, Type:DL:SLOT_TYPE_B0
...    Slot: 11, Type:DL:SLOT_TYPE_B0
...    Slot: 12, Type:DL:SLOT_TYPE_41
...    Slot: 13, Type:DL:SLOT_TYPE_41
...    Slot: 14, Type:DL:SLOT_TYPE_C5
...    Slot: 15, Type:DL:SLOT_TYPE_B0
...    Slot: 16, Type:DL:SLOT_TYPE_B4
...    Slot: 17, Type:DL:SLOT_TYPE_B2
...    Slot: 18, Type:DL:SLOT_TYPE_C5
...    Slot: 19, Type:DL:SLOT_TYPE_C5
...    Slot:0, Type:DL:SLOT_TYPE_B0
...    Slot:1, Type:DL:SLOT_TYPE_B0
...    Slot:2, Type:DL:SLOT_TYPE_B4
...    Slot:3, Type:DL:SLOT_TYPE_B2
...    Slot:4, Type:DL:SLOT_TYPE_C5
...    Slot:5, Type:DL:SLOT_TYPE_B0
...    Slot:6, Type:DL:SLOT_TYPE_B0
...    Slot:7, Type:DL:SLOT_TYPE_B2
...    Slot:8, Type:DL:SLOT_TYPE_PRACH
...    Slot:9, Type:DL:SLOT_TYPE_PRACH
...    Slot: 10, Type:DL:SLOT_TYPE_B0
...    Slot: 11, Type:DL:SLOT_TYPE_B0
...    Slot: 12, Type:DL:SLOT_TYPE_41
...    Slot: 13, Type:DL:SLOT_TYPE_41
...    Slot: 14, Type:DL:SLOT_TYPE_C5
...    Slot: 15, Type:DL:SLOT_TYPE_B0
...    Slot: 16, Type:DL:SLOT_TYPE_B0
...    Slot: 17, Type:DL:SLOT_TYPE_B2
...    Slot: 18, Type:DL:SLOT_TYPE_PRACH
...    Slot: 19, Type:DL:SLOT_TYPE_PRACH

${modify_APxml_4012}=    sed -i "s/rSpacingSSB>.*<\/subcarrierSpacingSSB>/rSpacingSSB>30<\/subcarrierSpacingSSB>/g" AirPhoneConfig*.xml;
...    sed -i "s/Periodicity>.*<\/dlUlTransmissionPeriodicity>/Periodicity>5<\/dlUlTransmissionPeriodicity>/g" AirPhoneConfig*.xml;
...    sed -i "s/<prachPreambleFormat>.*<\/prachPreambleFormat>/<prachPreambleFormat>6<\/prachPreambleFormat>/g" AirPhoneConfig*.xml;
...    sed -i "s/<prachConfigIndex>.*<\/prachConfigIndex>/<prachConfigIndex>151<\/prachConfigIndex>/g" AirPhoneConfig*.xml;
...    sed -i "s/<ssBurstSetPeriod>.*<\/ssBurstSetPeriod>/<ssBurstSetPeriod>20<\/ssBurstSetPeriod>/g" AirPhoneConfig*.xml;
...    sed -i "s/edSsBlocks>.*<\/numberOfTransmittedSsBlocks>/edSsBlocks>2<\/numberOfTransmittedSsBlocks>/g" AirPhoneConfig*.xml;
...    sed -i "s/<subcarrierSpacingSSB>.*<\/subcarrierSpacingSSB>/<subcarrierSpacingSSB>30<\/subcarrierSpacingSSB>/g" AirPhoneConfig*.xml
...    sed -i "s/<tddFrameStructureType>.*<\/tddFrameStructureType>/<tddFrameStructureType>1<\/tddFrameStructureType>/g" AirPhoneConfig*.xml


@{slottype_list_4012}    Slot:0, Type:DL:SLOT_TYPE_SSBURST
...    Slot:1, Type:DL:SLOT_TYPE_B0
...    Slot:2, Type:DL:SLOT_TYPE_B4
...    Slot:3, Type:DL:SLOT_TYPE_B2
...    Slot:4, Type:DL:SLOT_TYPE_C5
...    Slot:5, Type:DL:SLOT_TYPE_B0
...    Slot:6, Type:DL:SLOT_TYPE_B4
...    Slot:7, Type:DL:SLOT_TYPE_B2
...    Slot:8, Type:DL:SLOT_TYPE_C5
...    Slot:9, Type:DL:SLOT_TYPE_C5
...    Slot: 10, Type:DL:SLOT_TYPE_B0
...    Slot: 11, Type:DL:SLOT_TYPE_B0
...    Slot: 12, Type:DL:SLOT_TYPE_41
...    Slot: 13, Type:DL:SLOT_TYPE_41
...    Slot: 14, Type:DL:SLOT_TYPE_C5
...    Slot: 15, Type:DL:SLOT_TYPE_B0
...    Slot: 16, Type:DL:SLOT_TYPE_B4
...    Slot: 17, Type:DL:SLOT_TYPE_B2
...    Slot: 18, Type:DL:SLOT_TYPE_C5
...    Slot: 19, Type:DL:SLOT_TYPE_C5
...    Slot:0, Type:DL:SLOT_TYPE_B0
...    Slot:1, Type:DL:SLOT_TYPE_B0
...    Slot:2, Type:DL:SLOT_TYPE_B4
...    Slot:3, Type:DL:SLOT_TYPE_B2
...    Slot:4, Type:DL:SLOT_TYPE_C5
...    Slot:5, Type:DL:SLOT_TYPE_B0
...    Slot:6, Type:DL:SLOT_TYPE_B4
...    Slot:7, Type:DL:SLOT_TYPE_B2
...    Slot:8, Type:DL:SLOT_TYPE_C5
...    Slot:9, Type:DL:SLOT_TYPE_PRACH
...    Slot: 10, Type:DL:SLOT_TYPE_B0
...    Slot: 11, Type:DL:SLOT_TYPE_B0
...    Slot: 12, Type:DL:SLOT_TYPE_41
...    Slot: 13, Type:DL:SLOT_TYPE_41
...    Slot: 14, Type:DL:SLOT_TYPE_C5
...    Slot: 15, Type:DL:SLOT_TYPE_B0
...    Slot: 16, Type:DL:SLOT_TYPE_B4
...    Slot: 17, Type:DL:SLOT_TYPE_B2
...    Slot: 18, Type:DL:SLOT_TYPE_C5
...    Slot: 19, Type:DL:SLOT_TYPE_PRACH

*** Keywords ***


