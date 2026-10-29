from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')

B4PRACH_CONFIGURATION_4CC = \
    dict(guardPeriodLength=['2Symbols', '2Symbols', '2Symbols', '2Symbols'],
         prachConfigurationIndex=[135, 135, 135, 135],
         zeroCorrelationZoneConfig=[0, 0, 0, 0],
         totalNumberOfRAPreambles=[32, 32, 32, 32],
         cbraPreamblesPerSsb=['n32', 'n32', 'n32', 'n32'],
         rangeExtension=['1x_range', '1x_range', '1x_range', '1x_range'],
         prachRootSequenceIndex=[0, 0, 0, 0])
