using JuMP
using Gurobi

function build_biodisel_model(data_file::String, extra_parameters=false::Bool, have_other_values=false::Bool, change=Dict()::Dict(){String, Float})
    # Enabeling dependency usage
    include(data_file)


    if have_other_values
        if haskey(change, "petrol_constraint")
            global petrol_limit += change["petrol_constraint"]
        end
        if haskey(change, "water_constraint")
            global water_limit += change["water_constraint"]
        end
        if haskey(change, "land_constraint")
            global land_limit += change["land_constraint"]
        end
        if haskey(change, "x1_tax_modifier")
            global product_tax[1] -= 100/product_price[1]*change["x1_tax_modifier"]
        end
        if haskey(change, "x2_tax_modifier")
            global product_tax[2] -= 100/product_price[2]*change["x2_tax_modifier"]
        end
        if haskey(change, "x3_tax_modifier")
            global product_tax[3] -= 100/product_price[3]*change["x3_tax_modifier"]
        end
    end
    println("product_tax", product_tax)

    # Creating model
    m = Model()
    
    # Creating variables
    # liters of product
    @variable(m, x[I] >= 0)
    # liters of Methanol
    @variable(m, methanol >= 0)
    # liters of Petrol
    @variable(m, petrol >= 0)
    # liters of biodisel
    @variable(m, biodisel >= 0)
    # ha of crops planted Crops
    @variable(m, y[C] >= 0)

    # Goal: Maximize profit
    # simplifying product profit
    product_profit = (product_price .* ((100 .- product_tax) ./ 100))
    @objective(m, Max, sum( product_profit[i]*x[i] for i in I) 
                        - methanol_price*methanol 
                        - petrol_price*petrol)
    # Balances
    petrol_ratio = (100 .- biodisel_percentage) ./ 100
    biodisel_ratio = biodisel_percentage./ 100
    

    # product = n*biodisel + (1-n)*petrol
    @constraint(m, biodisel == sum( x[i]*biodisel_ratio[i] for i in I ))
    @constraint(m, petrol == sum( x[i]*petrol_ratio[i] for i in I ))


    # biodisel = vegtable oil + methanol
    vegetable_oil = @expression(m, sum( yeild[c]*oil_content[c]*y[c] for c in C ))
    @constraint(m, biodisel_produced*vegetable_oil == vegetable_oil_needed*biodisel)
    @constraint(m, biodisel_produced*methanol == methanol_needed*biodisel)
    
    # Constraints

    # Demand
    @constraint(m, Demand, sum( x[I] ) >= product_demmand)

    # Petrol limits
    @constraint(m, petrol_constraint, sum( petrol_ratio[i]*x[i] for i in I) <= petrol_limit)

    # Crops
    @constraint(m, land_constraint, sum( y[c] for c in C) <= land_limit)
    @constraint(m, water_constraint, sum( water_demand[c]*y[c] for c in C) <= water_limit)

    variabels = (x, y, methanol, petrol, biodisel, vegetable_oil)
    constraints = (Demand, petrol_constraint, land_constraint, water_constraint)

    if extra_parameters
        return m, variabels, constraints
    else
        return m
    end
end