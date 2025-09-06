from lark import Lark, Transformer, v_args

with open("grammars/grammar.lark") as f:
    grammar = f.read()

parser = Lark(grammar, parser="lalr")

class DeclEnv:
    def __init__(self):
        self.vars =  {}
        self.funcs = {}
        self.objects = {}
        self.units = {
            "M": 1e6,
            "T": 1e12,
            "P": 1e15
        }

env = DeclEnv()

@v_args(inline=True)
class Eval(Transformer):
    def number(self, n): return float(n)
    def var(self, name): return env.vers.get(name.value, 0)

    def assign(self, name, value):
        env.vars[name.value] = value
    
    def declare_obj(self, name, obj):
        env.objects[name.value] = obj
    
    def obj(self, *items):
        return [s.strip("") for s in items]

    def func_def(self, name, expr):
        env.funcs[name.value] = expr

    def call(self, name, *args):
        if name.value in env.funcs:
            varname = "x"
            old = env.vars.get(varname)
            env.vars[varname] = args[0]
            result = self.transform(env.funcs[name.value])
            env.vars[varname] = old
            return result
        return 0

    def expr_expr(): pass
