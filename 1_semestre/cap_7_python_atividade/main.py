anos_fumando = float(input("A quantos anos você fuma? "))
valor_maco = float(input("Qual o valor atual do maço de cigarros? R$ "))
macos_por_dia = float(input("Quantos maços você fuma por dia, em média? "))

dias_por_ano = 365.25
montante_gasto = anos_fumando * dias_por_ano * macos_por_dia * valor_maco

if montante_gasto < 20000:
    mensagem = f"Com o valor R$ {montante_gasto:.2f}, você poderia ter dado entrada em um carro."
elif 20000 <= montante_gasto <= 50000:
    mensagem = f"Com o valor R$ {montante_gasto:.2f}, você poderia ter comprado um carro popular usado."
else:
    mensagem = f"Com o valor R$ {montante_gasto:.2f}, você poderia ter comprado um carro zero."

print(mensagem)
