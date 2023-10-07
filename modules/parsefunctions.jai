// #import "uniform"; not needed yet and may never be
fc: u64 = 0;
rc: u64 = 0;
parse_lit :: (token: Token) -> Node {
    expr: Expression;
    children: [..]Node;
    expr.variableExpr = .{token.expr};
    return .{.Literal, expr, children};
}

parse_return :: (toks: [..]Token, it: int) -> Node {
    children: [..]Node;
    array_add(*children, parse_lit(toks[it + 1]));
    expr: Expression;
    rc += 1;
    expr.returnExpr = .{rc};

    return .{.Return, expr, children};
}

parse_function :: (toks: [..]Token, it: int) -> Node, u64 {
    scope_end := find_indexof_from_index(toks, it, .RBRACK);
    if scope_end == 0 {
        exit(1);
    }
    // almost all operations should be done on this array
    tslice := slice_arr(toks, it, cast(int) scope_end);
    children := parse_node(tslice);
    expr: Expression;
    fc += 1;
    expr.functionExpr = .{fc};
    return .{.Function, expr, children}, scope_end;
}

nodes_to_string :: (nodearr: []Node) -> string {
    str: String_Builder;
    append(*str, "[");
    for nodearr {
        append(*str, "{");
        if it.kind == {
            case .Literal;
            print_to_builder(*str, "Literal: %", it.value.variableExpr);

            case .Return;
            print_to_builder(*str, "Return: %", it.value.returnExpr);

            case .Function;
            print_to_builder(*str, "Function: %", it.value.functionExpr);
        }
        append(*str, ", ");
        children := nodes_to_string(it.children); // recursively make children to string
        append(*str, children);
        append(*str, "}");
        // Not last node
        if it_index < nodearr.count - 1 {
            append(*str, ", ");
        }
    }
    append(*str, "]");
    return builder_to_string(*str);
}

#import "parser";
#import "lexer";
#import "Basic";
#import "arrextras";
