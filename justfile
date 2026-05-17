projects := "letter-tags karcher-wd2-adapter"

default:
    @just --list

# Run a recipe in every project, e.g. `just each all` or `just each clean`.
each recipe:
    #!/usr/bin/env bash
    set -euo pipefail
    for p in {{projects}}; do
        echo "=== $p ==="
        (cd projects/$p && just {{recipe}})
    done

# Render every project's default artifacts.
all: (each "all")

# Wipe every project's build/ dir.
clean: (each "clean")

# Run a recipe in one project: `just p letter-tags one A`
p project +recipe:
    cd projects/{{project}} && just {{recipe}}
