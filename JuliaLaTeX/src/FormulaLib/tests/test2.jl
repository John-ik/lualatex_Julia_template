struct Test
    it::Any
    # Test(it)=Expr(:call,new(it))
end
(it::Test)() = eval(it.it)
# Core.eval(m::Module, it::Test) = Core.eval(m, it.it)
