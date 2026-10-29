"""
This file contains SFP classes used to store (Q)SFP parameters values based on SFP type.

:copyright: Nokia Networks
:author: Marek Bodziony
:contact: marek.bodziony@nokia.com
:maintainer: Marek Bodziony
:contact: marek.bodziony@nokia.com
"""


class Sfp:
    """
    Base class used to store (Q)SFP parameters values.
    """
    def __init__(self, compliance_code, vendor, vendor_part_number, vendor_revision, connector_type,
                 wave_length, transmission_rate, nominal_signaling_rate, tx_power_high_alarm_threshold,
                 tx_power_high_warn_threshold, tx_power_low_alarm_threshold, tx_power_low_warn_threshold,
                 rx_power_high_alarm_threshold, rx_power_high_warn_threshold, rx_power_low_alarm_threshold,
                 rx_power_low_warn_threshold, temperature_high_alarm_threshold, temperature_low_alarm_threshold):
        self.date_code = "manufactured_date"
        self.compliance_code = compliance_code
        self.vendor = vendor
        self.vendor_part_number = vendor_part_number
        self.vendor_revision = vendor_revision
        self.serial_number = "serial_number"
        self.connector_type = connector_type
        self.physical_port = 1
        self.wave_length = wave_length
        self.transmission_rate = transmission_rate
        self.nominal_signaling_rate = nominal_signaling_rate
        self.tx_power_high_alarm_threshold = tx_power_high_alarm_threshold
        self.tx_power_high_warn_threshold = tx_power_high_warn_threshold
        self.tx_power_low_alarm_threshold = tx_power_low_alarm_threshold
        self.tx_power_low_warn_threshold = tx_power_low_warn_threshold
        self.rx_power_high_alarm_threshold = rx_power_high_alarm_threshold
        self.rx_power_high_warn_threshold = rx_power_high_warn_threshold
        self.rx_power_low_alarm_threshold = rx_power_low_alarm_threshold
        self.rx_power_low_warn_threshold = rx_power_low_warn_threshold
        self.temperature_high_alarm_threshold = temperature_high_alarm_threshold
        self.temperature_low_alarm_threshold = temperature_low_alarm_threshold


class AOME(Sfp):
    """
    Class for SFP type AOME.
    """
    def __init__(self):
        Sfp.__init__(self, compliance_code="SFF_8472_REV_12_3", vendor="Hisense", vendor_part_number="LTF8502-BH-NK1",
                     vendor_revision="1", connector_type="LC", wave_length="850", transmission_rate="10300",
                     nominal_signaling_rate="TEST_VALUE", tx_power_high_alarm_threshold="0",
                     tx_power_high_warn_threshold="-1", tx_power_low_alarm_threshold="-8",
                     tx_power_low_warn_threshold="-8", rx_power_high_alarm_threshold="0",
                     rx_power_high_warn_threshold="-1", rx_power_low_alarm_threshold="-11",
                     rx_power_low_warn_threshold="-10", temperature_high_alarm_threshold="95",
                     temperature_low_alarm_threshold="-55")


class AOMC(Sfp):
    """
    Class for SFP type AOMC.
    """
    def __init__(self):
        Sfp.__init__(self, compliance_code="SFF_8472_REV_12_4", vendor="WTD", vendor_part_number="RTXM330-541-C39",
                     vendor_revision="1.0", connector_type="LC", wave_length="850", transmission_rate="9830.4",
                     nominal_signaling_rate="25750", tx_power_high_alarm_threshold="5",
                     tx_power_high_warn_threshold="2", tx_power_low_alarm_threshold="-11",
                     tx_power_low_warn_threshold="-8", rx_power_high_alarm_threshold="5",
                     rx_power_high_warn_threshold="2", rx_power_low_alarm_threshold="-13",
                     rx_power_low_warn_threshold="-10", temperature_high_alarm_threshold="95",
                     temperature_low_alarm_threshold="-50")


