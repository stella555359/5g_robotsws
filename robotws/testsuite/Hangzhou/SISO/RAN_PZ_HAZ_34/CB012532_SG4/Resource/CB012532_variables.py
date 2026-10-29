# Variables for CB012532 tests
# Author: Lan Shifu
# Contact: shifu.lan@nokia-sbell.com

ecpri_parameters_dict = {
    "72a": {
        "cell_level": [
            {"parameter": "actEcpri72e", "value": "false"},
            {"parameter": "numberOfRxBeamforming", "value": "8Rx"},
            {"parameter": "nrCellType", "value": "16DL8UL"},
            {"parameter": "srsForSubbandBm", "value": [{"bfSubbandSize": "4 PRBs"}]},
        ],
        "bts_level": [
            {"dist_name": "MNL-1/MNLENT-1/PMMNL-1", "parameter": "miOranRuTxStats", "value": "disabled"},
        ]
    },

    "72e": {
        "cell_level": [
            {"parameter": "actEcpri72e", "value": "true"},
            {"parameter": "numberOfRxBeamforming", "value": "16Rx"},
            {"parameter": "nrCellType", "value": "16DL4UL"},
            {"parameter": "srsForSubbandBm", "value": [{"bfSubbandSize": "2 PRBs"}]},
        ],
        "bts_level": []  # 72e mode has no bts-level parameters
    }
}
