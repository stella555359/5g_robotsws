"""
Project Name : TTI Trace Validation
Author       : Hari Somu
Created On   : November 4, 2025
Version      : 1.0.0
Description  : Initial release of TTI Trace Validation. This script Unzips the TTI Trace zip file
               Decodes all the TTI Traces in each subfolder in to Event CSV Files like [dlFdSchedData ]
               And Runs Validation logic to ensure whether a switch happened is a DTX or a NON-DTX All logs
               will be stored in the UNZIPPED folder in the same locaiton.
Contact      : hari.somu@nokia.com
"""

import sys
import os
import setup_path
import io
import tti_utilities.config as config
from contextlib import redirect_stdout
from pathlib import Path
import subprocess
import pkg_resources

# from utils.loader import format_aligned, color_text, LoadThresholdsFromConfigFile, load_dataframes, process_dataframes
from tti_utilities.loader import (
    format_aligned,
    color_text,
    LoadThresholdsFromConfigFile,
    load_dataframes,
)
from tti_utilities.variables import (
    threshold_mappings,
    METADATA_COLUMNS,
    save_thresholds,
    threshold_mappings_for_vonr,
)
from tti_utilities.measurementdurationcheck import MeasurementDurationCheck
from tti_utilities.threshold_check import row_passes_threshold

# from cli.interface import get_args, blinking_cursor, type_out
from cli.interface import type_out

# from utils import combine_csvs
from tti_utilities.logger_setup import create_log_folder, setup_named_logger
from tti_utilities.safe_helper import safe_dict_get, safe_iloc
from tti_utilities.sfn_utils import record_sfn_range
from tti_utilities.ulcheck import ulcheck, get_number_of_switches_in_UL_DCI
from tti_utilities.dlcheck import dlcheck, get_number_of_switches_in_DL_DCI
from tti_utilities.extraction_utils import (
    run_post_processing_script,
)

# from tti_utilities.input_parsing_utils import classify_path

#  setting up the spinner
#  def spinner():
#      while not done:
#          for ch in '|/-\\':
#              sys.stdout.write(f'\rProcessing... {ch}')
#              sys.stdout.flush()
#              time.sleep(0.1)
#  done = False
#  t = threading.Thread(target=spinner)
#  t.start()

_ = setup_path


def install_requirements():
    """Install packages from requirements.txt if not already installed."""
    # requirements.txt is in the same folder as main.py
    req_file = Path(__file__).parent / "requirements.txt"

    if not req_file.exists():
        print(f"Missing: {req_file}")
        sys.exit(1)

    # Read requirements and extract package names
    with open(req_file, "r") as f:
        req_lines = [
            line.strip() for line in f if line.strip() and not line.startswith("#")
        ]

    required_packages = []
    for line in req_lines:
        # Extract package name (remove ==, <, >, ;, [extras])
        pkg = (
            line.split("==")[0].split("<")[0].split(">")[0].split(";")[0].split("[")[0]
        )
        if pkg and "@" not in pkg:  # Skip URLs
            required_packages.append(pkg.lower())

    # Check what's missing
    installed = {dist.key.lower() for dist in pkg_resources.working_set}
    missing = [pkg for pkg in required_packages if pkg not in installed]
    print(missing)
    if missing:
        print(f"Installing missing packages from requirements.txt: {missing}")
        try:
            subprocess.check_call(
                [sys.executable, "-m", "pip", "install", "-r", str(req_file)],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            )
            print("Requirements installed successfully.")
        except subprocess.CalledProcessError as e:
            print(f"Failed to install requirements: {e}")
            sys.exit(1)
    else:
        print("All requirements already satisfied.")


# def sssgValidation(
#     ZIP_PATH=None,
#     PCAP_FILES=None,
#     ALREADY_DECODED=None,
#     FORMAT="eventCsv",
#     SCF_FILE=None,
#     DESTINATION_PATH=None,
#     UNZIPPED=None,
# ):


