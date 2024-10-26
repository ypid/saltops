# SPDX-FileCopyrightText: 2021 Robin Schneider <robin.schneider@geberit.com>
#
# SPDX-License-Identifier: AGPL-3.0-only

git__/etc/gitconfig:
  file.managed:
    - user: root
    - group: root
    - mode: 0644
    - name: /etc/gitconfig
    - source: salt://git/files/etc/gitconfig.j2
