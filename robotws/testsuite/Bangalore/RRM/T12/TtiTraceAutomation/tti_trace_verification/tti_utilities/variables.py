# threshold mappings
import json
from pathlib import Path

threshold_mappings = {
    "REDCAP": {
        "dense_to_sparse_mapping": {
            "avgDlDataRate": {
                "threshold": "dlRateThresholdToSparseSssg",
                "operator": "lt",
            },
            "avgUlDataRate": {
                "threshold": "ulRateThresholdToSparseSssg",
                "operator": "lt",
            },
            "bufferEmptyRatioDl": {
                "threshold": "dlBufferEmptyRatioToSparseSssg",
                "operator": "gt",
            },
            "bufferEmptyRatioUl": {
                "threshold": "ulBufferEmptyRatioToSparseSssg",
                "operator": "gt",
            }
        },
        "sparse_to_dense_mapping": {
            "avgDlDataRate": {
                "threshold": "dlRateThresholdFromSparseSssg",
                "operator": "gt",
            },
            "avgUlDataRate": {
                "threshold": "ulRateThresholdFromSparseSssg",
                "operator": "gt",
            },
            "bufferEmptyRatioDl": {
                "threshold": "dlBufferEmptyRatioFromSparseSssg",
                "operator": "lt",
            },
            "bufferEmptyRatioUl": {
                "threshold": "ulBufferEmptyRatioFromSparseSssg",
                "operator": "lt",
            }
        },
    },
    "NONREDCAP": {
        "dense_to_sparse_mapping": {
            "avgDlDataRate": {
                "threshold": "dlRateThresholdToSparseSssg",
                "operator": "lt",
            },
            "avgUlDataRate": {
                "threshold": "ulRateThresholdNoVoNRToSparseSssg",
                "operator": "lt",
            },
            "bufferEmptyRatioDl": {
                "threshold": "dlBufferEmptyRatioToSparseSssg",
                "operator": "gt",
            },
            "bufferEmptyRatioUl": {
                "threshold": "ulBufferEmptyRatioToSparseSssg",
                "operator": "gt",
            }
        },
        "sparse_to_dense_mapping": {
            "avgDlDataRate": {
                "threshold": "dlRateThresholdFromSparseSssg",
                "operator": "gt",
            },
            "avgUlDataRate": {
                "threshold": "ulRateThresholdNoVoNRFromSparseSssg",
                "operator": "gt",
            },
            "bufferEmptyRatioDl": {
                "threshold": "dlBufferEmptyRatioFromSparseSssg",
                "operator": "lt",
            },
            "bufferEmptyRatioUl": {
                "threshold": "ulBufferEmptyRatioFromSparseSssg",
                "operator": "lt",
            }
        },
    },
}

threshold_mappings_for_vonr = {
    "REDCAP": {
        "dense_to_sparse_mapping": {
            "avgDlDataRate": {
                "threshold": "dlRateThresholdToSparseSssg",
                "operator": "lt",
            },
            "avgUlDataRate": {
                "threshold": "ulRateThresholdToSparseSssg",
                "operator": "lt",
            },
            "bufferEmptyRatioDl": {
                "threshold": "dlBufferEmptyRatioToSparseSssg",
                "operator": "gt",
            },
            "bufferEmptyRatioUl": {
                "threshold": "ulBufferEmptyRatioToSparseSssg",
                "operator": "gt",
            }
        },
        "sparse_to_dense_mapping": {
            "avgDlDataRate": {
                "threshold": "dlRateThresholdFromSparseSssg",
                "operator": "gt",
            },
            "avgUlDataRate": {
                "threshold": "ulRateThresholdFromSparseSssg",
                "operator": "gt",
            },
            "bufferEmptyRatioDl": {
                "threshold": "dlBufferEmptyRatioFromSparseSssg",
                "operator": "lt",
            },
            "bufferEmptyRatioUl": {
                "threshold": "ulBufferEmptyRatioFromSparseSssg",
                "operator": "lt",
            }
        },
    },
    "NONREDCAP": {
        "dense_to_sparse_mapping": {
            "avgDlDataRate": {
                "threshold": "dlRateThresholdToSparseSssg",
                "operator": "lt",
            },
            "avgUlDataRate": {
                "threshold": "ulRateThresholdVoNRToSparseSssg",
                "operator": "lt",
            },
            "bufferEmptyRatioDl": {
                "threshold": "dlBufferEmptyRatioToSparseSssg",
                "operator": "gt",
            },
            "bufferEmptyRatioUl": {
                "threshold": "ulBufferEmptyRatioToSparseSssg",
                "operator": "gt",
            }
        },
        "sparse_to_dense_mapping": {
            "avgDlDataRate": {
                "threshold": "dlRateThresholdFromSparseSssg",
                "operator": "gt",
            },
            "avgUlDataRate": {
                "threshold": "ulRateThresholdVoNRFromSparseSssg",
                "operator": "gt",
            },
            "bufferEmptyRatioDl": {
                "threshold": "dlBufferEmptyRatioFromSparseSssg",
                "operator": "lt",
            },
            "bufferEmptyRatioUl": {
                "threshold": "ulBufferEmptyRatioFromSparseSssg",
                "operator": "lt",
            }
        },
    },
}

METADATA_COLUMNS = ["hfnTickCount", "sfn", "slot"]
MAX_SFN = 1024
MAX_SLOT = 19


def save_thresholds(thresholds_dict, name, save_path="."):
    """
    Save thresholds dictionary to {name}_thresholds.json

    Args:
        thresholds_dict: Your dictionary with thresholds
        name: Company/project name (e.g., "server1", "clientA")
        save_path: Folder to save (default: current directory)
    """
    # Create save path if it doesn't exist
    Path(save_path).mkdir(exist_ok=True)

    # Filename: {name}_thresholds.json
    filename = f"{name}_thresholds.json"
    filepath = Path(save_path) / filename

    # Save dictionary as JSON (perfect for dictionaries!)
    with open(filepath, "w") as f:
        json.dump(thresholds_dict, f, indent=4, sort_keys=True)

    print(f"✅ Saved thresholds to: {filepath}\n")
