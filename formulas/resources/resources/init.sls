# SPDX-FileCopyrightText: 2021 Robin Schneider <robin.schneider@geberit.com>
#
# SPDX-License-Identifier: AGPL-3.0-only

{% for path, options in salt['pillar.get']('resources:repositories', {}).items() %}
{%   if options.absent is defined and options.absent or options.get('state', "present") == 'absent' %}
resources__repository_absent_{{ path }}:
  file.absent:
    - name: {{ path }}
{%   else %}
resources__repository_present_{{ path }}:

{# git.cloned does not support recursive cloning #saltgate -> #ansiblegate :)
  git.cloned:
    - name: '{{ options['src'] }}'
    - target: {{ path }}
    {# I am missing the `{{ omit }}` feature from Ansible. Have not found a replacement the following is left unimplemented for now:
    - branch: '{{ options.get('branch', "null") }}'
    - user: '{{ options.get('user', "null") }}'
    - password: '{{ options.get('password', "null") }}'
    - identity: '{{ options.get('identity', "null") }}'
    - https_user: '{{ options.get('https_user', "null") }}'
    - https_pass: '{{ options.get('https_pass', "null") }}'
    - output_encoding: '{{ options.get('output_encoding', "null") }}'
    #}

  {# The git Ansible module does recursive cloning by default as it should! I am looking at you git Salt state! #}
  ansible.call:
    - source_control.git:
      - repo: '{{ options['src'] }}'
      - dest: {{ path }}

{%   endif %}
{% endfor %}


{% for path, options in salt['pillar.get']('resources:files', {}).items() %}
{%   if options.absent is defined and options.absent or options.get('state', "present") == 'absent' %}
resources__file_absent_{{ path }}:
  file.absent:
    - name: {{ path }}
{%   elif options.absent is defined and options.absent or options.get('state', "present") == 'link' %}
resources__file_symlink_{{ path }}:
  file.symlink:
    - name: {{ path }}
    - target: {{ options['target'] }}
    - makedirs: {{ options.get('makedirs', "null") }}
{%   elif options.get('recurse') == True %}
resources__file_recurse_{{ path }}:
  # FIXME: Issue with recursive copy.
  file.recurse:
    - name: {{ path }}
    - source: {{ options.get('source', "null") }}
    - file_mode: {{ options.get('file_mode', "null") }}
    - replace: {{ options.get('file_mode', "null") }}
{%   elif options.get('state', "present") == 'directory' %}
resources__file_directory_{{ path }}:
  file.directory:
    - name: {{ path }}
    - user: {{ options.get('user', "null") }}
    - group: {{ options.get('group', "null") }}
    - mode: {{ options.get('mode', "null") }}
    - makedirs: {{ options.get('makedirs', "null") }}
    - recurse: {{ options.get('recurse', "null") }}
{%   else %}
resources__file_present_{{ path }}:
  file.managed:
    - name: {{ path }}
    - source: {{ options.get('source', "null") }}
    - source_hash: {{ options.get('source_hash', "null") }}
    ## Don’t you dare allow skip_verify here ;-) Just use source_hash.
    - user: {{ options.get('user', "null") }}
    - group: {{ options.get('group', "null") }}
    - mode: {{ options.get('mode', "null") }}
    - template: {{ options.get('template', "null") }}
    - makedirs: {{ options.get('makedirs', "null") }}
    - dir_mode: {{ options.get('dir_mode', "null") }}
    - force: {{ options.get('force', "null") }}
    {% if 'contents' in options %}
    - contents: {{ options.get('contents', "null")|json }}
    {% endif %}
    {% if 'contents_pillar' in options %}
    - contents_pillar: {{ options.get('contents_pillar', "null")|json }}
    {% endif %}
    - check_cmd: {{ options.get('check_cmd', "null") }}
{%   endif %}
{% endfor %}
