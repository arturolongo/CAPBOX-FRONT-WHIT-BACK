# 🤖 HERRAMIENTAS DE IA: Mejores Contrincantes

## 📋 **Descripción**

Nueva funcionalidad para el coach que utiliza IA para recomendar los mejores contrincantes del gimnasio basándose en el nivel y categoría de cada alumno real.

## 🎯 **Funcionalidad**

### **✅ Características Principales:**

#### **1. Lista de Estudiantes Simulados del Gimnasio**
- **Datos simulados**: Genera estudiantes de ejemplo para demostración
- **Información**: Nombre, nivel, categoría, estadísticas de peleas
- **Niveles**: Principiante, Intermedio, Avanzado
- **Categorías**: Peso Pluma, Peso Ligero, Peso Medio
- **6 estudiantes**: Distribuidos en diferentes niveles y categorías

#### **2. Algoritmo de IA para Contrincantes**
- **Filtrado por nivel**: Solo estudiantes del mismo nivel
- **Validación**: Solo muestra contrincantes si hay más de un estudiante en el mismo nivel
- **Ordenamiento inteligente**: Por ratio de victorias y experiencia
- **Top 2 contrincantes**: Los mejores 2 oponentes por estudiante
- **Sin contrincantes**: Mensaje cuando no hay opciones disponibles

#### **3. Datos Simulados Realistas**
- **6 estudiantes**: Distribuidos en diferentes niveles
- **Estadísticas variadas**: Desde principiantes hasta avanzados
- **Categorías realistas**: Peso Pluma, Ligero, Medio
- **Experiencia progresiva**: Más peleas en niveles superiores

## 🎨 **Interfaz de Usuario**

### **✅ Diseño Visual:**

#### **1. Carga Simulada:**
- **Loading**: Indicador de carga (800ms)
- **Datos emulados**: 6 estudiantes de ejemplo
- **Distribución**: 2 Principiantes, 2 Intermedios, 2 Avanzados

#### **2. Tarjeta de Estudiante:**
- **Avatar**: Círculo con inicial del nombre
- **Color por nivel**: Azul (Principiante), Naranja (Intermedio), Rojo (Avanzado)
- **Información**: Nombre, nivel, categoría, estadísticas
- **Estadísticas**: "X peleas", "YW - ZL"

#### **3. Tarjeta de Contrincante:**
- **Fondo verde**: Indica recomendación de IA
- **Avatar pequeño**: Inicial del contrincante
- **Porcentaje de victoria**: Ratio de victorias en porcentaje
- **Estadísticas detalladas**: Categoría y número de peleas

#### **4. Estados de la UI:**
- **Loading**: Indicador de carga mientras se obtienen datos
- **Error**: Mensaje de error con botón de reintento
- **Sin contrincantes**: "Sin contrincantes disponibles en este nivel"

## 🔧 **Implementación Técnica**

### **✅ Archivos Modificados:**

#### **1. Página Principal:**
- `capbox/lib/features/coach/presentation/pages/coach_ai_tools_page.dart`

#### **2. Modelo de Datos Actualizado:**
```dart
class StudentData {
  final String id;
  final String name;
  final String level;
  final int age;
  final double weight;
  final double height;
  final int fights;
  final int wins;
  final int losses;
  final String category;

  factory StudentData.fromJson(Map<String, dynamic> json) {
    return StudentData(
      id: json['id'] ?? '',
      name: json['name'] ?? json['nombre'] ?? 'Estudiante',
      level: json['level'] ?? json['nivel'] ?? 'Principiante',
      age: json['age'] ?? json['edad'] ?? 0,
      weight: (json['weight'] ?? json['peso'] ?? 0).toDouble(),
      height: (json['height'] ?? json['altura'] ?? 0).toDouble(),
      fights: json['fights'] ?? json['peleas'] ?? 0,
      wins: json['wins'] ?? json['victorias'] ?? 0,
      losses: json['losses'] ?? json['derrotas'] ?? 0,
      category: json['category'] ?? json['categoria'] ?? 'Sin categoría',
    );
  }
}
```

