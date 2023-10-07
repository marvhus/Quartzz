main :: () {
    args := get_command_line_arguments();
    if args.count < 2 {
        print("Sorry you need to tell the compiler what to compile!\n");
        exit(1);
    }

    file := read_entire_file(args[1]);
    if !file then exit(1);

    lex: Lexer;
    lex.source = file;
    lex.tokens = tokenize(lex.source);
    parse(lex.tokens);
}

#import "Basic";
#import "File";
#import "lexer";
#import "parser";
