from random import randint
lst = []
with open('names.txt') as file:
    for line in file:
        s = line.split()
        name = " ".join(s[:3])
        dob = s[3]
        #(name, date_of_birth, point_id, salary)
        print(f"('{name}', '{dob}', {randint(1, 10)}, {randint(15000, 150000)}),")