class AOMC_A(AOMC):
    """
    Class for SFP type AOMC (revision A).
    """
    def __init__(self):
        AOMC.__init__(self)
        self.vendor = "FINISAR CORP."
        self.vendor_part_number = "FTLF8536W4BTV-NS"
        self.vendor_revision = "A"
        self.tx_power_high_alarm_threshold = "3"
        self.tx_power_low_alarm_threshold = "-9"
        self.rx_power_high_alarm_threshold = "3"
        self.rx_power_low_alarm_threshold = "-20"
        self.rx_power_low_warn_threshold = "-18"
        self.temperature_high_alarm_threshold = "90"
        self.temperature_low_alarm_threshold = "-45"


class AOMC_B(AOMC):
    """
    Class for SFP type AOMC (revision B).
    """
    def __init__(self):
        AOMC.__init__(self)
        self.vendor = "FINISAR CORP."
        self.vendor_part_number = "FTLF8536W4BTV-NN"
        self.vendor_revision = "A"
        self.tx_power_high_alarm_threshold = "3"
        self.tx_power_low_alarm_threshold = "-9"
        self.rx_power_high_alarm_threshold = "3"
        self.rx_power_low_alarm_threshold = "-20"
        self.rx_power_low_warn_threshold = "-18"
        self.temperature_high_alarm_threshold = "90"
        self.temperature_low_alarm_threshold = "-45"


class AOSC(Sfp):
    """
     Class for SFP type AOSC.
    """
    def __init__(self):
        Sfp.__init__(self, compliance_code="SFF_8472_REV_12_3", vendor="WTD", vendor_part_number="RTXM330-204-C39B",
                     vendor_revision="1.0", connector_type="LC", wave_length="1310", transmission_rate="9830.4",
                     nominal_signaling_rate="25750", tx_power_high_alarm_threshold="5",
                     tx_power_high_warn_threshold="2", tx_power_low_alarm_threshold="-10",
                     tx_power_low_warn_threshold="-7", rx_power_high_alarm_threshold="5",
                     rx_power_high_warn_threshold="2", rx_power_low_alarm_threshold="-16",
                     rx_power_low_warn_threshold="-13", temperature_high_alarm_threshold="95",
                     temperature_low_alarm_threshold="-50")


class AOSD(Sfp):
    """
    Class for SFP type AOSD.
    """
    def __init__(self):
        Sfp.__init__(self, compliance_code="SFF_8472_REV_12_4", vendor="WTD", vendor_part_number="RTXM330-201-C39A",
                     vendor_revision="1.0", connector_type="LC", wave_length="1310", transmission_rate="25781.25",
                     nominal_signaling_rate="25750", tx_power_high_alarm_threshold="5",
                     tx_power_high_warn_threshold="2", tx_power_low_alarm_threshold="-10",
                     tx_power_low_warn_threshold="-7", rx_power_high_alarm_threshold="5",
                     rx_power_high_warn_threshold="2", rx_power_low_alarm_threshold="-16",
                     rx_power_low_warn_threshold="-13", temperature_high_alarm_threshold="95",
                     temperature_low_alarm_threshold="-50")


class AOSD_Finisar(Sfp):
    """
    Class for SFP type AOSD_Finisar.
    """
    def __init__(self):
        Sfp.__init__(self, compliance_code="SFF_8472_REV_12_4", vendor="FINISAR CORP.",
                     vendor_part_number="FTLF1436W4BTV-NN", vendor_revision="A", connector_type="LC",
                     wave_length="1310", transmission_rate="25781.25", nominal_signaling_rate="25750",
                     tx_power_high_alarm_threshold="4", tx_power_high_warn_threshold="3",
                     tx_power_low_alarm_threshold="-9", tx_power_low_warn_threshold="-8",
                     rx_power_high_alarm_threshold="3", rx_power_high_warn_threshold="2",
                     rx_power_low_alarm_threshold="-20", rx_power_low_warn_threshold="-18",
                     temperature_high_alarm_threshold="95", temperature_low_alarm_threshold="-48")
