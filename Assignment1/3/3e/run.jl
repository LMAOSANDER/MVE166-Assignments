using JuMP
using Gurobi

include("model.jl")

# Create model
# new_values = Dict("Demand" =>, "petrol_constraint" =>, "land_constraint" =>, "water_constraint" =>)

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

println(sensitivity_report[x[1]])
println(sensitivity_report[x[2]])
println(sensitivity_report[x[3]])


let stop = [], vars = [1, 2, 3], x_orig = x, sensitivity = sensitivity_report
    for var in vars
        for type in [1, 2]
        let model = m, change = Dict()
        current_change = sensitivity[x_orig[var]][type]
        println("var: ", var, " type: ", type, " coeficient_change: ", current_change)
        change = Dict("x$(var)_tax_modifier" => current_change)
        push!(stop, "x$(var), type: $(type), coeficient_change: $(current_change), objective_value_change:")
        if !(isinf(current_change)) #termination_status(model) == JuMP.OPTIMAL
            model, variables, constraints = build_biodisel_model("data.jl",true,true,change)
            x, y, methanol, petrol, biodisel, vegetable_oil = variables
            Demand, petrol_constraint, land_constraint, water_constraint = constraints

            set_silent(model)
            set_optimizer(model, Gurobi.Optimizer)
            optimize!(model)
            
            if termination_status(model) == JuMP.OPTIMAL
                push!(stop, objective_value(model) - objective_value(m))
                println("Optimal objective value: ", objective_value(model))
                println("x=", value.(x.data))
                println("y=", value.(y.data))
                println("methanol=", value(methanol))
                println("petrol=", value(petrol))
                println("biodisel=", value(biodisel))
                println("vegetable_oil=", value(vegetable_oil))
            else
                println("error")
            end
            println()
        end
        end
        end
    end
for idx in range(1,length(stop))
    println(stop[idx])
end
end

    
