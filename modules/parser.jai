LiteralExpr :: struct {
    value: string;
}

ReturnExpr :: struct {
    count: u64;
}

FunctionExpr :: struct {
    count: u64;
}

Expression :: union {
    variableExpr: LiteralExpr;
    returnExpr:   ReturnExpr;
    functionExpr: FunctionExpr;
}

Node :: struct {
    kind: enum {
        Literal;
        Return;
        Function;
    };
    value: Expression;
    children : [..] Node;
}

AST :: struct {
    root: Node;
}

parse_node :: (tokens: [..]Token) -> [..]Node #expand {
    nodearr:[..] Node;
    for 0..tokens.count - 1 {
        if tokens[it].type == {
            case .RET; array_add(*nodearr, parse_return(tokens,it));
            case .LIT; array_add(*nodearr, parse_lit(tokens[it]));
            case;;
        }
    }
    return nodearr;
}

parse :: (tokens: [..]Token) -> AST
{
    nodearr: [..]Node;
    for 0..tokens.count - 1 {
        if tokens[it].type == {
            case .RET; 
            array_add(*nodearr, parse_return(tokens,it));

            case .LIT;
            array_add(*nodearr, parse_lit(tokens[it]));

            case .FUNC;
            node, skip := parse_function(tokens,it);
            array_add(*nodearr, node);
            it += cast(s64) skip;
        }
    }
    print("Succesfully parsed % tokens\nnodearr: %\n", tokens.count, nodes_to_string(nodearr));
    ast: AST = .{nodearr[0]};
    return ast;
}

// "Growing trees?!    I thought this was computer science not botany class"

#import "parsefunctions";
#import "lexer";
#import "Basic";
#import "File";
