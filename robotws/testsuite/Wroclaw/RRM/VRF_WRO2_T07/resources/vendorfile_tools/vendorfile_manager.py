import vendorfile_modifier as vfm
from taf.sbts.oam.coam.admin.interface import admin
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.decorators import logged_keyword


@logged_keyword
def download_default_vendorfile(local_path):
    """
    Downloads the default vendor file from the BTS into local_path

    local_path - the directory to which the vendor file should be downloaded.
    """
    admin_client = admin()
    oam_connection = admin_client.connect_to(name="vendorfile_connection")
    admin_client.download_vendor_file(target_file_name=f"{local_path}/vendor_lte.xml", connection=oam_connection)
    admin_client.teardown_admin(oam_connection)


@logged_keyword
def modify_vendorfile(local_path, filter_criteria, data_to_be_modified, xml_path=None):
    """
    Modifies locally-saved vendor file based on provided criteria.

    local_path - path to the local directory containing vendor_lte.xml.
    filter_criteria - a dictionary used to filter the xml file for specific passages.
        E.g. filter_criteria = {"bbHwVariant": "ABIP", "l1PoolType": "NR_L1Pool_Thor_FDD_FR1_CPRI", "csSize": "48"}
    data_to_be_modified - dictionary of parameters and values to which they should be modified within the filtered file
        E.g. data_to_be_modified = {"maxNumLayerPrbUlL1Sp": "648",
                                    "maxNumStreamPrbUlL1Sp": "648"}
    xml_path - a "xml path" to the desired parameters to further narrow down the desired area of changes
    """
    filepath = f"{local_path}/vendor_lte.xml"
    vfm.modify_vendor_file(filter_criteria, data_to_be_modified, filepath, xml_path)


@logged_keyword
def upload_vendorfile(local_path, perform_commissioning=True, scf_path=None):
    """
    Uploads a locally-saved vendor file onto the BTS

    local_path - local_path - path to the local directory containing vendor_lte.xml.
    perform_commissioning - whether to perform full BTS commissioning
    scf_path - scf file to be commissioned. If left as None, it will reupload the file being currently used.
               Unused if perform_commissioning is false.
    """
    admin_client = admin()
    oam_connection = admin_client.connect_to(name="vendorfile_connection")

    admin_client.set_vendor_file(vendor_file=f"{local_path}/vendor_lte.xml", connection=oam_connection)

    if perform_commissioning:
        if scf_path is None:
            scf_path = admin_client.get_current_scf_file(local_dir_path=local_path, file_name="scf.xml",
                                                         connection=oam_connection)

        admin_client.perform_commissioning(scf_file=scf_path, connection=oam_connection,
                                           skip_parameter_relation_errors=True, timeout=600)

    admin_client.teardown_admin(oam_connection)


@logged_keyword
def reset_vendorfile_to_default(local_path):
    """
    Uploads default vendorfile onto the BTS
    """
    download_default_vendorfile(local_path)
    upload_vendorfile(local_path)


@logged_keyword
def get_xml_path_for_list(listname):
    """
    Find xml path for given list name.
        E.g. get_xml_path_for_list(listname="bbL1SpPrbCapacity")
    """
    ns = vfm.ns
    path = ("{ns}cmData//"
            "{ns}managedObject[@class='NRBTS']//"
            "{ns}list[@name='{list_name}']/".format(ns="{" + ns + "}", list_name=listname))
    return path


@logged_keyword
def get_xml_path_for_parameter(parametername):
    """
    Find xml path for given parameter name.
        E.g. get_xml_path_for_parameter(parametername=bbPoolMode)
    """
    ns = vfm.ns
    path = ("{ns}cmData//"
            "{ns}managedObject[@class='NRBTS']//"
            "{ns}p[@name='{parameter_name}']".format(ns="{" + ns + "}", parameter_name=parametername))
    return path
