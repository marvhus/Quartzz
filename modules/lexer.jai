Token :: struct {
    type: TokenType;
    expr: string;
    pos: int;
}

TokenType :: enum u8 {
    RET :: 255;
    LIT :: 254;
    FUNC :: 253;
    MAIN_TAG :: 252;
    RBRACK :: 251;
    LBRACK :: 250;
    LPAREN :: 249;
    RPAREN :: 248;
    IDENT :: 247;
    EMPTYARGS :: 246;
    NOTHING :: 1;
    UNKNOWN :: 0;
}

Lexer :: struct {
    tokens: [..] Token; // resizable array of tokens
    source: string;
}

// doesnt remove spaces
remove_nl :: (str:string) -> string {
    s := str;
    // different os's have different newlines (fuck you windows)
    for 0..s.count - 1 {
        if s[it] == #char "\r" || s[it] == #char "\n" { 
            string_remove_by_index(*s,it);
        }
    }
    // more print debugging
    //print("%\n",s);
    return s;
}

// simple preprocessing
format_str :: (str: string, line: bool) -> []string {
    if line {
        // copy of str to preserve str incase we need to cross-reference
        cpstr := remove_nl(str);
        parsed := split(cpstr, " ");
        return parsed;
    }
    cpstr := remove_nl(str);
    parsed := split(cpstr, ";");
    return parsed;
}

// Function to help handle the default case,old method was getting to big
handle_default :: (str: string,line:int,tokens: [..] Token,it:int) -> Token {
    if str.count > 0 {
        if is_digit(str[0]) {
            return Token.{.LIT, str, line};
        }
        if tokens[it - 1].type == TokenType.FUNC {
            return Token.{.IDENT, str, line};
        }
        s: string = str;
        // remove first char
        s.data += 1;
        s.count -= 1;
        return smoltokenize(s,line);
    }
    return Token.{.NOTHING, str, line};
}

lexer_error :: (tokens: [..]Token) -> [..]Token {
    toks := tokens;
    for 0..toks.count - 1 {
        if toks[it].type == 1 {
            array_ordered_remove_by_index(*toks, it);
        } else if toks[it].type == 0 {
            print("Unknown Token found on line %:\n%\n", toks[it].pos, toks[it].expr);
            print("could not continue compiling due to the errors above\n");
            exit(1);
        }
    }
    return toks;
}

// Turn string into tokens
tokenize :: (src: string) -> [..]Token {
    tokens: [..]Token;
    line: int = 1;
    error: bool = false;
    srccp := format_str(src, false);
    for 0..srccp.count - 1 {
        // split each line on a space and then match since we are going line by line here
        str := format_str(srccp[it], true);
        for 0..str.count - 1 {
            // switch on token
            if str[it] =={
                case "return"; array_add(*tokens,Token.{.RET,       "", line});
                case "{";      array_add(*tokens,Token.{.LBRACK,    "", line});
                case "}";      array_add(*tokens,Token.{.RBRACK,    "", line});
                case "(";      array_add(*tokens,Token.{.LPAREN,    "", line});
                case ")";      array_add(*tokens,Token.{.RPAREN,    "", line});
                case "()";     array_add(*tokens,Token.{.EMPTYARGS, "", line});
                case "!!";     array_add(*tokens,Token.{.MAIN_TAG,  "", line});
                case "func";   array_add(*tokens,Token.{.FUNC,      "", line});
                case; array_add(*tokens, handle_default(str[it], line, tokens,it));
            }
        }
        line += 1;
    }
    toks_error_checked := lexer_error(tokens);
    print("Succesfully lexed the file\n");
    return toks_error_checked;
}

// Keep in sync with @tokenize
smoltokenize :: (tok: string, line: int) -> Token {
    if tok == {
        case "return"; return Token.{.RET,      "", line};
        case "{";      return Token.{.LBRACK,   "", line};
        case "}";      return Token.{.RBRACK,   "", line};
        case "(";      return Token.{.LPAREN,   "", line};
        case ")";      return Token.{.RPAREN,   "", line};
        case "()";     return Token.{.EMPTYARGS,"", line};
        case "!!";     return Token.{.MAIN_TAG, "", line};
        case "func";   return Token.{.FUNC,     "", line};
        case;          return Token.{.UNKNOWN, tok, line};
    }
}

#import "stringextras";
#import "String";
#import "Basic";
