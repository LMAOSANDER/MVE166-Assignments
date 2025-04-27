# Ev. use struct later?

# Biodisel parameters
biodisel_produced = 0.9 #[l]
vegetable_oil_needed = 1 #[l]
methanol_needed = 0.2 #[l]

# Methanol parameters
methanol_price = 1.5 #[€/l]

# Petrol parameters
petrol_price = 1 #[€/l]
# constraints
petrol_limit = 150_000 #[l]

# Crop parameters
C = 1:3
crops = ["Soybeans", "Sunflower seeds", "Cotton seeds"]
yeild = [2.6, 1.4, 0.9] #[t/ha]
water_demand = [5.0, 4.2, 1.0] #[Ml/ha]
oil_content = [0.178, 0.216, 0.433].*1000 #[l/t]
# constraints
water_limit = 5_000 #[l]
land_limit = 1_600 #[ha]


# Product parameters
I = 1:3
products = ["B5", "B30", "B100"]
biodisel_percentage = [5, 30, 100] #[%]
product_price = [1.43, 1.29, 1.16] #[€/l]
product_tax = [20.0, 5.0, 0.0] #[%]
# constraints
product_demmand = 280_000 #[l]

