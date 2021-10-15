# SPDX-FileCopyrightText: 2021 Robin Schneider <robin.schneider@geberit.com>
#
# SPDX-License-Identifier: AGPL-3.0-only

## pkgrepo.managed does not support just importing the RPM key.
## The repo itself is managed by SUSE Manager.
## So for this we need to call Ansible to the rescue.

## ansible.call cannot handle Salt URI.
elastic_co__openpgp_key_copy:
  file.managed:
    - source: 'salt://elastic_co/files/GPG-KEY-elasticsearch'
    - name: '/var/tmp/GPG-KEY-elasticsearch'

elastic_co__rpm_key_import:
  # It seems there is an issue with ansible.call with recent Salt versions.
  # Switch to cmd.run for now.
  # TODO: Switch back to ansible.call.

  # ansible.call:
  #   - packaging.os.rpm_key:
  #     # - key: 'https://artifacts.elastic.co/GPG-KEY-elasticsearch'
  #     # - key: 'salt://elastic_co/files/GPG-KEY-elasticsearch'
  #     - key: '/var/tmp/GPG-KEY-elasticsearch'


  #     ## SLES 12 ships with Ansible 2.8 which does not support fingerprint yet.
  #     {% if grains['os'] == "SUSE" and grains['osmajorrelease']|int >= 15 -%}
  #     - fingerprint: '4609 5ACC 8548 582C 1A26 99A9 D27D 666C D88E 42B4'
  #     {% endif %}

  cmd.run:
    - name: rpm --import /var/tmp/GPG-KEY-elasticsearch
