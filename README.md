# Processador MIPS Monociclo

Implementação de um processador MIPS monociclo (single-cycle) em Verilog, desenvolvido como projeto acadêmico de Arquitetura e Organização de Computadores.

## 📋 Sobre o Projeto

Este repositório contém a implementação completa de um processador MIPS de 32 bits em arquitetura monociclo, onde cada instrução é executada em um único ciclo de clock. O projeto foi desenvolvido em Verilog e pode ser sintetizado utilizando Quartus Prime da Intel/Altera.

## 🏗️ Arquitetura

O processador implementa a arquitetura MIPS clássica com os seguintes componentes principais:

- **Banco de Registradores**: 32 registradores de 32 bits
- **Unidade Lógica e Aritmética (ALU)**: Executa operações aritméticas e lógicas
- **Memória de Instruções**: Armazena o programa a ser executado
- **Memória de Dados**: Armazena dados durante a execução
- **Unidade de Controle**: Gera sinais de controle para coordenar a operação do processador
- **Program Counter (PC)**: Mantém o endereço da próxima instrução

## 🔧 Instruções Suportadas

O processador suporta as seguintes instruções MIPS:

### Tipo R (Registro)
- `add` - Adição
- `sub` - Subtração
- `and` - E lógico
- `or` - OU lógico
- `slt` - Set on Less Than
- `nor` - NOR lógico

### Tipo I (Imediato)
- `lw` - Load Word
- `sw` - Store Word
- `beq` - Branch if Equal
- `addi` - Add Immediate

### Tipo J (Jump)
- `j` - Jump incondicional

## 📁 Estrutura do Repositório

```
Processador-Mips-Monociclo/
├── modules/              # Módulos Verilog dos componentes
├── main_mips.v          # Arquivo principal do processador
├── mips_tb.v            # Testbench para simulação
├── Processador-Mips-Monociclo.qpf   # Arquivo de projeto Quartus
├── Processador-Mips-Monociclo.qsf   # Configurações Quartus
├── .gitignore
├── LICENSE
└── README.md
```

## 🚀 Como Utilizar

### Pré-requisitos

- **Quartus Prime** (Intel/Altera) - para síntese e simulação
- **ModelSim** ou **Quartus Simulator** - para simulação funcional
- Conhecimento básico de Verilog e arquitetura MIPS

### Simulação

1. Clone o repositório:
```bash
git clone https://github.com/emanuelrodrigues2005/Processador-Mips-Monociclo.git
cd Processador-Mips-Monociclo
```

2. Abra o projeto no Quartus Prime:
   - Abra o arquivo `Processador-Mips-Monociclo.qpf`

3. Execute a simulação:
   - Configure o testbench `mips_tb.v`
   - Execute a simulação no ModelSim ou Quartus Simulator
   - Verifique as formas de onda para validar o funcionamento

### Síntese

1. No Quartus Prime, compile o projeto
2. Verifique os relatórios de síntese para recursos utilizados
3. Programe o dispositivo FPGA (se disponível)

## 🔍 Testbench

O arquivo `mips_tb.v` contém casos de teste para validar o funcionamento do processador. Ele simula a execução de instruções e verifica se os resultados estão corretos.

## 🎓 Conceitos Implementados

- **Caminho de Dados (Datapath)**: Rota por onde os dados fluem no processador
- **Unidade de Controle**: Lógica que coordena as operações
- **Pipeline de Instrução**: Busca, decodificação e execução em ciclo único
- **Multiplexadores**: Seleção de entradas de dados
- **Extensão de Sinal**: Para valores imediatos de 16 para 32 bits

## 👥 Contribuidores

- Emanuel Jose Tenório Rodrigues[emanuelrodrigues2005](https://github.com/emanuelrodrigues2005)
- Gustavo Henrique Evangelista de Souza [HenriqueNoHub](https://github.com/HenriqueNoHub)
- Joao Ricardo De Andrade Ferreira Barbosa [zauns](https://github.com/zauns)
- Heitor Carvalho Santana[Heitor-C-S](https://github.com/Heitor-C-S)

## 📝 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.