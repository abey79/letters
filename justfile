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

# Render a single letter (both parts): `just one A`
one letter:
    @mkdir -p {{out}}
    @echo "  {{letter}} -> {{out}}/letter_{{letter}}_{body,outside}.stl"
    @{{openscad}} -q -o {{out}}/letter_{{letter}}_body.stl    -D 'letter="{{letter}}"' -D 'part="body"'    {{scad}}
    @{{openscad}} -q -o {{out}}/letter_{{letter}}_outside.stl -D 'letter="{{letter}}"' -D 'part="outside"' {{scad}}

# Render a preview PNG of a single letter: `just preview A`
preview letter:
    @mkdir -p {{out}}
    @{{openscad}} -q -o {{out}}/letter_{{letter}}.png \
        --imgsize=800,800 --colorscheme=Tomorrow \
        -D 'letter="{{letter}}"' {{scad}}

clean:
    rm -rf {{out}}
