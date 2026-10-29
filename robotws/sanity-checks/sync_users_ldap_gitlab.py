import argparse
import gitlab
import ldap

BASE_DN = 'ou=ultima,o=EEDIR'  # Base domain name in which LDAP should search for

PARSER = argparse.ArgumentParser(description="Script for synchronising LDAP group users with Gitlab project - each "
                                             "LDAP user grants an access on specific access level to Gitlab project. "
                                             "Users which are not included within LDAP group are removed.")
PARSER.add_argument('--ldap_server_url', help='LDAP server URL in which users will be searched for.'
                                              'Default: ldap://eseedir.nsn-net.net',
                    default='ldap://eseedir.nsn-net.net', type=str)
PARSER.add_argument('ldap_login', help='LDAP user record used for accessing LDAP database', type=str)
PARSER.add_argument('ldap_password', help='LDAP password of the user used for accessing LDAP database', type=str)
PARSER.add_argument('--ldap_group', help="LDAP group name from which users should be synced with Gitlab."
                                         "Default: I_EXT_TA_CODE_GUARDS", default='I_EXT_TA_CODE_GUARDS', type=str)
PARSER.add_argument('--gitlab_server', help='Gitlab server URL. Default: https://wrgitlab.int.net.nokia.com/',
                    default='https://wrgitlab.int.net.nokia.com/', type=str)
PARSER.add_argument('gitlab_token', help='Gitlab token of the user which has privileges to add/remove users from the'
                                         'Gitlab project', type=str)
PARSER.add_argument('--gitlab_project_id', help='Gitlab ID of the project to which members should be synced.'
                                                'Default: 12805 (robotws project)', default='12805', type=str)
PARSER.add_argument('--gitlab_access_level', help='Gitlab group membership level (No access - 0, Minimal access - 5,'
                                                  'Guest - 10, Reporter - 20, Developer - 30, Maintainer - 40).'
                                                  'Default: 40', default=40, type=int)


def connect_to_ldap_server(ldap_server, ldap_user_for_access, ldap_password_for_access):
    """
    Connect to LDAP server on given URL and log in with privileged user in order to be able to read from LDAP records

    :param ldap_server: LDAP server URL
    :type ldap_server: str
    :param ldap_user_for_access: LDAP user record used for reading from database
    :type ldap_user_for_access str
    :param ldap_password_for_access: LDAP user's password
    :type ldap_password_for_access: str
    :return ldap_connection: LDAP connection obj used for further searching actions
    :rtype ldap_connection:
    """
    ldap_connection = ldap.initialize(ldap_server)
    ldap_connection.set_option(ldap.OPT_REFERRALS, 0)
    ldap_connection.simple_bind_s(ldap_user_for_access, ldap_password_for_access)
    return ldap_connection


def get_group_members_usernames_from_ldap(ldap_connection, ldap_group):
    """
    Get usernames of members of LDAP group. LDAP uid parameter is being used for gathering the usernames. Group needs
    to be synced into ULTIMA (if it was created in IDM it can take 24 h before it will be synced).

    Few developer remarks which whould explain fixed indexses used in this method variables:

    * ldap_connection.search_s on LDAP group would output the structure as in below example:
    [
      (
        'cn=I_TAF_WRO,ou=Groups,ou=ULTIMA,o=EEDIR',
          {'uniqueMember': ['uid=foo,ou=People,ou=ULTIMA,o=EEDIR', 'uid=bar,ou=People,ou=ULTIMA,o=EEDIR']}
      )
    ]
    * ldap_connection.search_s on LDAP user would output the structure as in below example:
    [('uid=foo,ou=People,ou=ULTIMA,o=EEDIR', {'uid': ['foo']})]

    :param ldap_connection: LDAP connection object established via `connect_to_ldap_server` method
    :type ldap_connection: LDAPObject
    :param ldap_group: LDAP group name from which members' usernames should be fetched
    :type ldap_group: str
    :return usernames_from_ldap: List of usernames gathered from LDAP group
    :rtype usernames_from_ldap: list
    """
    result = ldap_connection.search_s(BASE_DN, ldap.SCOPE_SUBTREE, 'cn={}'.format(ldap_group), ['uniqueMember'])
    users_from_group = result[0][1]['uniqueMember']

    usernames_from_ldap = []
    for user in users_from_group:
        uid = user.decode().split(',')[0]
        username_details = ldap_connection.search_s(BASE_DN, ldap.SCOPE_SUBTREE, uid, ['uid'])
        username = username_details[0][1]['uid'][0]
        usernames_from_ldap.append(username.decode())
    return usernames_from_ldap


def get_gitlab_members_with_certain_access_level(gl_project, access_level):
    """
    Get Gitlab members from specific Gitlab project which match given access level

    :param gl_project: Gitlab project initialized by `gl.project.get(id)`
    :type gl_project: gitlab.v4.objects.Project
    :param access_level: Certain access level with which users should be searched for
    :type access_level: int
    :return members_list: List of Gitlab members objects with certain access level
    :rtype members_list: list
    """
    members_list = []
    for gl_member in gl_project.members.list(iterator=True, all=True):
        if gl_member.access_level == access_level:
            members_list.append(gl_member)
    return members_list


