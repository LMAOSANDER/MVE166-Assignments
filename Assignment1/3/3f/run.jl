using JuMP
using Gurobi

include("model.jl")

# Create model
# new_values = Dict("Demand" =>, "Petrol_limit" =>, "Land_limit" =>, "Water_limit" =>)

m, variables, constraints = build_biodisel_model("data.jl",true,false,Dict())

set_optimizer(m, Gurobi.Optimizer)
print(m)
optimize!(m)
x, y, methanol, petrol, biodisel, vegetable_oil = variables
Demand, petrol_constraint, land_constraint, water_constraint = constraints

sensitivity_report = lp_sensitivity_report(m)

# # Solution
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

println(sensitivity_report[water_constraint])
println((water_limit/(water_limit+sensitivity_report[water_constraint][1])-1)*water_demand[1])



    
