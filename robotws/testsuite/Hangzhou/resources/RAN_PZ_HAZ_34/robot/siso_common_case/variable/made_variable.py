ALLOWED_FAULT = [
    {'faultId': 61652},
    {'faultId': 61524},
    {'faultId': 61649},
    {'faultId': 9000},
    {'faultId': 4592},
    {'faultId': 4527},
    {'faultId': 1932},
    {'faultId': 4334},
    {'faultId': 61074},
    {'faultId': 61618},
    {'faultId': 4687},
    {'faultId': 4654},
    {'faultId': 4655},
    {'faultId': 8150},
]

ALLOWED_HISTORY_FAULT = [
    {'faultId': 7319},
    {'faultId': 7300},
    {'faultId': 8150},
    {'faultId': 6327},
    {'faultId': 10},
    {'faultId': 4038},
    {'faultId': 2412},
    {'faultId': 6202}
]

ALLOWED_HISTORY_FAULT.extend(ALLOWED_FAULT)

NR_Frequencies = {
    # Frequencie_band_width_scs_ssb
    'n78_100_30_30': {
        'NRB': 273,
        'Min_guard': 845,  # unit kHz
        'NrarfcnStep_3gpp': 2
    },
    'n78_80_30_30': {
        'NRB': 217,
        'Min_guard': 925,  # unit kHz
        'NrarfcnStep_3gpp': 2
    },
    'n78_70_30_30': {
        'NRB': 189,
        'Min_guard': 965,  # unit kHz
        'NrarfcnStep_3gpp': 2
    },
    'n78_60_30_30': {
        'NRB': 162,
        'Min_guard': 825,  # unit kHz
        'NrarfcnStep_3gpp': 2
    },
    'n78_40_30_30': {
        'NRB': 106,
        'Min_guard': 905,  # unit kHz
        'NrarfcnStep_3gpp': 2
    },
    'n78_30_30_30': {
        'NRB': 78,
        'Min_guard': 945,  # unit kHz
        'NrarfcnStep_3gpp': 2
    },
    'n78_20_30_30': {
        'NRB': 51,
        'Min_guard': 805,  # unit kHz
        'NrarfcnStep_3gpp': 2
    },
    'n41_100_30_30': {
        'NRB': 273,
        'Min_guard': 845,  # unit kHz
        'NrarfcnStep_3gpp': 6
    },
    'n41_20_30_30': {
        'NRB': 51,
        'Min_guard': 805,  # unit kHz
        'NrarfcnStep_3gpp': 6
    },
    'n40_20_30_30': {
        'NRB': 51,
        'Min_guard': 805,  # unit kHz
        'NrarfcnStep_3gpp': 20
    },
    'n40_40_30_30': {
        'NRB': 106,
        'Min_guard': 905,  # unit kHz
        'NrarfcnStep_3gpp': 20
    },
    'n40_60_30_30': {
        'NRB': 162,
        'Min_guard': 825,  # unit kHz
        'NrarfcnStep_3gpp': 20
    },
    'n40_80_30_30': {
        'NRB': 217,
        'Min_guard': 925,  # unit kHz
        'NrarfcnStep_3gpp': 20
    },
    'n77_100_30_30': {
        'NRB': 273,
        'Min_guard': 845,  # unit kHz
        'NrarfcnStep_3gpp': 2
    },
    'n77_80_30_30': {
        'NRB': 217,
        'Min_guard': 925,  # unit kHz
        'NrarfcnStep_3gpp': 2
    },
    'n77_60_30_30': {
        'NRB': 162,
        'Min_guard': 825,  # unit kHz
        'NrarfcnStep_3gpp': 2
    },
    'n77_40_30_30': {
        'NRB': 106,
        'Min_guard': 905,  # unit kHz
        'NrarfcnStep_3gpp': 2
    },
    'n78_50_30_30': {
        'NRB': 133,
        'Min_guard': 1045,  # unit kHz
        'NrarfcnStep_3gpp': 2
    },
    'n78_90_30_30': {
        'NRB': 245,
        'Min_guard': 885,  # unit kHz
        'NrarfcnStep_3gpp': 2
    },
    'n77_20_30_30': {
        'NRB': 51,
        'Min_guard': 805,  # unit kHz
        'NrarfcnStep_3gpp': 2
    }
}

