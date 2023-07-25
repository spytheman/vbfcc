module generators

/*
** C99 Generator (Accidentally works with C89 too)
*/

const (
	cgen_prelude_c99  = $embed_file('generators/preludes/cgen_c99.c')
	cgen_postlude_c99 = $embed_file('generators/postludes/cgen_c99.c')
)

// C99 Generator
// No data is stored in the struct
struct CGenBackend {}

// Generate the code
fn (cgen CGenBackend) generate_code(options CodeGenInterfaceOptions) ! {
	mut output := '/* Generated by BFCC */\n\n'
	output += generators.cgen_prelude_c99.to_string()

	for tok in options.il {
		output += match tok.type_token {
			.move_right {
				'\tptr += ${tok.value};'
			}
			.move_left {
				'\tptr -= ${tok.value};'
			}
			.add {
				'\tmemory[ptr] += ${tok.value};'
			}
			.sub {
				'\tmemory[ptr] -= ${tok.value};'
			}
			.exit {
				'\treturn 0;'
			}
			.jump_if_zero {
				'label_${tok.id}:\n\tif (memory[ptr] == 0) goto label_${tok.value};'
			}
			.jump_if_not_zero {
				'\tif (memory[ptr] != 0) goto label_${tok.value};\nlabel_${tok.id}:'
			}
			.input {
				'\tmemory[ptr] = getchar();'
			}
			.output {
				'\tputchar(memory[ptr]);'
			}
		} + '\n'
	}

	output += generators.cgen_postlude_c99.to_string()

	// Write the file
	write_code_to_single_file_or_stdout(output, options.output_file, options.print_stdout) or {
		return error('Failed to write code to file')
	}
}
