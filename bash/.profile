# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# if running bash
# if [ -n "$BASH_VERSION" ]; then
#     # include .bashrc if it exists
#     if [ -f "$HOME/.bashrc" ]; then
# 	. "$HOME/.bashrc"
#     fi
# fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi
# Also use bashrc if it exists.
[ -n "$BASH" ] && [ -r ~/.bashrc ] && . ~/.bashrc

# pip configuration.
eval "$(pip completion --bash)"

# pipx binary directory.
export PATH="~/.local/bin:${PATH}"

# pipenv configuration.
export PIPENV_VENV_IN_PROJECT=true

# CUDA configuration.
export PATH="/usr/local/cuda/bin:/usr/local/nvidia/bin:${PATH}"
export XLA_FLAGS="--xla_gpu_cuda_data_dir=/usr/local/cuda"
# Add search path for CUDA drivers installed by nvidia-driver-installer
# https://cloud.google.com/kubernetes-engine/docs/how-to/gpus#cuda
export LD_LIBRARY_PATH="/usr/local/nvidia/lib64:${LD_LIBRARY_PATH}"

export PATH="$HOME/.local/bin:${PATH}"
# Node configuration.
export PATH=${PATH}:/home/alex/bin/node/bin

export GOOGLE_APPLICATION_CREDENTIALS='service/agentic_keys/agentic/keys/service_accounts/agentic-test-sa-key.json'

. "$HOME/.cargo/env"

source ~/.dotfiles/profile
