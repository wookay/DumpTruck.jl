# Preferences
# https://github.com/JuliaPackaging/Preferences.jl

# JET
# https://github.com/aviatesk/JET.jl

using Preferences
if Preferences.load_preference("JET", "JET_DEV_MODE") != true
    Preferences.set_preferences!("JET", "JET_DEV_MODE" => true)
end

using JET: JET
using .JET: ReportConfig, @report_call

using Jive

@time_expr @report_call 1+2
println()

using DumpTruck
function dumping()
    dump(  :(1 + 2)  )
end

using DumpTruck
report_config = ReportConfig(#=target_modules=#(DumpTruck,), #=ignored_modules=#())
@time_expr report = @report_call report_config=report_config dumping()
show(report)

if string(report) != "No errors detected\n"
    throw(ErrorException("`JET.@report_call dump` found errors"))
end

