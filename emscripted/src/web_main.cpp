#include "interpreter/interpreter.hpp"
#include "lexer/lexer.hpp"
#include "parser/parser.hpp"

#include <emscripten/emscripten.h>
#include <iostream>

// run_vo(source) — called from JS.
// Output goes to stdout, which Emscripten routes to Module.print.
// JS captures it by temporarily overriding Module.print before the call.
// Errors are written to stdout so they appear in the same output area.
extern "C" {

EMSCRIPTEN_KEEPALIVE
void run_vo(const char* source) {
    try {
        lang::Lexer  lexer(source);
        lang::Parser parser(lexer.tokenize());
        auto         program = parser.parse();
        lang::Interpreter interp(false);
        interp.run(program);
    } catch (const std::exception& e) {
        std::cout << "Error: " << e.what() << "\n";
    } catch (...) {
        std::cout << "Error: unknown exception\n";
    }
    std::cout.flush();
}

} // extern "C"