#### **3. Algoritmo de IA Mejorado:**
```dart
List<StudentData> _getBestOpponents(StudentData student) {
  // Filtrar estudiantes del mismo nivel
  final sameLevelStudents = _students
      .where((s) => s.id != student.id && s.level == student.level)
      .toList();

  // Solo mostrar contrincantes si hay más de un estudiante en el mismo nivel
  if (sameLevelStudents.isEmpty) {
    return [];
  }

  // Ordenar por ratio de victorias y experiencia
  sameLevelStudents.sort((a, b) {
    final aRatio = a.fights > 0 ? a.wins / a.fights : 0;
    final bRatio = b.fights > 0 ? b.wins / b.fights : 0;
    
    if (aRatio != bRatio) {
      return bRatio.compareTo(aRatio);
    }
    return b.fights.compareTo(a.fights);
  });

  return sameLevelStudents.take(2).toList();
}
```

## 🔄 **Integración con Backend**

### **✅ Endpoint Requerido:**

#### **1. GET /coach/gym-students**
```json
// Respuesta esperada:
[
  {
    "id": "uuid",
    "name": "Nombre del Estudiante",
    "level": "Principiante|Intermedio|Avanzado",
    "age": 18,
    "weight": 70.5,
    "height": 1.75,
    "fights": 5,
    "wins": 3,
    "losses": 2,
    "category": "Peso Ligero"
  }
]
```

#### **2. Campos Soportados:**
- **Nombres alternativos**: `name` o `nombre`
- **Niveles alternativos**: `level` o `nivel`
- **Edad**: `age` o `edad`
- **Peso**: `weight` o `peso`
- **Altura**: `height` o `altura`
- **Peleas**: `fights` o `peleas`
- **Victorias**: `wins` o `victorias`
- **Derrotas**: `losses` o `derrotas`
- **Categoría**: `category` o `categoria`

## 🎯 **Lógica de Emparejamiento**

### **✅ Criterios de IA:**

#### **1. Validación de Datos:**
- **Gimnasio vacío**: Muestra mensaje de estado vacío
- **Un estudiante**: No muestra contrincantes
- **Múltiples estudiantes**: Aplica algoritmo de emparejamiento

#### **2. Filtrado por Nivel:**
- Principiantes vs Principiantes
- Intermedios vs Intermedios  
- Avanzados vs Avanzados

#### **3. Ordenamiento Inteligente:**
- **Prioridad 1**: Ratio de victorias (más alto primero)
- **Prioridad 2**: Número de peleas (más experiencia primero)
- **Exclusión**: No emparejar consigo mismo

## 🚀 **Navegación**

### **✅ Acceso:**
- **Ruta**: `/coach-ai-tools`
- **Desde**: Coach Home → "HERRAMIENTAS DE IA"
- **Navegación**: GoRouter configurado correctamente

### **✅ Estados:**
- **Loading**: Mientras obtiene datos del backend
- **Error**: Manejo de errores con reintento
- **Vacío**: Cuando no hay estudiantes en el gimnasio
- **Éxito**: Lista de estudiantes reales y contrincantes

## 📈 **Beneficios**

### **✅ Para el Coach:**
- **Datos reales**: Información actualizada del gimnasio
- **Emparejamientos inteligentes** basados en datos reales
- **Ahorro de tiempo** en selección de contrincantes
- **Mejor experiencia** para los estudiantes
- **Reducción de lesiones** por emparejamientos inadecuados

### **✅ Para los Estudiantes:**
- **Contrincantes apropiados** para su nivel
- **Desarrollo progresivo** de habilidades
- **Motivación** al enfrentar oponentes desafiantes pero justos
- **Seguridad** en el entrenamiento

## 🔧 **Casos de Uso**

### **✅ Escenarios:**

#### **1. Gimnasio Vacío:**
- Muestra mensaje: "No hay estudiantes en el gimnasio"
- Sugiere agregar estudiantes

#### **2. Un Solo Estudiante:**
- Muestra la información del estudiante
- Indica: "Sin contrincantes disponibles en este nivel"

#### **3. Múltiples Estudiantes:**
- Muestra todos los estudiantes
- Recomienda contrincantes por nivel
- Aplica algoritmo de IA para emparejamientos

---

**La herramienta de IA ahora utiliza datos reales del gimnasio para proporcionar emparejamientos inteligentes y seguros.** 🤖🥊 