#
# Defines Git aliases.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

#
# Settings
#
#

#####################################
# Copied from oh-my-zsh lib/git.zsh #
#####################################
# Outputs current branch info in prompt format
function git_prompt_info() {
  local ref
  if [[ "$(command git config --get oh-my-zsh.hide-status 2>/dev/null)" != "1" ]]; then
    ref=$(command git symbolic-ref HEAD 2> /dev/null) || \
    ref=$(command git rev-parse --short HEAD 2> /dev/null) || return 0
    echo "$ZSH_THEME_GIT_PROMPT_PREFIX${ref#refs/heads/}$(parse_git_dirty)$ZSH_THEME_GIT_PROMPT_SUFFIX"
  fi
}

# Checks if working tree is dirty
function parse_git_dirty() {
  local STATUS=''
  local FLAGS
  FLAGS=('--porcelain')
  if [[ "$(command git config --get oh-my-zsh.hide-dirty)" != "1" ]]; then
    if [[ $POST_1_7_2_GIT -gt 0 ]]; then
      FLAGS+='--ignore-submodules=dirty'
    fi
    if [[ "$DISABLE_UNTRACKED_FILES_DIRTY" == "true" ]]; then
      FLAGS+='--untracked-files=no'
    fi
    STATUS=$(command git status ${FLAGS} 2> /dev/null | tail -n1)
  fi
  if [[ -n $STATUS ]]; then
    echo "$ZSH_THEME_GIT_PROMPT_DIRTY"
  else
    echo "$ZSH_THEME_GIT_PROMPT_CLEAN"
  fi
}

# Gets the difference between the local and remote branches
function git_remote_status() {
    local remote ahead behind git_remote_status git_remote_status_detailed
    remote=${$(command git rev-parse --verify ${hook_com[branch]}@{upstream} --symbolic-full-name 2>/dev/null)/refs\/remotes\/}
    if [[ -n ${remote} ]]; then
        ahead=$(command git rev-list ${hook_com[branch]}@{upstream}..HEAD 2>/dev/null | wc -l)
        behind=$(command git rev-list HEAD..${hook_com[branch]}@{upstream} 2>/dev/null | wc -l)

        if [[ $ahead -eq 0 ]] && [[ $behind -eq 0 ]]; then
            git_remote_status="$ZSH_THEME_GIT_PROMPT_EQUAL_REMOTE"
        elif [[ $ahead -gt 0 ]] && [[ $behind -eq 0 ]]; then
            git_remote_status="$ZSH_THEME_GIT_PROMPT_AHEAD_REMOTE"
            git_remote_status_detailed="$ZSH_THEME_GIT_PROMPT_AHEAD_REMOTE_COLOR$ZSH_THEME_GIT_PROMPT_AHEAD_REMOTE$((ahead))%{$reset_color%}"
        elif [[ $behind -gt 0 ]] && [[ $ahead -eq 0 ]]; then
            git_remote_status="$ZSH_THEME_GIT_PROMPT_BEHIND_REMOTE"
            git_remote_status_detailed="$ZSH_THEME_GIT_PROMPT_BEHIND_REMOTE_COLOR$ZSH_THEME_GIT_PROMPT_BEHIND_REMOTE$((behind))%{$reset_color%}"
        elif [[ $ahead -gt 0 ]] && [[ $behind -gt 0 ]]; then
            git_remote_status="$ZSH_THEME_GIT_PROMPT_DIVERGED_REMOTE"
            git_remote_status_detailed="$ZSH_THEME_GIT_PROMPT_AHEAD_REMOTE_COLOR$ZSH_THEME_GIT_PROMPT_AHEAD_REMOTE$((ahead))%{$reset_color%}$ZSH_THEME_GIT_PROMPT_BEHIND_REMOTE_COLOR$ZSH_THEME_GIT_PROMPT_BEHIND_REMOTE$((behind))%{$reset_color%}"
        fi

        if [[ -n $ZSH_THEME_GIT_PROMPT_REMOTE_STATUS_DETAILED ]]; then
            git_remote_status="$ZSH_THEME_GIT_PROMPT_REMOTE_STATUS_PREFIX$remote$git_remote_status_detailed$ZSH_THEME_GIT_PROMPT_REMOTE_STATUS_SUFFIX"
        fi

        echo $git_remote_status
    fi
}

