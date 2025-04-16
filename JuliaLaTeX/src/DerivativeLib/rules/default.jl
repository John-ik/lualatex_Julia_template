# module DefaultRules
# using .DefineRuleMacro

@rule sin(x) cos(x) * x'
@rule cos(x) -sin(x) * x'
@rule sinpi(x) cospi(x) * π * x'
@rule cospi(x) -sinpi(x) * π * x'
@rule sincos(x) ((sin(x))', (cos(x))')
@rule sincospi(x) ((sinpi(x))', (cospi(x))')

@rule rad2deg(x) 180 / π * x'
@rule deg2rad(x) π / 180 * x'

@rule tan(x) x' / (cos(x)^2)
@rule cot(x) -x' / (sin(x)^2)


@rule expm1(x) exp(x) * x'
@rule exp(x) exp(x) * x'
@rule exp2(x) log(2) * exp2(x) * x'
@rule exp10(x) log(10) * exp10(x) * x'
# @rule Base.Math.exp_fast(x) Base.Math.exp_fast(x) * x'
# @rule Base.Math.exp2_fast(x) log(2) * Base.Math.exp2_fast(x) * x'
# @rule Base.Math.exp10_fast(x) log(10) * Base.Math.exp10_fast(x) * x'


@rule sqrt(x) 1 / (x^(1 / 2) * 2)


@rule log(x) x' / x
@rule log10(x) x' / (log(10) * x)
@rule log2(x) x' / (log(2) * x)
@rule log1p(x) x' / (1 + x)


# end