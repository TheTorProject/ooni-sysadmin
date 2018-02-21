# OONI sysadmin

In here live all the tools and scripts related to administering the
infrastructure that are part of OONI.

# Ansible roles

This is the section for using ansible roles to install and configure OONI
components.

It is required for all OONI team to run the same ansible version to monimise
compatibility issues. It is enforced by including `ansible-version.yml` play in
the playbooks.

If you need some python packages **only** for ansible module to
work and don't need it in system-wide pip repository, then you should put these
modules in separate virtual environment and set proper
`ansible_python_interpreter` for the play. See `docker_py` role and grep for
`/root/venv` for examples.

If you need to store secrets in repository then store them as vaults using
`ansible/vault` script as a wrapper for `ansible-vault`. Store encrypted
variables with `vault_` prefix to make world [a more grepable place](http://docs.ansible.com/ansible/playbooks_best_practices.html#best-practices-for-variables-and-vaults)
and link location of the variable using same name without prefix in corresponding `vars.yml`.
`scripts/ansible-syntax-check` checks links between vaults and plaintext files during Travis build.
`ansible/play` wrapper for `ansible-playbook` will execute a playbook with
proper vault secret and inventory.

## ooni-backend

This ansible role installs ooni-backend from git repo via pip in a python
virtual environment (virtualenv). The ooni-backend service is being started and
controlled via the [Supervisor](http://supervisord.org) service. This role
can be used for Debian releases and has been tested in Wheesy and Jessie Debian
releases.

### execute role

```
ansible-playbook -i "hosts-inventory" ansible/install-oonibackend.yml -v
```
Note: The inventory file should include hosts in custom group.

## ooniprobe

This ansible role install ooniprobe via apt (stretch repo) or via pip from this
the git repo. This role can be used for Debian releases and has been tested in
Wheesy and Jessie Debian releases. By seting the conditional variable
`set_ooniprobe_pip` to true ooniprobe will be istalled from git via pip.
Setting the conditional variable `set_ooniprobe_go` to true will install the
golang-go package.

### execute role

```
ansible-playbook -i "hosts-inventory" ansible/install-ooniprobe.yml -v
```

## Third party tools

This ansible role install third party tools required for some ooniprobe
tests. The following third party tools can be installed with this role:

Tool|oooniprobe test
----|---------------
OpenVPN|https://github.com/TheTorProject/ooni-spec/blob/master/test-specs/ts-015-openvpn.md
Psiphon|https://github.com/TheTorProject/ooni-spec/blob/master/test-specs/ts-014-psiphon.md
Lantern|https://github.com/TheTorProject/ooni-spec/blob/master/test-specs/ts-012-lantern.md

### execute role

```
ansible-playbook -i "hosts-inventory" ansible/install-thirdparty.yml -v
```

## tor pluggable transports

This ansible role install the tor pluggable transports required for ooniprobe
bridge reachability test. The following tor pluggable transports will be
installed with this role:

Pluggagle Transport
-------------------
fteproxy
obfsproxy (obfs2,obfs3,scramblesuit)
obfs4proxy
meek (not implemented yet in bridge reachability test)

### execute role

```
ansible-playbook -i "hosts-inventory" ansible/install-tor-pluggagle-trans.yml -v
```

## letsencrypt role

This ansible role installs the required dependencies and generates letsencrypt
certificates. Additionally is sets a monthly cron job that renews if needed the
generated certificates.

### execute role

```
ansible-playbook -i "hosts-inventory" ansible/install-letsencrypt.yml -v
```

## PostgreSQL role

This ansible role installs the dependencies and configuration required to run a
PostgreSQL service with a new database (`psql_db_name`) and a user (`psql_db_user`)
with a given password (`psql_db_passwd`).

This roles has been tested in Debian Jessie.

### Execute role

```
ansible-playbook -i "hosts-inventory" ansible/install-postgresql.yml -v
```

## ooni-measurements role

This ansible role deploys ooni-measurements application.


### execute role

```
ansible-playbook -i "hosts-inventory" ansible/ansible/deploy-ooni-measurements.yml -v
```

## munin role

This ansible roles deploy munin monitoring to master and slaves and issues the
letsencrypt certificate for munin virtualhost.

### execute role

```
ansible-playbook -i "hosts-inventory" ansible/deploy-munin.yml -v
```

## ooni-explorer role

This ansible role deploy ooni-explorer with letsencrypt certificate.

### execute role

```
ansible-playbook -i "hosts-inventory" ansible/ansible/deploy-ooni-explorer.yml -v
```

## slackin role

This ansible role deploys slackin with letsencrypt certificate and the slack
irc bridge.

### execute role

```
ansible/play -i ansible/inventory ansible/deploy-slackin.yml
```

# Instructions

Unless otherwise indicated the instructions are for debian wheezy.

## Setting up docker

```
# Install kernel >3.8
echo "deb http://http.debian.net/debian wheezy-backports main" >> /etc/apt/sources.list
apt-get update
apt-get install -t wheezy-backports linux-image-amd64
apt-get install curl
# Install docker
curl -sSL https://get.docker.com/ | sh
```

# Disaster recovery procedure

This is the procedure to restore all the system of the OONI infrastructure if
everything goes bad.

## Restore OONI pipeline

```
cd ansible/server_migration/
ansible-playbook -i hosts pipeline.yml -vvvv
```

# M-Lab deployment
M-Lab [deployment process]
(https://github.com/m-lab/ooni-support/#m-lab-deployment-process).

# Upgrading OONI infrastructure

## ooni-backend

Collected notes on how to successful upgrade a running ooni-backend (bouncer
and collector).

1. Build the docker image of the new bouncer.
2. Start the new docker image mapping a new bouncer directory that is not the
   live one.
3. Run a couple of tests against the newly created image by specifying a custom
   bouncer and collector (the new one).
4. Take down the old bouncer.
5. Take up the new bouncer.

Currently ooni-backend is running in a docker build the most painful way to
upgrade to a new backend version is to create a new docker build image and use
temporary mapping volume directories.
After successfully building (you have already test it right?) the docker image
we should re-run the newly created docker image *but* with the correct (the
ones in the build script) volume directories.
The reports in progress will fail and schedule retries once the new bouncer and
collector are back up.

### Common pitfalls

* Ensure that the HS private keys of bouncer and collector are in right PATH
(collector/private_key , bouncer/private_key).
* Set the bouncer address in bouncer.yaml to the correct HS address.
* ooni-backend will *not* generate missing directories and fail to start

### Testing

Running a short ooni-probe test will ensure that the backend has been
successfully upgraded, an example test:

```
ooniprobe --collector httpo://CollectorAddress.onion blocking/http_requests \
--url http://ooni.io/
```

# When adding new hosts

## DNS name policy

Public HTTP services are `${service}.ooni.io`. _Public_ means that it's part of some external system we can't control: published MK versions, web URLs and so on.

Private HTTP services like monitoring, probe and data management are `${service}.ooni.nu`. Exceptions are various legacy redirects like `www.ooni.nu`.

Multi-purpose VM SHOULD use 4...8 character name and have FQDN like `${deity}.ooni.nu`:
- WDC ~ [fish name](https://en.wikipedia.org/wiki/List_of_common_fish_names)
- AMS ~ [Roman deity](https://en.wikipedia.org/wiki/List_of_Roman_deities#Alphabetical_list)
- HKG ~ [Slavic deity](https://en.wikipedia.org/wiki/Deities_of_Slavic_religion)

Single-purpose VM names MAY use `${service}.ooni.nu` as an `inventory_hostname`.

Various legacy names should be cleaned up during re-deploying VMs with newer base OS version.

## New host in inventory

When you add a new host to `ansible/inventory` you need to update the continuous integration scripts to make Travis CI happy.

This can be done by doing:

```
./play inventory-check.yml
```

Then editing the line in the `inventory-check.yml` that says "stamp the
inventory that was checked" with the output of the `build inventory check` task
in the previous command.

Be also to then run:

```
./play ext-inventory.yml
```

This will fetch updates to the DNS zone.

`inventory_hostname` MUST NOT be renamed.

# PostgreSQL replica bootstrap

[`pg_basebackup`](https://www.postgresql.org/docs/current/static/app-pgbasebackup.html)
is nice, but does not support network traffic compression out of box and has no
obvious way to resume interrupted backup. `rsync` solves that issue, but it
needs either WAL archiving (to external storage) to be configured or
`wal_keep_segments` to be non-zero, because otherwise WAL logs are rotated ASAP
(`min_wal_size` and `max_wal_size` do not set amount of WAL log available to
reader, these options set amount of disk space allocated to writer!).
Also [replication slot](https://www.postgresql.org/docs/current/static/functions-admin.html#FUNCTIONS-REPLICATION)
may reserve WAL on creation, but beware, it postpones WAL reservation till replica connection by default.

[`pg_start_backup()`](https://www.postgresql.org/docs/current/static/continuous-archiving.html#BACKUP-LOWLEVEL-BASE-BACKUP)
+ `rsync -az --exclude pg_replslot --exclude postmaster.pid --exclude postmaster.opts` is a way to go.
And, obviously, don't exclude `pg_wal` (aka `pg_xlog`) if neither WAL archiving nor replication slot is not set up.

And don't forget to revoke `authorized_keys` if SSH was used for `rsync`!

# Updating firewall rules

If you need to update the firewalling rules, because you added a new host to
the `have_fw` group or you changed the hostname of a host, you should edit the
file `templates/iptables.filter.part/$HOSTNAME` and then run:

```
./play dom0-bootstrap.yml -t fw
```

# Donate to support OONI infrastructure

Send bitcoins to:
![bitcoin address](http://i.imgur.com/ILdOJ3V.png)
```
16MAyUCxfk7XiUjFQ7yawDhbGs43fyFxd
```
