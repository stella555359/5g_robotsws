try:
    from mock import MagicMock
except ImportError:
    from unittest.mock import MagicMock

tl = MagicMock()

# For ute_common_admin usage in on_air_tl_preparation
tl.gnbs[0].cu.oam_http_connection_details.addr = '0.0.0.0'
neighbour_oam = '0.0.0.0'

# For QT
tl.tl_cloud_topology = "dry_run_tl_cloud_topology_name"
tl.gnbs.__getitem__.return_value.cloud_deployment.flavors.__getitem__.return_value.default_vnf_prefix = "dryrun"
tl.gnbs.__getitem__.return_value.vnf_name = 'dryrun'
