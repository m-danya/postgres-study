from random import random, randint, choice
id = 1
ONE = 'оборудование для добычи'
TWO = 'транспорт'
cat = [ONE, TWO, TWO, ONE, ONE, ONE, TWO, ONE, ONE, TWO, ONE, ONE, ONE]

for i, c in enumerate(cat):
    # if c == ONE:
    #     print(f"({i + 1}, {randint(1, 100)}),")
    if c == TWO:
        print(f"({i + 1}, {randint(1, 100)}, {choice(['Low', 'Normal', 'High'])}),")