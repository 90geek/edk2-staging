## @file win_edkrepo_prompt.sh
# Note: For use on Git for Windows/MSYS2 ONLY.
# UNIX version is in install.py
#
# Copyright (c) 2020, Intel Corporation. All rights reserved.<BR>
# SPDX-License-Identifier: BSD-2-Clause-Patent
#

# Add EdkRepo command completions
[[ -r "/etc/profile.d/edkrepo_completions.sh" ]] && . "/etc/profile.d/edkrepo_completions.sh"

# Add EdkRepo to the prompt
ps1len="${#PS1}"
let "pos38 = ps1len - 38"
let "pos3 = ps1len - 3"
let "pos2 = ps1len - 2"
if [ "${PS1:pos38}" == '\[\033[36m\]`__git_ps1`\[\033[0m\]\n$ ' ]; then
  newps1="${PS1:0:pos38}"
  prompt_suffix='\[\033[36m\]`__git_ps1`\[\033[0m\]\n$ '
elif [ "${PS1:pos3}" == "\\$ " ]; then
  newps1="${PS1:0:pos3}"
  prompt_suffix="\\$ "
elif [ "${PS1:pos3}" == " $ " ]; then
  newps1="${PS1:0:pos3}"
  prompt_suffix=" $ "
elif [ "${PS1:pos2}" == "$ " ]; then
  newps1="${PS1:0:pos2}"
  prompt_suffix="$ "
else
  newps1="$PS1"
  prompt_suffix=""
fi

if [ -x "$(command -v edkrepo)" ] && [ -x "$(command -v $command_completion_edkrepo_file)" ]; then
  newps1="$newps1\[\033[32m\]\$current_edkrepo_combo\[\033[00m\]"
  current_edkrepo_combo=$(command_completion_edkrepo current-combo)

  # Determining the current Edkrepo combo requires invoking Python and parsing
  # manifest XML, which is a relatively expensive operation to do every time
  # the user presses <Enter>.
  # As a performance optimization, only do this if the present working directory
  # changed or if the last command executed was edkrepo
  do_combo_check="0"
  edkrepo_check_last_command() {
    if [[ "$BASH_COMMAND" == *"edkrepo"* ]] && [[ "$BASH_COMMAND" != *"_edkrepo"* ]]; then
      if [[ "$BASH_COMMAND" != *"edkrepo_"* ]]; then
        do_combo_check="1"
      fi
    fi
  }
  trap 'edkrepo_check_last_command' DEBUG
  if [[ ! -z ${PROMPT_COMMAND+x} ]] && [[ "$PROMPT_COMMAND" != "edkrepo_combo_chpwd" ]]; then
    old_prompt_command=$PROMPT_COMMAND
  fi
  old_pwd=$(pwd)
  edkrepo_combo_chpwd() {
      if [[ "$(pwd)" != "$old_pwd" ]]; then
        old_pwd=$(pwd)
        current_edkrepo_combo=$(command_completion_edkrepo current-combo)
        do_combo_check="0"
      elif [ "$do_combo_check" == "1" ]; then
        current_edkrepo_combo=$(command_completion_edkrepo current-combo)
        do_combo_check="0"
      fi
      if [[ ! -z ${PROMPT_COMMAND+x} ]]; then
        eval $old_prompt_command
      fi
  }
  PROMPT_COMMAND=edkrepo_combo_chpwd
fi

PS1="$newps1$prompt_suffix"
MSYS2_PS1="$PS1"  # for detection by MSYS2 SDK's bash.bashrc
