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

println(sensitivity_report[petrol_constraint])
println(sensitivity_report[water_constraint])
println(sensitivity_report[land_constraint])



let stop = [], vars = [petrol_constraint, land_constraint, water_constraint]
    for var in vars
        let model = m, change = Dict()
        change = Dict(name(var) => sensitivity_report[var][1])
        push!(stop, name(var))
        while termination_status(model) == JuMP.OPTIMAL
            model, variables, constraints = build_biodisel_model("data.jl",true,true,change)
            x, y, methanol, petrol, biodisel, vegetable_oil = variables
            Demand, petrol_constraint, land_constraint, water_constraint = constraints

            set_silent(model)
            set_optimizer(model, Gurobi.Optimizer)
            optimize!(model)
            
            if termination_status(model) == JuMP.OPTIMAL

                sensitivity_report = lp_sensitivity_report(model)
                sensitivity_report[petrol_constraint]

                local x1 = sensitivity_report[petrol_constraint]
                local x2 = sensitivity_report[land_constraint]
                local x3 = sensitivity_report[water_constraint]
                println(x1,"\n",x2,"\n",x3)

                if name(var) == name(petrol_constraint)
                    change[name(var)] += x1[1] - 0.00001
                elseif name(var) == name(land_constraint)
                    change[name(var)] += x2[1] - 0.00001
                elseif name(var) == name(water_constraint)
                    change[name(var)] += x3[1] - 0.00001
                end
                println()
            else
                println(change[name(var)])
                push!(stop, change[name(var)])
                println(name(var))
                println(water_limit)
                println("\n","\n","\n","\n")
            end
        end
        end
    end
    stop[2] += 150_000
    stop[4] += 1_600
    stop[6] += 5_000
    println(petrol_limit, "\n", land_limit, "\n", water_limit)
println(stop)
end

    
