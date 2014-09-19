# Install required packages
nvm_pkgs:
  pkg.installed:
    - names:
      - git
      - screen
      - g++

# Install nvm
nvm_install:
  cmd.run:
    - name: 'curl https://raw.githubusercontent.com/creationix/nvm/v0.16.1/install.sh | bash'
    - unless: 'ls ~/.nvm/nvm.sh'

# Command for executing nvm
{% set nvm_command = 'source ~/.nvm/nvm.sh;nvm' %}


# Install selected node versions
{% for node_app in salt['pillar.get']('node-app', []) %}

  # Install selected node versions
  {% for nvm in node_app['nvm'] %}

{% set state_id = node_app['name'] ~ 'nvm_install_v' ~ nvm['version'] %}
{{ state_id }}:
  cmd.run:
    - name: '{{ nvm_command }} install {{ nvm['version'] }}'
    - unless: '{{ nvm_command }} ls {{ nvm['version'] }}'

    # Install selected global package
    {% if nvm['global_packages'] is defined %}
      {% for package in nvm['global_packages'] %}

        {% set package_state_id = node_app['name'] ~ 'node_v' ~ nvm['version'] ~ '_install_package_' ~ package %}

{{ package_state_id }}:
  cmd.run:
    - name: '{{ nvm_command }} use {{ nvm['version'] }};npm install --unsafe-perm -g {{ package }}'
    - unless: 'npm ls --global true {{ package }}'

      {% endfor %}
    {% endif %}

  {% endfor %}

# Install npm packages
{% set app_npm_setup_state_id = node_app['name'] ~ '_npm_setup' %}
{{ app_npm_setup_state_id }}:
  cmd.run:
    - name: 'cd {{ node_app['path'] }} && {{ nvm_command }} use && npm install'
    - unless: 'ls {{ node_app['path'] }}/node_modules'

# Update npm packages
{% set app_npm_update_state_id = node_app['name'] ~ '_npm_update' %}
{{ app_npm_update_state_id }}:
  cmd.run:
    - name: 'cd {{ node_app['path'] }} && {{ nvm_command }} use && npm update'



# Setup app if defined
{% if node_app['setup'] is defined %}

{% set app_npm_setup_state_id = node_app['name'] ~ '_setup' %}
{{ app_npm_setup_state_id }}:
  cmd.run:
    - name: 'cd {{ node_app['path'] }} && {{ nvm_command }} use && {{ node_app['setup']['run'] }}'
    {% if node_app['setup']['unless'] is defined %}- unless: '{{ node_app['setup']['unless'] }}'{% endif %}

{% endif %}


# Start app
{% set app_run_state_id = node_app['name'] ~ '_run' %}
{{ app_run_state_id }}:
  cmd.run:
    - name: 'cd {{ node_app['path'] }} && screen -dmS {{ node_app['name'] }} npm start'
    - unless: 'screen -ls {{ node_app['name'] }}'

{% endfor %}
