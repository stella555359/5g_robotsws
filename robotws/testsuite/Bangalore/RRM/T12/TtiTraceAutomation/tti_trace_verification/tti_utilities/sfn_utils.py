import pandas as pd
from tti_utilities.variables import METADATA_COLUMNS, MAX_SLOT

# this is the name of the columns
# sssgSwitchingEvent that we have to tap in
SWITCHTYPES = {"SPARSETODENSE", "DENSETOSPARSE"}
EXPECTED_SWITCH = {"SPARSETODENSE": "DENSETOSPARSE", "DENSETOSPARSE": "SPARSETODENSE"}


def decrement_slot(col1, col2, slot):
    """Decrement slot (0-19). If 0, increment col2-1 and set slot=19"""
    try:
        slot = int(slot)
        col2 = int(col2)
        col1 = int(col1)
        if slot > 0:
            return col1, col2, slot - 1
        else:  # slot == 0
            return col1, col2 - 1, MAX_SLOT
    except (ValueError, TypeError):
        return col1, col2, slot  # Return original if not numeric


def record_sfn_range(
    df, output_file, metadata_cols=METADATA_COLUMNS, expected_switch_map=EXPECTED_SWITCH
):
    """
    Extracts paired metadata between SPARSETODENSE <-> DENSETOSPARSE switches.
    Handles incomplete pairs at end with fallback logic.
    """
    switchDescribeColumn = "sssgSwitchingEvent"
    df = df.copy()
    # print(df)
    # df['switch'] = 0  # Track pair number
    # print(df)

    pairs = []
    current_pair = {
        "start_metadata": None,
        "end_metadata": None,
        "switch": 0,
        "direction_start": None,
    }
    expecting_switch = None

    for idx, row in df.iterrows():
        direction = row[switchDescribeColumn]
        # print(direction)
        # Ignore rows with invalid directions
        if direction not in SWITCHTYPES:
            continue
        if current_pair["start_metadata"] is None:
            # if current_pair.get('start_metadata') is not None and expecting_switch is not None:
            # Start new pair switch
            current_pair = {
                "start_idx": idx,
                "start_metadata": {col: row[col] for col in metadata_cols},
                "switch": len(pairs) + 1,
                "direction_start": direction,
            }
            expecting_switch = expected_switch_map[direction]
            # print(expecting_switch)
        # elif direction == expecting_switch:
        #     # Close current pair switch
        #     current_pair['end_idx'] = idx
        #     current_pair['end_metadata'] = {col: row[col] for col in metadata_cols}
        #     pairs.append(current_pair.copy())
        #     current_pair = {'start_metadata': None, 'end_metadata': None, 'switch': 0, 'direction_start': None}
        #     expecting_switch = None
        else:
            if direction == expecting_switch:
                # Switch row ENDS current pair AND STARTS next pair
                current_pair["end_idx"] = idx
                # END metadata - Direct slot decrement
                end_metadata = {col: row[col] for col in metadata_cols}
                (
                    end_metadata[METADATA_COLUMNS[0]],
                    end_metadata[METADATA_COLUMNS[1]],
                    end_metadata[METADATA_COLUMNS[2]],
                ) = decrement_slot(
                    end_metadata[METADATA_COLUMNS[0]],
                    end_metadata[METADATA_COLUMNS[1]],
                    end_metadata[METADATA_COLUMNS[2]],
                )
                current_pair["end_metadata"] = end_metadata
                # current_pair['end_metadata'] = {col: row[col] for col in metadata_cols}
                pairs.append(current_pair.copy())
                # IMMEDIATELY start new pair using THIS SAME switch row
                current_pair = {
                    "start_idx": idx,
                    "start_metadata": {col: row[col] for col in metadata_cols},
                    "switch": len(pairs) + 1,
                    "direction_start": direction,
                }
                expecting_switch = expected_switch_map[direction]  # Flip again
        # If neither starting nor expected switch, keep iterating
    # Fallback for incomplete pair at the end of dataframe
    if current_pair["start_metadata"] is not None:

        current_pair["end_idx"] = idx
        if idx == df.index[-1]:
            current_pair["is_last_entry"] = True
        # END metadata - Direct slot decrement
        end_metadata = {col: row[col] for col in metadata_cols}
        (
            end_metadata[METADATA_COLUMNS[0]],
            end_metadata[METADATA_COLUMNS[1]],
            end_metadata[METADATA_COLUMNS[2]],
        ) = decrement_slot(
            end_metadata[METADATA_COLUMNS[0]],
            end_metadata[METADATA_COLUMNS[1]],
            end_metadata[METADATA_COLUMNS[2]],
        )
        current_pair["end_metadata"] = end_metadata
        current_pair["is_fallback"] = True
        pairs.append(current_pair)
    # Flatten pairs to DataFrame rows for output
    result_rows = []
    for pair in pairs:
        row = {
            "switch": pair["switch"],
            "direction_start": pair["direction_start"],
            "is_fallback": pair.get("is_fallback", False),
            "is_last_entry": pair.get("is_last_entry", False),
        }
        for k, v in pair["start_metadata"].items():
            row[f"start_{k}"] = v
        for k, v in pair["end_metadata"].items():
            row[f"end_{k}"] = v
        result_rows.append(row)

    result_df = pd.DataFrame(result_rows)
    print(result_df.to_string())
    result_df.to_csv(output_file, index=False)
    return result_df
