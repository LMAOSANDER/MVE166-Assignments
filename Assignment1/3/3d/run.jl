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
    println("Optimal objective value diffrence: $(548163.0342857142-JuMP.objective_value(m))")
    # println(dual(petrol_constraint))
else
    println("No optimal slution available")
end

# print(sensitivity_report[petrol_constraint])