from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')

RF_FACTORY_SW_INFO = {
        'AQQY_username': 'serviceuser',
        'AQQY_password': 'v160rWp/6qpX/RQjmnaupqP+FBV2/f7bgiwMI8+cpEY=',
        'factory_img_file': 'rfsw-package-aqql_0x1E24FEEC.tar',
        'file_number': '0x1E24FEEC',
        'build_version': 'RF.CTA6.22R2.20220520.005',
        'build_name': 'RF.CTA6.22R2.20220520.005'
}

RF_SW_DOWNLOAD_INFO = {
        'svn_path': 'https://svne1.ext.net.nokia.com/isource/svnroot/',
        'svn_username': 'y2fang',
        'svn_password': 'Fy64622759@',
        'path_to_file': 'BTS_D_RF_3/CTA6/tags/RF.CTA6.22R2.20220520.005/C_Element/SE_RFM/SS_CTA6/Target/'
}

GNB_SW_DOWNLOAD_INFO = {
        'common_web_service_hz': 'https://artifactory-hz1.int.net.nokia.com/artifactory/'
        'mn-cosi-sran-central-public-remote/build',
        'common_web_service': ['https://10.57.169.252/build/',
                               'https://artifactory-espoo2.int.net.nokia.com/artifactory/'
                               'mn-cosi-sran-central-public-local/build/',
                               'https://lterel.es-si-s3-z2.eecloud.nsn-net.net/build/',
                               'https://lterel.es-si-s3-z4.eecloud.nsn-net.net/build/']

}

test_pc_ip = tl.test_pc.default_ssh_connection_details.addr
print(test_pc_ip)
test_pc_username = tl.test_pc.default_ssh_connection_details.username
test_pc_password = tl.test_pc.default_ssh_connection_details.password
lmp_object = tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection
gnb_ip = lmp_object.addr
gnb_username = lmp_object.username
gnb_password = lmp_object.password
