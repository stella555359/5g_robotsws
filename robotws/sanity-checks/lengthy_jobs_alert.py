import argparse
import time

from gitlab import Gitlab
from taf.monitoring.alertmanager import Alert, AlertManager
from taf.tools.gitlab_stats import GitlabData


def prepare_parser():
    # type: () -> argparse.ArgumentParser
    parser = argparse.ArgumentParser(description="Script for posting alerts about lengthy dry-run CI/CD jobs")
    parser.add_argument('--threshold', help='Threshold for job duration in seconds. Default: 14400',
                        default=14400, type=int)
    parser.add_argument('--gitlab_token', help='Gitlab token', required=True, type=str)
    return parser


def post_alert(alert_manager, job):
    duration_string = time.strftime("%Hh:%Mm:%Ss", time.gmtime(round(job.duration)))
    url = 'https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/jobs/{}'.format(job.id)

    alert = Alert()
    alert.add_name('robotws lengthy dry-run job')
    alert.add_status('firing')
    alert.add_generator_url(url)
    alert.add_label('severity', 'minor')
    alert.add_label('stage', job.stage)
    alert.add_label('name', job.name)
    alert.add_annotation('summary', 'job running for {}'.format(duration_string))
    alert.add_label('url', url)
    alert.set_ends_at('+1h')
    alert_manager.post_alerts(alert)

    print('{:>12} | {:^15} | {:<32}\t=> {}'.format(duration_string, job.stage, job.name, url))


if __name__ == '__main__':
    cli_args_parser = prepare_parser()
    args = cli_args_parser.parse_args()

    manager = AlertManager('http://alertmanager.taf.nsn-rdnet.net', port=None)
    data = GitlabData(project_id='12805', token=args.gitlab_token)
    jobs = data.get_jobs('running')
    lengthy_jobs = [j for j in jobs if ('dry-run' in j.stage) and (j.duration > args.threshold)]
    if lengthy_jobs:
        print('Sending alerts regarding jobs:')
        for j in lengthy_jobs:
            post_alert(manager, j)
    else:
        print('Nothing to report!')
