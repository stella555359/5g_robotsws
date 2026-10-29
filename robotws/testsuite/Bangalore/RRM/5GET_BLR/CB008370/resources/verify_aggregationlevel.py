import pkgutil
import subprocess
import importlib

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


def check_AL_rnti(csv_file, rnti):
    pd = install_and_import_pandas()
    # Reading converted csv file and formatting it
    data = pd.read_csv(csv_file)
    df = pd.DataFrame(data)
    df = df.rename(columns={'3gpp.rnti': 'rnti'})
    df = df.rename(columns={'DlData_DciInfoL1sw.aggregationLevel': 'aggregationLevel'})
#    df_pdcch = df[df['_ws.col.Info'].str.contains("DlData_PdcchSendReq")]
    df_pdcch_crnti = df.loc[(df.rnti != 65535)]
    len_df_pdcch_crnti = len(df_pdcch_crnti)
    print(df_pdcch_crnti)
    len_df_pdcch_crnti_AL8 = len(df_pdcch_crnti.loc[(df_pdcch_crnti.aggregationLevel == '8')])
    print(len_df_pdcch_crnti_AL8)
    if len_df_pdcch_crnti_AL8 >= 85 * len_df_pdcch_crnti/100:
        print("PASS")
        return PASS
    else:
        print("FAIL")
        return FAIL
