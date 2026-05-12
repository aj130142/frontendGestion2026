# Documentación Técnica: Sistema de Gestión TechSolutions (Frontend)

## 1. Resumen Ejecutivo
El Frontend de TechSolutions es una aplicación multiplataforma desarrollada con Flutter, diseñada para ofrecer una interfaz de usuario intuitiva y de alto rendimiento. El sistema permite la gestión de proyectos, tareas y clientes, integrando visualizaciones analíticas avanzadas y generación de reportes bajo una arquitectura orientada a la reactividad y escalabilidad.

## 2. Arquitectura del Sistema

### 2.1 Patrón de Gestión de Estado
La aplicación utiliza el patrón **Provider** para la gestión de estados globales y la inyección de dependencias. Este enfoque permite:
- Desacoplamiento de la lógica de negocio de la interfaz de usuario.
- Actualizaciones reactivas y eficientes de la UI tras cambios en los datos.
- Centralización del estado de autenticación y permisos del usuario.

### 2.2 Estructura del Proyecto (Clean Architecture)
El código se organiza en capas lógicas para facilitar el mantenimiento:
- **Models**: Definición de estructuras de datos y lógica de serialización (JSON).
- **Services**: Capa de comunicación con la API REST y servicios externos (PDF, Almacenamiento local).
- **Providers**: Gestión de estados reactivos y lógica de negocio para cada módulo.
- **Screens**: Componentes de interfaz de usuario organizados por funcionalidad.
- **Widgets**: Componentes reutilizables para mantener la consistencia visual.

### 2.3 Jerarquía de Directorios

```text
lib/
├── models/         # Clases de datos (User, Project, Task, etc.)
├── providers/      # Lógica de estado y negocio (Auth, Projects, Tasks)
├── services/       # Clientes API y servicios auxiliares (PDF, Dashboard)
├── screens/        # Vistas de la aplicación (Dashboard, Listas, Formularios)
│   ├── auth/       # Módulo de Inicio de Sesión
│   ├── projects/   # Gestión de Proyectos
│   ├── tasks/      # Seguimiento de Tareas
│   └── ...         # Otros módulos (Clientes, Usuarios)
├── widgets/        # Componentes UI compartidos (AppDrawer, Gráficas)
├── utils/          # Configuraciones de rutas y constantes
└── main.dart       # Punto de entrada y configuración de la App
```

## 3. Módulos Funcionales Principales

### 3.1 Autenticación y Autorización Dinámica
- **Gestión de Sesión**: Almacenamiento seguro de tokens JWT (SharedPreferences para móvil/Web local).
- **Sistema de Permisos**: La interfaz se adapta dinámicamente según la matriz de permisos RBAC obtenida del backend, ocultando o mostrando funcionalidades de creación, edición o eliminación.

### 3.2 Dashboard Analítico
- **Visualización de Datos**: Integración de gráficas circulares dinámicas para mostrar el estado de las tareas por proyecto.
- **Agregación en Tiempo Real**: Cálculo de porcentajes de progreso y estados actuales directamente desde los servicios de analítica.

### 3.3 Gestión de Tareas y Proyectos
- **Seguimiento Detallado**: Vistas de lista con filtrado avanzado por título, responsable y prioridad.
- **Formularios Inteligentes**: Validación de reglas de negocio en tiempo real (ej. fechas de tareas restringidas al rango del proyecto).

### 3.4 Sistema de Reportes PDF
- **Generación On-the-Fly**: Creación de documentos PDF profesionales desde la aplicación.
- **Visualizaciones Gráficas**: Inclusión de diagramas estadísticos dentro del reporte para una mejor interpretación de los datos exportados.

## 4. Especificaciones Técnicas

### 4.1 Comunicación con el Servidor
- **ApiService**: Cliente HTTP personalizado con manejo global de errores y adjunto automático de tokens de autorización.
- **Seguridad**: Implementación de interceptores para la detección de tokens expirados.

### 4.2 Estándares Visuales
- **Diseño Responsivo**: Adaptación automática para dispositivos móviles y entornos web.
- **Navegación**: Utilización de `go_router` para una navegación basada en rutas declarativas y soporte de parámetros en URL.

## 5. Guía de Operación

### 5.1 Configuración del Entorno de Desarrollo
1. **Requisitos**: Flutter SDK 3.10+, Dart SDK 3.0+.
2. **Dependencias**:
   ```bash
   flutter pub get
   ```

### 5.2 Compilación y Despliegue
- **Ejecución en Desarrollo**:
  ```bash
  flutter run
  ```
- **Compilación Web (Producción)**:
  ```bash
  flutter build web --release
  ```
- **Compilación Móvil (Android)**:
  ```bash
  flutter build apk --release
  ```
