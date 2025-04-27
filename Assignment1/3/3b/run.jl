using JuMP
using Gurobi

include("model.jl")

# Create model
m, variables, constraints = build_biodisel_model("data.jl",true,false,Dict())

set_optimizer(m, Gurobi.Optimizer)
print(m)
optimize!(m)
x, y, methanol, petrol, biodisel, vegetable_oil = variables
Demand, petrol_constraint, land_constraint, water_constraint = constraints


# sensitivity_report = lp_sensitivity_report(m)

# Solution
if termination_status(m) == JuMP.OPTIMAL
    println(shadow_price(petrol_constraint))
    println(shadow_price(land_constraint))
    println(shadow_price(water_constraint))
else
    println("No optimal slution available")
end

# print(sensitivity_report[x[3]])