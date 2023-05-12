import random

import numpy as np
import matplotlib.pyplot as plt

T = 180  # Горизонт планирования
sleep = 20  # Время после которого никто никуда не едет
stations = 16  # Количество станций

# задаем вероятности для каждого числа
probs = [0.98, 0.004, 0.005, 0.0025, 0.0025, 0.0025, 0.0015, 0.0, 0.0, 0.001, 0.001]

nulls = np.zeros(T)
seq = np.array([])

for i in range(stations):
    for j in range(stations):
        # if i == 0 and j == 0: continue
        if j >= i and (i < 8 and j <= 8 or i >= 8 and j > 8):  # люди не ездят сначала в одну сторону, потом в дргую
            # генерируем последовательность из 144 чисел с распределением probs
            t = np.random.choice(range(len(probs)), size=T - sleep, p=probs)
            t = np.concatenate([t, np.zeros(sleep)])

            # Студенты едут в университет
            if j == 8:
                # Люди, которые поедут в 8 утра
                # Задаем параметры всплеска
                mean = 10  # среднее значение
                std = 5  # стандартное отклонение
                height = 10  # высота всплеска

                # Создаем массив со значениями функции Гаусса
                x = np.arange(0, T-sleep, 1)
                gaussian = height * np.exp(-(x - mean) ** 2 / (2 * std ** 2))
                gaussian = np.concatenate([gaussian, np.zeros(sleep)])
                # Добавляем функцию Гаусса к последовательности
                t += np.round(gaussian)

            # Студенты едут из университета
            if i == 8:
                # Люди, которые поедут в 8 утра
                # Задаем параметры всплеска
                mean = 84  # среднее значение
                std = 5  # стандартное отклонение
                height = 10  # высота всплеска

                # Создаем массив со значениями функции Гаусса
                x = np.arange(0, T-sleep, 1)
                gaussian = height * np.exp(-(x - mean) ** 2 / (2 * std ** 2))
                gaussian = np.concatenate([gaussian, np.zeros(sleep)])
                # Добавляем функцию Гаусса к последовательности
                t += np.round(gaussian)

            seq = np.concatenate([seq, t])
        else:
            seq = np.concatenate([seq, nulls])

f = open('text.txt', 'w')
# Выводим результат
for i in range(len(seq)):
    #print(int(seq[i]), ", ", end="")
    f.write(str(int(seq[i])) + ", ")
print(np.sum(seq))


# Отображаем последовательность и функцию Гаусса
# Всплеск пассажиров, когда студенты едут в университет с 1 остановки
plt.plot(seq[1440:1440+180])
# Всплеск пассажиров, когда студенты едут из университета
plt.plot(seq[24660:24660+180])
# plt.plot(gaussian[0:180])
plt.show()
print(seq[1440:1440+180])
print(np.sum(seq))
print(len(seq))