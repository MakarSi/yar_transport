import numpy as np

# Задаем параметры для нормального распределения
mu = 2  # Среднее значение
sigma = 2  # Стандартное отклонение
T = 144  # Горизонт планирования
sleep = 12  # Время после которого никто никуда не едет
stations = 8  # Количество станций

seq = np.random.normal(mu, sigma, T - sleep)
noise = np.random.normal(0, 3, T - sleep)
seq -= abs(noise)
seq = np.concatenate([seq, np.zeros(sleep)])
nulls = np.zeros(T)

for i in range(stations):
    for j in range(stations):
        if i == 0 and j == 0: continue
        if j >= i:
            # Генерируем случайную последовательность с нормальным распределением
            t = np.random.normal(mu, sigma, T - sleep)
            # Добавляем небольшой шум
            noise = np.random.normal(0, 3, T - sleep)
            t -= abs(noise)
            t = np.concatenate([t, np.zeros(sleep)])

            seq = np.concatenate([seq, t])
        else:
            seq = np.concatenate([seq, nulls])

# Округляем значения до целых чисел в диапазоне от 0 до 80
seq = np.round(seq)
seq[seq < 0] = 0
seq[seq > 80] = 80

f = open('text.txt', 'w')
# Выводим результат
for i in range(len(seq)):
    print(int(seq[i]), ", ", end="")
    f.write(str(int(seq[i])) + ", ")
