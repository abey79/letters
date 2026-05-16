out := "build"
scad := "letter_tag.scad"
letters := "A B C D E F G H I J K L M N O P Q R S T U V W X Y Z"
jobs := `nproc 2>/dev/null || echo 4`

# Render all 26 STLs into `build/` in parallel.
default: all

all:
    @mkdir -p {{out}}
    @echo "Rendering 26 letters with up to {{jobs}} parallel jobs..."
    @echo {{letters}} | tr ' ' '\n' | xargs -P{{jobs}} -I{} just one {}

# Render a single letter: `just one A`
one letter:
    @mkdir -p {{out}}
    @echo "  {{letter}} -> {{out}}/letter_{{letter}}.stl"
    @openscad -q -o {{out}}/letter_{{letter}}.stl -D 'letter="{{letter}}"' {{scad}}

# Render a preview PNG of a single letter: `just preview A`
preview letter:
    @mkdir -p {{out}}
    @openscad -q -o {{out}}/letter_{{letter}}.png \
        --imgsize=800,800 --colorscheme=Tomorrow \
        -D 'letter="{{letter}}"' {{scad}}

clean:
    rm -rf {{out}}
