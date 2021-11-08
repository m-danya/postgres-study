from random import random, randint
id = 1
ONE = 'оборудование для добычи'
TWO = 'транспорт'
cat = [ONE, TWO, TWO, ONE, ONE, ONE, TWO, ONE, ONE, TWO, ONE, ONE, ONE]

# (id, equipment_model_id, decommissioning_year)
for i in range(10):
    year = randint(2024, 2046)
    for j in range(randint(1, 3)):
        model = randint(1, 10)
        print(f"({id}, {model}, {year}), -- {cat[model - 1]}")
        id += 1