#!/usr/bin/python3
# -*- coding: utf-8 -*-

# SPDX-FileCopyrightText: 2019-2021 Robin Schneider <robin.schneider@geberit.com>
#
# SPDX-License-Identifier: AGPL-3.0-only


import subprocess
import re
import os

try:
    from subprocess import DEVNULL
except ImportError:
    DEVNULL = open(os.devnull, 'wb')


def _parse_sid_from_sap_instances(sap_instances_output):
    grains = {}

    sap_sids = re.findall(r':\s*\b(\w+)\b.*', sap_instances_output)
    sap_uniform_sids = set(map(str.lower, map(str, sap_sids)))
    sap_valid_sids = sap_uniform_sids.difference(['daa'])

    env_pattern_to_env_mapping = {
        r'^t': 'dev',
        r'^q': 'qas',
        r'^c': 'prod',
        r'd$': 'dev',
        r'q$': 'qas',
        r'p$': 'prod',
    }

    for sap_sid in sap_valid_sids:
        for sid_pattern, sap_env in env_pattern_to_env_mapping.items():
            if re.search(sid_pattern, sap_sid):
                grains.update({
                    'sap_env': sap_env,
                    'sap_sid': sap_sid,
                })
                break

    return grains


def sap_grains(test=False):
    grains = {}

    saphostctrl_file_path = '/usr/sap/hostctrl/exe/saphostctrl'
    if not test:
        if not os.path.isfile(saphostctrl_file_path) or not os.access(saphostctrl_file_path, os.X_OK):
            return grains

    # For local testing:
    sap_instances_output = '''
        Inst Info : GSD - 02 - myhostname - 749, patch 401, changelist 1806777
        Inst Info : GSD - 01 - orgservicename - 749, patch 401, changelist 1806777
        Inst Info : DAA - 98 - myhostname - 749, patch 401, changelist 1806777
    '''
    sap_instances_running_output = sap_instances_output

    if not test:
        sap_instances_output = subprocess.check_output([
            saphostctrl_file_path,
            '-function',
            'ListInstances',
        ], stderr=DEVNULL).decode('utf-8')
        sap_instances_running_output = subprocess.check_output([
            saphostctrl_file_path,
            '-function',
            'ListInstances',
            '-running',
        ], stderr=DEVNULL).decode('utf-8')

    grains['saphostctrl_instances'] = sap_instances_output
    grains.update(_parse_sid_from_sap_instances(sap_instances_output))

    if 'sap_sid' in grains and \
            'sap_sid' in _parse_sid_from_sap_instances(sap_instances_running_output):
        grains.setdefault('sap_solutions', [])
        grains['sap_solutions'].append('netweaver')

    # For local testing:
    sap_databases = '''
        Instance name: XXXXXXX, Hostname: XXXX, Vendor: HDB, Type: hdb, Release: XXXXX.XXX
          Database name: SYSTEMDB@T11, Status: Running
            Component name: sapstartsrv (HDB sapstartsrv), Status: Running (Running)
            Component name: hdbdaemon (HDB Daemon), Status: Running (Running)
    '''

    if not test:
        sap_databases = subprocess.check_output([
            saphostctrl_file_path,
            '-function',
            'ListDatabases',
        ], stderr=DEVNULL).decode('utf-8')

    grains['saphostctrl_databases'] = sap_databases

    if re.search(r'\btype[:=\s]*hdb\b', sap_databases, flags=re.IGNORECASE):
        grains.setdefault('sap_solutions', [])
        grains['sap_solutions'].append('hana')

    return grains


if __name__ == "__main__":
    import yaml
    print(yaml.dump(sap_grains(test=True), default_flow_style=False))