Variables_CFAM = {
    'AEQY': {
        'Uint_name': 'AEQY',
        'unitType_expect': '<unitType>AE</unitType>',
        'variant_expect': '<variant>QY</variant>',
        'ProductCode_expect': [
            '<p Name="Visible.Product.Code">475538A</p>',
            '<complex Name="Visible.Product.Code"><p Name="Key">475538A</p><p Name="Value">475538A</p></complex>'],
        'SuppTech_expect': '<list Name="Supported.Technology"><p>5G</p></list>',
        'NRFreqBand_expect': '<list Name="NR.Frequency.Band"><p>78</p><p>78</p></list>',
        'LinkType_expect': '<p Name="Type">CPRI</p>'
    },
    'AEQZ': {
        'UnitType_expect': '<unitType>AE</unitType>',
        'variant_expect': '<variant>QZ</variant>',
        'ProductCode_expect': [
            '<p Name="Visible.Product.Code">475444A</p>',
            '<complex Name="Visible.Product.Code"><p Name="Key">475444A</p><p Name="Value">475444A</p></complex>'],
        'SuppTech_expect': '<list Name="Supported.Technology"><p>5G</p></list>',
        'NRFreqBand_expect': '<list Name="NR.Frequency.Band"><p>78</p><p>78</p></list>',
        'LinkType_expect': '<p Name="Type">CPRI</p>'
    },
    'AEQB': {
        'Unit_name': 'AEQB',
        'unitType_expect': '<unitType>AE</unitType>',
        'variant_expect': '<variant>QB</variant>',
        'ProductCode_expect': '<p Name="Visible.Product.Code">474413A</p>',
        'SuppTech_expect': '<list Name="Supported.Technology"><p>5G</p></list>',
        'NRFreqBand_expect': '<list Name="NR.Frequency.Band"><p>78</p><p>78</p></list>',
        'Interface_Type': '<p Name="Interface.Type">CPRI-N,eCPRI</p>',
        'HW_Type': '<p Name="hwType">FR</p>'
    },
    'AEQC': {
        'Uint_name': 'AEQC',
        'unitType_expect': '<unitType>AE</unitType>',
        'variant_expect': '<variant>QC</variant>',
        'ProductCode_expect': '<Key.HW Manufacturer="N" ProductCode="475431A"/>'
                              '<Key.HW Manufacturer="N" ProductCode="475431B"/>',
        'SuppTech_expect': '<list Name="Supported.Technology"><p>5G</p></list>',
        'NRFreqBand_expect': '<list Name="NR.Frequency.Band"><p>78</p><p>78</p></list>',
        'LinkType_expect': '<p Name="Type">CPRI</p>'
    },
    'AEQQ': {
        'Uint_name': 'AEQQ',
        'unitType_expect': '<unitType>AE</unitType>',
        'variant_expect': '<variant>QQ</variant>',
        'ProductCode_expect': '<p Name="Visible.Product.Code">475252A</p>',
        'SuppTech_expect': '<list Name="Supported.Technology"><p>5G</p></list>',
        'NRFreqBand_expect': '<list Name="NR.Frequency.Band"><p>78</p><p>78</p></list>',
        'LinkType_expect': '<p Name="Type">CPRI</p>'
    },
    'AEQW': {
        'Uint_name': 'AEQW',
        'unitType_expect': '<unitType>AE</unitType>',
        'variant_expect': '<variant>QW</variant>',
        'ProductCode_expect': '<p Name="Visible.Product.Code">476277A</p>',
        'SuppTech_expect': '<list Name="Supported.Technology"><p>5G</p></list>',
        'NRFreqBand_expect': '<list Name="NR.Frequency.Band"><p>78</p><p>78</p></list>',
        'LinkType_expect': '<p Name="Type">eCPRI</p>'
    },
    'AQQQ': {
        'Uint_name': 'AQQQ',
        'unitType_expect': '<unitType>AQ</unitType>',
        'variant_expect': '<variant>QQ</variant>',
        'ProductCode_expect': '<p Name="Visible.Product.Code">475788A</p>',
        'SuppTech_expect': '<list Name="Supported.Technology"><p>5G</p></list>',
        'NRFreqBand_expect': '<list Name="NR.Frequency.Band"><p>78</p><p>78</p></list>',
        'LinkType_expect': '<p Name="Type">eCPRI</p>'
    },
    'AQQS': {
        'Uint_name': 'AQQS',
        'unitType_expect': '<unitType>AQ</unitType>',
        'variant_expect': '<variant>QS</variant>',
        'ProductCode_expect': '<Key.HW Manufacturer="N" ProductCode="475989A"/>'
                              '<Key.HW Manufacturer="N" ProductCode="476282A"/>'
                              '<Key.HW Manufacturer="N" ProductCode="093324A"/>'
                              '<Key.HW Manufacturer="N" ProductCode="093323A"/>',
        'SuppTech_expect': '<list Name="Supported.Technology"><p>5G</p></list>',
        'NRFreqBand_expect': '<list Name="NR.Frequency.Band"><p>77</p><p>77</p></list>',
        'LinkType_expect': '<p Name="Type">eCPRI</p>'
    },
    'AEQP': {
        'Uint_name': 'AEQP',
        'unitType_expect': '<unitType>AE</unitType>',
        'variant_expect': '<variant>QP</variant>',
        'ProductCode_expect': '<p Name="Visible.Product.Code">475238A</p>',
        'SuppTech_expect': '<list Name="Supported.Technology"><p>5G</p><p>EUTRA</p></list>',
        'NRFreqBand_expect': '<list Name="NR.Frequency.Band"><p>78</p><p>78</p></list>',
        'LinkType_expect': '<p Name="Type">CPRI</p>'
    },
    'AEQE': {
        'Uint_name': 'AEQE',
        'unitType_expect': '<unitType>AE</unitType>',
        'variant_expect': '<variant>QE</variant>',
        'ProductCode_expect': '<p Name="Visible.Product.Code">474750A</p>',
        'SuppTech_expect': '<list Name="Supported.Technology"><p>5G</p></list>',
        'NRFreqBand_expect': '<list Name="NR.Frequency.Band"><p>78</p><p>78</p></list>',
        'LinkType_expect': '<p Name="Type">CPRI</p>'
    },
    'AZNA': {
        'Uint_name': 'AZNA',
        'unitType_expect': '<unitType>AZ</unitType>',
        'variant_expect': '<variant>NA</variant>',
        'ProductCode_expect': '<p Name="Visible.Product.Code">473914A</p>',
        'SuppTech_expect': '<list Name="Supported.Technology"><p>EUTRA</p><p>5G</p></list>',
        'NRFreqBand_expect': '<list Name="NR.Frequency.Band"><p>40</p><p>40</p></list>',
        'LinkType_expect': '<p Name="Type">CPRI</p>'
    },
    'AZHA': {
        'Uint_name': 'AZHA',
        'unitType_expect': '<unitType>AZ</unitType>',
        'variant_expect': '<variant>HA</variant>',
        'ProductCode_expect': '<p Name="Visible.Product.Code">473941A</p>',
        'SuppTech_expect': '<list Name="Supported.Technology"><p>EUTRA</p><p>5G</p></list>',
        'NRFreqBand_expect': '<list Name="NR.Frequency.Band"><p>38</p><p>38</p><p>41</p><p>41</p></list>',
        'LinkType_expect': '<p Name="Type">CPRI</p>'
    },
    'AWHQG': {
        'Unit_name': 'AWHQG',
        'unitType_expect': '<unitType>AW</unitType>',
        'variant_expect': '<variant>HQG</variant>',
        'ProductCode_expect': '<p Name="Visible.Product.Code">474877A</p>',
        'SuppTech_expect': '<list Name="Supported.Technology"><p>5G</p></list>',
        'NRFreqBand_expect': '<list Name="NR.Frequency.Band"><p>78</p><p>78</p></list>',
        'LinkType_expect': '<p Name="Type">CPRI</p>'
    },
    'AWHQN': {
        'Uint_name': 'AWHQN',
        'unitType_expect': '<unitType>AW</unitType>',
        'variant_expect': '<variant>HQN</variant>',
        'ProductCode_expect': '<p Name="Visible.Product.Code">475701A</p>',
        'SuppTech_expect': '<list Name="Supported.Technology"><p>5G</p></list>',
        'NRFreqBand_expect': '<list Name="NR.Frequency.Band"><p>77</p><p>77</p></list>',
        'LinkType_expect': '<p Name="Interface.Type">eCPRI</p>'
    },
    'AWHQ2': {
        'Uint_name': 'AWHQ2',
        'unitType_expect': '<unitType>AW</unitType>',
        'variant_expect': '<variant>HQ2</variant>',
        'ProductCode_expect': '<p Name="Visible.Product.Code">476314A</p>',
        'SuppTech_expect': '<list Name="Supported.Technology"><p>5G</p></list>',
        'NRFreqBand_expect': '<list Name="NR.Frequency.Band"><p>78</p><p>78</p></list>',
        'LinkType_expect': '<p Name="Interface.Type">eCPRI</p>'
    },
    'AWHQX': {
        'Uint_name': 'AWHQX',
        'unitType_expect': '<unitType>AW</unitType>',
        'variant_expect': '<variant>HQX</variant>',
        'ProductCode_expect': '<p Name="Visible.Product.Code">475927A</p>',
        'SuppTech_expect': '<list Name="Supported.Technology"><p>5G</p></list>',
        'NRFreqBand_expect': '<list Name="NR.Frequency.Band"><p>77</p><p>77</p></list>',
        'LinkType_expect': '<p Name="Interface.Type">eCPRI</p>'
    },
    'AWHQW': {
        'Uint_name': 'AWHQW',
        'unitType_expect': '<unitType>AW</unitType>',
        'variant_expect': '<variant>HQW</variant>',
        'ProductCode_expect': '<p Name="Visible.Product.Code">475924A</p>',
        'SuppTech_expect': '<list Name="Supported.Technology"><p>5G</p></list>',
        'NRFreqBand_expect': '<list Name="NR.Frequency.Band"><p>77</p><p>77</p></list>',
        'LinkType_expect': '<p Name="Interface.Type">eCPRI</p>'
    },
    'AWHKB': {
        'Uint_name': 'AWHKB',
        'unitType_expect': '<unitType>AW</unitType>',
        'variant_expect': '<variant>HKB</variant>',
        'ProductCode_expect': '<p Name="Visible.Product.Code">476086A</p>',
        'SuppTech_expect': '<list Name="Supported.Technology"><p>EUTRA</p><p>5G</p></list>',
        'NRFreqBand_expect': '<list Name="EUTRA.Frequency.Band"><p>24</p><p>24</p></list>',
        'LinkType_expect': '<p Name="Type">CPRI</p>'
    },
    'AZQR': {
        'Unit_name': 'AZQR',
        'unitType_expect': '<unitType>AZ</unitType>',
        'variant_expect': '<variant>QR</variant>',
        'ProductCode_expect': '<p Name="Visible.Product.Code">475148A</p>',
        'SuppTech_expect': '<list Name="Supported.Technology"><p>EUTRA</p><p>5G</p></list>',
        'NRFreqBand_expect': '<list Name="NR.Frequency.Band"><p>78</p><p>78</p></list>',
        'LinkType_expect': '<p Name="Type">CPRI</p>'
    },
    'AZQD': {
        'Unit_name': 'AZQD',
        'unitType_expect': '<unitType>AZ</unitType>',
        'variant_expect': '<variant>QD</variant>',
        'ProductCode_expect': '<p Name="Visible.Product.Code">474798A</p>',
        'SuppTech_expect': '<list Name="Supported.Technology"><p>EUTRA</p><p>5G</p></list>',
        'NRFreqBand_expect': '<list Name="NR.Frequency.Band"><p>78</p><p>78</p></list>',
        'LinkType_expect': '<p Name="Type">CPRI</p>'
    },
    'AEQI': {
        'Unit_name': 'AEQI',
        'UnitType_expect': '<unitType>AE</unitType>',
        'variant_expect': '<variant>QI</variant>',
        'ProductCode_expect': [
            '<p Name="Visible.Product.Code">475440A</p>',
            '<complex Name="Visible.Product.Code"><p Name="Key">475440A</p><p Name="Value">475440A</p></complex>'],
        'SuppTech_expect': '<list Name="Supported.Technology"><p>5G</p></list>',
        'NRFreqBand_expect': '<list Name="NR.Frequency.Band"><p>78</p><p>78</p></list>',
        'LinkType_expect': '<p Name="Interface.Type">CPRI-N,eCPRI</p>'
    },
    'AEQK': {
        'Unit_name': 'AEQK',
        'unitType_expect': '<unitType>AE</unitType>',
        'variant_expect': '<variant>QK</variant>',
        'ProductCode_expect': '<p Name="Visible.Product.Code">475589A</p>',
        'SuppTech_expect': '<list Name="Supported.Technology"><p>5G</p></list>',
        'NRFreqBand_expect': '<list Name="NR.Frequency.Band"><p>77</p><p>77</p></list>',
        'LinkType_expect': '<p Name="Type">CPRI</p>'
    },
    'AWHQM': {
        'Uint_name': 'AWHQM',
        'unitType_expect': '<unitType>AQH</unitType>',
        'variant_expect': '<variant>QM</variant>',
        'ProductCode_expect': '<p Name="Visible.Product.Code">475246A</p>',
        'SuppTech_expect': '<list Name="Supported.Technology"><p>5G</p></list>',
        'NRFreqBand_expect': '<list Name="NR.Frequency.Band"><p>77</p><p>77</p></list>',
        'LinkType_expect': '<p Name="Type">CPRI</p>'
    },
    'AEQV': {
        'Uint_name': 'AEQV',
        'unitType_expect': '<unitType>AE</unitType>',
        'variant_expect': '<variant>QV</variant>',
        'ProductCode_expect': '<p Name="Visible.Product.Code">475294A</p>',
        'SuppTech_expect': '<list Name="Supported.Technology"><p>5G</p></list>',
        'NRFreqBand_expect': '<list Name="NR.Frequency.Band"><p>77</p><p>77</p></list>',
        'LinkType_expect': '<p Name="Type">CPRI</p>'
    },
    'AEQJ': {
        'Uint_name': 'AEQJ',
        'unitType_expect': '<unitType>AE</unitType>',
        'variant_expect': '<variant>QJ</variant>',
        'ProductCode_expect': '<p Name="Visible.Product.Code">475702A</p>',
        'SuppTech_expect': '<list Name="Supported.Technology"><p>5G</p></list>',
        'NRFreqBand_expect': '<list Name="NR.Frequency.Band"><p>78</p><p>78</p>',
        'LinkType_expect': '<p Name="Type">CPRI</p>'
    },
    'AEQF': {
        'Unit_name': 'AEQF',
        'UnitType_expect': '<unitType>AZ</unitType>',
        'variant_expect': '<variant>QF</variant>',
        'ProductCode_expect': '<p Name="Visible.Product.Code">474188A</p>',
        'SuppTech_expect': '<list Name="Supported.Technology"><p>EUTRA</p><p>5G</p></list>',
        'NRFreqBand_expect': '<list Name="NR.Frequency.Band"><p>78</p><p>78</p></list>',
        'LinkType_expect': '<p Name="Interface.Type">CPRI-N,eCPRI</p>'
    },
    'AENB': {
        'Unit_name': 'AENB',
        'UnitType_expect': '<unitType>AE</unitType>',
        'variant_expect': '<variant>NB</variant>',
        'ProductCode_expect': '<p Name="Visible.Product.Code">475728A</p>',
        'SuppTech_expect': '<list Name="Supported.Technology"><p>EUTRA</p><p>5G</p></list>',
        'NRFreqBand_expect': '<list Name="NR.Frequency.Band"><p>40</p><p>40</p></list>',
        'LinkType_expect': '<p Name="Interface.Type">CPRI-N,eCPRI</p>'
    },
    'AHPF': {
        'Uint_name': 'AHPF',
        'UnitType_expect': '<unitType>AH</unitType>',
        'variant_expect': '<variant>PF</variant>',
        'ProductCode_expect': '<p Name="Visible.Product.Code">475798A</p>',
        'SuppTech_expect': '<list Name="Supported.Technology"><p>5G</p></list>',
        'NRFreqBand_expect': '<list Name="NR.Frequency.Band"><p>28</p><p>28</p></list>',
        'LinkType_expect': '<p Name="Interface.Type">CPRI-N</p>'
    },
    'AZQF': {
        'Unit_name': 'AZQF',
        'UnitType_expect': '<unitType>AZ</unitType>',
        'variant_expect': '<variant>QF</variant>',
        'ProductCode_expect': '<p Name="Visible.Product.Code">474188A</p>',
        'SuppTech_expect': '<list Name="Supported.Technology"><p>EUTRA</p><p>5G</p></list>',
        'NRFreqBand_expect': '<list Name="NR.Frequency.Band"><p>78</p><p>78</p></list>',
        'LinkType_expect': '<p Name="Interface.Type">CPRI-N</p>'
    },
    'AWHHD': {
        'Unit_name': 'AWHHD',
        'unitType_expect': '<unitType>AW</unitType>',
        'variant_expect': '<variant>HHD</variant>',
        'ProductCode_expect': '<p Name="Visible.Product.Code">475068A</p>',
        'SuppTech_expect': '<list Name="Supported.Technology"><p>EUTRA</p><p>5G</p></list>',
        'NRFreqBand_expect': '<list Name="NR.Frequency.Band"><p>41</p><p>41</p></list>',
        'LinkType_expect': '<p Name="Type">CPRI</p>'
    },
    'AWHHF': {
        'Unit_name': 'AWHHF',
        'unitType_expect': '<unitType>AW</unitType>',
        'variant_expect': '<variant>HHF</variant>',
        'ProductCode_expect': '<p Name="Visible.Product.Code">475181A</p>',
        'SuppTech_expect': '<list Name="Supported.Technology"><p>EUTRA</p><p>5G</p></list>',
        'NRFreqBand_expect': '<list Name="NR.Frequency.Band"><p>41</p><p>41</p></list>',
        'LinkType_expect': '<p Name="Type">CPRI</p>'
    },
    'AQQK': {
        'Uint_name': 'AQQK',
        'UnitType_expect': '<unitType>AQ</unitType>',
        'variant_expect': '<variant>QK</variant>',
        'ProductCode_expect': '<Key.HW Manufacturer="N" ProductCode="475795A"/>'
                              '<Key.HW Manufacturer="N" ProductCode="476138A"/>'
                              '<Key.HW Manufacturer="N" ProductCode="092787A"/>'
                              '<Key.HW Manufacturer="N" ProductCode="092788A"/>',
        'SuppTech_expect': '<list Name="Supported.Technology"><p>5G</p></list>',
        'NRFreqBand_expect': '<list Name="NR.Frequency.Band"><p>77</p><p>77</p></list>',
        'LinkType_expect': '<p Name="Interface.Type">eCPRI</p>'
    },
    'AZQG': {
        'Unit_name': 'AZQG',
        'UnitType_expect': '<unitType>AZ</unitType>',
        'variant_expect': '<variant>QG</variant>',
        'ProductCode_expect': '<p Name="Visible.Product.Code">474994A</p>',
        'SuppTech_expect': '<list Name="Supported.Technology"><p>5G</p></list>',
        'NRFreqBand_expect': '<list Name="NR.Frequency.Band"><p>78</p><p>78</p></list>',
        'LinkType_expect': '<p Name="Interface.Type">CPRI-N,eCPRI</p>'
    },
    'AEQN': {
        'Uint_name': 'AEQN',
        'unitType_expect': '<unitType>AE</unitType>',
        'variant_expect': '<variant>QN</variant>',
        'ProductCode_expect': '<list Name="Visible.Product.Codes">\
<complex Name="Visible.Product.Code"><p Name="Key">474736A</p>\
<p Name="Value">474736A</p></complex><complex Name="Visible.Product.Code"><p Name="Key">090928A</p>\
<p Name="Value">090928A</p></complex></list>',
        'SuppTech_expect': '<list Name="Supported.Technology"><p>5G</p></list>',
        'NRFreqBand_expect': '<list Name="NR.Frequency.Band"><p>78</p><p>78</p></list>',
        'LinkType_expect': '<p Name="Interface.Type">CPRI-N,eCPRI</p>'
    },
    'AEQM': {
        'Uint_name': 'AEQM',
        'unitType_expect': '<unitType>AE</unitType>',
        'variant_expect': '<variant>QM</variant>',
        'ProductCode_expect': '<p Name="Visible.Product.Code">474842A</p>',
        'SuppTech_expect': '<list Name="Supported.Technology"><p>EUTRA</p><p>5G</p></list>',
        'NRFreqBand_expect': '<list Name="NR.Frequency.Band"><p>48</p><p>48</p></list>',
        'LinkType_expect': '<p Name="Interface.Type">CPRI-N,eCPRI</p>'
    },
    'AQQY': {
        'Unit_name': 'AQQY',
        'UnitType_expect': '<unitType>AQ</unitType>',
        'variant_expect': '<variant>QY</variant>',
        'ProductCode_expect': '<p Name="Visible.Product.Code">475573A</p>',
        'SuppTech_expect': [
            '<list Name="Supported.Technology"><p>5G</p><p>EUTRA</p></list>',
            '<list Name="Supported.Technology"><p>5G</p></list>'],
        'NRFreqBand_expect': '<list Name="NR.Frequency.Band"><p>78</p><p>78</p></list>',
        'LinkType_expect': '<p Name="Interface.Type">eCPRI</p>'
    },
    'AQQF': {
        'Unit_name': 'AQQF',
        'UnitType_expect': '<unitType>AQ</unitType>',
        'variant_expect': '<variant>QF</variant>',
        'ProductCode_expect': '<p Name="Visible.Product.Code">475922A</p>',
        'SuppTech_expect': [
            '<list Name="Supported.Technology"><p>5G</p><p>EUTRA</p></list>',
            '<list Name="Supported.Technology"><p>5G</p></list>'],
        'NRFreqBand_expect': '<list Name="NR.Frequency.Band"><p>78</p><p>78</p></list>',
        'LinkType_expect': '<p Name="Interface.Type">eCPRI</p>'
    },
    'AQQC': {
        'Unit_name': 'AQQC',
        'UnitType_expect': '<unitType>AQ</unitType>',
        'variant_expect': '<variant>QC</variant>',
        'ProductCode_expect': '<p Name="Visible.Product.Code">475789A</p>',
        'SuppTech_expect': '<list Name="Supported.Technology"><p>5G</p></list>',
        'NRFreqBand_expect': '<list Name="NR.Frequency.Band"><p>78</p><p>78</p></list>',
        'LinkType_expect': '<p Name="Interface.Type">eCPRI</p>'
    },
    'AQQA': {
        'Unit_name': 'AQQA',
        'UnitType_expect': '<unitType>AQ</unitType>',
        'variant_expect': '<variant>QA</variant>',
        'ProductCode_expect': '<p Name="Visible.Product.Code">475695A</p>',
        'SuppTech_expect': [
            '<list Name="Supported.Technology"><p>5G</p><p>EUTRA</p></list>',
            '<list Name="Supported.Technology"><p>5G</p></list>'],
        'NRFreqBand_expect': '<list Name="NR.Frequency.Band"><p>78</p><p>78</p></list>',
        'LinkType_expect': '<p Name="Interface.Type">eCPRI</p>'
    },
    'AEQU': {
        'Unit_name': 'AEQU',
        'unitType_expect': '<unitType>AE</unitType>',
        'variant_expect': '<variant>QU</variant>',
        'ProductCode_expect': '<p Name="Visible.Product.Code">476085A</p>',
        'SuppTech_expect': '<list Name="Supported.Technology"><p>5G</p></list>',
        'NRFreqBand_expect': '<list Name="NR.Frequency.Band"><p>77</p><p>77</p></list>',
        'LinkType_expect': '<p Name="Type">eCPRI</p>'
    },
    'AQQL': {
        'Uint_name': 'AQQL',
        'unitType_expect': '<unitType>AQ</unitType>',
        'variant_expect': '<variant>QL</variant>',
        'ProductCode_expect': '<p Name="Visible.Product.Code">475732A</p>',
        'SuppTech_expect': '<list Name="Supported.Technology"><p>5G</p></list>',
        'NRFreqBand_expect': '<list Name="NR.Frequency.Band"><p>78</p><p>78</p></list>',
        'LinkType_expect': '<p Name="Type">eCPRI</p>'
    },
    'AQQQA': {
        'Uint_name': 'AQQQA',
        'unitType_expect': '<unitType>AQ</unitType>',
        'variant_expect': '<variant>QQA</variant>',
        'ProductCode_expect': '<p Name="Visible.Product.Code">476090A</p>',
        'SuppTech_expect': '<list Name="Supported.Technology"><p>5G</p></list>',
        'NRFreqBand_expect': '<list Name="NR.Frequency.Band"><p>77</p><p>77</p></list>',
        'LinkType_expect': '<p Name="Type">eCPRI</p>'
    },
    'AQQN': {
        'Uint_name': 'AQQN',
        'unitType_expect': '<unitType>AQ</unitType>',
        'variant_expect': '<variant>QN</variant>',
        'ProductCode_expect': '<Key.HW Manufacturer="N" ProductCode="475937A"/>'
                              '<Key.HW Manufacturer="N" ProductCode="476281A"/>'
                              '<Key.HW Manufacturer="N" ProductCode="093175A"/>'
                              '<Key.HW Manufacturer="N" ProductCode="093176A"/>',
        'SuppTech_expect': [
            '<list Name="Supported.Technology"><p>5G</p><p>EUTRA</p></list>',
            '<list Name="Supported.Technology"><p>5G</p></list>'],
        'NRFreqBand_expect': '<list Name="NR.Frequency.Band"><p>78</p><p>78</p></list>',
        'LinkType_expect': '<p Name="Type">eCPRI</p>'
    },
    'AQQJ': {
        'Uint_name': 'AQQJ',
        'unitType_expect': '<unitType>AQ</unitType>',
        'variant_expect': '<variant>QJ</variant>',
        'ProductCode_expect': '<Key.HW Manufacturer="N" ProductCode="476383A"/>',
        'SuppTech_expect': '<list Name="Supported.Technology"><p>5G</p></list>',
        'NRFreqBand_expect': '<list Name="NR.Frequency.Band"><p>78</p><p>78</p></list>',
        'LinkType_expect': '<p Name="Type">eCPRI</p>'
    },
    'AQHC': {
        'Uint_name': 'AQHC',
        'unitType_expect': '<unitType>AQ</unitType>',
        'variant_expect': '<variant>HC</variant>',
        'ProductCode_expect': '<Key.HW Manufacturer="N" ProductCode="476108A"/>',
        'SuppTech_expect': [
            '<list Name="Supported.Technology"><p>5G</p><p>EUTRA</p></list>',
            '<list Name="Supported.Technology"><p>5G</p></list>'],
        'NRFreqBand_expect': '<list Name="NR.Frequency.Band"><p>41</p><p>41</p></list>',
        'LinkType_expect': '<p Name="Type">eCPRI</p>'
    },
    'AZQC': {
        'Uint_name': 'AZQC',
        'unitType_expect': '<unitType>AZ</unitType>',
        'variant_expect': '<variant>QC</variant>',
        'ProductCode_expect': [
            '<p Name="Visible.Product.Code">474156A</p>',
            '<complex Name="Visible.Product.Code"><p Name="Key">474156A</p><p Name="Value">474156A</p></complex>'],
        'SuppTech_expect': '<list Name="Supported.Technology"><p>EUTRA</p><p>5G</p></list>',
        'NRFreqBand_expect': '<list Name="NR.Frequency.Band"><p>48</p><p>48</p></list>',
        'LinkType_expect': '<p Name="Type">CPRI</p>'
    },
    'AWPQY': {
        'Uint_name': 'AWPQY',
        'unitType_expect': '<unitType>AW</unitType>',
        'variant_expect': '<variant>PQY</variant>',
        'ProductCode_expect': [
            '<p Name="Visible.Product.Code">476099A</p>',
            '<complex Name="Visible.Product.Code"><p Name="Key">476099A</p><p Name="Value">476099A</p></complex>'],
        'SuppTech_expect': '<list Name="Supported.Technology"><p>EUTRA</p><p>5G</p></list>',
        'NRFreqBand_expect': '<list Name="NR.Frequency.Band"><p>48</p><p>48</p></list>',
        'LinkType_expect': '<p Name="Type">eCPRI</p>'
    },
    'AWPQZ': {
        'Uint_name': 'AWPQZ',
        'unitType_expect': '<unitType>AW</unitType>',
        'variant_expect': '<variant>PQZ</variant>',
        'ProductCode_expect': [
            '<p Name="Visible.Product.Code">476101A</p>',
            '<complex Name="Visible.Product.Code"><p Name="Key">476101A</p><p Name="Value">476101A</p></complex>'],
        'SuppTech_expect': '<list Name="Supported.Technology"><p>EUTRA</p><p>5G</p></list>',
        'NRFreqBand_expect': '<list Name="NR.Frequency.Band"><p>48</p><p>48</p></list>',
        'LinkType_expect': '<p Name="Type">eCPRI</p>'
    },
    'AWPTC': {
        'Uint_name': 'AWPTC',
        'unitType_expect': '<unitType>AW</unitType>',
        'variant_expect': '<variant>PTC</variant>',
        'ProductCode_expect': [
            '<p Name="Visible.Product.Code">476205A</p>',
            '<complex Name="Visible.Product.Code"><p Name="Key">476205A</p><p Name="Value">476205A</p></complex>'],
        'SuppTech_expect': '<list Name="Supported.Technology"><p>5G</p></list>',
        'NRFreqBand_expect': '<list Name="NR.Frequency.Band"><p>79</p><p>79</p></list>',
        'LinkType_expect': '<p Name="Type">eCPRI</p>'
    },
    'AWPTD': {
        'Uint_name': 'AWPTD',
        'unitType_expect': '<unitType>AW</unitType>',
        'variant_expect': '<variant>PTD</variant>',
        'ProductCode_expect': [
            '<p Name="Visible.Product.Code">476206A</p>',
            '<complex Name="Visible.Product.Code"><p Name="Key">476206A</p><p Name="Value">476206A</p></complex>'],
        'SuppTech_expect': '<list Name="Supported.Technology"><p>5G</p></list>',
        'NRFreqBand_expect': '<list Name="NR.Frequency.Band"><p>79</p><p>79</p></list>',
        'LinkType_expect': '<p Name="Type">eCPRI</p>'
    },
    'AWHNB': {
        'Uint_name': 'AWHNB',
        'unitType_expect': '<unitType>AW</unitType>',
        'variant_expect': '<variant>HNB</variant>',
        'ProductCode_expect': '<p Name="Visible.Product.Code">476437A</p>',
        'SuppTech_expect': '<list Name="Supported.Technology"><p>EUTRA</p><p>5G</p></list>',
        'NRFreqBand_expect': '<list Name="NR.Frequency.Band"><p>53</p><p>53</p></list>',
        'LinkType_expect': '<p Name="Type">eCPRI</p>'
    },
    'AVQL': {
        'Unit_name': 'AVQL',
        'UnitType_expect': '<unitType>AV</unitType>',
        'variant_expect': '<variant>QL</variant>',
        'ProductCode_expect':
            '<complex Name="Visible.Product.Code"><p Name="Key">476203A</p><p Name="Value">476203A</p></complex>',
        'SuppTech_expect': '<list Name="Supported.Technology"><p>5G</p></list>',
        'NRFreqBand_expect': '<list Name="NR.Frequency.Band"><p>78</p><p>78</p></list>',
        'LinkType_expect': '<p Name="Interface.Type">eCPRI</p>'
    },
    'AVQA': {
        'Unit_name': 'AVQA',
        'UnitType_expect': '<unitType>AV</unitType>',
        'variant_expect': '<variant>QA</variant>',
        'ProductCode_expect':
            '<complex Name="Visible.Product.Code"><p Name="Key">476457A</p><p Name="Value">476457A</p></complex>',
        'SuppTech_expect': '<list Name="Supported.Technology"><p>5G</p></list>',
        'NRFreqBand_expect': '<list Name="NR.Frequency.Band"><p>78</p><p>78</p></list>',
        'LinkType_expect': '<p Name="Interface.Type">eCPRI</p>'
    },
    'AVQC': {
        'Unit_name': 'AVQC',
        'UnitType_expect': '<unitType>AV</unitType>',
        'variant_expect': '<variant>QC</variant>',
        'ProductCode_expect':
            '<complex Name="Visible.Product.Code"><p Name="Key">476335A</p><p Name="Value">476335A</p></complex>',
        'SuppTech_expect': '<list Name="Supported.Technology"><p>5G</p></list>',
        'NRFreqBand_expect': '<list Name="NR.Frequency.Band"><p>78</p><p>78</p></list>',
        'LinkType_expect': '<p Name="Interface.Type">eCPRI</p>'
    },
    'AVHQA': {
        'Uint_name': 'AVHQA',
        'unitType_expect': '<unitType>AV</unitType>',
        'variant_expect': '<variant>HQA</variant>',
        'ProductCode_expect': '<list Name="Visible.Product.Codes">\
<complex Name="Visible.Product.Code"><p Name="Key">476347A</p><p Name="Value">476347A</p></complex>\
<complex Name="Visible.Product.Code"><p Name="Key">476599A</p><p Name="Value">476599A</p></complex>\
<complex Name="Visible.Product.Code"><p Name="Key">476598A</p><p Name="Value">476598A</p></complex></list>',
        'SuppTech_expect': ['<list Name="Supported.Technology"><p>5G</p><p>EUTRA</p></list>',
                            '<list Name="Supported.Technology"><p>5G</p></list>'],
        'NRFreqBand_expect': '<list Name="NR.Frequency.Band"><p>41</p><p>41</p><p>78</p><p>78</p></list>',
        'LinkType_expect': '<p Name="Interface.Type">eCPRI</p>'
    },
    'AVHQB': {
        'Uint_name': 'AVHQB',
        'unitType_expect': '<unitType>AV</unitType>',
        'variant_expect': '<variant>HQB</variant>',
        'ProductCode_expect': '<list Name="Visible.Product.Codes">\
<complex Name="Visible.Product.Code"><p Name="Key">476501A</p><p Name="Value">476501A</p></complex>\
<complex Name="Visible.Product.Code"><p Name="Key">476502A</p><p Name="Value">476502A</p></complex>\
<complex Name="Visible.Product.Code"><p Name="Key">476503A</p><p Name="Value">476503A</p></complex></list>',
        'SuppTech_expect': ['<list Name="Supported.Technology"><p>5G</p><p>EUTRA</p></list>',
                            '<list Name="Supported.Technology"><p>5G</p></list>'],
        'NRFreqBand_expect': '<list Name="NR.Frequency.Band"><p>38</p><p>38</p><p>78</p><p>78</p></list>',
        'LinkType_expect': '<p Name="Interface.Type">eCPRI</p>'
    },
}

Old_SW_version_for_stream = {
    'SBTS22R3': 'SBTS22R3_ENB_0000_001588_000000',
    'SBTS22R4': 'SBTS22R4_ENB_0000_000758_000007',
    'SBTS23R1': 'SBTS23R1_ENB_0000_000006_000000',
    'SBTS00': 'SBTS00_ENB_9999_221021_000008'
}
