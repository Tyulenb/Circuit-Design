def main():
    x = float(input("Первый элемент = "))
    if x == 0:
        print("Ошибка: Некорректный первый элемент")
        return

    n = float(input("Количество элементов = "))

    if n != int(n) or n <= 0:
        print("Ошибка: Некорректное количество элементов")
        return

    arr = [];
    arr.append(x)

    for i in range(int(n)-1):
        calc = arr[-1]**2 + n/arr[-1]
        if calc > 10**38 or abs(calc) < (10**-38):
            print(f"Ошибка: значение {i+2}-го элемента слишком большое")
            break
        arr.append(calc)

    print("Вычисленные значения: ")
    for i in range(len(arr)):
        print(f"{i+1}.", arr[i])

main()
#print(f"{arr[-1]} ** 2 + {n} / {arr[-1]} = {calc}")

