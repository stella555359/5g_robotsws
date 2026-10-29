from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value('${tl}')

GNB_SW_DOWNLOAD_INFO = {
    'common_web_service_hz': (
        'https://artifactory-hz1.int.net.nokia.com/artifactory/'
        'mn-cosi-sran-central-public-remote/build/'
    ),
    'common_web_service': [
        'https://10.57.169.252/build/',
        'https://artifactory-espoo2.int.net.nokia.com/artifactory/'
        'mn-cosi-sran-central-public-local/build/',
        'https://artifactory-hz1.int.net.nokia.com/artifactory/'
        'mn-cosi-sran-central-public-remote/build/',
    ]
}

TL_SCOUT_MAPPING_INFO = {
    '7_5_UTE4G402T612': '7_5_UTE5G402T599_4G',
    '7_5_UTE4G402T609': '7_5_UTE5G402T600_4G',
    '7_5_UTE4G402T611': '7_5_UTE5G402T596_4G',
    '7_5_UTE4G402T610': '7_5_UTE5G402T315_4G',
    '7_5_UTE4G402T613': '7_5_UTE5G402T312_4G',
    '7_5_UTE5G402T312': '7_5_UTE5G402T312_5G-1',
    '7_5_UTE5G402T598': '7_5_UTE5G402T312_5G-2'
}

artifactory = (
    "cmVmdGtuOjAxOjE3OTM4NjQ4MzE6VDhEWGd5U1MwMUsxYmFjdjVUYzFoNUlVRmdu"
)
