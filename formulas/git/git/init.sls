git__/etc/gitconfig:
  file.managed:
    - user: root
    - group: root
    - mode: 0644
    - name: /etc/gitconfig
    - source: salt://git/files/etc/gitconfig.j2
