using JuMP
using Gurobi

include("model.jl")

# Create model
m, x, y, methanol, petrol, biodisel, vegetable_oil = build_biodisel_model("data.jl",true)

set_optimizer(m, Gurobi.Optimizer)


print(m)

optimize!(m)

# sensitivity_report = lp_sensitivity_report(m)

# Solution
if termination_status(m) == JuMP.OPTIMAL
    println("Optimal objective value: $(JuMP.objective_value(m))")
    println("x=", value.(x.data))
    println("y=", value.(y.data))
    println("methanol=", value(methanol))
    println("petrol=", value(petrol))
    println("biodisel=", value(biodisel))
    println("vegetable_oil=", value(vegetable_oil))
else
    println("No optimal slution available")
end

# print(sensitivity_report[x[3]])