def sssgValidation(directory, scf_file):
    install_requirements()
    # logic here continues after getting all the required files

    def run_validation_script(subfolder, XML_THRESHOLD_FILE):
        #  Create a buffer to hold all console output
        console_buffer = io.StringIO()

        #  Redirect stdout and stderr to the buffer
        sys.stdout = console_buffer
        sys.stderr = console_buffer
        try:

            #  files_directory = args.files_dir
            #  XML_THRESHOLD_FILE = args.threshold
            #  COMBINE_FLAG = args.combine
            #  if COMBINE_FLAG:
            #      combine_csvs.run(files_directory)

            #  🔧 CONFIGURATION
            config.LOG_FOLDER = create_log_folder(
                base_dir=subfolder
            )  # Create and store log folder in config
            config.FILES_DIRECTORY = (
                subfolder  # setting up the files directory globally
            )
            mlogger = setup_named_logger(
                "mlogger", f"{config.LOG_FOLDER}/measurementDurationCheck.log"
            )
            vlogger = setup_named_logger(
                "vlogger", f"{config.LOG_FOLDER}/verification.log"
            )

            dataframes = (
                load_dataframes()
            )  # loading all the dataframes into the dataframes variable

            if dataframes == "fatal":
                return "Test Failed"

            def get_rnti_and_type(dataframes):
                rntis = {}
                unique_rnti = (
                    safe_dict_get(
                        dataframes,
                        "ssgEvaluation",
                        logger=mlogger,
                        error_message="Retrieving Key sssgEvaluationFailed",
                    )["rnti"]
                    .unique()
                    .tolist()
                )
                # print("printing unique rnti")
                print(unique_rnti)
                for rnti in unique_rnti:
                    df = safe_dict_get(
                        dataframes,
                        "ssgEvaluation",
                        logger=mlogger,
                        error_message="Retreieved Key ssgEvaluation FAILED",
                    )
                    matches = df[(df["rnti"] == rnti) & df["evaluationResult"] == 1]
                    if len(matches) == 0:
                        print(f"Skipping rnti {rnti}. Since it is having zero switches")
                        unique_rnti.remove(rnti)
                ulFdSched = safe_dict_get(
                    dataframes,
                    "ulFdSched",
                    logger=mlogger,
                    error_message="Retriveing ulFdSched failed",
                )  # open fd schedule and get what type it is
                print(f"Printing unique rnti's\n {unique_rnti}")
                for rnti in unique_rnti:
                    try:
                        value = ulFdSched[ulFdSched["rnti"] == rnti].iloc[1][
                            "supportOfRedCap"
                        ]
                    except (IndexError, KeyError):
                        try:
                            value = ulFdSched[ulFdSched["rnti"] == rnti].iloc[0][
                                "supportOfRedCap"
                            ]
                        except (IndexError, KeyError):
                            type_out(
                                "\nThere is no row 1 in ulFdSchedData. Unable to decide the Rnti Type"
                            )
                            sys.exit(1)
                    # except Exception as e:
                    #     type_out(
                    #         f"{e}\nThere is no row 1 in ulFdSchedData. Unable to decide the Rnti Type"
                    #     )
                    #     return
                    rntis[rnti] = int(value)
                return rntis

            rntis = get_rnti_and_type(dataframes)
            print(rntis)
            print(f"Found {len(rntis)} UE's")
            redcap_decision = {0: "NONREDCAP", 1: "REDCAP"}

            # adding logic to get the sfn recorder ranges

            # record_sfn_range(df=dataframes['sssgSwitchingState'])
            rnti_failed = []
            for rnti in rntis:
                print(f"\nProcessing for rnti {rnti} in subfolder {subfolder}")
                #  print("i am in loop")
                dataframes = load_dataframes(rnti)
                UE_TYPE = redcap_decision.get(rntis[rnti], "unknown")
                print(UE_TYPE)
                if UE_TYPE == "unknown":
                    break  # exit
                type_out(f"\nUE-TYPE : {UE_TYPE}, RNTI {rnti}")
                mlogger.info(f"RECEVIED UE-TYPE IS {UE_TYPE}, RNTI {rnti}")
                TARGET_LIST_NAME = (
                    "sssgSwitchingRedCap" if UE_TYPE == "REDCAP" else "sssgSwitching"
                )  # TARGET_LIST_NAME
                mlogger.info(
                    f"Target Thresholds I am searching for in the given configuration file is {TARGET_LIST_NAME}"
                )

                thresholds = LoadThresholdsFromConfigFile(
                    XML_THRESHOLD_FILE=XML_THRESHOLD_FILE,
                    TARGET_LIST_NAME=TARGET_LIST_NAME,
                )  # measurementDurationFromSparseSssg measurementDurationToSparseSssg

                voNrFlag = False
                if "voipStateData" in dataframes:
                    voipStateData = dataframes["voipStateData"]
                    if len(voipStateData) >= 1:
                        thresholds_mappings_to_check = threshold_mappings_for_vonr[
                            UE_TYPE
                        ]
                        print("\nConsidering VoNR thresholds since UE is Vonr\n")
                        voNrFlag = True
                    else:
                        thresholds_mappings_to_check = threshold_mappings[UE_TYPE]
                        print("\nConsidering NoVoNR thresholds since UE is NoVonr\n")

                else:
                    thresholds_mappings_to_check = threshold_mappings[UE_TYPE]
                    print("\nConsidering NoVoNR thresholds since UE is NoVonr\n")

                temporary_string = f"{rnti}_{UE_TYPE}"
                save_thresholds(thresholds, temporary_string, f"{config.LOG_FOLDER}")

                mlogger.info(f"{thresholds_mappings_to_check}")
                mlogger.info(
                    f"Measurement DurationCheck : DenseToSparse -\
                        {thresholds['measurementDurationToSparseSssg']}ms\
                            SparseToDense -{thresholds['measurementDurationFromSparseSssg']}ms"
                )
                ssgEvaluation = safe_dict_get(
                    dataframes,
                    "ssgEvaluation",
                    logger=mlogger,
                    error_message="Retrieving Key sssgEvaluationFailed",
                )
                MeasurementDurationFlag, sfn_df = MeasurementDurationCheck(
                    ssgEvaluation=ssgEvaluation, thresholds=thresholds
                )  # calling step0 measurement duration check
                if MeasurementDurationFlag:
                    type_out("Measurement DurationCheck : )", end="")
                    type_out(
                        "DenseToSparse - {thresholds['measurementDurationToSparseSssg']}",
                        end="",
                    )
                    type_out(
                        "SparseToDense - {thresholds['measurementDurationFromSparseSssg']}ms"
                    ),
                    color_text("Test Passed", "pass"),
                    mlogger.info("Test passed")
                else:
                    type_out("Measurement DurationCheck : )", end="")
                    type_out(
                        "DenseToSparse - {thresholds['measurementDurationToSparseSssg']}",
                        end="",
                    )
                    type_out(
                        "SparseToDense - {thresholds['measurementDurationFromSparseSssg']}ms"
                    ),
                    color_text("Test Failed", "failed"),
                    mlogger.error("Test Failed")
                #  df = dataframes['ssgEvaluation'] # redundant steps that i will fix later
                df = safe_dict_get(
                    dataframes,
                    "ssgEvaluation",
                    on_error="exit",
                    logger=mlogger,
                    also_print=True,
                )
                #  filtered = df[df['evaluationResult'] == 1]  #  🔍 Filter and evaluate rows
                # print(df)
                # filtered = safe_filter(
                #     df,
                #     lambda d: (df["evaluationResult"] == 1) & (d["rnti"] == rnti),
                #     error_message="No columns with filter evaluationResult == 1 or else the key doesn't exist.",
                # )
                try:
                    filtered = df[(df["evaluationResult"] == 1) & (df["rnti"] == rnti)]
                    if filtered.empty:
                        type_out(
                            "No columns with filter evaluationResult == 1 or else the key doesn't exist."
                        )
                        continue
                except Exception as e:
                    type_out(
                        f"{e}\nNo columns with filter evaluationResult == 1 or else the key doesn't exist."
                    )
                    continue
                # sfn_recorded_range = record_sfn_range(
                #     df=dataframes["sssgSwitchingState"],
                #     output_file=f"{config.LOG_FOLDER}/recorded_sfn_range.csv",
                # )
                # print(filtered)
                vlogger.info(f"Found {len(filtered)} switches")
                type_out(f"\nFound {len(filtered)} switches")
                #  resultdf = pd.DataFrame(columns=METADATA_COLUMNS + ["Result"])

                ul_switches = get_number_of_switches_in_UL_DCI(dataframes, sfn_df)
                dl_switches = get_number_of_switches_in_DL_DCI(dataframes, sfn_df)

                if (ul_switches == len(filtered)) and (dl_switches == len(filtered)):
                    sfn_recorded_range = None
                else:
                    sfn_recorded_range = record_sfn_range(
                        df=dataframes["sssgSwitchingState"],
                        output_file=f"{config.LOG_FOLDER}/recorded_sfn_range.csv",
                    )
                buffer = io.StringIO()  # buffer for the loop
                does_even_one_switch_fail = False
                with redirect_stdout(buffer):
                    #  for i in tqdm(range(len(filtered))):
                    failed_switches = []
                    for i in range(len(filtered)):
                        #  row = filtered.iloc[i]
                        row = safe_iloc(
                            filtered, i, error_message="Retrieveing switch rows failed"
                        )  # Gets df.iloc[0]['name'], exits if it fails
                        if row is None:
                            continue
                        switchNumber = i + 1
                        #  type_out switch 1
                        type_out(f"\nSwitch {switchNumber} ", end="")
                        vlogger.info(f"\nSwitch {switchNumber}")
                        switch = row["currentSssg"].strip().lower()
                        #  switch = safe_row_get(row=row, col='currentSssg', strip=True, lower=True)
                        type_out(
                            "DenseToSparse" if switch == "dense" else "SparseToDense"
                        )
                        if sfn_recorded_range is not None:
                            type_out(
                                sfn_recorded_range.iloc[[i]].to_string(index=False)
                            )
                        print()

                        # cqi_threshold_flag, buffer_from_cqi = row_passes_cqi(
                        #     row, thresholds
                        # )
                        # (
                        #     type_out(
                        #         format_aligned(
                        #             "cqiThreshold Check:",
                        #             color_text("Test Passed", "pass"),
                        #         )
                        #     )
                        #     if cqi_threshold_flag
                        #     else type_out(
                        #         format_aligned(
                        #             "cqiThreshold Check:",
                        #             color_text("Test Failed", "fail"),
                        #         )
                        #     )
                        # )
                        # type_out(buffer_from_cqi)

                        threshold_flag, buffer_from_threshold = row_passes_threshold(
                            row, thresholds, thresholds_mappings_to_check, voNrFlag
                        )
                        (
                            type_out(
                                format_aligned(
                                    "Threshold Check:",
                                    color_text("Test Passed", "pass"),
                                )
                            )
                            if threshold_flag
                            else type_out(
                                format_aligned(
                                    "Threshold Check:",
                                    color_text("Test Failed", "fail"),
                                )
                            )
                        )  # type_out to the console whether check passed or failed
                        type_out(buffer_from_threshold)
                        sfn_range_df = sfn_df[
                            (sfn_df[METADATA_COLUMNS[0]] == row[METADATA_COLUMNS[0]])
                            & (sfn_df[METADATA_COLUMNS[1]] == row[METADATA_COLUMNS[1]])
                            & (sfn_df[METADATA_COLUMNS[2]] == row[METADATA_COLUMNS[2]])
                        ]

                        ul_flag, buffer_from_ul = ulcheck(
                            switchNumber, sfn_range_df, dataframes, sfn_recorded_range
                        )
                        (
                            type_out(
                                format_aligned(
                                    "UL Check:", color_text("Test Passed", "pass")
                                )
                            )
                            if ul_flag
                            else type_out(
                                format_aligned(
                                    "UL Check:", color_text("Test Failed", "failed")
                                )
                            )
                        )  # type_out to the console whether check passed or failed
                        type_out(buffer_from_ul)

                        #  dl_flag = dlcheck(switchNumber, sfn_range_df, dataframes)

                        dl_flag, buffer_from_dl = dlcheck(
                            switchNumber, sfn_range_df, dataframes, sfn_recorded_range
                        )
                        (
                            type_out(
                                format_aligned(
                                    "DL Check:", color_text("Test Passed", "pass")
                                )
                            )
                            if dl_flag
                            else type_out(
                                format_aligned(
                                    "DL Check:", color_text("Test Failed", "failed")
                                )
                            )
                        )  # type_out to the console whether check passed or failed
                        type_out(buffer_from_dl)
                        # print("theshold_flag", threshold_flag)
                        # print("ul_flag", ul_flag)
                        # print("dl flag", dl_flag)

                        overall_result_flag = threshold_flag and (ul_flag or dl_flag)
                        if overall_result_flag is False:
                            failed_switches.append(i + 1)
                            does_even_one_switch_fail = True
                        (
                            type_out(
                                format_aligned(
                                    "Overall Result:", color_text("Test Passed", "pass")
                                )
                            )
                            if overall_result_flag
                            else type_out(
                                format_aligned(
                                    "Overall Result:",
                                    color_text("Test Failed", "failed"),
                                )
                            )
                        )

                        # type_out to the console whether check passed or failed

                type_out(buffer.getvalue())
                buffer.close()
                (
                    type_out(
                        format_aligned(
                            "Final Result:", color_text("Test Failed", "failed")
                        )
                    )
                    if does_even_one_switch_fail is True
                    or MeasurementDurationFlag is False
                    else type_out(
                        format_aligned(
                            "Final Result:", color_text("Test Passed", "pass")
                        )
                    )
                )  # type_out to the console whether check passed or failed
                if len(failed_switches) > 0:
                    type_out(format_aligned(f"Failed switches are {failed_switches}"))
                    rnti_failed.append(rnti)
                    # return "Test Failed"
                else:
                    type_out(format_aligned("No switches failed"))
                    # return "Test Passed"

        finally:
            sys.stdout = sys.__stdout__
            sys.stderr = sys.__stderr__

            #  Ensure the folder exists
            os.makedirs("subfolder", exist_ok=True)
            #  Build the full file path
            file_path = os.path.join(config.LOG_FOLDER, "ValidationResult.txt")

            #  Write the buffered output to a file
            with open(file_path, "w", encoding="utf-8") as f:
                f.write(console_buffer.getvalue())

            type_out(console_buffer.getvalue())

        if len(rnti_failed) > 0:
            return "Test Failed"
        else:
            return "Test Passed"

    # Check if directory exists
    if not os.path.isdir(directory):
        print(f"Error: Directory '{directory}' does not exist")
        return False

    # Check if SCF file exists
    if not os.path.isfile(scf_file):
        print(f"Error: SCF file '{scf_file}' does not exist")
        return False

    # Check if SCF file ends with .xml
    if not scf_file.endswith(".xml"):
        print(f"Error: SCF file '{scf_file}' must end with .xml")
        return False

    run_post_processing_script(directory)
    return run_validation_script(directory, scf_file)


if __name__ == "__main__":
    sssgValidation()
