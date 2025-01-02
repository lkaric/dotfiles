# Dotfiles Setup Guide

This guide will walk you through the process of setting up your dotfiles using the `init.sh` script from the [dotfiles repository](https://github.com/lkaric/dotfiles) by lkaric.

## Prerequisites

Before you begin, make sure you have the following prerequisites installed on your system:

- **Git**: You can download and install Git from the official website: [https://git-scm.com/](https://git-scm.com/)

- **Chezmoi**: You can download and install Chezmoi following the official instructions: [https://chezmoi.io/](https://chezmoi.io/)

## Setup

Initial setup

```sh
$chezmoi init --apply lkaric
```

Pull the latest changes

```sh
$ chezmoi update
```
