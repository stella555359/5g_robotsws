#  Testline names mapping in WRO7 team. First keys are VM hostnames.

import socket

TL_MAP = {
    # REG
    "7-16-UTE5GCLOUDT161": {
        "testline_name": "7_16_UTE5GCLOUDT161",
        "testline_name_scout": "7_16_MRBTS-50069",
        "testline_label": "WRO7_E2E_ASIL_ABIL_2xABIO_3xAHLOA_2xAEHC",
        "owner": "P.Wisniewski"
    },
    "7-16-MRBTS50046": {
        "testline_name": "7_16_MRBTS50046",
        "testline_name_scout": "7_16_MRBTS50046",
        "testline_label": "WRO7_E2E_ASIL_ABIB_ABIO_AEHC",
        "owner": "J.Wojczyszyn"
    },
    "7-16-UTE5GCLOUDT151-1": {
        "testline_name": "7-16-UTE5GCLOUDT151",
        "testline_name_scout": "7_16_UTE5GCLOUD151",
        # "testline_name_scout": "7_16_MRBTS-50050",
        "testline_label": "WRO7_REG_ASIL_ABIL_2xABIO_3xAHLOA_2xAEHC",
        "owner": "M.Guszpit"
    },
    "7-16-UTE5GSA5-1": {
        "testline_name": "7_16_UTE5GSA5",
        "testline_name_scout": "7_16_UTE5GSA5",
        # "testline_name_scout": "7_16_MRBTS-50069",
        "testline_label": "WRO7_REG_ASIL_3xABIO_AEAN_AQQE_AZQL",
        "owner": "J.Wojczyszyn"
    },
    "7-16-UTE5GCLOUDT177": {
        "testline_name": "7_16_UTE5GCLOUDT177",
        "testline_name_scout": "7_16_UTE5GCLOUDT177",
        # "testline_name_scout": "7_16_MRBTS-50067",
        "testline_label": "WRO7_REG_ASIL_3xABIO_AEQN_AZQL",
        "owner": "TA WRO7"
    },
    "7-16-UTE5G286CLASS041-2": {
        "testline_name": "7_16_UTE5G286CLASS041",
        "testline_name_scout": "7_16_UTE5G286CLASS041",
        # "testline_name_scout": "7_16_MRBTS-50041",
        "testline_label": "WRO7_REG_ASIL_ABIL_3xAHLOA_2xAEHC",
        "owner": "J.Wojczyszyn"
    },
    "7-16-UTE5GCLOUDT152-1": {
        "testline_name": "7_16_UTE5GCLOUDT152",
        "testline_name_scout": "7_16_UTE5GCLOUDT152",
        # "testline_name_scout": "7_16_MRBTS-50051",
        "testline_label": "WRO7_REG_ASIL_ABIL_3xAHLOA",
        "owner": "M. Guszpit"
    },
    "7-16-UTE5GCLOUDT201-1": {
        "testline_name": "7_16_UTE5GCLOUDT201",
        "testline_name_scout": "7_16_UTE5GCLOUDT201",
        # "testline_name_scout": "7_16_MRBTS-50043",
        "testline_label": "WRO7_REG_ASIL_ABIL_AHFIB",
        "owner": "M. Guszpit"
    },
    "7-16-UTE5GCLOUDT191": {
        "testline_name": "7_16_UTE5GCLOUDT191",
        "testline_name_scout": "7_16_MRBTS-50806",
        "testline_label": "WRO7_REG_ASIL_ABIL_2xAEQN",
        "owner": "M. Guszpit"
    },
    # Manuals UUF
    "7-16-UTE5GCLOUD2": {
        "testline_name": "7_16_UTE5GCLOUD2",
        "testline_name_scout": "7_16_UTE5GCLOUD2",
        "testline_label": "WRO7_ASIL_ABIL_3xAHLOA",
        "owner": "M.Haladewicz"
    },
    "7-16-UTE5GCLOUD1": {
        "testline_name": "7_16_UTE5GCLOUD1",
        "testline_name_scout": "7_16_MRBTS-51779",
        "testline_label": "WRO7_ASIB_2xABIO_2xAHLOA_2xAEHC",
        "owner": "G.Slopien"
    },
    "7-16-UTE5GMRBTS40106": {
        "testline_name": "7_16_UTE5GMRBTS40106",
        "testline_name_scout": "10_16_MRBTS-50110-40106",
        "testline_label": "WRO7_ASIL_ABIO_AHEGB_AQQE",
        "owner": "A.Sheiko"
    },
    "7-16-UTE5GCLOUD8": {
        "testline_name": "7_16_UTE5GCLOUD8",
        "testline_name_scout": "10_16_MRBTS-51704",
        "testline_label": "WRO7_ASIB_2xABIO_AQQY_AHLOA",
        "owner": "A.Sheiko"
    },
    # Patrycja SFE    },
    "7-16-UTE5GCLOUDT204": {
        "testline_name": "10_16_50804-40860",
        "testline_name_scout": "10_16_50804-40860",
        "testline_label": "WRO7_REG_ASIL_2xABIO_4xAEQN_8xAEQY",
        "owner": "P.Lis"
    },
    "PLWR5GRRMF1414:": {
        "testline_name": "10_16_50803-40802_MRBTS-50803-40860",
        "testline_name_scout": "10_16_50803-40802_MRBTS-50803-40860",
        "testline_label": "WRO7_E2E_ASIK_ABIL_12xAEQN",
        "owner": "B.Zajac"
    },
    "PLWR5GRRM5E275:": {
        "testline_name": "10_16_51150-40803_MRBTS-51150",
        "testline_name_scout": "10_16_51150-40803_MRBTS-51150",
        "testline_label": "WRO7_E2E_1ASIL+1ABIO+2AEQY+2AQQL+2AVQL",
        "owner": "B.Zajac"
    },
    # Brzazgi SFE
    "MRBTS-50863": {
        "testline_name": "10_16_MRBTS-50863",
        "testline_name_scout": "10_16_MRBTS-50863",
        "testline_label": "WRO7_E2E_ASIL_2xABIO_1xAEQN_2xAZQG_1xAZQS_1xAHGA",
        "owner": "T.Brzazgacz"
    },
    "MRBTS-50862": {
        "testline_name": "10_16_MRBTS-50862",
        "testline_name_scout": "10_16_MRBTS-50862",
        "testline_label": "WRO7_E2E_ASIK_ABIL_1xAEQN_2xAEQY",
        "owner": "T.Brzazgacz"
    },
    "MRBTS-50892": {
        "testline_name": "10_16_MRBTS-50892",
        "testline_name_scout": "10_16_MRBTS-50892",
        "testline_label": "WRO7_E2E_ASIL_ABIO_2xAQQA",
        "owner": "T.Brzazgacz"
    },
    # Marcin SFE
    "MRBTS-50801": {
        "testline_name": "10_16_50801-40800_MRBTS-50801",
        "testline_name_scout": "10_16_50801-40800_MRBTS-50801",
        "testline_label": "WRO7_SFE_ASIK_2xABIL_6xAEQN",
        "owner": "M. Prajzner"
    },
    "MRBTS-50802": {
        "testline_name": "10_16_50802-40801_MRBTS-50802",
        "testline_name_scout": "10_16_50802-40801_MRBTS-50802",
        "testline_label": "WRO7_SFE_ASIL_ABIO_2xAEQN_4xAEQY",
        "owner": "M. Prajzner"
    },
    "plwr5grrma34b8": {
        "testline_name": "10_16_MRBTS-40863",
        "testline_name_scout": "10_16_MRBTS-40863",
        "testline_label": "WRO7_E2E_ASIL_ABIO_AHCA_FRGP_FGHB",
        "owner": "T.Brzazgacz"
    },
    # Witek
    "7-16-UTE5GCLOUD200": {
        "testline_name": "7_16_MRBTS-50040",
        "testline_name_scout": "7_16_MRBTS-50040",
        "testline_label": "WRO7_DUAL_CORE",
        "owner": "W.Galka"
    },
    "7-16-MRBTS55150": {
        "testline_name": "7_16_MRBTS55150",
        "testline_name_scout": "7_16_MRBTS5515",
        "testline_label": "WRO7_E2E_ASOE_AHGA_AZQO",
        "owner": "W.Galka"
    },
    # Karol
    "7-16-UTE5GCLOUDT164": {
        "testline_name": "7_16_UTE5GCLOUDT164",
        "testline_name_scout": "7_16_UTE5GCLOUDT164",
        "testline_label": "WRO7_ASIL_3xABIO_AEQY",
        "owner": "K.Malutk"
    },
    # Ania
    "7-16-UTE5GCLOUD8": {
        "testline_name": "7_16_MRBTS51704",
        "testline_name_scout": "MRBTS-51704",
        "testline_label": "",
        "owner": "A.Sheiko"
    },
    # Kasia
    "7-16-UTE5GCLOUD882": {
        "testline_name": "7_16_UTE5GCLOUD882",
        "testline_name_scout": "10_16_MRBTS-50882",
        "testline_label": "WRO7_ASIL_ABIO_AZQL_AZHL-AHFII_AHLOA",
        "owner": "K.Meinhardt"
    },
    "7-16-UTE5GCLOUD881": {
        "testline_name": "7_16_UTE5GCLOUD881",
        "testline_name_scout": "10_16_MRBTS-50881",
        "testline_label": "WRO7_ASIL_ABIO_ABIN_AZQO_AZQL_AHGA_ARHA_AZQG",
        "owner": "K.Meinhardt"
    },
    # CI Mock:
    "CI_MOCK": {
        "testline_name": "MOCK",
        "testline_name_scout": "MOCK",
        "testline_label": "MOCK",
        "owner": "MOCK"
    },
}

hostname = socket.gethostname()

if hostname not in TL_MAP.keys():
    hostname = "CI_MOCK"

TL_NAME = TL_MAP[hostname]["testline_name"]
TL_NAME_SCOUT = TL_MAP[hostname]["testline_name_scout"]
TL_OWNER = TL_MAP[hostname]["owner"]
TL_LABEL = TL_MAP[hostname]["testline_label"]
