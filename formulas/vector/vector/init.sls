# SPDX-FileCopyrightText: 2021 Robin Schneider <robin.schneider@geberit.com>
#
# SPDX-License-Identifier: AGPL-3.0-only

## pkgrepo.managed does not support just importing the RPM key.
## The repo itself is managed by SUSE Manager.
## So for this we need to call Ansible to the rescue.

## ansible.call cannot handle Salt URI.
vector__openpgp_key_copy:
  file.managed:
    - name: '/var/tmp/gpg.3543DB2D0A2BC4B8.key'
    - source: 'salt://vector/files/gpg.3543DB2D0A2BC4B8.key'

vector__rpm_key_import:
  ansible.call:
    - packaging.os.rpm_key:
      # - key: 'https://artifacts.elastic.co/GPG-KEY-elasticsearch'
      # - key: 'salt://vector/files/GPG-KEY-elasticsearch'
      - key: '/var/tmp/gpg.3543DB2D0A2BC4B8.key'


      ## SLES 12 ships with Ansible 2.8 which does not support fingerprint yet.
      {% if grains['os'] == "SUSE" and grains['osmajorrelease']|int >= 15 -%}
      - fingerprint: '1E46 C153 E9EF A240 18C3  6F75 3543 DB2D 0A2B C4B8'
      {% endif %}
