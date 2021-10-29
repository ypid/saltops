# SPDX-FileCopyrightText: 2021 Robin Schneider <robin.schneider@geberit.com>
#
# SPDX-License-Identifier: AGPL-3.0-only

etckeeper__install:
  pkg.installed:
    - refresh: False
    - cache_valid_time: 86400
    - pkgs:
      - etckeeper
      - etckeeper-cron
      - etckeeper-zypp-plugin


{% if grains.os|lower == "suse" and grains.osmajorrelease|string in ["12"] -%}
etckeeper__/etc/etckeeper/etckeeper.conf:
  file.managed:
    - user: root
    - group: root
    - mode: 0644
    - name: /etc/etckeeper/etckeeper.conf
    - source: salt://etckeeper/files/etc/etckeeper/etckeeper.conf.j2
{% endif %}

etckeeper__/etc/.gitignore:
  file.prepend:
    - name: /etc/.gitignore
    - text:
      - ssh/ssh_host_*_key
      - X11/xorg.conf.backup
      - apparmor.d/libvirt/*.files

etckeeper__/etc/.gitattributes:
  file.managed:
    - name: /etc/.gitattributes
    - source: salt://etckeeper/files/etc/gitattributes.j2
    - template: jinja
    - user: root
    - group: root
    - mode: 0644

etckeeper__init:
  cmd.run:
    - name: etckeeper init
    - creates: /etc/.etckeeper

etckeeper__set_user_/etc/.git/config:
  git.config_set:
    - name: user.name
    - value: 'The /etc Keeper'
    - repo: /etc

etckeeper__set_email_/etc/.git/config:
  git.config_set:
    - name: user.email
    - value: '{{ salt['pillar.get']('minion_email', 'root@' + grains['fqdn']) }}'
    - repo: /etc

etckeeper__initial_commit:
  cmd.run:
    - name: etckeeper commit 'Initial commit by the "etckeeper" SaltStack formula'
    - creates: /etc/.git/refs/heads/master
