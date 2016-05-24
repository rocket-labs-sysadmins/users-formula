{% from "users/map.jinja" import users with context %}
include:
  - users

{% for name, user in pillar.get('users', {}).items() if user.absent is not defined or not user.absent %}
{%- if user == None -%}
{%- set user = {} -%}
{%- endif -%}
{%- set home = user.get('home', "/home/%s" % name) -%}
{%- set manage = user.get('manage_bashrc', False) -%}
{%- if 'prime_group' in user and 'name' in user['prime_group'] %}
{%- set user_group = user.prime_group.name -%}
{%- else -%}
{%- set user_group = name -%}
{%- endif %}
{# user bashrc can be set globally via users:lookup keys. Per-user values override defaults. #}
{%- set bashrc_template = user.get('bashrc_template', users.bashrc_template|default(False)) %}
{%- set bashrc_template_format = user.get('bashrc_template_format', users.bashrc_template_format|default('None')) %}
{%- if manage -%}
users_{{ name }}_user_bashrc:
  file.managed:
    - name: {{ home }}/.bashrc
    - user: {{ name }}
    - group: {{ user_group }}
    - mode: 644
    - source:
      - bashrc_template|default('salt://users/files/bashrc/' ~ name ~ '/bashrc')
      - salt://users/files/bashrc/bashrc
    - template: {{ bashrc_template_format }}
{% endif %}
{% endfor %}
