import re
import os
import pkgutil
import importlib
import subprocess


BTS_config = [
    {
        "cellid": "167215105",
        "pci": "577",
        "NRCELL_id": "NRCELL-0",
        "Cell_type": "NR_FDD",
    },
    {
        "cellid": "191283201",
        "pci": "574",
        "NRCELL_id": "NRCELL-1",
        "Cell_type": "NR_FDD",
    },
    {
        "cellid": "191283202",
        "pci": "575",
        "NRCELL_id": "NRCELL-2",
        "Cell_type": "NR_TDD",
    },
    {
        "cellid": "191283203",
        "pci": "576",
        "NRCELL_id": "NRCELL-3",
        "Cell_type": "NR_TDD",
    },
]


def is_pandas_installed():
    return bool(pkgutil.find_loader('pandas'))


def install_and_import_pandas():
    if not is_pandas_installed():
        install_package('pandas')
    return importlib.import_module('pandas')


def install_package(package):
    try:
        subprocess.call(['pip', 'install', '-U', 'numpy', package])
    except Exception as e:
        raise (AssertionError("Error installing package " + str(e)))


def getTputFromVduSyslog(log_path, outputf="output.txt"):
    pd = install_and_import_pandas()
    DL_pattern = re.compile(
        r"L2Lo.+nrCellId (\d+).+TBS\|MacCe\|StatusPdu\|DataPdu: (\d+)\|(\d+)\|(\d+)\|(\d+)"
    )
    UL_pattern = re.compile(
        r"L2Lo.+UL: (\d+) Bytes received. \((\d+) rlcPduBytes, (\d+) rlcPdus (\d+) zeroTbs\), nrCellIdentity (\d+)"
    )
    DL_result_list, UL_result_list = [], []
    with open(log_path, "r") as f:
        while True:
            line = f.readline()
            if line:
                if "L2Lo" in line:
                    if "DataPdu" in line:
                        DL_result = DL_pattern.findall(line, re.I)
                        if DL_result:
                            cellid = DL_result[0][0]
                            for cell in BTS_config:
                                if cell["cellid"] == cellid:
                                    nrcellid = cell["NRCELL_id"]
                                    break
                            tbs = int(DL_result[0][1])
                            macce = int(DL_result[0][2])
                            statusPdu = int(DL_result[0][3])
                            dataPdu = int(DL_result[0][4])
                        row_dict = {
                            "NRCELL-ID": nrcellid,
                            "TBS": tbs,
                            "MacCe": macce,
                            "StatusPdu": statusPdu,
                            "DataPdu": dataPdu,
                        }
                        DL_result_list.append(row_dict)
                    if "UL" in line:
                        UL_result = UL_pattern.findall(line, re.I)
                        if UL_result:
                            cellid = UL_result[0][4]
                            for cell in BTS_config:
                                if cell["cellid"] == cellid:
                                    nrcellid = cell["NRCELL_id"]
                                    break
                            bytes_received = int(UL_result[0][0])
                            rlcPduBytes = int(UL_result[0][1])
                            rlcPdus = int(UL_result[0][2])
                            zeroTbs = int(UL_result[0][3])
                            UL_result_list.append(
                                {
                                    "NRCELL-ID": nrcellid,
                                    "Bytes_received": bytes_received,
                                    "rlcPduBytes": rlcPduBytes,
                                    "rlcPdus": rlcPdus,
                                    "zeroTbs": zeroTbs,
                                }
                            )
            else:
                break
    output_dir = os.path.dirname(log_path)
    output_file = os.path.join(output_dir, outputf)
    f = open(output_file, "w")
    if DL_result_list:
        dl_df = pd.DataFrame(
            DL_result_list, index=list(
                range(
                    0, len(DL_result_list))))
        dl_data = dl_df.groupby("NRCELL-ID").sum()
        # print(dl_data.loc['NRCELL-4', 'DataPdu'])
        print(f"DL Tput from syslog:\n{dl_data}")
        print(f"DL Tput from Syslog:\n {dl_data}\n", file=f)
    if UL_result_list:
        ul_df = pd.DataFrame(
            UL_result_list, index=list(
                range(
                    0, len(UL_result_list))))
        ul_data = ul_df.groupby("NRCELL-ID").sum()
        print(f"UL Tput from syslog:\n{ul_data}")
        print(f"UL Tput from Syslog:\n {ul_data}\n", file=f)
    f.close()


def getDLCsvCouterSum(files_list):
    pd = install_and_import_pandas()
    dfs = [pd.read_csv(file, low_memory=False) for file in files_list]
    combined_df = pd.concat(dfs, ignore_index=True)
    df1 = combined_df[["physCellId", "lcId", "rlcAmDc", "macLength"]]
    data = (
        df1[df1["rlcAmDc"] == "DATA"].groupby(
            ["physCellId", "lcId", "rlcAmDc"]).sum()
    )
    # data = data.reset_index()
    print(data.to_dict())
    return data.to_dict()


def getMacLengthByPhysCellIdAndLcId(csv_data_dict, physCellId, lcId):
    assert csv_data_dict, "[ERROR] The csv_data_dict is incorrect or empty."
    key_to_check = (int(physCellId), int(lcId), "DATA")
    macLength = 0.0
    if key_to_check in csv_data_dict["macLength"]:
        macLength = csv_data_dict["macLength"][(
            int(physCellId), int(lcId), "DATA")]
        print(macLength)
    # assert macLength, "[ERROR] macLength id NOT filtered: {}".format(macLength)
    return macLength


if __name__ == "__main__":
    log_folder = "/home/ute/logs/"
    file_1 = f"{log_folder}MacSubPduTxAm18.csv"
    file_2 = f"{log_folder}MacSubPduTxAm18_1.csv"
    file_3 = f"{log_folder}MacSubPduTxAm18_2.csv"
    files_list = [file_1, file_2, file_3]
    csv_data_dict = getDLCsvCouterSum(files_list)
    getMacLengthByPhysCellIdAndLcId(csv_data_dict, 577, 6)
