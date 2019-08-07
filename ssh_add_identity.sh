#! /bin/bash

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>

# todo write usage option

# Expand tilde 
idty=${1/#\~/${HOME}}

# Need exactly one option
if (( $# != 1 )); then
  echo "Illegal number of parameters"
  exit 1
fi

# Option needs to be a regular file
if [[ ! -f "$idty" ]]; then
  echo "$1 is not a regular file"
  exit 1
fi

# Only run one ssh-agent
if [ ! -S ${HOME}/.ssh/ssh_auth_sock ]; then
  eval `ssh-agent`
  ln -sf "${SSH_AUTH_SOCK}" ${HOME}/.ssh/ssh_auth_sock
fi
export SSH_AUTH_SOCK=${HOME}/.ssh/ssh_auth_sock

idty_present=""
for known_idty in $(ssh-add -l | awk '{ print $3 }'); do
  if [[ "${known_idty}" == "${idty}" ]]; then
    idty_present="yes"
  fi
done

if [[ -z "${idty_present}" ]]; then
  ssh-add "${idty}"
  echo "identity added"
else
  echo "identity already present"
fi
