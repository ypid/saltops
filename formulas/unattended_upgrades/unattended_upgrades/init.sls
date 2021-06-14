# SPDX-FileCopyrightText: 2019-2020 Robin Schneider <robin.schneider@geberit.com>
#
# SPDX-License-Identifier: AGPL-3.0-only

unattended_upgrades__file_managed_/usr/local/bin/apply_updates:
  file.managed:
    - user: root
    - group: root
    - mode: 0744
    - name: /usr/local/lib/apply_updates
    - source: salt://unattended_upgrades/files/usr/local/lib/apply_updates.j2
    - template: jinja
