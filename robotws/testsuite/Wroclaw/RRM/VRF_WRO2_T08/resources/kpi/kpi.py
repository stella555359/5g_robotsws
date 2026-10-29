from .parsers import bip_parser, tti_parser


def parse_tti(log_path, kpi_names):
    tti_parser.reset()
    return tti_parser.parse(logfile=log_path, stat_names=kpi_names)


def parse_bip(log_path, kpi_names):
    bip_parser.reset()
    return bip_parser.parse(logfile=log_path, stat_names=kpi_names)
