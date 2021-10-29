# SPDX-FileCopyrightText: 2021 Robin Schneider <robin.schneider@geberit.com>
#
# SPDX-License-Identifier: AGPL-3.0-only

atd_install:
  pkg.installed:
    - refresh: False
    - cache_valid_time: 86400
    - pkgs:
      - at

atd_service:
  service.running:
    - name: 'atd'
    - enable: True
