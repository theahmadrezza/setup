#!/usr/bin/env bash

# Script to maintain a clean repository history with a single commit and tag

# Enable strict mode: exit on error, exit on unset variable, fail on pipe errors
set -euo pipefail

# Function that resets git history to a single clean commit and force-pushes it
git_squash_all_history() {
    # Clear the terminal screen for a clean output view
    clear

    # Create a new orphan branch with no commit history (detached from all parents)
    git checkout --orphan temp_branch

    # Stage all files in the working directory, including new/modified/deleted ones
    git add -A

    # Create a single commit containing the current state of all staged files
    git commit -m "initial release"

    # Forcefully delete the old local main branch (which contains prior history)
    git branch -D main

    # Rename the current orphan branch (temp_branch) to main
    git branch -m main

    # Force-push the new single-commit main branch, overwriting remote history
    git push -f origin main

    # Force-create (or move) the tag "v1.0.0" to point at the new single commit
    git tag -f v1.0.0

    # Force-push the tag to the remote, overwriting any existing tag with the same name
    git push -f origin v1.0.0

    # Print a confirmation message once the sync process completes successfully
    echo "Repository synced: Single commit and tag maintained."
}

# Invoke the function to execute the clean-sync process
git_squash_all_history
