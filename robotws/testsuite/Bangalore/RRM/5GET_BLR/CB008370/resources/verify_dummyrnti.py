import pkgutil
import subprocess
import importlib

# list_pdcch_rnti = []
# initialize a null list
unique_list = []

PASS = 1
FAIL = 0


def install_package(package):
    try:
        subprocess.call(['pip', 'install', '-U', 'numpy', package])
    except Exception as e:
        raise (AssertionError("Error installing package " + str(e)))


def is_pandas_installed():
    return bool(pkgutil.find_loader('pandas'))


def install_and_import_pandas():
    print("pandas library installation")
    if not is_pandas_installed():
        install_package('pandas')
    return importlib.import_module('pandas')


def check_dummy_rnti(csv_file, rnti):
    """
    This function will Get the DlData_PdcchSendReq on slot 0, 5, 10 and 15.
    Get the RNTI values present in PDCCH and compare it with the CRNTI value of actual UEs attached.
    SI-RNTI are ignored and if there is any RNTI which is present other than actual CRNTI , then its considered as
    dummy RNTI
    """
    dummy_rnti = []
    pd = install_and_import_pandas()
    # Reading converted csv file and formatting it
    data = pd.read_csv(csv_file)
    df = pd.DataFrame(data)
    df = df.rename(columns={'_ws.col.info': 'info'})
    df = df.rename(columns={'3gpp.sfn': 'sfn'})
    df = df.rename(columns={'3gpp.slot': 'slot'})
    df = df.rename(columns={'3gpp.rnti': 'rnti'})
    df_pdcch = df[df['info'].str.contains("DlData_PdcchSendReq")]
    print(df_pdcch)
    # Get slot 0,5,10 and 15 slot data
    df_pdcch_slot_051015 = df_pdcch.loc[
        (df_pdcch.slot == 0) | (df_pdcch.slot == 5) | (df_pdcch.slot == 10) | (df_pdcch.slot == 15)]
    count = len(df_pdcch_slot_051015.rnti.unique())
    for i in range(0, count):
        list_pdcch_rnti = df_pdcch_slot_051015.rnti.unique()[i].split(",")
        for x in list_pdcch_rnti:
            if x == '65535':
                continue
            if x not in unique_list:
                unique_list.append(x)
    rnti_list = [rnti]
    print("RNTI and filtered PDCCH_rnti ", rnti_list, unique_list, len(unique_list), len(rnti_list))
    if len(unique_list) == (len(rnti_list)+1):
        dummy_rnti = set(unique_list) - set(rnti_list)
    if len(dummy_rnti) == 1:
        print("PASS", len(dummy_rnti))
        return PASS
    else:
        print("Dummy RNTI not present", len(dummy_rnti))
        return FAIL
