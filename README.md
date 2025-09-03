# Katholiks App

Um aplicativo Flutter para a comunidade católica, oferecendo recursos de fé, oração e conexão comunitária.

## Estrutura do Projeto

```
lib/
├── main.dart                    # Ponto de entrada do aplicativo
├── models/                      # Modelos de dados
│   └── user.dart               # Modelo de usuário
├── screens/                     # Telas do aplicativo
│   ├── splash_screen.dart      # Tela de inicialização
│   ├── auth/                   # Telas de autenticação
│   │   ├── login_screen.dart   # Tela de login
│   │   └── register_screen.dart # Tela de registro
│   └── home/                   # Telas principais
│       ├── home_screen.dart    # Tela principal com navegação
│       └── profile_screen.dart # Tela de perfil do usuário
├── services/                   # Serviços do aplicativo
│   └── auth_service.dart       # Serviço de autenticação
├── utils/                      # Utilitários
│   └── routes.dart            # Configuração de rotas
└── widgets/                    # Widgets reutilizáveis
    ├── custom_button.dart     # Botão customizado
    └── custom_text_field.dart # Campo de texto customizado
```

## Funcionalidades Implementadas

### 🔐 Autenticação
- ✅ Tela de login com validação
- ✅ Tela de registro/cadastro
- ✅ Validação de email e senha
- ✅ Gerenciamento de estado de loading
- ✅ Serviço de autenticação simulado

### 🏠 Navegação
- ✅ Splash screen animada
- ✅ Sistema de rotas configurado
- ✅ Navegação por bottom tabs
- ✅ Navegação entre telas de auth

### 🎨 Interface
- ✅ Design Material 3
- ✅ Tema claro e escuro
- ✅ Widgets customizados reutilizáveis
- ✅ Responsividade básica

### 📱 Telas Principais
- ✅ **Início**: Dashboard com recursos principais
- ✅ **Explorar**: Seção de descoberta (em desenvolvimento)
- ✅ **Comunidade**: Interação social (em desenvolvimento)
- ✅ **Perfil**: Gerenciamento do perfil do usuário

### 🧩 Recursos Planejados
- 📖 **Bíblia**: Leitura das escrituras
- 🙏 **Orações**: Coleção de orações
- 📅 **Eventos**: Calendário de atividades
- ⛪ **Paróquias**: Localizador de igrejas

## Como Executar

1. Certifique-se de ter o Flutter instalado
2. Clone o projeto
3. Execute os comandos:

```bash
flutter pub get
flutter run
```

## Próximos Passos

1. **Autenticação Real**: Integrar com Firebase ou backend
2. **Persistência**: Implementar armazenamento local
3. **Recursos Católicos**: 
   - Integrar API de leituras bíblicas
   - Adicionar coleção de orações
   - Implementar calendário litúrgico
4. **Comunidade**: Sistema de posts e comentários
5. **Localizador**: Mapa de paróquias próximas
6. **Notificações**: Lembretes de oração e eventos

## Tecnologias Utilizadas

- **Flutter**: Framework de desenvolvimento
- **Material 3**: Design system
- **Dart**: Linguagem de programação

## Arquitetura

O projeto segue uma arquitetura simples e organizada:

- **Models**: Estruturas de dados
- **Services**: Lógica de negócio e APIs
- **Screens**: Interface do usuário
- **Widgets**: Componentes reutilizáveis
- **Utils**: Utilitários e configurações

## Contribuição

Este é um projeto em desenvolvimento. Contribuições são bem-vindas!
