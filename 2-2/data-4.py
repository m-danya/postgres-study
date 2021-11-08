from random import randint
from random import random

names = ['1Мультифазный перекачивающий  насос двухвинтовый 2ВВ', # нефть
        '2Цементировочный агрегат ЦА-320 (АЦ-32) на шасси УРАЛ 4320', # транспорт
        '3Агрегат для исследования скважин АИС-1 на Урал 4320',# транспорт
        '4Буровой насос F-1300', # нефть
        '5Устьевые елки Ду 65 мм АФК 2 с двумя дополнительными задвижками на рабочее давление 21,35 Мпа', # газ
        '6Клапан отсекающий КО 302 М Ду-100, 80 Ру-32 МПа (320), 16 МПа (160)', # газ
        '7Агрегат для депарафинизации скважин АДПМ 12/150 на шасси Урал 4320 (6х6)', # транспорт
        '8Лодка для добычи родонита', # родонит
        '9Лодка для добычи алмазов Б-53 11134к', # алмазы
        '10Автоцистерна АЦПТ-9,5 на шасси УРАЛ 4320' # транспорт
    ]
ONE = 'оборудование для добычи'
TWO = 'транспорт'
cat = [ONE, TWO, TWO, ONE, ONE, ONE, TWO, ONE, ONE, TWO]
for i in range(10):
    print(f"({i + 1}, '{names[i]}', {random() * 10000:.2f}, {random() + randint(50000, 50000000):.2f}, '{cat[i]}'),")