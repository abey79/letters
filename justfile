out := "build"
scad := "letter_tag.scad"
letters := "A B C D E F G H I J K L M N O P Q R S T U V W X Y Z"
jobs := `nproc 2>/dev/null || echo 4`
openscad := env_var_or_default("OPENSCAD", `command -v openscad 2>/dev/null || command -v OpenSCAD 2>/dev/null || echo /Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD`)

# Render all 26 STLs into `build/` in parallel.
default: all

all:
    @mkdir -p {{out}}
    @echo "Rendering 26 letters with up to {{jobs}} parallel jobs..."
    @echo {{letters}} | tr ' ' '\n' | xargs -P{{jobs}} -I{} just one {}

# Render a single letter (both bodies in one 3MF): `just one A`
one letter:
    @mkdir -p {{out}}
    @echo "  {{letter}} -> {{out}}/letter_{{letter}}.3mf"
    @{{openscad}} -q --enable=lazy-union -o {{out}}/letter_{{letter}}.3mf \
        -O export-3mf/material-type=color \
        -D 'letter="{{letter}}"' {{scad}}

# Render a preview PNG of a single letter: `just preview A`
preview letter:
    @mkdir -p {{out}}
    @{{openscad}} -q -o {{out}}/letter_{{letter}}.png \
        --imgsize=800,800 --colorscheme=Tomorrow \
        -D 'letter="{{letter}}"' {{scad}}

# Regenerate README images (preview + cutaway) via OpenSCAD + PyVista.
docs:
    @mkdir -p {{out}}/docs
    @{{openscad}} -q -o {{out}}/docs/A_body.stl    -D 'letter="A"' -D 'part="body"'    {{scad}}
    @{{openscad}} -q -o {{out}}/docs/A_outside.stl -D 'letter="A"' -D 'part="outside"' {{scad}}
    @uv run docs/render.py {{out}}/docs/A_body.stl {{out}}/docs/A_outside.stl docs/preview.png preview
    @uv run docs/render.py {{out}}/docs/A_body.stl {{out}}/docs/A_outside.stl docs/cutaway.png cutaway

clean:
    rm -rf {{out}}
