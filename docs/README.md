<!--
SPDX-FileCopyrightText: 2021 Robin Schneider <robin.schneider@geberit.com>

SPDX-License-Identifier: CC-BY-SA-4.0
-->

# SaltStack configuration management

SaltStack is used to configure the base OS and if possible also the application
on servers. To allow to scale, structure is needed. The structure proposed by
Robin Schneider is complex but is based on years of experience with Ansible and
DebOps operating ~50 production servers. Try to first learn the SaltStack
basics and then as you hit the limits of SaltStack as it is shown in tutorials,
check how Robin solved it. The approach is heavily based on
https://docs.debops.org/en/master/

## Concept

* Public Salt Formulas should be reused if existing.
* If no Formula is public, we write our own Salt State. They should be
  structured the same as Salt Formulas. The parts below will only refer to
  Formulas which includes Salt States.
* Salt Formula should not contain anything specific to the organization. This
  allows it to be shared. When using Formulas, this principle
  allows to easily integrate public changes into the local clone of the repo.
  This point is not strictly required for Salt States the sysadmin writes for
  herself but still good practice.
  The Formula should instead have sane defaults which are not specific
  to an organization.
  It is prohibited to include anything
  sensible like passwords or personal information in Salt States because of the
  architecture of SaltStack! Ask yourself who can access the Salt States from
  the Salt Master and then reconsider.
* Environment specifics should be provided to a Formula via Salt Pillar.

## Pillar layout

`pillarstack` is used. It is one of the ext pillar modules provided
by SaltStack and was chosen because it allows multiple stages of the Pillar
source data. This in turn allows to base one Pillar variable on the content of
a previously defined Pillar variable.

The stages and their function are:

* `10_minion_groups`: Determine the content of the `minion_groups` Pillar variable.
  It can be determined based on the CMDB of the organization, minion ID or
  other Pillar variables.
  Minion groups can be used to describe an overall service, like `log_collection_es_cluster`.
  Also for services provided only by a single minion, a group should still be
  defined to allow for easy migration by temporarily adding the old and new
  minion to the group.
* `15_secrets`: Assign secrets via Pillar to minions based on their `minion_groups`.
  This stage can also be provided by an ext Pillar module that talks to a Vault or Password manager.
* `20_variables`: Assign Pillar that are not secret to minions based based on their `minion_groups`.
  `20_variables` is the main part of the Pillar.
  Its main responsibility is to map from minion group to the Formula(s) that
  are needed to implement the function of the minion group.
  For this, the Formulas need to be "enabled" to run on a minion (on highstate)
  by adding them to the `states` Pillar dictionary.
  The now enabled Formulas need to be parametrized to fit into the organization.

  `20_variables` is after `15_secrets` so that Pillar data can be
  constructed including secrets that a public Salt Formula understands. For
  example `kibana.config.elasticsearch.password`.
* `90_order_states`: The only responsibility of this stage is to convert
  `states` into an ordered list.
  Because multiple files in `20_variables` might use the same Formula or
  configure certain aspects of a Formula, the `states` variable is a dictionary
  which allows to declare a dependency to a Formula without duplicating the
  entry as it would be with a list.
  As such dependences can be defined without a clear order but Formulas might
  have dependencies on each other, they are sorted here.

## Install a new SaltStack Formula

* Clone via `git submodule` into `./formulas/`
* Activate the Formula in `/etc/salt/master.d/zzz_custom.conf`

## Write own Salt State

* Create a directory in `./files/$name_of_state`. The name should be the application or package that is configured.
* Try to follow the public conventions https://docs.saltproject.io/en/latest/topics/development/conventions/formulas.html

## Example

See the `example/` file tree.
