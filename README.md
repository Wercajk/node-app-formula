Node.js App Formula
=============

To setup Node.js app.

## What it does

1. Install [nvm](https://github.com/creationix/nvm)
2. Install Node.js version for each defined app with global packages as well

## Install

1. Add remotes to /etc/salt/master

  ```yaml
  gitfs_remotes:
    - git://github.com/Wercajk/node-app-formula
  ```
2. Setup [pillar](http://docs.saltstack.com/en/latest/topics/pillar/) from pillar.example
3. Add basic to your server [state file](http://docs.saltstack.com/en/latest/topics/tutorials/starting_states.html)

  ```yaml
  include:
      - node-app
  ```

  or to the [top.sls](http://docs.saltstack.com/en/latest/ref/states/top.html) file


  ```yaml
  base:
    'some.server.example.com':
      - node-app
  ```
