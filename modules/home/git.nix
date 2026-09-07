{ user, ... }:
let
  dots = user.dotfiles;

  # Work identity (GitHub account mladenctrl, org github.com/mladenctrl).
  # Change name/email here if commits should carry a different address.
  hiveyard = {
    name = "Mladen Karadzić";
    email = "290313393+mladenctrl@users.noreply.github.com";
    signingkey = "~/.ssh/hiveyard.pub";
  };

  # Git matches the URL as written in .git/config; insteadOf rewrites are NOT
  # applied before includeIf, so cover every spelling.
  hiveyardRemotes = [
    "hasconfig:remote.*.url:git@github.com:mladenctrl/**"
    "hasconfig:remote.*.url:https://github.com/mladenctrl/**"
    "hasconfig:remote.*.url:git@github-hiveyard:mladenctrl/**"
  ];
in
{
  programs.git = {
    enable = true;

    signing = {
      format = "ssh";
      key = "~/.ssh/personal.pub";
      # Both pubkeys must be registered as Signing keys on GitHub for the
      # Verified badge; locally keys/allowed_signers verifies them.
      signByDefault = true;
    };

    includes = map (condition: {
      inherit condition;
      contents = {
        user = hiveyard;
        # TODO: flip to true once keys/hiveyard.pub is registered as a Signing
        # key on the work GitHub account (unverified signatures can be rejected
        # by branch protection).
        commit.gpgsign = false;
      };
    }) hiveyardRemotes;

    ignores = [
      ".DS_Store"
      "**/.claude/settings.local.json"
    ];

    settings = {
      # Personal identity (GitHub account lkaric) is the default.
      user = {
        name = "Lazar Karić";
        email = "16634314+lkaric@users.noreply.github.com";
      };

      alias = {
        a = "add";
        ap = "add -p";
        amc = "am --continue";
        b = "branch";
        bm = "branch --merged";
        bnm = "branch --no-merged";
        c = "clone";
        ca = "commit --amend";
        cane = "commit --amend --no-edit";
        cf = "commit --fixup";
        cm = "commit --message";
        co = "checkout";
        cob = "checkout -b";
        com = "checkout master";
        cp = "cherry-pick";
        d = "diff";
        dc = "diff --cached";
        dom = "diff origin/master";
        fo = "fetch origin";
        g = "grep --line-number";
        mbhom = "merge-base HEAD origin/master";
        mff = "merge --ff-only";
        ol = "log --pretty=oneline";
        lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
        p = "push";
        pf = "push --force";
        prb = "pull --rebase";
        r = "restore";
        ra = "rebase --abort";
        rc = "rebase --continue";
        ri = "rebase --interactive";
        rl = "reflog";
        riom = "rebase --interactive origin/master";
        rpo = "remote prune origin";
        s = "status -sb";
        ss = "commit --message snapshot --no-gpg-sign";
        su = "submodule update";
        wd = "diff --patience --word-diff";
      };

      init.defaultBranch = "main";
      core = {
        editor = "nvim";
        whitespace = "trailing-space,space-before-tab";
      };
      color.ui = "auto";
      advice = {
        addEmptyPathspec = false;
        pushNonFastForward = false;
        statusHints = true;
      };
      diff = {
        algorithm = "histogram";
        renamelimit = 8192;
        renames = "copies";
      };
      fetch = {
        prune = true;
        fsckobjects = false;
      };
      receive.fsckobjects = true;
      transfer.fsckobjects = true;
      push.default = "current";
      rebase = {
        autosquash = true;
        autostash = true;
      };
      pager = {
        branch = false;
        grep = false;
      };
      status.submoduleSummary = true;
      trim.bases = "main,master,gh-pages";
      gpg.ssh.allowedSignersFile = "${dots}/keys/allowed_signers";
      # Any clone of the work org goes over the hiveyard key automatically.
      url."git@github-hiveyard:mladenctrl/".insteadOf = "git@github.com:mladenctrl/";
    };
  };
}
