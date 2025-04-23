using JuMP
using Gurobi

function build_biodisel_model(data_file::String, extra_parameters=false::Bool)
    # Enabeling dependency usage
    include(data_file)

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

    # Maximize earnings
    # simplifying earnings
    earnings = (product_price .* (100 .- product_tax) ./ 100)
    @objective(m, Max, sum( earnings[i]*x[i] for i in I) 
                        - methanol_price*methanol 
                        - petrol_price*petrol)
    # Balances
    petrol_ratio = (100 .- biodisel_percentage) ./ 100
    biodisel_ratio = biodisel_percentage./ 100

    # product = n*biodisel + (1-n)*petrol
    @constraint(m, biodisel == sum( x[i]*biodisel_ratio[i] for i in I ))
    @constraint(m, petrol == sum( x[i]*petrol_ratio[i] for i in I ))

    # biodisel = vegtable oil + methanol
    vegetable_oil = @expression(m, sum( oil_content[c]*y[c] for c in C ))
    @constraint(m, biodisel_produced*vegetable_oil == vegetable_oil_needed*biodisel)
    @constraint(m, biodisel_produced*methanol == methanol_needed*biodisel)

    
    # Constraints

    # Demand
    if product_constraint
        @constraint(m, sum( x[I] ) == product_demmand)
        #@constraint(m, [i=1:3], x[i] == product_demmand)
    end
    # Petrol limits
    if petrol_constraint
        @constraint(m, sum( petrol_ratio[i]*x[i] for i in I) <= petrol_limit)
    end
    # Methanol limits
    if methanol_constraint
        @constraint(m, methanol <= methanol_limit)
    end
    # Crops
    if land_constraint
        @constraint(m, sum( y[c] for c in C) <= land_limit)
    end
    if water_constraint
        @constraint(m, sum( water_demand[c]*y[c] for c in C) <= water_limit)
    end
    if extra_parameters
        return m, x, y, methanol, petrol, biodisel, vegetable_oil
    else
        return m, x, y
    end
end