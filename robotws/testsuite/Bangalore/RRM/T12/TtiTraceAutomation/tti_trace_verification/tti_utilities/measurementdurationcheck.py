import pandas as pd
import logging
import tti_utilities.config as config
from tti_utilities.variables import METADATA_COLUMNS, MAX_SFN

mlogger = logging.getLogger("mlogger")


def MeasurementDurationCheck(ssgEvaluation, thresholds):
    # print(ssgEvaluation)
    df = ssgEvaluation
    # df.insert(
    #     0, "excel_row", range(2, len(df) + 2)
    # )  # Inserts column A with true Excel rows
    sfn_df = pd.DataFrame(
        columns=[
            METADATA_COLUMNS[0],
            METADATA_COLUMNS[1],
            METADATA_COLUMNS[2],
            "rnti",
            "starthfnTickCount",
            "startRange",
            "endhfnTickCount",
            "endRange",
        ]
    )
    all_meta_changes_successful = True  # Track success

    # MAX_SFN = 1024
    def get_sfn_diff(current_val, next_val):
        return abs(next_val - current_val) % MAX_SFN

    # for i in range(len(df) - 1):  # stop at second-last row
    for i in range(len(df)):  # stop at second-last row
        if i != (len(df) - 1):
            current = df.iloc[i]
            next_row = df.iloc[i + 1]
            # mlogger.info(f"Processing row {i+2}: {current.to_dict()}")
            mlogger.info(f"Processing row {current['excel_row']}: {current.to_dict()}")

            # if current["isEligibleSwitching"] == 1:

            if current["evaluationResult"] == 0:
                if current["currentSssg"].lower() == "dense":
                    expected_next = (
                        current[METADATA_COLUMNS[1]]
                        + thresholds["measurementDurationToSparseSssg"] // 10
                    ) % MAX_SFN
                else:
                    expected_next = (
                        current[METADATA_COLUMNS[1]]
                        + thresholds["measurementDurationFromSparseSssg"] // 10
                    ) % MAX_SFN
                actual_next = next_row[METADATA_COLUMNS[1]]
                mlogger.info(
                    f"Expected next sfn: {expected_next}, Actual next sfn: {actual_next}"
                )
                if expected_next == actual_next:
                    # mlogger.info(f"Row {i+2} → Row {i+2+1}: Correct sfn change\n")
                    mlogger.info(
                        f"Row {current['excel_row']} → Row {current['excel_row']+1}: Correct sfn change\n"
                    )
                else:
                    # mlogger.warning(f"Row {i+2} → Row {i+2+1}: sfn change failed\n")
                    mlogger.warning(
                        f"Row {current['excel_row']} → Row {current['excel_row']+1}: sfn change failed\n"
                    )

                    all_meta_changes_successful = False

            elif current["evaluationResult"] == 1:
                current_sfn = current["sfn"]
                current_hfn = current[METADATA_COLUMNS[0]]

                next_sfn = next_row["sfn"]
                next_hfn = next_row[METADATA_COLUMNS[0]]
                sfn_df.loc[len(sfn_df)] = {
                    METADATA_COLUMNS[0]: current[METADATA_COLUMNS[0]],
                    METADATA_COLUMNS[1]: current[METADATA_COLUMNS[1]],
                    METADATA_COLUMNS[2]: current[METADATA_COLUMNS[2]],
                    "rnti": current["rnti"],
                    "starthfnTickCount": current_hfn,
                    "endhfnTickCount": next_hfn,
                    "startRange": current_sfn,
                    "endRange": next_sfn,
                }
                mlogger.info(
                    f"""
                    Row {i+1} (set=1): sfn Range recorded: {(int(current_hfn),
                                                             int(current_sfn))} to {(int(next_hfn),
                                                                                     int(next_sfn))}\n
                    """
                )
        else:
            # check if the last row has a switch
            current = df.iloc[i]
            if current["evaluationResult"] == 1:
                current_sfn = current["sfn"]
                current_hfn = current[METADATA_COLUMNS[0]]
                next_sfn = pd.NA
                next_hfn = pd.NA
                sfn_df.loc[len(sfn_df)] = {
                    METADATA_COLUMNS[0]: current[METADATA_COLUMNS[0]],
                    METADATA_COLUMNS[1]: current[METADATA_COLUMNS[1]],
                    METADATA_COLUMNS[2]: current[METADATA_COLUMNS[2]],
                    "rnti": current["rnti"],
                    "starthfnTickCount": current_hfn,
                    "endhfnTickCount": next_hfn,
                    "startRange": current_sfn,
                    "endRange": next_sfn,
                }
                mlogger.info(
                    f"""Row {i+1} (set=1): sfn Range recorded:
                    {(int(current_hfn), int(current_sfn))} to {((next_hfn), (next_sfn))}\n"""
                )
    log_file_path = f"{config.LOG_FOLDER}/sfnRange.log"
    with open(log_file_path, "w", encoding="utf-8") as f:
        f.write("Logging SFN range DataFrame:\n")
        f.write(sfn_df.to_string(index=False))
        f.write("\n\n")  # Add spacing between logs

    return all_meta_changes_successful, sfn_df