# Outputs the name of the current branch
# Usage example: git pull origin $(git_current_branch)
# Using '--quiet' with 'symbolic-ref' will not cause a fatal error (128) if
# it's not a symbolic ref, but in a Git repo.
function git_current_branch() {
  local ref
  ref=$(command git symbolic-ref --quiet HEAD 2> /dev/null)
  local ret=$?
  if [[ $ret != 0 ]]; then
    [[ $ret == 128 ]] && return  # no git repo.
    ref=$(command git rev-parse --short HEAD 2> /dev/null) || return
  fi
  echo ${ref#refs/heads/}
}


# Gets the number of commits ahead from remote
function git_commits_ahead() {
  if command git rev-parse --git-dir &>/dev/null; then
    local commits="$(git rev-list --count @{upstream}..HEAD)"
    if [[ "$commits" != 0 ]]; then
      echo "$ZSH_THEME_GIT_COMMITS_AHEAD_PREFIX$commits$ZSH_THEME_GIT_COMMITS_AHEAD_SUFFIX"
    fi
  fi
}

# Gets the number of commits behind remote
function git_commits_behind() {
  if command git rev-parse --git-dir &>/dev/null; then
    local commits="$(git rev-list --count HEAD..@{upstream})"
    if [[ "$commits" != 0 ]]; then
      echo "$ZSH_THEME_GIT_COMMITS_BEHIND_PREFIX$commits$ZSH_THEME_GIT_COMMITS_BEHIND_SUFFIX"
    fi
  fi
}

# Outputs if current branch is ahead of remote
function git_prompt_ahead() {
  if [[ -n "$(command git rev-list origin/$(git_current_branch)..HEAD 2> /dev/null)" ]]; then
    echo "$ZSH_THEME_GIT_PROMPT_AHEAD"
  fi
}

# Outputs if current branch is behind remote
function git_prompt_behind() {
  if [[ -n "$(command git rev-list HEAD..origin/$(git_current_branch) 2> /dev/null)" ]]; then
    echo "$ZSH_THEME_GIT_PROMPT_BEHIND"
  fi
}

# Outputs if current branch exists on remote or not
function git_prompt_remote() {
  if [[ -n "$(command git show-ref origin/$(git_current_branch) 2> /dev/null)" ]]; then
    echo "$ZSH_THEME_GIT_PROMPT_REMOTE_EXISTS"
  else
    echo "$ZSH_THEME_GIT_PROMPT_REMOTE_MISSING"
  fi
}

# Formats prompt string for current git commit short SHA
function git_prompt_short_sha() {
  local SHA
  SHA=$(command git rev-parse --short HEAD 2> /dev/null) && echo "$ZSH_THEME_GIT_PROMPT_SHA_BEFORE$SHA$ZSH_THEME_GIT_PROMPT_SHA_AFTER"
}

# Formats prompt string for current git commit long SHA
function git_prompt_long_sha() {
  local SHA
  SHA=$(command git rev-parse HEAD 2> /dev/null) && echo "$ZSH_THEME_GIT_PROMPT_SHA_BEFORE$SHA$ZSH_THEME_GIT_PROMPT_SHA_AFTER"
}

# Get the status of the working tree
function git_prompt_status() {
  local INDEX STATUS
  INDEX=$(command git status --porcelain -b 2> /dev/null)
  STATUS=""
  if $(echo "$INDEX" | command grep -E '^\?\? ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_UNTRACKED$STATUS"
  fi
  if $(echo "$INDEX" | grep '^A  ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_ADDED$STATUS"
  elif $(echo "$INDEX" | grep '^M  ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_ADDED$STATUS"
  fi
  if $(echo "$INDEX" | grep '^ M ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_MODIFIED$STATUS"
  elif $(echo "$INDEX" | grep '^AM ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_MODIFIED$STATUS"
  elif $(echo "$INDEX" | grep '^ T ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_MODIFIED$STATUS"
  fi
  if $(echo "$INDEX" | grep '^R  ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_RENAMED$STATUS"
  fi
  if $(echo "$INDEX" | grep '^ D ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_DELETED$STATUS"
  elif $(echo "$INDEX" | grep '^D  ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_DELETED$STATUS"
  elif $(echo "$INDEX" | grep '^AD ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_DELETED$STATUS"
  fi
  if $(command git rev-parse --verify refs/stash >/dev/null 2>&1); then
    STATUS="$ZSH_THEME_GIT_PROMPT_STASHED$STATUS"
  fi
  if $(echo "$INDEX" | grep '^UU ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_UNMERGED$STATUS"
  fi
  if $(echo "$INDEX" | grep '^## [^ ]\+ .*ahead' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_AHEAD$STATUS"
  fi
  if $(echo "$INDEX" | grep '^## [^ ]\+ .*behind' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_BEHIND$STATUS"
  fi
  if $(echo "$INDEX" | grep '^## [^ ]\+ .*diverged' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_DIVERGED$STATUS"
  fi
  echo $STATUS
}

# Compares the provided version of git to the version installed and on path
# Outputs -1, 0, or 1 if the installed version is less than, equal to, or
# greater than the input version, respectively.
function git_compare_version() {
  local INPUT_GIT_VERSION INSTALLED_GIT_VERSION
  INPUT_GIT_VERSION=(${(s/./)1})
  INSTALLED_GIT_VERSION=($(command git --version 2>/dev/null))
  INSTALLED_GIT_VERSION=(${(s/./)INSTALLED_GIT_VERSION[3]})

  for i in {1..3}; do
    if [[ $INSTALLED_GIT_VERSION[$i] -gt $INPUT_GIT_VERSION[$i] ]]; then
      echo 1
      return 0
    fi
    if [[ $INSTALLED_GIT_VERSION[$i] -lt $INPUT_GIT_VERSION[$i] ]]; then
      echo -1
      return 0
    fi
  done
  echo 0
}

# Outputs the name of the current user
# Usage example: $(git_current_user_name)
function git_current_user_name() {
  command git config user.name 2>/dev/null
}

# Outputs the email of the current user
# Usage example: $(git_current_user_email)
function git_current_user_email() {
  command git config user.email 2>/dev/null
}

# This is unlikely to change so make it all statically assigned
POST_1_7_2_GIT=$(git_compare_version "1.7.2")
# Clean up the namespace slightly by removing the checker function
unfunction git_compare_version

# Log
zstyle -s ':prezto:module:git:log:medium' format '_git_log_medium_format' \
  || _git_log_medium_format='%C(bold)Commit:%C(reset) %C(green)%H%C(red)%d%n%C(bold)Author:%C(reset) %C(cyan)%an <%ae>%n%C(bold)Date:%C(reset)   %C(blue)%ai (%ar)%C(reset)%n%+B'
zstyle -s ':prezto:module:git:log:oneline' format '_git_log_oneline_format' \
  || _git_log_oneline_format='%C(green)%h%C(reset) %s%C(red)%d%C(reset)%n'
zstyle -s ':prezto:module:git:log:brief' format '_git_log_brief_format' \
  || _git_log_brief_format='%C(green)%h%C(reset) %s%n%C(blue)(%ar by %an)%C(red)%d%C(reset)%n'

# Status
zstyle -s ':prezto:module:git:status:ignore' submodules '_git_status_ignore_submodules' \
  || _git_status_ignore_submodules='none'

#
# Aliases
#

if ! zstyle -t ':prezto:module:git:alias' skip 'yes'; then
  # Git
  alias g='git'

  # Branch (b)
  alias gb='git branch'
  alias gba='git branch --all --verbose'
  alias gbc='git checkout -b'
  alias gbd='git branch --delete'
  alias gbD='git branch --delete --force'
  alias gbl='git branch --verbose'
  alias gbL='git branch --all --verbose'
  alias gbm='git branch --move'
  alias gbM='git branch --move --force'
  # alias gbr='git branch --move'
  # alias gbR='git branch --move --force'
  # Git Branch Recent
  alias gbr='git for-each-ref --count=10 --sort=-committerdate refs/heads/ --format="%(refname:short)"'
  alias gbs='git show-branch'
  alias gbS='git show-branch --all'
  alias gbv='git branch --verbose'
  alias gbV='git branch --verbose --verbose'
  alias gbx='git branch --delete'
  alias gbX='git branch --delete --force'

  # Commit (c)
  alias gc='git commit --verbose'
  alias gca='git commit --verbose --all'
  alias gcm='git commit --message'
  alias gcam='git commit --all --message'
  alias gco='git checkout'
  alias gcO='git checkout --patch'
  alias gcf='git commit --amend --reuse-message HEAD'
  alias gcF='git commit --verbose --amend'
  alias gcp='git cherry-pick --ff'
  alias gcP='git cherry-pick --no-commit'
  alias gcr='git revert'
  alias gcR='git reset "HEAD^"'
  alias gcs='git show'
  alias gcl='git-commit-lost'

  # Conflict (C)
  alias gCl='git --no-pager diff --name-only --diff-filter=U'
  alias gCa='git add $(gCl)'
  alias gCe='git mergetool $(gCl)'
  alias gCo='git checkout --ours --'
  alias gCO='gCo $(gCl)'
  alias gCt='git checkout --theirs --'
  alias gCT='gCt $(gCl)'

  # Data (d)
  alias gd='git ls-files'
  alias gdc='git ls-files --cached'
  alias gdx='git ls-files --deleted'
  alias gdm='git ls-files --modified'
  alias gdu='git ls-files --other --exclude-standard'
  alias gdk='git ls-files --killed'
  alias gdi='git status --porcelain --short --ignored | sed -n "s/^!! //p"'

  # Fetch (f)
  alias gf='git fetch'
  alias gfa='git fetch --all'
  alias gfc='git clone'
  alias gfm='git pull'
  alias gfr='git pull --rebase'

  # Flow (F)
  alias gFi='git flow init'
  alias gFf='git flow feature'
  alias gFb='git flow bugfix'
  alias gFl='git flow release'
  alias gFh='git flow hotfix'
  alias gFs='git flow support'

  alias gFfl='git flow feature list'
  alias gFfs='git flow feature start'
  alias gFff='git flow feature finish'
  alias gFfp='git flow feature publish'
  alias gFft='git flow feature track'
  alias gFfd='git flow feature diff'
  alias gFfr='git flow feature rebase'
  alias gFfc='git flow feature checkout'
  alias gFfm='git flow feature pull'
  alias gFfx='git flow feature delete'

  alias gFbl='git flow bugfix list'
  alias gFbs='git flow bugfix start'
  alias gFbf='git flow bugfix finish'
  alias gFbp='git flow bugfix publish'
  alias gFbt='git flow bugfix track'
  alias gFbd='git flow bugfix diff'
  alias gFbr='git flow bugfix rebase'
  alias gFbc='git flow bugfix checkout'
  alias gFbm='git flow bugfix pull'
  alias gFbx='git flow bugfix delete'

  alias gFll='git flow release list'
  alias gFls='git flow release start'
  alias gFlf='git flow release finish'
  alias gFlp='git flow release publish'
  alias gFlt='git flow release track'
  alias gFld='git flow release diff'
  alias gFlr='git flow release rebase'
  alias gFlc='git flow release checkout'
  alias gFlm='git flow release pull'
  alias gFlx='git flow release delete'

  alias gFhl='git flow hotfix list'
  alias gFhs='git flow hotfix start'
  alias gFhf='git flow hotfix finish'
  alias gFhp='git flow hotfix publish'
  alias gFht='git flow hotfix track'
  alias gFhd='git flow hotfix diff'
  alias gFhr='git flow hotfix rebase'
  alias gFhc='git flow hotfix checkout'
  alias gFhm='git flow hotfix pull'
  alias gFhx='git flow hotfix delete'

  alias gFsl='git flow support list'
  alias gFss='git flow support start'
  alias gFsf='git flow support finish'
  alias gFsp='git flow support publish'
  alias gFst='git flow support track'
  alias gFsd='git flow support diff'
  alias gFsr='git flow support rebase'
  alias gFsc='git flow support checkout'
  alias gFsm='git flow support pull'
  alias gFsx='git flow support delete'

  # Grep (g)
  alias gg='git grep'
  alias ggi='git grep --ignore-case'
  alias ggl='git grep --files-with-matches'
  alias ggL='git grep --files-without-matches'
  alias ggv='git grep --invert-match'
  alias ggw='git grep --word-regexp'

  # Index (i)
  alias gia='git add'
  alias giA='git add --patch'
  alias giu='git add --update'
  alias gid='git diff --no-ext-diff --cached'
  alias giD='git diff --no-ext-diff --cached --word-diff'
  alias gii='git update-index --assume-unchanged'
  alias giI='git update-index --no-assume-unchanged'
  alias gir='git reset'
  alias giR='git reset --patch'
  alias gix='git rm -r --cached'
  alias giX='git rm -rf --cached'

  # Log (l)
  alias gl='git log --topo-order --pretty=format:"${_git_log_medium_format}"'
  alias gls='git log --topo-order --stat --pretty=format:"${_git_log_medium_format}"'
  alias gld='git log --topo-order --stat --patch --full-diff --pretty=format:"${_git_log_medium_format}"'
  alias glo='git log --topo-order --pretty=format:"${_git_log_oneline_format}"'
  alias glg='git log --topo-order --all --graph --pretty=format:"${_git_log_oneline_format}"'
  alias glb='git log --topo-order --pretty=format:"${_git_log_brief_format}"'
  alias glc='git shortlog --summary --numbered'

  # Merge (m)
  alias gm='git merge'
  alias gmC='git merge --no-commit'
  alias gmF='git merge --no-ff'
  alias gma='git merge --abort'
  alias gmt='git mergetool'

  # Push (p)
  alias gp='git push origin $(git_current_branch)'
  alias gpf='git push --force-with-lease'
  alias gpF='git push --force'
  alias gpa='git push --all'
  alias gpA='git push --all && git push --tags'
  alias gpt='git push --tags'
  alias gpc='git push --set-upstream origin "$(git-branch-current 2> /dev/null)"'
  alias gpp='git pull origin "$(git-branch-current 2> /dev/null)" && git push origin "$(git-branch-current 2> /dev/null)"'

  # Rebase (r)
  alias gr='git rebase'
  alias gra='git rebase --abort'
  alias grc='git rebase --continue'
  alias gri='git rebase --interactive'
  alias grs='git rebase --skip'

  # Remote (R)
  alias gR='git remote'
  alias gRl='git remote --verbose'
  alias gRa='git remote add'
  alias gRx='git remote rm'
  alias gRm='git remote rename'
  alias gRu='git remote update'
  alias gRp='git remote prune'
  alias gRs='git remote show'
  alias gRb='git-hub-browse'

  # Stash (s)
  alias gs='git stash'
  alias gsa='git stash apply'
  alias gsx='git stash drop'
  alias gsX='git-stash-clear-interactive'
  alias gsl='git stash list'
  alias gsL='git-stash-dropped'
  alias gsd='git stash show --patch --stat'
  alias gsp='git stash pop'
  alias gsr='git-stash-recover'
  alias gss='git stash save --include-untracked'
  alias gsS='git stash save --patch --no-keep-index'
  alias gsw='git stash save --include-untracked --keep-index'

  # Submodule (S)
  alias gS='git submodule'
  alias gSa='git submodule add'
  alias gSf='git submodule foreach'
  alias gSi='git submodule init'
  alias gSI='git submodule update --init --recursive'
  alias gSl='git submodule status'
  alias gSm='git-submodule-move'
  alias gSs='git submodule sync'
  alias gSu='git submodule foreach git pull origin master'
  alias gSx='git-submodule-remove'

  # Subrepo (p)
  alias gpc='git subrepo clone'

  # Working Copy (w)
  alias gws='git status --ignore-submodules=${_git_status_ignore_submodules} --short'
  alias gwS='git status --ignore-submodules=${_git_status_ignore_submodules}'
  alias gwd='git diff --no-ext-diff'
  alias gwD='git diff --no-ext-diff --word-diff'
  alias gwr='git reset --soft'
  alias gwR='git reset --hard'
  alias gwc='git clean -n'
  alias gwC='git clean -f'
  alias gwx='git rm -r'
  alias gwX='git rm -rf'
fi

# git-checkout-branch
# Change branch using fzf.
function gcb() {
    new_branch=$(gb | fzf)
    no_spaces=$(echo $new_branch | tr -d ' ')
    gco $no_spaces
}

# Deletes all merged branches
function gdd() {
    git branch --merged | grep -v '^* master$' | grep -v '^  master$' | xargs -n 1 git branch -d
}