def set_developer_role_to_gitlab_members_which_are_not_on_ldap_list(
    gl_project,
    gl_members_list,
    gl_members_usernames,
    ldap_list
):
    """
    Remove members from Gitlab project if they are absent in LDAP group.

    :param gl_project: Gitlab project initialized by `gl.project.get(id)`
    :type gl_project: gitlab.v4.objects.Project
    :param gl_members_list: List of Gitlab members objects with certain access level
    :type gl_members_list: list
    :param gl_members_usernames: List of Gitlab members' usernames used for calculating the diff with LDAP list
    :type gl_members_usernames: list
    :param ldap_list: List of usernames gathered from LDAP group
    :type ldap_list: list
    """
    updated_users = []

    users_to_update = list(set(gl_members_usernames) - set(ldap_list))
    # filter out bots, whose names start with 'project_', such as 'project_15411_bot2'
    users_to_update = [member for member in users_to_update if not member.startswith('project_')]
    for gl_member in gl_members_list:
        if gl_member.username in users_to_update:
            user = gl_project.members.get(gl_member.id)
            user.access_level = gitlab.const.DEVELOPER_ACCESS
            user.save()
            updated_users.append(gl_member.username)

    print(f"Users which are not on LDAP list and got their access level set to 30 (Developer): {updated_users}")
    print(f"Number of updated users: {len(updated_users)}")


def add_gitlab_members_which_are_on_ldap_list(gl_conn, gl_project, gl_members_usernames, ldap_list, access_level):
    """
    Add users from LDAP list to Gitlab project with certain access level, if they're absent. If user can't be found in
    Gitlab then proper information is printed that it should be added by email. If user is already member of the group
    but with different privileges, then access level is updated.

    :param gl_conn: Gitlab connection object
    :type gl_conn: gitlab.Gitlab
    :param gl_project: Gitlab project initialized by `gl.project.get(id)`
    :type gl_project: gitlab.v4.objects.Project
    :param gl_members_usernames: List of Gitlab members' usernames used for calculating the diff with LDAP list
    :type gl_members_usernames: list
    :param ldap_list: List of usernames gathered from LDAP group
    :type ldap_list: list
    :param access_level: Certain access level with which users should be searched for
    :type access_level: int
    :return:
    """
    uids_not_in_gitlab = []
    added_users = []

    usernames_to_add = list(set(ldap_list) - set(gl_members_usernames))

    for username in usernames_to_add:
        gl_user = gl_conn.users.list(search=username)
        try:
            gl_project.members.create({'user_id': gl_user[0].id, 'access_level': access_level})
            added_users.append(username)
        except IndexError:
            uids_not_in_gitlab.append(username)
        except gitlab.exceptions.GitlabCreateError:
            gl_project.members.update(gl_user[0].id, {'access_level': access_level})
            added_users.append(username)

    print(f"Users added to project {gl_project.name} with access level {access_level}: {added_users}")
    print(f"Number of added users: {len(added_users)}")
    print(f"Users which are absent in Gitlab and should be invited by email: {uids_not_in_gitlab}")
    print(f"Number of absent users: {len(uids_not_in_gitlab)}")


if __name__ == '__main__':
    args = PARSER.parse_args()

    # Establish LDAP connection and gather LDAP usernames
    ldap_conn_obj = connect_to_ldap_server(args.ldap_server_url, args.ldap_login, args.ldap_password)
    ldap_usernames_list = get_group_members_usernames_from_ldap(ldap_conn_obj, args.ldap_group)
    print(f"LDAP usernames list: {ldap_usernames_list}")
    print(f"Number of LDAP usernames fetched: {len(ldap_usernames_list)}")

    # Establish Gitlab connection, get project details and extract all members with defined access rights
    # Users which are created by Gitlab access tokens (project_xyz_bot) are filtered out
    gl = gitlab.Gitlab(args.gitlab_server, private_token=args.gitlab_token)
    project = gl.projects.get(args.gitlab_project_id)
    members = get_gitlab_members_with_certain_access_level(project, args.gitlab_access_level)
    members = [member for member in members if not member.username.startswith('project_')]
    members_usernames = [member.username for member in members]
    print(f"Members list with access level {args.gitlab_access_level}: {members_usernames}")
    print(f"Number of members with access level {args.gitlab_access_level}: {len(members_usernames)}")

    # Restroct access level for users which are not on LDAP list
    set_developer_role_to_gitlab_members_which_are_not_on_ldap_list(
        project, members, members_usernames, ldap_usernames_list
    )

    # Add or elevate the users which are not in Gitlab but they're present in LDAP list
    add_gitlab_members_which_are_on_ldap_list(gl, project, members_usernames, ldap_usernames_list,
                                              args.gitlab_access_level)
