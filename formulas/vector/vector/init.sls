# SPDX-FileCopyrightText: 2021 Robin Schneider <robin.schneider@geberit.com>
#
# SPDX-License-Identifier: AGPL-3.0-only

# pkgrepo.managed does not support just importing the RPM key.
# The repo itself is managed by SUSE Manager.
# So for this we need to call Ansible to the rescue.

# ansible.call cannot handle Salt URI.
vector__openpgp_key_copy:
  file.managed:
    - source: 'salt://vector/files/gpg.3543DB2D0A2BC4B8.key'
    - name: '/var/tmp/gpg.3543DB2D0A2BC4B8.key'

vector__rpm_key_import:
  # It seems there is an issue with ansible.call with recent Salt versions.
  # Switch to cmd.run for now.
  # TODO: Switch back to ansible.call.

  # ansible.call:
  #   - packaging.os.rpm_key:
  #     # - key: 'https://artifacts.elastic.co/GPG-KEY-elasticsearch'
  #     # - key: 'salt://vector/files/GPG-KEY-elasticsearch'
  #     - key: '/var/tmp/gpg.3543DB2D0A2BC4B8.key'


  #     # # SLES 12 ships with Ansible 2.8 which does not support fingerprint yet.
  #     # # So this parameter is only set for SLES 15 or higher.
  #     # {% if grains['os'] == "SUSE" and grains['osmajorrelease']|int >= 15 -%}
  #     # - fingerprint: '1E46 C153 E9EF A240 18C3  6F75 3543 DB2D 0A2B C4B8'
  #     # {% endif %}

  cmd.run:
    - name: rpm --import /var/tmp/gpg.3543DB2D0A2BC4B8.key
